{ config, inputs, pkgs, lib, unstablePkgs, ... }:
{
  home.stateVersion = "23.11";

  # list of programs
  # https://mipmip.github.io/home-manager-option-search

  # aerospace config
  # home.file = lib.mkMerge [
  #   (lib.mkIf pkgs.stdenv.isDarwin {
  #     ".config/aerospace/aerospace.toml".text = builtins.readFile ./aerospace/aerospace.toml;
  #   })
  # ];
  xdg.configFile."ghostty/config".source = ghostty/config;
  programs.ghostty.package = null;
  programs.ghostty.enableZshIntegration = true;
  # programs.ghostty = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   package = null;
  #   settings = {
  #     shell-integration-features = "no-cursor";
  #     cursor-style = "block";
  #   };
  # };
  # programs.ghostty.settings = {
  #
  #   # theme = light:onehalflight,dark:Dracula
  #   theme = "nord";
  #
  #   #font-family = "FiraCode Nerd Font"
  #   font-family = "BerkeleyMono Nerd Font";
  #   font-size = 18;
  #
  #   window-width = 122;
  #   window-height = 30;
  #
  #   window-padding-x = 6;
  #   window-padding-y = 6;
  #   window-padding-balance = true;
  #
  #   macos-option-as-alt = true;
  #   macos-titlebar-style = "native";
  #   macos-icon = "custom-style";
  #   macos-icon-ghost-color = "white";
  #   macos-icon-screen-color = "black";
  #
  #   clipboard-paste-protection = false;
  #
  #   mouse-hide-while-typing = true;
  #
  #   shell-integration = "zsh";
  #
  #   auto-update = "off";
  #   shell-integration-features = "no-cursor";
  #   cursor-style = "block";
  # };
  programs.gpg.enable = true;
  # programs.zsh.oh-my-zsh = {
  #   enable = false;
  # };

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
      gruvbox
      vim-tmux-navigator
    ];
    extraConfig = lib.readFile ../data/tmux-conf;
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  programs.alacritty.enable = true;

  programs.bat.enable = true;
  programs.bat.config.theme = "Nord";
  #programs.zsh.shellAliases.cat = "${pkgs.bat}/bin/bat";

  # programs.nixvim = {
  #  enable = true;
  #  viAlias = true;
  #  vimAlias = true;
  #  # imports = lib.findModulesList ../data/nvim;
  # };
  
  #programs.neovim = {
  #  enable = true;
  #  viAlias = true;
  #  vimAlias = true;
  #  vimdiffAlias = true;
  #  defaultEditor = true;
  #   plugins = with pkgs.vimPlugins; [
  #     ## regular
  #     comment-nvim
  #     lualine-nvim
  #     nvim-web-devicons
  #     vim-tmux-navigator

  #     ## with config
  #     # {
  #     #   plugin = gruvbox-nvim;
  #     #   config = "colorscheme gruvbox";
  #     # }

  #     {
  #       plugin = catppuccin-nvim;
  #       config = "colorscheme catppuccin";
  #     }

  #     ## telescope
  #     {
  #       plugin = telescope-nvim;
  #       type = "lua";
  #       config = builtins.readFile ./nvim/plugins/telescope.lua;
  #     }
  #     telescope-fzf-native-nvim

  #   ];
  #   extraLuaConfig = '' 
  #     ${builtins.readFile ../data/nvim/lua/custom/telescope/live_grep.lua}
  #     ${builtins.readFile ../data/nvim/lua/config/keymaps.lua}
  #     '';
  #};

  programs.zoxide.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      StrictHostKeyChecking no
    '';
    matchBlocks = {
      # ~/.ssh/config
      "*" = {
        user = "root";
        extraOptions = {
          UserKnownHostsFile = "/dev/null";
          LogLevel = "ERROR";
        };
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
      };
    };
  };
}
