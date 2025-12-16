# PowerShell Script to install Firefox Extension via Group Policy (policies.json)
# Run this script with administrative privileges
# The browser will require a restart to enable the extension

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

Write-Output "Installing P8 extension policy for Mozilla Firefox"

# Extension configuration
$extensionId = "support@produce8.com"
$installUrl = "https://addons.mozilla.org/firefox/downloads/file/4579169/produce8_agent-3.1.37.xpi"

# Find Firefox installation directory
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

if (-not $firefoxPath) {
    Write-Output "ERROR: Could not find Firefox installation directory"
    Write-Output "Searched in: $($firefoxPaths -join ', ')"
    exit 1
}

Write-Output "Found Firefox installation: $firefoxPath"

# Define policies.json location
$distributionDir = Join-Path $firefoxPath "distribution"
$policiesFile = Join-Path $distributionDir "policies.json"

# Create distribution directory if it doesn't exist
if (-not (Test-Path $distributionDir)) {
    try {
        New-Item -Path $distributionDir -ItemType Directory -Force | Out-Null
        Write-Output "Created distribution directory: $distributionDir"
    } catch {
        Write-Output "ERROR: Could not create distribution directory: $_"
        exit 1
    }
}

# Read existing policies.json if it exists
$policies = @{}
if (Test-Path $policiesFile) {
    try {
        $existingContent = Get-Content $policiesFile -Raw -ErrorAction Stop
        $policies = $existingContent | ConvertFrom-Json -ErrorAction Stop | ConvertTo-Hashtable
        Write-Output "Found existing policies.json, preserving existing policies..."
    } catch {
        Write-Output "WARNING: Could not parse existing policies.json, will create new one"
        Write-Output "Error: $_"
        $policies = @{}
    }
}

# Ensure policies structure exists
if (-not $policies.ContainsKey("policies")) {
    $policies["policies"] = @{}
}

# Convert to hashtable if it's a PSCustomObject
if ($policies["policies"] -is [PSCustomObject]) {
    $policies["policies"] = $policies["policies"] | ConvertTo-Hashtable
}

# Ensure ExtensionSettings exists
if (-not $policies["policies"].ContainsKey("ExtensionSettings")) {
    $policies["policies"]["ExtensionSettings"] = @{}
}

# Convert ExtensionSettings to hashtable if needed
if ($policies["policies"]["ExtensionSettings"] -is [PSCustomObject]) {
    $policies["policies"]["ExtensionSettings"] = $policies["policies"]["ExtensionSettings"] | ConvertTo-Hashtable
}

# Add or update our extension
$policies["policies"]["ExtensionSettings"][$extensionId] = @{
    installation_mode = "force_installed"
    install_url = $installUrl
}

# Convert back to JSON with proper formatting
$jsonContent = $policies | ConvertTo-Json -Depth 10

# Write policies.json file with UTF-8 encoding without BOM (Firefox requirement)
try {
    # Use UTF8NoBOM encoding
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($policiesFile, $jsonContent, $utf8NoBom)
    Write-Output "Successfully created/updated policies.json at: $policiesFile"
} catch {
    Write-Output "ERROR: Could not write policies.json file: $_"
    exit 1
}

Write-Output ""
Write-Output "Policy file contents:"
Write-Output $jsonContent
Write-Output ""
Write-Output "Installation complete. Mozilla Firefox extension policy set."
Write-Output "Restart Firefox to apply changes."
