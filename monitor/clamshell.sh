#!/bin/bash

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
is_connected=$(cat /sys/class/power_supply/AC/online)
ext_monitors=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "eDP-1" and .active == true) | .name')

if [[ $lid_state == 'closed' ]]; then
  if [[ "$is_connected" == "1" || -n "$ext_monitors" ]]; then
    swaymsg output eDP-1 disable
  else
    sudo pm-suspend
  fi
else
  swaymsg output eDP-1 enable
fi
