{ config, pkgs, ...}:
{
  config = {
    fonts.fontconfig = {
      defaultFonts = {
        sansSerif = [ "Fira Sans" ];
        monospace = [ "BlexMono" ];
      };
    };
  };
}

