#Install Chrome Browser Extension
# PowerShell Script for Chrome Extension Deployment via Group Policy

# Define the extension ID and update URL
$extensionID = "kjdhkfobigjnlanlfjakbbibdbakdcnc"
$updateURL = "https://clients2.google.com/service/update2/crx"

# Define the registry path for Chrome Extensions
$regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"

# Check if registry path exists
if(-not (Test-Path $regPath)) {
    # Create the registry path
    New-Item -Path $regPath -Force
}

# Define the registry entry for the extension
$regValue = "$extensionID;$updateURL"

# Add the registry entry
Set-ItemProperty -Path $regPath -Name "1" -Value $regValue -Force

# Note: Ensure that PowerShell is run with administrative privileges to modify the registry

