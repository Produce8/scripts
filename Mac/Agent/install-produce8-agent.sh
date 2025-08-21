#!/bin/bash

# Create the account properties config file 
# Set your account id by replacing # in the next line. ie. accountId=59079b49-772c-453b-bb33-70a04e372466
accountId=#
configFileDir="/Users/Shared/Produce8-Agent"

# Check if accountId was updated
if [[ "$accountId" == *"#"* ]]; then
  echo "Error: Please replace '#' with a valid accountId."
  exit 1
fi

mkdir $configFileDir
echo "account.accountId=$accountId" > "$configFileDir/account.properties"

# Optionally, you can add a departmentId by uncommenting the lines below and replacing # with the desired department id before running the script
# departmentId=#
# if [[ "$departmentId" == *"#"* ]]; then
#   echo "Error: Please replace '#' with a valid departmentId."
#   exit 1
# fi
# echo "departmentId=$departmentId" >> "$configFileDir/account.properties"

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
