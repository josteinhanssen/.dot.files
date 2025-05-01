{
  config,
  lib,
  pkgs,
  ...
}:

let
  audioCheckScript = pkgs.writeShellScript "check-audio-playing" ''
    # Use pw-dump to check for active audio streams by looking at audio levels
    ${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq '.[] | select(.type == "PipeWire:Interface:Node" and .info.state == "running" and .info.params.Props != null and .info.params.Props.channelVolumes != null) | .info.params.Props.channelVolumes[] | select(. > 0.01)' | ${pkgs.gnugrep}/bin/grep -q .
  '';
in
{
  home.packages = [ pkgs.hypridle ];
  services.hypridle = {
    enable = true;

    # Basic configuration
    lockCmd = "hyprlock"; # Command to run when locking
    beforeSleepCmd = "loginctl lock-session"; # Command to run before system sleeps
    afterSleepCmd = ""; # Command to run after system wakes up from sleep

    # Timeout configuration (in seconds)
    timeouts = [
      {
        timeout = 300; # 5 minutes
        command = "hyprlock"; # Lock the screen
      }
      {
        timeout = 600; # 10 minutes
        command = "${pkgs.systemd}/bin/systemctl suspend"; # Suspend the system
      }
    ];

    # Inhibit idle when these conditions are met
    listeners = [
      {
        name = "fullscreen";
        timeout = 30; # Check every 30 seconds
        onCheck = "hyprctl activewindow -j | jq -e '.fullscreen' | grep -q 'true'";
        onTimeout = ""; # Do nothing, effectively inhibiting idle
      }
      {
        name = "audio";
        timeout = 30;
        onCheck = "${audioCheckScript}";
        onTimeout = ""; # Do nothing, effectively inhibiting idle
      }
    ];
  };
}
