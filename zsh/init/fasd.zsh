# Inspired by fasd plugin of ohmyzsh.
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fasd

function my_fasd_init() {
  (( ! ${+commands[fasd]} )) && return

  local fasd_cache="$ZSH/cache/fasd-init"
  if [[ "$commands[fasd]" -nt "$fasd_cache" || ! -s "$fasd_cache" ]] {
    echo 'Generating fasd initialization script...'
    fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
      zsh-wcomp zsh-wcomp-install >| "$fasd_cache"
  }
  source "$fasd_cache"
}

my_fasd_init
