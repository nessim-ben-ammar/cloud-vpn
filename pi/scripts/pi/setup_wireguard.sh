#!/bin/bash

# Script to setup WireGuard on Raspberry Pi
# This script runs ON the Pi (called by orchestrator)
# Expects config file to be at /etc/wireguard/wg0.conf

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

# Check if configuration file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <config-file>"
    echo "Example: $0 $WG_CONFIG_FILE"
    exit 1
fi

CONFIG_FILE="$1"

echo "Setting up WireGuard on Raspberry Pi..."

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found"
    exit 1
fi

echo "Using configuration file: $CONFIG_FILE"
echo "Configuring WireGuard..."

# Define paths
WG_CONF="/etc/wireguard/$WG_INTERFACE.conf"

# Create WireGuard directory and install configuration
mkdir -p /etc/wireguard
install -m 600 "$CONFIG_FILE" "$WG_CONF"

# Enable and start WireGuard service
systemctl enable wg-quick@$WG_INTERFACE
systemctl start wg-quick@$WG_INTERFACE

echo "✅ WireGuard setup completed!"
echo ""
echo "WireGuard status:"
wg show
