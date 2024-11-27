<#
.NOTES
  Version:        Beta 001.00.00
  Author:         <LemmyFL>
  Last Change Date:  27.11.2024
#>
# Start-Process -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/main/WindowsRepairScript.ps1' -UseBasicParsing).Content }" -Verb RunAs
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function CheckIfElevated() {
    Write-Log "Info: Checking for elevated permissions..."

    $isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Log "ERROR: Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
        return $false
    }

    Write-Log "Info: Code is running as administrator — go on executing the script..."
    return $true
}



#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Press ESC key to close..."

do {
    $key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} until ($key.VirtualKeyCode -eq 27)
