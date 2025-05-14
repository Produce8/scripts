# ========================
# Produce8 Unified Installer
# ========================

# --- Deployment Switches ---
$DeployAgent            = $true
$DeployApp              = $true
$DeployEdgeExtension    = $true
$DeployChromeExtension  = $true

# --- Configuration Variables ---
$TempFolder         = "C:\temp"
$LogFile            = Join-Path $TempFolder "Produce8Installation.log"
$AgentMsiUrl        = "https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/x64/Produce8-Agent-latest.msi"
$AgentMsiFile       = Join-Path $TempFolder "produce8-agent.msi"
$AppMsiUrl          = "https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/win32/x64/Produce8.msi"
$AppMsiFile         = Join-Path $TempFolder "produce8-app.msi"
$AccountId          = "######"  # <-- Replace with your actual ACCOUNTID

# Browser Extension Info
$EdgeExtensionID    = "clfmhpehigjmbgobgdebalogdgohbafk"
$EdgeUpdateUrl      = "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
$ChromeExtensionID  = "kjdhkfobigjnlanlfjakbbibdbakdcnc"
$ChromeUpdateUrl    = "https://clients2.google.com/service/update2/crx"

# --- Ensure Temp Directory Exists ---
if (-not (Test-Path -Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null
}

# --- Function to Log Messages ---
function Write-Log {
    param ([string]$Message)
    "$((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) - $Message" | Out-File -FilePath $LogFile -Append
}

# --- Function to Install MSI ---
function Install-MSI {
    param (
        [string]$Url,
        [string]$FilePath,
        [string]$Arguments
    )
    Write-Log "Downloading MSI from $Url"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $FilePath -ErrorAction Stop
        Write-Log "Download complete: $FilePath"
    } catch {
        Write-Log "Download failed: $_"
        throw
    }

    Write-Log "Installing: $FilePath"
    try {
        Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i `"$FilePath`" $Arguments" -ErrorAction Stop
        Write-Log "Installation successful for $FilePath"
    } catch {
        Write-Log "Installation failed: $_"
        throw
    }
}

# --- Begin Main Execution ---
Write-Log "=== Produce8 Unified Installation Script Started ==="

# --- Install Produce8 Agent ---
if ($DeployAgent) {
    if ([string]::IsNullOrWhiteSpace($AccountId) -or $AccountId -eq "######") {
        Write-Log "ERROR: Account ID is not set. Please update the script."
        throw "Missing ACCOUNTID"
    }
    Install-MSI -Url $AgentMsiUrl -FilePath $AgentMsiFile -Arguments "/quiet ACCOUNTID=$AccountId"
}

# --- Install Produce8 Desktop App ---
if ($DeployApp) {
    Install-MSI -Url $AppMsiUrl -FilePath $AppMsiFile -Arguments "/quiet"
}

# --- Install EDGE Extension ---
if ($DeployEdgeExtension) {
    Write-Log "Configuring Edge Extension"
    $edgeRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
    if (-not (Test-Path $edgeRegPath)) {
        New-Item -Path $edgeRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $edgeRegPath -Name "1" -Value "$EdgeExtensionID;$EdgeUpdateUrl" -Force
    Write-Log "Edge Extension registered"
}

# --- Install Chrome Extension ---
if ($DeployChromeExtension) {
    Write-Log "Configuring Chrome Extension"
    $chromeRegPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
    if (-not (Test-Path $chromeRegPath)) {
        New-Item -Path $chromeRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $chromeRegPath -Name "1" -Value "$ChromeExtensionID;$ChromeUpdateUrl" -Force
    Write-Log "Chrome Extension registered"
}

# --- End of Script ---
Write-Log "=== Produce8 Unified Installation Script Completed ==="
 