function my_fzf_init() {
  setopt local_options
  setopt extendedglob

  local fzfbin
  if ! fzfbin=$(command -v fzf) {
    return
  }

  local fzfzsh="$ZSH/cache/fzf-zsh"
  if [[ "$fzfbin" -nt "$fzfzsh" ]] {
    rm -f "$fzfzsh"
  }

  # Cache `fzf --zsh` output.
  if [[ -z "$fzfzsh"(#qN.mh-6) ]] {
    "$fzfbin" --zsh > "$fzfzsh"
  }

  # Only ** completion, without the Ctrl-T, Ctrl-R and Alt-C key bindings.
  local FZF_CTRL_T_COMMAND= FZF_CTRL_R_COMMAND= FZF_ALT_C_COMMAND=
  source "$fzfzsh"

  # fzf's own walker doesn't read .gitignore, .ignore or .fdignore, but fd does.
  # Like the walker, it skips .git and hidden directories when it lists only
  # directories. ** passes . for the current directory, and fd prints
  # ./src/main.rb for it, so it gets no path: then it's src/main.rb.
  if (( ${+commands[fd]} )) {
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    function _fzf_compgen_path() {
      fd --hidden --follow --exclude .git/ . ${1:#.}
    }
    function _fzf_compgen_dir() {
      fd --type d --follow --exclude .git/ . ${1:#.}
    }
  }
}

my_fzf_init
