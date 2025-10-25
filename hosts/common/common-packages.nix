{ inputs, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    nixpkgs-unstable.legacyPackages.${pkgs.system}.beszel
    nixpkgs-unstable.legacyPackages.${pkgs.system}.talosctl

    ## stable
    comma
    coreutils
    diffr # Modern Unix `diff`
    difftastic # Modern Unix `diff`
    du-dust # Modern Unix `du`
    dua # Modern Unix `du`
    duf # Modern Unix `df`
    entr # Modern Unix `watch`
    fd
    gh
    google-chrome
    jetbrains-mono # font
    jq
    just
    kubectl
    neovim
    nmap
    ripgrep
    tree
    unzip
    uv
    watch
    wget

    # requires nixpkgs.config.allowUnfree = true;
    # vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}
