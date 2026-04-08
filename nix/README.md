# NixOS Configuration

Nix flake for declarative system configuration using NixOS + Home Manager.

## Structure

- `flake.nix` - Main flake entry point
- `constants.nix` - Shared constants (username, home dir, paths)
- `system/` - NixOS system-level configuration
  - `configuration.nix` - Main system config (boot, power, services)
  - `packages/` - System packages (python, node, rust)
  - `bluetooth.nix` - Bluetooth configuration
- `home/` - Home Manager user configuration
  - `zsh/` - Zsh configuration (via zinit)
  - `tmux/` - Tmux configuration
  - `i3/` - i3 window manager config
  - `kitty/`, `rofi/`, `git/`, `opencode.nix` - Various app configs
- `niri/` - Niri (Wayland compositor) config (optional)

## Features

- **Dual compositor support**: i3 (X11) and Niri (Wayland)
- **Noctalia shell**: Custom shell integration
- **Power management**: Suspend-then-hibernate, hibernation support
- **Full user environment**: Zsh, tmux, kitty, rofi, git via Home Manager
- **Custom packages**: Python, Node.js, Rust toolchains

## Usage

```bash
# Rebuild NixOS
sudo nixos-rebuild switch --flake .#nixos

# Format nix files
nix fmt

# Update flakes
nix flake update
```