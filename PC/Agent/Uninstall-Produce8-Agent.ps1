$processName = "Produce8-Agent"
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Stop-Process -Name $processName
    Write-Host "Process '$processName' stopped."
} else {
    Write-Host "Process '$processName' is not running. Continue to uninstall."
}

if (Get-Package -Name $processName) {
    Uninstall-Package -Name $processName -Force -Verbose
    Write-Host "$processName has been uninstalled successfully."
} else {
    Write-Host "Package '$processName' cannot be found."
}

