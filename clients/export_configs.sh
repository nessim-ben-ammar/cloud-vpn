#!/bin/bash
# Download all client configuration files from the VPN server

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"

DEST="exported_configs"
mkdir -p "$DEST"

scp -i "$SSH_KEY" -r $SERVER:/etc/wireguard/clients "$DEST" || exit 1

echo "Client configurations copied to $DEST/"

