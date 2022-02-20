function my_rbenv_init() {
  (( ! ${+commands[rbenv]} )) && return

  local rbenv_cache="$ZSH/cache/rbenv-init"
  if [[ "$commands[rbenv]" -nt "$rbenv_cache" || ! -s $rbenv_cache ]] {
    echo 'Generating rbenv initialization script...'
    rbenv init - zsh >| $rbenv_cache
    zcompile $rbenv_cache
  }
  source $rbenv_cache
}

my_rbenv_init
