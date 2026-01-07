#!/bin/bash
# Combined uninstall script for Chrome, Edge, and Firefox extensions on macOS
# This script removes Produce8 extensions from all three browsers

echo "=========================================="
echo "Uninstalling Produce8 Browser Extensions"
echo "=========================================="
echo ""

# Function to uninstall Chrome extension
uninstall_chrome() {
echo "--- Uninstalling Google Chrome Extension ---"

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
echo "--- Uninstalling Microsoft Edge Extension ---"

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
echo "--- Uninstalling Mozilla Firefox Extension ---"

EXTENSION_ID="support@produce8.com"

# Check both possible locations for Firefox plist
PLIST_PATHS=(
    "/Library/Managed Preferences/org.mozilla.firefox.plist"
    "/Library/Preferences/org.mozilla.firefox.plist"
)

FOUND_ANY=false

for PLIST_PATH in "${PLIST_PATHS[@]}"; do
    # Check if the plist exists
    if [ ! -f "$PLIST_PATH" ]; then
        continue
    fi
    
    FOUND_ANY=true
    echo "Processing: $PLIST_PATH"
    
    # Check if ExtensionSettings exists
    /usr/libexec/PlistBuddy -c "Print :ExtensionSettings" "$PLIST_PATH" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        # Check if our extension ID exists in ExtensionSettings
        /usr/libexec/PlistBuddy -c "Print :ExtensionSettings:$EXTENSION_ID" "$PLIST_PATH" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /usr/libexec/PlistBuddy -c "Delete :ExtensionSettings:$EXTENSION_ID" "$PLIST_PATH"
            echo "  Removed Firefox extension policy for $EXTENSION_ID"
            
            # Check if ExtensionSettings is now empty and remove it if so
            EXT_SETTINGS_CONTENT=$(/usr/libexec/PlistBuddy -c "Print :ExtensionSettings" "$PLIST_PATH" 2>/dev/null)
            EXT_SETTINGS_CLEANED=$(echo "$EXT_SETTINGS_CONTENT" | tr -d '[:space:]' | tr -d '\n')
            if [ -z "$EXT_SETTINGS_CONTENT" ] || [ "$EXT_SETTINGS_CLEANED" = "Dict{}" ]; then
                /usr/libexec/PlistBuddy -c "Delete :ExtensionSettings" "$PLIST_PATH" 2>/dev/null || true
                echo "  Removed empty ExtensionSettings dictionary."
            fi
        else
            echo "  Extension $EXTENSION_ID not found in ExtensionSettings."
        fi
    else
        echo "  No ExtensionSettings policy found in this file."
    fi
    
    # Check if the plist is now empty or only contains EnterprisePoliciesEnabled
    # If so, remove the entire file
    if [ -f "$PLIST_PATH" ]; then
        # Check if EnterprisePoliciesEnabled exists
        /usr/libexec/PlistBuddy -c "Print :EnterprisePoliciesEnabled" "$PLIST_PATH" > /dev/null 2>&1
        HAS_ENTERPRISE=$?
        
        # Check if ExtensionSettings still exists
        /usr/libexec/PlistBuddy -c "Print :ExtensionSettings" "$PLIST_PATH" > /dev/null 2>&1
        HAS_EXT_SETTINGS=$?
        
        # If only EnterprisePoliciesEnabled exists (no ExtensionSettings), remove it
        if [ $HAS_ENTERPRISE -eq 0 ] && [ $HAS_EXT_SETTINGS -ne 0 ]; then
            /usr/libexec/PlistBuddy -c "Delete :EnterprisePoliciesEnabled" "$PLIST_PATH" 2>/dev/null || true
            echo "  Removed EnterprisePoliciesEnabled."
        fi
        
        # Check if file is now empty by trying to list keys
        # PlistBuddy will fail if the dict is empty
        /usr/libexec/PlistBuddy -c "Print" "$PLIST_PATH" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            # File appears to be empty or corrupted, remove it
            rm -f "$PLIST_PATH" 2>/dev/null && echo "  Removed empty plist file."
        else
            # Check if there are any keys in the plist
            # Use grep to find keys and count lines, ensuring we get a clean integer
            PLIST_OUTPUT=$(/usr/libexec/PlistBuddy -c "Print" "$PLIST_PATH" 2>/dev/null)
            if [ $? -eq 0 ]; then
                KEY_COUNT=$(echo "$PLIST_OUTPUT" | grep -c "<key>" 2>/dev/null || echo "0")
                # Clean up the count - remove whitespace and ensure it's a number
                KEY_COUNT=$(echo "$KEY_COUNT" | awk '{print $1}' | tr -d '[:space:]')
                # Validate it's a number, default to 0 if not
                if ! echo "$KEY_COUNT" | grep -qE '^[0-9]+$'; then
                    KEY_COUNT=0
                fi
                if [ "$KEY_COUNT" -eq 0 ]; then
                    rm -f "$PLIST_PATH" 2>/dev/null && echo "  Removed empty plist file."
                else
                    # Fix permissions if file still exists
                    chmod 644 "$PLIST_PATH" 2>/dev/null || true
                    chown root:wheel "$PLIST_PATH" 2>/dev/null || true
                fi
            else
                # If Print fails, file might be empty or corrupted
                rm -f "$PLIST_PATH" 2>/dev/null && echo "  Removed empty/corrupted plist file."
            fi
        fi
    fi
done

if [ "$FOUND_ANY" = false ]; then
    echo "No Firefox preferences plist files found. Nothing to remove."
fi

# Remove extension XPI file from all user profiles
echo ""
echo "Removing extension XPI files from user profiles..."

REMOVED_COUNT=0

# Check all user profiles on the system
for USER_HOME in /Users/*; do
    # Skip if not a directory
    [ ! -d "$USER_HOME" ] && continue
    
    # Skip default system accounts
    USER_NAME=$(basename "$USER_HOME")
    if [[ "$USER_NAME" == "Shared" ]] || [[ "$USER_NAME" == ".localized" ]]; then
        continue
    fi
    
    # Firefox profiles directory
    FIREFOX_PROFILES_DIR="$USER_HOME/Library/Application Support/Firefox/Profiles"
    
    if [ -d "$FIREFOX_PROFILES_DIR" ]; then
        # Find all Firefox profiles
        for PROFILE_DIR in "$FIREFOX_PROFILES_DIR"/*; do
            [ ! -d "$PROFILE_DIR" ] && continue
            
            EXTENSIONS_DIR="$PROFILE_DIR/extensions"
            EXTENSION_XPI="$EXTENSIONS_DIR/${EXTENSION_ID}.xpi"
            RENAMED_XPI="$EXTENSIONS_DIR/${EXTENSION_ID}.xpi.removed"
            
            # First, try to clean up any previously renamed files (in case Firefox is now closed)
            if [ -f "$RENAMED_XPI" ]; then
                rm -f "$RENAMED_XPI" 2>/dev/null && REMOVED_COUNT=$((REMOVED_COUNT + 1)) && echo "  Cleaned up previously renamed file: $RENAMED_XPI"
            fi
            
            # Now try to remove the current XPI file
            if [ -f "$EXTENSION_XPI" ]; then
                # Try to delete the file
                if rm -f "$EXTENSION_XPI" 2>/dev/null; then
                    echo "  Removed: $EXTENSION_XPI"
                    REMOVED_COUNT=$((REMOVED_COUNT + 1))
                else
                    # If deletion fails (likely because Firefox is running), rename it instead
                    # Firefox won't find it with a different name, so the extension won't load
                    if mv "$EXTENSION_XPI" "$RENAMED_XPI" 2>/dev/null; then
                        echo "  Renamed (Firefox was running): $EXTENSION_XPI -> $RENAMED_XPI"
                        echo "  Extension will not load. File will be deleted when Firefox is closed and script is run again"
                        REMOVED_COUNT=$((REMOVED_COUNT + 1))
                    else
                        echo "  WARNING: Could not delete or rename $EXTENSION_XPI"
                        echo "  Please close Firefox completely and run this script again"
                    fi
                fi
            fi
        done
    fi
done

if [ $REMOVED_COUNT -eq 0 ]; then
    echo "  No extension XPI files found in any user profiles"
else
    echo "  Removed extension files from $REMOVED_COUNT location(s)"
fi

echo "Firefox extension uninstall completed."
echo ""
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