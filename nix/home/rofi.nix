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
    };
  };
}
