#!/bin/bash
# Silent system-wide uninstall of Chrome extension for RMM

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

exit 0
