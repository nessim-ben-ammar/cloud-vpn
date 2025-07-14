#!/bin/bash

# Script to configure fail2ban on Raspberry Pi for SSH protection
# This script runs ON the Pi (called by orchestrator)

set -e

# Check if we're running on a Pi
if [ ! -f /proc/device-tree/model ] || ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo "❌ ERROR: This script should run on a Raspberry Pi!"
    echo "You're currently on a different system. Please run this script on the Pi."
    exit 1
fi

# Source centralized configuration
if [ -f "config.sh" ]; then
    source "config.sh"
else
    echo "❌ Configuration file 'config.sh' not found"
    echo "Please make sure config.sh exists in the current directory"
    exit 1
fi

echo "Configuring fail2ban for SSH protection..."

# Create fail2ban local configuration for SSH
cat > /etc/fail2ban/jail.local << FAIL2BAN_CONFIG
[DEFAULT]
# Ban hosts for $FAIL2BAN_BANTIME seconds
bantime = $FAIL2BAN_BANTIME

# A host is banned if it has generated "maxretry" during the last "findtime" seconds
findtime = $FAIL2BAN_FINDTIME

# Number of failures before a host get banned
maxretry = $FAIL2BAN_MAXRETRY

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
maxretry = $FAIL2BAN_MAXRETRY
bantime = $FAIL2BAN_BANTIME
findtime = $FAIL2BAN_FINDTIME


FAIL2BAN_CONFIG

# Configure automatic fail2ban start
systemctl enable fail2ban
systemctl restart fail2ban

# Wait for fail2ban to start
sleep 3

echo "✅ fail2ban configuration completed!"
echo ""
echo "Configuration summary:"
echo "- SSH max authentication attempts: $FAIL2BAN_MAXRETRY"
echo "- Ban time: $FAIL2BAN_BANTIME seconds"
echo "- Find time: $FAIL2BAN_FINDTIME seconds"
echo ""
echo "Checking fail2ban status..."
fail2ban-client status
