{ lib, config, pkgs, inputs, ...}:
{

  options = {
    xremap.withGnome = lib.mkEnableOption "with gnome";
    xremap.withHypr = lib.mkEnableOption "with hypr";
    xremap.userName = lib.mkOption {
      default = "hoffs";
      description = "user name";
    };
  };

  config = {
    services.xremap = {
      withGnome = config.xremap.withGnome;
      withHypr = config.xremap.withHypr;
      watch = true;
      serviceMode = "system";
      userName = "${config.xremap.userName}";
      yamlConfig = ''
        virtual_modifiers:
          - CapsLock
        modmap:
          - name: main remaps;
            remap:
              leftalt:
                held: leftctrl
                alone: esc
                alone_timeout_millis: 150
              leftctrl: leftalt
              CapsLock:
                held: CapsLock
                alone: esc
                alone_timeout_millis: 150
              rightalt: Super_R
        keymap:
          - name: main
            remap:
              CapsLock-j: down
              CapsLock-k: up
              CapsLock-h: left
              CapsLock-l: right
      '';
    };
  };
}

