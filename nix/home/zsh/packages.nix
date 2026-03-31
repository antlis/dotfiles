{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    zinit                     # zsh plugin manager | https://github.com/zdharma-continuum/zinit
    fzf                       # Fuzzy finder | https://junegunn.github.io/fzf
    zoxide                    # Smarter cd | https://github.com/ajeetdsouza/zoxide
    ripgrep                   # Fast grep | https://github.com/BurntSushi/ripgrep
    bat                       # Cat with syntax highlighting | https://github.com/sharkdp/bat
    zsh-fzf-tab               # Replace zsh's default completion selection menu with fzf! | https://github.com/Aloxaf/fzf-tab?tab=readme-ov-file
    zsh-you-should-use        # Simple zsh plugin that reminds you that you should use one of your existing aliases for a command you just typed. | https://github.com/MichaelAquilina/zsh-you-should-use
    zsh-syntax-highlighting   # Fish shell like syntax highlighting for Zsh. | https://github.com/zsh-users/zsh-syntax-highlighting
    zsh-autosuggestions       # Fish-like autosuggestions for zsh | https://github.com/zsh-users/zsh-autosuggestions
    zsh-completions           # Additional completion definitions for Zsh. | https://github.com/zsh-users/zsh-completions
  ];
}
