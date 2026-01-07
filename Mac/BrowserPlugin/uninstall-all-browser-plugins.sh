#!/bin/bash
# Combined uninstall script for Chrome, Edge, and Firefox extensions on macOS
# This script removes Produce8 extensions from all three browsers

echo "=========================================="
echo "Uninstalling Produce8 Browser Extensions"
echo "=========================================="
echo ""

# Function to uninstall Chrome extension
uninstall_chrome() {
EXTENSION_ID="kjdhkfobigjnlanlfjakbbibdbakdcnc"
UPDATE_URL="https://clients2.google.com/service/update2/crx"
FORCE_INSTALL_STRING="${EXTENSION_ID};${UPDATE_URL}"

# Managed Preferences path for Chrome
PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/com.google.Chrome.plist"

# Remove extension from managed preferences
if [ -f "$PLIST_PATH" ]; then
    /usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist" "$PLIST_PATH" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        INDEX=0
        while : ; do
            VALUE=$(/usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist:$INDEX" "$PLIST_PATH" 2>/dev/null)
            if [ $? -ne 0 ]; then break; fi
            if [ "$VALUE" == "$FORCE_INSTALL_STRING" ]; then
                /usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist:$INDEX" "$PLIST_PATH"
                break
            fi
            INDEX=$((INDEX + 1))
        done

        # Delete the key if empty
        NUM_ITEMS=$(/usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist" "$PLIST_PATH" | wc -l)
        if [ "$NUM_ITEMS" -eq 0 ]; then
            /usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist" "$PLIST_PATH"
        fi
    fi
fi

# Remove extension from all user profiles
for USER_HOME in /Users/*; do
    # Default profile Extensions folder
    EXT_DIR="$USER_HOME/Library/Application Support/Google/Chrome/Default/Extensions/$EXTENSION_ID"
    [ -d "$EXT_DIR" ] && rm -rf "$EXT_DIR"

    # Local extension settings
    LOCAL_EXT_DIR="$USER_HOME/Library/Application Support/Google/Chrome/Default/Local Extension Settings/$EXTENSION_ID"
    [ -d "$LOCAL_EXT_DIR" ] && rm -rf "$LOCAL_EXT_DIR"

    # Additional browser profiles
    for PROFILE_DIR in "$USER_HOME/Library/Application Support/Google/Chrome/"*/Extensions/$EXTENSION_ID; do
        [ -d "$PROFILE_DIR" ] && rm -rf "$PROFILE_DIR"
    done

    # Remove cached or temporary extension data
    rm -rf "$USER_HOME/Library/Caches/Google/Chrome/"*/Extensions/$EXTENSION_ID 2>/dev/null
done

# Fix permissions on managed plist
if [ -f "$PLIST_PATH" ]; then
    sudo chmod 644 "$PLIST_PATH"
    sudo chown root:wheel "$PLIST_PATH"
fi

echo "Google Chrome extension $EXTENSION_ID removal completed."
echo "Please restart Google Chrome and consider rebooting the system for full cleanup."
}

# Function to uninstall Edge extension
uninstall_edge() {
EXTENSION_ID="clfmhpehigjmbgobgdebalogdgohbafk"
UPDATE_URL="https://edge.microsoft.com/extensionwebstorebase/v1/crx"
FORCE_INSTALL_STRING="${EXTENSION_ID};${UPDATE_URL}"

# Managed Preferences path for Microsoft Edge
PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/com.microsoft.Edge.plist"

# Remove extension from managed preferences
if [ -f "$PLIST_PATH" ]; then
    /usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist" "$PLIST_PATH" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        INDEX=0
        while : ; do
            VALUE=$(/usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist:$INDEX" "$PLIST_PATH" 2>/dev/null)
            if [ $? -ne 0 ]; then break; fi
            if [ "$VALUE" == "$FORCE_INSTALL_STRING" ]; then
                /usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist:$INDEX" "$PLIST_PATH"
                break
            fi
            INDEX=$((INDEX + 1))
        done

        # Delete the key if empty
        NUM_ITEMS=$(/usr/libexec/PlistBuddy -c "Print :ExtensionInstallForcelist" "$PLIST_PATH" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$NUM_ITEMS" -eq 0 ] || [ -z "$NUM_ITEMS" ]; then
            /usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist" "$PLIST_PATH" 2>/dev/null
        fi
    fi
fi

# Remove extension from all user profiles
for USER_HOME in /Users/*; do
    # Default profile Extensions folder
    EXT_DIR="$USER_HOME/Library/Application Support/Microsoft Edge/Default/Extensions/$EXTENSION_ID"
    [ -d "$EXT_DIR" ] && sudo rm -rf "$EXT_DIR"

    # Additional browser profiles
    for PROFILE_DIR in "$USER_HOME/Library/Application Support/Microsoft Edge/"*/Extensions/$EXTENSION_ID; do
        [ -d "$PROFILE_DIR" ] && sudo rm -rf "$PROFILE_DIR"
    done

    # Remove cached or temporary extension data
    sudo rm -rf "$USER_HOME/Library/Caches/Microsoft Edge/"*/Extensions/$EXTENSION_ID 2>/dev/null
done

# Fix permissions on managed plist
if [ -f "$PLIST_PATH" ]; then
    sudo chmod 644 "$PLIST_PATH"
    sudo chown root:wheel "$PLIST_PATH"
fi

echo "Microsoft Edge extension $EXTENSION_ID removal completed."
echo "Please restart Microsoft Edge and consider rebooting the system for full cleanup."
}

# Function to uninstall Firefox extension
uninstall_firefox() {
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
}

# Main execution
uninstall_chrome
uninstall_edge
uninstall_firefox

echo "=========================================="
echo "Uninstall Complete"
echo "=========================================="
echo "Please restart your browsers for changes to take effect."
echo "You may need to reboot the system for full cleanup."

exit 0

