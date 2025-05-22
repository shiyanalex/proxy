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

read -p "Enter the number of users to create (default 1): " num_users
num_users=${num_users:-1}

# Generate the configuration file
echo "Creating configuration file..."
cat << EOF > /etc/shadowsocks-libev/config.json
{
    "server": "0.0.0.0",
    "mode": "tcp_and_udp",
    "server_port": $port,
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": true,
    "reuse_port": true,
    "no_delay": true,
    "users": [
EOF

for i in $(seq 1 $num_users); do
    password=$(openssl rand -base64 12)
    comma=","
    if [ $i -eq $num_users ]; then
        comma=""
    fi
    echo "        {\"password\": \"$password\"}$comma" >> /etc/shadowsocks-libev/config.json
done

echo "    ]" >> /etc/shadowsocks-libev/config.json
echo "}" >> /etc/shadowsocks-libev/config.json

# Restart Shadowsocks service
echo "Restarting Shadowsocks service..."
systemctl restart shadowsocks-libev
systemctl enable shadowsocks-libev

# Add firewall rule for Google Cloud
echo "Adding firewall rule for Google Cloud..."
gcloud compute firewall-rules create allow-shadowsocks --allow tcp:$port,udp:$port --target-tags=shadowsocks-server --description="Allow Shadowsocks traffic on port $port"

# Display connection details
echo "Configuration complete!"
ip=$(curl -s ifconfig.me)
echo "Server IP: $ip"
echo "Port: $port"
echo "Encryption Method: aes-256-gcm"
echo "To monitor bandwidth usage, use: vnstat -l -i eth0"
