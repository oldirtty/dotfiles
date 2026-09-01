# zinit setup
declare -A ZINIT
ZINIT[ZCOMPDUMP_PATH]="$HOME/.cache/zsh/.zcompdump"
fpath=(~/.cache/zsh/completions $fpath)

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d $ZINIT_HOME/.git ]] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# plugins snippet rápidos
zi snippet OMZP::sudo
zi snippet OMZP::dotenv
zi snippet OMZP::extract
zi snippet OMZP::colored-man-pages
zi snippet OMZP::command-not-found
zi snippet OMZL::key-bindings.zsh

zi ice as"program" pick"bin/fzf" atclone"(./install --bin)" atpull"%atclone"
zi light junegunn/fzf

zi light Aloxaf/fzf-tab

# TurboMode
zi lucid wait for \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf \
        zsh-users/zsh-completions \
    atload'source "$ZDOTDIR/colors.zsh"' atinit'zicompinit; zicdreplay' \
        zdharma-continuum/fast-syntax-highlighting

ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=()

FZF_PLUGIN="${ZINIT_HOME%/zinit.git}/plugins/junegunn---fzf"
if [[ -d "$FZF_PLUGIN" ]]; then
    source "${FZF_PLUGIN}/shell/key-bindings.zsh" 2>/dev/null
    source "${FZF_PLUGIN}/shell/completion.zsh" 2>/dev/null
fi
unset FZF_PLUGIN

# completions
zstyle ':fzf-tab:*' fzf-flags --bind=right:ignore
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*:messages' format ' %F{yellow}--- %d ---%f'
zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'eza -1 --all --color=always --icons=always $realpath'
