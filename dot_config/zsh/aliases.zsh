# aliases.zsh
alias cd='z'
alias md='mkdir -p'
alias ls='eza --icons --group-directories-first'
alias lsa='ls -A'
alias l='ls -l'
alias la='lsa -l'
alias tree='eza --tree --icons --git-ignore'
alias open='xdg-open'

alias vim='nvim'
alias vidir='VISUAL="hx" vidir'
alias cm="chezmoi"
alias rg="rg --hidden --glob '!.git/'"
alias ff='fastfetch'
alias sysfetch='fastfetch -c neofetch.jsonc --logo-type none'

# Global aliases
alias -g C='| wl-copy'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
