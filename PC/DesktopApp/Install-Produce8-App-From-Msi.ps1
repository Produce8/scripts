# Add this example script to a Datto component and upload the MSI file directly within the same component.

# Get the working directory for Datto RMM
$WorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Output "working dir: $WorkingDir"

# Path to the uploaded MSI file
$MsiPath = Join-Path $WorkingDir "Produce8.msi"
Write-Output "Installing Produce8 Desktop App from: $MsiPath"

Start-Process -Wait msiexec -argumentlist "/i $MsiPath"