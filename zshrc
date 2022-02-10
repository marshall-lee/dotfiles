[[ -z "$ZSH" ]] && export ZSH="$HOME/.zsh"

my_comppath=() # Track paths with completion functions separately
function my_add_comp_path() {
  [[ ! ${fpath[(r)$1]} ]] && fpath=($1 $fpath)
  [[ ! ${my_comppath[(r)$1]} ]] && my_comppath=($1 $my_comppath)
}

# Links something from zsh-users/zsh-completions repo
function my_link_zsh_completion() {
  [[ -e $ZSH/completions/_$1 ]] && return

  local comppath
  if [[ $HOMEBREW_PREFIX && -e $HOMEBREW_PREFIX/share/zsh-completions ]] {
    comppath=$HOMEBREW_PREFIX/share/zsh-completions
  } else {
    return
  }
  ln -s $comppath/_$1 $ZSH/completions/_$1
}

# Compiles the file if needed and executes it
function my_compile() {
  if [[ ! -e $1.zwc || $1 -nt $1.zwc ]] {
    zcompile $1
  } else {
    return 0
  }
}

my_compile $ZSH/brew.zsh && source $ZSH/brew.zsh

for config_file ($ZSH/lib/*.zsh); do
  my_compile $config_file && source $config_file
done

my_compile $ZSH/compinit.zsh && source $ZSH/compinit.zsh
