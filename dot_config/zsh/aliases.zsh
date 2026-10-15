# aliases.zsh
alias cd='z'
alias lsa='ls -a'
alias la='ls -la'
alias eza='eza --icons --group-directories-first'
alias tree='eza --tree --icons --git-ignore'
alias open='xdg-open'

alias vim='nvim'
alias vidir='VISUAL="hx" vidir'
alias cm="chezmoi"
alias lzg="lazygit"
alias ff='fastfetch'
alias sysfetch='fastfetch -c neofetch.jsonc --logo-type none'

# Global aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
alias -g C='| wl-copy'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
