let
  username      = "lad";
  homeDir       = "/home/${username}";
  dotfilesDir   = "${homeDir}/dotfiles";
  screenshotDir = "${homeDir}/Pictures/Screenshot";
in
{
  inherit username homeDir dotfilesDir screenshotDir;
}
