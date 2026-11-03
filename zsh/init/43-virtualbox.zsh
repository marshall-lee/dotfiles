function my_init_virtualbox() {
  (( ! ${+commands[VBoxManage]} )) && return

  my_link_zsh_completion virtualbox
}

my_init_virtualbox
