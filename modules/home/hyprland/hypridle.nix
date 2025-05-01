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
    settings = {
      # Basic configuration
      general = {
        lock_cmd = "hyprlock";
      };

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
          on-check = "hyprctl activewindow -j | jq -e '.fullscreen' | grep -q 'true'";
          on-timeout = ""; # Do nothing, effectively inhibiting idle
        }
        {
          name = "audio";
          timeout = 30;
          on-check = "${audioCheckScript}";
          on-timeout = ""; # Do nothing, effectively inhibiting idle
        }
      ];
    };

  };
}
