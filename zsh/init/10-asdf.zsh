function my_asdf_init() {
  if (( ${+commands[asdf]} )) {
    path=("${HOME}/.asdf/shims" $path)
  }
}

my_asdf_init
