#!/bin/bash

sync_directories() {
  if [ -z "${REMOTE_PASS}" ]; then
    rsync -avz --delete --exclude-from="${EXCLUDE_FILE}" -e "ssh" "$LOCAL_DIR" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
  else
    sshpass -p "${REMOTE_PASS}" rsync -avz --delete --exclude-from="${EXCLUDE_FILE}" -e "ssh" "$LOCAL_DIR" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
  fi
}

show_help() {
  cat <<- EOF
Usage: ssh-sync-folders [OPTIONS]

Options:
  -l, --local-dir=DIR           Local directory to be synced (default: current directory)
  -u, --remote-user=USER        Remote SSH user
  -p, --remote-pass=PASSWORD    Remote SSH password (optional)
  -h, --remote-host=HOST        Remote SSH host
  -d, --remote-dir=DIR          Remote directory to sync to (default: /shared)
  -e, --exclude=PATTERNS        Comma-separated list of file/folder patterns to exclude
  --help                        Show this help message and exit

EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -l|--local-dir=*)
      LOCAL_DIR="${1#*=}"
      shift
      ;;
    -u|--remote-user=*)
      REMOTE_USER="${1#*=}"
      shift
      ;;
    -p|--remote-pass=*)
      REMOTE_PASS="${1#*=}"
      shift
      ;;
    -h|--remote-host=*)
      REMOTE_HOST="${1#*=}"
      shift
      ;;
    -d|--remote-dir=*)
      REMOTE_DIR="${1#*=}"
      shift
      ;;
    -e|--exclude=*)
      EXCLUDE_PATTERNS="${1#*=}"
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Invalid option: ${1}. Run with --help for usage information." >&2
      exit 1
      ;;
  esac
  shift
done

LOCAL_DIR=${LOCAL_DIR:-${SSH_SYNC_LOCAL_DIR:-$PWD}}
REMOTE_USER=${REMOTE_USER:-${SSH_SYNC_REMOTE_USER}}
REMOTE_PASS=${REMOTE_PASS:-${SSH_SYNC_REMOTE_PASS}}
REMOTE_HOST=${REMOTE_HOST:-${SSH_SYNC_REMOTE_HOST}}
REMOTE_DIR=${REMOTE_DIR:-${SSH_SYNC_REMOTE_DIR:-/ssh-sync}}

EXCLUDE_FILE=$(mktemp)
IFS=',' read -ra EXCLUDE_PATTERNS_ARRAY <<< "${EXCLUDE_PATTERNS:-${SSH_SYNC_EXCLUDE_PATTERNS}}"
for pattern in "${EXCLUDE_PATTERNS_ARRAY[@]}"; do
  echo "${pattern}" >> "${EXCLUDE_FILE}"
done

if [ -z "${LOCAL_DIR}" ] || [ -z "${REMOTE_USER}" ] || [ -z "${REMOTE_HOST}" ]; then
  echo "All arguments or environment variables (except remote directory, remote password, and exclude patterns) are required." >&2
  exit 1
fi

echo "Running initial sync, local dir: $LOCAL_DIR; remote dir: $REMOTE_DIR"
sync_directories
sync_result=$?

if [ $sync_result -ne 0 ]; then
  echo "Initial sync failed. Exiting."
  exit 1
fi

echo "Initial sync done."

echo "[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]"
while inotifywait -r -e modify,create,delete,move "${LOCAL_DIR}"; do
  sync_directories
done

rm "${EXCLUDE_FILE}"
