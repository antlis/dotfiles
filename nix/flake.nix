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
      # Pinned: a specific commit on main that matches the bun version we
      # provide (now ≥1.3.14 via the nixpkgs-unstable overlay above). This
      # commit was the last "update nix node_modules hashes" update whose
      # build target bun range overlapped with the rest of the system. Bump
      # periodically alongside a `nix flake update opencode` and a rebuild.
      url = "github:sst/opencode/49c6b46afc2815f396512b8ade2838a58785c636";
    };

    # pi coding agent (https://pi.dev). No official nixpkgs entry; this community
    # flake builds @earendil-works/pi-coding-agent and exposes pkgs.pi-coding-agent
    # via its overlay. Intentionally NOT following our nixpkgs: it pins its own
    # nixpkgs so its pi.cachix.org cache hits and we avoid a local npm build.
    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      claude-code,
      ...
    }@inputs:
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
          inputs.pi.overlays.default
          (final: prev: {
            amnezia-vpn = final.callPackage ./pkgs/amnezia-vpn.nix { };
            mimocode = final.callPackage ./pkgs/mimocode.nix { };
          })
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

          (
            { config, ... }:
            {
              nixpkgs.pkgs = pkgs;
            }
          )

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
