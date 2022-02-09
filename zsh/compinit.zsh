autoload -Uz compinit
setopt local_options
setopt extendedglob

local dumpfile=$ZSH/cache/zcompdump

# Cache compinit check result for 1 hour.
# If there're some changes in completions folder then cache is also invalidated.
if [[ -n $dumpfile(#qN.mh-1) ]] && [[ ! $ZSH/completions -nt $dumpfile ]] {
  # -C option skips the check and compaudit run
  compinit -C -d $dumpfile
} else {
  echo "Checking completions..."
  compinit -i -d $dumpfile
  touch $dumpfile
}
