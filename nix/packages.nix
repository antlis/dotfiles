{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty
    git
    rofi
    opencode
    telegram-desktop
    slack
    discord
    amnezia-vpn
    keynav
    neofetch
    yazi
    lazygit
    lazydocker
    brave
    surfraw
    # brave-beta
 
    peek
    simplescreenrecorder

    tmux
    tmuxinator

    adwaita-icon-theme
    tree
    xclip
    pay-respects

    zsh-syntax-highlighting
    zsh-fzf-tab
    zsh-you-should-use
    # zshmarks
    fzf

    mpv
    yt-dlp

    neovim
    nodejs   # for many LSPs
    ripgrep  # for telescope/fzf search
    fd       # file finder
    gcc      # for treesitter compilation
    unzip    # for mason
    tree-sitter

    bat
    lsd
    btop

    x2x

    hubstaff
  ];
}
