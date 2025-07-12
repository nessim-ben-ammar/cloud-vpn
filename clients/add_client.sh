#!/bin/bash

SERVER_IP=$(terraform -chdir=../iac output -raw instance_public_ip)
SERVER="ubuntu@$SERVER_IP"
SSH_KEY="../iac/ssh_keys/aws-instance-ssh-key"

if [ -z "$1" ]; then
  echo "Usage: $0 <client-name>"
  exit 1
fi

CLIENT_NAME="$1"

# Execute everything remotely over SSH
ssh -i "$SSH_KEY" $SERVER "sudo bash -s" <<EOF
set -e
CLIENT_NAME="$CLIENT_NAME"
SERVER_PUBLIC_IP="$SERVER_IP"

cd /etc/wireguard
mkdir -p clients/\$CLIENT_NAME
cd clients/\$CLIENT_NAME
umask 077

# Generate key pair
wg genkey | tee \${CLIENT_NAME}_private.key | wg pubkey > \${CLIENT_NAME}_public.key
CLIENT_PRIV=\$(cat \${CLIENT_NAME}_private.key)
CLIENT_PUB=\$(cat \${CLIENT_NAME}_public.key)

# Detect server public key
SERVER_PUB=\$(wg show wg0 public-key)

# Determine next available IP in 192.168.2.x
USED_IPS=\$(grep -oP 'AllowedIPs\s*=\s*\K[0-9.]+' /etc/wireguard/wg0.conf | cut -d. -f4 | sort -n)
NEXT=2
for ip in \$USED_IPS; do
  if [ "\$ip" -eq "\$NEXT" ]; then
    NEXT=\$((NEXT + 1))
  else
    break
  fi
done
CLIENT_IP="192.168.2.\$NEXT"

# Create client config
cat > \${CLIENT_NAME}.conf <<EOC
[Interface]
PrivateKey = \$CLIENT_PRIV
Address = \$CLIENT_IP/32
DNS = 192.168.2.1

[Peer]
PublicKey = \$SERVER_PUB
Endpoint = \$SERVER_PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOC

# Add peer to server config (if not present)
grep -q \$CLIENT_PUB /etc/wireguard/wg0.conf || echo "
[Peer]
PublicKey = \$CLIENT_PUB
AllowedIPs = \$CLIENT_IP/32
" >> /etc/wireguard/wg0.conf

# Restart WireGuard
systemctl restart wg-quick@wg0

# Generate QR code
qrencode -t ansiutf8 < \${CLIENT_NAME}.conf

# Make config readable by ubuntu user for scp
chmod 644 \${CLIENT_NAME}.conf

# Copy config to ubuntu user's home directory for scp access
cp \${CLIENT_NAME}.conf /home/ubuntu/\${CLIENT_NAME}.conf
chown ubuntu:ubuntu /home/ubuntu/\${CLIENT_NAME}.conf
EOF

# Copy config back to host
scp -i "$SSH_KEY" $SERVER:/home/ubuntu/${CLIENT_NAME}.conf .

# Clean up temporary file on server
ssh -i "$SSH_KEY" $SERVER "rm -f /home/ubuntu/${CLIENT_NAME}.conf"
cd