function rsync-fswatch() {
  local local_path=$1
  local remote_path=$2
  if [[ -z $local_path || -z $remote_path ]] {
    echo "Usage: rsync-fswatch <local-path> <remote-path>" >&2
    return -1
  }
  # Sync all.
  rsync --delete -vrlpt ${local_path} ${remote_path}

  # Watch for changes & sync.
  fswatch -o ${local_path} | xargs -I{} rsync --delete -vrlpt ${local_path} ${remote_path}
}

function rsync-cp() {
  local local_path=$1
  local remote_path=$2
  if [[ -z $local_path || -z $remote_path ]] {
    echo "Usage: rsync-cp <local-path> <remote-path>" >&2
    return -1
  }

  rsync -vrlp ${local_path} ${remote_path}
}
