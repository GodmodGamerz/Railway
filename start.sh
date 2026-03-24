cat > /mnt/user-data/outputs/start.sh << 'SCRIPT'
#!/bin/bash

set -e

echo "========================================="
echo "  Railway SSH VPS Starting..."
echo "========================================="

# Set password for 'vps' user from environment variable
if [ -z "$SSH_PASSWORD" ]; then
    echo "[ERROR] SSH_PASSWORD environment variable is not set!"
    exit 1
fi

echo "vps:$SSH_PASSWORD" | chpasswd
echo "[OK] Password set for user 'vps'"

# Railway assigns a port via $PORT - sshd MUST listen on this exact port
SSH_PORT=${PORT:-22}
echo "[OK] SSH will listen on port: $SSH_PORT"

# Completely rewrite sshd_config to avoid any sed issues
cat > /etc/ssh/sshd_config << EOF
Port $SSH_PORT
AddressFamily any
ListenAddress 0.0.0.0

PermitRootLogin no
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM no
X11Forwarding no
PrintMotd no

ClientAliveInterval 60
ClientAliveCountMax 10

AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# Always regenerate host keys fresh
ssh-keygen -A
echo "[OK] SSH host keys generated"

echo ""
echo "========================================="
echo "  Connect using:"
echo "  ssh vps@<your-railway-domain> -p <tcp-proxy-port>"
echo "  Password: (your SSH_PASSWORD value)"
echo "========================================="

# Start SSH in foreground with verbose logging
exec /usr/sbin/sshd -D -e
SCRIPT
echo "Done"
