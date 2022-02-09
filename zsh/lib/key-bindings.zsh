# Inspired by ohmyzsh.
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey -e

bindkey "^[m" copy-prev-shell-word
