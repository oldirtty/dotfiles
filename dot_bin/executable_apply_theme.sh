#!/bin/bash
set -euo pipefail

CHEZMOI_SRC="$HOME/.local/share/chezmoi"
PLACEHOLDER='{{ colors.primary.default.hex }}'
ACCENT_HEX="$(cat "$HOME/.cache/noctalia/accent.hex")"

sed "s/${PLACEHOLDER}/${ACCENT_HEX}/g" \
  "$CHEZMOI_SRC/dot_config/starship.toml" > "$HOME/.config/starship.toml"

sed "s/${PLACEHOLDER}/${ACCENT_HEX}/g" \
  "$CHEZMOI_SRC/dot_config/fastfetch/config.jsonc" > "$HOME/.config/fastfetch/config.jsonc"
