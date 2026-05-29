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

    opencode = {
      # Pinned: commits from 2026-05-18 onward require bun 1.3.14, which is not
      # yet in nixpkgs 25.11 (has 1.3.13). This is the newest "update nix
      # node_modules hashes" commit still on bun 1.3.13 (2026-05-17), so its
      # nix/hashes.json matches the bun 1.3.13 build. Bump once nixpkgs has 1.3.14.
      url = "github:sst/opencode/49c6b46afc2815f396512b8ade2838a58785c636";
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
        inputs.opencode.overlays.default
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
