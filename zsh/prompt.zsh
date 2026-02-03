# My theme is a fork of Pure https://github.com/sindresorhus/pure

prompt_my_set_title() {
  setopt localoptions noshwordsplit

  # Emacs terminal does not support settings the title.
  (( ${+EMACS} || ${+INSIDE_EMACS} )) && return

  case $TTY in
    # Don't set title over serial console.
    /dev/ttyS[0-9]*) return;;
  esac

  # Show hostname if connected via SSH.
  local hostname=
  if [[ -n $prompt_my_state[username] ]]; then
    # Expand in-place in case ignore-escape is used.
    hostname="${(%):-(%m) }"
  fi

  local -a opts
  case $1 in
    expand-prompt) opts=(-P);;
    ignore-escape) opts=(-r);;
  esac

  # Set title atomically in one print statement so that it works when XTRACE is enabled.
  print -n $opts $'\e]0;'${hostname}${2}$'\a'
}

prompt_my_preexec() {
  typeset -g prompt_my_cmd_timestamp=$EPOCHSECONDS

  # Shows the current directory and executed command in the title while a process is active.
  prompt_my_set_title 'ignore-escape' "$PWD:t: $2"
}

# Change the colors if their value are different from the current ones.
prompt_my_set_colors() {
  local color_temp key value
  for key value in ${(kv)prompt_my_colors}; do
    zstyle -t ":prompt:my:$key" color "$value"
    case $? in
      1) # The current style is different from the one from zstyle.
        zstyle -s ":prompt:my:$key" color color_temp
        prompt_my_colors[$key]=$color_temp ;;
      2) # No style is defined.
        prompt_my_colors[$key]=$prompt_my_colors_default[$key] ;;
    esac
  done
}

