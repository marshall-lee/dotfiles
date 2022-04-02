
my_comppath=() 
# Tracks paths with completion functions separately from fpath
function my_add_comp_path() {
  [[ -z ${fpath[(r)$1]} ]] && fpath=($1 $fpath)
  [[ -z ${my_comppath[(r)$1]} ]] && my_comppath=($1 $my_comppath)
}

# Links something from zsh-users/zsh-completions repo
function my_link_zsh_completion() {
  [[ -e $ZSH/completions/_$1 ]] && return

  local comppath
  if [[ -n $HOMEBREW_PREFIX && -e $HOMEBREW_PREFIX/share/zsh-completions ]] {
    comppath=$HOMEBREW_PREFIX/share/zsh-completions
  } else {
    return
  }
  ln -s $comppath/_$1 $ZSH/completions/_$1
}
