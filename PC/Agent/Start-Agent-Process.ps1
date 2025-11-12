$agentExePath = "C:\Program Files\Produce8-Agent\Produce8-Agent.exe"
$agentProcessName = "Produce8-Agent"

# Check if the process is already running
$isAgentProcessRunning = Get-Process -Name $agentProcessName -ErrorAction SilentlyContinue

if ($isAgentProcessRunning) {
    Write-Output "Produce8-Agent is already running. PID: $($isAgentProcessRunning.Id)"
} else {
    # Check if the executable exists
    if (Test-Path $agentExePath) {
        Write-Output "Starting Produce8-Agent..."
        Start-Process -FilePath $agentExePath

        # Wait for 5 seconds to allow process to startup
        Start-Sleep -Seconds 5

        # Check if the process started
        $processCheck = Get-Process -Name $agentProcessName -ErrorAction SilentlyContinue
        if ($processCheck) {
            Write-Output "Produce8-Agent started successfully. PID: $($processCheck.Id)"
        } else {
            Write-Output "Error: Produce8-Agent failed to start."
        }
    } else {
        Write-Output "Error: Produce8-Agent executable not found at $agentExePath"
    }
}
