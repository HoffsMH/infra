{ config, pkgs, inputs, ...}:
{
  config = {
    #desktop environment
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
  };
}

