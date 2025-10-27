{
  inputs = {
    # Every six months, update this. For six months from release, continues to reeive security updates.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = {...} @ inputs:
    with inputs; let
      inherit (self) outputs;

      stateVersion = "25.05";
      libx = import ./lib {inherit inputs outputs stateVersion;};
    in {
      darwinConfigurations = {
        # personal
        Shafiques-MacBook-Air = libx.mkDarwin {hostname = "Shafiques-MacBook-Air";};
      };

      colmena = {
        meta = {
          nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
          specialArgs = {
            inherit inputs outputs stateVersion self;
          };
        };

        defaults = {
          lib,
          config,
          name,
          ...
        }: {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
        };

        # wd
        morphnix = import ./hosts/nixos/morphnix;
        nvllama = import ./hosts/nixos/nvllama;
      };
    };
}
