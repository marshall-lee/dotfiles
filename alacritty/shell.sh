# command -v prints the path it finds, and also checks a full path is runnable.
tmux=$(command -v tmux || command -v /opt/homebrew/bin/tmux) || exec $SHELL

# The first window gets the session named shire: it attaches to it, or creates
# it. When another window already shows shire, a new window gets a new session,
# so windows don't mirror each other. With no shire, display prints nothing and
# the test is false.
if [ "$("$tmux" display -p -t =shire: '#{session_attached}' 2>/dev/null)" -gt 0 ] 2>/dev/null; then
  exec "$tmux" new-session
else
  exec "$tmux" new-session -A -s shire
fi
