{ config, pkgs, ... }:

let
  secrets = import /etc/nixos/secrets.nix;
in {
  imports = [
    (builtins.fetchGit {
      url = "https://github.com/rycee/home-manager.git";
      rev = "8b15f1899356762187ce119980ca41c0aba782bb";
    } + "/nixos/default.nix")
    ./users/sarius.nix
  ];
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    termite.terminfo
    rxvt_unicode.terminfo
    restic
  ];

  environment.variables.EDITOR = "vim";

  users.mutableUsers = false; # disallow change of users by user
  users.users.kloenk = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "bluetooth"
      "libvirt"
    ];
    shell = pkgs.fish;
    hashedPassword = secrets.hashedPasswords.kloenk;
    packages = with pkgs; [
      wget
      vim
      tmux
      nload
      htop
      rsync
      ripgrep
      exa
      bat
      progress
      pv
      parallel
      skim
      file
      git
      elinks
      bc
      zstd
      usbutils
      pciutils
      mediainfo
      ffmpeg_4
      mktorrent
      unzip
      gptfdisk
      jq
      nix-prefetch-git
      pass-otp
      gopass
      neofetch
      sl
      exa
    ];
  };

  home-manager.users.kloenk = {

    programs.vim = {
      enable = true;
      extraConfig = ''
        source $VIMRUNTIME/defaults.vim

        " make vim more vimy
        set nocompatible
  
        " encoding
        set encoding=utf-8

        " UI
        set history=50
        set ruler
        set showcmd

        " File search
        set path+=**
        set wildmenu
        set wildignore+=**/target**,**/*.iml,**/.git/**
  
        " Search
        set hlsearch
  
        " File browsing
        filetype plugin on
        let g:netrw_banner=0        " disable annoying banner
        let g:netrw_browse_split=4  " open in prior window
        let g:netrw_altv=1          " open splits to the right
        let g:netrw_liststyle=3     " tree view
        let g:netrw_list_hide=netrw_gitignore#Hide()
        let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
  
        " Code folding
        set nu
        set foldmethod=indent
        set foldlevel=99
        nnoremap <space> za
  
        " Code styling
        filetype plugin indent on
        syntax on
  
        " Completion
        set autoindent
        inoremap { {<CR>}<ESC>O
  
        " SBT integration
        nnoremap <C-b> :w<CR>:!sbt -client package<CR>:!scala ./target/*/*.jar<CR>
  
        "execute pathogen#infect()
        " filetype plugin indent on
  
  
        " cargo commands
        :com! CargoCheck !cargo check
      '';
    };

    programs.git = {
      enable = true;
      userName = "Kloenk";
      userEmail = "kloenk@kloenk.de";
      extraConfig = {
        core.editor = "${pkgs.vim}/bin/vim";
        color.ui = true;
      };
    };

    programs.fish = {
      enable = true;
      shellInit = ''
        set PAGER less
      '';
      shellAbbrs = {
        admin-YouGen = "ssh admin-yougen";
        cb = "cargo build";
        cr = "cargo run";
        ct = "cargo test";
        exit = " exit";
        gc = "git commit";
        gis = "git status";
        gp = "git push";
        hubble = "mosh hubble";
        atom = "ssh atom";
        ipa = "ip a";
        ipr = "ip r";
        lycus = "ssh lycus";
        pluto = "ssh pluto";
        s = "sudo";
        ssy = "sudo systemctl";
        sy = "systemctl";
        v = "vim";
      };
      shellAliases = {
	      ls = "exa";
	      l = "exa -a";
	      ll = "exa -lgh";
	      la = "exa -lagh";
	      lt = "exa -T";
	      lg = "exa -lagh --git";
      };
    };

    programs.ssh = {
      enable = true;
      forwardAgent = false;
      controlMaster = "auto";
      controlPersist = "15m";
      matchBlocks = {
        hubble = {
          hostname = "kloenk.de";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
        hubble-encrypt = {
          hostname = "51.254.249.187";
          port = 62954;
          user = "root";
          forwardAgent = false;
          identityFile = "/etc/nixos/secrets/id_rsa";
          checkHostIP = false;
          extraOptions = { "UserKnownHostsFile" = "/dev/null"; };
        };
        lycus = {
          hostname = "ll.qc.to";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
        admin-yougen = {
          hostname = "10.66.6.42";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
        admin-yougen-lycus = {
          hostname = "10.66.6.42";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
          proxyJump = "lycus";
        };
        pluto = {
          hostname = "10.0.0.3";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
        pluto-lycus = {
          hostname = "10.0.0.3";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
          proxyJump = "lycus";
        };
        volta = {
          hostname = "10.0.0.4";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
        volta-lycus = {
          hostname = "10.0.0.4";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
          proxyJump = "lycus";
        };
        atom = {
          hostname = "192.168.178.248";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
        atom-wg = {
          hostname = "192.168.42.7";
          port = 62954;
          user = "kloenk";
          forwardAgent = true;
        };
      };
    };

    programs.termite = {
      enable = true;
      cursorBlink = "off";
      backgroundColor = "rgba(0, 0, 0, 0.7)";
      colorsExtra = ''
        color0 = #6c6c6c
        color1 = #e9897c
        color2 = #b6e77d
        color3 = #ecebbe
        color4 = #a9cdeb
        color5 = #ea96eb
        color6 = #c9caec
        color7 = #f2f2f2

        color8 = #747474
        color9 = #f99286
        color10 = #c3f786
        color11 = #fcfbcc
        color12 = #b6defb
        color13 = #fba1fb
        color14 = #d7d9fc
        color15 = #e2e2e2
      '';
    };
  };

  programs.fish.enable = true;
  programs.mtr.enable = true;
  users.users.root.shell = pkgs.fish;
}
