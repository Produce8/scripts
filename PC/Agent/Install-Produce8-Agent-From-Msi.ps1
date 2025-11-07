# This script is to be used when the installer is uploaded to RMM directly.
# For an all-in-one solution that downloads the installer and runs it,
# use the "Install-Produce8-Agent.ps1" script instead.

# Get the working directory for Datto RMM (e.g. C:/ProgramData/CentraStage/Packages/...)
$WorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Output "working dir: $WorkingDir"

# Path to the uploaded MSI file
$MsiPath = Join-Path $WorkingDir "Produce8-Agent-latest.msi"
Write-Output "Installing Produce8 Agent from: $MsiPath"

Start-Process -Wait msiexec -argumentlist "/i $MsiPath /quiet ACCOUNTID=#" # Replace # with your Account Id