prompt_my_preprompt_render() {
  setopt localoptions noshwordsplit

  unset prompt_my_async_render_requested

  local git_color
  if [[ $prompt_my_git_untracked == 1 || $prompt_my_git_unstaged == 1 ]] {
    git_color=$prompt_my_colors[git:dirty]
  } elif [[ $prompt_my_git_untracked == 0 && $prompt_my_git_unstaged == 0 ]] {
    git_color=$prompt_my_colors[git:clean]
  } else {
    git_color=default
  }

  # Initialize the preprompt array.
  local -a preprompt_parts

  # Username and machine, if applicable.
  [[ -n $prompt_my_state[username] ]] && preprompt_parts+=($prompt_my_state[username])

  # Set the path.
  preprompt_parts+=('%F{${prompt_my_colors[path]}}%~%f')

  # Git branch (dirty or clean).
  typeset -gA prompt_my_vcs_info
  if [[ -n $prompt_my_vcs_info[branch] ]]; then
    preprompt_parts+=("%F{$git_color}"'${prompt_my_vcs_info[branch]}%f')
  fi
  # Git staged/unstaged changes.
  if [[ $prompt_my_git_staged == 1 ]]; then
    preprompt_parts+=("%F{$prompt_my_colors[git:staged]}●%f")
  fi
  if [[ $prompt_my_git_unstaged == 1 ]]; then
    preprompt_parts+=("%F{$prompt_my_colors[git:unstaged]}●%f")
  fi
  # Git action (for example, merge).
  if [[ -n $prompt_my_vcs_info[action] ]]; then
    preprompt_parts+=("%F{$prompt_my_colors[git:action]}"'$prompt_my_vcs_info[action]%f')
  fi
  # Git pull/push arrows.
  if [[ -n $prompt_my_git_arrows ]]; then
    preprompt_parts+=('%F{$prompt_my_colors[git:arrow]}${prompt_my_git_arrows}%f')
  fi
  # Git stash symbol (if opted in).
  if [[ -n $prompt_my_git_stash ]]; then
    preprompt_parts+=('%F{$prompt_my_colors[git:stash]}${PURE_GIT_STASH_SYMBOL:-≡}%f')
  fi

  local cleaned_ps1=$PROMPT
  local -H MATCH MBEGIN MEND
  if [[ $PROMPT = *$prompt_newline* ]]; then
    # Remove everything from the prompt until the newline. This
    # removes the preprompt and only the original PROMPT remains.
    cleaned_ps1=${PROMPT##*${prompt_newline}}
  fi
  unset MATCH MBEGIN MEND

  # Construct the new prompt with a clean preprompt.
  local -ah ps1
  ps1=(
    ${(j. .)preprompt_parts}  # Join parts, space separated.
    $prompt_newline           # Separate preprompt and prompt.
    $cleaned_ps1
  )

  PROMPT="${(j..)ps1}"

  # Expand the prompt for future comparision.
  local expanded_prompt
  expanded_prompt="${(S%%)PROMPT}"

  if [[ $1 == precmd ]]; then
    # Initial newline, for spaciousness.
    print
  elif [[ $prompt_my_last_prompt != $expanded_prompt ]]; then
    # Redraw the prompt.
    prompt_my_reset_prompt
  fi

  typeset -g prompt_my_last_prompt=$expanded_prompt
}

prompt_my_precmd() {
  setopt localoptions noshwordsplit

  # Shows the full path in the title.
  prompt_my_set_title 'expand-prompt' '%~'

  # Modify the colors if some have changed..
  prompt_my_set_colors

  # Perform async Git dirty check.
  (( $prompt_my_async_enabled )) && prompt_my_async_tasks

  # Make sure VIM prompt is reset.
  prompt_my_reset_prompt_symbol

  # Print the preprompt.
  prompt_my_preprompt_render "precmd"
}

prompt_my_async_vcs_info() {
  setopt localoptions noshwordsplit

  # Configure `vcs_info` inside an async task. This frees up `vcs_info`
  # to be used or configured as the user pleases.
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' use-simple true
  # Only export three message variables from `vcs_info`.
  zstyle ':vcs_info:*' max-exports 3
  # Export branch (%b), Git toplevel (%R), action (rebase/cherry-pick) (%a)
  zstyle ':vcs_info:git*' formats '%b' '%R' '%a'
  zstyle ':vcs_info:git*' actionformats '%b' '%R'

  vcs_info

  local -A info
  info[pwd]=$PWD
  info[branch]=$vcs_info_msg_0_
  info[top]=$vcs_info_msg_1_
  info[action]=$vcs_info_msg_2_

  print -r - ${(@kvq)info}
}

# Fastest possible way to check if a Git repo has untracked files.
prompt_my_async_git_untracked() {
  local untracked_git_mode=$(command git config --get status.showUntrackedFiles)
  if [[ "$untracked_git_mode" == 'no' ]]; then
    return 0
  fi

  test -z "$(command git --no-optional-locks ls-files --exclude-standard --directory --no-empty-directory --others)"
  return $?
}

# Fastest possible way to check if a Git repo has staged files.
prompt_my_async_git_staged() {
  # Inspired by VCS_INFO_get_data_git
  if command git rev-parse --quiet --verify HEAD > /dev/null; then
    command git diff-index --cached --quiet --ignore-submodules=dirty HEAD
  else
    command git diff-index --cached --quiet --ignore-submodules=dirty 4b825dc642cb6eb9a060e54bf8d69288fbee4904
  fi
  return $?
}

prompt_my_async_git_unstaged() {
  command git diff --no-ext-diff --ignore-submodules=dirty --quiet --exit-code
  return $?
}

prompt_my_async_git_arrows() {
  setopt localoptions noshwordsplit
  command git rev-list --left-right --count HEAD...@'{u}'
}

prompt_my_async_git_stash() {
  git rev-list --walk-reflogs --count refs/stash
}

# Try to lower the priority of the worker so that disk heavy operations
# like `git status` has less impact on the system responsivity.
prompt_my_async_renice() {
  setopt localoptions noshwordsplit

  if command -v renice >/dev/null; then
    command renice +15 -p $$
  fi

  if command -v ionice >/dev/null; then
    command ionice -c 3 -p $$
  fi
}

prompt_my_async_init() {
  typeset -g prompt_my_async_inited
  if ((${prompt_my_async_inited:-0})); then
    return
  fi
  if (( $prompt_my_async_enabled )); then
    prompt_my_async_inited=1
    async_start_worker "prompt_my" -u -n
    async_register_callback "prompt_my" prompt_my_async_callback
    async_worker_eval "prompt_my" prompt_my_async_renice
  fi
}

prompt_my_async_tasks() {
  setopt localoptions noshwordsplit

  # Initialize the async worker.
  prompt_my_async_init

  # Update the current working directory of the async workers.
  async_worker_eval "prompt_my" builtin cd -q $PWD

  typeset -gA prompt_my_vcs_info

  local -H MATCH MBEGIN MEND
  if [[ $PWD != ${prompt_my_vcs_info[pwd]}* ]]; then
    # Stop any running async jobs.
    async_flush_jobs "prompt_my"

    # Reset Git preprompt variables, switching working tree.
    unset prompt_my_git_unstaged
    unset prompt_my_git_staged
    unset prompt_my_git_untracked
    unset prompt_my_git_arrows
    unset prompt_my_git_stash
    prompt_my_vcs_info[branch]=
    prompt_my_vcs_info[top]=
  fi
  unset MATCH MBEGIN MEND

  async_job "prompt_my" prompt_my_async_vcs_info

  # Only perform tasks inside a Git working tree.
  [[ -n $prompt_my_vcs_info[top] ]] || return

  prompt_my_async_refresh
}

prompt_my_async_refresh() {
  setopt localoptions noshwordsplit

  async_job "prompt_my" prompt_my_async_git_arrows

  async_job "prompt_my" prompt_my_async_git_staged
  async_job "prompt_my" prompt_my_async_git_unstaged
  async_job "prompt_my" prompt_my_async_git_untracked

  # If stash is enabled, tell async worker to count stashes
  if zstyle -t ":prompt:my:git:stash" show; then
    async_job "prompt_my" prompt_my_async_git_stash
  else
    unset prompt_my_git_stash
  fi
}

prompt_my_check_git_arrows() {
  setopt localoptions noshwordsplit
  local arrows left=${1:-0} right=${2:-0}

  (( right > 0 )) && arrows+=${PURE_GIT_DOWN_ARROW:-⇣}
  (( left > 0 )) && arrows+=${PURE_GIT_UP_ARROW:-⇡}

  [[ -n $arrows ]] || return
  typeset -g REPLY=$arrows
}

prompt_my_async_callback() {
  setopt localoptions noshwordsplit
  local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6
  local do_render=0

  case $job in
    \[async])
      # Handle all the errors that could indicate a crashed
      # async worker. See zsh-async documentation for the
      # definition of the exit codes.
      if (( code == 2 )) || (( code == 3 )) || (( code == 130 )); then
        # Our worker died unexpectedly, try to recover immediately.
        # TODO(mafredri): Do we need to handle next_pending
        #                 and defer the restart?
        typeset -g prompt_my_async_inited=0
        async_stop_worker prompt_my
        prompt_my_async_init   # Reinit the worker.
        prompt_my_async_tasks  # Restart all tasks.

        # Reset render state due to restart.
        unset prompt_my_async_render_requested
      fi
      ;;
    \[async/eval])
      if (( code )); then
        # Looks like async_worker_eval failed,
        # rerun async tasks just in case.
        prompt_my_async_tasks
      fi
      ;;
    prompt_my_async_vcs_info)
      local -A info
      typeset -gA prompt_my_vcs_info

      # Parse output (z) and unquote as array (Q@).
      info=("${(Q@)${(z)output}}")
      local -H MATCH MBEGIN MEND
      if [[ $info[pwd] != $PWD ]]; then
        # The path has changed since the check started, abort.
        return
      fi
      # Check if Git top-level has changed.
      if [[ $info[top] = $prompt_my_vcs_info[top] ]]; then
        # If the stored pwd is part of $PWD, $PWD is shorter and likelier
        # to be top-level, so we update pwd.
        if [[ $prompt_my_vcs_info[pwd] = ${PWD}* ]]; then
          prompt_my_vcs_info[pwd]=$PWD
        fi
      else
        # Store $PWD to detect if we (maybe) left the Git path.
        prompt_my_vcs_info[pwd]=$PWD
      fi
      unset MATCH MBEGIN MEND

      # The update has a Git top-level set, which means we just entered a new
      # Git directory. Run the async refresh tasks.
      [[ -n $info[top] ]] && [[ -z $prompt_my_vcs_info[top] ]] && prompt_my_async_refresh

      # Always update branch, top-level and stash.
      prompt_my_vcs_info[branch]=$info[branch]
      prompt_my_vcs_info[top]=$info[top]
      prompt_my_vcs_info[action]=$info[action]

      do_render=1
      ;;
    prompt_my_async_git_staged)
      local prev_staged=$prompt_my_git_staged
      prompt_my_git_staged=$code

      [[ $prev_staged != $prompt_my_git_staged ]] && do_render=1
      ;;
    prompt_my_async_git_unstaged)
      local prev_unstaged=$prompt_my_git_unstaged
      prompt_my_git_unstaged=$code

      [[ $prev_unstaged != $prompt_my_git_unstaged ]] && do_render=1
      ;;
    prompt_my_async_git_untracked)
      local prev_untracked=$prompt_my_git_untracked
      prompt_my_git_untracked=$code

      [[ $prev_untracked != $prompt_my_git_untracked ]] && do_render=1
      ;;
    prompt_my_async_git_arrows)
      case $code in
        0)
          local REPLY
          prompt_my_check_git_arrows ${(ps:\t:)output}
          if [[ $prompt_my_git_arrows != $REPLY ]]; then
            typeset -g prompt_my_git_arrows=$REPLY
            do_render=1
          fi
          ;;
        *)
          # Non-zero exit status from `prompt_my_async_git_arrows`,
          # indicating that there is no upstream configured.
          if [[ -n $prompt_my_git_arrows ]]; then
            unset prompt_my_git_arrows
            do_render=1
          fi
          ;;
      esac
      ;;
    prompt_my_async_git_stash)
      local prev_stash=$prompt_my_git_stash
      typeset -g prompt_my_git_stash=$output
      [[ $prev_stash != $prompt_my_git_stash ]] && do_render=1
      ;;
  esac

  if (( next_pending )); then
    (( do_render )) && typeset -g prompt_my_async_render_requested=1
    return
  fi

  [[ ${prompt_my_async_render_requested:-$do_render} = 1 ]] && prompt_my_preprompt_render
  unset prompt_my_async_render_requested
}

