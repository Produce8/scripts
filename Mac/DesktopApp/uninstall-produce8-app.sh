#!/bin/bash
# Script requires elevated permissions

APP_NAME="Produce8"
APP_PATH="/Applications/$APP_NAME.app"

# Exit the app if it's running
if pgrep -x "$APP_NAME" >/dev/null; then
    pkill -x "$APP_NAME"
    sleep 2
fi

# Delete the application
if [ -d "$APP_PATH" ]; then
    sudo rm -rf "$APP_PATH"
else
    echo "$APP_NAME not found in /Applications"
fi

# Remove related user files
rm -rf ~/Library/Application\ Support/$APP_NAME
rm -rf ~/Library/Caches/$APP_NAME
rm -rf ~/Library/Preferences/com.electron.$APP_NAME.plist
rm -rf ~/Library/Logs/$APP_NAME

echo "$APP_NAME has been uninstalled."
