<#
.NOTES
  Version:         01.00.00
  Author:         <LemmyFL>
  Creation Date:  <12.12.2023>
#>
# Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/main/WindowsAutoupdateScript.ps1' -UseBasicParsing).Content }" -Verb RunAs
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function AskForRestart()
{
  Write-Host "Updates installed successfully. Restart is required."
  $userInput = Read-Host "Do you want to restart now? (Y/N)"
    if ($userInput -eq 'Y' -or $userInput -eq 'y') 
    {
      Restart-Computer -Force
    }
    else 
    {
      Write-Host "You chose not to restart. Please restart your computer at your earliest convenience."
    }
}    
#-----------------------------------------------------------[Execution]------------------------------------------------------------

$void = Start-Transcript -Force -path "C:\LemmyFL_Logs\WindowsAutoupdateScript\WindowsAutoupdateScript_$(Get-Date -Format 'yyyy_MM_dd_-_HH_mm').txt"

Install-Module -Name PSWindowsUpdate -Force
winget install --id Microsoft.Powershell --source winget
winget install --id Microsoft.Powershell.Preview --source winget
Update-Module -Name PSWindowsUpdate -Force
winget upgrade --all
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Force
Stop-Transcript
AskForRestart
exit
