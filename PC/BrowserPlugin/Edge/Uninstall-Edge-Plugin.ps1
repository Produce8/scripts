# PowerShell Script to Remove Microsoft Edge Extension Registry Policy
# Run this script with administrative privileges
# The browser will require a restart for changes to take effect

Write-Output "Uninstalling P8 extension policy for Microsoft Edge"

# Registry path for Edge ExtensionInstallForcelist
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
$extensionID = "clfmhpehigjmbgobgdebalogdgohbafk"
$updateURL   = "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
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
        Write-Output "No matching Edge extension policy found for Produce8 agent."
        exit
    }
} else {
    Write-Output "No Edge extension policy registry path found."
    exit
}

Write-Output "Microsoft Edge extension policy uninstalled successfully. Restart Edge to apply changes."
