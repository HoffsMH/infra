{ pkgs, inputs, userName, ... }: {
  # home.packages = [ pkgs.atool pkgs.httpie ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hoffs";
  home.homeDirectory = "/home/hoffs";
  programs.zsh.enable = true;
  programs.zsh = {
    initExtra = ''
      # Include your custom .zshrc configurations here
      # You can also source your existing .zshrc file
      source /home/${userName}/.zshrc.common
    '';
  };

  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    cursorTheme = {
      name = "Nordzy-cursors-white";
      package = pkgs.nordzy-cursor-theme;
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";
}

