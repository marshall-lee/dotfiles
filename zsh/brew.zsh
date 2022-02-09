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

if [[ ! $brew_repo ]] {
  return
}

# Cache `brew shellenv` output.
shellenv=$shellenv-$(git --work-tree $brew_repo --git-dir $brew_repo/.git rev-parse --short HEAD)
if [[ ! -e $shellenv ]] {
  echo 'Saving brew shellenv...'
  $brew_repo/bin/brew shellenv > $shellenv
}

source $shellenv

local zsh_completions=$HOMEBREW_PREFIX/share/zsh/site-functions
if [[ -d $zsh_completions ]] {
  chmod -R 755 $zsh_completions
  fpath=($zsh_completions $fpath)
}

function brew-use-keg() {
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
