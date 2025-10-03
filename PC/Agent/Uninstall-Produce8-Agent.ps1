$processName = "Produce8-Agent"
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Stop-Process -Name $processName -Force
    Write-Output "Process '$processName' stopped."
} else {
    Write-Output "Process '$processName' is not running. Continue to uninstall."
}

if (Get-Package -Name $processName) {
    if (Uninstall-Package -Name $processName -Force -Verbose) {
        Write-Output "$processName has been uninstalled successfully."
    } else {
        Write-Output "Failed to uninstall '$processName'."
    }
} else {
    Write-Output "Package '$processName' cannot be found."
}