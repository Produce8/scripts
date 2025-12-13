# PowerShell Script to Remove Firefox Extension Registry Policy
# Run this script with administrative privileges
# The browser will require a restart for changes to take effect

Write-Output "Uninstalling P8 extension policy for Mozilla Firefox"

# Registry path for Firefox Extensions
$regPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install"
$extensionURL = "https://addons.mozilla.org/firefox/downloads/latest/produce8-agent/latest.xpi"

if (Test-Path $regPath) {
    $props = Get-ItemProperty -Path $regPath
    $removed = $false

    foreach ($prop in $props.PSObject.Properties) {
        if ($prop.Value -eq $extensionURL) {
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
        Write-Output "No matching Firefox extension policy found for Produce8 agent."
        exit
    }
} else {
    Write-Output "No Firefox extension policy registry path found."
    exit
}

Write-Output "Mozilla Firefox extension policy uninstalled successfully. Restart Firefox to apply changes."