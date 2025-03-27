#!/bin/bash

brightness_step=5
notification_timeout=1000

function use_ddcutil {
  if ddcutil detect 2>/dev/null | grep -q "VCP version"; then
    echo 1
  else
    echo 0
  fi
}

ext_monitor=use_ddcutil
lid_state=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')

function set_brightness {
  local value=$1
  if [ $lid_state = 'open' ]; then
    brightnessctl set $value%
  fi

  if $ext_monitor; then
    for disp in $(ddcutil detect | grep "Display" | awk '{print $2}'); do
      ddcutil --display $disp setvcp 10 $value
    done
  fi
}

function get_brightness_eDP {
  local current=$(brightnessctl g)
  local max=$(brightnessctl m)

  echo "$((current * 100 / max))"
}

function get_brightness_ext {
  echo "$(ddcutil getvcp 10 | awk -F 'current value = |,' '{print $2}' | xargs)"
}

function get_brightness {
  if [ $lid_state = 'open' ]; then
    echo $(get_brightness_eDP)
  else
    echo $(get_brightness_ext)
  fi
}

function get_brightness_icon {
  brightness_icon=""
}

function show_brightness_notif {
  brightness=$(get_brightness)

  get_brightness_icon
  notify-send -t $notification_timeout -h string:x-dunst-stack-tag:brightness_notif -h int:value:$brightness "$brightness_icon $brightness%"
}

case $1 in
  up)
    show_brightness_notif
    ;;

  down)
    show_brightness_notif
    ;;

  dim)
    set_brightness 10
    show_brightness_notif
    ;;

  bright)
    set_brightness 100
    show_brightness_notif
    ;;

  test) ;;
esac
