#!/bin/bash

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
is_connected=$(cat /sys/class/power_supply/AC/online)

if [[ $lid_state == 'closed' ]]; then
  if [[ "$is_connected" == "1" ]]; then
    swaymsg output eDP-1 disable
  else
    sudo pm-suspend
  fi
else
  swaymsg output eDP-1 enable
  brightnessctl set 100%
fi
