[cmdletbinding()]
Param()

# Connection details
$InfluxConn = @{
    URI    = 'http://localhost:8086/write?db=metrics'
    Method = 'POST'
}
  
# Optional tags
$Hostname = $env:ComputerName
$Region = 'UKSouth'

While (1) {

    $CPU = ((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples |
        Where-Object { $_.InstanceName -eq '_total' }).CookedValue
  
    # This is the Influx line protocol
    $Metric = "cpu_load,Host=$Hostname,Region=$Region value=$CPU"
    
    Invoke-RestMethod @InfluxConn -Body $Metric -Verbose
  
    Start-Sleep -Seconds 5
}

# Visualise in Grafana