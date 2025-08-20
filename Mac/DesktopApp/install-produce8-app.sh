#!/bin/bash

# Local path to save the installer pkg file
PKG_PATH="/tmp/Produce8.pkg"

# Download the pkg
curl -L "https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/darwin/x64/Produce8.pkg" -o "$PKG_PATH"

if [[ $? -ne 0 ]]; then
  echo "Unable to download the Produce8 desktop app installer file"
  exit 1
fi

# Run the installer (system-wide, requires sudo)
echo "Installing Produce8..."
sudo installer -pkg "$PKG_PATH" -target /

if [[ $? -eq 0 ]]; then
  echo "Produce8 installed successfully"
else
  echo "Installation failed"
  exit 1
fi
