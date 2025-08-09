#!/bin/bash
set -e

######## DEPENDENCIES ########

# jq-1.8.1
# brightnessctl
# nitrogen

##############################

### PATH VARS
SCRIPT_PATH=$(dirname "$(realpath "$0")")
MONITOR_INFO_FILE="$SCRIPT_PATH/monitor_info.json"
TEMP_JSON_FILE="$SCRIPT_PATH/temp.json"

### GLOBAL VARS
LID_STATE=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)

### FUNCTIONS
function write_field() {
  local key=$1
  local value=$2

  if [[ ! -f $TEMP_JSON_FILE ]]; then
    touch "$TEMP_JSON_FILE"
    echo "{}" >"$TEMP_JSON_FILE"
  fi

  new_field=$(jq --arg key "$key" \
    --arg value "$value" \
    '. += {$key: $value}' \
    "$TEMP_JSON_FILE")
  echo "$new_field" >"$TEMP_JSON_FILE"
}

function cleanup() {
  if [[ -f $TEMP_JSON_FILE ]]; then
    rm -rf "$TEMP_JSON_FILE"
  fi
}

function write_new_monitor() {
  if [[ ! -f $TEMP_JSON_FILE ]]; then
    echo "ERROR!: no new monitor information!"
    exit 1
  fi

  local new_mon
  local new_json

  new_mon=$(<"$TEMP_JSON_FILE")
  new_json=$(jq --argjson m "$new_mon" '.monitors += [$m]' "$MONITOR_INFO_FILE")

  echo "$new_json" >"$MONITOR_INFO_FILE"
  cleanup
}

readarray -t displays < <(xrandr | grep " connected" | awk '{print $1}')

if [[ ! -f "$MONITOR_INFO_FILE" ]]; then
  touch "$MONITOR_INFO_FILE"
  echo "{\"monitors\":[]}" >"$MONITOR_INFO_FILE"
fi

for disp in "${displays[@]}"; do
  EDID=$(xrandr --verbose | grep -A 30 "$disp" | grep -A 16 EDID | sed "1d" | tr -d '[:space:]')
  MODE=$(xrandr | grep -A 1 "$disp" | sed "1d" | awk '{print $1}')

  registerd=$(jq -r --arg EDID "$EDID" '.monitors[] | select(.EDID==$EDID)' "$MONITOR_INFO_FILE")

  if [[ -z "$registerd" ]]; then
    write_field "NAME" "$disp"
    write_field "MODE" "$MODE"
    write_field "EDID" "$EDID"
    write_field "POS" "0x0"
    write_field "SCALE" "1"

    write_new_monitor
  fi

  scale=$(jq -r --arg EDID "$EDID" \
    '.monitors[] | select(.EDID==$EDID) | .SCALE' "$MONITOR_INFO_FILE")
  mode=$(jq -r --arg EDID "$EDID" \
    '.monitors[] | select(.EDID==$EDID) | .MODE' "$MONITOR_INFO_FILE")
  pos=$(jq -r --arg EDID "$EDID" \
    '.monitors[] | select(.EDID==$EDID) | .POS' "$MONITOR_INFO_FILE")

  if [[ "${#displays[@]}" -eq 1 ]]; then
    xrandr --output "$disp" \
      --scale "$scale" \
      --mode "$mode" \
      --pos 0x0
  else
    xrandr --output "$disp" \
      --scale "$scale" \
      --mode "$mode" \
      --pos "$pos"
  fi
done

if [[ $LID_STATE == 'closed' ]]; then
  xrandr --output eDP --off
else
  brightnessctl set 100%
fi

# wallpaper
exec nitrogen --set-zoom-fill ~/wallpaper/flower-field.jpg --head=0
