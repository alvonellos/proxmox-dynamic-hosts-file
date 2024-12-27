#!/bin/bash

# Uninstaller script for hostname updater hook

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This uninstaller must be run as root."
    exit 1
fi

# Define paths
SCRIPT_DIR="/usr/local/bin"
SCRIPT_NAME="update_hosts.sh"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"
CRON_FILE="/etc/cron.d/hostname_updater"
HOOKS_FILE="/etc/dhcp/dhclient-exit-hooks.d/update-etc-hosts"

# Remove the script from /usr/local/bin
if [ -f "$SCRIPT_PATH" ]; then
    rm -f "$SCRIPT_PATH"
    echo "Removed $SCRIPT_PATH"
else
    echo "Script $SCRIPT_PATH not found. Skipping."
fi

# Remove the cron job
if [ -f "$CRON_FILE" ]; then
    rm -f "$CRON_FILE"
    echo "Removed cron job file $CRON_FILE"
else
    echo "Cron job file $CRON_FILE not found. Skipping."
fi

# Remove the DHCP client hook
if [ -f "$HOOKS_FILE" ]; then
    rm -f "$HOOKS_FILE"
    echo "Removed DHCP hook $HOOKS_FILE"
else
    echo "DHCP hook $HOOKS_FILE not found. Skipping."
fi

# Confirmation
echo "Uninstaller completed. The hostname updater and associated configurations have been removed."

