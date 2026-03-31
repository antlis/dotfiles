{ config, pkgs, lib, ... }:
let
  c = import ../../constants.nix;

  zshmarks = pkgs.fetchFromGitHub {
    owner = "jocelynmallon";
    repo = "zshmarks";
    rev = "master";
    sha256 = "sha256-tNKFBW+DsP83Stjhk+0B6BPguYVNEthTBNzN4aOU6Zs=";
  };
in
{
  imports = [
    ./path.nix
    ./packages.nix
  ];

  # ── Starship prompt ──────────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$character";
      add_newline = false;
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    enableCompletion = false;          # zinit loads OMZL::completion.zsh
    autosuggestion.enable = false;     # loaded via zinit turbo
    syntaxHighlighting.enable = false; # loaded via zinit turbo

    initContent = ''
      # ── Zinit bootstrap ─────────────────────────────────────────────────────
      ZINIT_HOME="${pkgs.zinit}/share/zinit"
      source "$ZINIT_HOME/zinit.zsh"

      # ── OMZ libs ─────────────────────────────────────────────────────────────
      zinit snippet OMZL::git.zsh
      zinit snippet OMZL::key-bindings.zsh
      zinit snippet OMZL::completion.zsh
      zinit snippet OMZL::history.zsh

      # ── OMZ plugins ──────────────────────────────────────────────────────────
      zinit snippet OMZP::git
      zinit snippet OMZP::vi-mode

      # ── Local plugins (eager — must be available immediately) ────────────────
      zinit light ${pkgs.zsh-fzf-tab}/share/fzf-tab
      zinit light ${zshmarks}

      # ── Turbo plugins (via Nix store — no network at shell start) ────────────
      zinit wait lucid for \
        ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use \
        ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting \
        ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions \
        ${pkgs.zsh-completions}/share/zsh/site-functions

      # ── Custom aliases & functions ───────────────────────────────────────────
      source ${c.homeDir}/.zsh-custom/aliases.zsh
      source ${c.homeDir}/.zsh-custom/functions.zsh

      # ── Keybinds ─────────────────────────────────────────────────────────────
      bindkey '^x^x' edit-command-line

      # ── FZF ──────────────────────────────────────────────────────────────────
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS='--height 96% --reverse --preview "bat --color=always --style=numbers --line-range=:500 {}"'

      # ── Tools ────────────────────────────────────────────────────────────────
      unalias z 2>/dev/null; eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # ── Tmux git ─────────────────────────────────────────────────────────────
      if [[ $TMUX ]]; then source ~/.tmux-git/tmux-git.sh; fi

      # ── Lazy load rvm ────────────────────────────────────────────────────────
      rvm() {
        unfunction rvm
        if [ -s "$HOME/.rvm/scripts/rvm" ]; then
          . "$HOME/.rvm/scripts/rvm"
        elif [ -s "/usr/local/rvm/scripts/rvm" ]; then
          . "/usr/local/rvm/scripts/rvm"
        fi
        rvm "$@"
      }

      # ── Lazy load gvm ────────────────────────────────────────────────────────
      gvm() {
        unfunction gvm
        [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
        gvm "$@"
      }

      # ── Add keys if agent is running but has no identities loaded ────────────
      # Add keys if agent is running but has no identities loaded
      if [[ $(ssh-add -l 2>/dev/null) == "The agent has no identities." ]]; then
        ssh-add ~/.ssh/id_rsa ~/.ssh/id_lsgitlab_rsa 2>/dev/null
      fi
    '';
  };
}
