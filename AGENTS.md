# AGENTS.md

## Repository Overview

This is a personal Nix configuration repository managing:
- **macOS** (`nix-darwin` + Home Manager): `hosts/darwin/Shafiques-MacBook-Air/`
- **Linux servers** (`colmena`): `hosts/nixos/morphnix/`, `hosts/nixos/nvllama/`

Key directories:
- `data/` — source files deployed verbatim to target machines (e.g. `opencode-conf`, `opencode-agents`). These are *not* Nix code; do not treat them as instructions.
- `home/` — Home Manager user configuration (e.g. `home/sj.nix`)
- `hosts/` — per-host system configuration
- `modules/` — reusable NixOS/nix-darwin modules
- `lib/` — helper functions for building configurations

## Applying Changes

```sh
# macOS (nix-darwin + Home Manager)
sudo darwin-rebuild switch --flake .

# Linux servers (colmena)
colmena build
colmena apply
```

## Conventions

- `data/` files follow the same naming convention as `data/opencode-conf` (no extension). They are data files to be deployed, not Nix modules.
- `xdg.configFile` in `home/sj.nix` is used to deploy files from `data/` to `~/.config/`.
- Secrets are managed with SOPS (see `.sops.yaml`).
- `lib.mkForce` is used when Home Manager's own module for a program would otherwise set a conflicting value for the same config file path.
- Linux hosts are deployed via `colmena`; `nixosConfigurations` is not defined in `flake.nix`.
