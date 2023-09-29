function git-remote-head() {
  local remote=${1:-origin}
  local symref=refs/remotes/${remote}/HEAD
  local ref=$(git symbolic-ref ${symref} | sed "s@^refs/remotes/${remote}/@@")
  if [[ -z $ref ]] {
    # Query the remote HEAD
    echo "Failed to get ${symref} symbolic ref, trying to query the ${remote} HEAD" >&2
    ref=$(git remote set-head $remote --auto | sed "s@^${remote}/HEAD set to @@")
  }
  [[ -z $ref ]] && return -1
  echo $ref
}

function git-branch-delete-merged() {
  local remote=${1:-origin}

  local head=$(git-remote-head ${remote})
  [[ -z $head ]] && return -1

  local current=$(git branch --show-current)
  [[ -z $current ]] && return -1

  local branches=$(git branch --format='%(refname:short)' --merged ${remote}/${head} | grep -v -e "^${head}$" -e "^${current}$")
  [[ -z $branches ]] && return 0

  if [[ -o interactive ]] {
    local answer
    echo "The following branches are gonna be removed:\n${branches}\n"
    read -q "answer?Are you sure?"
    [[ $answer == n ]] && return -1
  }

  echo
  echo ${branches} | xargs -I{} git branch -d {}
}

function git-branch-delete-gone() {
  local current=$(git branch --show-current)
  [[ -z $current ]] && return -1

  local branches=$(git branch --format='%(upstream:track)%(refname:short)' | grep -e "^\[gone\]" | sed "s/^\[gone\]//" | grep -v -e "^${current}$")
  [[ -z $branches ]] && return 0

  if [[ -o interactive ]] {
    local answer
    echo "The following branches are gonna be removed:\n${branches}\n"
    read -q "answer?Are you sure?"
    [[ $answer == n ]] && return -1
  }

  echo
  echo ${branches} | xargs -I{} git branch -D {}
}
