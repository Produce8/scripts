$processName = "Produce8-Agent-dev"
Write-Output "Checking if process '$processName' is running..."
try {
    $proc = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($proc) {
        Stop-Process -Name $processName -Force -ErrorAction Stop
        Write-Output "Process '$processName' stopped."
    } else {
        Write-Output "Process '$processName' is not running. Continue to uninstall."
    }
}
catch {
    Write-Output "Error stopping process '$processName': $_"
}

Write-Output "checking if program '$processName' is installed..."
try {
    $pkg = Get-Package -Name $processName -ErrorAction SilentlyContinue
    if ($pkg) {
        Write-Output "Found $processName. Uninstalling..."
        try {
            Uninstall-Package -Name $processName -Force -ErrorAction Stop
            Write-Output "$processName has been uninstalled successfully."
        }
        catch {
            Write-Output "Failed to uninstall $processName via Uninstall-Package: $_"
        }
    } else {
        Write-Output "Package '$processName' cannot be found."
    }
}
catch {
    Write-Output "Error checking package '$processName': $_"
}

# List of files and folders to delete
$paths = @(
    "C:\Users\mthai\AppData\Roaming\Produce8-Agent-dev", # local db files
    "C:\Users\mthai\AppData\Local\Logs\Produce8-Agent-dev", # log files
    "C:\ProgramData\Produce8-Agent-dev", # account config
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force
            Write-Host "Deleted: $path"
        } catch {
            Write-Host "Failed to delete: $path — $($_.Exception.Message)"
        }
    } else {
        Write-Host "Path not found: $path"
    }
}