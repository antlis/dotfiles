{ pkgs, inputs, ... }:
{
  programs.niri.enable = true;
  programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable.overrideAttrs {
    doCheck = false;
  };

  # Noctalia-shell binary cache
  nix.settings = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Electron/Chromium apps should use Wayland natively
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
