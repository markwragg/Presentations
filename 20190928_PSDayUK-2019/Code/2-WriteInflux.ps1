[cmdletbinding()]
Param()

$InfluxConn = @{
    Server   = 'http://localhost:8086'
    Database = 'metrics'
}
  
$Tags = @{
    Host   = $env:ComputerName
    Region = 'UKSouth'
}
  
$MemCounter = '\Memory\Available MBytes'
$CPUCounter = '\Processor(_Total)\% Processor Time'
  
While (1) {

    $Metrics = @{
        Memory = (Get-Counter $MemCounter).CounterSamples.CookedValue
        CPU    = (Get-Counter $CPUCounter).CounterSamples.CookedValue
    }
  
    Write-Influx @InfluxConn -Measure 'Server' -Tags $Tags -Metrics $Metrics
  
    Start-Sleep -Seconds 5
}

# Visualise in Grafana