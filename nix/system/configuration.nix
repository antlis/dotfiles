{ config, pkgs, lib, vpnServerIp ? "127.0.0.1", vpnSshHost ? "vpn-host", vpnChainEntryIp ? "127.0.0.1", vpnCfEntryIp ? "127.0.0.1", vpnOlcrtcRelayIps ? [ "127.0.0.1" ], amneziaServerIps ? [ ], workVpnName ? "", workVpnTransportIps ? [ ], corpVpnSshHost ? "", corpVpnSubnets ? [ ], ... }:
let
  olcrtc = pkgs.callPackage ../pkgs/olcrtc.nix { };
  naiveproxy = pkgs.callPackage ../pkgs/naiveproxy.nix { };
in
{
  imports =
    [
      ../home/home.nix
      ./packages/packages.nix
      ./bluetooth.nix
      ./nfs-media.nix
      ./nfs-home.nix
      ./nfs-remote.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "kvm_intel" "kvm_amd" "tiny_power_button" ];

  # Hibernation settings
  boot.initrd.kernelModules = [ "nvme_core" "nvme" "ext4" ];
  powerManagement.enable = true;
  # Use root partition UUID for resume
  boot.resumeDevice = "/dev/disk/by-uuid/e49c4ff0-e799-4ee0-a97c-666e71c3a004";
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];
  # Suspend-then-hibernate and power buttons
  services.power-profiles-daemon.enable = true;
  services.logind.settings = {
    Login = {
      HandleLidSwitch            = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      # HandlePowerKey             = "hibernate";
      HandlePowerKeyLongPress    = "poweroff";
    };
  };
  services.acpid = {
    enable = true;
    handlers = {
      # power = {
      #   event = "button/power.*";
      #   action = "${pkgs.systemd}/bin/systemctl hibernate";
      # };
      lid = {
        event = "button/lid.*";
        action = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      };
    };
  };
  # Set suspend-to-hibernate delay (default 1h)
  environment.etc."systemd/sleep.conf".text = ''
    [Sleep]
    HibernateDelaySec=5min
  '';

  # Firmware updates (fwupd/LVFS). Needed to check for a BIOS update that may
  # fix the e820/ACPI memory-map jitter breaking hibernate resume on this T480s.
  services.fwupd.enable = true;

  services.openssh.enable = true;
  # Enable sshd, but don't start it on boot
  systemd.services.sshd.wantedBy = lib.mkForce [];

  # Mesh VPN client (joins our self-hosted headscale control plane). Only routes the
  # 100.x tailnet, so it coexists with the circumvention tiers + Amnezia (no default-route
  # grab). The one-time `tailscale up --login-server … --authkey …` join command — with the
  # private server URL + key — lives in the vault note, kept out of this public repo.
  services.tailscale.enable = true;
  # open UDP 41641 so peers can reach us for DIRECT connections (else inbound
  # disco/handshake hits nixos-fw-refuse -j DROP and every path stays relayed).
  services.tailscale.openFirewall = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # iHD VAAPI driver for the Intel UHD 620 (Kaby Lake) — hardware video decode,
    # needed by Moonlight (game streaming) and any VAAPI consumer.
    extraPackages = with pkgs; [ intel-media-driver ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "lad" ];

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-l2tp
      networkmanager-strongswan
    ];
    # Split-tunnel coexistence for the corporate work VPN (workVpnName): when it
    # comes up, pin every subnet it pushes (corp internal nets + corp DNS) to the
    # main table ABOVE any active sing-box circumvention tier's rules, so corp
    # traffic uses the work tunnel while everything else stays on the AI tunnel.
    dispatcherScripts = lib.optionals (workVpnName != "") [{
      type = "basic";
      source = pkgs.writeShellScript "work-vpn-split" ''
        [ "$CONNECTION_ID" = "${workVpnName}" ] || exit 0
        ip=${pkgs.iproute2}/bin/ip
        iface="''${VPN_IP_IFACE:-$DEVICE_IP_IFACE}"
        case "$2" in
          vpn-up|up)
            for net in $($ip route show dev "$iface" 2>/dev/null | ${pkgs.gawk}/bin/awk '$1!="default"{print $1}'); do
              $ip rule add to "$net" lookup main priority 91 2>/dev/null || true
            done
            ;;
          vpn-down|down)
            while $ip rule del priority 91 2>/dev/null; do :; done
            ;;
        esac
      '';
    }];
  };
  # Always-on: pin the work VPN's transport/front-door IPs to the main table so
  # the OpenVPN (UDP) handshake reaches them over the bare line even when a
  # sing-box circumvention tier is active (its TCP-only/QUIC-reject tun can't
  # carry the handshake). Higher priority (90) than the dispatcher's subnet pins (91).
  systemd.services.work-vpn-transport-pin = lib.mkIf (workVpnTransportIps != [ ]) {
    description = "Pin work VPN transport IPs to main routing table";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "work-vpn-pin-up" (lib.concatMapStringsSep "\n" (ip: ''
        ${pkgs.iproute2}/bin/ip rule del to ${ip}/32 lookup main priority 90 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule add to ${ip}/32 lookup main priority 90
      '') workVpnTransportIps);
      ExecStop = pkgs.writeShellScript "work-vpn-pin-down" (lib.concatMapStringsSep "\n" (ip: ''
        ${pkgs.iproute2}/bin/ip rule del to ${ip}/32 lookup main priority 90 2>/dev/null || true
      '') workVpnTransportIps);
    };
  };

  # Always-on: pin Docker's bridge pool (10.210.0.0/16, see default-address-pools
  # below) to the main table so host->container traffic — including DNAT'd
  # published ports like MariaDB on 127.0.0.1:3306 — bypasses any active sing-box
  # circumvention tier's rules (~prio 9000) and uses the docker bridge. Disjoint
  # from the corp pins (90/91), so the AI tunnel and the local stack run at once.
  systemd.services.docker-subnet-pin = {
    description = "Pin Docker bridge pool to main routing table (coexist with sing-box tiers)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "docker-subnet-pin-up" ''
        ${pkgs.iproute2}/bin/ip rule del to 10.210.0.0/16 lookup main priority 89 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule add to 10.210.0.0/16 lookup main priority 89
      '';
      ExecStop = pkgs.writeShellScript "docker-subnet-pin-down" ''
        ${pkgs.iproute2}/bin/ip rule del to 10.210.0.0/16 lookup main priority 89 2>/dev/null || true
      '';
    };
  };

  # Corp access via Moscow gateway: vps-msk-2 runs the corp OpenVPN, exposing
  # internal subnets. corp-msk-route adds a /32 host route for vps-msk-2 so it
  # bypasses any active Amnezia full-tunnel (/1 routes). corp-msk-proxy opens
  # SSH -D 10800 giving a SOCKS5 on localhost:10800 (no credentials — SSH key auth).
  # Browser uses ~/.config/umbrella-proxy.pac → routes *.corp.internal through it.
  # Git SSH uses ProxyJump vps-msk-2 (in ~/.ssh/config).
  # Corp access via Moscow gateway (corpVpnSshHost) which runs the corp OpenVPN.
  # corpVpnSubnets: internal subnets to route transparently via tun2socks → SOCKS5 → SSH.
  # Values live in private.nix (gitignored); empty defaults disable all three services.
  systemd.services.corp-tun = lib.mkIf (corpVpnSubnets != [ ]) {
    description = "Corp transparent tunnel — tun2socks via SOCKS5 → ${corpVpnSshHost}";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "corp-msk-proxy.service" ];
    wants = [ "network-online.target" ];
    requires = [ "corp-msk-proxy.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "corp-tun-start" ''
        set -e
        ${pkgs.tun2socks}/bin/tun2socks -device tun://corp0 -proxy socks5://127.0.0.1:10800 -loglevel silent &
        T=$!
        for i in $(seq 1 20); do
          ${pkgs.iproute2}/bin/ip link show corp0 >/dev/null 2>&1 && break
          sleep 0.5
        done
        ${pkgs.iproute2}/bin/ip link set corp0 up
        for subnet in ${lib.concatStringsSep " " corpVpnSubnets}; do
          ${pkgs.iproute2}/bin/ip route replace "$subnet" dev corp0
        done
        trap "kill $T 2>/dev/null" TERM INT
        wait $T
      '';
      ExecStopPost = pkgs.writeShellScript "corp-tun-stop" ''
        for subnet in ${lib.concatStringsSep " " corpVpnSubnets}; do
          ${pkgs.iproute2}/bin/ip route del "$subnet" 2>/dev/null || true
        done
      '';
      Restart = "on-failure";
      RestartSec = 3;
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
    };
  };

  systemd.services.corp-msk-route = lib.mkIf (corpVpnSshHost != "") {
    description = "Route corp gateway direct, bypassing Amnezia full-tunnel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "corp-msk-route-up" ''
        ${pkgs.iproute2}/bin/ip route replace ${vpnChainEntryIp} via 192.168.0.1 dev wlp61s0 2>/dev/null || true
      '';
      ExecStop = pkgs.writeShellScript "corp-msk-route-down" ''
        ${pkgs.iproute2}/bin/ip route del ${vpnChainEntryIp} 2>/dev/null || true
      '';
    };
  };

  # AmneziaWG (self-hosted awg2) endpoint exemption — coexist with the full-tunnel.
  # AmneziaVPN full-tunnels via policy routing (`ip rule 220: from all lookup 220`
  # -> default dev amn0). Premium servers get priority-90 exemption rules so their
  # traffic stays direct, but the self-hosted awg2 servers get NONE — so only the
  # first handshake init escapes (a race before amn0's routing is up); every retry
  # then loops back into amn0 and the handshake never completes ("infinite
  # connecting"). Diagnosed 2026-06-29: init reaches the server, server replies once,
  # no retry ever arrives again. Fix: add a high-priority (91, just after Premium's
  # 90) `ip rule` per server IP -> main table, which follows the current physical
  # default route — so it works on any network, not just the home LAN. Bound to amn0
  # so it (re)asserts on every connect and ExecStop removes the rules on disconnect.
  systemd.services.amnezia-server-route = lib.mkIf (amneziaServerIps != [ ]) {
    description = "Exempt self-hosted AmneziaWG server IPs from the full-tunnel (else awg2 handshakes loop into amn0) + keep the Tailscale mesh direct";
    bindsTo = [ "sys-subsystem-net-devices-amn0.device" ];
    after = [ "sys-subsystem-net-devices-amn0.device" ];
    wantedBy = [ "sys-subsystem-net-devices-amn0.device" ];
    # lifecycle is entirely amn0-device-driven; don't let nixos switch try to
    # start/stop it (it can't start with amn0 absent → cosmetic switch failure).
    restartIfChanged = false;
    stopIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "amnezia-server-route-up" ''
        ${pkgs.coreutils}/bin/sleep 3   # let Amnezia install its own routing first
        gwline=$(${pkgs.iproute2}/bin/ip -o route show default | ${pkgs.gnugrep}/bin/grep -v amn0 | ${pkgs.coreutils}/bin/head -1)
        gw=$(echo "$gwline" | ${pkgs.gnused}/bin/sed -nE 's/.*via ([0-9.]+).*/\1/p')
        dev=$(echo "$gwline" | ${pkgs.gnused}/bin/sed -nE 's/.*dev ([^ ]+).*/\1/p')
        for ip in ${lib.concatStringsSep " " amneziaServerIps}; do
          while ${pkgs.iproute2}/bin/ip rule del to "$ip/32" lookup main priority 91 2>/dev/null; do :; done
          ${pkgs.iproute2}/bin/ip rule add to "$ip/32" lookup main priority 91
          [ -n "$gw" ] && ${pkgs.iproute2}/bin/ip route replace "$ip" via "$gw" dev "$dev" 2>/dev/null || true
        done
        # --- Tailscale mesh coexistence -------------------------------------
        # Amnezia full-tunnels by injecting 0.0.0.0/1 + 128.0.0.0/1 dev amn0 into
        # the MAIN table (both more specific than the physical /0 default), so
        # even Tailscale's own `fwmark 0x80000 -> main` bypass still lands in amn0
        # and mesh peers get reached via PL (~230ms) instead of their real
        # endpoints. Give the fwmarked Tailscale underlay its own table (100)
        # holding just the physical default, and point a high-priority rule
        # (above Amnezia's 220) at it. The overlay (100.64.0.0/10) stays on main —
        # Tailscale's /10 route there beats amn0's /1, so replies leave tailscale0.
        if [ -n "$dev" ]; then
          # copy the physical iface's on-link (connected) routes into table 100 so
          # same-LAN peers (e.g. arch-t480 on 192.168.x) resolve directly instead
          # of being sent via the gateway — otherwise Tailscale can't punch a LAN path.
          ${pkgs.iproute2}/bin/ip -o route show table main dev "$dev" scope link 2>/dev/null | while read -r r; do
            ${pkgs.iproute2}/bin/ip route replace $r dev "$dev" table 100 2>/dev/null || true
          done
        fi
        if [ -n "$gw" ] && [ -n "$dev" ]; then
          ${pkgs.iproute2}/bin/ip route replace default via "$gw" dev "$dev" table 100
        fi
        while ${pkgs.iproute2}/bin/ip rule del priority 100 fwmark 0x80000/0xff0000 lookup 100 2>/dev/null; do :; done
        ${pkgs.iproute2}/bin/ip rule add priority 100 fwmark 0x80000/0xff0000 lookup 100
        while ${pkgs.iproute2}/bin/ip rule del to 100.64.0.0/10 lookup main priority 91 2>/dev/null; do :; done
        ${pkgs.iproute2}/bin/ip rule add to 100.64.0.0/10 lookup main priority 91
        ${pkgs.iproute2}/bin/ip route flush cache 2>/dev/null || true
      '';
      ExecStop = pkgs.writeShellScript "amnezia-server-route-down" ''
        for ip in ${lib.concatStringsSep " " amneziaServerIps}; do
          while ${pkgs.iproute2}/bin/ip rule del to "$ip/32" lookup main priority 91 2>/dev/null; do :; done
          ${pkgs.iproute2}/bin/ip route del "$ip" 2>/dev/null || true
        done
        while ${pkgs.iproute2}/bin/ip rule del priority 100 fwmark 0x80000/0xff0000 lookup 100 2>/dev/null; do :; done
        ${pkgs.iproute2}/bin/ip route flush table 100 2>/dev/null || true
        while ${pkgs.iproute2}/bin/ip rule del to 100.64.0.0/10 lookup main priority 91 2>/dev/null; do :; done
      '';
    };
  };

  # AmneziaVPN routes ALL IPv6 into the tunnel (::/1 + 8000::/1 dev amn0), but the
  # servers have no working IPv6 egress — so every v6 destination black-holes. Since
  # most sites are dual-stack and DNS returns AAAA, browsers try v6 first and stall:
  # "connects but no pages open". Replace the tunnel's v6 split-default with
  # `unreachable` so v6 fails instantly and happy-eyeballs falls back to v4 (which
  # works through the tunnel). Privacy-safe: v6 just stops, no leak. Bound to the
  # amn0 device so it (re)asserts on every connect and — crucially — the ExecStop
  # removes the dev-less unreachable routes when amn0 goes away, otherwise they would
  # black-hole IPv6 with the VPN off.
  systemd.services.amnezia-ipv6-blackhole = {
    description = "Fail-fast IPv6 while AmneziaWG is up (server has no v6 egress; forces v4 fallback)";
    bindsTo = [ "sys-subsystem-net-devices-amn0.device" ];
    after = [ "sys-subsystem-net-devices-amn0.device" ];
    wantedBy = [ "sys-subsystem-net-devices-amn0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # settle: let Amnezia finish adding its routes before we override them
      ExecStart = pkgs.writeShellScript "amnezia-ipv6-blackhole-up" ''
        ${pkgs.coreutils}/bin/sleep 2
        ${pkgs.iproute2}/bin/ip -6 route replace unreachable ::/1 metric 1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route replace unreachable 8000::/1 metric 1 2>/dev/null || true
      '';
      ExecStop = pkgs.writeShellScript "amnezia-ipv6-blackhole-down" ''
        ${pkgs.iproute2}/bin/ip -6 route del unreachable ::/1 metric 1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route del unreachable 8000::/1 metric 1 2>/dev/null || true
      '';
    };
  };

  systemd.services.corp-msk-proxy = lib.mkIf (corpVpnSshHost != "") {
    description = "Corp SOCKS proxy — SSH -D 10800 via ${corpVpnSshHost}";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "corp-msk-route.service" ];
    wants = [ "network-online.target" ];
    requires = [ "corp-msk-route.service" ];
    serviceConfig = {
      Type = "simple";
      User = "lad";
      Environment = "HOME=/home/lad";
      ExecStart = "${pkgs.openssh}/bin/ssh -D 10800 -N -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=accept-new -i /home/lad/.ssh/corp_msk_service -F /home/lad/.ssh/config ${corpVpnSshHost}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  services.strongswan = {
    enable = true;
    secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  };
  environment.etc."strongswan.conf".text = ''
    charon {
      integrity_test = no
    }
  '';
  services.xl2tpd.enable = true;
  environment.etc."NetworkManager/VPN/nm-l2tp-service.name".source = "${pkgs.networkmanager-l2tp}/lib/NetworkManager/VPN/nm-l2tp-service.name";
  environment.systemPackages = with pkgs; [
    ppp
    hubstaff
  ];

  virtualisation.docker.enable = true;
  # Keep Docker's bridge networks off the 172.16/12 space the sing-box
  # circumvention tiers use. The naive tier's tun lands on 172.19.0.1/30, which
  # collided with Docker's default 172.19.0.0/16 (the AppHost "aspire" network)
  # and broke host->container connections — e.g. the API reaching MariaDB on
  # 127.0.0.1:3306 (DNAT'd to the container's 172.x address, then hijacked into
  # table 2022 by the tier's policy rules). Park Docker on 10.210.x instead.
  # NOTE: existing networks keep their old subnet — after rebuild run
  #   docker compose down (AppHost compose files) and bring the stack back up so
  #   they recreate from this pool (or `docker network rm` the apphost nets).
  virtualisation.docker.daemon.settings.default-address-pools = [
    { base = "10.210.0.0/16"; size = 24; }
  ];

  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT    = "ru_RU.UTF-8";
    LC_MONETARY       = "ru_RU.UTF-8";
    LC_NAME           = "ru_RU.UTF-8";
    LC_NUMERIC        = "ru_RU.UTF-8";
    LC_PAPER          = "ru_RU.UTF-8";
    LC_TELEPHONE      = "ru_RU.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock-color
        dmenu
      ];
    };
  };

  services.displayManager = {
    gdm.enable = true;
    defaultSession = "none+i3";
  };
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.lad = {
    isNormalUser = true;
    description = "lad";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
  users.defaultUserShell = pkgs.zsh;

  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.chromium.enable = true;

  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    BROWSER = "brave";
    PAGER   = "more";
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.amnezia-vpn.enable = true;
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };
  programs.nix-ld.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.libinput = {
    enable = true;
    touchpad = {
      accelSpeed        = "1";
      accelProfile      = "flat";
      disableWhileTyping = true;
      tapping           = true;
      naturalScrolling  = false;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Binary cache for the pi coding agent (pi.nix flake) so it isn't built locally.
  nix.settings.substituters = [ "https://pi.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
  ];

  # --- VPN toggles (reality-on/off, hysteria-on/off, ssh-vpn-on/off) ---
  # Run as root so sing-box can create the tun device and sshuttle can set routes.
  # Not started at boot (no wantedBy) — toggled on demand from the desktop/CLI.
  systemd.services.reality-vpn = let
    serverIp = vpnServerIp;
    # Pin traffic to the VPN server to the main routing table (real gateway), at a
    # higher priority than sing-box's auto_route rules — otherwise sing-box's own
    # connection to the server loops back into the tun and times out.
    pinRoute = pkgs.writeShellScript "reality-pin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule add to ${serverIp}/32 lookup main priority 100
    '';
    unpinRoute = pkgs.writeShellScript "reality-unpin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
    '';
  in {
    description = "Reality VPN (sing-box full tunnel)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pinRoute}";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /home/lad/.config/sing-box/reality.json";
      ExecStopPost = "${unpinRoute}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.hysteria-vpn = let
    serverIp = vpnServerIp;
    pinRoute = pkgs.writeShellScript "hysteria-pin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule add to ${serverIp}/32 lookup main priority 100
    '';
    unpinRoute = pkgs.writeShellScript "hysteria-unpin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
    '';
  in {
    description = "Hysteria2 VPN (sing-box full tunnel, UDP/QUIC)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pinRoute}";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /home/lad/.config/sing-box/hysteria.json";
      ExecStopPost = "${unpinRoute}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.chain-vpn = let
    serverIp = vpnChainEntryIp;
    pinRoute = pkgs.writeShellScript "chain-pin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule add to ${serverIp}/32 lookup main priority 100
    '';
    unpinRoute = pkgs.writeShellScript "chain-unpin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
    '';
  in {
    description = "Chain VPN (sing-box multi-hop: domestic entry -> foreign exit)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pinRoute}";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /home/lad/.config/sing-box/chain.json";
      ExecStopPost = "${unpinRoute}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  # XHTTP bridge: Xray does VLESS-XHTTP to Cloudflare (defeats CF's WS buffering),
  # exposing a local SOCKS that the cf-vpn tun routes into. PartOf cf-vpn so it
  # starts/stops together. (sing-box can't do XHTTP, hence the Xray bridge.)
  systemd.services.cf-bridge = {
    description = "Cloudflare XHTTP bridge (Xray: SOCKS127.0.0.1:1080 -> VLESS-XHTTP via Cloudflare)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    partOf = [ "cf-vpn.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xray}/bin/xray run -c /home/lad/.config/xray/cf.json";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.cf-vpn = let
    serverIp = vpnCfEntryIp;
    pinRoute = pkgs.writeShellScript "cf-pin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule add to ${serverIp}/32 lookup main priority 100
    '';
    unpinRoute = pkgs.writeShellScript "cf-unpin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
    '';
  in {
    description = "Cloudflare-fronted VPN (sing-box tun -> Xray XHTTP bridge -> Cloudflare)";
    after = [ "network-online.target" "cf-bridge.service" ];
    wants = [ "network-online.target" ];
    requires = [ "cf-bridge.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pinRoute}";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /home/lad/.config/sing-box/cloudflare.json";
      ExecStopPost = "${unpinRoute}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.olcrtc-bridge = let
    # The exit server's alpha reconnect logic can wedge after a disconnect; restart it
    # (while the previous link is still up) so the bridge always meets a fresh peer.
    serverRefresh = pkgs.writeShellScript "olcrtc-server-refresh" ''
      # Which exit to refresh follows the active olcrtc tier: the menu writes the SSH host
      # alias to srv-host when switching NL<->PL (defaults to ${vpnSshHost} if absent).
      host=$(${pkgs.coreutils}/bin/cat /home/lad/.config/olcrtc/srv-host 2>/dev/null || echo ${vpnSshHost})
      ${pkgs.openssh}/bin/ssh -i /home/lad/.ssh/vpn_ed25519 -o IdentitiesOnly=yes \
        -F /home/lad/.ssh/config -o UserKnownHostsFile=/home/lad/.ssh/known_hosts \
        -o StrictHostKeyChecking=accept-new -o ConnectTimeout=12 \
        "$host" 'systemctl restart olcrtc'
    '';
  in {
    description = "olcrtc client bridge (WebRTC-over-Jitsi -> SOCKS 127.0.0.1:8808)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    partOf = [ "olcrtc-vpn.service" ];
    serviceConfig = {
      Type = "simple";
      User = "lad";
      WorkingDirectory = "/home/lad/.config/olcrtc";
      ExecStartPre = [ "-${serverRefresh}" "${pkgs.coreutils}/bin/sleep 5" ];
      ExecStart = "${olcrtc}/bin/olcrtc /home/lad/.config/olcrtc/client.yaml";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.olcrtc-vpn = let
    # Pin signaling + TURN IPs (from private.nix) so the bridge's WebRTC bypasses the tun.
    jitsiIps = vpnOlcrtcRelayIps;
    pinRoute = pkgs.writeShellScript "olcrtc-pin-route" ''
      for ip in ${lib.concatStringsSep " " jitsiIps}; do
        ${pkgs.iproute2}/bin/ip rule del to $ip/32 lookup main priority 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule add to $ip/32 lookup main priority 100
      done
    '';
    unpinRoute = pkgs.writeShellScript "olcrtc-unpin-route" ''
      for ip in ${lib.concatStringsSep " " jitsiIps}; do
        ${pkgs.iproute2}/bin/ip rule del to $ip/32 lookup main priority 100 2>/dev/null || true
      done
    '';
  in {
    description = "olcrtc VPN (sing-box tun -> olcrtc WebRTC bridge -> Jitsi -> exit)";
    after = [ "network-online.target" "olcrtc-bridge.service" ];
    wants = [ "network-online.target" ];
    requires = [ "olcrtc-bridge.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pinRoute}";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /home/lad/.config/sing-box/olcrtc.json";
      ExecStopPost = "${unpinRoute}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.naive-bridge = {
    description = "naiveproxy client bridge (Chrome-stack HTTP/2 -> SOCKS 127.0.0.1:1081)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    partOf = [ "naive-vpn.service" ];
    serviceConfig = {
      Type = "simple";
      User = "lad";
      ExecStart = "${naiveproxy}/bin/naive /home/lad/.config/naive/config.json";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.naive-vpn = let
    serverIp = vpnServerIp; # naive exit = vps-nl origin (www.antlis.xyz -> here); pin out of the tun
    pinRoute = pkgs.writeShellScript "naive-pin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule add to ${serverIp}/32 lookup main priority 100
    '';
    unpinRoute = pkgs.writeShellScript "naive-unpin-route" ''
      ${pkgs.iproute2}/bin/ip rule del to ${serverIp}/32 lookup main priority 100 2>/dev/null || true
    '';
  in {
    description = "naiveproxy VPN (sing-box tun -> naive Chrome-stack bridge -> NL exit)";
    after = [ "network-online.target" "naive-bridge.service" ];
    wants = [ "network-online.target" ];
    requires = [ "naive-bridge.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pinRoute}";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /home/lad/.config/sing-box/naive.json";
      ExecStopPost = "${unpinRoute}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  systemd.services.ssh-vpn = {
    description = "SSH VPN (sshuttle tunnel)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.sshuttle}/bin/sshuttle -r ${vpnSshHost} 0/0 --dns --ssh-cmd "${pkgs.openssh}/bin/ssh -i /home/lad/.ssh/vpn_ed25519 -o IdentitiesOnly=yes -F /home/lad/.ssh/config -o UserKnownHostsFile=/home/lad/.ssh/known_hosts -o StrictHostKeyChecking=accept-new"'';
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  # Auto-failover watchdog: if the active VPN tier stops passing traffic for
  # ~THRESHOLD*INTERVAL, rotate to the next tier. Only acts when a tier is
  # already active (respects the "no VPN" state). The i3bar shows the switch.
  systemd.services.vpn-failover = let
    watch = pkgs.writeShellScript "vpn-failover" ''
      set -u
      SC=/run/current-system/sw/bin/systemctl
      CURL=${pkgs.curl}/bin/curl
      TIERS="reality-vpn hysteria-vpn chain-vpn cf-vpn"
      INTERVAL=30
      THRESHOLD=3
      fails=0
      active_tier() { for t in $TIERS; do if $SC is-active --quiet "$t"; then echo "$t"; return 0; fi; done; return 1; }
      next_tier() {
        case "$1" in
          reality-vpn)  echo hysteria-vpn ;;
          hysteria-vpn) echo chain-vpn ;;
          chain-vpn)    echo cf-vpn ;;
          *)            echo reality-vpn ;;
        esac
      }
      online() {
        $CURL -s --max-time 8 -o /dev/null https://www.gstatic.com/generate_204 && return 0
        $CURL -s --max-time 8 -o /dev/null https://1.1.1.1/cdn-cgi/trace && return 0
        return 1
      }
      echo "vpn-failover: watching ($TIERS)"
      while true; do
        if ! cur=$(active_tier); then fails=0; sleep $INTERVAL; continue; fi
        if online; then
          fails=0
        else
          fails=$((fails + 1))
          echo "vpn-failover: $cur check failed ($fails/$THRESHOLD)"
        fi
        if [ "$fails" -ge "$THRESHOLD" ]; then
          nxt=$(next_tier "$cur")
          echo "vpn-failover: $cur DOWN -> switching to $nxt"
          $SC stop "$cur" 2>/dev/null || true
          $SC start "$nxt" 2>/dev/null || true
          fails=0
          sleep 12
        fi
        sleep $INTERVAL
      done
    '';
  in {
    description = "VPN auto-failover watchdog (rotate tiers when the active one stops passing traffic)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # NOT wantedBy — started manually via failover-on, stopped via failover-off.
    serviceConfig = { ExecStart = "${watch}"; Restart = "on-failure"; RestartSec = 5; };
  };

  # Let lad toggle the VPN units (and pause the watchdog) without a password.
  security.sudo.extraRules = [{
    users = [ "lad" ];
    commands = let sc = "/run/current-system/sw/bin/systemctl"; in [
      { command = "${sc} start reality-vpn";  options = [ "NOPASSWD" ]; }
      { command = "${sc} stop reality-vpn";   options = [ "NOPASSWD" ]; }
      { command = "${sc} start hysteria-vpn"; options = [ "NOPASSWD" ]; }
      { command = "${sc} stop hysteria-vpn";  options = [ "NOPASSWD" ]; }
      { command = "${sc} start chain-vpn";    options = [ "NOPASSWD" ]; }
      { command = "${sc} stop chain-vpn";     options = [ "NOPASSWD" ]; }
      { command = "${sc} start cf-vpn";       options = [ "NOPASSWD" ]; }
      { command = "${sc} stop cf-vpn";        options = [ "NOPASSWD" ]; }
      { command = "${sc} start olcrtc-vpn";   options = [ "NOPASSWD" ]; }
      { command = "${sc} stop olcrtc-vpn";    options = [ "NOPASSWD" ]; }
      { command = "${sc} start naive-vpn";    options = [ "NOPASSWD" ]; }
      { command = "${sc} stop naive-vpn";     options = [ "NOPASSWD" ]; }
      { command = "${sc} start ssh-vpn";      options = [ "NOPASSWD" ]; }
      { command = "${sc} stop ssh-vpn";       options = [ "NOPASSWD" ]; }
      { command = "${sc} start vpn-failover"; options = [ "NOPASSWD" ]; }
      { command = "${sc} stop vpn-failover";  options = [ "NOPASSWD" ]; }
    ];
  }];

  system.stateVersion = "25.11";
}
