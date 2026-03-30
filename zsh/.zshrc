# Path to your oh-my-zsh installation.
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then
  export ZSH="$HOME/.oh-my-zsh"
elif [ -f /run/current-system/sw/share/oh-my-zsh/oh-my-zsh.sh ]; then
  export ZSH="/run/current-system/sw/share/oh-my-zsh"
fi

ZSH_THEME="robbyrussell"

plugins=(
  git
  gitfast
  vi-mode
  fzf
  # fzf-tab
  you-should-use
  zsh-syntax-highlighting
  # docker
  # docker-compose
)

zstyle :omz:plugins:ssh-agent identities id_rsa id_lsgitlab_rsa

source $ZSH/oh-my-zsh.sh

# ── Lazy load nvm ─────────────────────────────────────────────────────────────
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

# ── Lazy load ssh-agent ────────────────────────────────────────────────────────
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

# ── Env ────────────────────────────────────────────────────────────────────────
export NVIM_APPNAME=nvim-lazyvim
export GH_EDITOR="nvim"
export EDITOR="nvim"
export PAGER=more

# ── FZF ────────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 96% --reverse --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# ── Tools (fast, keep eager) ───────────────────────────────────────────────────
unalias z 2>/dev/null; eval "$(zoxide init zsh)"
eval "$(pay-respects zsh)"

# ── Tmux git ───────────────────────────────────────────────────────────────────
if [[ $TMUX ]]; then source ~/.tmux-git/tmux-git.sh; fi

# ── Keybinds ───────────────────────────────────────────────────────────────────
bindkey '^x^x' edit-command-line

# ── Google Cloud SDK ───────────────────────────────────────────────────────────
if [ -f "${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/path.zsh.inc" ]; then
  . "${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/completion.zsh.inc" ]; then
  . "${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/completion.zsh.inc"
fi
