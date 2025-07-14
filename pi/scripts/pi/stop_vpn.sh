#!/bin/bash

# PI SCRIPT - Switch Pi gateway from VPN to normal internet
# This script runs ON the PI to switch from VPN routing to normal internet
# Pi remains as DHCP server and internet gateway, but traffic goes directly to internet
# Usage: sudo ./stop_vpn.sh

set -e

# Check if we're running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ ERROR: This script must be run as root (with sudo)"
    echo "Usage: sudo ./stop_vpn.sh"
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

echo "🔧 Switching Pi gateway from VPN to normal internet..."
echo "====================================================="
echo ""

# 1. Stop and disable WireGuard
echo "🛑 Stopping WireGuard service..."
if systemctl is-active --quiet wg-quick@$WG_INTERFACE; then
    systemctl stop wg-quick@$WG_INTERFACE
    echo "✅ WireGuard service stopped"
else
    echo "ℹ️  WireGuard service was not running"
fi

if systemctl is-enabled --quiet wg-quick@$WG_INTERFACE; then
    systemctl disable wg-quick@$WG_INTERFACE
    echo "✅ WireGuard service disabled"
else
    echo "ℹ️  WireGuard service was not enabled"
fi

# 2. Fix iptables: change from VPN routing to direct internet routing
echo "🔄 Updating iptables for direct internet routing..."
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o $LAN_INTERFACE -j MASQUERADE
echo "✅ iptables updated for direct internet routing"

# 3. Update dnsmasq DNS to use normal internet DNS
echo "🔄 Updating dnsmasq DNS to normal internet..."
sed -i "s/server=$VPN_DNS_SERVER/server=8.8.8.8/" /etc/dnsmasq.conf
sed -i "s/dhcp-option=6,$VPN_DNS_SERVER/dhcp-option=6,8.8.8.8,8.8.4.4/" /etc/dnsmasq.conf
systemctl restart dnsmasq
echo "✅ dnsmasq updated to use normal internet DNS"

# 4. Save iptables rules
echo "💾 Saving iptables rules..."
if command -v iptables-save >/dev/null 2>&1; then
    iptables-save > /etc/iptables/rules.v4
    echo "✅ iptables rules saved"
else
    echo "⚠️  Warning: iptables-save not found, rules may not persist after reboot"
fi

# 5. Verify
echo ""
echo "🔍 Verifying configuration..."
echo "IP forwarding: $(cat /proc/sys/net/ipv4/ip_forward)"
echo ""
echo "Current NAT rules:"
iptables -t nat -L POSTROUTING -v --line-numbers
echo ""
echo "Testing internet connectivity..."
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "✅ Internet connectivity working!"
else
    echo "⚠️  Internet connectivity test failed"
fi

echo ""
echo "✅ VPN stopped! Pi gateway now routes traffic directly to internet."
echo ""
echo "The Pi continues to serve as:"
echo "- DHCP server for your network"
echo "- Internet gateway for all devices"
echo "- DNS server using normal internet DNS (8.8.8.8, 8.8.4.4)"
echo ""
echo "To re-enable VPN mode, run: ./deploy_to_pi.sh"
