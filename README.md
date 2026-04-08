# 🏠 dotfiles

> My personal Arch Linux configuration files, managed with GNU Stow

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![NixOS](https://img.shields.io/badge/-NixOS-5277C3?style=for-the-badge&logo=NixOS&logoColor=white)
![Maintained](https://img.shields.io/badge/Maintained-yes-green.svg?style=for-the-badge)

## 📦 Setup

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management.

```bash
# Clone the repository
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Install a specific configuration
stow <package-name>

# Example: Install nvim configuration
stow nvim-lazyvim

# Install all configurations
stow */
```

## 🛠️ Tools & Configurations

### 🪟 Window Managers & Compositors

| Tool | Description | Config |
|------|-------------|--------|
| ![Hyprland](https://img.shields.io/badge/-Hyprland-58E1FF?style=flat&logo=wayland&logoColor=white) **hypr** | Modern Wayland compositor with eye-candy animations | `hypr/` |
| ![i3](https://img.shields.io/badge/-i3wm-2A2A2A?style=flat) **i3** | Tiling window manager for X11 | `i3/` |

### 🖥️ Terminal & Shell

| Tool | Description | Config |
|------|-------------|--------|
| ![Kitty](https://img.shields.io/badge/-Kitty-000000?style=flat) **kitty** | GPU-accelerated terminal emulator | `kitty/` |
| ![Zsh](https://img.shields.io/badge/-Zsh-4EAA25?style=flat&logo=gnu-bash&logoColor=white) **zsh** | Z Shell with Zinit for fast plugin loading | `zsh/` |
| ![Tmux](https://img.shields.io/badge/-Tmux-1BB91F?style=flat) **tmux** | Terminal multiplexer for session management | `tmux/` |
| **starship** | Blazing-fast cross-shell prompt | `starship/` |

### ✏️ Editor

| Tool | Description | Config |
|------|-------------|--------|
| ![Neovim](https://img.shields.io/badge/-Neovim-57A143?style=flat&logo=neovim&logoColor=white) **lazyvim** | Neovim with LazyVim distribution | `nvim-lazyvim/` |

### 🚀 Application Launchers & Tools

| Tool | Description | Config |
|------|-------------|--------|
| ![Rofi](https://img.shields.io/badge/-Rofi-FF7139?style=flat) **rofi** | Application launcher and dmenu replacement | `rofi/` |
| ![Yazi](https://img.shields.io/badge/-Yazi-F6C177?style=flat) **yazi** | Blazing fast terminal file manager | `yazi/` |

### ⚙️ Utilities & Dev Tools

| Tool | Description | Config |
|------|-------------|--------|
| ![Git](https://img.shields.io/badge/-Git-F05032?style=flat&logo=git&logoColor=white) **git** | Version control system configuration | `git/` |
| **keynav** | Keyboard-driven mouse cursor control | `keynav/` |
| **xbindkeysrc** | X11 keyboard shortcuts daemon | `xbindkeysrc/` |
| **opencode** | OpenCode AI assistant configuration | `opencode/` |

### 📦 Infrastructure as Code

| Tool | Description | Config |
|------|-------------|--------|
| ![NixOS](https://img.shields.io/badge/-NixOS-5277C3?style=flat&logo=NixOS&logoColor=white) **nix** | NixOS flake with Home Manager for declarative config | `nix/` |

### 📜 Scripts

| Script | Description |
|--------|-------------|
| **bootstrap.sh** | Sets up zsh plugins (zinit), private repos, and external dependencies |
| **monitor.sh** | Display layout script for multi-monitor setups |

## 🎨 Features

- 🌊 **Wayland-ready**: Hyprland/Niri configuration with smooth animations
- 🪟 **X11 fallback**: i3wm for compatibility
- ⚡ **Blazing fast**: GPU-accelerated terminal, modern file manager, starship prompt
- 🎯 **Keyboard-centric**: Vim motions everywhere, custom keybindings
- 📦 **Modular**: Each tool is a separate stow package
- 🐚 **Shell enhancements**: Zsh with Zinit (turbo-loading), syntax highlighting, fzf-tab
- 🐧 **NixOS-ready**: Full NixOS + Home Manager configuration for declarative system management

## 📝 Notes

- **OS**: Arch Linux / NixOS 🐧
- **Management**: GNU Stow for symlink farm (or Nix for NixOS)
- **Philosophy**: Minimal, fast, keyboard-driven workflow

## 🔧 Requirements

```bash
# Install stow
sudo pacman -S stow

# Install tools (adjust as needed)
sudo pacman -S hyprland i3-wm kitty zsh tmux neovim rofi git yazi keynav xbindkeys starship
```

## 📚 Structure

```
~/.dotfiles/
├── git/          # Git configuration
├── hypr/         # Hyprland (Wayland compositor)
├── i3/           # i3 window manager
├── keynav/       # Keyboard navigation
├── kitty/        # Terminal emulator
├── nix/          # NixOS flake + Home Manager config
├── nvim-lazyvim/ # Neovim with LazyVim
├── opencode/     # OpenCode AI assistant config
├── rofi/         # Application launcher
├── scripts/      # Bootstrap and utility scripts
├── starship/     # Starship prompt config
├── tmux/         # Terminal multiplexer
├── xbindkeysrc/  # X11 keybindings
├── yazi/         # File manager
└── zsh/          # Z Shell (Zinit-based)
```

## 🤝 Contributing

Feel free to fork and adapt these dotfiles for your own use!

## 📄 License

These configurations are free to use and modify.