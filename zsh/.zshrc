# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"
# ZSH_THEME="dracula"
# ZSH_THEME="af-magic"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  tmux
  ssh-agent
  gh
  git
  zshmarks
  vi-mode
  fzf
  you-should-use
  zsh-syntax-highlighting
  docker
  zsh-docker-aliases
  docker-compose
)
# https://github.com/MichaelAquilina/zsh-you-should-use

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Startup lunch
# exec cd $HOME/Projects/prismhr/delta-tax/ && npm run dev


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f $HOME/.nvm/versions/node/v12.9.0/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash ] && . $HOME/.nvm/versions/node/v12.9.0/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
# [ -f $HOME/.nvm/versions/node/v12.9.0/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash ] && . $HOME/.nvm/versions/node/v12.9.0/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
# [ -f $HOME/.nvm/versions/node/v12.9.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.bash ] && . $HOME/.nvm/versions/node/v12.9.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.bash

# FZF stuff
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [[ $TMUX ]]; then source ~/.tmux-git/tmux-git.sh; fi
# https://dev.to/matrixersp/how-to-use-fzf-with-ripgrep-to-selectively-ignore-vcs-files-4e27
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 96% --reverse --preview "highlight -O ansi --force {}"'

# https://www.erickpatrick.net/blog/adding-syntax-highlighting-to-fzf.vim-preview-window
# export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --layout reverse --margin=1,4 --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# export FZF_DEFAULT_OPTS='--height 96% --reverse --preview "cat {}"'

# Load RVM if it is installed,
#  first try to load  user install
#  then try to load root install, if user install is not there.
if [ -s "$HOME/.rvm/scripts/rvm" ] ; then
  . "$HOME/.rvm/scripts/rvm"
elif [ -s "/usr/local/rvm/scripts/rvm" ] ; then
  . "/usr/local/rvm/scripts/rvm"
fi

### ZNT's installer added snippet ###
# fpath=( "$fpath[@]" "$HOME/.config/znt/zsh-navigation-tools" )
# autoload n-aliases n-cd n-env n-functions n-history n-kill n-list n-list-draw n-list-input n-options n-panelize n-help
# autoload znt-usetty-wrapper znt-history-widget znt-cd-widget znt-kill-widget
# alias naliases=n-aliases ncd=n-cd nenv=n-env nfunctions=n-functions nhistory=n-history
# alias nkill=n-kill noptions=n-options npanelize=n-panelize nhelp=n-help
# zle -N znt-history-widget
# bindkey '^R' znt-history-widget
# setopt AUTO_PUSHD HIST_IGNORE_DUPS PUSHD_IGNORE_DUPS
# zstyle ':completion::complete:n-kill::bits' matcher 'r:|=** l:|=*'
### END ###

# https://www.youtube.com/watch?v=mz9LBUteKNo
# Edit command line in vim
bindkey '^x^x' edit-command-line

eval $(thefuck --alias)

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# autojump
# . /usr/share/autojump/autojump.sh
source "/etc/profile.d/rvm.sh"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# custom node scripts path
path+=~/.js
path+=('${HOME}/.local/bin/')

# The next line updates PATH for the Google Cloud SDK.
if [ -f '${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/path.zsh.inc' ]; then .'${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/completion.zsh.inc' ]; then . '${HOME}/google-cloud-sdk-345.0.0-linux-x86_64/google-cloud-sdk/completion.zsh.inc'; fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# GH
# https://cli.github.com/manual/gh_help_environment
export GH_EDITOR="nvim"
export ts_issue="ToolSense/frontend"
