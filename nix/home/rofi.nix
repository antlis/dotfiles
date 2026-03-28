{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    font = "Fira Code 15";
    theme = "${config.home.homeDirectory}/dotfiles/rofi/.config/rofi/onedark.rasi";
    extraConfig = {
      modi = "window,drun,combi";
      combi-modi = "window,drun,ssh,~/.local/bin/rofi-bookmarks,~/.js/";
    };
  };
}
