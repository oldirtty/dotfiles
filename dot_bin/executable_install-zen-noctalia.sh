#!/usr/bin/env bash
# Installs fx-autoconfig + noctalia-bridge.uc.js into Zen Browser.
# Auto-detects the profile and the Zen installation — no editing required.
#
# Usage:
#   ./install.sh                 # auto-detect everything
#   ./install.sh /path/to/zen    # force the Zen installation directory
set -euo pipefail

# ── 1. Find the Zen installation directory (where omni.ja lives) ───────────
find_zen_program_dir() {
  if [[ -n "${1:-}" ]]; then
    echo "$1"
    return
  fi

  local bin
  bin="$(command -v zen-browser 2>/dev/null || command -v zen 2>/dev/null || true)"
  if [[ -n "$bin" ]]; then
    bin="$(readlink -f "$bin")"
    local dir
    dir="$(dirname "$bin")"
    if [[ -f "$dir/omni.ja" ]]; then
      echo "$dir"
      return
    fi
  fi

  for candidate in /opt/zen /opt/zen-browser-bin /usr/lib/zen-browser /usr/lib64/zen-browser; do
    if [[ -f "$candidate/omni.ja" ]]; then
      echo "$candidate"
      return
    fi
  done

  echo ""
}

ZEN_PROGRAM_DIR="$(find_zen_program_dir "${1:-}")"
if [[ -z "$ZEN_PROGRAM_DIR" ]]; then
  echo "Could not auto-detect the Zen installation." >&2
  echo "Run: ./install.sh /path/to/zen/folder (the folder containing omni.ja)" >&2
  exit 1
fi
echo "Zen found at: $ZEN_PROGRAM_DIR"

# ── 2. Find the Zen profile via profiles.ini ────────────────────────────────
find_zen_profile_dir() {
  local candidates=(
    "$HOME/.config/zen"
    "$HOME/.zen"
    "$HOME/.var/app/app.zen_browser.zen/.zen"
  )

  for base in "${candidates[@]}"; do
    local ini="$base/profiles.ini"
    if [[ -f "$ini" ]]; then
      local rel
      rel="$(awk -F= '
        /^\[Profile/ { inprof=1; path=""; def=0 }
        inprof && /^Path=/ { path=$2 }
        inprof && /^Default=1/ { def=1 }
        inprof && /^\[/ && !/^\[Profile/ { inprof=0 }
        def && path { print path; exit }
      ' "$ini")"

      if [[ -z "$rel" ]]; then
        rel="$(awk -F= '/^Path=/{print $2; exit}' "$ini")"
      fi

      if [[ -n "$rel" ]]; then
        echo "$base/$rel"
        return
      fi
    fi
  done
  echo ""
}

PROFILE_DIR="$(find_zen_profile_dir)"
if [[ -z "$PROFILE_DIR" || ! -d "$PROFILE_DIR" ]]; then
  echo "Could not auto-detect the Zen profile." >&2
  echo "Check ~/.config/zen/profiles.ini or set the path manually by editing this script." >&2
  exit 1
fi
echo "Profile found at: $PROFILE_DIR"

# Determine if sudo is needed for Zen program dir
SUDO_CMD=""
if [[ ! -w "$ZEN_PROGRAM_DIR" ]]; then
  SUDO_CMD="sudo"
  echo "Elevated privileges required to write to $ZEN_PROGRAM_DIR. Requesting sudo..."
fi

# ── 3. fx-autoconfig: "program" half ────────────────────────────────────────
if [[ ! -f "$ZEN_PROGRAM_DIR/config.js" ]]; then
  $SUDO_CMD curl -fsSL "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js" \
    -o "$ZEN_PROGRAM_DIR/config.js"
fi

$SUDO_CMD mkdir -p "$ZEN_PROGRAM_DIR/defaults/pref"
$SUDO_CMD bash -c "cat > '$ZEN_PROGRAM_DIR/defaults/pref/config-prefs.js' <<'EOF'
pref(\"general.config.filename\", \"config.js\");
pref(\"general.config.obscure_value\", 0);
pref(\"general.config.sandbox_enabled\", false);
EOF"

# ── 4. fx-autoconfig: "profile" half (chrome/utils) — only if missing ──────
if [[ ! -f "$PROFILE_DIR/chrome/utils/chrome.manifest" ]]; then
  curl -fsSL "https://github.com/MrOtherGuy/fx-autoconfig/archive/refs/heads/master.tar.gz" \
    -o /tmp/fx-autoconfig.tar.gz
  rm -rf /tmp/fx-autoconfig-extract
  mkdir -p /tmp/fx-autoconfig-extract
  tar -xzf /tmp/fx-autoconfig.tar.gz -C /tmp/fx-autoconfig-extract --strip-components=1

  mkdir -p "$PROFILE_DIR/chrome"
  cp -r /tmp/fx-autoconfig-extract/profile/chrome/utils "$PROFILE_DIR/chrome/"
  echo "fx-autoconfig installed."
else
  echo "fx-autoconfig already installed, keeping it."
fi

# ── 5. Our bridge ────────────────────────────────────────────────────────
mkdir -p "$PROFILE_DIR/chrome/JS"

BRIDGE_FILE="noctalia-bridge.uc.js"
BRIDGE_SRC="$PROFILE_DIR/chrome/JS/$BRIDGE_FILE"

echo ""
echo "Installation Complete."
echo "Fully close Zen and reopen it once."
echo "If this is the first fx-autoconfig install on this profile, also use"
echo "about:support -> 'Clear Startup Cache...'"
