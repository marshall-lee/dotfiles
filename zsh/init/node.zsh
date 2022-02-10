function my_init_node() {
  (( ! ${+commands[node]} )) && return

  my_link_zsh_completion node
}

my_init_node
