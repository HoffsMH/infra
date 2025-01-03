{ config, pkgs, ...}:
{
  config = {
    # Configure keymap in X11
    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };


    # keyboard
    hardware.keyboard.qmk.enable = true;
    hardware.uinput.enable = true;
    users.groups = {
      uinput = {};
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      openFirewall = true;
      nssmdns4 = true;
    };


    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth
    hardware.bluetooth = {
      powerOnBoot = true;
      enable = true;
      settings = {
        General = {
          FastConnectable = true;
          Experimental = true;
        };

        Policy = {
          AutoEnable = true;
        };

      };
    };
  };
}

