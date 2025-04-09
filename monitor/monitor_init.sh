#!/bin/bash

function detect_ext_monitor() {
  internal_display="eDP-1"
  external_connected=$(swaymsg -t get_outputs | jq -r ".[] | select(.name != \"$internal_display\") | .name")

  if [ -n "$external_connected" ]; then
    echo 1
  else
    echo 0
  fi
}

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
ext_monitor=$(detect_ext_monitor)

if [[ $lid_state == 'closed' ]]; then
  swaymsg output eDP-1 disable
else
  swaymsg output eDP-1 enable
fi

if [[ "$ext_monitor" == "1" ]]; then
  for disp in $(ddcutil detect | grep "Display" | awk '{print $2}'); do
    model=$(ddcutil --display "$disp" capabilities | grep "Model:" | awk '{print $2}')

    if [[ "$model" == "PD2506Q" ]]; then
      input_src=$(ddcutil --display "$disp" getvcp 60 | awk -F'sl=0x' '{print $2}' | cut -c1-2)
      output=$(swaymsg -t get_outputs | jq -r '.[] | "\(.name): \(.model)"' | grep -i "$model" | awk -F: '{print $1}')

      if [[ "$input_src" != "13" ]]; then
        swaymsg output "$output" disable
      else
        swaymsg output "$output" enable
      fi
    fi
  done
fi
