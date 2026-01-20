# MonitorMemoryUsage.ps1
# Monitors memory usage of a specific executable and logs to a text file

param(
    [string]$ProcessName = "LemonTree.exe",
    [string]$LogFile = "MemoryUsageLog.txt",
    [int]$IntervalSeconds = 10
)

Write-Host "Monitoring memory usage for process: $ProcessName"
Write-Host "Logging to: $LogFile"
Write-Host "Interval: $IntervalSeconds seconds"

"Timestamp,ProcessName,PID,WorkingSet(MB),PrivateMemory(MB)" | Out-File -FilePath $LogFile -Encoding utf8

while ($true) {
    $processes = Get-Process | Where-Object { $_.ProcessName -eq ($ProcessName -replace ".exe$", "") }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($processes) {
        foreach ($proc in $processes) {
            $line = "{0},{1},{2},{3:N2},{4:N2}" -f $timestamp, $proc.ProcessName, $proc.Id, ($proc.WorkingSet64/1MB), ($proc.PrivateMemorySize64/1MB)
            $line | Out-File -FilePath $LogFile -Append -Encoding utf8
        }
    } else {
        $line = "{0},{1},N/A,N/A,N/A" -f $timestamp, $ProcessName
        $line | Out-File -FilePath $LogFile -Append -Encoding utf8
    }
    Start-Sleep -Seconds $IntervalSeconds
}
