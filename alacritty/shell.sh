if command -v tmux; then
  exec tmux
else
  exec $SHELL
fi
