[cmdletbinding()]
Param()

$InfluxConn = @{
    Server   = 'http://localhost:8086'
    Database = 'metrics'
}

$Metrics = @{
    App = 'MyApp'
}

Write-Host 'Starting deployment..'

If (-not (Test-Path $PSScriptRoot\MyApp\MyApp-Original.ps1)) {
    Write-Host 'Deploying MyApp2..'

    Write-Influx @InfluxConn -Measure 'Deployment' -Metrics @{App = 'MyApp-1.0.2'}

    Rename-Item $PSScriptRoot\MyApp\MyApp.ps1 -NewName MyApp-Original.ps1
    Rename-Item $PSScriptRoot\MyApp\MyApp2.ps1 -NewName MyApp.ps1   
}
ElseIf (Test-Path $PSScriptRoot\MyApp\MyApp3.ps1) {
    Write-Host 'Deploying MyApp3..'

    Write-Influx @InfluxConn -Measure 'Deployment' -Metrics @{App = 'MyApp-1.0.3'}

    Rename-Item $PSScriptRoot\MyApp\MyApp.ps1 -NewName MyApp2.ps1
    Rename-Item $PSScriptRoot\MyApp\MyApp3.ps1 -NewName MyApp.ps1   
}
Else {
    Write-Host 'Reverting to MyApp..'

    Write-Influx @InfluxConn -Measure 'Deployment' -Metrics @{App = 'MyApp-1.0.1'}

    Rename-Item $PSScriptRoot\MyApp\MyApp.ps1 -NewName MyApp3.ps1
    Rename-Item $PSScriptRoot\MyApp\MyApp-Original.ps1 -NewName MyApp.ps1
}

Write-Host 'Deployment complete!' -ForegroundColor Green

# Visualise Deployments: SELECT App FROM Deployment WHERE $timeFilter