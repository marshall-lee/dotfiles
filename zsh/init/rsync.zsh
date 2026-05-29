function rsync-fswatch() {
  local src_path=$1
  local dst_path=$2
  if [[ -z $src_path || -z $dst_path ]] {
    echo "Usage: rsync-fswatch <src-path> <dst-path>" >&2
    return -1
  }
  local args=(-vrlpt "${src_path}" "${dst_path}")
  if [[ -n $SSHPORT ]] {
    args=(--rsh "ssh -p ${SSHPORT}" "${args[@]}")
  }

  # Sync all.
  rsync "${args[@]}"

  # Watch for changes & sync.
  fswatch -o ${src_path} | xargs -I{} rsync "${args[@]}"
}

function rsync-cp() {
  if (( $# < 2 )) {
    echo "Usage: rsync-cp [opt...] <src-path>... <dst-path>" >&2
    return -1
  }
  local args=(-vrlp "$@")
  if [[ -n $SSHPORT ]] {
    args=(--rsh "ssh -p ${SSHPORT}" "${args[@]}")
  }

  rsync "${args[@]}"
}
