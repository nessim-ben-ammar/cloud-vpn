#!/bin/bash

# Upload previously archived client configuration files to the server.
# Usage: restore_configs.sh [archive]

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/oci-instance-ssh-key"
ARCHIVE="${1:-wireguard-backup.tar.gz}"

if [ ! -f "$ARCHIVE" ]; then
  echo "Archive $ARCHIVE not found"
  exit 1
fi

# Copy archive to the server
scp -i "$SSH_KEY" "$ARCHIVE" "$SERVER:/tmp/"

BASENAME=$(basename "$ARCHIVE")
# Extract archive on the server and restart WireGuard
ssh -i "$SSH_KEY" "$SERVER" "sudo tar -xzf /tmp/$BASENAME -C /etc && sudo rm /tmp/$BASENAME && sudo systemctl restart wg-quick@wg0"

echo "WireGuard configuration restored from $ARCHIVE"

