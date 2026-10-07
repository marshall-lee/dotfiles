function my_zsh_syntax_highlighting_init() {
  local try_paths=(
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  )

  local scriptpath
  for scriptpath ("${try_paths[@]}") {
    if [[ -f "${scriptpath}" ]] {
      source "${scriptpath}"
      break
    }
  }
}

my_zsh_syntax_highlighting_init
