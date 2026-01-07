# PowerShell Script to Remove Produce8 Extensions from Chrome, Edge, and Firefox
# Run this script with administrative privileges
# The browsers will require a restart for changes to take effect

Write-Output "=========================================="
Write-Output "Uninstalling Produce8 Browser Extensions"
Write-Output "=========================================="
Write-Output ""

# Helper function to convert PSCustomObject to Hashtable (for Firefox)
function ConvertTo-Hashtable {
    param([Parameter(ValueFromPipeline)]$InputObject)
    process {
        if ($null -eq $InputObject) { return $null }
        if ($InputObject -is [Hashtable]) { return $InputObject }
        if ($InputObject -is [PSCustomObject]) {
            $hash = @{}
            $InputObject.PSObject.Properties | ForEach-Object {
                $value = $_.Value
                if ($value -is [PSCustomObject]) {
                    $hash[$_.Name] = ConvertTo-Hashtable $value
                } elseif ($value -is [Array]) {
                    $hash[$_.Name] = $value | ForEach-Object { ConvertTo-Hashtable $_ }
                } else {
                    $hash[$_.Name] = $value
                }
            }
            return $hash
        }
        return $InputObject
    }
}

# Function to uninstall Chrome extension
function Uninstall-Chrome {
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
}

# Function to uninstall Edge extension
function Uninstall-Edge {
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
    
}

