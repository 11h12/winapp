# =====================================================================
# 0. ADMINISTRATOR CHECK
# =====================================================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[ERROR] You must run this script as an Administrator!" -ForegroundColor Red
    exit
}

# =====================================================================
# 1. YOUR APP INPUT SECTION
# =====================================================================
$MyApps = @(
    # --- WINGET APPS (Public Software) ---
    [PSCustomObject]@{ Name="Lightshot"; Type="Winget"; Target="Skillbrains.Lightshot"; Version="5.5.0"; Date="2026-02-25" },
    [PSCustomObject]@{ Name="VS Code"; Type="Winget"; Target="Microsoft.VisualStudioCode"; Version="Latest"; Date="2026-02-26" },
    [PSCustomObject]@{ Name="GitHub Desktop"; Type="Winget"; Target="GitHub.GitHubDesktop"; Version="Latest"; Date="2026-02-26" },
    [PSCustomObject]@{ Name="Google Chrome"; Type="Winget"; Target="Google.Chrome"; Version="Latest"; Date="2026-02-15" },
    
    # Visual Studio with Python and C++ Workloads
    [PSCustomObject]@{ 
        Name    = "Visual Studio 2022" 
        Type    = "Winget" 
        Target  = "Microsoft.VisualStudio.2022.Community" 
        Args    = "--override `"--add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.Python --passive --norestart`""
        Version = "Latest"; Date = "2026-02-26" 
    },
    
    # --- DIRECT LINK APPS (Installers) ---
    [PSCustomObject]@{ 
        Name       = "Antigravity IDE"
        Type       = "DirectLink"
        # Official Google Direct Link for Windows x64
        Target     = "https://antigravity.google/download/windows-x64" 
        InstallCmd = "/S" 
        Version    = "1.18.4"; Date = "2026-02-21"
    },
    [PSCustomObject]@{ 
        Name       = "Daily App"
        Type       = "DirectLink"
        Target     = "https://github.com/11h12/winapp/releases/download/v1.0/daily-app-setup.exe"
        InstallCmd = "/S"
        Version    = "2.1.0"; Date = "2026-01-28"
    }
)

# =====================================================================
# 2. THE HYBRID ENGINE
# =====================================================================
Write-Host "Loading your setup menu..." -ForegroundColor Cyan

# Select-Object ensures only the chosen columns show in the popup
$selectedApps = $MyApps | Select-Object Name, Type, Version, Date | Out-GridView -Title "Select Apps to Install (Hold CTRL to select multiple)" -PassThru

if ($null -eq $selectedApps) { exit }

foreach ($app in $selectedApps) {
    # Find the original object from $MyApps to get Target and InstallCmd
    $appData = $MyApps | Where-Object { $_.Name -eq $app.Name }

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $($appData.Name)" -ForegroundColor Cyan
    
    if ($appData.Type -eq "Winget") {
        Write-Host " -> Checking/Installing via Winget..." -ForegroundColor Yellow
        $argList = "install --id $($appData.Target) -e --silent --accept-package-agreements --accept-source-agreements"
        if ($appData.Args) { $argList += " $($appData.Args)" }
        
        $process = Start-Process -FilePath "winget" -ArgumentList $argList -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) { Write-Host " -> Success!" -ForegroundColor Green }
        elseif ($process.ExitCode -eq -1978335189) { Write-Host " -> Already installed!" -ForegroundColor Green }
        else { Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red }
    }
    
    elseif ($appData.Type -eq "DirectLink") {
        $tempFile = "$env:TEMP\$($appData.Name -replace ' ', '').exe"
        Write-Host " -> Downloading installer from $($appData.Target)..." -ForegroundColor Yellow
        
        try {
            Invoke-WebRequest -Uri $appData.Target -OutFile $tempFile -ErrorAction Stop
            
            Write-Host " -> Running silent installation..." -ForegroundColor Yellow
            $process = Start-Process -FilePath $tempFile -ArgumentList $appData.InstallCmd -PassThru -NoNewWindow
            
            # Wait for up to 30 seconds for the installer to finish
            $process | Wait-Process -Timeout 30 -ErrorAction SilentlyContinue
            Write-Host " -> Process complete." -ForegroundColor Green
        } catch {
            Write-Host " -> ERROR: Could not download or run the file." -ForegroundColor Red
        }
        
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
    }
}
Write-Host "`nAll selected tasks complete!" -ForegroundColor Cyan
