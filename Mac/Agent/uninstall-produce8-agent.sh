#!/bin/bash

APP_NAME="Produce8-Agent"

# Fail-safe: exit if APP_NAME wasn't replaced by a valid build name                                           
if [ "$APP_NAME" == *"BUILD"* ] || [ -z "$APP_NAME" ]; then                                               
  echo "[ERROR] APP_NAME is not set properly. Aborting to prevent accidental deletion."                       
  exit 1                                                                                                      
fi 

PLIST_AGENT="/Library/LaunchAgents/com.produce8.${APP_NAME}.plist"
PLIST_DAEMON="/Library/LaunchDaemons/com.produce8.${APP_NAME}-Updater.plist"
BIN_PATH="/Library/${APP_NAME}-Updater/${APP_NAME}-Updater"
APP_PATH="/Applications/${APP_NAME}.app"

# Stop and unload LaunchAgent
if [ -f "$PLIST_AGENT" ]; then
    USER_ID=$(stat -f%u /dev/console)
    launchctl bootout gui/${USER_ID} "$PLIST_AGENT" 2>/dev/null
    rm "$PLIST_AGENT"
fi

# Stop and unload LaunchDaemon
if [ -f "$PLIST_DAEMON" ]; then
    launchctl bootout system "$PLIST_DAEMON" 2>/dev/null
    rm "$PLIST_DAEMON"
fi

# Remove updater binary and directory
rm -rf "/Library/${APP_NAME}-Updater"

# Remove main app (optional)
rm -rf "$APP_PATH"

echo "[INFO] Uninstallation complete."

