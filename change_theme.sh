#!/usr/bin/env bash
# ============================================================================
# Dotfiles ─ change_theme.sh
# ============================================================================

# ────── Parameter validation ──────
if [[ $# -lt 1 ]]; then
  echo "Error: no theme specified." >&2
  echo "Usage: $0 <theme>" >&2
  exit 1
fi

if [[ $# -gt 1 ]]; then
  echo "Error: too many arguments (expected 1, got $#)." >&2
  echo "Usage: $0 <theme>" >&2
  exit 1
fi

THEME="$1"
DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
SPICETIFY="$HOME/.spicetify/spicetify"
SPICETIFY_CONFIG="$HOME/.config/spicetify/config-xpui.ini"

# ────── Global counters ──────
any_changes=0
spicetify_change=0

# ────── Function to update a file ──────
update_file() {
  local base_dir="$1"
  local file="$2"
  local pattern="$3"
  local template="$4"
  local create_if_missing="$5"

  local filepath="${base_dir}/${file}"

  # Primeiro substitui {theme} no template
  local replacement=$(echo "$template" | sed "s/{theme}/$THEME/g")

  if [[ ! -f "$filepath" ]]; then
    echo ""
    if [[ "$create_if_missing" == "true" ]]; then
      echo "[CREATE] ${file} (in ${base_dir}):"
      echo "  NEW: ${replacement}"
      any_changes=1
      return 0
    else
      echo "[SKIP] File not found: ${file} (in ${base_dir})"
      return 1
    fi
  fi

  # Pega a linha atual
  local current_line=$(grep -E "$pattern" "$filepath" | head -1)

  if [[ -z "$current_line" ]]; then
    echo ""
    echo "[SKIP] Pattern not found in ${file}"
    return 1
  fi

  if [[ "$current_line" == "$replacement" ]]; then
    echo ""
    echo "[NO CHANGE] ${file}"
    return 1
  else
    echo ""
    echo "[CHANGE] ${file}:"
    echo "  OLD: $current_line"
    echo "  NEW: $replacement"
    any_changes=1
    return 0
  fi
}

# ────── Function to apply changes ──────
apply_file() {
  local base_dir="$1"
  local file="$2"
  local pattern="$3"
  local template="$4"
  local create_if_missing="$5"

  local filepath="${base_dir}/${file}"

  # Primeiro substitui {theme} no template
  local replacement=$(echo "$template" | sed "s/{theme}/$THEME/g")

  if [[ ! -f "$filepath" ]]; then
    if [[ "$create_if_missing" == "true" ]]; then
      mkdir -p "$(dirname "$filepath")"
      printf '%s\n' "$replacement" > "$filepath"
      echo "[CREATED] ${file}"
    fi
    return
  fi

  # Substitui a linha que começa com o pattern
  sed -i "/$pattern/c\\$replacement" "$filepath"
  echo "[DONE] ${file}"
}

# ────── Define all managed files ──────
declare -a FILE_CONFIGS=(
  "DOT|ghostty/.config/ghostty/theme.ghostty|^theme =|theme = dark:{theme} Dark, light:{theme} Light|true"
  "DOT|neovim/.config/nvim/lua/config/colorscheme.lua|^return|return '{theme}'|true"
  "DOT|mpv/.config/mpv/script-opts/colorscheme.conf|^colorscheme=|colorscheme={theme}|true"
  "DOT|zen/.config/zen/profile.default/chrome/current_theme.css|@import url|@import url('./themes/{theme}.css');|true"
  "HOME|.zshenv|^export OMP_PALETTE=|export OMP_PALETTE={theme}|true"
)

# ────── Helper to resolve base_dir ──────
resolve_base_dir() {
  local base_dir="$1"
  if [[ "$base_dir" == "DOT" ]]; then
    echo "$DOT"
  elif [[ "$base_dir" == "HOME" ]]; then
    echo "$HOME_DIR"
  else
    echo "$base_dir"
  fi
}

# ────── Preview changes ──────
echo "─────────────────────────────────────────────"
echo " Theme migration preview: '${THEME}'"
echo "─────────────────────────────────────────────"

for config in "${FILE_CONFIGS[@]}"; do
  IFS='|' read -r base_dir file pattern template create <<< "$config"
  base_path=$(resolve_base_dir "$base_dir")
  update_file "$base_path" "$file" "$pattern" "$template" "$create"
done

# ────── Spicetify preview ──────
if [[ -f "$SPICETIFY_CONFIG" ]]; then
  current_scheme=$(grep -E "^color_scheme" "$SPICETIFY_CONFIG" | sed 's/.*= *//')

  if [[ "$current_scheme" == "$THEME" ]]; then
    echo ""
    echo "[NO CHANGE] spicetify (color_scheme already '${THEME}')"
  else
    echo ""
    echo "[CHANGE] spicetify:"
    echo "  OLD: color_scheme = ${current_scheme}"
    echo "  NEW: color_scheme = ${THEME}"
    any_changes=1
    spicetify_change=1
  fi
else
  echo ""
  echo "[SKIP] spicetify config not found"
fi

# ────── Check if any changes ──────
if [[ $any_changes -eq 0 ]]; then
  echo ""
  echo "No changes to apply. '${THEME}' is already the active theme."
  exit 0
fi

# ────── Confirmation ──────
echo ""
echo "─────────────────────────────────────────────"
read -rp "Apply changes? [y to confirm]: " answer

if [[ ! "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  echo ""
  echo "Aborted. No files were modified."
  exit 0
fi

# ────── Apply changes ──────
echo ""
for config in "${FILE_CONFIGS[@]}"; do
  IFS='|' read -r base_dir file pattern template create <<< "$config"
  base_path=$(resolve_base_dir "$base_dir")
  apply_file "$base_path" "$file" "$pattern" "$template" "$create"
done

# ────── Apply spicetify changes ──────
if [[ "$spicetify_change" -eq 1 ]]; then
  echo "[DONE] spicetify"
  "$SPICETIFY" config color_scheme "${THEME}"
fi

echo ""
echo "Theme '${THEME}' applied successfully."
