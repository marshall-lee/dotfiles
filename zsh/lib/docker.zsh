# Symlink Docker Desktop completion files.
# https://docs.docker.com/desktop/mac/#install-shell-completion
if [[ "$OSTYPE" == darwin* ]] && [[ -e /Applications/Docker.app ]] {
  [[ ! -e $ZSH/completions/_docker ]] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion $ZSH/completions/_docker
  [[ ! -e $ZSH/completions/_docker-compose ]] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion $ZSH/completions/_docker-compose
}
