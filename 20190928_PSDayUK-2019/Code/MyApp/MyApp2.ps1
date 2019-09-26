$Processes = Get-Process
$Services = Get-Service
$Files = Get-ChildItem C:\Temp

Start-Sleep (Get-Random -Min 5 -Max 15)