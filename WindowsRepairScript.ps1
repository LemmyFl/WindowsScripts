<#
.NOTES
  Version:        Beta 00.02.00
  Author:         <LemmyFL>
  Creation Date:  <12.12.2023>
#>
# Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/main/WindowsRepairScript.ps1' -UseBasicParsing).Content }" -Verb RunAs
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function CheckFilesystem()
{
# Get a list of all drive letters on the system
$driveLetters = Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object { $_.DeviceID }

# Loop through each drive and run chkdsk
foreach ($driveLetter in $driveLetters) {
    # Run chkdsk for every drive on the system
    $void = chkdsk /scan /perf $driveLetter

    # Check if the output of chkdsk contains an error
    if ($LASTEXITCODE -ne 0) 
      {
        Write-Host "chkdsk on drive $driveLetter - Error found"
      } 
    else 
      {
        Write-Host "$driveLetter - OK"
      }
}
}

Function CheckDISM()
{
    # Run DISM to scan the image for errors
    $void = DISM /online /cleanup-image /scanhealth 

    # Check if DISM reported an error (Exit Code equal 0)
    if ($LASTEXITCODE -eq "0" ) 
        {
        Write-Host "DISM scan - OK"
        }
    else
        {
        # Run DISM to restore the image Health
        Write-Host "DISM scan - Error found and reparing";
        $void = DISM /online /cleanup-image /restorehealth

        # Check if the restore was successful
        if ($LASTEXITCODE -eq "0") 
            {
            Write-Output "DISM repair - OK - Health has been restored successfully"
            }
        else
            {
            Write-Output "DISM repair failed - Check the DISM logs for more information (C:\windows\logs\dism\)"
            }
        }

}

Function CheckSFC()
{
    # Run SFC /scannow to scan the system files for corruption and missing files
    $void = SFC /scannow

    # Check if the sfc scan was without failure (Exit Code equal 0)
    if ($LASTEXITCODE -eq "0")
    {
    Write-Host "SFC scan - OK"
    }
    else
    {
    Write-Host "SFC scan - Error found and reparing"
    $void = SFC /scannow
    }
           if ($LASTEXITCODE -eq "0")
           {
           Write-Host "SFC repair - OK - Health has been restored successfully"
           }
           else
           {
           Write-Host "SFC repair failed - Check the SFC logs for more information (C:\Windows\Logs\CBS\)"
           }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$void = Start-Transcript -Force -path "C:\LemmyFL_Logs\WindowsRepairScript\WindowsRepairScript_$(Get-Date -Format 'yyyy_MM_dd_-_HH_mm').txt"

Write-Host "Windwos Repair Script Running"

CheckFilesystem
CheckDISM
CheckSFC

Stop-Transcript
pause
exit
