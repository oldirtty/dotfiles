#!/usr/bin/env bash

bat_dir=""
for d in /sys/class/power_supply/BAT*; do
  if [ -r "$d/capacity" ]; then
    bat_dir="$d"
    break
  fi
done
[ -n "$bat_dir" ] || exit 0

capacity="$(<"$bat_dir/capacity")"
status=""
[ -r "$bat_dir/status" ] && status="$(<"$bat_dir/status")"

case "$status" in
  Charging)
    icon="󰂄"
    ;;
  Full|"Not charging")
    icon="󰚥"
    ;;
  *)
    if [ "$capacity" -ge 90 ]; then
      icon="󰁹"
    elif [ "$capacity" -ge 80 ]; then
      icon="󰂂"
    elif [ "$capacity" -ge 70 ]; then
      icon="󰂁"
    elif [ "$capacity" -ge 60 ]; then
      icon="󰂀"
    elif [ "$capacity" -ge 50 ]; then
      icon="󰁿"
    elif [ "$capacity" -ge 40 ]; then
      icon="󰁾"
    elif [ "$capacity" -ge 30 ]; then
      icon="󰁽"
    elif [ "$capacity" -ge 20 ]; then
      icon="󰁼"
    elif [ "$capacity" -ge 10 ]; then
      icon="󰁻"
    else
      icon="󰁺"
    fi
    ;;
esac

printf ' %s %s%% ' "$icon" "$capacity"
