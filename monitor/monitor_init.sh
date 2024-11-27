#!/bin/bash

if [[ "$UDEV_EXEC" == "1" ]]; then
  export DISPLAY=:0
  export XAUTHORITY=/home/joepasss/.Xauthority
fi

POS_EDP="0x630"
POS_ULTRA="0x0"
POS_DP="3600x0"

EDID_ULTRA="00ffffffffffff001e6d2b7774150300"
EDID_DP="00ffffffffffff0009d1458000000000"

OFF_EDP=false
OFF_ULTRA=false
OFF_DP=false

LID_STATE=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')
if [[ "$LID_STATE" == "open" ]]; then
  OFF_EDP=false
else
  OFF_EDP=true
fi

DISCONNECTED_MONITORS=($(xrandr | grep " disconnected" | awk '{print $1}'))
MONITORS=($(xrandr | grep " connected" | awk '{print $1}'))

get_edid() {
  local monitor="$1"
  xrandr --props | awk -v mon="$monitor" '
    $0 ~ mon {found=1}
    found && /EDID:/ {getline; gsub(/[[:space:]]/, ""); print; exit}
  '
}

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
    EDID=$(get_edid "$monitor")

    if [[ "$EDID" == $EDID_ULTRA ]]; then
      if $OFF_ULTRA; then
        xrandr \
          --output "$monitor" \
          --off
      else
        xrandr \
          --output "$monitor" \
          --scale 2 \
          --pos "$POS_ULTRA"
      fi
    fi

    if [[ "$EDID" == $EDID_DP ]]; then
      if $OFF_DP; then
        xrandr \
          --output "$monitor" \
          --off
      else
        xrandr \
          --output "$monitor" \
          --scale 2 \
          --pos "$POS_DP"
      fi
    fi
  fi
done

# wallpaper
/home/joepasss/scripts/wallpaper.sh
