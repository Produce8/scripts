# pkill "Produce8-Agent"
pkgFilePath="{path of PKG file}"

echo "PKG file starting."

# Install the .pkg file using the installer command
sudo installer -pkg "$pkgFilePath" -target /Applications -dumplog

echo "PKG file installed."

open -n /Applications/Produce8-Agent.app 