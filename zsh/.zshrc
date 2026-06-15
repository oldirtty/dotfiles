# ── Aliases ────────────────
alias cd='z'
alias md='mkdir -p'
alias vim='nvim'
alias code='codium'
alias ls='eza --icons --group-directories-first'
alias lsa='ls -A'
alias l='ls -l'
alias la='lsa -l'
alias tree='eza --tree --icons --git-ignore'
alias open='xdg-open'
alias reboot-windows='sudo bootctl set-oneshot windows.conf && sudo reboot'

# Global aliases
alias -g C='| wl-copy'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# ── Environment Variables ────────────────
typeset -U path PATH
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$PATH"
export GNOME_KEYRING_CONTROL="$XDG_RUNTIME_DIR/keyring"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

# ── Zsh options ────────────────
setopt interactive_comments
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# ── History ────────────────
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
export HISTFILE="$HOME/.cache/zsh/.zsh_history"

setopt append_history share_history hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

declare -A ZINIT
ZINIT[ZCOMPDUMP_PATH]="$HOME/.cache/zsh/.zcompdump"

fpath=(~/.cache/zsh/completions $fpath) # add custom completions
# ── Zinit ────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d $ZINIT_HOME/.git ]] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ────────────────
zi snippet OMZL::git.zsh
zi snippet OMZP::git
zi snippet OMZP::sudo
zi snippet OMZP::extract
zi snippet OMZP::colored-man-pages
zi snippet OMZP::command-not-found

# fzf install
zi ice as"program" pick"bin/fzf" atclone"./install --bin" atpull"%atclone"
zi light junegunn/fzf

zi light Aloxaf/fzf-tab
zi light MichaelAquilina/zsh-you-should-use

# Turbo
zi lucid wait for \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf \
        zsh-users/zsh-completions \
    atinit'zicompinit; zicdreplay' \
        zdharma-continuum/fast-syntax-highlighting

# ── Keybindings ────────────────
bindkey -e
zi snippet OMZL::key-bindings.zsh

bindkey '^F' fzf-file-widget # ctrl+f runs fzf file
bindkey '^C' send-break # break cmd exec
bindkey '^E' edit-command-line # edit command line
bindkey '^H' backward-kill-word # ctrl+backspace
bindkey '^W' kill-region # del everything behind

# Numeric keypad
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# ── Shell integrations ────────────────
eval "$(dircolors ~/.config/dircolors)"
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/ohmyposh.toml)"
#eval "$(starship init zsh)"

# ── Plugin config ────────────────
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=()

# fzfs
FZF_PLUGIN="${ZINIT_HOME%/zinit.git}/plugins/junegunn---fzf"
source "${FZF_PLUGIN}/shell/key-bindings.zsh"
source "${FZF_PLUGIN}/shell/completion.zsh"
unset FZF_PLUGIN

# Completions
zstyle ':fzf-tab:*' fzf-flags --bind=right:ignore
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'eza -1 --all --color=always --icons $realpath'

# Fast Syntax Highlighting styles
typeset -A FAST_HIGHLIGHT_STYLES

#[base]
FAST_HIGHLIGHT_STYLES[default]='none'
FAST_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
FAST_HIGHLIGHT_STYLES[commandseparator]='yellow'
FAST_HIGHLIGHT_STYLES[redirection]='fg=yellow'
FAST_HIGHLIGHT_STYLES[here-string-tri]='fg=yellow'
FAST_HIGHLIGHT_STYLES[here-string-text]='fg=yellow'
FAST_HIGHLIGHT_STYLES[here-string-var]='fg=cyan'
FAST_HIGHLIGHT_STYLES[exec-descriptor]='fg=yellow,bold'
FAST_HIGHLIGHT_STYLES[comment]='fg=245'
FAST_HIGHLIGHT_STYLES[correct-subtle]='fg=12'
FAST_HIGHLIGHT_STYLES[incorrect-subtle]='fg=red'
FAST_HIGHLIGHT_STYLES[subtle-separator]='fg=green'
FAST_HIGHLIGHT_STYLES[subtle-bg]='bg=18'
FAST_HIGHLIGHT_STYLES[recursive-base]='none'

#[command-point]
FAST_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
FAST_HIGHLIGHT_STYLES[subcommand]='fg=yellow'
FAST_HIGHLIGHT_STYLES[alias]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[suffix-alias]='fg=green,underline'
FAST_HIGHLIGHT_STYLES[global-alias]='fg=cyan'
FAST_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[function]='fg=yellow,bold'
FAST_HIGHLIGHT_STYLES[command]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[hashed-command]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[single-sq-bracket]='fg=green'
FAST_HIGHLIGHT_STYLES[double-sq-bracket]='fg=green'
FAST_HIGHLIGHT_STYLES[double-paren]='fg=yellow'

#[paths]
FAST_HIGHLIGHT_STYLES[path]='fg=15,underline'
FAST_HIGHLIGHT_STYLES[pathseparator]=''
FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[globbing]='fg=blue'
FAST_HIGHLIGHT_STYLES[globbing-ext]='fg=blue'

#[brackets]
FAST_HIGHLIGHT_STYLES[paired-bracket]='bg=blue'
FAST_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
FAST_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'
FAST_HIGHLIGHT_STYLES[bracket-level-5]='fg=cyan,bold'

#[arguments]
FAST_HIGHLIGHT_STYLES[single-hyphen-option]='none'
FAST_HIGHLIGHT_STYLES[double-hyphen-option]='none'
FAST_HIGHLIGHT_STYLES[back-quoted-argument]='none'
FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'

#[in-string]
FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=cyan'
FAST_HIGHLIGHT_STYLES[back-or-dollar-double-quoted-argument]='fg=cyan'

#[other]
FAST_HIGHLIGHT_STYLES[variable]='none'
FAST_HIGHLIGHT_STYLES[assign]='none'
FAST_HIGHLIGHT_STYLES[assign-array-bracket]='fg=green'
FAST_HIGHLIGHT_STYLES[history-expansion]='fg=blue'

#[math]
FAST_HIGHLIGHT_STYLES[mathvar]='fg=blue,bold'
FAST_HIGHLIGHT_STYLES[mathnum]='fg=magenta'
FAST_HIGHLIGHT_STYLES[matherr]='fg=red'

#[for-loop]
FAST_HIGHLIGHT_STYLES[forvar]='none'
FAST_HIGHLIGHT_STYLES[fornum]='fg=magenta'
FAST_HIGHLIGHT_STYLES[foroper]='fg=yellow'
FAST_HIGHLIGHT_STYLES[forsep]='fg=yellow,bold'

#[case]
FAST_HIGHLIGHT_STYLES[case-input]='fg=green'
FAST_HIGHLIGHT_STYLES[case-parentheses]='fg=yellow'
FAST_HIGHLIGHT_STYLES[case-condition]='bg=blue'

#[optarg]
FAST_HIGHLIGHT_STYLES[optarg-string]='fg=yellow'
FAST_HIGHLIGHT_STYLES[optarg-number]='fg=magenta'



# filen-cli
PATH=$PATH:~/.filen-cli/bin
