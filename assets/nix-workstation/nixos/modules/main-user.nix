{ lib, config, pkgs, ...}:
{
  options = {
    main-user.enable = lib.mkEnableOption "enable user module";
    main-user.userName = lib.mkOption {
      default = "hoffs";
      description = "user name";
    };
  };

  config = lib.mkIf config.main-user.enable {
    users.users."${config.main-user.userName}" = {
      isNormalUser = true;
      description = "main user";
      initialPassword = "123";
      extraGroups = [ "networkmanager" "wheel"  "input" "uinput" "docker" ];
      shell = pkgs.zsh;
    };

    environment.variables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      XDG_CONFIG_HOME = "/home/${config.main-user.userName}/.config";
      BROWSER = "firefox";
      READER = "zathura";
      HISTSIZE = "1000";
      SAVEHIST = "1000";
      CAP_FILE="/home/${config.main-user.userName}/personal/00-cap-md/cap.md";

      CAP_DIR="/home/${config.main-user.userName}/personal/00-cap-md/";

      XDG_DESKTOP_DIR="/home/${config.main-user.userName}/Personal";
      XDG_DOWNLOAD_DIR="/home/${config.main-user.userName}/personal/01-cap-storage";
      XDG_TEMPLATES_DIR="/home/${config.main-user.userName}/Templates";
      XDG_PUBLICSHARE_DIR="/home/${config.main-user.userName}/";
      XDG_DOCUMENTS_DIR="/home/${config.main-user.userName}/personal/";
      XDG_MUSIC_DIR="/home/${config.main-user.userName}/personal/media/audio/capture/";
      XDG_PICTURES_DIR="/home/${config.main-user.userName}/personal/media/image/capture/";
      XDG_VIDEOS_DIR="/home/${config.main-user.userName}/personal/media/video/capture/";
      PATH = [
        "/home/${config.main-user.userName}/bin"
        "/home/${config.main-user.userName}/go/bin"
      ];
    };

    system.userActivationScripts.clone-go-utils.text = ''
      targetDir="/home/hoffs/code/util/go-utils"
      if [ ! -d "$targetDir" ]; then
        mkdir -p "$(dirname "$targetDir")"
        ${pkgs.git}/bin/git clone https://github.com/HoffsMH/go-utils.git "$targetDir"
      fi
    '';
  };
}
