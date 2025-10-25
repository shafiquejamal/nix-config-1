# ironicbadger/nix-config

Repo contains configuration for personal machines, mostly running nix-darwin. I have no idea what I'm doing, and the deeper I go the less of a clue I have apparently.

```
nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.Shafiques-MacBook-Air.system" && sudo ./result/sw/bin/darwin-rebuild switch --flake ".#"


sudo darwin-rebuild switch --flake .

# This first way pins to a specific commit - this is for 25.05. Only if you need to. In general, use the second command. To get the the commit number:
# https://status.nixos.org/
# nixpkgs-25.05-darwin	
nix flake lock --update-input nixpkgs github:NixOS/nixpkgs/95ec937f47c15392185aafd64480dc128f8a80bd

# This takes the latest - maybe be not a good idea to take the last, because will not have the cache, and will rebuild the world
# Run this - then wait a day or two to build
nix flake update nixpkgs
sudo darwin-rebuild switch --flake .
```
