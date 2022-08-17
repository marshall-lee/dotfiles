function my_rbenv_init() {
  (( ! ${+commands[rbenv]} )) && return

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
