function my_cargo_init() {
  local cargo_env=$HOME/.cargo/env
  [[ -f $cargo_env ]] && source $cargo_env

  local cargo_bin_dir=$HOME/.cargo/bin
  [[ -d $cargo_bin_dir ]] && path=($cargo_bin_dir $path)
}

function my_rustup_init() {
  setopt local_options
  setopt extendedglob
  local rustup_completions=$ZSH/completions/_rustup
  local cargo_completions=$ZSH/completions/_cargo
  if (( ${+commands[rustup]} )) {
    [[ ! -e $rustup_completions ]] && rustup completions zsh rustup > $rustup_completions
    if [[ -z $cargo_completions(#qN@mh-1) ]] && (( ${+commands[rustc]} )) {
      rm -f $cargo_completions
      ln -s $(rustc --print sysroot)/share/zsh/site-functions/_cargo $cargo_completions
    }
  } elif [[ -e $rustup_completions ]] {
    rm -f $rustup_completions
    rm -f $cargo_completions
    [[ -d $HOME/.rustup ]] && rm -rf $HOME/.rustup
  }
}

my_cargo_init
my_rustup_init
