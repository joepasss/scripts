#!/bin/bash

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)

if [[ $lid_state == 'closed' ]]; then
  swaymsg output eDP-1 disable
else
  swaymsg output eDP-1 enable
fi

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
