# Install the Produce8 Desktop App
# This script checks for a temp directory and creates one if it doesn't exist
# and downloads the MSI installer from AWS S3 and finally runs the installer.
# Links for both x64 (default) and arm64 installers are included. 

# Set error action for error handling in RMM
$ErrorActionPreference = "Stop"

Write-Output "Running Produce8 Desktop App Installation Script"

# Create temp directory if it doesn't exist
Write-Output "Checking for temp directory..."
$tempDir = ""

if (Test-Path -Path 'C:\tmp'){
    $tempDir = "C:\tmp"
    Write-Output "Using existing temp directory: $tempDir"
} elseif (Test-Path -Path 'C:\temp'){
    $tempDir = "C:\temp"
    Write-Output "Using existing temp directory: $tempDir"
} else {
    Write-Output "Creating temp directory: C:\tmp"
    $tempDir = 'C:\tmp'
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    Write-Output "Temp directory created: $tempDir"
}

$path = Join-Path $tempDir 'produce8-app.msi'
Write-Output "MSI will be saved to: $path"

# Download the MSI
Write-Output "Downloading Produce8 Desktop App installer..."
try {
    $downloadUrl = "https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/win32/x64/Produce8.msi"
    #For ARM64 devices, use this URL instead:
    #$downloadUrl = "https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/win32/arm64/Produce8.msi"
    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $path -ErrorAction Stop
    Write-Output "Download completed successfully"
} catch {
    Write-Output "ERROR: Download failed - $($_.Exception.Message)"
    exit 1
}

# Verify the file was downloaded
if (-not (Test-Path $path)) {
    Write-Output "ERROR: Downloaded file not found at $path"
    exit 1
}

# Install the MSI
Write-Output "Installing Produce8 Desktop App..."
try {
    $installArgs = "/i `"$path`" /qn /norestart"
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Write-Output "Installation completed successfully"
} catch {
    Write-Output "ERROR: Installation failed - $($_.Exception.Message)"
    exit 1
}

Write-Output "Produce8 Desktop App Installation Completed"