<#
.NOTES
  Version:        Beta 00.02.00
  Author:         <LemmyFL>
  Creation Date:  12.12.2023
#>
# Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/main/WindowsRepairScript.ps1' -UseBasicParsing).Content }" -Verb RunAs
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function CheckFileSystem()
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
        Write-Host "chkdsk on drive $driveLetter - OK"
      }
}
}

Function CheckDISM()
{
    # Run DISM to scan the image for errors
    $void = DISM /online /cleanup-image /scanhealth 

    # Check if DISM reported an error (Exit Code equal 0)
    if ($LASTEXITCODE -eq 0 ) 
        {
        Write-Host "DISM scan - OK"
        }
    else
        {
        # Run DISM to restore the image Health
        Write-Host "DISM scan - Error found and repairing";
        $void = DISM /online /cleanup-image /restorehealth

        # Check if the restore was successful
        if ($LASTEXITCODE -eq 0) 
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
    if ($LASTEXITCODE -eq 0)
      {
        Write-Host "SFC scan - OK"
      }
    else
      {
        Write-Host "SFC scan - Error found and repairing"
        $void = SFC /scannow
      }
           if ($LASTEXITCODE -eq 0)
             {
               Write-Host "SFC repair - OK - Health has been restored successfully"
             }
            else
             {
               Write-Host "SFC repair failed - Check the SFC logs for more information (C:\Windows\Logs\CBS\)"
             }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "*Windows Repair Script Running*"

CheckFileSystem
CheckDISM
CheckSFC

Write-Host "Press ESC key to close..."

do {
    $key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} until ($key.VirtualKeyCode -eq 27)
