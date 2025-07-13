#!/bin/bash

# Script to configure fail2ban on Raspberry Pi for SSH protection
# This script runs on the host and executes the configuration on the Pi via SSH

set -e

# SSH Config
KEY="../ssh_keys/pi_ssh_key"
USER="pi"
HOST="192.168.188.2"
PORT=22

echo "Starting fail2ban configuration on Raspberry Pi..."

# Check if SSH key exists
if [ ! -f "$KEY" ]; then
    echo "Error: SSH key '$KEY' not found"
    exit 1
fi

# Execute fail2ban configuration remotely
ssh -i "$KEY" -p "$PORT" "$USER@$HOST" "sudo bash -s" <<'EOF'
set -e

echo "Configuring fail2ban for SSH protection..."

# Create fail2ban local configuration for SSH
cat > /etc/fail2ban/jail.local << 'FAIL2BAN_CONFIG'
[DEFAULT]
# Ban hosts for 1 hour (3600 seconds)
bantime = 3600

# A host is banned if it has generated "maxretry" during the last "findtime" seconds
findtime = 600

# Number of failures before a host get banned
maxretry = 5

# Destination email for notifications (optional)
# destemail = your-email@domain.com

# Sender email (optional)
# sender = fail2ban@yourdomain.com

# Email actions (optional)
# action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
filter = sshd[mode=aggressive]
backend = systemd
journalmatch = _SYSTEMD_UNIT=ssh.service
maxretry = 5
bantime = 3600
findtime = 600


FAIL2BAN_CONFIG

# Configure automatic fail2ban start
systemctl enable fail2ban
systemctl restart fail2ban

# Wait for fail2ban to start
sleep 3

echo "✅ fail2ban configuration completed!"
echo ""
echo "Configuration summary:"
echo "- SSH max authentication attempts: 5"
echo "- Ban time: 1 hour (3600 seconds)"
echo "- Find time: 10 minutes (600 seconds)"
echo ""
echo "Checking fail2ban status..."
fail2ban-client status
EOF

echo "✅ fail2ban configuration completed successfully!"
echo ""
echo "To check fail2ban status: ssh -i $KEY -p $PORT $USER@$HOST 'sudo fail2ban-client status'"
echo "To check banned IPs: ssh -i $KEY -p $PORT $USER@$HOST 'sudo fail2ban-client status sshd'"
echo "To unban an IP: ssh -i $KEY -p $PORT $USER@$HOST 'sudo fail2ban-client set sshd unbanip <IP>'"
