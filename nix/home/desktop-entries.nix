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
      icon = "/home/lad/.local/share/icons/beekeeper.png";
      terminal = false;
      categories = [ "Development" "Database" ];
    };
    yougile = {
      name = "YouGile";
      comment = "Project management";
      exec = "/home/lad/Applications/YouGile-40.41.3-x86_64.AppImage";
      icon = "/home/lad/.local/share/icons/yougile.png";
      terminal = false;
      categories = [ "Office" ];
    };
    reality-on = {
      name = "Reality VPN — On";
      comment = "Full-tunnel VPN, disguised as HTTPS";
      exec = "${realityOn}/bin/reality-on";
      icon = "security-high";
      terminal = false;
      categories = [ "Network" ];
    };
    reality-off = {
      name = "Reality VPN — Off";
      comment = "Disconnect the Reality full-tunnel VPN";
      exec = "${realityOff}/bin/reality-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    ssh-vpn-on = {
      name = "SSH VPN — On";
      comment = "sshuttle tunnel";
      exec = "${sshVpnOn}/bin/ssh-vpn-on";
      icon = "network-server";
      terminal = false;
      categories = [ "Network" ];
    };
    ssh-vpn-off = {
      name = "SSH VPN — Off";
      comment = "Disconnect the sshuttle VPN";
      exec = "${sshVpnOff}/bin/ssh-vpn-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    hysteria-on = {
      name = "Hysteria2 VPN — On";
      comment = "UDP/QUIC full tunnel — backup transport";
      exec = "${hysteriaOn}/bin/hysteria-on";
      icon = "network-wireless-hotspot";
      terminal = false;
      categories = [ "Network" ];
    };
    hysteria-off = {
      name = "Hysteria2 VPN — Off";
      comment = "Disconnect the Hysteria2 VPN";
      exec = "${hysteriaOff}/bin/hysteria-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    chain-on = {
      name = "Chain VPN — On";
      comment = "Multi-hop relay (domestic entry → foreign exit)";
      exec = "${chainOn}/bin/chain-on";
      icon = "insert-link";
      terminal = false;
      categories = [ "Network" ];
    };
    chain-off = {
      name = "Chain VPN — Off";
      comment = "Disconnect the multi-hop chain";
      exec = "${chainOff}/bin/chain-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    cf-on = {
      name = "Cloudflare VPN — On";
      comment = "VLESS-WS via Cloudflare — survives IP-blocking (last resort)";
      exec = "${cfOn}/bin/cf-on";
      icon = "cloudstatus";
      terminal = false;
      categories = [ "Network" ];
    };
    cf-off = {
      name = "Cloudflare VPN — Off";
      comment = "Disconnect the Cloudflare-fronted VPN";
      exec = "${cfOff}/bin/cf-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    olcrtc-on = {
      name = "olcrtc VPN — On";
      comment = "WebRTC-over-Jitsi tunnel — beats CF throttling from residential RU";
      exec = "${olcrtcOn}/bin/olcrtc-on";
      icon = "jitsi";
      terminal = false;
      categories = [ "Network" ];
    };
    olcrtc-off = {
      name = "olcrtc VPN — Off";
      comment = "Disconnect the olcrtc WebRTC tunnel";
      exec = "${olcrtcOff}/bin/olcrtc-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    naive-on = {
      name = "naive VPN — On";
      comment = "Chrome-HTTP/2 proxy — looks like normal browsing; fingerprint-diverse from Reality";
      exec = "${naiveOn}/bin/naive-on";
      icon = "google-chrome";
      terminal = false;
      categories = [ "Network" ];
    };
    naive-off = {
      name = "naive VPN — Off";
      comment = "Disconnect the naiveproxy tunnel";
      exec = "${naiveOff}/bin/naive-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    failover-on = {
      name = "VPN Failover — On";
      comment = "Watchdog: auto-switch tiers if the active VPN stops working";
      exec = "${failoverOn}/bin/failover-on";
      icon = "view-refresh";
      terminal = false;
      categories = [ "Network" ];
    };
    failover-off = {
      name = "VPN Failover — Off";
      comment = "Stop the auto-failover watchdog";
      exec = "${failoverOff}/bin/failover-off";
      icon = "network-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
  };

  # CLI commands: reality/hysteria/chain/cf/ssh-vpn -on/off + failover-on/off.
  home.packages = [
    realityOn realityOff hysteriaOn hysteriaOff chainOn chainOff
    cfOn cfOff sshVpnOn sshVpnOff olcrtcOn olcrtcOff naiveOn naiveOff failoverOn failoverOff
    (pkgs.callPackage ../pkgs/olcrtc.nix { })      # `olcrtc <config>` on PATH (WebRTC tunnel)
    (pkgs.callPackage ../pkgs/naiveproxy.nix { })  # `naive <config>` on PATH (Chrome-stack proxy)
    pkgs.nekoray   # GUI client (bundles Xray/sing-box; supports XHTTP) for ad-hoc profiles
  ];
}
