{ config, pkgs, lib, ... }:
let
  c = import ../constants.nix;
in
{
  home-manager.users.${c.username} = { pkgs, lib, config, ... }: {
    home.stateVersion = "25.11";
    home.username = c.username;
    home.homeDirectory = c.homeDir;
    imports = [
      ./i3/i3.nix
      ./i3/i3status.nix
      ./zsh/zshrc.nix
      ./desktop-entries.nix
      ./git.nix
      ./kitty.nix
      ./rofi.nix
      ./opencode.nix
    ];
    services.dunst.enable = true;
    services.ssh-agent.enable = true;
    home.activation.createScreenshotDir = lib.mkAfter ''
      mkdir -p ${c.screenshotDir}
    '';
    home.activation.setupScreenlayout = lib.mkAfter ''
      mkdir -p ${c.homeDir}/.screenlayout
    '';
    dconf.settings = {
      "org/gnome/gnome-screenshot" = {
        auto-save-directory = "file://${c.screenshotDir}";
      };
    };
    home.file = {
      ".config/nvim-lazyvim".source = config.lib.file.mkOutOfStoreSymlink
        "${c.dotfilesDir}/nvim-lazyvim/.config/nvim-lazyvim";
      ".tmux.conf".source               = "${c.dotfilesDir}/tmux/.tmux.conf";
      ".tmux-git.conf".source           = "${c.dotfilesDir}/tmux/.tmux-git.conf";
      ".config/yazi".source             = "${c.dotfilesDir}/yazi/.config/yazi";
      ".xbindkeysrc".source             = "${c.dotfilesDir}/xbindkeysrc/.xbindkeysrc";
      ".config/keynav".source           = "${c.dotfilesDir}/keynav/.config/keynav";
      ".screenlayout/monitor.sh".source = "${c.dotfilesDir}/scripts/monitor.sh";
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
