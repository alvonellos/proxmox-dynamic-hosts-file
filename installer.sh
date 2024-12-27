#!/bin/bash

# Installer script for hostname updater hook

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This installer must be run as root."
    exit 1
fi

# Create the script directory if it doesn't exist
SCRIPT_DIR="/usr/local/bin"
SCRIPT_NAME="update_hosts.sh"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# Copy the script to the appropriate directory
cp ./update_hosts.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Create a cron job to run the script at boot
CRON_JOB="@reboot root $SCRIPT_PATH"
CRON_FILE="/etc/cron.d/hostname_updater"

if [ ! -f "$CRON_FILE" ]; then
    echo "$CRON_JOB" > "$CRON_FILE"
    chmod 644 "$CRON_FILE"
    echo "Cron job installed to update hostname at boot."
else
    # Update the cron job if it exists
    grep -q "$SCRIPT_PATH" "$CRON_FILE"
    if [ $? -ne 0 ]; then
        echo "$CRON_JOB" >> "$CRON_FILE"
        echo "Cron job updated to include hostname updater."
    else
        echo "Cron job already includes the hostname updater. Skipping update."
    fi
fi

# Install the script as a DHCP client exit hook
HOOKS_DIR="/etc/dhcp/dhclient-exit-hooks.d"
HOOKS_FILE="$HOOKS_DIR/update-etc-hosts"

if [ ! -d "$HOOKS_DIR" ]; then
    mkdir -p "$HOOKS_DIR"
    echo "Created hooks directory: $HOOKS_DIR"
fi

cp ./update_hosts.sh "$HOOKS_FILE"
chmod +x "$HOOKS_FILE"

if [ -f "$HOOKS_FILE" ]; then
    echo "Hook installed at $HOOKS_FILE"
else
    echo "Failed to install hook."
    exit 1
fi

# Confirmation
echo "Installer completed. The hostname updater is now installed with a cron job and DHCP hooks."

