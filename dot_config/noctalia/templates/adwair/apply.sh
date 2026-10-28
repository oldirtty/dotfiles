#!/usr/bin/env bash
# Adwair folder icons — dynamic folder color for Noctalia.
# Recolors the generated folder icons in places/scalable the same way Adwair's
# generator (make/generator/colors.py) does: the folder uses a "main" and a
# "light" color plus four tints mixed with white, and the glyph on top uses
# main. Here main/light come from the Noctalia theme and the glyph gets
# GLYPH_CONTRAST against the folder so every hue looks alike.
#
# The current colors are read from folder.svg, so any installed Adwair color
# (install.sh -c) or a previous run is recolored in place. If Adwair is only
# installed system-wide it is copied once to $XDG_DATA_HOME/icons under the
# same name; the system copy is never touched. Re-run ./install.sh to reset.
set -euo pipefail

COLOR_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/templates/adwair/colors-final"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
THEME=Adwair
GLYPH_CONTRAST=1.3 # contrast ratio between the glyph and the folder (higher = stronger glyph)

msg() { printf 'adwair-icons: %s\n' "$*" >&2; }

[[ -f "$COLOR_FILE" ]] || exit 0
mapfile -t lines <"$COLOR_FILE"
LIGHT="${lines[0]//[# ]/}" MAIN="${lines[1]//[# ]/}"
for c in "$LIGHT" "$MAIN"; do
  [[ "$c" =~ ^[0-9a-fA-F]{6}$ ]] || exit 0
done
LIGHT="${LIGHT,,}" MAIN="${MAIN,,}"

# The icons' own neutral colors (shadow, paper) must never be used for the folder,
# or the next run would recolor them too.
nudge() {
  case "$1" in 000000) echo 010101 ;; f2f2f2) echo f1f1f1 ;; ffffff) echo fefefe ;; *) echo "$1" ;; esac
}
LIGHT="$(nudge "$LIGHT")" MAIN="$(nudge "$MAIN")"

# Same hue as the folder, darker (or lighter when it is too dark to go darker)
# until the WCAG contrast ratio against it is GLYPH_CONTRAST. Works in linear light.
glyph_color() {
  awk -v hex="$1" -v r="$GLYPH_CONTRAST" '
    function lin(h, i,  v) {
      v = index("0123456789abcdef", substr(hex, i, 1)) - 1
      v = (v * 16 + index("0123456789abcdef", substr(hex, i + 1, 1)) - 1) / 255
      return (v <= 0.04045) ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4
    }
    function enc(c) {
      if (c < 0) c = 0; if (c > 1) c = 1
      c = (c <= 0.0031308) ? c * 12.92 : 1.055 * c ^ (1 / 2.4) - 0.055
      return sprintf("%02x", int(c * 255 + 0.5))
    }
    BEGIN {
      c[0] = lin(hex, 1); c[1] = lin(hex, 3); c[2] = lin(hex, 5)
      y = 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
      yd = (y + 0.05) / r - 0.05
      if (yd >= 0 && y > 0) {
        for (i = 0; i < 3; i++) c[i] *= yd / y
      } else {
        t = (r * (y + 0.05) - 0.05 - y) / (1 - y)
        for (i = 0; i < 3; i++) c[i] += t * (1 - c[i])
      }
      printf "%s%s%s", enc(c[0]), enc(c[1]), enc(c[2])
    }'
}
GLYPH="$(glyph_color "$LIGHT")"

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

# Rewrites one generated icon: every color of the folder body (main, light and
# their white mixes, exactly as colors.py computes them) goes from old to new,
# and every color after the glyph group starts becomes the glyph color.
recolor() { # <old main> <old light> <file>
  awk -v RS='\001' -v om="$1" -v ol="$2" -v nm="$MAIN" -v nl="$LIGHT" -v glyph="$GLYPH" '
    function hexv(h, i) { return index("0123456789abcdef", substr(h, i, 1)) - 1 }
    function byte(h, i) { return hexv(h, i) * 16 + hexv(h, i + 1) }
    function rnd(x,  r, f) { r = int(x); f = x - r; if (f > 0.5 || (f == 0.5 && r % 2)) r++; return r }
    function mix(h, a,  i, s) {
      for (i = 1; i <= 5; i += 2) s = s sprintf("%02x", rnd(byte(h, i) + (255 - byte(h, i)) * a))
      return s
    }
    function paint(s, isglyph,  out, t, h) {
      while (match(s, /#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]/)) {
        t = substr(s, RSTART + 1, 6); h = tolower(t)
        out = out substr(s, 1, RSTART) (isglyph ? glyph : ((h in m) ? m[h] : t))
        s = substr(s, RSTART + RLENGTH)
      }
      return out s
    }
    BEGIN {
      m[om] = nm; m[ol] = nl
      m[mix(om, .165)] = mix(nm, .165)
      m[mix(ol, .15)] = mix(nl, .15); m[mix(ol, .2)] = mix(nl, .2); m[mix(ol, .23)] = mix(nl, .23)
    }
    {
      i = match($0, /<g transform="translate\([^"]*\) scale\(/)
      printf "%s%s", paint(i ? substr($0, 1, i - 1) : $0, 0), i ? paint(substr($0, i), 1) : ""
    }' "$3"
}

if ! dir="$(find_user_dir "$THEME")"; then
  sys="$(find_system_dir "$THEME")" || { msg "$THEME icon theme is not installed"; exit 1; }
  dir="$DATA_HOME/icons/$THEME"
  mkdir -p "$DATA_HOME/icons"
  cp -a --reflink=auto "$sys" "$dir"
fi
scalable="$dir/places/scalable"
[[ -w "$scalable" ]] || { msg "$scalable is not writable"; exit 1; }

# Current folder colors, as colors.py wrote them (.s0 = main, .s4 = light).
css() { sed -n "s/.*\\.$1 { fill: #\\([0-9a-fA-F]\\{6\\}\\).*/\\1/p" "$scalable/folder.svg" | head -n1; }
OLD_MAIN="$(css s0)" OLD_LIGHT="$(css s4)"
[[ -n "$OLD_MAIN" && -n "$OLD_LIGHT" ]] || { msg "cannot read the folder colors from $scalable/folder.svg"; exit 1; }
OLD_MAIN="${OLD_MAIN,,}" OLD_LIGHT="${OLD_LIGHT,,}"

changed=0
for f in "$scalable"/*.svg; do
  [[ -f "$f" && ! -L "$f" ]] || continue
  grep -qi "#$OLD_MAIN" "$f" && grep -qi "#$OLD_LIGHT" "$f" || continue
  tmp="$f.tmp"
  recolor "$OLD_MAIN" "$OLD_LIGHT" "$f" >"$tmp"
  if cmp -s "$tmp" "$f"; then rm -f "$tmp"; else mv -f "$tmp" "$f"; changed=1; fi
done

if ((changed)) && command -v gtk-update-icon-cache >/dev/null; then
  gtk-update-icon-cache -f -q "$dir" 2>/dev/null || true
fi
