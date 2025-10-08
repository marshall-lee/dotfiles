function rsync-fswatch() {
  local src_path=$1
  local dst_path=$2
  if [[ -z $src_path || -z $dst_path ]] {
    echo "Usage: rsync-fswatch <src-path> <dst-path>" >&2
    return -1
  }
  # Sync all.
  rsync -vrlpt ${src_path} ${dst_path}

  # Watch for changes & sync.
  fswatch -o ${src_path} | xargs -I{} rsync -vrlpt ${src_path} ${dst_path}
}

function rsync-cp() {
  if (( $# < 2 )) {
    echo "Usage: rsync-cp [opt...] <src-path>... <dst-path>" >&2
    return -1
  }

  rsync -vrlp "$@"
}
