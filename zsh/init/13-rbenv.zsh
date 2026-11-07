function my_rbenv_init() {
  (( ! ${+commands[rbenv]} )) && return

  # Symlink rbenv completion files.
  local rbenv_lib_completions=/usr/lib/rbenv/completions/_rbenv
  if [[ -f $rbenv_lib_completions ]] {
    [[ (! -L $ZSH/completions/_rbenv) && (! -f $ZSH/completions/_rbenv) && -f $rbenv_lib_completions ]] && ln -s $rbenv_lib_completions $ZSH/completions/_rbenv
  } else {
    [[ -L $ZSH/completions/_rbenv ]] && [[ $(readlink $ZSH/completions/_rbenv) == $rbenv_lib_completions ]] && rm -f $ZSH/completions/_rbenv
  }

  local rbenv_cache="$ZSH/cache/rbenv-init"
  if [[ "$commands[rbenv]" -nt "$rbenv_cache" || ! -s $rbenv_cache ]] {
    echo 'Generating rbenv initialization script...'
    rbenv init - --no-rehash zsh >| $rbenv_cache
    zcompile $rbenv_cache
  }
  source $rbenv_cache
  rbenv rehash 2>/dev/null &|
}

my_rbenv_init
