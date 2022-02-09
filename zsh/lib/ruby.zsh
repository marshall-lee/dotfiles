alias rb="ruby"
function bundle-install {
  local root=`git rev-parse --show-toplevel`
  bundle config --local path "$root/vendor/bundle"
  bundle config --local bin "$root/.bundle/bin"
  bundle install
}
