#!/bin/bash

CONNECTED_MONITORS=$(xrandr --query | grep " connected" | wc -l)

if [ "$CONNECTED_MONITORS" -gt 1 ]; then
  elogind-inhibit --what=sleep --mode=block --why="Monitor connected"
else
  elogind-inhibit --mode=off
fi
