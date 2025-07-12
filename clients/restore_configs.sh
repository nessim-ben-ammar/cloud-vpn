#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file>"
  exit 1
fi

BACKUP_FILE="$1"
SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"

scp -i "$SSH_KEY" "$BACKUP_FILE" $SERVER:/tmp/wireguard_backup.tar.gz || exit 1
ssh -i "$SSH_KEY" $SERVER "sudo tar -xzf /tmp/wireguard_backup.tar.gz -C / && sudo rm /tmp/wireguard_backup.tar.gz && sudo systemctl restart wg-quick@wg0"

echo "Configuration restored from $BACKUP_FILE"
