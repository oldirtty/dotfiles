#!/usr/bin/env bash
# Colloid folder icons — dynamic folder color for Noctalia.
# Colloid draws every folder with one color (#60c0f0 by default) shaded with
# black/white overlays, so recoloring is a single color swap in places/scalable,
# the same swap Colloid's install.sh does for -t / -s.
#
# The current color is read from folder.svg, so any installed Colloid color
# (install.sh -t / -s) or a previous run is recolored in place. If Colloid is
# only installed system-wide it is copied once to $XDG_DATA_HOME/icons under the
# same name; the system copy is never touched. Re-run ./install.sh to reset.
set -euo pipefail

COLOR_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/templates/colloid/colors-final"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
THEME=Colloid # Colloid, Colloid-Dark, Colloid-Light or a variant such as Colloid-Nord-Dark

msg() { printf 'colloid: %s\n' "$*" >&2; }

[[ -f "$COLOR_FILE" ]] || exit 0
read -r NEW <"$COLOR_FILE" || true
NEW="${NEW//[# ]/}"
[[ "$NEW" =~ ^[0-9a-fA-F]{6}$ ]] || exit 0
NEW="${NEW,,}"

# The icons' own neutral colors (overlays, text) must never be used for the
# folder, or the next run would recolor them too.
case "$NEW" in 000000) NEW=010101 ;; 333333) NEW=343434 ;; ffffff) NEW=fefefe ;; esac

find_user_dir() {
  local d
  for d in "$DATA_HOME/icons/$1" "$HOME/.icons/$1"; do
    [[ -f "$d/index.theme" ]] && { printf '%s' "$d"; return 0; }
  done
  return 1
}

find_system_dir() {
  local IFS=: d
  for d in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share} /usr/local/share /usr/share; do
    [[ -f "$d/icons/$1/index.theme" ]] && { printf '%s' "$d/icons/$1"; return 0; }
  done
  return 1
}

if ! dir="$(find_user_dir "$THEME")"; then
  sys="$(find_system_dir "$THEME")" || { msg "$THEME icon theme is not installed"; exit 1; }
  dir="$DATA_HOME/icons/$THEME"
  mkdir -p "$DATA_HOME/icons"
  # -L: Colloid-Dark/Light link into each other, so the copy must be self-contained.
  # Colloid ships a few dangling links (e.g. kerry.svg), so cp exits non-zero.
  cp -aL --reflink=auto "$sys" "$dir" 2>/dev/null || true
fi
scalable="$dir/places/scalable"
[[ -w "$scalable" ]] || { msg "$scalable is not writable"; exit 1; }

# Current folder color, as install.sh wrote it (.ColorScheme-Highlight in folder.svg).
OLD="$(grep -A1 'ColorScheme-Highlight {' "$scalable/folder.svg" | grep -oiE '#[0-9a-fA-F]{6}' | head -n1 || true)"
OLD="${OLD#\#}"
[[ -n "$OLD" ]] || { msg "cannot read the folder color from $scalable/folder.svg"; exit 1; }
OLD="${OLD,,}"
[[ "$OLD" != "$NEW" ]] || exit 0

for f in "$scalable"/*.svg; do
  [[ -f "$f" && ! -L "$f" ]] || continue
  grep -qi "#$OLD" "$f" && sed -i "s/#$OLD/#$NEW/gI" "$f"
done

if command -v gtk-update-icon-cache >/dev/null; then
  gtk-update-icon-cache -f -q "$dir" 2>/dev/null || true
fi
