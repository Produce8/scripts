# PowerShell Script to install Firefox Browser Extension Registry Policy
# Run this script with administrative privileges in order to modify the registry
# The broswer will require a restart to enable the extension

# Define the extension download URL
Write-Output "Instaling P8 extension for Firefox"
Write-Output "Downloading the extension .xpi."
$extensionURL = "https://addons.mozilla.org/firefox/downloads/latest/produce8-agent/latest.xpi"

# Define the registry path for Firefox Extensions
$regPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install"

# Creates the registry path if it does not exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
	Write-Output "Created registry path: $regPath"
}

# Add the registry entry (increment "1" if this entry is in use)
Set-ItemProperty -Path $regPath -Name "1" -Value $extensionURL -Force

Write-Output "Installation complete. Firefox extension policy set."