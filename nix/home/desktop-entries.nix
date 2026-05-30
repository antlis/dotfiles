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
    sudo ${systemctl} start reality-vpn
    sleep 3
    ip=$(${curl} -s --max-time 10 https://ifconfig.me || echo "unknown")
    ${notify} -i network-vpn "Reality VPN" "Connected — exit IP $ip"
  '';
  realityOff = pkgs.writeShellScriptBin "reality-off" ''
    sudo ${systemctl} stop reality-vpn
    ${notify} -i network-vpn "Reality VPN" "Disconnected"
  '';
  sshVpnOn = pkgs.writeShellScriptBin "ssh-vpn-on" ''
    sudo ${systemctl} start ssh-vpn
    sleep 3
    ip=$(${curl} -s --max-time 10 https://ifconfig.me || echo "unknown")
    ${notify} -i network-vpn "SSH VPN (sshuttle)" "Connected — exit IP $ip"
  '';
  sshVpnOff = pkgs.writeShellScriptBin "ssh-vpn-off" ''
    sudo ${systemctl} stop ssh-vpn
    ${notify} -i network-vpn "SSH VPN (sshuttle)" "Disconnected"
  '';
  hysteriaOn = pkgs.writeShellScriptBin "hysteria-on" ''
    sudo ${systemctl} stop reality-vpn 2>/dev/null || true
    sudo ${systemctl} start hysteria-vpn
    sleep 3
    ip=$(${curl} -s --max-time 10 https://ifconfig.me || echo "unknown")
    ${notify} -i network-vpn "Hysteria2 VPN" "Connected — exit IP $ip"
  '';
  hysteriaOff = pkgs.writeShellScriptBin "hysteria-off" ''
    sudo ${systemctl} stop hysteria-vpn
    ${notify} -i network-vpn "Hysteria2 VPN" "Disconnected"
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
      icon = "network-vpn";
      terminal = false;
      categories = [ "Network" ];
    };
    reality-off = {
      name = "Reality VPN — Off";
      comment = "Disconnect the Reality full-tunnel VPN";
      exec = "${realityOff}/bin/reality-off";
      icon = "network-vpn-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    ssh-vpn-on = {
      name = "SSH VPN — On";
      comment = "sshuttle tunnel";
      exec = "${sshVpnOn}/bin/ssh-vpn-on";
      icon = "network-vpn";
      terminal = false;
      categories = [ "Network" ];
    };
    ssh-vpn-off = {
      name = "SSH VPN — Off";
      comment = "Disconnect the sshuttle VPN";
      exec = "${sshVpnOff}/bin/ssh-vpn-off";
      icon = "network-vpn-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
    hysteria-on = {
      name = "Hysteria2 VPN — On";
      comment = "UDP/QUIC full tunnel — backup transport";
      exec = "${hysteriaOn}/bin/hysteria-on";
      icon = "network-vpn";
      terminal = false;
      categories = [ "Network" ];
    };
    hysteria-off = {
      name = "Hysteria2 VPN — Off";
      comment = "Disconnect the Hysteria2 VPN";
      exec = "${hysteriaOff}/bin/hysteria-off";
      icon = "network-vpn-disconnected";
      terminal = false;
      categories = [ "Network" ];
    };
  };

  # Expose the toggles as CLI commands: reality-on/off, hysteria-on/off, ssh-vpn-on/off.
  home.packages = [ realityOn realityOff hysteriaOn hysteriaOff sshVpnOn sshVpnOff ];
}
