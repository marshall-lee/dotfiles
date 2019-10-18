# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

if [[ `tty` == /dev/pts/* ]] || [[ `tty` == /dev/ttys* ]]; then
  ZSH_THEME="agnoster"
else
  ZSH_THEME="sammy"
fi
DEFAULT_USER=$USER
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git sudo ruby fasd postgres docker zsh-syntax-highlighting zsh-completions lol)

# User configuration

source $ZSH/oh-my-zsh.sh

function setgemfile() {
  export BUNDLE_GEMFILE=$1:A
}

function bundle_install() {
  root=`git rev-parse --show-toplevel`
  bundle install --path "$root/vendor/bundle" --binstubs "$root/.bundle/bin"
}

function debug_cflags() {
  # export CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer" CXXFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer"
  export CFLAGS="-g3 -O0" CXXFLAGS="-g3 -O0"
}

function diff {
  colordiff -u "$@" | less -RF
}

export TERM=xterm-256color

eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" --no-use
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"

export PATH="$PATH:/usr/local/heroku/bin"
export PATH="$(find $HOME/.nvm/versions/node/* -maxdepth 0 | tail -1)/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH=".git/safe/../../.cabal-sandbox/bin:$PATH"
export PATH=".git/safe/../../node_modules/.bin:$PATH"
export PATH=".git/safe/../../bin:$PATH"
export EDITOR=vim

autoload -U compinit && compinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
