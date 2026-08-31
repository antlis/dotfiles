{ config, pkgs, lib, ... }:
let
  c = import ../constants.nix;
in
{
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${c.dotfilesDir}/.claude/settings.json";
  };
}
