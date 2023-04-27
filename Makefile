.PHONY: install configure uninstall

install:
	@cp sync-folders.sh /usr/bin/ssh-sync-folders
	@chmod +x /usr/bin/ssh-sync-folders
	@echo "Installed ssh-sync-folders to /usr/bin/"

configure:
	@read -p "Enter local directory (default: current directory): " local_dir; \
	read -p "Enter remote SSH user: " remote_user; \
	read -p "Enter remote SSH password (optional): " remote_pass; \
	read -p "Enter remote SSH host: " remote_host; \
	read -p "Enter remote directory (default: /shared): " remote_dir; \
	read -p "Enter comma-separated exclude patterns (optional): " exclude_patterns; \
	echo "export SSH_SYNC_LOCAL_DIR=$$local_dir" >> ~/.bashrc; \
	echo "export SSH_SYNC_REMOTE_USER=$$remote_user" >> ~/.bashrc; \
	echo "export SSH_SYNC_REMOTE_PASS=$$remote_pass" >> ~/.bashrc; \
	echo "export SSH_SYNC_REMOTE_HOST=$$remote_host" >> ~/.bashrc; \
	echo "export SSH_SYNC_REMOTE_DIR=$$remote_dir" >> ~/.bashrc; \
	echo "export SSH_SYNC_EXCLUDE_PATTERNS=$$exclude_patterns" >> ~/.bashrc; \
	exec bash; \
	echo "Configuration updated. Restart your terminal to apply the changes."

uninstall:
	@rm -f /usr/bin/ssh-sync-folders
	@echo "Uninstalled ssh-sync-folders from /usr/bin/"

