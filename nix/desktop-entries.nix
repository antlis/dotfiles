{ config, pkgs, lib, ... }:
let
  c = import ./constants.nix;
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
  };
}
