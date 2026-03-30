{ config, pkgs, lib, ... }:
let
  c = import ../../constants.nix;

  # Fetch plugins that aren't in nixpkgs
  zshmarks = pkgs.fetchFromGitHub {
    owner = "jocelynmallon";
    repo = "zshmarks";
    rev = "master";
    sha256 = "sha256-tNKFBW+DsP83Stjhk+0B6BPguYVNEthTBNzN4aOU6Zs=";
  };
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    # Let zinit handle history, completion, syntax — keep these minimal
    enableCompletion = false;   # zinit loads OMZL::completion.zsh
    autosuggestion.enable = false;  # loaded via zinit turbo
    syntaxHighlighting.enable = false;  # loaded via zinit turbo

    # ── Plugins managed by Nix (available as store paths) ─────────────────────
    # We pass store paths to zinit so nothing is downloaded at runtime

    initContent = ''
      # Fixes __git_ps1
      # source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh

      # ── Zinit bootstrap ─────────────────────────────────────────────────────
      ZINIT_HOME="${pkgs.zinit}/share/zinit"
      source "$ZINIT_HOME/zinit.zsh"

      # ── Theme ────────────────────────────────────────────────────────────────
      zinit snippet OMZT::robbyrussell

      # ── OMZ libs ─────────────────────────────────────────────────────────────
      zinit snippet OMZL::git.zsh
      zinit snippet OMZL::key-bindings.zsh
      zinit snippet OMZL::completion.zsh
      zinit snippet OMZL::history.zsh

      # ── OMZ plugins ──────────────────────────────────────────────────────────
      zinit snippet OMZP::git

      # zinit ice svn
      # zinit snippet OMZP::gitfast
 
      zinit snippet OMZP::vi-mode

      # ── Local plugins (eager — via Nix store paths) ───────────────────────
      zinit light ${pkgs.zsh-fzf-tab}/share/fzf-tab
      zinit light ${zshmarks}

      # ── Turbo plugins (via Nix store paths — no network at shell start) ────
      zinit wait lucid for \
        ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use \
        ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting \
        ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions \
        ${pkgs.zsh-completions}/share/zsh/site-functions

      # ── Custom aliases & functions ──────────────────────────────────────────
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

      # ── Tools ─────────────────────────────────────────────────────────────────
      unalias z 2>/dev/null; eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # ── Tmux git ──────────────────────────────────────────────────────────────
      if [[ $TMUX ]]; then source ~/.tmux-git/tmux-git.sh; fi

      # ── Google Cloud SDK ──────────────────────────────────────────────────────
      if [ -f "${c.homeDir}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/path.zsh.inc" ]; then
        . "${c.homeDir}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/path.zsh.inc"
      fi
      if [ -f "${c.homeDir}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/completion.zsh.inc" ]; then
        . "${c.homeDir}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/completion.zsh.inc"
      fi

      # ── Lazy load nvm ────────────────────────────────────────────────────────
      export NVM_DIR="$HOME/.nvm"
      _load_nvm() {
        unfunction node npm npx nvm pnpm 2>/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
      }
      node()  { _load_nvm; node "$@"; }
      npm()   { _load_nvm; npm "$@"; }
      npx()   { _load_nvm; npx "$@"; }
      nvm()   { _load_nvm; nvm "$@"; }

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

      # ── Lazy load ssh-agent ──────────────────────────────────────────────────
      _load_ssh_agent() {
        unfunction ssh ssh-add scp sftp 2>/dev/null
        eval "$(ssh-agent -s)" > /dev/null
        ssh-add ~/.ssh/id_rsa ~/.ssh/id_lsgitlab_rsa 2>/dev/null
      }
      ssh()     { _load_ssh_agent; ssh "$@"; }
      ssh-add() { _load_ssh_agent; ssh-add "$@"; }
      scp()     { _load_ssh_agent; scp "$@"; }
      sftp()    { _load_ssh_agent; sftp "$@"; }
      git() {
        if [[ "$1" == "push" || "$1" == "pull" || "$1" == "fetch" || "$1" == "clone" ]]; then
          _load_ssh_agent
        fi
        command git "$@"
      }
    '';

    # ── Session variables ──────────────────────────────────────────────────────
    sessionVariables = {
      NVIM_APPNAME = "nvim-lazyvim";
      GH_EDITOR    = "nvim";
      EDITOR       = "nvim";
      PAGER        = "more";
      GOPATH       = "${c.homeDir}/go";
      BUN_INSTALL  = "${c.homeDir}/.bun";
      NVM_DIR      = "${c.homeDir}/.nvm";
      PNPM_HOME    = "/home/${c.username}/.local/share/pnpm";
    };

    # ── PATH ──────────────────────────────────────────────────────────────────
    # Managed here instead of initContent so HM can merge cleanly
    profileExtra = ''
      export PATH="${c.homeDir}/.opencode/bin:$PATH"
      export PATH="${c.homeDir}/.cargo/bin:$PATH"
      export PATH="${c.homeDir}/.local/bin:$PATH"
      export PATH="${c.homeDir}/my-scripts:$PATH"
      export PATH="${c.homeDir}/bin:$PATH"
      export PATH="/usr/local/bin:/usr/sbin:/sbin:$PATH"
      export PATH="$PATH:/opt/warpdotdev/warp-terminal"
      export PATH="$PATH:${c.homeDir}/.spoof-dpi/bin"
      export PATH="$PATH:${c.homeDir}/.spoofdpi/bin"
      export PATH="$PATH:$GOPATH/bin"
      export PATH="$PATH:${c.homeDir}/.rvm/bin"
      export PATH="$PATH:${c.homeDir}/.bun/bin"
      export PATH="$PATH:${c.homeDir}/perl5/bin"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac

      # perl
      PERL5LIB="${c.homeDir}/perl5/lib/perl5''${PERL5LIB:+:''${PERL5LIB}}"; export PERL5LIB;
      PERL_LOCAL_LIB_ROOT="${c.homeDir}/perl5''${PERL_LOCAL_LIB_ROOT:+:''${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
      PERL_MB_OPT="--install_base \"${c.homeDir}/perl5\""; export PERL_MB_OPT;
      PERL_MM_OPT="INSTALL_BASE=${c.homeDir}/perl5"; export PERL_MM_OPT;

      # bun completions
      [ -s "${c.homeDir}/.bun/_bun" ] && source "${c.homeDir}/.bun/_bun"

      # nix
      if [ -e "${c.homeDir}/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "${c.homeDir}/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';
  };

  # ── Packages needed in PATH for the shell ───────────────────────────────────
  home.packages = with pkgs; [
    zinit
    fzf                       # Fuzzy finder for terminal | https://junegunn.github.io/fzf
    zoxide                    # Smarter cd — jumps to frecent directories | https://github.com/ajeetdsouza/zoxide
    ripgrep                   # https://github.com/burntsushi/ripgrep
    bat                       # Cat clone with syntax highlighting and Git integration | https://github.com/sharkdp/bat
    zsh-fzf-tab
    zsh-you-should-use
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
  ];
}
