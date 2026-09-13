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

      # Remote control over a private abstract socket so the rofi cheatsheet
      # (rofi-kitty-keybindings) can fire actions. `socket-only` disallows
      # control via TTY escape codes — only a process holding the socket can
      # drive kitty. NB: with multiple kitty processes, only the first to start
      # owns @mykitty (others warn and run without remote control).
      allow_remote_control = "socket-only";
      listen_on = "unix:@mykitty";
    };

    extraConfig = builtins.readFile (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf";
        hash = "sha256-cWrJfNVCuuT/NbU8qYCq5PAB4MS8WcT74AMBm+IO+c0=";
      }
    );
  };
}
