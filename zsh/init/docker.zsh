function my_docker_init() {
  # Symlink Docker Desktop completion files.
  # https://docs.docker.com/desktop/faqs/macfaqs/#zsh
  if [[ "$OSTYPE" == darwin* ]] && [[ -e /Applications/Docker.app ]] {
    local docker_app_etc=/Applications/Docker.app/Contents/Resources/etc
    [[ ! -e $ZSH/completions/_docker && -e $docker_app_etc/docker.zsh-completion ]] && ln -s $docker_app_etc/docker.zsh-completion $ZSH/completions/_docker
    [[ ! -e $ZSH/completions/_docker-compose && -e $docker_app_etc/docker-compose.zsh-completion ]] && ln -s $docker_app_etc/docker-compose.zsh-completion $ZSH/completions/_docker-compose
  }
}

my_docker_init
