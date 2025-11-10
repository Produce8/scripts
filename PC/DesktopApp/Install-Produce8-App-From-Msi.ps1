# This script is to be used when the installer is uploaded to RMM directly.
# For an all-in-one solution that downloads the installer and runs it,
# use the "Install-Produce8-App.ps1" script instead.

# Get the working directory for Datto RMM
$WorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Output "working dir: $WorkingDir"

# Path to the uploaded MSI file
$MsiPath = Join-Path $WorkingDir "Produce8.msi"
Write-Output "Installing Produce8 Desktop App from: $MsiPath"

Start-Process -Wait msiexec -argumentlist "/i $MsiPath"