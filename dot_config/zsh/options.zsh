# options.zsh
setopt interactive_comments
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

HISTSIZE=10000
SAVEHIST=$HISTSIZE
mkdir -p "$HOME/.cache/zsh/"
export HISTFILE="$HOME/.cache/zsh/.zsh_history"

setopt append_history share_history hist_ignore_space hist_ignore_all_dups
