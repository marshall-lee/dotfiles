function my_ag_init() {
  local ag_completions
  if [[ -n $HOMEBREW_PREFIX && -e $HOMEBREW_PREFIX/opt/ag ]] {
    ag_completions=$HOMEBREW_PREFIX/opt/ag/share/zsh/site-functions
  }

  [[ -n $ag_completions ]] && my_add_comp_path $ag_completions
}

my_ag_init
