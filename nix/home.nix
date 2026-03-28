{ config, pkgs, lib, ... }:
{
  home-manager.users.lad = { pkgs, lib, config, ... }: {
    home.stateVersion = "25.11";
    home.username = "lad";
    home.homeDirectory = "/home/lad";

    imports = [
      ./home/git.nix
      ./home/kitty.nix
      ./home/rofi.nix
    ];

    services.dunst.enable = true;

    home.activation.createScreenshotDir = lib.mkAfter ''
      mkdir -p ${config.home.homeDirectory}/Pictures/Screenshot
    '';

    home.activation.setupScreenlayout = lib.mkAfter ''
      mkdir -p ${config.home.homeDirectory}/.screenlayout
    '';

    dconf.settings = {
      "org/gnome/gnome-screenshot" = {
        auto-save-directory = "file://${config.home.homeDirectory}/Pictures/Screenshot";
      };
    };

    home.file = {
      ".config/nvim-lazyvim".source = /home/lad/dotfiles/nvim-lazyvim/.config/nvim-lazyvim;
      ".tmux.conf".source = /home/lad/dotfiles/tmux/.tmux.conf;
      ".tmux-git.conf".source = /home/lad/dotfiles/tmux/.tmux-git.conf;
      ".config/yazi".source = /home/lad/dotfiles/yazi/.config/yazi;
      ".zshrc".source = /home/lad/dotfiles/zsh/.zshrc;
      ".xbindkeysrc".source = /home/lad/dotfiles/xbindkeysrc/.xbindkeysrc;
      ".config/keynav".source = /home/lad/dotfiles/keynav/.config/keynav;
      ".config/i3".source = /home/lad/dotfiles/i3/.config/i3;
      ".config/i3status".source = /home/lad/dotfiles/i3/.config/i3status;
      ".screenlayout/monitor.sh".source = /home/lad/dotfiles/scripts/monitor.sh;
      ".tmux-git".source = builtins.fetchGit {
        url = "https://github.com/drmad/tmux-git.git";
        ref = "master";
      };
      ".tmux/plugins/tpm".source = builtins.fetchGit {
        url = "https://github.com/tmux-plugins/tpm.git";
        ref = "master";
      };
      ".config/tmux-airline-dracula".source = builtins.fetchGit {
        url = "https://github.com/sei40kr/tmux-airline-dracula.git";
        ref = "master";
      };
    };
  };
}
