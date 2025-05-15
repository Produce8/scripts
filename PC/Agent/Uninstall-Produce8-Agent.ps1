$processName = "Produce8-Agent-dev"
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Stop-Process -Name $processName
    Write-Host "Process '$processName' stopped."
} else {
    Write-Host "Process '$processName' is not running. Continue to uninstall."
}

Uninstall-Package -Name $processName -Force -Verbose
Write-Host "$processName has been uninstalled."
