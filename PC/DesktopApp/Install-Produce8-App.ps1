## Install the Produce8 Desktop App
#Download the msi - x64 devices
Invoke-WebRequest https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/win32/x64/Produce8.msi -OutFile c:\tmp\produce8-app.msi 

#For ARM64 devices, the download link is slightly different
#Invoke-WebRequest https://p8desktopapp-v2-main.s3.us-west-2.amazonaws.com/%40cyclops/desktopapp/main/win32/arm64/Produce8.msi -OutFile c:\tmp\produce8-app.msi 

#run it
Start-Process -Wait msiexec -argumentlist "/i C:\tmp\produce8-app.msi"