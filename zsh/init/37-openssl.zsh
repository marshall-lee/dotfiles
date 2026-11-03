function my_init_openssl() {
  (( ! ${+commands[openssl]} )) && return

  my_link_zsh_completion openssl
}

my_init_openssl
