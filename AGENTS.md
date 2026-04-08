# AGENTS.md

This repository contains dotfiles and NixOS configuration. Most files are configuration
rather than executable code, but the following guidelines apply when editing.

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
- **Symlinks**: Use GNU Stow for managing dotfiles on non-NixOS systems

## Repository Structure

```
.
├── nix/           # NixOS flake (system + home manager configs)
│   ├── flake.nix  # Main entry point
│   ├── system/    # NixOS system modules
│   ├── home/      # Home Manager user configs
│   └── niri/      # Niri (Wayland) config (optional)
├── hypr/          # Hyprland (Wayland compositor) config
├── i3/            # i3 window manager config
├── zsh/           # Zsh config for non-NixOS systems
├── nvim-lazyvim/  # Neovim/LazyVim config
├── tmux/          # Tmux config
├── kitty/         # Terminal emulator config
├── rofi/          # Application launcher config
├── yazi/          # File manager config
├── scripts/       # Utility scripts (bootstrap.sh, monitor.sh)
├── starship/      # Prompt config
├── git/           # Git config
├── keynav/        # Keyboard mouse config
├── xbindkeysrc/   # X11 keybindings
└── opencode/      # OpenCode AI assistant config
```

## Notes

- Nix config uses NixOS 25.11 + Home Manager release-25.11
- Zsh uses Zinit for fast plugin loading (turbo mode)
- Some configs exist in both `nix/home/` (Nix-managed) and top-level (stow-managed)
- Private configs go in `nix/system/private.nix` (gitignored)