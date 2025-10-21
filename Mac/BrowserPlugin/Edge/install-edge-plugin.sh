#!/bin/bash

echo "Installing Microsoft Edge Extension on macOS..."

EXTENSION_ID="clfmhpehigjmbgobgdebalogdgohbafk"
UPDATE_URL="https://edge.microsoft.com/extensionwebstorebase/v1/crx"
FORCE_INSTALL_STRING="${EXTENSION_ID};${UPDATE_URL}"

# Managed Preferences directory and plist path for Microsoft Edge
PREFS_DIR="/Library/Managed Preferences"
PLIST_PATH="$PREFS_DIR/com.microsoft.Edge.plist"

# Ensure the directory exists with proper permissions
if [ ! -d "$PREFS_DIR" ]; then
  echo "Creating Managed Preferences directory..."
  sudo mkdir -p "$PREFS_DIR"
  sudo chown root:wheel "$PREFS_DIR"
  sudo chmod 755 "$PREFS_DIR"
fi

# Create a valid empty plist if it does not exist
if [ ! -f "$PLIST_PATH" ]; then
  echo "Creating new empty plist file..."
  sudo /usr/libexec/PlistBuddy -c "Clear" "$PLIST_PATH" 2>/dev/null || \
  sudo /usr/libexec/PlistBuddy -c "Save" "$PLIST_PATH" 2>/dev/null || \
  sudo /usr/libexec/PlistBuddy -c "Add :dummy string" "$PLIST_PATH"
fi

# Remove existing ExtensionInstallForcelist key if it exists
sudo /usr/libexec/PlistBuddy -c "Delete :ExtensionInstallForcelist" "$PLIST_PATH" 2>/dev/null

# Add the ExtensionInstallForcelist as an array with our extension string
sudo /usr/libexec/PlistBuddy -c "Add :ExtensionInstallForcelist array" "$PLIST_PATH"
sudo /usr/libexec/PlistBuddy -c "Add :ExtensionInstallForcelist:0 string $FORCE_INSTALL_STRING" "$PLIST_PATH"

# Set proper permissions and ownership
sudo chmod 644 "$PLIST_PATH"
sudo chown root:wheel "$PLIST_PATH"

echo "Extension $EXTENSION_ID installed in $PLIST_PATH."
echo "Please restart Microsoft Edge to activate the extension."
