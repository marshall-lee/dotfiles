[[ -z "$ZSH" ]] && export ZSH="$HOME/.zsh"

# Links something from zsh-users/zsh-completions repo
function link_zsh_completion() {
  [[ -e $ZSH/completions/_$1 ]] && return

  local comppath
  if [[ $HOMEBREW_PREFIX && -e $HOMEBREW_PREFIX/share/zsh-completions ]] {
    comppath=$HOMEBREW_PREFIX/share/zsh-completions
  } else {
    return
  }
  ln -s $comppath/_$1 $ZSH/completions/_$1
}

source $ZSH/brew.zsh

for config_file ($ZSH/lib/*.zsh); do
  source "$config_file"
done

source $ZSH/compinit.zsh
