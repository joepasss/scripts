#!/bin/bash

POWER_STATE="$(cat /sys/class/power_supply/AC/online)"

if [ "$POWER_STATE" -eq 1 ]; then
  GOV="performance"
else
  GOV="ondemand"
fi

for CPU in /sys/devices/system/cpu/cpu[0-9]*; do
  echo "$GOV" >"$CPU/cpufreq/scaling_governor"
done