prompt_my_reset_prompt() {
  if [[ $CONTEXT == cont ]]; then
    # When the context is "cont", PS2 is active and calling
    # reset-prompt will have no effect on PS1, but it will
    # reset the execution context (%_) of PS2 which we don't
    # want. Unfortunately, we can't save the output of "%_"
    # either because it is only ever rendered as part of the
    # prompt, expanding in-place won't work.
    return
  fi

  zle && zle .reset-prompt
}

prompt_my_reset_prompt_symbol() {
  prompt_my_state[prompt]=${PURE_PROMPT_SYMBOL:-❯}
}

prompt_my_update_vim_prompt_widget() {
  setopt localoptions noshwordsplit
  prompt_my_state[prompt]=${${KEYMAP/vicmd/${PURE_PROMPT_VICMD_SYMBOL:-❮}}/(main|viins)/${PURE_PROMPT_SYMBOL:-❯}}

  prompt_my_reset_prompt
}

prompt_my_reset_vim_prompt_widget() {
  setopt localoptions noshwordsplit
  prompt_my_reset_prompt_symbol

  # We can't perform a prompt reset at this point because it
  # removes the prompt marks inserted by macOS Terminal.
}

prompt_my_switch_to_vicmd() {
  zle vi-add-eol
}

prompt_my_state_setup() {
  setopt localoptions noshwordsplit

  # Check SSH_CONNECTION and the current state.
  local ssh_connection=${SSH_CONNECTION:-$PROMPT_PURE_SSH_CONNECTION}
  local username hostname
  if [[ -z $ssh_connection ]] && (( $+commands[who] )); then
    # When changing user on a remote system, the $SSH_CONNECTION
    # environment variable can be lost. Attempt detection via `who`.
    local who_out
    who_out=$(who -m 2>/dev/null)
    if (( $? )); then
      # Who am I not supported, fallback to plain who.
      local -a who_in
      who_in=( ${(f)"$(who 2>/dev/null)"} )
      who_out="${(M)who_in:#*[[:space:]]${TTY#/dev/}[[:space:]]*}"
    fi

    local reIPv6='(([0-9a-fA-F]+:)|:){2,}[0-9a-fA-F]+'  # Simplified, only checks partial pattern.
    local reIPv4='([0-9]{1,3}\.){3}[0-9]+'   # Simplified, allows invalid ranges.
    # Here we assume two non-consecutive periods represents a
    # hostname. This matches `foo.bar.baz`, but not `foo.bar`.
    local reHostname='([.][^. ]+){2}'

    # Usually the remote address is surrounded by parenthesis, but
    # not on all systems (e.g. busybox).
    local -H MATCH MBEGIN MEND
    if [[ $who_out =~ "\(?($reIPv4|$reIPv6|$reHostname)\)?\$" ]]; then
      ssh_connection=$MATCH

      # Export variable to allow detection propagation inside
      # shells spawned by this one (e.g. tmux does not always
      # inherit the same tty, which breaks detection).
      export PROMPT_PURE_SSH_CONNECTION=$ssh_connection
    fi
    unset MATCH MBEGIN MEND
  fi

  hostname='%F{$prompt_my_colors[host]}@%m%f'
  # Show `username@host` if logged in through SSH.
  [[ -n $ssh_connection ]] && username='%F{$prompt_my_colors[user]}%n%f'"$hostname"

  # Show `username@host` if root, with username in default color.
  [[ $UID -eq 0 ]] && username='%F{$prompt_my_colors[user:root]}%n%f'"$hostname"

  typeset -gA prompt_my_state
  prompt_my_state+=(username "$username")
}

