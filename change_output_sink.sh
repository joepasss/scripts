#!/bin/bash

selected=$(pactl list short sinks | while read -r _ name _; do
  label="$name"
  lower_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')

  if [[ "$lower_name" == *usb* ]]; then
    label="🎚️ USB DAC ($name)"
  elif [[ "$lower_name" == *bluez* ]]; then
    label="🎧 Bluetooth ($name)"
  elif [[ "$lower_name" == *hdmi* ]]; then
    label="📺 HDMI ($name)"
  elif [[ "$lower_name" == *pci* ]]; then
    label="📺 PCI ($name)"
  fi

  echo "$label|$name"
done | rofi -dmenu -p "Select Sink" | cut -d '|' -f2)

if [[ -n "$selected" ]]; then
  pactl set-default-sink "$selected"

  for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$selected"
  done

  notify-send -t 1000 "🔈 Switched to: $selected"
fi
