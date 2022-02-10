local ag_completions

if [[ -n $HOMEBREW_PREFIX && -e $HOMEBREW_PREFIX/opt/ag ]] {
  ag_completions=$HOMEBREW_PREFIX/opt/ag/share/zsh/site-functions
}

[[ $ag_completions ]] && fpath=($ag_completions $fpath)
