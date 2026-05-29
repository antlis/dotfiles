{ config, pkgs, lib, ... }:
let
  c = import ../constants.nix;
in
{
  # pi auto-discovers extensions from ~/.pi/agent/extensions/*.ts. Symlink our
  # nano-gpt provider in from the dotfiles repo (out-of-store, so edits to the
  # .ts apply without a rebuild). openrouter and opencode-zen are pi built-ins —
  # no extension needed, just `/login` (or their *_API_KEY env vars).
  home.file.".pi/agent/extensions/nano-gpt.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${c.dotfilesDir}/pi/extensions/nano-gpt.ts";
}
