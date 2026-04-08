# AGENTS.md

This file provides guidance to AI coding agents working in this repository.

## What This Is

Personal dotfiles and NixOS configuration for a Linux desktop environment. Most files are declarative configuration, not executable code. The system runs NixOS with dual compositor support (i3 for X11, Niri for Wayland), Neovim (LazyVim), Zsh, Kitty terminal, and many TUI tools.

## How Dotfiles Are Managed

Two parallel systems exist:
- **NixOS + Home Manager** (`nix/`): Declarative configs for the NixOS machine. Home Manager generates symlinks for neovim, yazi, xbindkeysrc, etc. This is the primary system.
- **GNU Stow** (top-level dirs): Each top-level directory (e.g., `kitty/`, `tmux/`) mirrors the home directory structure. Run `stow <dirname>` to symlink into `~`. Used on non-NixOS systems.

Some configs exist in both `nix/home/` (Nix-managed) and as top-level stow packages. When editing, check which is active on the target system.

## Build / Lint / Validation Commands

### Nix (nix/ directory)

```bash
# Format all nix files (nixfmt-rfc-style)
nix fmt

# Check flake evaluates correctly
nix flake check

# Show what the NixOS build will produce
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run

# Rebuild NixOS (on NixOS machine)
sudo nixos-rebuild switch --flake .#nixos

# Update flake inputs
nix flake update
```

### Shell Scripts (scripts/, hypr/scripts/)

```bash
# Syntax check
bash -n script.sh

# ShellCheck (if installed)
shellcheck script.sh
```

## Architecture

- `nix/flake.nix` — Entry point. Imports system and home configs, plus external flakes (niri, noctalia shell, claude-code).
- `nix/constants.nix` — Shared values (username, paths) used across modules.
- `nix/system/` — NixOS system-level: boot, services, power management, packages.
- `nix/system/private.nix` — Gitignored. Sensitive system config.
- `nix/home/` — Home Manager: per-program configs (zsh/, tmux/, i3/, git.nix, kitty.nix, etc.).
- `nix/niri/` — Optional Niri Wayland compositor module (system + home + packages).
- `hypr/` — Hyprland config (standalone, not Nix-managed). Split into `custom/` (user prefs) and `hyprland/` (compositor-specific + scripts).
- `scripts/bootstrap.sh` — Clones external repos and plugins for non-NixOS setup.

## Code Style Guidelines

### Nix (.nix files)

- **Indentation**: 2 spaces, no tabs
- **Attrset style**: Use `{ key = value; }` for single-line, multi-line for large attrsets
- **Imports**: Use relative paths with `./` prefix
- **Comments**: Use `# ── Section ──` style for major sections (matching existing pattern)
- **Trailing semicolons**: Always include after final attribute in attrset
- **Let bindings**: Use `let ... in` for local definitions, indent body 2 spaces
- **Prefer inheriting**: Use `inherit` to reduce repetition
- **Naming**: Use camelCase for variable names in Nix (`myVariable`), kebab-case for file names
- **Formatting**: Run `nix fmt` (nixfmt-rfc-style)

Example:
```nix
{ config, pkgs, lib, ... }:
let
  c = import ./constants.nix;
in
{
  # ── Section ─────────────────────────────────────────
  imports = [ ./submodule.nix ];

  programs.foo = {
    enable = true;
    settings = {
      option = "value";
    };
  };
}
```

### Shell Scripts (.sh files)

- **Shebang**: `#!/usr/bin/env bash` (not sh)
- **Indentation**: 2 spaces
- **Variables**: Use `${VAR}` consistently, quote expansions `"$VAR"`
- **Functions**: Use `function name() { ... }` or `name() { ... }` (not both mixed)
- **Local variables**: Use `local` for function-local vars
- **Error handling**: Use `set -euo pipefail` at script top for strict mode
- **Exit codes**: Explicit `exit 0` or `exit 1` for scripts that return status

Example:
```bash
#!/usr/bin/env bash
set -euo pipefail

clone_or_pull() {
  local target="$1"
  local url="$2"
  if [[ -d "$target" ]]; then
    echo "Updating $(basename "$target")..."
    git -C "$target" pull
  fi
}
```

### Configuration Files

- **Hyprland (hypr/)**: Uses Hypr configuration syntax, keybinds in `keybinds.conf`
- **Kitty (kitty/)**: INI-style, comments with `#`
- **Yazi (yazi/)**: TOML format, theme in `theme.toml`
- **Tmux (tmux/)**: TMUX_CONF syntax, `.tmux.conf` + `.tmux-git.conf`

### General Conventions

- **Comments**: Keep minimal; explain "why", not "what"
- **Line length**: Prefer under 100 chars where reasonable
- **No trailing whitespace**: Remove on save
- **Executable scripts**: `chmod +x` for scripts in scripts/ and hypr/scripts/

## Important Notes

- NixOS 25.11 + Home Manager release-25.11
- Zsh uses Zinit with turbo mode for fast plugin loading
- Git uses `gh` (GitHub CLI) for credential management and `delta` as the pager
- Neovim config at `nvim-lazyvim/` uses LazyVim distribution with 40+ plugins managed via lazy.nvim
