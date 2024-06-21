<#
.NOTES
  Version:        Beta 00.03.00
  Author:         <LemmyFL>
  Creation Date:  12.12.2023
#>
# Start-Process -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/main/WindowsRepairScript.ps1' -UseBasicParsing).Content }" -Verb RunAs
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function CheckFileSystem {
    Write-Host "Checking Filesystem on Local Drives"
    $driveLetters = Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object { $_.DeviceID }
    foreach ($driveLetter in $driveLetters) {
        chkdsk /scan /perf $driveLetter > $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "chkdsk on drive $driveLetter - Error found"
        } else {
            Write-Host "chkdsk on drive $driveLetter - OK"
        }
    }
}

Function CheckDISM {
    Write-Host "Checking Operating System Integrity"
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
}

Function CheckSFC {
    Write-Host "Checking System File Integrity"
    SFC /scannow > $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SFC scan - OK"
    } else {
        Write-Host "SFC scan - Error found and repairing"
        SFC /scannow > $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SFC repair - OK - Health has been restored successfully"
        } else {
            Write-Host "SFC repair failed - Check the SFC logs for more information (C:\Windows\Logs\CBS\)"
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Windows Repair Script Running"

CheckFileSystem
CheckDISM
CheckSFC

Write-Host "Press ESC key to close..."

do {
    $key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} until ($key.VirtualKeyCode -eq 27)
