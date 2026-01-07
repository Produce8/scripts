#!/bin/bash

echo "Installing Firefox Extension on macOS..."

EXTENSION_ID="support@produce8.com"
EXTENSION_URL="https://addons.mozilla.org/firefox/downloads/file/4579169/produce8_agent-3.1.37.xpi"

# Use /Library/Managed Preferences/ for enterprise deployment (applies to all users)
PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/org.mozilla.firefox.plist"

# Ensure the directory exists
mkdir -p "$PREFS_DIR"

# Enable Enterprise Policies (required for Firefox to read policies)
/usr/libexec/PlistBuddy -c "Delete :EnterprisePoliciesEnabled" "$PLIST_PATH" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :EnterprisePoliciesEnabled bool true" "$PLIST_PATH"

# Remove old Extensions:Install if it exists (deprecated format)
/usr/libexec/PlistBuddy -c "Delete :Extensions" "$PLIST_PATH" 2>/dev/null || true

# Remove existing ExtensionSettings if it exists
/usr/libexec/PlistBuddy -c "Delete :ExtensionSettings" "$PLIST_PATH" 2>/dev/null || true

# Add ExtensionSettings dictionary
/usr/libexec/PlistBuddy -c "Add :ExtensionSettings dict" "$PLIST_PATH"

# Add extension ID dictionary
/usr/libexec/PlistBuddy -c "Add :ExtensionSettings:$EXTENSION_ID dict" "$PLIST_PATH"

# Add installation_mode
/usr/libexec/PlistBuddy -c "Add :ExtensionSettings:$EXTENSION_ID:installation_mode string force_installed" "$PLIST_PATH"

# Add install_url
/usr/libexec/PlistBuddy -c "Add :ExtensionSettings:$EXTENSION_ID:install_url string $EXTENSION_URL" "$PLIST_PATH"

# Set permissions
chmod 644 "$PLIST_PATH"
chown root:wheel "$PLIST_PATH"

echo "Plist file created at: $PLIST_PATH"
echo "However, Firefox requires this to be deployed via MDM configuration profile to work."




