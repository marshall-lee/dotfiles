function my_opam_init() {
  setopt local_options
  setopt extendedglob

  local opambin
  if ! opambin=$(command -v opam) {
    return
  }

  local opamenv="$ZSH/cache/opam-env"
  if [[ "$opambin" -nt "$opamenv" ]] {
    rm -f "$opamenv"
  }

  # Cache `opam env` output.
  if [[ -z "$opamenv"(#qN.mh-6) ]] {
    command opam env --shell=zsh | grep -v '^PATH=' > "$opamenv"
  }

  source "$opamenv"
  path=("$OPAM_SWITCH_PREFIX/bin" $path)
}

my_opam_init
