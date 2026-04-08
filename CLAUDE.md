# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles and NixOS configuration for a Linux desktop environment. Most files are declarative configuration, not executable code. The system runs NixOS with dual compositor support (i3 for X11, Niri for Wayland), Neovim (LazyVim), Zsh, Kitty terminal, and many TUI tools.

## Key Commands

```bash
# NixOS rebuild (run from nix/ directory)
sudo nixos-rebuild switch --flake .#nixos

# Format all .nix files
nix fmt

# Check flake evaluates
nix flake check

# Dry-run build
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run

# Update flake inputs
nix flake update

# Shell script linting
shellcheck script.sh
```

## How Dotfiles Are Managed

Two parallel systems exist:
- **NixOS + Home Manager** (`nix/`): Declarative configs for the NixOS machine. Home Manager generates symlinks for neovim, yazi, xbindkeysrc, etc. This is the primary system.
- **GNU Stow** (top-level dirs): Each top-level directory (e.g., `kitty/`, `tmux/`) mirrors the home directory structure. Run `stow <dirname>` to symlink into `~`. Used on non-NixOS systems.

Some configs exist in both `nix/home/` (Nix-managed) and as top-level stow packages. When editing, check which is active on the target system.

## Architecture

- `nix/flake.nix` — Entry point. Imports system and home configs, plus external flakes (niri, noctalia shell, claude-code).
- `nix/constants.nix` — Shared values (username, paths) used across modules.
- `nix/system/` — NixOS system-level: boot, services, power management, packages.
- `nix/system/private.nix` — Gitignored. Sensitive system config.
- `nix/home/` — Home Manager: per-program configs (zsh/, tmux/, i3/, git.nix, kitty.nix, etc.).
- `nix/niri/` — Optional Niri Wayland compositor module (system + home + packages).
- `hypr/` — Hyprland config (standalone, not Nix-managed). Split into `custom/` (user prefs) and `hyprland/` (compositor-specific + scripts).
- `scripts/bootstrap.sh` — Clones external repos and plugins for non-NixOS setup.

## Code Style

- **Nix**: 2 spaces, `# -- Section --` comments, camelCase variables, kebab-case filenames, always trailing semicolons. Format with `nix fmt` (nixfmt-rfc-style).
- **Shell**: `#!/usr/bin/env bash`, 2 spaces, `set -euo pipefail`, quote all variable expansions.
- **Config files**: Follow existing format conventions per tool (TOML for yazi/starship, INI-style for kitty, Hypr syntax for hyprland).
- Comments explain "why", not "what". Keep line length under 100 chars.

## Important Notes

- NixOS 25.11 + Home Manager release-25.11.
- Zsh uses Zinit with turbo mode for fast plugin loading.
- Git uses `gh` (GitHub CLI) for credential management and `delta` as the pager.
- Neovim config at `nvim-lazyvim/` uses LazyVim distribution with 40+ plugins managed via lazy.nvim.
