#!/bin/bash

if [[ "$UDEV_EXEC" == "1" ]]; then
  export DISPLAY=:0
  export XAUTHORITY=/home/joepasss/.Xauthority
fi

#####################################

# POS OPTIONS
#
# LAPTOP + BENQ SPREAD
POS_SPREAD_EDP="5120x630"
POS_SPREAD_DP="0x0"
#
# LAPTOP + BENQ STACK
POS_STACK_EDP="760x2880"
POS_STACK_DP="0x0"

####################################

POS_EDP="$POS_SPREAD_EDP"
POS_DP="$POS_SPREAD_DP"

while [[ $# -gt 0 ]]; do
  case "$1" in
  --spread)
    POS_EDP="$POS_SPREAD_EDP"
    POS_DP="$POS_SPREAD_DP"
    shift
    ;;
  --stack)
    POS_EDP="$POS_STACK_EDP"
    POS_DP="$POS_STACK_DP"
    shift
    ;;
  esac
done

OFF_EDP=false
OFF_DP=false

LID_STATE=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')
if [[ "$LID_STATE" == "open" ]]; then
  OFF_EDP=false
else
  OFF_EDP=true
fi

DISCONNECTED_MONITORS=($(xrandr | grep " disconnected" | awk '{print $1}'))
MONITORS=($(xrandr | grep " connected" | awk '{print $1}'))

for monitor in "${DISCONNECTED_MONITORS[@]}"; do
  xrandr --output "$monitor" --off
done

for monitor in "${MONITORS[@]}"; do
  if [[ "$monitor" == "eDP" ]]; then
    if $OFF_EDP; then
      xrandr \
        --output "$monitor" \
        --off
    else
      xrandr \
        --output "$monitor" \
        --mode 2880x1800 \
        --scale 1.25 \
        --pos "$POS_EDP"
    fi

  elif [[ "$monitor" == DisplayPort* ]]; then
    if $OFF_DP; then
      xrandr \
        --output "$monitor" \
        --off
    else
      xrandr \
        --output "$monitor" \
        --mode 2560x1440 \
        --scale 2 \
				--primary \
        --pos "$POS_DP"
    fi
  fi
done

feh --bg-scale /home/joepasss/wallpaper/wallpaper.jpg
