# options.zsh
setopt interactive_comments
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
mkdir -p "$HOME/.cache/zsh/"
export HISTFILE="$HOME/.cache/zsh/.zsh_history"

setopt append_history share_history hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups
