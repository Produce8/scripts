# PowerShell Script to Remove Google Chrome Extension Registry Policy
# Run this script with administrative privileges
# The browser will require a restart for changes to take effect

Write-Output "Uninstalling P8 extension policy for Google Chrome"

# Registry path for Chrome ExtensionInstallForcelist
$regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
$extensionID = "kjdhkfobigjnlanlfjakbbibdbakdcnc"
$updateURL   = "https://clients2.google.com/service/update2/crx"
$regValue    = "$extensionID;$updateURL"

if (Test-Path $regPath) {
    $props = Get-ItemProperty -Path $regPath
    $removed = $false

    foreach ($prop in $props.PSObject.Properties) {
        if ($prop.Value -eq $regValue) {
            try {
                Remove-ItemProperty -Path $regPath -Name $prop.Name -ErrorAction Stop
                Write-Output "Removed registry entry: $regPath\$($prop.Name)"
                $removed = $true
            }
            catch {
                Write-Output "Failed to remove $($prop.Name): $_"
            }
        }
    }

    # Clean up if the key is empty
    if ($removed) {
        $remaining = (Get-ItemProperty -Path $regPath).PSObject.Properties |
                     Where-Object { $_.Name -notmatch '^PS(.*)' }

        if (-not $remaining) {
            try {
                Remove-Item -Path $regPath -Recurse -Force
                Write-Output "Registry path $regPath was empty and has been removed."
            }
            catch {
                Write-Output "Failed to remove empty registry path: $_"
            }
        }
    }
    else {
        Write-Output "No matching Chrome extension policy found for Produce8 agent."
        exit
    }
} else {
    Write-Output "No Chrome extension policy registry path found."
    exit
}

Write-Output "Google Chrome extension policy uninstalled successfully. Restart Chrome to apply changes."
