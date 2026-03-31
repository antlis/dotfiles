let
  username      = "lad";
  homeDir       = "/home/lad";
  dotfilesDir   = "${homeDir}/dotfiles";
  screenshotDir = "${homeDir}/Pictures/Screenshot";
in
{
  inherit username homeDir dotfilesDir screenshotDir;
}
