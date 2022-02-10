autoload -Uz compinit
setopt local_options
setopt extendedglob

local dumpfile=$ZSH/cache/zcompdump

# Cache compinit check result for 1 hour.
# If there're some changes in completions folder then cache is also invalidated.
[[ $ZSH/completions -nt $dumpfile ]] && rm -f $dumpfile
if [[ -n $dumpfile(#qN.mh-1) ]] {
  # -C option skips the check and compaudit run
  compinit -i -C -d $dumpfile
} else {
  echo "Checking completions..."
  compinit -i -d $dumpfile
  touch $dumpfile
}

autoload -Uz bashcompinit && bashcompinit

for comp ($ZSH/bash-completions/*(N)); do
  source $comp
done
