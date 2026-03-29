{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/opencode" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/lad/dotfiles/opencode;
    };
  };
}
