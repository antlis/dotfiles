{ lib, writeShellApplication, uv, python312 }:

# Headroom is not packaged in nixpkgs yet. Keep the command declarative in the
# system profile, but run it from a dedicated venv so dependency resolution is
# stable and repeatable.
writeShellApplication {
  name = "headroom";
  runtimeInputs = [ uv ];
  text = ''
    set -eu

    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/headroom"
    venv_dir="$cache_dir/venv"
    marker="$cache_dir/.installed"

    if [ ! -x "$venv_dir/bin/headroom" ] || [ ! -f "$marker" ]; then
      mkdir -p "$cache_dir"
      uv venv --python "${python312}/bin/python" "$venv_dir" >/dev/null
      uv pip install         --python "$venv_dir/bin/python"         'headroom-ai[proxy]'         >/dev/null
      touch "$marker"
    fi

    exec "$venv_dir/bin/headroom" "$@"
  '';
  meta = {
    description = "Headroom context compression CLI wrapper";
    homepage = "https://github.com/chopratejas/headroom";
    mainProgram = "headroom";
    platforms = lib.platforms.linux;
  };
}
