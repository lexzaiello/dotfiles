args@{ pkgs, lib, ... }:

let
  colorscheme = import ./features/colorscheme.nix;
  system = "x86_64-linux";
  mk_auto_randr_config = (port: ''
    output eDP
    crtc 0
    mode 2560x1600
    pos 0x0
    primary
    rate 165.00
    x-prop-colorspace Default
    x-prop-max_bpc 16
    x-prop-non_desktop 0
    x-prop-scaling_mode None
    x-prop-tearfree auto
    x-prop-underscan off
    x-prop-underscan_hborder 0
    x-prop-underscan_vborder 0
    output DisplayPort-${toString port}
    crtc 1
    mode 2560x1440
    pos 2560x0
    rate 59.95
    x-prop-colorspace Default
    x-prop-max_bpc 8
    x-prop-non_desktop 0
    x-prop-scaling_mode None
    x-prop-tearfree auto
    x-prop-underscan off
    x-prop-underscan_hborder 0
    x-prop-underscan_vborder 0
  '');
  forall_monitors = (prefix: data_with_n:
    lib.map (n: {
      name = "${prefix}${toString n}/config";
      value = {
        text = data_with_n n;
      };
    }) (lib.range 0 10));
  autorandr_configs = builtins.listToAttrs
    (forall_monitors ".config/autorandr/two-monitors"
      (n: mk_auto_randr_config n));
in {
  nixpkgs.config = {
    allowUnfree = true;
  };
  imports = [
    (import ./features/xdg.nix)
    (import ./features/alacritty.nix args)
    (import ./features/gtk.nix args)
    (import ./features/qt.nix args)
    (import ./features/zsh.nix args)
    (import ./features/emacs.nix args)
    (import ./features/git.nix)
    (import ./features/direnv.nix)
    (import ./features/nushell.nix args)
    (import ./features/polybar.nix args)
  ];

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = { color-scheme = "prefer-light"; };
    };
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dowlandaiello";
  home.homeDirectory = "/home/dowlandaiello";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = let
    tex = (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-medium dvisvgm dvipng # for preview and export as html
        wrapfig amsmath ulem hyperref capt-of mathpartir minted upquote
        needspace ec cm;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    });
    my_dmenu = pkgs.writeShellScriptBin "mydmenu_run" ''
      #!/bin/sh
      dmenu_run  -nb "${colorscheme.palette.base00}" -nf "${colorscheme.palette.base01}" -sf "${colorscheme.palette.base00}" -sb "${colorscheme.palette.base01}"
    '';
  in with pkgs; [
    kdePackages.okular
    cachix
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    nerd-fonts.monoid
    dmenu
    my_dmenu
    feh
    gruvbox-gtk-theme
    zsh-syntax-highlighting
    python313Packages.python-lsp-server
    xclip
    black
    python313
    go
    libgcc
    gcc
    cargo
    rustc
    rust-analyzer
    rustfmt
    pavucontrol
    docker-compose
    tor-browser
    protobuf
    discord
    nodePackages.typescript-language-server
    typescript
    kdePackages.kleopatra
    signal-desktop
    obsidian
    chromium
    flameshot
    vale
    elan
    lldb
    gdb
    llvm
    obs-studio
    picom
    ghostscript
    tex
    (rstudioWrapper.override {
      packages = with rPackages; [ Rmpfr readr dplyr tidyverse ];
    })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # ".vale.ini".text = ''
    #   StylesPath = styles
    #
    #   Vocab = Blog
    #
    #   [*.org]
    #   BasedOnStyles = Microsoft
    # '';
    ".config/picom/picom.conf".text = ''
      backend = "glx";
      corner-radius = 10;
      shadow = true;
      shadow-radius = 15;
      blur-method = "dual_kawase";
      blur-strength = 7;
      vsync = true;
    '';
    ".config/direnv/direnv.toml".text = ''
      [global]
      log_filter = "^$"
    '';
  } // autorandr_configs;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dowlandaiello/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "${pkgs.emacs30}/bin/emacsclient";
    SHELL = "zsh";
    GOPATH = "/home/dowlandaiello/go";
    GOBIN = "/home/dowlandaiello/go/bin";
    PATH = "$PATH:/home/dowlandaiello/go/bin";
    GDK_BACKEND = "x11";
    GDK_GL = "gles";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
