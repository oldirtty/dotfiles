# keybinds.zsh
bindkey -e

bindkey '^F' fzf-file-widget
bindkey '^C' send-break
bindkey '^E' edit-command-line
bindkey '^H' backward-kill-word
bindkey '^W' kill-region

# numeric keypad
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"
