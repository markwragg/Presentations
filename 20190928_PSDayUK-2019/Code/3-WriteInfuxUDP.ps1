[cmdletbinding()]
Param()

$InfluxConn = @{
    IP   = '127.0.0.1'
    Port = 8089
    # Note we can't point to a specific DB, its set on the listener config, but you could have multiple listeners
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

    Write-InfluxUDP @InfluxConn -Measure 'Server' -Metrics $Metrics -Tags $Tags

    Start-Sleep -Seconds 1
}

# Stop/Start Influx