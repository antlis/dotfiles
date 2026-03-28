{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    blueman
  ];
}
