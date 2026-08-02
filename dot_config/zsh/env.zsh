# env.zsh
typeset -U path PATH
export EDITOR=helix
export VISUAL=helix

export GNOME_KEYRING_CONTROL="$XDG_RUNTIME_DIR/keyring"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

# Paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
