path=(/usr/local/bin /usr/local/sbin $path)
[[ $HOMEBREW_PREFIX == /opt/homebrew ]] && path=(/opt/homebrew/bin /opt/homebrew/sbin $path) # Give ARM homebrew a priority
path=($HOME/.local/bin $path)
