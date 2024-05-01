# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
let
  userName = "hoffs";
in 
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/main-user.nix
      ../../modules/xremap.nix
      inputs.home-manager.nixosModules.default
      inputs.xremap-flake.nixosModules.default
    ];

  xremap.withHypr = true;

  services = {
    syncthing = {
      enable = true;
      user = "${userName}";
      dataDir = "/home/${userName}/personal";
      configDir = "/home/${userName}/.config/syncthing";
      # overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      # overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "pixel" = { id = "CYNFWDD-VM6L4E3-PWXXSU3-Q57ABXS-LRNPX24-S4GYGMC-66RSISQ-DN2KWAT"; };
          "old-laptop" = { id = "RB7GILS-Y2WUKW4-PSZGYFS-XVXTJGV-FGMUE4J-M5JFN5R-2V2F4GP-FZQDVAO"; };
        };
        folders = {
          ".password-store" = {
            path = "/home/hoffs/personal/.password-store";
            devices = [ "old-laptop" ];
          };

          "00-cap-md" = {
            path = "/home/hoffs/personal/00-cap-md";
            devices = [ "old-laptop" ];
          };
          "01-cap-storage" = {
            path = "/home/hoffs/personal/01-cap-storage";
            devices = [ "old-laptop" ];
          };
          "02-cap-storage" = {
            path = "/home/hoffs/personal/02-cap-storage";
            devices = [ "old-laptop" ];
          };

          "reference" = {
            path = "/home/hoffs/personal/reference";
            devices = [ "old-laptop" ];
          };
        };
      };
    };
  };

  hardware.uinput.enable = true;

  users.groups = {
    uinput = {};
  };

  hardware.keyboard.qmk.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 
  networking.hostName = "danube"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  services.mullvad-vpn.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.xserver.desktopManager.gnome.enable = true;

  # uncomment these 2 lines if you want linux terminal login
  # services.xserver.autorun = false;
  # services.xserver.displayManager.startx.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;

  services.udev.packages = with pkgs; [ 
    yubikey-personalization 
    yubikey-manager
  ];
  services.pcscd.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  environment.shells = with pkgs; [ bash zsh ];
  system.activationScripts.bashLink = {
    text = ''
      ln -sf ${pkgs.bash}/bin/bash /bin/bash || true
    '';
    deps = [];
  };

  system.activationScripts.zshLink = {
    text = ''
      ln -sf ${pkgs.zsh}/bin/zsh /bin/zsh || true
    '';
    deps = [];
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  virtualisation.docker.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.

  main-user.enable = true;
  main-user.userName = userName;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "${userName}" = import ./home.nix { inherit inputs userName pkgs; };
    };
  };

  security.sudo = {
    wheelNeedsPassword = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  inherit (builtins.trace "myVariable value is:" inputs);

  environment.systemPackages = with pkgs; [
    firefox
    git-branchless
    slack
    atuin
    docker
    docker-compose
    google-cloud-sdk
    delta
    direnv
    lazygit
    starship
    wl-clipboard
    xclip
    # inputs.nixpkgs-stable.wl-clipboard
    zoxide
    brave
    google-chrome
    gnupg
    neovim
    git
    yubikey-personalization
    yubikey-manager
    fzf
    pinentry
    # pinentry-gnome
    pulsemixer
    ripgrep
    gcc
    gnumake
    kitty
    unzip
    lua
    gopass
    tmux
    wtype
    gfold
    syncthing
    samba
    yt-dlp
    htop

    fd
    bat
    eza
    mpv
    libnotify
    duf
    du-dust
    dogdns
    input-remapper
    pfetch
    btop
    zsh-autopair
    zsh-fast-syntax-highlighting
    manix
    pcmanfm
    discord
    pika-backup
    mako
    qmk
    p7zip
    lf
    timer
    dunst
    swww
    rofi
    wofi
    kooha
    zoom-us
    acpi
    ueberzugpp 

    # keyboard events
    wev
    xorg.xev
    sqlite
    yt-dlp 
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    fira
  ];

  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [ "Fira Sans" ];
      monospace = [ "BlexMono" ];
    };
  };

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    export SHELL=$(which zsh)
    export NIXPKGS_ALLOW_INSECURE=1
    export CAP_FILE="$HOME/personal/00-cap-md/cap.md"
    export CAP_DIR="$HOME/personal/00-cap-md/"
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.ssh.startAgent = false;

  programs.gnupg.agent = { 
     enable = true;
     enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  system.stateVersion = "23.11"; # Did you read the comment?

}
