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
    "server": "0.0.0.0",
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
echo -e "\n\033[1;32m===== Configuration Complete! =====\033[0m"
echo -e "\033[1;34mServer IP:\033[0m \033[1;37m$server_ip\033[0m"
echo -e "\033[1;34mPort:\033[0m \033[1;37m$port\033[0m"
echo -e "\033[1;34mPassword:\033[0m \033[1;37m$password\033[0m"
echo -e "\033[1;34mEncryption Method:\033[0m \033[1;37maes-256-gcm\033[0m"
echo -e "\033[1;32m===================================\033[0m\n"
