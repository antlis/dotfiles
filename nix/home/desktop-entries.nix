{ config, pkgs, lib, ... }:
let
  c = import ../constants.nix;
  screenshotScript = flag: pkgs.writeShellScript "screenshot" ''
    gnome-screenshot ${flag}
    LATEST=$(ls -t ${c.screenshotDir}/*.png | head -1)
    xclip -selection clipboard -t image/png < "$LATEST"
    notify-send "Screenshot saved & copied"
  '';
  fzfKillScript = pkgs.writeShellScript "fzf-kill" ''
    export PATH="$HOME/.local/bin:$HOME/.local/share/pnpm:$PATH:/usr/bin:/bin"
    bash "$HOME/.local/bin/fzf-kill"
  '';

  # VPN toggles. These start/stop root systemd units
  # (defined in system/configuration.nix) — allowed passwordless via a scoped
  # sudo rule — then show a dunst notification. Also exposed as CLI commands.
  systemctl = "/run/current-system/sw/bin/systemctl";
  notify = "${pkgs.libnotify}/bin/notify-send";
  curl = "${pkgs.curl}/bin/curl";
  realityOn = pkgs.writeShellScriptBin "reality-on" ''
    sudo ${systemctl} stop hysteria-vpn 2>/dev/null || true
    sudo ${systemctl} stop chain-vpn 2>/dev/null || true
    sudo ${systemctl} stop cf-vpn 2>/dev/null || true
    sudo ${systemctl} stop olcrtc-vpn 2>/dev/null || true
    sudo ${systemctl} stop naive-vpn 2>/dev/null || true
    sudo ${systemctl} start reality-vpn
    sleep 3
    ip=$(${curl} -s --max-time 10 https://ifconfig.me || echo "unknown")
    ${notify} -i security-high "Reality VPN" "Connected — exit IP $ip"
  '';
  realityOff = pkgs.writeShellScriptBin "reality-off" ''
    sudo ${systemctl} stop reality-vpn
    ${notify} -i network-disconnected "Reality VPN" "Disconnected"
  '';
  sshVpnOn = pkgs.writeShellScriptBin "ssh-vpn-on" ''
    sudo ${systemctl} start ssh-vpn
    sleep 3
    ip=$(${curl} -s --max-time 10 https://ifconfig.me || echo "unknown")
    ${notify} -i network-server "SSH VPN (sshuttle)" "Connected — exit IP $ip"
  '';
  sshVpnOff = pkgs.writeShellScriptBin "ssh-vpn-off" ''
    sudo ${systemctl} stop ssh-vpn
    ${notify} -i network-disconnected "SSH VPN (sshuttle)" "Disconnected"
  '';
  hysteriaOn = pkgs.writeShellScriptBin "hysteria-on" ''
    sudo ${systemctl} stop reality-vpn 2>/dev/null || true
    sudo ${systemctl} stop chain-vpn 2>/dev/null || true
    sudo ${systemctl} stop cf-vpn 2>/dev/null || true
    sudo ${systemctl} stop olcrtc-vpn 2>/dev/null || true
    sudo ${systemctl} stop naive-vpn 2>/dev/null || true
    sudo ${systemctl} start hysteria-vpn
    sleep 3
    ip=$(${curl} -s --max-time 10 https://ifconfig.me || echo "unknown")
    ${notify} -i network-wireless-hotspot "Hysteria2 VPN" "Connected — exit IP $ip"
  '';
  hysteriaOff = pkgs.writeShellScriptBin "hysteria-off" ''
    sudo ${systemctl} stop hysteria-vpn
    ${notify} -i network-disconnected "Hysteria2 VPN" "Disconnected"
  '';
  chainOn = pkgs.writeShellScriptBin "chain-on" ''
    sudo ${systemctl} stop reality-vpn 2>/dev/null || true
    sudo ${systemctl} stop hysteria-vpn 2>/dev/null || true
    sudo ${systemctl} stop cf-vpn 2>/dev/null || true
    sudo ${systemctl} stop olcrtc-vpn 2>/dev/null || true
    sudo ${systemctl} stop naive-vpn 2>/dev/null || true
    sudo ${systemctl} start chain-vpn
    sleep 5
    ip=$(${curl} -s --max-time 12 https://ifconfig.me || echo "unknown")
    ${notify} -i insert-link "Chain VPN (relay)" "Connected — exit IP $ip"
  '';
  chainOff = pkgs.writeShellScriptBin "chain-off" ''
    sudo ${systemctl} stop chain-vpn
    ${notify} -i network-disconnected "Chain VPN (relay)" "Disconnected"
  '';
  cfOn = pkgs.writeShellScriptBin "cf-on" ''
    sudo ${systemctl} stop reality-vpn 2>/dev/null || true
    sudo ${systemctl} stop hysteria-vpn 2>/dev/null || true
    sudo ${systemctl} stop chain-vpn 2>/dev/null || true
    sudo ${systemctl} stop olcrtc-vpn 2>/dev/null || true
    sudo ${systemctl} stop naive-vpn 2>/dev/null || true
    sudo ${systemctl} start cf-vpn
    sleep 5
    ip=$(${curl} -s --max-time 12 https://ifconfig.me || echo "unknown")
    ${notify} -i cloudstatus "Cloudflare VPN" "Connected — exit IP $ip"
  '';
  cfOff = pkgs.writeShellScriptBin "cf-off" ''
    sudo ${systemctl} stop cf-vpn
    ${notify} -i network-disconnected "Cloudflare VPN" "Disconnected"
  '';
  olcrtcOn = pkgs.writeShellScriptBin "olcrtc-on" ''
    sudo ${systemctl} stop reality-vpn 2>/dev/null || true
    sudo ${systemctl} stop hysteria-vpn 2>/dev/null || true
    sudo ${systemctl} stop chain-vpn 2>/dev/null || true
    sudo ${systemctl} stop cf-vpn 2>/dev/null || true
    sudo ${systemctl} stop naive-vpn 2>/dev/null || true
    sudo ${systemctl} start olcrtc-vpn
    # olcrtc-vpn refreshes the exit server, joins Jitsi, then negotiates WebRTC —
    # can take ~30s. Poll, and self-revert to Hysteria if it never comes up, so a
    # failed switch can't strand a connection that only reaches the net via VPN.
    ip=""
    for i in $(seq 1 12); do
      sleep 4
      ip=$(${curl} -s --max-time 6 https://ifconfig.me) && [ -n "$ip" ] && break
      ip=""
    done
    if [ -n "$ip" ]; then
      ${notify} -i jitsi "olcrtc VPN (WebRTC/Jitsi)" "Connected — exit IP $ip"
    else
      sudo ${systemctl} stop olcrtc-vpn 2>/dev/null || true
      sudo ${systemctl} start hysteria-vpn
      ${notify} -i network-disconnected "olcrtc VPN (WebRTC/Jitsi)" "Failed to connect — reverted to Hysteria"
    fi
  '';
  olcrtcOff = pkgs.writeShellScriptBin "olcrtc-off" ''
    sudo ${systemctl} stop olcrtc-vpn
    ${notify} -i network-disconnected "olcrtc VPN (WebRTC/Jitsi)" "Disconnected"
  '';
  naiveOn = pkgs.writeShellScriptBin "naive-on" ''
    sudo ${systemctl} stop reality-vpn 2>/dev/null || true
    sudo ${systemctl} stop hysteria-vpn 2>/dev/null || true
    sudo ${systemctl} stop chain-vpn 2>/dev/null || true
    sudo ${systemctl} stop cf-vpn 2>/dev/null || true
    sudo ${systemctl} stop olcrtc-vpn 2>/dev/null || true
    sudo ${systemctl} start naive-vpn
    ip=""
    for i in $(seq 1 8); do
      sleep 3
      ip=$(${curl} -s --max-time 6 https://ifconfig.me) && [ -n "$ip" ] && break
      ip=""
    done
    if [ -n "$ip" ]; then
      ${notify} -i google-chrome "naive VPN (Chrome HTTP/2)" "Connected — exit IP $ip"
    else
      sudo ${systemctl} stop naive-vpn 2>/dev/null || true
      sudo ${systemctl} start hysteria-vpn
      ${notify} -i network-disconnected "naive VPN (Chrome HTTP/2)" "Failed to connect — reverted to Hysteria"
    fi
  '';
  naiveOff = pkgs.writeShellScriptBin "naive-off" ''
    sudo ${systemctl} stop naive-vpn
    ${notify} -i network-disconnected "naive VPN (Chrome HTTP/2)" "Disconnected"
  '';
  failoverOn = pkgs.writeShellScriptBin "failover-on" ''
    sudo ${systemctl} start vpn-failover
    ${notify} -i view-refresh "VPN failover" "Watchdog ON — auto-switches tiers if the active one fails"
  '';
  failoverOff = pkgs.writeShellScriptBin "failover-off" ''
    sudo ${systemctl} stop vpn-failover
    ${notify} -i network-disconnected "VPN failover" "Watchdog OFF"
  '';
  # Single rofi menu for all VPN tiers. Marks the active one (●), selecting a tier
  # connects it (each -on auto-stops the others); plus Disconnect + Failover toggle.
  vpnMenu = pkgs.writeShellScriptBin "vpn-menu" ''
    sc=${systemctl}
    active="none"
    for pair in "reality-vpn:Reality" "hysteria-vpn:Hysteria2" "naive-vpn:naive" "olcrtc-vpn:olcrtc" "cf-vpn:Cloudflare" "chain-vpn:Chain" "ssh-vpn:SSH"; do
      unit="''${pair%%:*}"; name="''${pair##*:}"
      $sc is-active --quiet "$unit" && active="$name"
    done
    amn=""
    ${pkgs.iproute2}/bin/ip link show amn0 >/dev/null 2>&1 && amn="   ⚠ Amnezia (amn0) up — disable it before a sing-box tier"
    fo=$($sc is-active --quiet vpn-failover && echo ON || echo OFF)
    # rofi dmenu icon protocol: "<label>\0icon\x1f<themed-icon-name>". -show-icons renders it.
    row() { printf '%s\0icon\x1f%s\n' "$1" "$2"; }
    mark() { if [ "$1" = "$active" ]; then row "🟢 $1" "$2"; else row "$1" "$2"; fi; }
    choice=$( { mark Reality security-high; mark Hysteria2 network-wireless; \
                mark naive applications-internet; mark olcrtc camera-web; \
                mark Cloudflare weather-overcast; mark Chain insert-link; mark SSH utilities-terminal; \
                row "✕ Disconnect ($active)" network-offline; \
                row "⚙ Failover: $fo" view-refresh; } \
              | ${pkgs.rofi}/bin/rofi -dmenu -i -show-icons -p "VPN" -mesg "Active: $active$amn" )
    case "$choice" in
      "✕ Disconnect"*)
        case "$active" in
          Reality)    ${realityOff}/bin/reality-off ;;
          Hysteria2)  ${hysteriaOff}/bin/hysteria-off ;;
          naive)      ${naiveOff}/bin/naive-off ;;
          olcrtc)     ${olcrtcOff}/bin/olcrtc-off ;;
          Cloudflare) ${cfOff}/bin/cf-off ;;
          Chain)      ${chainOff}/bin/chain-off ;;
          SSH)        ${sshVpnOff}/bin/ssh-vpn-off ;;
        esac ;;
      *"Failover: ON")  ${failoverOff}/bin/failover-off ;;
      *"Failover: OFF") ${failoverOn}/bin/failover-on ;;
      *Reality)    ${realityOn}/bin/reality-on ;;
      *Hysteria2)  ${hysteriaOn}/bin/hysteria-on ;;
      *naive)      ${naiveOn}/bin/naive-on ;;
      *olcrtc)     ${olcrtcOn}/bin/olcrtc-on ;;
      *Cloudflare) ${cfOn}/bin/cf-on ;;
      *Chain)      ${chainOn}/bin/chain-on ;;
      *SSH)        ${sshVpnOn}/bin/ssh-vpn-on ;;
    esac
  '';
in
{
  xdg.desktopEntries = {
    yazifloat = {
      name = "yazifloat";
      exec = "kitty --start-as=fullscreen yazi ${c.screenshotDir}";
      icon = "system-file-manager";
      terminal = false;
    };
    prtsc = {
      name = "prtsc";
      comment = "Screenshot";
      exec = "${screenshotScript ""}";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "Utility" ];
    };
    prtsca = {
      name = "prtsca";
      comment = "Screenshot area";
      exec = "${screenshotScript "-a"}";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "Utility" ];
    };
    fzf-kill = {
      name = "fzf-kill";
      comment = "Run fzf-kill";
      exec = "kitty --start-as=fullscreen ${fzfKillScript}";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "Utility" ];
    };
    nighttime = {
      name = "nighttime";
      comment = "nighttime";
      exec = "redshift -O 3000";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "Utility" ];
    };
    nighttime-off = {
      name = "nighttime-off";
      comment = "nighttime-off";
      exec = "redshift -x";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "Utility" ];
    };
    brave-debug = {
      name = "Brave Browser (Debug Mode)";
      comment = "Launch Brave Browser with remote debugging enabled";
      exec = "brave --remote-debugging-port=9222";
      icon = "brave";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };
    beekeeper-studio = {
      name = "Beekeeper Studio";
      comment = "SQL editor and database manager";
      exec = "/home/lad/Applications/Beekeeper-Studio-5.6.3.AppImage";
      icon = "beekeeper-studio"; # named icon from papirus (the old .png path never existed)
      terminal = false;
      categories = [ "Development" "Database" ];
    };
    vpn-menu = {
      name = "VPN";
      comment = "Pick / switch / disconnect any VPN tier (rofi menu)";
      exec = "${vpnMenu}/bin/vpn-menu";
      icon = "network-vpn";
      terminal = false;
      categories = [ "Network" ];
    };
  };

  # `vpn-menu` (rofi launcher) + the underlying CLI commands (reality/hysteria/
  # naive/olcrtc/chain/cf/ssh-vpn -on/off + failover-on/off), still usable directly.
  home.packages = [
    vpnMenu
    realityOn realityOff hysteriaOn hysteriaOff chainOn chainOff
    cfOn cfOff sshVpnOn sshVpnOff olcrtcOn olcrtcOff naiveOn naiveOff failoverOn failoverOff
    (pkgs.callPackage ../pkgs/olcrtc.nix { })      # `olcrtc <config>` on PATH (WebRTC tunnel)
    (pkgs.callPackage ../pkgs/naiveproxy.nix { })  # `naive <config>` on PATH (Chrome-stack proxy)
    pkgs.nekoray   # GUI client (bundles Xray/sing-box; supports XHTTP) for ad-hoc profiles
  ];
}
