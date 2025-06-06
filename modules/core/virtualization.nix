{ config, pkgs, username, ... }:

{
  # Add user to libvirtd, qemu, and kvm groups for full access
  users.users.${username}.extraGroups = [ "libvirtd" "kvm" "qemu" ];

  # Install packages needed for virtualization and working virt-manager
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    qemu_kvm         # QEMU with KVM support
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    adwaita-icon-theme
  ];

  # Manage the virtualization services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
        runAsRoot = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.spice-vdagentd.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;
}
