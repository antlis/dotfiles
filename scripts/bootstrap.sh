#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Private repos cloned to ~/.config
declare -A CONFIG_REPOS=(
  ["tmuxinator"]="git@github.com:antlis/tmuxinator.git"
  # add more as needed
)

# Oh-my-zsh custom plugins
declare -A ZSH_PLUGINS=(
  ["fzf-tab"]="git@github.com:Aloxaf/fzf-tab.git"
  ["you-should-use"]="git@github.com:MichaelAquilina/zsh-you-should-use.git"
  ["zsh-syntax-highlighting"]="git@github.com:zsh-users/zsh-syntax-highlighting.git"
  ["zshmarks"]="git@github.com:jocelynmallon/zshmarks.git"
)

clone_or_pull() {
  local target="$1"
  local url="$2"
  if [ -d "$target" ]; then
    echo "Updating $(basename $target)..."
    git -C "$target" pull
  else
    echo "Cloning $url..."
    git clone "$url" "$target"
  fi
}

# Clone private repos into ~/.config
for dir in "${!CONFIG_REPOS[@]}"; do
  clone_or_pull "$CONFIG_DIR/$dir" "${CONFIG_REPOS[$dir]}"
done

# Clone zsh plugins into oh-my-zsh custom plugins dir
mkdir -p "$ZSH_CUSTOM/plugins"
for plugin in "${!ZSH_PLUGINS[@]}"; do
  clone_or_pull "$ZSH_CUSTOM/plugins/$plugin" "${ZSH_PLUGINS[$plugin]}"
done

# Clone zsh-custom repo and symlink files to ~/.oh-my-zsh/custom/
ZSH_CUSTOM_REPO="$HOME/.zsh-custom"
clone_or_pull "$ZSH_CUSTOM_REPO" "git@github.com:antlis/zsh-custom.git"

# Symlink aliases and functions to ZSH_CUSTOM
for file in "$ZSH_CUSTOM_REPO"/*.zsh; do
  [ -f "$file" ] || continue  # skip if glob didn't expand
  filename=$(basename "$file")
  target="$ZSH_CUSTOM/$filename"
  if [ ! -L "$target" ]; then
    echo "Linking $filename to $ZSH_CUSTOM..."
    ln -sf "$file" "$target"
  else
    echo "$filename already linked, skipping..."
  fi
done

echo "Done!"
