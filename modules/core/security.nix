{ ... }:
{
  security.rtkit.enable = true;
  security.sudo.enable = true;
  security.pam.services.swaylock = { };
  security.pam.services.hyprlock = { };
  security.pam.services = {
    gnome-keyring = {
      startAuthentication = true;
      acceptSession = true;
      plainSession = true;
    };
  };
}
