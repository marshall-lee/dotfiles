function my_compinit() {
  autoload -Uz compinit
  setopt local_options
  setopt extendedglob
  local dumpfile=$ZSH/cache/zcompdump

  # If there're some changes in completion folders then cached dumpfile is invalidated.
  # Also recompute the dumpfile every hour.

  for cachepath ($SHELL $my_comppath); do
    if [[ $cachepath -nt $dumpfile ]] {
      rm -f $dumpfile
      break
    }
  done

  if [[ -n $dumpfile(#qN.mh-1) ]] {
    # -C option skips the check and compaudit run
    compinit -i -C -d $dumpfile
  } else {
    echo "Checking completions..."
    compinit -i -d $dumpfile
    touch $dumpfile
    zcompile $dumpfile
  }

  autoload -Uz bashcompinit && bashcompinit

  for comp ($ZSH/bash-completions/*(N)); do
    source $comp
  done
}

my_compinit
