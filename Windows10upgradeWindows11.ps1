<#
.NOTES
  Version:        Beta 001.00.00
  Author:         <LemmyFL>
  Last Change Date:  27.11.2024
#>
# Start-Process -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $(iwr 'https://raw.githubusercontent.com/LemmyFl/WindowsScripts/refs/heads/main/Windows10upgradeWindow11.ps1' -UseBasicParsing).Content }" -Verb RunAs
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

function Start-WindowsUpdateUpgrade {
    param (
        [string]$DownloadDir = 'C:\Temp\Windows_FU\packages',
        [string]$LogDir = 'C:\Temp\Windows_FU\Logs',
        [string]$Url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
    )
    
    # Initialize
    try {
        # Variables
        [string]$LogFilePath = Join-Path -Path $LogDir -ChildPath "$(get-date -format 'yyyyMMdd_hhmmsstt')_WindowsUpgrade.log"
        [string]$UpdaterBinary = Join-Path -Path $DownloadDir -ChildPath 'Win10Upgrade.exe'
        [string]$UpdaterArguments = "/quietinstall /skipeula /auto upgrade /copylogs `"$LogDir`""
        
        # Logging Function
        function Write-Log {
            param (
                [string]$Message,
                [ValidateSet("INFO", "ERROR", "WARNING")][string]$Level = "INFO"
            )
            $Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            $LogMessage = "$Timestamp [$Level] $Message"
            Add-Content -Path $LogFilePath -Value $LogMessage
            if ($Level -eq "ERROR") {
                Write-Host $LogMessage -ForegroundColor Red
            } elseif ($Level -eq "WARNING") {
                Write-Host $LogMessage -ForegroundColor Yellow
            } else {
                Write-Host $LogMessage -ForegroundColor Green
            }
        }

        # Check if script is running as Admin
        function CheckIfElevated {
            return (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
        }

        Write-Log -Message "Script initialization started."
        Write-Log -Message "User: $env:USERNAME, Machine: $env:COMPUTERNAME"
        Write-Log -Message "Current Windows Version: $([System.Environment]::OSVersion.VersionString)"

        # Verify Admin Privileges
        if (!(CheckIfElevated)) {
            Write-Log -Message "Script must be run as an administrator!" -Level "ERROR"
            throw "Script is not elevated. Terminating."
        }

        # Ensure Directories Exist
        foreach ($Dir in @($DownloadDir, $LogDir)) {
            if (!(Test-Path -Path $Dir)) {
                New-Item -ItemType Directory -Path $Dir -Force | Out-Null
                Write-Log -Message "Created directory: $Dir"
            }
        }

        # Remove existing UpdaterBinary if it exists
        if (Test-Path -Path $UpdaterBinary) {
            Remove-Item -Path $UpdaterBinary -Force
            Write-Log -Message "Removed existing updater binary: $UpdaterBinary"
        }

        # Download the Windows Update Assistant
        Write-Log -Message "Attempting to download Windows Update Assistant..."
        $webClient = New-Object System.Net.WebClient
        try {
            $webClient.DownloadFile($Url, $UpdaterBinary)
            Write-Log -Message "Download successful: $UpdaterBinary"
        } catch {
            Write-Log -Message "Download failed: $_.Exception.Message" -Level "ERROR"
            throw "Failed to download updater binary."
        }

        # Start Update Process
        if (Test-Path -Path $UpdaterBinary) {
            Write-Log -Message "Starting Windows Update process..."
            try {
                Start-Process -FilePath $UpdaterBinary -ArgumentList $UpdaterArguments -Wait
                Write-Log -Message "Update process initiated successfully."
            } catch {
                Write-Log -Message "Failed to start update process: $_.Exception.Message" -Level "ERROR"
                throw "Failed to start update process."
            }
        } else {
            Write-Log -Message "Updater binary does not exist after download: $UpdaterBinary" -Level "ERROR"
            throw "Updater binary not found."
        }
    } catch {
        Write-Log -Message "Unhandled exception: $_.Exception.Message" -Level "ERROR"
        throw
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

CheckIfElevated
Start-WindowsUpdateUpgrade


Write-Host "Press ESC key to close..."

do {
    $key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} until ($key.VirtualKeyCode -eq 27)
