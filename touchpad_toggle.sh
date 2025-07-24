#!/bin/bash

DEVICE_NAME="SYNA8018:00 06CB:CE67 Touchpad"
DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME")
STATE=$(xinput list-props "$DEVICE_ID" | grep "Device Enabled" | awk '{print $NF}')

if [ "$STATE" -eq 1 ]; then
  xinput disable "$DEVICE_ID"
else
  xinput enable "$DEVICE_ID"
fi
