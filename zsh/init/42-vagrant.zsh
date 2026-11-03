function my_init_vagrant() {
  (( ! ${+commands[vagrant]} )) && return

  my_link_zsh_completion vagrant
}

my_init_vagrant
