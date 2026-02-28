args@{ lib, pkgs, inputs, ... }:

let
  system = "x86_64-linux";
in {
  imports = [ # Include the results of the hardware scan.
    (import ./hardware-configuration.nix args)
    inputs.home-manager.nixosModules.default
  ];

  # Binary Cache for haskell.nix
  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];
  nix.settings.substituters = [
    "https://cache.iog.io"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = ["amdgpu.backlight=0" "amdgpu.abmlevel=0"];
  hardware.enableRedistributableFirmware = true;

  services.thermald.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS config
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  security.polkit.enable = true;
  services.upower.enable = true;
  services.fwupd.enable = true;
  services.fprintd.enable = false;

  services.zfs.autoScrub.enable = true;

  networking.hostName = "dggLnixsigma"; # Define your hostname.
  networking.hostId = "e5bf82bb";
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = true;
  services.resolved.enable = true;

  time.timeZone = "America/Los_Angeles";
  services.avahi.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true; # use xkb.options in tty.

  fonts.packages = with pkgs; [
    comic-neue
    nerd-fonts.comic-shanns-mono
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    roboto
    iosevka
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka-term-slab
    nerd-fonts.monoid
    inter
    nerd-fonts.victor-mono
    comfortaa
  ];

  # Zsh
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };
  programs.nix-ld.enable = true;
  programs.light.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure keymap in X11
  services.autorandr.enable = true;
  services.picom = {
    enable = true;
    package = pkgs.picom;
    backend = "glx";
    settings = {
      corner-radius = 12;
      rounded-corners = true;
      rounded-corners-exclude = [
        "class_g = 'Polybar'"
      ];
      inactive-opacity = 0.9;
      active-opacity = 0.98;
      frame-opacity = 1.0;
      inactive-opacity-override = true;
      round-borders = 1;
      blur-background = true;
      blur-method = "dual_kawase";
      blur-strength = 7;
      vsync = true;
    };
  };
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      options = "ctrl:swapcaps";
    };

    videoDrivers = [ "amdgpu" ];

    windowManager = {
      xmonad =
        let colorScheme = import ./features/colorscheme.nix;
        in {
          enable = true;
          enableContribAndExtras = true;
          config = pkgs.writeText "xmonad.hs" ''
            import qualified Data.Map as Map
            import XMonad
            import XMonad.Util.SpawnOnce (spawnOnce)
            import XMonad.Hooks.EwmhDesktops
            import XMonad.Util.EZConfig (additionalKeys)
            import XMonad.Util.Themes
            import XMonad.Layout.DecorationEx
            import XMonad.Layout.DecorationMadness
            import XMonad.Layout.Tabbed
            import XMonad.Layout
            import XMonad.Layout.NoBorders
            import XMonad.Layout.Decoration
            import XMonad.Layout.ResizableTile
            import XMonad.Layout.TwoPane
            import XMonad.Layout.Spacing
            import XMonad.Layout.Gaps
            import XMonad.Hooks.ManageDocks
            import XMonad.StackSet

            myTheme = def {
              activeColor           = "${colorScheme.palette.base06}"
              , inactiveColor       = "${colorScheme.palette.base02}"
              , urgentColor         = "${colorScheme.palette.base06}"
              , activeBorderColor   = "${colorScheme.palette.base01}"
              , inactiveBorderColor = "${colorScheme.palette.base02}"
              , urgentBorderColor   = "${colorScheme.palette.base05}"
              , activeBorderWidth   = 2
              , inactiveBorderWidth = 1
              , urgentBorderWidth   = 2
              , activeTextColor     = "${colorScheme.palette.base00}"
              , inactiveTextColor   = "${colorScheme.palette.base06}"
              , urgentTextColor     = "${colorScheme.palette.base06}"
              , fontName            = "${import ./features/font.nix}"
              , decoWidth           = 0
              , decoHeight          = 0
              , windowTitleAddons   = []
              , windowTitleIcons    = []
            }

            myLayout = avoidStruts $ tiled
              ||| noBorders Full
              ||| noBorders (tabbed shrinkText myTheme)
              ||| floating
              where
                tiled = gaps [(U,10),(D,10),(L,10),(R,10)] $ spacing 8 $ tallDefault shrinkText myTheme
                floating = floatSimple shrinkText myTheme

            myStartupHook :: X ()
            myStartupHook = do
              spawnOnce "${pkgs.feh}/bin/feh --bg-scale ~/Pictures/wallpapers/bruh.jpg"
              spawnOnce "${pkgs.polybar}/bin/polybar main >>/home/dowlandaiello/.config/polybar/logfile 2>&1"

            main = xmonad $ docks $ ewmhFullscreen $ ewmh $ def
                { terminal    = "${pkgs.emacs30}/bin/emacsclient --create-frame -e '(vterm (generate-new-buffer-name \"*vterm*\"))'"
                , modMask     = mod4Mask
                , startupHook = myStartupHook
                , layoutHook = myLayout
                , borderWidth = 1
                , normalBorderColor = "${colorScheme.palette.base02}"
                , focusedBorderColor = "${colorScheme.palette.base04}"
                } `additionalKeys` [
                ((mod4Mask, xK_Return),
                        spawn "${pkgs.emacs30}/bin/emacsclient --create-frame -e '(vterm (generate-new-buffer-name \"*vterm*\"))'")
                , ((controlMask .|. shiftMask, xK_space), spawn "mydmenu_run")
                , ((mod4Mask, xK_e), spawn "${pkgs.emacs30}/bin/emacsclient --create-frame ~/Documents/org/Todo.org")
                , ((mod4Mask, xK_s), spawn "${pkgs.emacs30}/bin/emacsclient --create-frame ~/Documents/org/skills/Skills.org")
                , ((mod4Mask, xK_f), sendMessage $ JumpToLayout "Full")
                , ((mod4Mask, xK_n), windows focusDown)
                , ((mod4Mask, xK_p), windows focusUp)
                , ((mod4Mask .|. shiftMask, xK_n), windows swapDown)
                , ((mod4Mask .|. shiftMask, xK_p), windows swapUp)
              ]
          '';
        };
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust
    '';
  };

  # Enable sound.
  services.pulseaudio.enable = true;
  services.pulseaudio.support32Bit = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.pipewire.enable = false;

  # OpenGL
  hardware.graphics.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dowlandaiello = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" "docker" "podman" "dialout" "video" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.nushell;
    packages = with pkgs; [ ];
  };

  home-manager = {
    users = { "dowlandaiello" = import ./home.nix args; };
  };

  xdg.portal.config = { common = { default = [ "gtk" ]; }; };

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xorg.xbacklight
    zoom
    wget
    emacs
    home-manager
    git
    git-lfs
    firefox
    killall
    neofetch
    ripgrep
    gnumake
    nixfmt-classic
    lsof
    zip
    unzip
    openssl
    pkg-config
    libiconv
    dconf
    xorg.xwd
    pulseaudioFull
    (polybar.override { mpdSupport = true; })
    mesa
    libglvnd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve+" ];
  networking.nat.externalInterface = "enp0s31f6";

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

