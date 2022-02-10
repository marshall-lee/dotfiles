function my_asdf_init() {
  local asdf

  if [[ -n $HOMEBREW_PREFIX ]] && [[ -e $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh ]] {
    asdf=$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh
  }

  if [[ -n $asdf ]] && source $asdf
}

my_asdf_init
