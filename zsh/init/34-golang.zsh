function my_init_golang() {
  (( ! ${+commands[go]} )) && return

  [[ -z $GOBIN ]] && export GOBIN=$HOME/.local/bin

  my_link_zsh_completion golang
}

my_init_golang
