#!/bin/bash

# Archive all client configuration files from the server and copy them locally.

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"
ARCHIVE="wireguard-backup.tar.gz"

# Create archive on the server containing entire /etc/wireguard directory
ssh -i "$SSH_KEY" "$SERVER" "sudo tar -czf /tmp/$ARCHIVE -C /etc wireguard"

# Download the archive to the current directory
scp -i "$SSH_KEY" "$SERVER:/tmp/$ARCHIVE" .

# Remove the temporary archive on the server
ssh -i "$SSH_KEY" "$SERVER" "sudo rm -f /tmp/$ARCHIVE"

echo "WireGuard configuration archived to $ARCHIVE"

