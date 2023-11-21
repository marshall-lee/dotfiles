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
  if [[ -z $shellenv(#qN.mh-1) ]] {
    local shellenv_version_line= shellenv_version=
    if [[ -e $shellenv ]] {
      shellenv_version_line=$(head -n 1 $shellenv)
      shellenv_version=${shellenv_version_line/#\# /}
    }
    local shellenv_new_version=$(git --work-tree $brew_repo --git-dir $brew_repo/.git rev-parse --short HEAD)
    if [[ $shellenv_new_version != $shellenv_version ]] {
      echo "Saving brew shellenv... version=${shellenv_new_version}"

      echo "# $shellenv_new_version" > $shellenv
      PATH=/usr/bin:/bin:/usr/sbin:/sbin $brew_repo/bin/brew shellenv >> $shellenv
      zcompile $shellenv
    } else {
      touch $shellenv
    }
  }

  source $shellenv
  typeset -Ux path # Remove duplicate /usr/local/{bin,sbin} entries

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
      echo "LDFLAGS=-L$dir/lib $LDFLAGS"
    }
    if [[ -d $dir/include ]] {
      export CPPFLAGS="-I$dir/include $CPPFLAGS"
      echo "CPPFLAGS=-I$dir/include $CPPFLAGS"
    }
    if [[ -d $dir/lib/pkgconfig ]] {
      local pkg_configs=(${(s/:/)PKG_CONFIG_PATH})
      pkg_configs=($dir/lib/pkgconfig $PKG_CONFIG_PATH)
      local pkg_config_path=${(j/:/)pkg_configs}
      export PKG_CONFIG_PATH=$pkg_config_path
      echo "PKG_CONFIG_PATH=$pkg_config_path"
    }
  } else {
    echo "no such directory $dir"
    return 1
  }
}

function brew-x86-use-keg-dev() {
  if [[ ! -d /usr/local/Homebrew ]] {
    echo 'No x86_64 Homebrew installation found'
    return 1
  }

  local dir=/usr/local/opt/$1
  if [[ -d $dir ]] {
    if [[ -d $dir/lib ]] {
      export LDFLAGS="-L$dir/lib $LDFLAGS"
      echo "LDFLAGS=-L$dir/lib $LDFLAGS"
    }
    if [[ -d $dir/include ]] {
      export CPPFLAGS="-I$dir/include $CPPFLAGS"
      echo "CPPFLAGS=-I$dir/include $CPPFLAGS"
    }
    if [[ -d $dir/lib/pkgconfig ]] {
      local pkg_configs=(${(s/:/)PKG_CONFIG_PATH})
      pkg_configs=($dir/lib/pkgconfig $PKG_CONFIG_PATH)
      local pkg_config_path=${(j/:/)pkg_configs}
      export PKG_CONFIG_PATH=$pkg_config_path
      echo "PKG_CONFIG_PATH=$pkg_config_path"
    }
  } else {
    echo "no such directory $dir"
    return 1
  }
}

my_brew_init
