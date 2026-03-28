{ config, pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "MesloLGL Nerd Font Mono";
      size = 15.0;
    };

    settings = {
      scrollback_lines = 100000;
      bold_font        = "auto";
      italic_font      = "auto";
      bold_italic_font = "auto";
    };

    extraConfig = builtins.readFile (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf";
        hash = "sha256-cWrJfNVCuuT/NbU8qYCq5PAB4MS8WcT74AMBm+IO+c0=";
      }
    );
  };
}
