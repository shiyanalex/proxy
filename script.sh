#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Update the system
echo "Updating the system..."
apt update && apt upgrade -y

# Install necessary packages
echo "Installing Shadowsocks and vnstat..."
apt install -y shadowsocks-libev vnstat

# Prompt for configuration
read -p "Enter the port number for Shadowsocks (default 8388): " port
port=${port:-8388}

# Generate random password
password=$(openssl rand -base64 12)

# Get external IP
server_ip=$(curl -s ifconfig.me)

# Generate the configuration file
echo "Creating configuration file..."
cat << EOF > /etc/shadowsocks-libev/config.json
{
    "server": "$server_ip",
    "mode": "tcp_and_udp",
    "server_port": $port,
    "timeout": 300,
    "method": "aes-256-gcm",
    "password": "$password",
    "fast_open": true,
    "reuse_port": true,
    "no_delay": true
}
EOF

# Restart Shadowsocks service
echo "Restarting Shadowsocks service..."
systemctl restart shadowsocks-libev
systemctl enable shadowsocks-libev

# Display connection details
echo "Configuration complete!"
echo "Server IP: $server_ip"
echo "Port: $port"
echo "Password: $password"
echo "Encryption Method: aes-256-gcm"
echo "To monitor bandwidth usage, use: vnstat -l -i ens4"
