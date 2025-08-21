#!/bin/bash

# Temporary path to save the installer pkg file
PKG_PATH="/tmp/Produce8-Agent-latest.pkg"

# Download the pkg
curl -L "https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/pkg/arm64/Produce8-Agent-latest.pkg" -o "$PKG_PATH"

if [[ $? -ne 0 ]]; then
  echo "Unable to download the Produce8 agent installer file"
  exit 1
fi

# Run the installer for the system - requires elevated permissions
echo "Installing Produce8 Agent.."
sudo installer -pkg "$PKG_PATH" -target /

if [[ $? -eq 0 ]]; then
  echo "Produce8-Agent installed successfully"
else
  echo "Installation failed"
  exit 1
fi
