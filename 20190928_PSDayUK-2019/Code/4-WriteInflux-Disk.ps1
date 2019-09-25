$InfluxConn = @{
    Server   = 'http://localhost:8086'
    Database = 'metrics'
}
  
While (1) {

    $Disks = Get-WmiObject -Class Win32_logicaldisk
  
    ForEach ($Disk in $Disks) {

        $Tags = @{
            Host     = $env:ComputerName
            DeviceID = $Disk.DeviceID
        }

        $Metrics = @{
            DeviceID   = $Disk.DeviceID
            VolumeName = $Disk.VolumeName
            Size       = $Disk.Size
            FreeSpace  = $Disk.FreeSpace
            UsedSpace  = ($Disk.Size - $Disk.FreeSpace)
        }

        Write-Influx @InfluxConn -Measure 'Disk' -Tags $Tags -Metrics $Metrics
    }
  
    Start-Sleep -Seconds 5
}

# Visualise in Grafana