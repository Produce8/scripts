# This script will
#   1. Create a temporary directory 
#   2. Download the installer from AWS S3 to the temp directory
#   3. Run the installer from the temp directory

$tempDir = ""

if (Test-Path -Path 'C:\tmp'){
    $tempDir = "C:\tmp"
}
elseif (Test-Path -Path 'C:\temp'){
    $tempDir = "C:\temp"
} else {
    # Create the temp folder if it does not exist
    $tempDir = 'C:\tmp'
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
}

$path = $tempDir+'\produce8-agent-latest.msi'

Invoke-WebRequest https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/x64/Produce8-Agent-latest.msi -OutFile $path 

# For Arm64 devices use this link instead
#Invoke-WebRequest https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/arm64/Produce8-Agent-latest.msi -OutFile $path 

# Set your account id by replacing # in the next line.
# ie. Start-Process -Wait msiexec -argumentlist "/i C:\tmp\produce8.msi /quiet ACCOUNTID=59079b49-772c-453b-bb33-70a04e372466"
Start-Process -Wait msiexec -argumentlist "/i $path /quiet ACCOUNTID=#"
