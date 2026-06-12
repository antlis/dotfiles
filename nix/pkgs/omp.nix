{ lib, writeShellApplication, callPackage }:

# oh-my-pi (https://omp.sh) — a fork of pi-mono by @can1357 that adds LSP/DAP
# integration, persistent Python+Bun tool-calling kernels, and other "batteries
# included" features. Distributed as the npm package `@oh-my-pi/pi-coding-agent`.
#
# Why a wrapper, not a flake build:
# - omp ships no native release artifact; it is invoked via `bun <dist/cli.js>`.
# - nixpkgs 25.11's bun is 1.3.3 (too old) and nixpkgs-unstable maxes at 1.3.13
#   (still too old for the modern handlebars/JSX syntax in cli.js). We pull
#   bun from our own pkgs/bun.nix (pinned to 1.3.14).
# - Installing the npm package once into a cache dir (modeled on headroom.nix)
#   keeps the version under our control. Bumping omp = bump `version` below
#   + delete `~/.cache/omp/.installed-<old>`.
#
# Config dir: ~/.omp/agent/ — does NOT collide with pi's ~/.pi/agent/, so the
# two agents can coexist.
let
  version = "15.11.0";
  pkg = "@oh-my-pi/pi-coding-agent@${version}";
  # Our pinned 1.3.14 bun, not nixpkgs' 1.3.3.
  bun = callPackage ./bun.nix { };
in
writeShellApplication {
  name = "omp";
  runtimeInputs = [ bun ];
  text = ''
    set -eu

    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/omp"
    install_dir="$cache_dir/global"
    cli="$install_dir/node_modules/@oh-my-pi/pi-coding-agent/dist/cli.js"
    marker="$cache_dir/.installed-${version}"

    if [ ! -f "$cli" ] || [ ! -f "$marker" ]; then
      mkdir -p "$install_dir"
      BUN_INSTALL_GLOBAL_DIR="$install_dir" bun install -g "${pkg}" >/dev/null
      touch "$marker"
    fi

    # Invoke the package's bin entrypoint directly. `bun install -g` is
    # supposed to symlink `node_modules/.bin/omp` from package.json#bin, but
    # with @oh-my-pi/pi-coding-agent that symlink is not created (a known bun
    # quirk for this package's layout) so we resolve dist/cli.js ourselves.
    exec bun "$cli" "$@"
  '';
  meta = {
    description = "oh-my-pi coding agent CLI (LSP/DAP, Python+Bun tool-calling, fork of pi)";
    homepage = "https://omp.sh";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = lib.platforms.linux;
  };
}
