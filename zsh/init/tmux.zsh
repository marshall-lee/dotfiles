# Tells tmux which host an ssh command in this pane is connected to, so the
# status bar can show it (@ssh_host in tmux.conf).
function my_tmux_ssh_host_preexec() {
  setopt local_options extended_glob
  # $3 is the command about to run, with aliases expanded.
  local -a words=(${(z)3})
  while [[ $words[1] == [A-Za-z_]##=* ]] shift words
  [[ ${words[1]:t} == ssh ]] || return

  local i
  for (( i = 2; i <= $#words; i++ )) {
    case $words[i] in
      # Flags ending with one that takes a value, like -p or -vi: skip the value.
      (-[46AaCfGgKkMNnqsTtVvXxYy]#[BbcDEeFIiJLlmOoPpQRSWw]) (( i++ )) ;;
      (-*) ;;
      (*)
        local host=${(Q)words[i]}
        [[ $host == ssh://* ]] && host=${${host#ssh://}%:<->}
        tmux set -p -t $TMUX_PANE @ssh_host ${host#*@}
        my_tmux_ssh_host_set=1
        return
        ;;
    esac
  }
}

function my_tmux_ssh_host_precmd() {
  # Hand the last command's status on to the prompt, which colors by it.
  local ret=$?
  if (( ${+my_tmux_ssh_host_set} )) {
    unset my_tmux_ssh_host_set
    tmux set -pu -t $TMUX_PANE @ssh_host
  }
  return ret
}

function my_tmux_init() {
  [[ -z $TMUX ]] && return

  autoload -Uz add-zsh-hook
  add-zsh-hook preexec my_tmux_ssh_host_preexec
  add-zsh-hook precmd my_tmux_ssh_host_precmd
}

my_tmux_init
