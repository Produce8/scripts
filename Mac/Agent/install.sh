# pkill "Produce8-Agent"
pkgFilePath="Produce8-Agent-1.0.585.pkg"

echo "PKG file starting."

# Install the .pkg file using the installer command
sudo installer -pkg "$pkgFilePath" -target /Applications -dumplog

echo "PKG file installed."

open -n /Applications/Produce8-Agent.app 