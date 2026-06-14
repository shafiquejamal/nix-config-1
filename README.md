# ironicbadger/nix-config

Repo contains configuration for personal machines, mostly running nix-darwin. I have no idea what I'm doing, and the deeper I go the less of a clue I have apparently.

```sh
nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.Shafiques-MacBook-Air.system" && sudo ./result/sw/bin/darwin-rebuild switch --flake ".#"


sudo darwin-rebuild switch --flake .

# This first way pins to a specific commit - this is for 25.05. Only if you need to. In general, use the second command. To get the the commit number:
# https://status.nixos.org/
# nixpkgs-25.05-darwin
nix flake lock --update-input nixpkgs github:NixOS/nixpkgs/95ec937f47c15392185aafd64480dc128f8a80bd

# This takes the latest - maybe be not a good idea to take the last, because will not have the cache, and will rebuild the world
# Run this - then wait a day or two to build
nix flake update nixpkgs
nix flake update && sudo darwin-rebuild switch --flake .
```

## Adding a Linux host

This repo is currently used primarily for `nix-darwin`. When adding a Linux host, create it under `hosts/nixos/<hostname>/default.nix`.

### 1. Create the host file

Example:

```nix
# hosts/nixos/<hostname>/default.nix
{ inputs, pkgs, lib, stateVersion, ... }:
{
  imports = [
    ../../common/nixos-common.nix
    ../../../modules/beszel-agent.nix
  ];

  networking.hostName = "<hostname>";

  services.beszel-agent = {
    enable = true;
    # key = "...";
    # extraFilesystems = [ "/" ];
  };
}
```

### 2. Add the host to `flake.nix`

Under the `colmena` output, add:

```nix
<hostname> = import ./hosts/nixos/<hostname>;
```

### 3. Deploy it

Linux hosts are currently intended to be deployed through `colmena`:

```sh
colmena build
colmena apply
```

### 4. Optional: local `nixos-rebuild`

The `justfile` includes Linux `nixos-rebuild` commands, but `flake.nix` does not currently define `nixosConfigurations`. If you want to use:

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

you will also need to add a `nixosConfigurations` output for that host.

## Beszel on Linux

`beszel` is not installed as a shared package. It is owned by `modules/beszel-agent.nix`, so a Linux host only gets it when that module is imported and `services.beszel-agent.enable = true;`.
