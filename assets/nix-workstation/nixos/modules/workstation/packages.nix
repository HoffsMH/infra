{ config, pkgs, ...}:
{
  config = {

    virtualisation.docker.enable = true;
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

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
      figlet

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
      swww
      rofi
      wofi
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
      yt-dlp
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
      ctpv
      glow
      vial
      via

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

