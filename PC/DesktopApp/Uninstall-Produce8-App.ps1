$AppName     = "Produce8"
$ProductCode = $null

# Kill process if running
Write-Output "Stopping $AppName if it is running..."
if (Get-Process -Name $AppName -ErrorAction SilentlyContinue) {
    Stop-Process -Name $AppName -Force
    Write-Output "Process $AppName stopped."
} else {
    Write-Output "No running process $AppName found."
}

# Registry keys where uninstall info is stored
$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

Write-Output "Searching for $AppName in installed programs..."
foreach ($key in $UninstallKeys) {
    $subKeys = Get-ChildItem $key -ErrorAction SilentlyContinue
    foreach ($subKey in $subKeys) {
        $props = Get-ItemProperty $subKey.PSPath -ErrorAction SilentlyContinue
        if ($props.DisplayName -and $props.DisplayName -like "*$AppName*") {
            Write-Output "Found installed app: $($props.DisplayName) $($props.DisplayVersion)"
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
        Write-Output "Uninstalling $AppName via msiexec ProductCode $ProductCode..."
        Start-Process "msiexec.exe" -ArgumentList "/x $ProductCode /qn /norestart" -Wait -NoNewWindow
        Write-Output "$AppName has been uninstalled successfully."
    } else {
        Write-Output "Uninstalling $AppName via UninstallString: $ProductCode"
        Start-Process "cmd.exe" -ArgumentList "/c `"$ProductCode /qn /norestart`"" -Wait -NoNewWindow
        Write-Output "$AppName has been uninstalled successfully."
    }
} else {
    Write-Output "Could not find an installed program matching $AppName."
}
