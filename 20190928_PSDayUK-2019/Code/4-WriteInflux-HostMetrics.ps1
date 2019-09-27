[cmdletbinding()]
Param()

$InfluxConn = @{
    Server   = 'http://localhost:8086'
    Database = 'metrics'
}

$Tags = @{
    Host     = $env:ComputerName
    Region   = 'UKSouth'
}

# Perf counters
$MemCounter = '\Memory\Available MBytes'
$CPUCounter = '\Processor(_Total)\% Processor Time'
$BytesSentCounter = '\Network Interface(*)\Bytes Sent/sec'
$BytesReceivedCounter = '\Network Interface(*)\Bytes Received/sec'
  
While (1) {

    $Metrics = @{
        Memory = (Get-Counter $MemCounter).CounterSamples[0].CookedValue
        CPU    = (Get-Counter $CPUCounter).CounterSamples[0].CookedValue
    }
  
    Write-Influx @InfluxConn -Measure 'Server' -Tags $Tags -Metrics $Metrics -Verbose

    $Metrics = @{
        BytesSent     = (Get-Counter $BytesSentCounter).CounterSamples[0].CookedValue
        BytesReceived = (Get-Counter $BytesReceivedCounter).CounterSamples[0].CookedValue
    }

    Write-Influx @InfluxConn -Measure 'Network' -Tags $Tags -Metrics $Metrics -Verbose

    $Disks = Get-WmiObject -Class 'Win32_logicaldisk'
  
    ForEach ($Disk in $Disks) {

        $Tags = @{
            Host     = $env:ComputerName
            Region   = 'UKSouth'
            DeviceID    = $Disk.DeviceID
            VolumeName  = $Disk.VolumeName
        }

        $Metrics = @{
            DeviceID    = $Disk.DeviceID
            VolumeName  = $Disk.VolumeName
            Size        = $Disk.Size
            FreeSpace   = $Disk.FreeSpace
            UsedSpace   = ($Disk.Size - $Disk.FreeSpace)
            FreePercent = ($Disk.FreeSpace / $Disk.Size) * 100
            UsedPercent = (($Disk.Size - $Disk.FreeSpace) / $Disk.Size) * 100
        }

        Write-Influx @InfluxConn -Measure 'Disk' -Tags $Tags -Metrics $Metrics -Verbose
    }    
  
    Start-Sleep -Seconds 5
}

# Visualise in Grafana