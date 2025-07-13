#!/bin/bash

LID_EVENT="/dev/input/event1"

libinput debug-events --device="$LID_EVENT" | while read -r line; do
  if echo "$line" | grep -q "SWITCH_TOGGLE"; then
    ~/scripts/xorg/clamshell.sh
  fi
done
