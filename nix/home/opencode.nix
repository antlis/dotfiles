{ config, pkgs, lib, ... }:
let
  c = import ../constants.nix;
in
{
  home.file = {
    ".config/opencode" = {
      source = config.lib.file.mkOutOfStoreSymlink "${c.dotfilesDir}/opencode";
    };
  };
}
