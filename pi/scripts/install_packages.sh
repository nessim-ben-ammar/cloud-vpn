#!/bin/bash

# Script to install necessary packages on Raspberry Pi for VPN client functionality
# This script runs on the host and executes the installation on the Pi via SSH

set -e

# SSH Config
KEY="../ssh_keys/pi_ssh_key"
USER="pi"
HOST="192.168.188.2"
PORT=22

echo "Starting remote package installation on Raspberry Pi..."

# Check if SSH key exists
if [ ! -f "$KEY" ]; then
    echo "Error: SSH key '$KEY' not found"
    exit 1
fi

# Execute installation commands remotely
ssh -i "$KEY" -p "$PORT" "$USER@$HOST" "sudo bash -s" <<'EOF'
set -e

echo "Starting package installation on Raspberry Pi..."

# Update package lists
echo "Updating package lists..."
apt update

# Upgrade existing packages
echo "Upgrading existing packages..."
apt upgrade -y

# Install essential packages for VPN client functionality
echo "🔧 Installing packages..."
apt install -y \
    wireguard \
    iptables-persistent \
    fail2ban

# Clean up
echo "🧹 Cleaning up..."
apt autoremove -y
apt autoclean

echo "✅ Package installation completed successfully!"
EOF

echo "Remote installation completed!"