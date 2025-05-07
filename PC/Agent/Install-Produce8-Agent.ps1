#Download the msi
Invoke-WebRequest https://desktop-agent-assets-main.s3.us-west-2.amazonaws.com/main/msi/x64/Produce8-Agent-latest.msi -OutFile c:\tmp\produce8.msi 
#Run it with the right accountId 
#ie. Start-Process -Wait msiexec -argumentlist "/i C:\tmp\produce8.msi /quiet ACCOUNTID=59079b49-772c-453b-bb33-70a04e372466"
Start-Process -Wait msiexec -argumentlist "/i C:\tmp\produce8.msi /quiet ACCOUNTID=###"
