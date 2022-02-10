(( ! ${+commands[go]} )) && return

[[ -z $GOBIN ]] && export GOBIN=$HOME/.local/bin

link_zsh_completion golang
