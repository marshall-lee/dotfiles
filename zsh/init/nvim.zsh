function my_init_nvim() {
  (( ! ${+commands[nvim]} )) && return

  alias vim=nvim
}

my_init_nvim
