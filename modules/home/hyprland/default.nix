{ inputs, ... }:
{
  imports = [
    ./hyprland.nix
    ./config.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./variables.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
