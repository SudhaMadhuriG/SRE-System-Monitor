# Display computer name
Write-Output "Computer: $env:COMPUTERNAME"

# Retrieve operating system information
$os = Get-CimInstance Win32_OperatingSystem

# Calculate memory values in GiB
$totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$availableRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)

# Calculate used RAM
$usedRAM = [math]::Round($totalRAM - $availableRAM, 2)

# Calculate RAM usage percentage
$ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)

# Display memory information
Write-Output "Total RAM: $totalRAM GiB"
Write-Output "Available RAM: $availableRAM GiB"
Write-Output "Used RAM: $usedRAM GiB"
Write-Output "RAM Usage: $ramPercent%"

# Check whether RAM usage is high
if ($ramPercent -ge 80) {
    Write-Output "WARNING: High memory usage!"
}
else {
    Write-Output "STATUS: Memory usage is normal."
}

# Retrieve CPU information
$cpu = Get-CimInstance Win32_Processor

# Calculate average CPU load
$cpuUsage = ($cpu | Measure-Object -Property LoadPercentage -Average).Average

# Display CPU usage
Write-Output "CPU Usage: $cpuUsage%"

# Check CPU usage
if ($cpuUsage -ge 90) {
    Write-Output "WARNING: High CPU usage!"
}
else {
    Write-Output "STATUS: CPU usage is normal."
}

# Create a reports folder if it does not exist
New-Item -ItemType Directory -Path ".\reports" -Force | Out-Null

# Create a timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Build a system health report
$report = @"
System Health Report
--------------------
Timestamp: $timestamp
Computer: $env:COMPUTERNAME
Total RAM: $totalRAM GiB
Available RAM: $availableRAM GiB
Used RAM: $usedRAM GiB
RAM Usage: $ramPercent%
CPU Usage: $cpuUsage%
"@

# Save the report
$report | Out-File -FilePath ".\reports\health-report.txt" -Append

Write-Output "Report saved successfully!"

# Create a structured system-health record
$healthData = [PSCustomObject]@{
    Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Computer     = $env:COMPUTERNAME
    CPUPercent   = $cpuUsage
    RAMPercent   = $ramPercent
    UsedRAMGiB   = $usedRAM
    AvailableRAMGiB = $availableRAM
}

# Save the record to a CSV file
$healthData | Export-Csv -Path ".\reports\health-history.csv" -NoTypeInformation -Append

Write-Output "CSV history updated successfully!"