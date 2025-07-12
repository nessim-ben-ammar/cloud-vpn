#!/bin/bash

# Restore /etc/wireguard from an S3 bucket onto the new server

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"

if [ -z "$1" ]; then
  echo "Usage: $0 <s3-bucket-name>"
  exit 1
fi

BUCKET="$1"

aws s3 cp "s3://$BUCKET/wireguard-config.tar.gz" wireguard-config.tar.gz || exit 1

scp -i "$SSH_KEY" wireguard-config.tar.gz $SERVER:/tmp/
ssh -i "$SSH_KEY" $SERVER "sudo tar -xzf /tmp/wireguard-config.tar.gz -C / && rm /tmp/wireguard-config.tar.gz && systemctl restart wg-quick@wg0"

rm wireguard-config.tar.gz

echo "Configuration restored and WireGuard restarted"

