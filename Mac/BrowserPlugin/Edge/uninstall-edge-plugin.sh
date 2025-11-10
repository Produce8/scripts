#!/bin/bash
# Silent system-wide uninstall of Microsoft Edge extension for RMM

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

exit 0
