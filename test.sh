#!/bin/bash

# Test script for Hostname Updater

# Paths
INSTALLER="./installer.sh"
UNINSTALLER="./uninstall.sh"
UPDATE_SCRIPT="/usr/local/bin/update_hosts.sh"
HOOKS_FILE="/etc/dhcp/dhclient-exit-hooks.d/update-etc-hosts"
CRON_FILE="/etc/cron.d/hostname_updater"
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.bak"

# Helper function to check file existence
check_file() {
    if [ -f "$1" ]; then
        echo "[PASS] $1 exists."
    else
        echo "[FAIL] $1 does not exist."
        exit 1
    fi
}

# Backup original hosts file
if [ -f "$HOSTS_FILE" ]; then
    cp "$HOSTS_FILE" "$BACKUP_FILE"
    echo "[INFO] Backed up $HOSTS_FILE to $BACKUP_FILE"
else
    echo "[ERROR] $HOSTS_FILE not found. Cannot proceed."
    exit 1
fi

# Test Installer
echo "[TEST] Running Installer"
sudo bash "$INSTALLER"

# Verify installer actions
check_file "$UPDATE_SCRIPT"
check_file "$HOOKS_FILE"
check_file "$CRON_FILE"

# Test Update Script
echo "[TEST] Running Update Script"
sudo bash "$UPDATE_SCRIPT"

# Verify hosts file is updated
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
if grep -q "$HOSTNAME" "$HOSTS_FILE" && grep -q "$IP" "$HOSTS_FILE"; then
    echo "[PASS] $HOSTS_FILE contains updated hostname and IP."
else
    echo "[FAIL] $HOSTS_FILE was not updated correctly."
    exit 1
fi

# Test Uninstaller
echo "[TEST] Running Uninstaller"
sudo bash "$UNINSTALLER"

# Verify uninstaller actions
if [ -f "$UPDATE_SCRIPT" ] || [ -f "$HOOKS_FILE" ] || [ -f "$CRON_FILE" ]; then
    echo "[FAIL] Uninstaller did not remove all files."
    exit 1
else
    echo "[PASS] All files removed by uninstaller."
fi

# Restore original hosts file
mv "$BACKUP_FILE" "$HOSTS_FILE"
echo "[INFO] Restored original $HOSTS_FILE"

# Test completed
echo "[TEST] All tests completed successfully."

