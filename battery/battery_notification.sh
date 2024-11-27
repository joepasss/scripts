#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT0"
THRESHOLD=20
INTERVAL=300

while true; do

  BATTERY_CAPACITY=$(cat "$BATTERY_PATH/capacity")
  BATTERY_STATUS=$(cat "$BATTERY_PATH/status")

  if [[ "$BATTERY_STATUS" == "Discharging" && "$BATTERY_CAPACITY" -le "$THRESHOLD" ]]; then
    notify-send "Low Battery" "Battery level is at ${BATTERY_CAPACITY}%" -u critical
  fi

  sleep "$INTERVAL"
done
