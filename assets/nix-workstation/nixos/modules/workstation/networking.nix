{ config, pkgs, ...}:
{
  config = {
    networking.networkmanager.enable = true;
    networking.wireguard.enable = true;
    services.mullvad-vpn.enable = true;
  };
}

