#!/bin/bash

echo "Installing Produce8 Agent on macOS..."

# Get the working directory for Datto RMM (e.g., /Library/Application Support/CentraStage/Packages/...)
WORKING_DIR="$(dirname "$0")"
echo "Working dir: $WORKING_DIR"

# Path to the uploaded PKG file
PKG_PATH="$WORKING_DIR/Produce8-Agent-latest.pkg"
echo "Installing Produce8 Agent from: $PKG_PATH"

# Run the installer
# If your PKG supports custom arguments (like ACCOUNTID), use the environment variable approach
ACCOUNT_ID=#

# Check if accountId was updated
if [[ "$ACCOUNT_ID" == *"#"* ]]; then
  echo "Error: Please replace '#' with a valid accountId."
  exit 1
fi

CONFIG_FILE_DIR="/Users/Shared/Produce8-Agent"
mkdir $CONFIG_FILE_DIR
echo "account.accountId=$ACCOUNT_ID" > "$CONFIG_FILE_DIR/account.properties"
sudo installer -pkg "$PKG_PATH" -target /

INSTALL_EXIT_CODE=$?
if [ $INSTALL_EXIT_CODE -eq 0 ]; then
    echo "Produce8 Agent installed successfully."
else
    echo "Installation failed with exit code $INSTALL_EXIT_CODE."
    exit $INSTALL_EXIT_CODE
fi
