#!/bin/bash

echo "Uninstalling Chrome Extension on macOS..."

EXTENSION_ID="kjdhkfobigjnlanlfjakbbibdbakdcnc"
UPDATE_URL="https://clients2.google.com/service/update2/crx"
FORCE_INSTALL_STRING="${EXTENSION_ID};${UPDATE_URL}"

PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/com.google.Chrome.plist"

# Check if the plist exists
if [ ! -f "$PLIST_PATH" ]; then
    echo "No managed Chrome preferences found. Nothing to remove."
    exit 0
fi

# Check if ExtensionInstallForcelist exists
/usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist" "$PLIST_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "No ExtensionInstallForcelist found. Nothing to remove."
    exit 0
fi

# Find and remove the matching extension string
INDEX=0
FOUND=0
while : ; do
    VALUE=$(/usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist:$INDEX" "$PLIST_PATH" 2>/dev/null)
    if [ $? -ne 0 ]; then
        break
    fi

    if [ "$VALUE" == "$FORCE_INSTALL_STRING" ]; then
        /usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist:$INDEX" "$PLIST_PATH"
        echo "Removed extension $EXTENSION_ID from managed preferences."
        FOUND=1
        break
    fi

    INDEX=$((INDEX + 1))
done

if [ "$FOUND" -eq 0 ]; then
    echo "Extension $EXTENSION_ID not found in ExtensionInstallForcelist."
fi

# Fix permissions
chmod 644 "$PLIST_PATH"
chown root:wheel "$PLIST_PATH"

