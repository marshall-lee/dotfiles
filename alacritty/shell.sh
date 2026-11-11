# command -v prints the path it finds, and also checks a full path is runnable.
tmux=$(command -v tmux || command -v /opt/homebrew/bin/tmux) || exec $SHELL

# The session is named with the OS's Nerd Font icon. uname, not $OSTYPE: this
# runs in /bin/sh, which is dash on some Linux systems, and dash doesn't set it.
case $(uname -s) in
  Darwin) session='' ;;
  Linux) session='' ;;
  *) session='' ;;
esac

# The first window gets that session: it attaches to it, or creates it. When
# another window already shows it, a new window gets a new session, so windows
# don't mirror each other. display needs a pane target, hence the colon; with
# no such session it prints nothing and the test is false.
if [ "$("$tmux" display -p -t "=$session:" '#{session_attached}' 2>/dev/null)" -gt 0 ] 2>/dev/null; then
  exec "$tmux" new-session
else
  exec "$tmux" new-session -A -s "$session"
fi
