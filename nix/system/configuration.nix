{ config, pkgs, lib, vpnServerIp ? "127.0.0.1", vpnSshHost ? "vpn-host", ... }:
{
  imports =
    [
      ../home/home.nix
      ./packages/packages.nix
      ./bluetooth.nix
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

  services.openssh.enable = true;
  # Enable sshd, but don't start it on boot
  systemd.services.sshd.wantedBy = lib.mkForce [];

  hardware.graphics.enable32Bit = true;

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
  systemd.services.ssh-vpn = {
    description = "SSH VPN (sshuttle tunnel)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.sshuttle}/bin/sshuttle -r ${vpnSshHost} 0/0 --dns --ssh-cmd "${pkgs.openssh}/bin/ssh -i /home/lad/.ssh/id_rsa -F /home/lad/.ssh/config -o UserKnownHostsFile=/home/lad/.ssh/known_hosts -o StrictHostKeyChecking=accept-new"'';
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  # Let lad toggle exactly these two units without a password (for one-click launchers).
  security.sudo.extraRules = [{
    users = [ "lad" ];
    commands = let sc = "/run/current-system/sw/bin/systemctl"; in [
      { command = "${sc} start reality-vpn";  options = [ "NOPASSWD" ]; }
      { command = "${sc} stop reality-vpn";   options = [ "NOPASSWD" ]; }
      { command = "${sc} start hysteria-vpn"; options = [ "NOPASSWD" ]; }
      { command = "${sc} stop hysteria-vpn";  options = [ "NOPASSWD" ]; }
      { command = "${sc} start ssh-vpn";      options = [ "NOPASSWD" ]; }
      { command = "${sc} stop ssh-vpn";       options = [ "NOPASSWD" ]; }
    ];
  }];

  system.stateVersion = "25.11";
}
