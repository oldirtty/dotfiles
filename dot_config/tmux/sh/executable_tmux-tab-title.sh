#!/usr/bin/env bash

cmd="$1"
path="$2"

if [ -n "$cmd" ] && [ "$cmd" != "zsh" ] && [ "$cmd" != "-zsh" ]; then
  printf '%s' "$cmd"
  exit 0
fi

if [ -n "$path" ] && top=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null); then
  basename "$top"
else
  printf 'zsh'
fi