prompt_my_setup() {
  # Prevent percentage showing up if output doesn't end with a newline.
  export PROMPT_EOL_MARK=''

  prompt_opts=(subst percent)

  # Borrowed from `promptinit`. Sets the prompt options in case Pure was not
  # initialized via `promptinit`.
  setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

  if [[ -z $prompt_newline ]]; then
    # This variable needs to be set, usually set by promptinit.
    typeset -g prompt_newline=$'\n%{\r%}'
  fi

  zmodload zsh/datetime
  zmodload zsh/zle
  zmodload zsh/parameter
  zmodload zsh/zutil

  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info
  autoload -Uz async && async 2>/dev/null

  typeset -g prompt_my_async_enabled=$(( $? == 0 ))

  # The `add-zle-hook-widget` function is not guaranteed to be available.
  # It was added in Zsh 5.3.
  autoload -Uz +X add-zle-hook-widget 2>/dev/null

  # Set the colors.
  typeset -gA prompt_my_colors_default prompt_my_colors
  prompt_my_colors_default=(
    git:arrow            cyan
    git:stash            cyan
    git:branch           242
    git:branch:cached    red
    git:action           yellow
    git:dirty            yellow
    git:clean            green
    git:staged           green
    git:unstaged         red
    host                 242
    path                 blue
    prompt:error         red
    prompt:success       cyan
    prompt:continuation  242
    user                 242
    user:root            default
  )
  prompt_my_colors=("${(@kv)prompt_my_colors_default}")

  add-zsh-hook precmd prompt_my_precmd
  add-zsh-hook preexec prompt_my_preexec

  prompt_my_state_setup

  zle -N prompt_my_reset_prompt
  zle -N prompt_my_update_vim_prompt_widget
  zle -N prompt_my_reset_vim_prompt_widget
  if (( $+functions[add-zle-hook-widget] )); then
    add-zle-hook-widget zle-line-finish prompt_my_reset_vim_prompt_widget
    add-zle-hook-widget zle-keymap-select prompt_my_update_vim_prompt_widget
    # add-zle-hook-widget zle-isearch-exit prompt_my_switch_to_vicmd
  fi

  # Prompt turns red if the previous command didn't exit with 0.
  PROMPT='%(?.%F{$prompt_my_colors[prompt:success]}.%F{$prompt_my_colors[prompt:error]})${prompt_my_state[prompt]}%f '

  # Indicate continuation prompt by … and use a darker color for it.
  PROMPT2='%F{$prompt_my_colors[prompt:continuation]}… %(1_.%_ .%_)%f'$prompt_indicator

  # Store prompt expansion symbols for in-place expansion via (%). For
  # some reason it does not work without storing them in a variable first.
  typeset -ga prompt_my_debug_depth
  prompt_my_debug_depth=('%e' '%N' '%x')

  # Compare is used to check if %N equals %x. When they differ, the main
  # prompt is used to allow displaying both filename and function. When
  # they match, we use the secondary prompt to avoid displaying duplicate
  # information.
  local -A ps4_parts
  ps4_parts=(
    depth     '%F{yellow}${(l:${(%)prompt_my_debug_depth[1]}::+:)}%f'
    compare   '${${(%)prompt_my_debug_depth[2]}:#${(%)prompt_my_debug_depth[3]}}'
    main      '%F{blue}${${(%)prompt_my_debug_depth[3]}:t}%f%F{242}:%I%f %F{242}@%f%F{blue}%N%f%F{242}:%i%f'
    secondary '%F{blue}%N%f%F{242}:%i'
    prompt     '%F{242}>%f '
  )
  # Combine the parts with conditional logic. First the `:+` operator is
  # used to replace `compare` either with `main` or an ampty string. Then
  # the `:-` operator is used so that if `compare` becomes an empty
  # string, it is replaced with `secondary`.
  local ps4_symbols='${${'${ps4_parts[compare]}':+"'${ps4_parts[main]}'"}:-"'${ps4_parts[secondary]}'"}'

  # Improve the debug prompt (PS4), show depth by repeating the +-sign and
  # add colors to highlight essential parts like file and function name.
  PROMPT4="${ps4_parts[depth]} ${ps4_symbols}${ps4_parts[prompt]}"
}

prompt_my_setup "$@"
