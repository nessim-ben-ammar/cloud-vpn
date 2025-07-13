#!/bin/bash

# Config
KEY="../ssh_keys/pi_ssh_key"
USER="pi"
HOST="192.168.188.2"

# Optional: set default port (22), override with -p
PORT=22

# Connect
ssh -i "$KEY" -p "$PORT" "$USER@$HOST"
