{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri + Noctalia (remove these two inputs to disable)
    niri.url = "github:sodiboo/niri-flake";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, claude-code, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };

      overlays = [
        inputs.claude-code.overlays.default
      ];
    };

    c = import ./constants.nix;
    privateNix = /. + c.homeDir + "/dotfiles/nix/system/private.nix";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./system/configuration.nix
        home-manager.nixosModules.home-manager

        # Niri + Noctalia (remove these 3 lines to disable)
        inputs.niri.nixosModules.niri
        ./niri/system.nix
        ./niri/home.nix

        ({ config, ... }: {
          nixpkgs.pkgs = pkgs;
        })

        (builtins.path {
          path = /etc/nixos/hardware-configuration.nix;
          name = "hardware-configuration.nix";
        })

        (builtins.path {
          path = privateNix;
          name = "private.nix";
        })
      ];
    };
    formatter.x86_64-linux = pkgs.nixfmt-rfc-style;
  };
}
