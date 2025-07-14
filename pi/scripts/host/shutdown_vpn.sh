#!/bin/bash

# HOST SCRIPT - Shutdown VPN on Pi remotely
# This script runs ON the HOST to shutdown VPN on Pi
# Usage: ./shutdown_vpn_remote.sh

set -e

# Check if we're accidentally running on Pi
if [ -f /proc/device-tree/model ] && grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo "❌ ERROR: This script should run on the HOST, not on the Pi!"
    echo "You're currently on a Raspberry Pi. Please run this script from your host machine."
    exit 1
fi

# Source centralized configuration
if [ -f "../config.sh" ]; then
    source "../config.sh"
    KEY="$SSH_KEY"
    USER="$SSH_USER"
    HOST="$SSH_HOST"
    PORT="$SSH_PORT"
else
    echo "❌ Configuration file '../config.sh' not found"
    echo "Please make sure config.sh exists in the scripts directory"
    exit 1
fi

echo "🔧 Shutting down VPN on Pi remotely..."
echo "======================================"
echo ""

# Check SSH connectivity
echo "🔧 Checking SSH connection to Pi..."
if [ ! -f "$KEY" ]; then
    echo "❌ SSH key '$KEY' not found"
    exit 1
fi

if ! ssh -i "$KEY" -p "$PORT" -o ConnectTimeout=5 -o BatchMode=yes "$USER@$HOST" exit 2>/dev/null; then
    echo "❌ Cannot connect to Pi at $HOST"
    exit 1
fi
echo "✅ SSH connection successful"
echo ""

# Execute shutdown on Pi
echo "🔧 Executing VPN shutdown on Pi..."
echo ""
ssh -i "$KEY" -p "$PORT" "$USER@$HOST" "cd ~/scripts && sudo bash shutdown_vpn.sh"

echo ""
echo "✅ VPN shutdown completed successfully!"
echo ""
echo "The VPN is now disabled on the Pi."
echo ""
echo "To re-enable the VPN, run:"
echo "  ./deploy_to_pi.sh"
echo "or manually on the Pi:"
echo "  sudo systemctl start wg-quick@wg0"
echo "  sudo systemctl enable wg-quick@wg0"
