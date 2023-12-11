<#
.NOTES
  Version:        Beta 0.0.5
  Author:         <LemmyFL>
  Creation Date:  <11.12.2023>
#>

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function CheckFilesystem()
{
# Get a list of all drive letters on the system
Write-Host "Filesystem and Metadata scan in progress, this may take some time..."
$driveLetters = Get-CimInstance -Query "SELECT * FROM Win32_LogicalDisk" | ForEach-Object { $_.DeviceID }

# Loop through each drive and run chkdsk with
foreach ($driveLetter in $driveLetters) {

# Run chkdsk for every Drive on the System
$chkdskOutput = chkdsk $driveLetter

# Check if the output of chkdsk contains an Error and if wich Drive Letter
if ($LASTEXITCODE -ne 0)
{
    Write-Output "chkdsk on drive $driveLetter - Error found"
    } 

else
{
    Write-Output "No Error found on drives"
    }
}
}

Function CheckDISM()
{
    # Run DISM to scan the image for errors
    Write-Host "DISM scan in progress, this may take a while...";
    $void = DISM /online /cleanup-image /scanhealth 

    # Check if DISM reported an error (Exit Code equal 0)
    if ($LASTEXITCODE -eq "0" ) 
        {
        Write-Host "No Error found during the DISM scan."
        }
    else
        {
        # Run DISM to restore the image Health
        Write-Host "Error found and reparing";
        $void= DISM /online /cleanup-image /restorehealth

        # Check if the restore was successful
        if ($LASTEXITCODE -eq "0") 
            {
            Write-Output "Health has been restored successfully."
            }
        else
            {
            Write-Output "Failed to restore health. Check the DISM logs for more information (C:\windows\logs\dism\dism.log)."
            }
        }

}

Function CheckSFC()
{
    # Run SFC /scannow to scan the system files for corruption and missing files
    Write-Host "SFC scan started"
    $void = SFC /scannow

    # Check if the sfc scan was without failure (Exit Code equal 0)
    if ($LASTEXITCODE -eq "0")
    {
    Write-Host "No Error found during the SFC scan."
    }
    else
    {
    Write-Host "Error found during the 1st SFC scan, 2nd auto repairing startet to check if it is repaired..."
    $void = SFC /scannow
    }
           if ($LASTEXITCODE -eq "0")
           {Write-Host "No Error found during the 2nd SFC scan."
           }
           else
           {
           Write-Host "Error found during the 2nd SFC scan, check the SFC logs for more information."
           }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Transcript -Force -path "C:\PS\Logs\WindowsRepairScript_$(Get-Date -Format 'yyyy_MM_dd_-_HH_mm').txt"

CheckFilesystem
CheckDISM
CheckSFC

Stop-Transcript
Set-ExecutionPolicy RemoteSigned
pause
