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

ext_monitor=$(use_ddcutil)
lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)

function set_brightness {
  local value=$1
  if [ "$lid_state" = 'open' ]; then
    brightnessctl set "$value"%
  fi

  if [ "$ext_monitor" -eq 1 ]; then
    for disp in $(ddcutil detect | grep "Display" | awk '{print $2}'); do
      model=$(ddcutil --display "$disp" capabilities | grep "Model:" | awk '{print $2}')

      if [[ "$model" == "PD2506Q" ]]; then
        input_src=$(ddcutil --display 2 getvcp 60 | awk -F'sl=0x' '{print $2}' | cut -c1-2)

        if [[ "$input_src" == "13" ]]; then
          ddcutil --display "$disp" setvcp 10 "$value"
        fi
      else
        ddcutil --display "$disp" setvcp 10 "$value"
      fi

    done
  fi
}

function get_brightness_eDP {
  local current
  local max

  current="$(brightnessctl g)"
  max="$(brightnessctl m)"

  echo "$((current * 100 / max))"
}

function get_brightness_ext {
  ddcutil getvcp 10 | awk -F 'current value = |,' '{print $2}' | xargs
}

function get_brightness {
  if [ "$lid_state" = 'open' ]; then
    get_brightness_eDP
  else
    get_brightness_ext
  fi
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