# Function to uninstall Firefox extension
function Uninstall-Firefox {
# PowerShell Script to Remove Firefox Extension via Group Policy (policies.json)
# Run this script with administrative privileges
# The browser will require a restart for changes to take effect

# Helper function to convert PSCustomObject to Hashtable
function ConvertTo-Hashtable {
    param([Parameter(ValueFromPipeline)]$InputObject)
    process {
        if ($null -eq $InputObject) { return $null }
        if ($InputObject -is [Hashtable]) { return $InputObject }
        if ($InputObject -is [PSCustomObject]) {
            $hash = @{}
            $InputObject.PSObject.Properties | ForEach-Object {
                $value = $_.Value
                if ($value -is [PSCustomObject]) {
                    $hash[$_.Name] = ConvertTo-Hashtable $value
                } elseif ($value -is [Array]) {
                    $hash[$_.Name] = $value | ForEach-Object { ConvertTo-Hashtable $_ }
                } else {
                    $hash[$_.Name] = $value
                }
            }
            return $hash
        }
        return $InputObject
    }
}

Write-Output "Uninstalling P8 extension policy for Mozilla Firefox"

# Extension ID (must match install script)
$extensionId = "support@produce8.com"

# Remove extension policy from policies.json
Write-Output "Removing extension from policies.json"

$firefoxPaths = @(
    "${env:ProgramFiles}\Mozilla Firefox",
    "${env:ProgramFiles(x86)}\Mozilla Firefox"
)

$firefoxPath = $null
foreach ($path in $firefoxPaths) {
    if (Test-Path $path) {
        $firefoxPath = $path
        break
    }
}

if ($firefoxPath) {
    $policiesFile = Join-Path $firefoxPath "distribution\policies.json"
    
    if (Test-Path $policiesFile) {
        try {
            $existingContent = Get-Content $policiesFile -Raw -ErrorAction Stop
            $policies = $existingContent | ConvertFrom-Json -ErrorAction Stop | ConvertTo-Hashtable
            
            # Check if our extension exists in ExtensionSettings
            if ($policies.policies -and $policies.policies.ExtensionSettings -and $policies.policies.ExtensionSettings.ContainsKey($extensionId)) {
                $policies.policies.ExtensionSettings.Remove($extensionId)
                Write-Output "Removed extension from ExtensionSettings"
                
                # Clean up empty sections
                if ($policies.policies.ExtensionSettings.Count -eq 0) {
                    $policies.policies.Remove("ExtensionSettings")
                }
                if ($policies.policies.Count -eq 0) {
                    $policies.Remove("policies")
                }
                
                # Delete file if empty, otherwise update it
                if ($policies.Count -eq 0) {
                    Remove-Item $policiesFile -Force -ErrorAction Stop
                    Write-Output "Removed policies.json (file was empty)"
                } else {
                    $jsonContent = $policies | ConvertTo-Json -Depth 10
                    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                    [System.IO.File]::WriteAllText($policiesFile, $jsonContent, $utf8NoBom)
                    Write-Output "Updated policies.json (removed extension)"
                }
            } else {
                Write-Output "Extension not found in policies.json"
            }
        } catch {
            Write-Output "WARNING: Could not update policies.json: $_"
        }
    } else {
        Write-Output "policies.json not found (may already be removed)"
    }
} else {
    Write-Output "Firefox installation directory not found"
}

# Remove extension XPI file from all user profiles
Write-Output ""
Write-Output "Removing extension XPI files from user profiles..."

# Check all user profiles on the system (not just current user)
$usersPath = "C:\Users"
$allProfilesFound = 0

if (Test-Path $usersPath) {
    $users = Get-ChildItem -Path $usersPath -Directory -ErrorAction SilentlyContinue
    foreach ($user in $users) {
        # Skip default system accounts
        if ($user.Name -match '^(Default|Public|All Users)$') {
            continue
        }
        
        $userAppData = Join-Path $user.FullName "AppData\Roaming\Mozilla\Firefox\Profiles"
        Write-Output "User app data: $userAppData"
        
        if (Test-Path $userAppData) {
            Write-Output "Checking user: $($user.Name)"
            Write-Output "  Profile path: $userAppData"
            
            $profiles = Get-ChildItem -Path $userAppData -Directory -ErrorAction SilentlyContinue
            
            Write-Output "Profiles: $profiles"
            
            if ($null -ne $profiles -and $profiles.Count -gt 0) {
                Write-Output "  Found $($profiles.Count) profile(s)"
                
                foreach ($profile in $profiles) {
                    $extensionsDir = Join-Path $profile.FullName "extensions"
                    $extensionXpi = Join-Path $extensionsDir "$extensionId.xpi"
                    $renamedXpi = Join-Path $extensionsDir "$extensionId.xpi.removed"
                    
                    # First, try to clean up any previously renamed files (in case Firefox is now closed)
                    if (Test-Path $renamedXpi) {
                        try {
                            Remove-Item $renamedXpi -Force -ErrorAction Stop
                            Write-Output "Cleaned up previously renamed file: $renamedXpi"
                            $allProfilesFound++
                        } catch {
                            Write-Output "WARNING: Could not clean up previously renamed file."
                            # File still locked, skip it
                        }
                    }
                    
                    # Now try to remove the current XPI file
                    if (Test-Path $extensionXpi) {
                        try {
                            # Try to delete the file first
                            Remove-Item $extensionXpi -Force -ErrorAction Stop
                            Write-Output "Removed: $extensionXpi"
                            $allProfilesFound++
                        } catch {
                            # If deletion fails (likely because Firefox is running), rename it instead
                            # Firefox won't find it with a different name, so the extension won't load
                            try {
                                Rename-Item -Path $extensionXpi -NewName "$extensionId.xpi.removed" -Force -ErrorAction Stop
                                Write-Output "Renamed (Firefox was running): $extensionXpi -> $renamedXpi"
                                Write-Output "Extension will not load. File will be deleted when Firefox is closed and script is run again"
                                $allProfilesFound++
                            } catch {
                                Write-Output "WARNING: Could not delete or rename $extensionXpi - $_"
                                Write-Output "Please close Firefox completely and run this script again"
                            }
                        }
                    }
                }
            }
        }
    }
    
    if ($allProfilesFound -eq 0) {
        Write-Output "No extension files found in any user profiles"
    }
} else {
    Write-Output "Users directory not found: $usersPath"
}

Write-Output ""
Write-Output "Uninstall complete. Please completely close Firefox and restart it to apply changes."

}

# Main execution
Uninstall-Chrome
Uninstall-Edge
Uninstall-Firefox

Write-Output "=========================================="
Write-Output "Uninstall Complete"
Write-Output "=========================================="
Write-Output "Please restart your browsers for changes to take effect."
Write-Output "You may need to reboot the system for full cleanup."