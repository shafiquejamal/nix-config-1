# mcmodding-mcp Implementation Plan

## Goal

Add `mcmodding-mcp` to this Nix config as a declaratively packaged CLI/MCP server, without using `npm install -g`.

This plan is written so a lower-cost model can implement it correctly with minimal guesswork.

## Repo-Specific Context

- Repo root: `/Users/sj/tmp/nix-config`
- This repo does **not** currently have a local `pkgs/` tree or package overlay convention.
- Shared system packages are defined in `hosts/common/common-packages.nix`.
- The repo already overlays Node in `lib/helpers.nix`:
  - `nodejs = prev.nodejs_22;`
  - `nodejs-slim = prev.nodejs-slim_22;`
- Do **not** change that overlay as part of this task.
- Do **not** change the existing `nodejs_24` entry in `environment.systemPackages`; that is a separate policy decision.

## Why This Packaging Approach

Use the upstream GitHub tag, not the published npm tarball.

Reason:

- reproducible `pnpm` packaging in Nix needs `pnpm-lock.yaml`
- the GitHub tag includes the lockfile
- the npm tarball ships built output but not the lockfile, making reproducible vendoring worse

Use `fetchPnpmDeps` + `pnpmConfigHook`.

Disable upstream `postinstall`.

Reason:

- upstream `postinstall` downloads the documentation database from GitHub
- that is network I/O and should not happen during a Nix build
- the application can download/update its databases at runtime instead

## Files To Change

1. Add a new file: `hosts/common/mcmodding-mcp.nix`
2. Update: `hosts/common/common-packages.nix`

Do **not** modify any other files.

## New File: `hosts/common/mcmodding-mcp.nix`

Create this file with the exact content below:

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs-slim,
  pnpm_10,
  pnpmConfigHook,
  makeWrapper,
  python3,
  cctools,
  xcbuild,
}:

