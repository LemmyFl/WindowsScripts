<#
.NOTES
  Version:        Beta 1.03.00
  Author:         <LemmyFL>
  Last Change Date:  20.05.2025
#>
# Start-Process -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/main/WindowsRepairScript.ps1' -UseBasicParsing).Content }" -Verb RunAs

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function CheckFileSystem {
    Write-Host "Checking Filesystem on Local Drives"
    try {
        $driveLetters = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object { $_.DeviceID }
        foreach ($driveLetter in $driveLetters) {
            chkdsk /scan /perf $driveLetter > $null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "chkdsk on drive $driveLetter - Error found"
            } else {
                Write-Host "chkdsk on drive $driveLetter - OK"
            }
        }
    } catch {
        Write-Host "An error occurred during filesystem check: $_"
    }
}

Function CheckDISM {
    Write-Host "Checking Operating System Integrity"
    try {
        DISM /online /cleanup-image /scanhealth > $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "DISM scan - OK"
        } else {
            Write-Host "DISM scan - Error found and repairing"
            DISM /online /cleanup-image /restorehealth > $null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "DISM repair - OK - Health has been restored successfully"
            } else {
                Write-Host "DISM repair failed - Check the DISM logs for more information (C:\windows\logs\dism\)"
            }
        }
    } catch {
        Write-Host "An error occurred during DISM check: $_"
    }
}

Function CheckSFC {
    Write-Host "Checking System File Integrity"
    try {
        SFC /scannow > $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SFC scan - OK"
        } else {
            Write-Host "SFC scan - Error found and repairing"
            # Nur ein zweiter Versuch, wie ursprünglich
            SFC /scannow > $null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SFC repair - OK - Health has been restored successfully"
            } else {
                Write-Host "SFC repair failed - Check the SFC logs for more information (C:\Windows\Logs\CBS\)"
            }
        }
    } catch {
        Write-Host "An error occurred during SFC check: $_"
    }
}

Function CheckDrivers {
    Write-Host "Checking Driver Integrity"
    try {
        $drivers = Get-WindowsDriver -Online
        foreach ($driver in $drivers) {
            if ($driver.OriginalFileName -and -not (Test-Path $driver.OriginalFileName)) {
                Write-Host "Driver file missing: $($driver.OriginalFileName)"
            }
        }
        Write-Host "Driver integrity check - Complete"
    } catch {
        Write-Host "An error occurred during driver check: $_"
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Windows Repair Script Running"

CheckFileSystem
CheckDISM
CheckSFC
CheckDrivers

Write-Host "Press ESC key to close..."

# Ermöglicht auch Abbruch mit Strg+C
try {
    do {
        $key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } until ($key.VirtualKeyCode -eq 27)
} catch {
    # Abbruchbehandlung, falls das Skript im Hintergrund oder per Remote ausgeführt wird
    Write-Host "Script execution finished."
}
