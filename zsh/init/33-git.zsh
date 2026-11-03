function git-remote-head() {
  local remote=${1:-$(git for-each-ref --format='%(upstream:remotename)' $(git symbolic-ref -q HEAD))}
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
  local remote=${1:-$(git for-each-ref --format='%(upstream:remotename)' $(git symbolic-ref -q HEAD))}

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

  local remotes=($(git branch --format='%(upstream:remotename)' | sort | uniq))
  git fetch --multiple -v --prune ${remotes}

  local branches=$(LC_ALL=C git branch --format='%(upstream:track)%(refname:short)' | grep -e "^\[gone\]" | sed "s/^\[gone\]//" | grep -v -e "^${current}$")
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

function git-submodule-update-hack() {
  local pathspec=$1
  [[ -z ${pathspec} ]] && return -1

  local sha1=$2
  [[ -z ${sha1} ]] && return -1

  git diff --quiet --exit-code ${pathspec}
  if (( $? )) {
    echo "You've got some changes at '${pathspec}' in the worktree. See git diff '${pathspec}'."
    return -1
  }

  git diff --quiet --cached --exit-code ${pathspec}
  if (( $? )) {
    echo "You've got some changes at '${pathspec}' in the index. See git diff --cached '${pathspec}'."
    return -1
  }

  git update-index --cacheinfo 160000 ${sha1} ${pathspec}
  (( $? )) && return -1

  git diff --quiet --exit-code ${pathspec}
  if (( $? )) {
    local answer
    read -q "answer?Do you want to deinit the '${pathspec}' submodule?"
    if [[ ${answer} == y ]] {
      git submodule deinit -f ${pathspec}
      (( $? )) && return -1
    }
  }
}
