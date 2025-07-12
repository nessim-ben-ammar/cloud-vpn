#!/bin/bash

# Backup /etc/wireguard from the server to an S3 bucket

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"

if [ -z "$1" ]; then
  echo "Usage: $0 <s3-bucket-name>"
  exit 1
fi

BUCKET="$1"
TMP_DIR=$(mktemp -d)

# Copy configuration from server
scp -i "$SSH_KEY" -r $SERVER:/etc/wireguard "$TMP_DIR" || exit 1

tar -czf wireguard-config.tar.gz -C "$TMP_DIR" wireguard
aws s3 cp wireguard-config.tar.gz "s3://$BUCKET/" --sse AES256

rm -rf "$TMP_DIR" wireguard-config.tar.gz

echo "Backup uploaded to s3://$BUCKET/"

