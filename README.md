## Description

A simple Bash script to sync a local directory with a remote directory over SSH using rsync and inotifywait. 

The script sets up file watches on the local directory and automatically syncs any changes to the remote directory. 
If the initial sync fails due to permission issues or other errors, the script will not set up watches and will exit.

## Usage

```bash
./sync-folders.sh [OPTIONS]
```

### Options

- `-l`, --local-dir=DIR: Local directory to be synced (default: current directory)
- `-u`, --remote-user=USER: Remote SSH user
- `-p`, --remote-pass=PASSWORD: Remote SSH password (optional)
- `-h`, --remote-host=HOST: Remote SSH host
- `-d`, --remote-dir=DIR: Remote directory to sync to (default: /shared)
- `-e`, --exclude=PATTERNS: Comma-separated list of file/folder patterns to exclude
- `--help`: Show help message and exit

You can also set the following environment variables instead of providing the options via command line arguments:

- `SSH_SYNC_LOCAL_DIR`: Local directory to be synced
- `SSH_SYNC_REMOTE_USER`: Remote SSH user
- `SSH_SYNC_REMOTE_PASS`: Remote SSH password (optional if using RSA keys)
- `SSH_SYNC_REMOTE_HOST`: Remote SSH host
- `SSH_SYNC_REMOTE_DIR`: Remote directory to sync to
- `SSH_SYNC_EXCLUDE_PATTERNS`: Comma-separated list of file/folder patterns to exclude

## Dependencies

- `rsync`
- `inotify-tools`
- `sshpass` (optional, required if using a remote password)

## Installation

A Makefile is included for easy installation and uninstallation. 

To install the script, simply run:

```bash
make install
```

This will copy the script to `/usr/bin` and make it executable. 

To uninstall the script, run:

```bash
make uninstall
```

## Example

```bash
./sync-folders.sh -l /path/to/local/dir -u remote_user -h remote_host -d /path/to/remote/dir -e ".git,*.log"
```

This command will sync `/path/to/local/dir` to `/path/to/remote/dir` on the remote host, excluding any `.git` directories and `*.log` files. 
The local directory will be watched for changes, and any modifications will be synced to the remote directory automatically.


