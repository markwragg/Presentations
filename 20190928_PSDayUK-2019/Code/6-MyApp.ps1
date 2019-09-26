$InfluxConn = @{
    IP   = '127.0.0.1'
    Port = 8089
}


While (1) {

    $Error.Clear()

    Try {
        $ExecutionTime = Measure-Command {
            . $PSScriptRoot\MyApp\MyApp.ps1
        }
    }
    Catch {
        Write-Error $_
    }
    Finally {
        $Tags = @{
            Host       = $env:ComputerName
            Region     = 'UKSouth'
        }
        
        $Metrics = @{ 
            ErrorCount    = $Error.Count
            ExecutionTime = $ExecutionTime.TotalSeconds
        }

        Write-InfluxUDP @InfluxConn -Measure 'MyApp' -Tags $Tags -Metrics $Metrics
    }
    
    Start-Sleep 5
}