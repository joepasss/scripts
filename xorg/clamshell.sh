#!/bin/bash

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
is_connected=$(cat /sys/class/power_supply/AC/online)

if [[ $lid_state == 'closed' ]]; then
  if [[ $is_connected == "1" ]]; then
    xrandr --output eDP --off
  else
    sudo pm-suspend
  fi
else
  /home/joepasss/scripts/xorg/monitor_init.sh

  brightnessctl set 100%
fi

exec nitrogen --set-zoom-fill ~/wallpaper/flower-field.jpg --head=0
