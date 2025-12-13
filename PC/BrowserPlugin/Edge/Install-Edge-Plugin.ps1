# PowerShell Script to install Microsoft Edge Extension Registry Policy 
# Run this script with administrative privileges in order to modify the registry
# The broswer will require a restart to enable the extension

# Define the extension ID and update URL
Write-Output "Instaling P8 extension policy for Microsoft Edge"
$extensionID = "clfmhpehigjmbgobgdebalogdgohbafk"
$updateURL = "https://edge.microsoft.com/extensionwebstorebase/v1/crx"

# Define the registry path for Edge Extensions
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"

# Check if registry path exists
if(-not (Test-Path $regPath)) {
    # Create the registry path
    New-Item -Path $regPath -Force
	Write-Output "Created registry path: $regPath"
}

# Define the registry entry for the extension
$regValue = "$extensionID;$updateURL"

# Add the registry entry (increment "1" if this entry is in use)
Set-ItemProperty -Path $regPath -Name "1" -Value $regValue -Force

Write-Output "Installation complete. Edge extension policy set."
Write-Output "Restart Edge to apply changes."