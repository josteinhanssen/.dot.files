#!/bin/bash

# Get current layout
current=$(hyprctl getoption input:kb_layout -j | jq -r '.str')

# Toggle layout
if [[ "$current" == *"us"* ]]; then
    hyprctl keyword input:kb_layout "no"
    notify-send "Keyboard" "Norwegian layout" -t 1000
else
    hyprctl keyword input:kb_layout "us"
    notify-send "Keyboard" "US layout" -t 1000
fi
