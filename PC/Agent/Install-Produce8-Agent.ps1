$tempDir = ""

if (Test-Path -Path 'C:\tmp'){
    $tempDir = "C:\tmp"
}
elseif (Test-Path -Path 'C:\temp'){
    $tempDir = "C:\temp"
} else {
    throw 'No temp directory found. Aborting installation.'
}

$path = $tempDir+'\produce8-agent-latest.msi'

Invoke-WebRequest https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/x64/Produce8-Agent-latest.msi -OutFile $path 
# Run it with the right accountId 
# ie. Start-Process -Wait msiexec -argumentlist "/i C:\tmp\produce8.msi /quiet ACCOUNTID=59079b49-772c-453b-bb33-70a04e372466"
Start-Process -Wait msiexec -argumentlist "/i $path /quiet ACCOUNTID=###"
