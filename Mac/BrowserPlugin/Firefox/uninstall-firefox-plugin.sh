#!/bin/bash

echo "Uninstalling Firefox Extension on macOS..."

EXTENSION_ID="support@produce8.com"

PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/org.mozilla.firefox.plist"

# Check if the plist exists
if [ ! -f "$PLIST_PATH" ]; then
    echo "No managed Firefox preferences found. Nothing to remove."
    exit 0
fi

# Check if ExtensionSettings exists
/usr/libexec/PlistBuddy -c "Print :ExtensionSettings" "$PLIST_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "No ExtensionSettings policy found. Nothing to remove."
    exit 0
fi

# Check if our extension ID exists in ExtensionSettings
/usr/libexec/PlistBuddy -c "Print :ExtensionSettings:$EXTENSION_ID" "$PLIST_PATH" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    /usr/libexec/PlistBuddy -c "Delete :ExtensionSettings:$EXTENSION_ID" "$PLIST_PATH"
    echo "Removed Firefox extension policy for $EXTENSION_ID"
    
    # Check if ExtensionSettings is now empty and remove it if so
    # Get the full output of ExtensionSettings - if empty, it will be just "Dict {" or similar
    EXT_SETTINGS_CONTENT=$(/usr/libexec/PlistBuddy -c "Print :ExtensionSettings" "$PLIST_PATH" 2>/dev/null)
    # Check if the content is empty or only contains dict markers (empty dict)
    # An empty dict shows as "Dict {" followed by "}" with nothing meaningful in between
    # Remove all whitespace and check if it's just "Dict{}"
    EXT_SETTINGS_CLEANED=$(echo "$EXT_SETTINGS_CONTENT" | tr -d '[:space:]' | tr -d '\n')
    if [ -z "$EXT_SETTINGS_CONTENT" ] || [ "$EXT_SETTINGS_CLEANED" = "Dict{}" ]; then
        /usr/libexec/PlistBuddy -c "Delete :ExtensionSettings" "$PLIST_PATH" 2>/dev/null || true
        echo "Removed empty ExtensionSettings dictionary."
    fi
else
    echo "Extension $EXTENSION_ID not found in ExtensionSettings."
fi

# Fix permissions
chmod 644 "$PLIST_PATH"
chown root:wheel "$PLIST_PATH"