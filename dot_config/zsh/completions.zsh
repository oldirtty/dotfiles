# completions.zsh
_comp_dir=~/.cache/zsh/completions
[[ -d $_comp_dir ]] || mkdir -p $_comp_dir

_gen_completion() {
  local cmd=$1 file=$_comp_dir/_$1
  shift
  (( $+commands[$cmd] )) || return
  [[ -s $file && $file -nt $commands[$cmd] ]] && return
  "$cmd" "$@" > $file 2>/dev/null || rm -f $file
}

_gen_completion chezmoi completion zsh
_gen_completion rbw gen-completions zsh
_gen_completion starship completions zsh
_gen_completion gowall completion zsh
_gen_completion noctalia completions zsh

regen-completions() {
  rm -f $_comp_dir/_*
  rm -f ~/.cache/zsh/.zcompdump*
  exec zsh
}