let
  pnpm = pnpm_10.override { inherit nodejs-slim; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mcmodding-mcp";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "OGMatrix";
    repo = "mcmodding-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7f22gyIBFFC6+lTEMpbYA9fsw/2f2H8X7KTgj2jl47Y=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-feUl2B1HYI/haJDJhOue+aDs59szjN2YIrFSsKJlF7Q=";
  };

  nativeBuildInputs =
    [
      nodejs-slim
      pnpmConfigHook
      pnpm
      makeWrapper
      python3
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cctools
      xcbuild
    ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"postinstall": "node scripts/postinstall.js",' ""
  '';

  buildPhase = ''
    runHook preBuild

    export npm_config_nodedir=${nodejs-slim}

    pushd node_modules
    pnpm rebuild better-sqlite3 esbuild protobufjs
    popd

    pushd node_modules/.pnpm/node_modules/sharp
    pnpm run install
    popd

    pnpm build
    CI=true pnpm prune --prod --ignore-scripts

    # Clean up broken symlinks left behind by `pnpm prune`.
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/mcmodding-mcp $out/bin
    cp -r dist node_modules package.json $out/libexec/mcmodding-mcp/

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/mcmodding-mcp \
      --add-flags "$out/libexec/mcmodding-mcp/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP server for Minecraft modding documentation";
    homepage = "https://github.com/OGMatrix/mcmodding-mcp";
    license = licenses.mit;
    mainProgram = "mcmodding-mcp";
    platforms = platforms.unix;
  };
})
```

## Why Each Choice Matters

These are not optional implementation details:

- `pnpm = pnpm_10.override { inherit nodejs-slim; };`
  - keeps `pnpm` and Node on the same toolchain
  - avoids subtle mismatches between dependency vendoring and build-time native module rebuilds

- `postPatch` removing `postinstall`
  - prevents network downloads during the Nix build
  - upstream runtime still knows how to manage/download DB files later

- `pnpm rebuild better-sqlite3 esbuild protobufjs`
  - upstream marks these as built dependencies
  - they should be rebuilt in the vendored dependency tree

- `sharp` handled separately with `pnpm run install`
  - this matches stronger nixpkgs patterns for `sharp`
  - do **not** fold `sharp` into the generic rebuild line

- `CI=true pnpm prune --prod --ignore-scripts`
  - removes dev dependencies before installation

- `find node_modules -xtype l -delete`
  - `pnpm prune` is known to leave dangling symlinks
  - do **not** skip this cleanup step

- install layout under `$out/libexec/mcmodding-mcp`
  - runtime code uses its own `dist` and `node_modules`
  - database files are stored in HOME/XDG locations, not in the install tree

- no `--chdir` in the wrapper
  - not needed based on upstream runtime behavior
  - avoid adding extra behavior without evidence it is required

## Update `hosts/common/common-packages.nix`

Modify the file minimally.

### Current top of file

It currently begins like this:

```nix
{
  inputs,
  pkgs,
  unstablePkgs,
  ...
}: let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in {
```

### Change it to

```nix
{
  inputs,
  pkgs,
  unstablePkgs,
  ...
}: let
  inherit (inputs) nixpkgs nixpkgs-unstable;
  mcmodding-mcp = pkgs.callPackage ./mcmodding-mcp.nix {};
in {
```

### Then add `mcmodding-mcp` to `environment.systemPackages`

Insert it into the package list near the other developer tools. Keep the rest of the file unchanged.

The relevant section should become:

```nix
    jq
    just
    jdk21
    kubectl
    mcmodding-mcp
    nmap
    nodejs_24
    opencode
```

Do **not** remove or rename `nodejs_24`.

## Expected Result After Implementation

After rebuilding the system:

- `mcmodding-mcp` should be on `PATH`
- the command `mcmodding-mcp` should launch the packaged CLI
- the package build should not attempt network downloads for the documentation database
- at runtime, the tool may still download/update its databases in the user data directory

Expected runtime data locations from upstream:

- macOS: `~/Library/Application Support/mcmodding-mcp`
- Linux: `${XDG_DATA_HOME:-~/.local/share}/mcmodding-mcp`

## Verification Steps

Perform verification in this order.

### 1. Read back the changed files

Confirm:

- `hosts/common/mcmodding-mcp.nix` exactly matches the planned structure
- `hosts/common/common-packages.nix` only has the new `let` binding and the added package entry

### 2. Build the Darwin system configuration

From repo root, run:

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.Shafiques-MacBook-Air.system"
```

This is the meaningful validation step for this repo.

### 3. If the build succeeds, optionally apply it

Only if the task explicitly includes switching the system, run:

```sh
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#"
```

If the task is only to implement the code change, building is enough.

### 4. Sanity check command visibility after switch

If a switch was performed, verify:

```sh
mcmodding-mcp --help
```

If `--help` is unsupported, just run:

```sh
mcmodding-mcp
```

and confirm the command starts rather than failing due to missing runtime files.

## Things The Implementing Model Must Not Do

- Do not add a new top-level `pkgs/` directory.
- Do not modify `flake.nix`.
- Do not modify `lib/helpers.nix`.
- Do not replace `nodejs_24` with `nodejs` in `environment.systemPackages`.
- Do not re-enable upstream `postinstall`.
- Do not add extra wrapper flags like `--chdir` unless a real runtime failure proves they are needed.
- Do not add tests or scripts that do not already fit this repo.

## Common Failure Modes And How To Avoid Them

### Failure: `sharp` packaging breaks

Cause:

- using `pnpm rebuild sharp` instead of `pnpm run install` in the `sharp` package directory

Fix:

- keep the dedicated `pushd node_modules/.pnpm/node_modules/sharp` block exactly as written

### Failure: store output contains broken symlinks

Cause:

- running `pnpm prune` without cleaning dangling symlinks

Fix:

- keep `find node_modules -xtype l -delete`

### Failure: native module mismatch

Cause:

- `pnpm` and Node using different versions/toolchains

Fix:

- keep `pnpm = pnpm_10.override { inherit nodejs-slim; };`

### Failure: build attempts network access

Cause:

- forgetting to remove upstream `postinstall`

Fix:

- keep the `substituteInPlace package.json` removal

## Minimal Success Criteria

The implementation is correct if:

1. the new package file exists with the planned content
2. `common-packages.nix` references it with `pkgs.callPackage ./mcmodding-mcp.nix {}`
3. the package is added to `environment.systemPackages`
4. `nix build ".#darwinConfigurations.Shafiques-MacBook-Air.system"` succeeds
