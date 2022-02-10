if (( ${+commands[stack]} )) {
  [[ ! -e $ZSH/bash-completions/stack ]] && stack --bash-completion-script stack > $ZSH/bash-completions/stack
} else {
  [[ -e $ZSH/bash-completions/stack ]] && rm -f $ZSH/bash-completions/stack
}
