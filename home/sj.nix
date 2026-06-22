{ config, inputs, pkgs, lib, unstablePkgs, ... }:
{
  home.stateVersion = "23.11";
  xdg.configFile."ghostty/config".source = ghostty/config;
  programs.ghostty.package = null;
  programs.ghostty.enableZshIntegration = true;
  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--color=auto"
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [
      "--no-mouse"
    ];
  };

  programs.git.settings = {
    user.email = "shafique.jamal@gmail.com";
    user.name = "Shafique Jamal";
  };

  programs.git.settings = {
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "diff3";
        tool = "meld";
      };
      pull = {
        rebase = true;
      };
  }; 
  programs.diff-so-fancy.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = "openpgp";
  };

  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.lf.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = pkgs.lib.importTOML ./starship/starship.toml;
  };

  programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    initContent = (builtins.readFile ../data/mac-dot-zshrc);
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "ssh-agent" ];
      theme = "robbyrussell";
      extraConfig = ''
        zstyle :omz:plugins:ssh-agent quiet yes
        zstyle :omz:plugins:ssh-agent identities id_github id_bitbucket id_digitalocean id_aws.pem
      '';
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 9999999;
    mouse = true;
    shell = "/bin/zsh";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
    extraConfig = lib.readFile ../data/tmux-conf;
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  programs.opencode = {
    enable = true;
  };

  xdg.configFile."opencode/opencode.json".source = lib.mkForce ../data/opencode-conf;
  xdg.configFile."opencode/AGENTS.md".source = ../data/AGENTS.md;

  programs.alacritty.enable = true;

  programs.bat.enable = true;
  programs.bat.config.theme = "Nord";
  programs.zoxide.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        User = "root";
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
        LogLevel = "ERROR";
      };
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
      };
    };
  };
}
