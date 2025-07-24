#!/bin/bash
set -e

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
readarray -t displays < <(xrandr | grep " connected" | awk '{print $1}')

# POS
pos_edp="0x0"

if [[ "${#displays[@]}" -eq 1 && "${displays[0]}" == "eDP" ]]; then
  pos_edp="0x0"
else
  pos_edp="480x2160"
fi

# reset
for disp in "${displays[@]}"; do
  xrandr --output "$disp" --off
done

# monitor resolution
for disp in "${displays[@]}"; do
  if [[ "$disp" == "eDP" ]]; then
    xrandr --output "$disp" \
      --scale 1 \
      --mode 2880x1800
  elif [[ "$disp" == "DisplayPort"* ]]; then
    xrandr --output "$disp" \
      --scale 1.5 \
      --mode 2560x1440
  elif [[ "$disp" == "HDMI"* ]]; then
    xrandr --output "$disp" \
      --scale 1.5 \
      --mode 3440x1440
  fi
done

# monitor pos
for disp in "${displays[@]}"; do
  if [[ "$disp" == "eDP" ]]; then
    xrandr --output "$disp" --pos "$pos_edp"
  else
    xrandr --output "$disp" --pos 0x0
  fi
done

# edp brightness set
brightnessctl set 100%

if [[ $lid_state == 'closed' ]]; then
  xrandr --output eDP --off
fi

# wallpaper
exec nitrogen --set-zoom-fill ~/wallpaper/flower-field.jpg --head=0
