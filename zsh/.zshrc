# ── Zinit bootstrap ───────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ── OMZ libs (eager) ──────────────────────────────────────────────────────────
zinit snippet OMZL::git.zsh
zinit snippet OMZL::key-bindings.zsh
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::history.zsh

# ── OMZ plugins (eager) ───────────────────────────────────────────────────────
zinit snippet OMZP::git
zinit snippet OMZP::vi-mode

# ── Local plugins (eager — functions must be available immediately) ────────────
zinit light ~/.oh-my-zsh/custom/plugins/fzf-tab
zinit light ~/.oh-my-zsh/custom/plugins/zshmarks

# ── Turbo plugins (load AFTER prompt — near-instant startup) ──────────────────
zinit wait lucid for \
  ~/.oh-my-zsh/custom/plugins/you-should-use \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions

# ── Custom aliases & functions ────────────────────────────────────────────────
source ~/.zsh-custom/aliases.zsh
source ~/.zsh-custom/functions.zsh

# ── Keybinds ───────────────────────────────────────────────────────────────────
bindkey '^x^x' edit-command-line

# ── Env ────────────────────────────────────────────────────────────────────────
export NVIM_APPNAME=nvim-lazyvim
export GH_EDITOR="nvim"
export EDITOR="nvim"
export PAGER=more

# ── PATH ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/my-scripts:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:/usr/sbin:/sbin:$PATH"
export PATH=$PATH:/opt/warpdotdev/warp-terminal
export PATH=$PATH:~/.spoof-dpi/bin
export PATH=$PATH:~/.spoofdpi/bin

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# pnpm
export PNPM_HOME="/home/lad/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# rvm
export PATH="$PATH:$HOME/.rvm/bin"

# perl
PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

# nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# ── FZF ────────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 96% --reverse --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# ── Tools ─────────────────────────────────────────────────────────────────────
unalias z 2>/dev/null; eval "$(zoxide init zsh)"

# ── Starship prompt ───────────────────────────────────────────────────────────
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

# ── Tmux git ───────────────────────────────────────────────────────────────────
if [[ $TMUX ]]; then source ~/.tmux-git/tmux-git.sh; fi

# ── Lazy load rvm ─────────────────────────────────────────────────────────────
rvm() {
  unfunction rvm
  if [ -s "$HOME/.rvm/scripts/rvm" ]; then
    . "$HOME/.rvm/scripts/rvm"
  elif [ -s "/usr/local/rvm/scripts/rvm" ]; then
    . "/usr/local/rvm/scripts/rvm"
  fi
  rvm "$@"
}

# ── Lazy load gvm ─────────────────────────────────────────────────────────────
gvm() {
  unfunction gvm
  [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
  gvm "$@"
}

# ── SSH agent — add keys if agent has no identities loaded ────────────────────
if [[ $(ssh-add -l 2>/dev/null) == "The agent has no identities." ]]; then
  ssh-add ~/.ssh/id_rsa ~/.ssh/id_lsgitlab_rsa 2>/dev/null
fi
