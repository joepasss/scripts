#!/bin/bash

brightness_step=5
notification_timeout=1000

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)

function set_brightness {
  local value=$1
  if [ "$lid_state" = 'open' ]; then
    brightnessctl set "$value"%
  fi
}

function get_brightness {
  local current
  local max

  current="$(brightnessctl g)"
  max="$(brightnessctl m)"

  echo "$((current * 100 / max))"
}

function get_brightness_icon {
  brightness_icon=""
}

function show_brightness_notif {
  brightness=$(get_brightness)

  get_brightness_icon
  notify-send -t $notification_timeout -h string:x-dunst-stack-tag:brightness_notif -h int:value:"$brightness" "$brightness_icon $brightness%"
}

case $1 in
  up)
    current=$(get_brightness)
    new_brightness=$((current + brightness_step))

    if [ "$new_brightness" -gt 100 ]; then
      new_brightness=100
    fi

    set_brightness "$new_brightness"
    show_brightness_notif
    ;;

  down)
    current=$(get_brightness)
    new_brightness=$((current - brightness_step))

    if [ "$new_brightness" -lt $brightness_step ]; then
      new_brightness=$brightness_step
    fi

    set_brightness "$new_brightness"
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
