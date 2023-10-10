#requires -version 2
<#
.SYNOPSIS
  <Repair windows Image and Check Filesystem>

.DESCRIPTION
  <Chkdsk + DISM + SFC>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        0.0.1
  Author:         <Lennart Heidtmann>
  Creation Date:  <10.10.2023>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function CheckDISM()
{
DISM /online /cleanup-image /scanhealth
}

Function CheckSFC()
{
SFC /Scannow
}

Function CheckFilesystem()
{
# Get a list of all drive letters on the system
$driveLetters = Get-WmiObject -Query "SELECT * FROM Win32_LogicalDisk" | ForEach-Object { $_.DeviceID }

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
    Write-Output "No Error found"
    }
}
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#CheckFilesystem
CheckDISM
#CheckSFC
