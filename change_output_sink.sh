#!/bin/bash

selected=$(pactl list short sinks | while read -r _ name _; do
  label="$name"
  if echo "$name" | grep -qi "usb"; then
    label="🎚️ USB DAC ($name)"
  elif echo "$name" | grep -qi "bluez"; then
    label="🎧 Bluetooth ($name)"
  elif echo "$name" | grep -qi "hdmi"; then
    label="📺 HDMI ($name)"
  elif echo "$name" | grep -qi "pci"; then
    label="📺 PCI ($name)"
  fi
  echo "$label|$name"
done | fuzzel --dmenu -p "Select Sink" | cut -d '|' -f2)

if [[ -n "$selected" ]]; then
  pactl set-default-sink "$selected"

  for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$selected"
  done

  notify-send -t 1000 "🔈 Switched to: $selected"
fi
