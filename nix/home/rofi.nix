{ config, pkgs, ... }:
let
  c = import ../constants.nix;
in
{
  # Keybinding cheatsheet scripts (i3 / AyuGram / mpv / Discord / Brave), deployed
  # as a live out-of-store symlink so they can be edited without a rebuild. The
  # launcher (rofi-keybindings) finds its siblings via $0's dir, so they must stay
  # co-located here. i3 binds mod+slash to this dir's rofi-keybindings.
  home.file.".local/share/rofi-cheatsheets".source =
    config.lib.file.mkOutOfStoreSymlink "${c.dotfilesDir}/rofi/cheatsheets";

  programs.rofi = {
    enable = true;
    font = "Fira Code 15";
    theme = "${c.dotfilesDir}/rofi/.config/rofi/onedark.rasi";
    extraConfig = {
      # Terminal apps (Terminal=true .desktop entries, e.g. yazi) launch via rofi's
      # `terminal` option. Without this rofi falls back to rofi-sensible-terminal,
      # which picks xterm before kitty and ignores our theme/config.
      terminal = "${pkgs.kitty}/bin/kitty";
      modi = "window,drun,combi";
      combi-modi = "window,drun,ssh,~/.local/bin/rofi-bookmarks,~/.js/";
      # Icons are enabled per-launch (mod+d passes -show-icons) so script modes
      # like bookmarks/tabs don't get an empty icon column. icon-theme is global
      # but only takes effect when a mode actually shows icons.
      icon-theme = "Papirus-Dark";
    };
  };
}
