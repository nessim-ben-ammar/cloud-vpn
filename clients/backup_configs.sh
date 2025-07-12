#!/bin/bash

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"

DEST="backups"
mkdir -p "$DEST"
BACKUP_NAME="wireguard_backup_$(date +%Y%m%d%H%M%S).tar.gz"

ssh -i "$SSH_KEY" $SERVER "sudo tar -czf /tmp/$BACKUP_NAME -C / etc/wireguard && sudo chmod 644 /tmp/$BACKUP_NAME"
scp -i "$SSH_KEY" $SERVER:/tmp/$BACKUP_NAME "$DEST/" || exit 1
ssh -i "$SSH_KEY" $SERVER "sudo rm -f /tmp/$BACKUP_NAME"

echo "Backup stored at $DEST/$BACKUP_NAME"
