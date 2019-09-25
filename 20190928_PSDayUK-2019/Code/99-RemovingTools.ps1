[cmdletbinding()]
Param()

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

# Removal script for Influx and Grafana

## Remove Grafana

if ((Read-Host 'Are you sure you want to remove Grafana?') -eq 'y'){

    Stop-Service Grafana -Force

    nssm remove Grafana confirm
    
    While (Get-Service Grafana -ErrorAction SilentlyContinue) {
        Write-Host 'Waiting for Grafana Service to be removed..'
        Start-Sleep 5
    }

    Write-Host 'Removing Grafana Files..'
    Remove-Item -LiteralPath 'C:\Grafana' -Recurse -Force

    Write-Host 'Removing Grafana FireWall rule..'
    Get-NetFirewallRule -DisplayName "Grafana" | Remove-NetFirewallRule -Verbose
}

## Remove InfluxDB

if ((Read-Host 'Are you sure you want to remove InfluxDB?') -eq 'y'){

    Stop-Service InfluxDB -Force

    nssm remove InfluxDB confirm
    
    While (Get-Service InfluxDB -ErrorAction SilentlyContinue) {
        Write-Host 'Waiting for InfluxDB Service to be removed..'
        Start-Sleep 5
    }

    Write-Host 'Removing Influx Files..'
    Remove-Item -LiteralPath 'C:\Influx' -Recurse -Force
    
    Get-NetFirewallRule -DisplayName "Influx" | Remove-NetFirewallRule -Verbose
    Get-NetFirewallRule -DisplayName "InfluxUDP" | Remove-NetFirewallRule -Verbose
}