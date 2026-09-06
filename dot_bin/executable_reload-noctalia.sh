#!/bin/bash

pkill -x noctalia
sleep 1

LOCAL="$HOME/.local/bin/noctalia"
GLOBAL="/usr/bin/noctalia"

if [ -f "$LOCAL" ]; then
  echo "Running $LOCAL -d"
  "$LOCAL" -d
elif [ -f "$GLOBAL" ]; then
  echo "Running $GLOBAL -d"
  "$GLOBAL" -d
else
  echo "Noctalia not found!"
fi
