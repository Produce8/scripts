# PowerShell Script to install Firefox Extension Registry Policy 
# Run this script with administrative privileges in order to modify the registry
# The browser will require a restart to enable the extension

# Define the extension URL
Write-Output "Installing P8 extension policy for Mozilla Firefox"
$extensionURL = "https://addons.mozilla.org/firefox/downloads/latest/produce8-agent/latest.xpi"

# Define the registry path for Firefox Extensions
$regPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install"

# Check if registry path exists
if (-not (Test-Path $regPath)) {
    # Create the registry path
    New-Item -Path $regPath -Force | Out-Null
    Write-Output "Created registry path: $regPath"
}

# Find next available registry key
$existingKeys = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Where-Object { $_ -match '^\d+$' }
$regValueName = 1
if ($existingKeys) {
    $maxKey = ($existingKeys | ForEach-Object { [int]$_ } | Measure-Object -Maximum).Maximum
    $regValueName = $maxKey + 1
}

# Check if extension URL already exists
$existingProps = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
$alreadyExists = $false
if ($existingProps) {
    $existingProps.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS(.*)' } | ForEach-Object {
        if ($_.Value -eq $extensionURL) {
            Write-Output "Extension already registered with key: $($_.Name)"
            $alreadyExists = $true
        }
    }
}

# Add the registry entry if it doesn't already exist
if (-not $alreadyExists) {
    Set-ItemProperty -Path $regPath -Name $regValueName -Value $extensionURL -Force
    Write-Output "Registered extension with key: $regValueName"
    Write-Output "Extension URL: $extensionURL"
}

Write-Output "Installation complete. Mozilla Firefox extension policy set."
Write-Output "Restart Firefox to apply changes."
