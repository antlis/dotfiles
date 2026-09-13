{ config, pkgs, lib, sshHosts, amneziaServerIp, figmaApiKey, telepadConfig, openCodeApiKey, ... }:
let
  c = import ../constants.nix;
  # Gitignored local module, loaded from disk (needs --impure) like privateNix.
  # Kept out of the public repo. Absent = skipped.
  bridgeModule = /. + c.homeDir + "/dotfiles/nix/home/opencode-bridge.nix";
in
{
  home-manager.extraSpecialArgs = { inherit sshHosts amneziaServerIp figmaApiKey telepadConfig openCodeApiKey; };

  home-manager.users.${c.username} = { pkgs, lib, config, ... }: {
    home.sessionVariables = {
      OPENCODE_API_KEY = openCodeApiKey;
    };

    home.stateVersion = "25.11";
    home.username = c.username;
    home.homeDirectory = c.homeDir;
    imports = [
      ./i3/i3.nix
      ./i3/i3status.nix
      ./zsh/zshrc.nix
      ./tmux/tmux.nix
      ./desktop-entries.nix
      ./git.nix
      ./kitty.nix
      ./rofi.nix
      ./opencode.nix
      ./claude.nix
      ./pi.nix
      ./ssh.nix
      ./ayugram.nix
      ./telepad.nix
    ] ++ lib.optional (builtins.pathExists bridgeModule) bridgeModule;
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
      "org/gnome/nautilus/preferences" = {
        show-image-thumbnails = "always";
        show-directory-item-counts = "never";
      };
    };
    home.file = {
      ".config/nvim-lazyvim".source = config.lib.file.mkOutOfStoreSymlink
        "${c.dotfilesDir}/nvim-lazyvim/.config/nvim-lazyvim";
      ".config/yazi".source             = "${c.dotfilesDir}/yazi/.config/yazi";
      ".config/keynav".source           = "${c.dotfilesDir}/keynav/.config/keynav";
      ".screenlayout/monitor.sh".source = "${c.dotfilesDir}/scripts/monitor.sh";
      ".config/tmux-airline-dracula".source = builtins.fetchGit {
        url = "https://github.com/sei40kr/tmux-airline-dracula.git";
        ref = "master";
      };
      ".codex/config.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${c.dotfilesDir}/codex/config.toml";
      };
    };
  };
}
