# Powershell script to install the Produce8 Agent
# This script will
#   1. Create a temporary directory if it doesn't exist
#   2. Download the installer from AWS S3 to the temp directory
#   3. Run the installer from the temp directory
# Links for both x64 (default) and arm64 installers are included. 

# Set error action for error handling in RMM
$ErrorActionPreference = "Stop"

Write-Output "Running Produce8 Agent Installation Script"

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

$path = Join-Path $tempDir 'produce8-agent-latest.msi'
Write-Output "MSI will be saved to: $path"

# Download the MSI
Write-Output "Downloading Produce8 Desktop App installer..."
try {
    $downloadUrl = "https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/x64/Produce8-Agent-latest.msi"
    #For ARM64 devices, use this URL instead:
    #$downloadUrl = "https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/arm64/Produce8-Agent-latest.msi "
    
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
    # Set your account id by replacing # in the next line. ie. ACCOUNTID=59079b49-772c-453b-bb33-70a04e372466
    # The account id can be found in the Produce8 portal under the "Account Settings" menu.
    $installArgs = "/i `"$path`" /qn /norestart ACCOUNTID=#"
    
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Write-Output "Installation completed successfully"
} catch {
    Write-Output "ERROR: Installation failed - $($_.Exception.Message)"
    exit 1
}

Write-Output "Produce8 Agent Installation Completed"
