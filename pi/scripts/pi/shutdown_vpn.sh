#!/bin/bash

# PI SCRIPT - Shutdown VPN on Pi
# This script runs ON the PI to shutdown the VPN
# Usage: sudo ./shutdown_vpn.sh

set -e

# Check if we're running on a Pi
if [ ! -f /proc/device-tree/model ] || ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo "❌ ERROR: This script should run on a Raspberry Pi!"
    echo "You're currently on a different system. Please run this script on the Pi."
    exit 1
fi

# Check if we're running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ ERROR: This script must be run as root (with sudo)"
    echo "Usage: sudo ./shutdown_vpn.sh"
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

echo "🔧 Shutting down VPN on Pi..."
echo "=============================="
echo ""

# Check if WireGuard service is running
if systemctl is-active --quiet wg-quick@$WG_INTERFACE; then
    echo "🔧 Stopping WireGuard service..."
    systemctl stop wg-quick@$WG_INTERFACE
    echo "✅ WireGuard service stopped"
else
    echo "ℹ️  WireGuard service is not running"
fi

# Check if WireGuard service is enabled
if systemctl is-enabled --quiet wg-quick@$WG_INTERFACE; then
    echo "🔧 Disabling WireGuard service..."
    systemctl disable wg-quick@$WG_INTERFACE
    echo "✅ WireGuard service disabled"
else
    echo "ℹ️  WireGuard service is not enabled"
fi

# Verify shutdown
echo ""
echo "🔍 Verifying VPN shutdown..."
if ! systemctl is-active --quiet wg-quick@$WG_INTERFACE; then
    echo "✅ VPN successfully shut down"
    echo ""
    echo "WireGuard interface status:"
    wg show || echo "No WireGuard interfaces active"
else
    echo "⚠️  VPN may still be running"
fi

echo ""
echo "📋 Current network interfaces:"
ip addr show | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1"

echo ""
echo "✅ VPN shutdown completed!"
