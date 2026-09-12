#!/usr/bin/env bash

pkill -x noctalia
sleep 1

LOCAL="$HOME/.local/bin/noctalia"
GLOBAL="$(which noctalia)"

if [ -f "$LOCAL" ]; then
  echo "Running $LOCAL -d"
  "$LOCAL" -d
elif [ -f "$GLOBAL" ]; then
  echo "Running $GLOBAL -d"
  "$GLOBAL" -d
else
  echo "Noctalia not found!"
fi
