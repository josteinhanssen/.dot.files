{
  config,
  lib,
  pkgs,
  ...
}:

let
  audioCheckScript = pkgs.writeShellScript "check-audio-playing" ''
    #!/bin/bash

    # Check if pw-dump and jq are installed
    if ! command -v pw-dump &> /dev/null || ! command -v jq &> /dev/null; then
        echo "Error: pw-dump or jq is not installed."
        exit 1
    fi

    # Get the output of pw-dump and check for nodes with state "running"
    audio_playing=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.state == "running" and .info.props."media.class" == "Stream/Output/Audio") | .info.state')

    # If any node is "running", audio is playing
    if [[ -n "$audio_playing" ]]; then
        echo "Audio is playing."
        exit 0
    else
        echo "No audio is playing."
        exit 1
    fi
  '';
  lockIfNoAudioScript = pkgs.writeShellScript "check-audio-playing" ''
    #!/bin/bash

    # Path to the check-audio script
    CHECK_AUDIO_SCRIPT="${audioCheckScript}"

    # Run the check-audio script
    if "$CHECK_AUDIO_SCRIPT"; then
        echo "Audio is playing, skipping lock."
        exit 0
    else
        echo "No audio, proceeding to lock."
        hyprlock
        exit 0
    fi
  '';
in
{
  home.packages = [ pkgs.hypridle ];
  services.hypridle = {
    enable = true;
    settings = {
      # Basic configuration
      general = {
        lock_cmd = "pidof hyprlock || ${audioCheckScript}";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      # Inhibit idle when these conditions are met
      listener = [
        {
          timeout = 60; # 5 minutes
          on-timeout = "pidof hyprlock || ${audioCheckScript}";
        }
      ];
    };

  };
}
