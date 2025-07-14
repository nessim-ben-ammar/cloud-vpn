#!/bin/bash

# HOST SCRIPT - Connect to Pi via SSH
# This script uses centralized configuration

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

# Connect
ssh -i "$KEY" -p "$PORT" "$USER@$HOST"
