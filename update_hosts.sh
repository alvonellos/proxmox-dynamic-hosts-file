#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Get the current hostname
HOSTNAME=$(hostname)

# Get the primary IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Validate the IP address
if [[ -z "$IP_ADDRESS" ]]; then
    echo "Unable to determine the IP address."
    exit 1
fi

# Backup the /etc/hosts file
cp /etc/hosts /etc/hosts.bak

# Update the /etc/hosts file
sed -i.bak "/\s${HOSTNAME}$/d" /etc/hosts
echo "$IP_ADDRESS $HOSTNAME" >> /etc/hosts

echo "Updated /etc/hosts with IP $IP_ADDRESS for hostname $HOSTNAME."

