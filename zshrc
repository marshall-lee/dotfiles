[[ -z "$ZSH" ]] && export ZSH="$HOME/.zsh"

source $ZSH/brew.zsh

for config_file ($ZSH/lib/*.zsh); do
  source "$config_file"
done

source $ZSH/compinit.zsh
