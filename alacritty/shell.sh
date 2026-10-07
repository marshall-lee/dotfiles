if command -v tmux; then
  exec tmux
elif [ -f /opt/homebrew/bin/tmux ]; then
  exec /opt/homebrew/bin/tmux
else
  exec $SHELL
fi
