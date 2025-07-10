#!/bin/bash

echo "Uninstall Produce8 Desktop App script running..."
echo

# Detect console user
CURRENT_USER=$(stat -f "%Su" /dev/console)

if [[ -z "$CURRENT_USER" || "$CURRENT_USER" == "root" ]]; then
  echo "Could not detect non-root console user. Defaulting to /Users/Shared."
  USER="/Users/Shared"
else
  USER=$(dscl . -read /Users/"$CURRENT_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
  if [[ -z "$USER" || ! -d "$USER" ]]; then
    echo "Failed to resolve valid home for user '$CURRENT_USER'. Defaulting to /Users/Shared."
    USER="/Users/Shared"
  fi
fi

APP_NAME="Produce8"
SYSTEM_APP_NAME="produce8"
APP_BUNDLE_PATH="/Applications/$APP_NAME.app"

# Find and kill running process
echo "Terminate Produce8 Desktop App Process..."
MATCHING_PROCS=$(ps -axo pid,command | grep -i "$APP_BUNDLE_PATH" | grep -v grep)

if [ -n "$MATCHING_PROCS" ]; then
  PIDS=$(echo "$MATCHING_PROCS" | awk '{print $1}')
  echo "$PIDS" | xargs sudo kill -9
  if [ $? -eq 0 ]; then
    echo "Process stopped successfully."
  else
    echo "Failed to kill process."
  fi
else
  echo "Process not running."
fi

echo

# Uninstall application bundle
echo "Attemping to uninstall the desktop application"
if [ -d "$APP_BUNDLE_PATH" ]; then
  echo "Removing app bundle at $APP_BUNDLE_PATH"
  sudo rm -rf "$APP_BUNDLE_PATH"
  if [ $? -eq 0 ]; then
    echo "Desktop app removed."
  else
    echo "Failed to remove desktop app."
  fi
else
  echo "Produce8 desktop app does not exist on the machine."
fi
echo

# Paths to clean
APP_FILE_PATHS=(
  "$USER/Library/Application Support/$APP_NAME"
  "$USER/Library/Logs/$APP_NAME"
  "$USER/Library/Preferences/com.electron.$SYSTEM_APP_NAME.plist"
  "$USER/Library/Caches/com.electron.$SYSTEM_APP_NAME"
)

# Remove app-related files
echo "Attemping to remove related files..."
for path in "${APP_FILE_PATHS[@]}"; do
  if [ -e "$path" ]; then
    echo "Attempting to remove: $path"
    rm -rf "$path"
    if [ $? -eq 0 ]; then
      echo "Removed: $path"
    else
      echo "Failed to remove: $path"
    fi
  else
    echo "Skipping file - does not exist. ($path)"
  fi
done

echo
echo "$APP_NAME desktop app has been uninstalled from your system."
