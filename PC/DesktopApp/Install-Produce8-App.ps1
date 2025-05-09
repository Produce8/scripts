#Download the msi
Invoke-WebRequest https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/win32/x64/Produce8.msi -OutFile c:\tmp\produce8-app.msi 
#run it
Start-Process -Wait msiexec -argumentlist "/i C:\tmp\produce8-app.msi
