# Inspired by ohmyzsh.
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/theme-and-appearance.zsh

autoload -U colors && colors
setopt prompt_subst
unsetopt beep
DEFAULT_USER=$USER # don't show username in the prompt
if [[ "$OSTYPE" == (darwin|freebsd)* ]] {
  export LSCOLORS="Gxfxcxdxbxegedabagacad"
  export CLICOLOR=
}
