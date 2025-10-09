$AppName     = "Produce8"
$ProductCode = $null

# Kill process if running
Write-Host "Stopping $AppName if it is running..."
if (Get-Process -Name $AppName -ErrorAction SilentlyContinue) {
    Stop-Process -Name $AppName -Force
    Write-Host "Process $AppName stopped."
} else {
    Write-Host "No running process $AppName found."
}

# Registry keys where uninstall info is stored
$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

Write-Host "Searching for $AppName in installed programs..."
foreach ($key in $UninstallKeys) {
    $subKeys = Get-ChildItem $key -ErrorAction SilentlyContinue
    foreach ($subKey in $subKeys) {
        $props = Get-ItemProperty $subKey.PSPath -ErrorAction SilentlyContinue
        if ($props.DisplayName -and $props.DisplayName -like "*$AppName*") {
            Write-Host "Found installed app: $($props.DisplayName) $($props.DisplayVersion)"
            if ($props.PSChildName -match "^{.*}$") {
                $ProductCode = $props.PSChildName # Registry key found matching desktop app name
            } elseif ($props.UninstallString) {
                $ProductCode = $props.UninstallString
            }
            break
        }
    } 
    if ($ProductCode) { break } # Stop searching through registry keys if the desktop app was found
}

if ($ProductCode) {
    if ($ProductCode -match "^{.*}$") {
        Write-Host "Uninstalling $AppName via msiexec ProductCode $ProductCode..."
        Start-Process "msiexec.exe" -ArgumentList "/x $ProductCode /qn /norestart" -Wait -NoNewWindow
        Write-Host "$AppName has been uninstalled successfully."
    } else {
        Write-Host "Uninstalling $AppName via UninstallString: $ProductCode"
        Start-Process "cmd.exe" -ArgumentList "/c `"$ProductCode /qn /norestart`"" -Wait -NoNewWindow
        Write-Host "$AppName has been uninstalled successfully."
    }
} else {
    Write-Host "Could not find an installed program matching $AppName."
}
