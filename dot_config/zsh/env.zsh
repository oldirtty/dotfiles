# env.zsh
typeset -U path PATH
export EDITOR=hx
export VISUAL="$EDITOR"

export GNOME_KEYRING_CONTROL="$XDG_RUNTIME_DIR/keyring"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

# Paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"

NOCTALIA_ACCENT=$(cat ~/.cache/noctalia/accent.hex 2>/dev/null || echo "white")
