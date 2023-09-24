#!/usr/bin/env pwsh
#Requires -RunAsAdministrator

$hive = "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*"
$amdGpuLocations = [System.Collections.ArrayList]::new()
$driverDescription = "DriverDesc"
$providerName = "ProviderName"
$amdProviderName = "Advanced Micro Devices, Inc."
$igd = "AMD Radeon(TM) Graphics"
$peg = "AMD Radeon RX"
$disabled = 0
$enabled = 1
$successful = $true

$enableUlps = "EnableUlps"

Write-Host "Searching registry for AMD graphics card ..."

Get-Item $hive -ErrorAction SilentlyContinue | ForEach-Object {
    $providerMatched = (Get-ItemPropertyValue $_.PsPath -Name $providerName) -eq $amdProviderName
    $pegMatched = (Get-ItemPropertyValue $_.PsPath -Name $driverDescription).Contains($peg) 
    $igdMatched = (Get-ItemPropertyValue $_.PsPath -Name $driverDescription).Contains($igd)
    if ($providerMatched -and $igdMatched) {
        $description = (Get-ItemPropertyValue $_.PsPath -Name $driverDescription)
        Write-Host "Found AMD integrated graphics card `"$description`" at $_. Not modifying ..."
    }
    if ($providerMatched -and $pegMatched) {
        $amdGpuLocations.Add($_) | Out-Null
    }
}

if ($amdGpuLocations.Count -eq 0) {
    Write-Host "No AMD Radeon RX graphics card could be found on your system. Exiting ..."
    exit 1
} else {
    foreach ($gpu in $amdGpuLocations) {
        $description = (Get-ItemPropertyValue $gpu.PsPath -Name $driverDescription)
        Write-Host "Found AMD Radeon RX graphics card `"$description`" at $gpu."
    }
}

foreach ($gpu in $amdGpuLocations) {
    try {
        $description = (Get-ItemPropertyValue $gpu.PsPath -Name $driverDescription)
        Write-Host "Writing registry keys for `"$description`" ..."

        Write-Host "Writing registry key $enableUlps with Value $disabled at $gpu."
        New-ItemProperty -Path $gpu.PsPath -Name $enableUlps -Value $disabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null

        Write-Host "Writing registry keys for `"$description`" completed."
    } catch {
        Write-Host "Writing to the registry at $gpu failed: $($_.Exception.Message)."
        Write-Host "Stacktrace: $($_.Exception.StackTrace)."
        $successful = $false
    }
}

if ($successful) {
    Write-Host "Script run successful."
    Write-Host "You'll need to reboot your system for the changes to take effect."
    exit 0
} else {
    Write-Host "An error occured."
    Write-Host "Check the output above for more information."
    Write-Host "Script run unsuccessful."
    exit 1
}
