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
  [ -f "$file" ] || continue
  filename=$(basename "$file")
  target="$ZSH_CUSTOM/$filename"
  if [ ! -L "$target" ]; then
    echo "Linking $filename to $ZSH_CUSTOM..."
    ln -sf "$file" "$target"
  else
    echo "$filename already linked, skipping..."
  fi
done
# Clone links repo to ~/Documents/
LINKS_REPO="$HOME/Documents/links"
clone_or_pull "$LINKS_REPO" "git@github.com:antlis/links.git"
# Symlink bookmarks to ~/.config/surfraw/bookmarks
SURFRAW_DIR="$CONFIG_DIR/surfraw"
if [ ! -d "$SURFRAW_DIR" ]; then
  echo "Creating $SURFRAW_DIR..."
  mkdir -p "$SURFRAW_DIR"
fi
BOOKMARKS_TARGET="$SURFRAW_DIR/bookmarks"
BOOKMARKS_SOURCE="$LINKS_REPO/bookmarks.link"
if [ ! -L "$BOOKMARKS_TARGET" ]; then
  echo "Linking bookmarks..."
  ln -sf "$BOOKMARKS_SOURCE" "$BOOKMARKS_TARGET"
else
  echo "bookmarks already linked, skipping..."
fi
# Clone rofi-scripts to ~/bin/rofi
BIN_DIR="$HOME/bin"
if [ ! -d "$BIN_DIR" ]; then
  echo "Creating $BIN_DIR..."
  mkdir -p "$BIN_DIR"
fi
clone_or_pull "$BIN_DIR/rofi" "git@github.com:antlis/rofi-scripts.git"
# Clone my-scripts to ~/my-scripts
clone_or_pull "$HOME/my-scripts" "git@github.com:antlis/my-scripts.git"
# Fetch fzf-kill binary
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
if [ ! -f "$LOCAL_BIN/fzf-kill" ]; then
  echo "Installing fzf-kill..."
  curl -L "https://raw.githubusercontent.com/Zeioth/fzf-kill/main/fzf-kill" -o "$LOCAL_BIN/fzf-kill"
  chmod +x "$LOCAL_BIN/fzf-kill"
else
  echo "fzf-kill already installed, skipping..."
fi
echo "Done!"
