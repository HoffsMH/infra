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
      ../../modules/workstation/xremap/xremap.nix
      ../../modules/workstation/packages.nix
      ../../modules/workstation/io.nix
      ../../modules/workstation/auth.nix
      ../../modules/workstation/desktop-environment.nix
      ../../modules/workstation/defaults.nix
      ../../modules/workstation/networking.nix
      ../../modules/workstation/theme.nix
      inputs.home-manager.nixosModules.default
      inputs.xremap-flake.nixosModules.default
    ];

  networking.hostName = "p14s"; # Define your hostname.
  xremap.withWlroots = true;
  main-user.enable = true;
  main-user.userName = userName;

  services = {
    syncthing = {
      enable = true;
      user = "${userName}";
      dataDir = "/home/${userName}/personal";
      configDir = "/home/${userName}/.config/syncthing";
      # overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      settings = {
        devices = {
          "pixel" = { id = "CYNFWDD-VM6L4E3-PWXXSU3-Q57ABXS-LRNPX24-S4GYGMC-66RSISQ-DN2KWAT"; };
          "old-laptop" = { id = "RB7GILS-Y2WUKW4-PSZGYFS-XVXTJGV-FGMUE4J-M5JFN5R-2V2F4GP-FZQDVAO"; };
          "lexi-phone" = { id = "SFC6HWI-V2WDT70-T765LFQ-HGH6UGB-GVHZNSB-QWYRJGR-SL4DJTA-V6APEQW"; };
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
            devices = [ "old-laptop" "pixel" ];
          };
          "02-cap-storage" = {
            path = "/home/hoffs/personal/02-cap-storage";
            devices = [ "old-laptop" ];
          };
          "shares/lexi-matt" = {
            path = "/home/hoffs/personal/shares/lexi-matt";
            devices = [ "old-laptop" "lexi-phone" "pixel" ];
          };
          "reference" = {
            path = "/home/hoffs/personal/reference";
            devices = [ "old-laptop" ];
          };
        };
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 


  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "${userName}" = import ./home.nix { inherit inputs userName pkgs; };
    };
  };


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  system.stateVersion = "24.05"; # Did you read the comment?

}
