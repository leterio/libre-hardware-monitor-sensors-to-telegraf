function Format-SensorString {
    param($string)
    if ($null -eq $string) { return "" }
    else { return $string.ToString().Replace('#', '').Replace(',', '.').Replace(' ', '\ ') }
}

$Hardwares = Get-WmiObject -Namespace root\LibreHardwareMonitor -Query 'select Identifier, Name from Hardware'
$Sensors = Get-WmiObject -Namespace root\LibreHardwareMonitor -Query 'select * from Sensor'

$TemperatureMap = @{}

foreach ($Sensor in $Sensors | Sort-Object Parent, SensorType, Name) { 
    $SensorParent = ($Hardwares | Where-Object { $_.Identifier -eq $Sensor.Parent }).Name
    if ($null -eq $SensorParent) { $SensorParent = $Sensor.Parent }
    
    if ($Sensor.SensorType -eq "Temperature") {
        if (-not $TemperatureMap.ContainsKey($SensorParent)) { $TemperatureMap[$SensorParent] = @() }
        $TemperatureMap[$SensorParent] += [double]$Sensor.Value
    }

    Write-Output $("lhm_sensor,device={0},type={1} {2}={3}" -f (Format-SensorString $SensorParent), (Format-SensorString $Sensor.SensorType), (Format-SensorString $Sensor.Name), (Format-SensorString $Sensor.Value))
} 

foreach ($Sensor in $TemperatureMap.GetEnumerator()) {
    Write-Output $("lhm_sensor,device={0},type=Temperature Average={1}" -f (Format-SensorString $Sensor.Name), (Format-SensorString ($Sensor.Value | Measure-Object -Average).Average))
}
