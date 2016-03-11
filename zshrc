# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
fpath=($HOME/.zsh/Completion $fpath)

ZSH_THEME="agnoster"
DEFAULT_USER=$USER
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git archlinux sudo ruby rails mvn fasd postgres zsh-syntax-highlighting zsh-completions iwhois)

# User configuration

export PATH="$PATH:/home/marshall/.gem/ruby/2.2.0/bin"

# source /usr/share/bash-completion/bash_completion
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

alias readme='redcarpet-pygments README.md | TERM=xterm-256color elinks'

bindkey -s '\el' 'ls -lAh --color | less -r\n'

export TERM=xterm-256color

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:/usr/local/heroku/bin"
export PATH="$PATH:$HOME/bin"
export PATH=".cabal-sandbox/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="node_modules/.bin:$PATH"
export EDITOR=vim

autoload -U compinit && compinit
