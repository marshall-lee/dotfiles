function my_brew_init() {
  setopt local_options
  setopt extendedglob
  local brew_repo_arm=/opt/homebrew
  local brew_repo_x86=/usr/local/Homebrew
  local brew_repo
  local shellenv

  if [[ -e $brew_repo_arm/bin/brew ]] {
    # First check arm64 version of Homebrew
    brew_repo=$brew_repo_arm
    shellenv=$ZSH/cache/opt-homebrew-shellenv
    if [[ -e $brew_repo_x86/bin/brew ]] {
      alias brew-x86='arch -x86_64 /usr/local/bin/brew'
    }
  } elif [[ -e $brew_repo_x86/bin/brew ]] {
    brew_repo=$brew_repo_x86
    shellenv=$ZSH/cache/usr-local-Homebrew-shellenv
  }

  [[ -z $brew_repo ]] && return

  # Cache `brew shellenv` output.
  local shellenv_version
  local shellenv_version_file="${shellenv:h}/.${shellenv:t}-version"
  [[ -e $shellenv_version_file ]] && shellenv_version=$(<$shellenv_version_file)
  if [[ ! -e $shellenv || -n $shellenv(#qN.mh+1) ]] {
    local shellenv_new_version=$(git --work-tree $brew_repo --git-dir $brew_repo/.git rev-parse --short HEAD)
    if [[ $shellenv_new_version != $shellenv_version ]] {
      echo 'Saving brew shellenv...'
      echo $shellenv_new_version > $shellenv_version_file

      HOMEBREW_PREFIX=$($brew_repo/bin/brew --prefix)
      HOMEBREW_CELLAR=$($brew_repo/bin/brew --cellar)
      HOMEBREW_REPOSITORY=$($brew_repo/bin/brew --repository)
      echo "export HOMEBREW_PREFIX=\"$HOMEBREW_PREFIX\"" > $shellenv
      echo "export HOMEBREW_CELLAR=\"$HOMEBREW_CELLAR\"" >> $shellenv
      echo "export HOMEBREW_REPOSITORY=\"$HOMEBREW_REPOSITORY\"" >> $shellenv
      echo "export PATH=\"$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin\${PATH+:\$PATH}\"" >> $shellenv
      echo "export MANPATH=\"$HOMEBREW_PREFIX/share/man\${MANPATH+:\$MANPATH}:\"" >> $shellenv
      echo "export INFOPATH=\"$HOMEBREW_PREFIX/share/info:\${INFOPATH:-}\"" >> $shellenv
    }
  }

  source $shellenv

  # Track pre-installed completions for compinit caching if they exist in the $fpath.
  local site_functions=$HOMEBREW_PREFIX/share/zsh/site-functions
  [[ -n ${fpath[(r)$site_functions]} ]] && my_add_comp_path $site_functions
}

function brew-use-keg() {
  if [[ -z $HOMEBREW_PREFIX ]] {
    echo 'No Homebrew installation found'
    return 1
  }

  local dir=$HOMEBREW_PREFIX/opt/$1
  if [[ -d $dir ]] {
    if [[ -d $dir/bin ]] {
      path=($dir/bin $path)
    }
    if [[ -d $dir/sbin ]] {
      path=($dir/sbin $path)
    }
  } else {
    echo "no such directory $dir"
    return 1
  }
}

function brew-use-keg-dev() {
  if [[ -z $HOMEBREW_PREFIX ]] {
    echo 'No Homebrew installation found'
    return 1
  }

  local dir=$HOMEBREW_PREFIX/opt/$1
  if [[ -d $dir ]] {
    if [[ -d $dir/lib ]] {
      export LDFLAGS="-L$dir/lib $LDFLAGS"
    }
    if [[ -d $dir/include ]] {
      export CPPFLAGS="-I$dir/include $CPPFLAGS"
    }
    if [[ -d $dir/lib/pkgconfig ]] {
      local pkg_configs=(${(s/:/)PKG_CONFIG_PATH})
      pkg_configs=($dir/lib/pkgconfig $PKG_CONFIG_PATH)
      export PKG_CONFIG_PATH=${(j/:/)pkg_configs}
    }
  } else {
    echo "no such directory $dir"
    return 1
  }
}

my_brew_init
