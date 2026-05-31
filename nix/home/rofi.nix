{ config, pkgs, ... }:
let
  c = import ../constants.nix;
in
{
  programs.rofi = {
    enable = true;
    font = "Fira Code 15";
    theme = "${c.dotfilesDir}/rofi/.config/rofi/onedark.rasi";
    extraConfig = {
      modi = "window,drun,combi";
      combi-modi = "window,drun,ssh,~/.local/bin/rofi-bookmarks,~/.js/";
      # Icons are enabled per-launch (mod+d passes -show-icons) so script modes
      # like bookmarks/tabs don't get an empty icon column. icon-theme is global
      # but only takes effect when a mode actually shows icons.
      icon-theme = "Papirus-Dark";
    };
  };
}
