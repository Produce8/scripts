#!/bin/bash

echo "Installing Chrome Extension on macOS..."

EXTENSION_ID="kjdhkfobigjnlanlfjakbbibdbakdcnc"
UPDATE_URL="https://clients2.google.com/service/update2/crx"
FORCE_INSTALL_STRING="${EXTENSION_ID};${UPDATE_URL}"

# Create the Managed Preferences directory if it doesn't exist
PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/com.google.Chrome.plist"

# Ensure the directory exists
mkdir -p "$PREFS_DIR"

# Use PlistBuddy to write the extension config
/usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist" "$PLIST_PATH" 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :ExtensionInstallForcelist array" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :ExtensionInstallForcelist:0 string $FORCE_INSTALL_STRING" "$PLIST_PATH"

# Set permissions
chmod 644 "$PLIST_PATH"
chown root:wheel "$PLIST_PATH"

echo "Extension $EXTENSION_ID installed."
