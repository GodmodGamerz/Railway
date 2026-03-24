#!/bin/bash

set -e

echo "========================================="
echo "  Railway SSH VPS Starting..."
echo "========================================="

# Set password for 'vps' user from environment variable
# You must set SSH_PASSWORD in Railway environment variables
if [ -z "$SSH_PASSWORD" ]; then
    echo "[ERROR] SSH_PASSWORD environment variable is not set!"
    echo "Set it in Railway: Settings > Variables > SSH_PASSWORD=yourpassword"
    exit 1
fi

echo "vps:$SSH_PASSWORD" | chpasswd
echo "[OK] Password set for user 'vps'"

# Railway assigns a random port via $PORT env var
# We need sshd to listen on that port
SSH_PORT=${PORT:-22}

sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config

# Regenerate host keys if missing
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
    echo "[OK] SSH host keys generated"
fi

echo "[OK] SSH will listen on port: $SSH_PORT"
echo ""
echo "========================================="
echo "  Connect using:"
echo "  ssh vps@<your-railway-domain> -p $SSH_PORT"
echo "  Password: (your SSH_PASSWORD value)"
echo "========================================="

# Start SSH in foreground
exec /usr/sbin/sshd -D -e
