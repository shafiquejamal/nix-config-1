{
  inputs,
  pkgs,
  unstablePkgs,
  ...
}: let
  inherit (inputs) nixpkgs nixpkgs-unstable;
  mcmodding-mcp = pkgs.callPackage ./mcmodding-mcp.nix {};
in {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.talosctl

    ## stable
    awscli2
    comma
    coreutils
    diffr # Modern Unix `diff`
    difftastic # Modern Unix `diff`
    dust # Modern Unix `du`
    dua # Modern Unix `du`
    duf # Modern Unix `df`
    entr # Modern Unix `watch`
    fd
    gh
    ghostscript
    go
    google-chrome
    jetbrains-mono # font
    jq
    just
    jdk25
    kubectl
    mcmodding-mcp
    nmap
    nodejs_24
    opencode
    podman
    podman-compose
    ripgrep
    rustup
    tree
    unzip
    uv
    watch
    wget
    zoom-us

    # requires nixpkgs.config.allowUnfree = true;
    # vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}
