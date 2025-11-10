# PowerShell Script to install Brave Browser Extension Registry Policy
# Run this script with administrative privileges in order to modify the registry
# The browser will require a restart to enable the extension

Write-Output "Installing P8 extension policy for Brave Browser..."

# Define the extension ID and update URL
$extensionID = "kjdhkfobigjnlanlfjakbbibdbakdcnc"
$updateURL = "https://clients2.google.com/service/update2/crx"

# Define the registry path for Brave Extensions
$regPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist"

# Check if registry path exists
if (-not (Test-Path $regPath)) {
    # Create the registry path
    New-Item -Path $regPath -Force
    Write-Output "Created registry path: $regPath"
}

# Define the registry entry for the extension
$regValue = "$extensionID;$updateURL"

# Add the registry entry (increment "1" if this entry is in use)
Set-ItemProperty -Path $regPath -Name "1" -Value $regValue -Force

Write-Output "Installation complete. Brave extension policy set. Restart Brave to apply changes."
