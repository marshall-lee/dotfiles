[[ -z "$ZSH" ]] && export ZSH="$HOME/.zsh"

function my_start() {
  local -a my_sources
  local script_dir="${0:A:h}/zsh"
  my_sources=($ZSH/lib.zsh)
  if [[ -f $ZSH/pre-init.zsh ]] {
    my_sources=($my_sources $ZSH/pre-init.zsh)
  }
  # The init scripts run in the order of their numeric prefixes: (on) sorts them
  # by name.
  my_sources=($my_sources $ZSH/init/*.zsh(on))
  if [[ -f $ZSH/post-init.zsh ]] {
    my_sources=($my_sources $ZSH/post-init.zsh)
  }
  local need_compile
  if [[ -f $ZSH/my.zsh ]] {
    need_compile=false
    # The init directory itself changes when a script is added, removed or
    # renamed.
    for src in $my_sources $ZSH/init; do
      if [[ $src -nt $ZSH/my.zsh ]] {
        need_compile=true
        break
      }
    done
  } else {
    need_compile=true
  }

  local antidote_path="$HOME/.antidote"
  local antidote_enabled=false
  if [[ -d "$antidote_path" ]] {
    fpath=("$antidote_path/functions" $fpath)
    antidote_enabled=true
    autoload -Uz antidote
    zstyle ':antidote:bundle:*' zcompile 'yes'
    if [[ "$script_dir/zsh_plugins.txt" -nt "$ZSH/my.zsh" || "$antidote_path" -nt "$ZSH/my.zsh" ]] {
      need_compile=true
    }
  }

  if $need_compile; then
    echo "Compiling the my.zsh bundle..."
    if $antidote_enabled; then
      antidote bundle <"$script_dir/zsh_plugins.txt" >| "$ZSH/my.zsh"
      echo >> "$ZSH/my.zsh"
    else
      rm -f "$ZSH/my.zsh"
    fi
    cat $my_sources >> "$ZSH/my.zsh"
    zcompile "$ZSH/my.zsh"
  fi
  source "$ZSH/my.zsh"
}
my_start
