{ lib, config, pkgs, inputs, ...}:
{

  options = {
    xremap.withGnome = lib.mkEnableOption "with gnome";
    xremap.withWlroots = lib.mkEnableOption "with Wlroots";
    xremap.userName = lib.mkOption {
      default = "hoffs";
      description = "user name";
    };
  };

  config = {
    services.xremap = {
      debug = true;
      withGnome = config.xremap.withGnome;
      withWlroots = config.xremap.withWlroots;
      watch = true;
      serviceMode = "system";
      userName = "${config.xremap.userName}";
      config = {
        virtual_modifiers = [
          "CapsLock"
        ];
        modmap = [
          {
            name = "main remaps";
            remap = {
              leftalt = {
                held = "leftctrl";
                alone = "esc";
                aloneTimeoutMillis = "150";
              };
              leftctrl = "leftalt";
              CapsLock = {
                held = "CapsLock";
                alone = "esc";
                aloneTimeoutMillis = "150";
              };
              rightalt = "Super_R";
            };
          }
        ];
        keymap = [
          {
            name = "main";
            remap = {
              CapsLock-j = "down";
              CapsLock-k = "up";
              CapsLock-h = "left";
              CapsLock-l = "right";
              VolumeUp = { launch = ["/run/current-system/sw/bin/wpctl" "set-volume" "@DEFAULT_SINK@" "5%+"]; };
              VolumeDown = { launch = ["/run/current-system/sw/bin/wpctl" "set-volume" "@DEFAULT_SINK@" "5%-"]; };

              XREL_Z_AXIS_1 = "BTN_MIDDLE";
              XREL_Z_AXIS_2 = "BTN_MIDDLE";
            };
          }
        ];
      };
    };
  };
}

