#!/bin/bash

CURRENT_OUTPUT=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true and .visible==true).output')
OTHER_OUTPUT=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==false and .visible==true).output')

i3-msg move workspace to output $OTHER_OUTPUT
