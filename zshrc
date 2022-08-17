[[ -z "$ZSH" ]] && export ZSH="$HOME/.zsh"

function my_start() {
  local my_sources=($ZSH/lib.zsh)
  if [[ -f $ZSH/pre-init.zsh ]] {
    my_sources=($my_sources $ZSH/pre-init.zsh)
  }
  my_sources=($my_sources
    $ZSH/brew.zsh
    $ZSH/init/*.zsh
    $ZSH/compinit.zsh
    $ZSH/prompt.zsh
  )
  if [[ -f $ZSH/post-init.zsh ]] {
    my_sources=($my_sources $ZSH/post-init.zsh)
  }
  local need_compile
  if [[ -f $ZSH/my.zsh ]] {
    need_compile=false
    for src in $my_sources; do
      if [[ $src -nt $ZSH/my.zsh ]] {
        need_compile=true
        break
      }
    done
  } else {
    need_compile=true
  }
  if $need_compile; then
    echo "Compiling the sources..."
    cat $my_sources > $ZSH/my.zsh
    zcompile $ZSH/my.zsh
  fi
  source $ZSH/my.zsh
}
my_start
