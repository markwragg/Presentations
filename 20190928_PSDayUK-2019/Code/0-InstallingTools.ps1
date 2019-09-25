[cmdletbinding()]
Param(
    $grafana_version = '6.3.6',
    $grafana_port = 8080,

    $influx_version = '1.7.8',
    $influx_port = 8086,
    
    $influx_database = 'metrics',

    $enable_udp_listener = $true,
    $influx_udp_port = 8089,
    $influx_udp_database = 'metrics'
)

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }
}

if (-not (Test-IsAdmin)) { Throw 'Please run this script as Administrator.' }

Push-Location

# Prereqs

## Install Chocolately

Write-Host 'Installing Chocolatey..'

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path = $env:PATH + ";$env:ALLUSERSPROFILE\chocolatey\bin"

## Install non-sucking service manager

choco install -y nssm

# Install

## Install and configure Grafana

Write-Host 'Installing Grafana..'

Set-Location C:\
Invoke-WebRequest https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${grafana_version}.windows-amd64.zip -OutFile Grafana.zip
Expand-Archive C:\Grafana.zip
Get-Item C:\Grafana\Grafana* | Rename-Item -NewName Grafana

$GrafanaConfig = 'C:\Grafana\Grafana\conf\defaults.ini'
(Get-Content $GrafanaConfig).Replace('http_port = 3000', "http_port = ${grafana_port}") | Set-Content $GrafanaConfig

New-NetFirewallRule -DisplayName "Grafana" -Direction Inbound -Action Allow -LocalPort ${grafana_port} -Protocol TCP

nssm install Grafana "C:\Grafana\Grafana\bin\grafana-server.exe" 
Start-Service Grafana

## Install and configure Influx

Write-Host 'Installing Influx..'

Set-Location C:\
Invoke-WebRequest https://dl.influxdata.com/influxdb/releases/influxdb-${influx_version}_windows_amd64.zip -OutFile Influx.zip
Expand-Archive C:\Influx.zip
Get-Item C:\Influx\InfluxDB* | Rename-Item -NewName InfluxDB

$InfluxConfig = 'C:\Influx\InfluxDB\influxdb.conf'
(Get-Content $InfluxConfig).Replace('# bind-address = ":8086"', "bind-address = "":${influx_port}""") | Set-Content $InfluxConfig

New-NetFirewallRule -DisplayName "Influx" -Direction Inbound -Action Allow -LocalPort ${influx_port} -Protocol TCP

nssm install InfluxDB "C:\Influx\InfluxDB\influxd.exe" """-config C:\Influx\InfluxDB\influxdb.conf"""
Start-Service InfluxDB

Write-Host "Creating Influx Database '${influx_database}'.."

C:\Influx\InfluxDB\influx.exe -execute "CREATE DATABASE ${influx_database}"


if ($enable_udp_listener -eq $true) {

    Write-Host 'Adding UDP listener for Influx..'

    $UDPConfig = @"
[[udp]]
enabled = true
bind-address = ":${influx_udp_port}"
database = "${influx_udp_database}"
batch-size = 5000
batch-timeout = "1s"
batch-pending = 10
read-buffer = 0
"@
    Add-Content -Path $InfluxConfig -Value $UDPConfig
    New-NetFirewallRule -DisplayName "InfluxUDP" -Direction Inbound -Action Allow -LocalPort ${influx_udp_port} -Protocol UDP
    C:\Influx\InfluxDB\influx.exe -execute 'CREATE DATABASE ${influx_udp_database}'
    Restart-Service InfluxDB
}

Write-Host 'Done!' -ForegroundColor Green

Pop-Location