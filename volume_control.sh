#!/bin/bash

# See README.md for usage instructions
volume_step=5
max_volume=100
notification_timeout=1000
download_album_art=true
show_album_art=true
show_music_in_volume_indicator=true

function get_mute {
  if wpctl get-volume @DEFAULT_SINK@ | grep -q '\[MUTED\]'; then
    echo "MUTED"
  else
    echo "UNMUTED"
  fi
}

function get_volume {
  local vol=$(wpctl get-volume @DEFAULT_SINK@ | grep -oP '\d+\.\d+')
  volume=$(echo "$vol * 100" | bc | awk '{print int($1)}')

  echo $volume
}

function get_volume_icon {
  volume=$(get_volume)
  mute=$(get_mute)

  if [ "$volume" -eq 0 ] || [ "$mute" == "MUTED" ]; then
    volume_icon=""
  elif [ "$volume" -lt 50 ]; then
    volume_icon=" "
  else
    volume_icon=" "
  fi

  echo "$volume_icon"
}

function get_album_art {
  url=$(playerctl -f "{{mpris:artUrl}}" metadata)
  if [[ $url == "file://"* ]]; then
    album_art="${url/file:\/\//}"
  elif [[ $url == "http://"* ]] && [[ $download_album_art == "true" ]]; then
    # Identify filename from URL
    filename="$(echo $url | sed "s/.*\///")"

    # Download file to /tmp if it doesn't exist
    if [ ! -f "/tmp/$filename" ]; then
      wget -O "/tmp/$filename" "$url"
    fi

    album_art="/tmp/$filename"
  elif [[ $url == "https://"* ]] && [[ $download_album_art == "true" ]]; then
    # Identify filename from URL
    filename="$(echo $url | sed "s/.*\///")"

    # Download file to /tmp if it doesn't exist
    if [ ! -f "/tmp/$filename" ]; then
      wget -O "/tmp/$filename" "$url"
    fi

    album_art="/tmp/$filename"
  else
    album_art=""
  fi
}

# Displays a volume notification
function show_volume_notif {
  volume=$(get_mute)
  get_volume_icon

  if [[ $show_music_in_volume_indicator == "true" ]]; then
    current_song=$(playerctl -f "{{title}} - {{artist}}" metadata)

    if [[ $show_album_art == "true" ]]; then
      get_album_art
    fi

    notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume -i "$album_art" "$volume_icon $volume%" "$current_song"
  else
    notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume "$volume_icon $volume%"
  fi
}

# Displays a music notification
function show_music_notif {
  song_title=$(playerctl -f "{{title}}" metadata)
  song_artist=$(playerctl -f "{{artist}}" metadata)
  song_album=$(playerctl -f "{{album}}" metadata)

  if [[ $show_album_art == "true" ]]; then
    get_album_art
  fi

  notify-send -t $notification_timeout -h string:x-dunst-stack-tag:music_notif -i "$album_art" "$song_title" "$song_artist - $song_album"
}

case $1 in
up)
  volume=$(get_volume)

  wpctl set-mute @DEFAULT_SINK@ 0

  if [ $(("$volume" + "$volume_step")) -gt $max_volume ]; then
    wpctl set-volume @DEFAULT_SINK@ "$max_volume"%
  else
    wpctl set-volume @DEFAULT_SINK@ "$volume_step"%+
  fi

  show_volume_notif
  ;;

down)
  wpctl set-volume @DEFAULT_SINK@ "$volume_step"%-

  show_volume_notif
  ;;

mute)
  wpctl set-mute @DEFAULT_SINK@ toggle

  show_volume_notif
  ;;

test)
  get_mute
  ;;

esac
