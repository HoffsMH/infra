{ config, pkgs, ...}:
{
  config = {
    # administration/auth
    security.sudo = {
      wheelNeedsPassword = false;
    };

    programs.ssh.startAgent = false;
    programs.gnupg.agent = { 
       enable = true;
       enableSSHSupport = true;
    };

    environment.shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';

    services.udev.packages = with pkgs; [ 
      yubikey-personalization 
      yubikey-manager
    ];
    services.pcscd.enable = true;
  };
}

