{
  config,
  inputs,
  pkgs,
  ...
}:
let
  hyprland-pkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      package = hyprland-pkgs.mesa;
      extraPackages = with pkgs; [
        intel-media-driver
        (vaapiIntel.override { enableHybridCodec = true; })
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    nvidia.modesetting.enable = true;
    nvidia.powerManagement.enable = true;
    nvidia.open = false;
    nvidia.nvidiaSettings = true;
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidia.forceFullCompositionPipeline = true;
  };
  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [
    blueman
  ];
}
