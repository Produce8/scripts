# PowerShell Script to install Firefox Extension Registry Policy 
# Run this script with administrative privileges in order to modify the registry
# The broswer will require a restart to enable the extension

$extensionURL   = "https://addons.mozilla.org/firefox/downloads/latest/produce8-agent/latest.xpi"
$localTempDir   = Join-Path $env:TEMP "FirefoxExtension"
$localXpiPath   = Join-Path $localTempDir "produce8-agent.xpi"
$regPath        = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install"

Write-Output "Instaling P8 extension policy for Mozilla Firefox"

# Create local folder
if (-not (Test-Path $localTempDir)) { 
    New-Item -Path $localTempDir -ItemType Directory | Out-Null
    Write-Output "Created local folder: $localTempDir"
} else {
    Write-Output "Local folder already exists: $localTempDir"
}

# Download the extension
try {
    Write-Output "Downloading extension from $extensionURL..."
    Invoke-WebRequest -Uri $extensionURL -OutFile $localXpiPath -UseBasicParsing
    Write-Output "Extension downloaded to $localXpiPath"
} catch {
    Write-Output "ERROR: Failed to download extension. $_"
    throw
}

# Ensure registry path exists
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Output "Created registry path: $regPath"
} else {
    Write-Output "Registry path already exists: $regPath"
}

# Find next available registry key
$existingKeys = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$regValueName = 1
while ($existingKeys -contains $regValueName.ToString()) { $regValueName++ }
Write-Output "Using registry key: $regValueName"

# Add registry entry
Set-ItemProperty -Path $regPath -Name $regValueName -Value $localXpiPath -Force
Write-Output "Registry updated to install extension."

Write-Output "Installation complete. Verify in Firefox: about:policies -> Active Policies."
