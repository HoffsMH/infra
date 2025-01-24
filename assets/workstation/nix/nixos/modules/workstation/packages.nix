{ config, pkgs, inputs, ...}:
let
  nixpkgsStable = import inputs.nixpkgs-stable { inherit (pkgs) system; };
in
{
  config = {

    virtualisation.docker.enable = true;
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      firefox
      slack
      atuin
      docker
      docker-compose
      google-cloud-sdk
      bitwarden-cli

      # delta
      # inputs.nixpkgs-stable.packages.${pkgs.system}.delta

      nixpkgsStable.delta
      nixpkgsStable.git-branchless
      xcp
      keymapp
      kitty


      direnv
      lazygit
      lazydocker
      starship
      wl-clipboard
      xclip
      zoxide
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
      foot
      chafa
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
      # lf
      timer
      swww
      kooha
      zoom-us
      acpi
      zathura
      bc
      feh
      brightnessctl
      blueman
      grim
      slurp
      swappy
      xdg-desktop-portal-hyprland
      nwg-look
      hyprcursor
      ansible
      axel
      entr
      xh
      tokei
      autoconf
      autorandr
      jq
      xdotool
      poppler_utils
      imagemagick
      file
      glow
      vial
      via
      epub-thumbnailer

      # keyboard events
      wev
      xorg.xev
      sqlite
      gource
    ];

    fonts.packages = with pkgs; [
      nerdfonts
      fira
    ];
    services.cpupower-gui.enable = true;

    programs.zsh.enable = true;
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
  };
}

