# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

if [[ `tty` == /dev/pts/* ]]; then
  ZSH_THEME="agnoster"
else
  ZSH_THEME="sammy"
fi
DEFAULT_USER=$USER
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git archlinux sudo ruby rails mvn fasd postgres docker zsh-syntax-highlighting zsh-completions iwhois lol)

# User configuration

source $ZSH/oh-my-zsh.sh

function _rspec_command () {
  if [ -e "bin/rspec" ]; then
    bin/rspec $@
  else
    command rspec $@
  fi
}

alias rspec='_rspec_command'
# compdef _rspec_command=rspec

function _bundle_command () {
  if [ -e "bin/bundle" ]; then
    bin/bundle $@
  else
    command bundle $@
  fi
}

alias bundle='_bundle_command'

function _spring_command () {
  if [ -e "bin/spring" ]; then
    bin/spring $@
  else
    command spring $@
  fi
}

alias spring='_spring_command'

function setgemfile() {
  export BUNDLE_GEMFILE=$1:A
}

alias readme='redcarpet-pygments README.md | TERM=xterm-256color elinks'

alias tmux="tmux -2"

bindkey -s '\el' 'ls -lAh --color | less -r\n'

export TERM=xterm-256color

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:/usr/local/heroku/bin"
export PATH="$PATH:$HOME/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH=".git/safe/../../.cabal-sandbox/bin:$PATH"
export PATH=".git/safe/../../node_modules/.bin:$PATH"
export PATH=".git/safe/../../bin:$PATH"
export EDITOR=vim

autoload -U compinit && compinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
