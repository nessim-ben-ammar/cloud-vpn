#!/bin/bash

# Script to setup dnsmasq DHCP server on Raspberry Pi
# This configures Pi as DHCP server AND gateway, bypassing router DHCP limitations
# Usage: ./setup_dnsmasq.sh

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

echo "Setting up dnsmasq DHCP server on Raspberry Pi..."
echo "This will configure Pi as DHCP server and gateway"
echo ""

echo "Configuring dnsmasq DHCP server..."

# Check if dnsmasq is installed
if ! command -v dnsmasq >/dev/null 2>&1; then
    echo "❌ Error: dnsmasq is not installed. Please run install_packages.sh first."
    exit 1
fi

# Check if WireGuard is configured
if [ ! -f "/etc/wireguard/$WG_INTERFACE.conf" ]; then
    echo "❌ Error: WireGuard configuration not found. Please run setup_wireguard.sh first."
    exit 1
fi

# Stop dnsmasq if running
echo "🛑 Stopping dnsmasq service..."
systemctl stop dnsmasq 2>/dev/null || true

# Backup original dnsmasq configuration
echo "💾 Backing up original dnsmasq configuration..."
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup 2>/dev/null || true

# Create new dnsmasq configuration
echo "📝 Creating dnsmasq configuration..."
cat > /etc/dnsmasq.conf << DNSMASQ_EOF
# dnsmasq configuration for Pi Gateway with VPN
# Interface to bind to (Pi's ethernet interface)
interface=$LAN_INTERFACE

# Don't bind to lo interface
bind-interfaces

# DHCP range - devices will get IPs in this range
dhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,$SUBNET_MASK,$DHCP_LEASE_TIME

# Gateway option - Pi itself
dhcp-option=3,$PI_IP

# DNS servers - VPN DNS only
dhcp-option=6,$VPN_DNS_SERVER

# Domain name
domain=$DOMAIN_NAME

# Enable DHCP logging
log-dhcp

# Cache size
cache-size=1000

# Don't read /etc/resolv.conf
no-resolv

# Upstream DNS servers (through VPN only)
server=$VPN_DNS_SERVER

# Don't forward plain names
domain-needed

# Don't forward addresses in the non-routed address spaces
bogus-priv

DNSMASQ_EOF

echo "✅ dnsmasq configuration created"

# Configure Pi's static IP (ensure it's static)
echo "🔧 Configuring Pi's static IP..."
cat > /etc/dhcpcd.conf << DHCPCD_EOF
# dhcpcd configuration for Pi Gateway

# Static IP configuration for $LAN_INTERFACE
interface $LAN_INTERFACE
static ip_address=$PI_IP/24
static routers=$ROUTER_IP
static domain_name_servers=$VPN_DNS_SERVER

# Fallback to DHCP if static fails
profile static_$LAN_INTERFACE
static ip_address=$PI_IP/24
static routers=$ROUTER_IP
static domain_name_servers=$VPN_DNS_SERVER

# Use static profile for $LAN_INTERFACE
interface $LAN_INTERFACE
fallback static_$LAN_INTERFACE

DHCPCD_EOF

echo "✅ Static IP configuration updated"

# Enable and start dnsmasq
echo "🚀 Starting dnsmasq service..."
systemctl enable dnsmasq
systemctl start dnsmasq

# Check if dnsmasq started successfully
if systemctl is-active --quiet dnsmasq; then
    echo "✅ dnsmasq started successfully"
else
    echo "❌ dnsmasq failed to start"
    systemctl status dnsmasq
    exit 1
fi

# Show dnsmasq status
echo ""
echo "📊 dnsmasq status:"
systemctl status dnsmasq --no-pager -l

echo ""
echo "📋 Active DHCP leases:"
cat /var/lib/dhcp/dhcpd.leases 2>/dev/null || echo "No leases yet"

echo ""
echo "✅ dnsmasq DHCP server setup completed!"
