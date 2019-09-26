[cmdletbinding()]
Param()

$InfluxConn = @{
    Server   = 'http://localhost:8086'
    Database = 'metrics'
}

$BootTime = (Get-CimInstance -ClassName win32_operatingsystem).lastbootuptime

$UnexpectedCheck = Get-EventLog -LogName System -After $BootTime |
Where-Object { $_.Source -eq 'EventLog' -and $_.EventID -eq 6008 }

$Restart = if ($UnexpectedCheck) { 'Unexpected Restart' } else { 'Restart' }

$Tags = @{
    Host       = $env:ComputerName
    Region     = 'UKSouth'
    Unexpected = [bool]$UnexpectedCheck
}

$Metrics = @{
    Restart = $Restart
}

Write-Influx @InfluxConn -Measure 'Startup' -Tags $Tags -Metrics $Metrics -TimeStamp $BootTime -Verbose

# Visualise with Grafana -- Need to change aggregation to count(), set fill to none.

<# Demonstrate annotations:

- Board Settings > Annotations
- Query: SELECT Restart,Host FROM Startup WHERE $timeFilter
- Text: Host

#>