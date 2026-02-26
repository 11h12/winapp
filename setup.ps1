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
    # --- WINGET APPS (Public) ---
    [PSCustomObject]@{ Name="Lightshot"; Type="Winget"; Target="Skillbrains.Lightshot"; Version="5.5.0"; Date="2026-02-25" },
    [PSCustomObject]@{ Name="VS Code"; Type="Winget"; Target="Microsoft.VisualStudioCode"; Version="Latest"; Date="2026-02-26" },
    [PSCustomObject]@{ Name="GitHub Desktop"; Type="Winget"; Target="GitHub.GitHubDesktop"; Version="Latest"; Date="2026-02-26" },
    [PSCustomObject]@{ Name="Google Chrome"; Type="Winget"; Target="Google.Chrome"; Version="Latest"; Date="2026-02-15" },
    
    # Visual Studio with Python and C++ Workloads
    [PSCustomObject]@{ 
        Name    = "Visual Studio 2022 (C++ & Python)" 
        Type    = "Winget" 
        Target  = "Microsoft.VisualStudio.2022.Community" 
        Args    = "--override `"--add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.Python --passive --norestart`""
        Version = "Latest" 
        Date    = "2026-02-26" 
    },
    
    # --- GIT REPOS (Antigravity) ---
    [PSCustomObject]@{ 
        Name    = "Clone Antigravity Repo"
        Type    = "GitClone"
        Target  = "https://github.com/google/antigravity.git" 
        Dest    = "$HOME\Documents\Antigravity"
        Version = "Main"
        Date    = "2026-02-26"
    },

    # --- DIRECT LINK APPS (Private) ---
    [PSCustomObject]@{ 
        Name    = "Daily App"
        Type    = "DirectLink"
        Target  = "https://github.com/11h12/winapp/releases/download/v1.0/daily-app-setup.exe"
        InstallCmd = "/S"
        Version = "2.1.0"
        Date    = "2026-01-28"
    }
)

# =====================================================================
# 2. THE HYBRID ENGINE
# =====================================================================
Write-Host "Loading your setup menu..." -ForegroundColor Cyan
$selectedApps = $MyApps | Select-Object Name, Type, Version, Date | Out-GridView -Title "Select Apps/Repos (Hold CTRL to select multiple)" -PassThru

if ($null -eq $selectedApps) { exit }

foreach ($app in $selectedApps) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $($app.Name)" -ForegroundColor Cyan
    
    if ($app.Type -eq "Winget") {
        Write-Host " -> Checking/Installing via Winget..." -ForegroundColor Yellow
        $argList = "install --id $($app.Target) -e --silent --accept-package-agreements --accept-source-agreements"
        if ($app.Args) { $argList += " $($app.Args)" }
        
        $process = Start-Process -FilePath "winget" -ArgumentList $argList -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) { Write-Host " -> Success!" -ForegroundColor Green }
        elseif ($process.ExitCode -eq -1978335189) { Write-Host " -> Already installed!" -ForegroundColor Green }
        else { Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red }
    }
    
    elseif ($app.Type -eq "GitClone") {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Host " -> Installing Git..." -ForegroundColor Yellow
            Start-Process -FilePath "winget" -ArgumentList "install --id Git.Git -e --silent --accept-source-agreements" -Wait
        }
        if (Test-Path $app.Dest) {
            Write-Host " -> Path $($app.Dest) already exists. Skipping." -ForegroundColor Yellow
        } else {
            git clone $app.Target $app.Dest
            Write-Host " -> Clone Successful!" -ForegroundColor Green
        }
    }

    elseif ($app.Type -eq "DirectLink") {
        $tempFile = "$env:TEMP\$($app.Name -replace ' ', '').exe"
        Invoke-WebRequest -Uri $app.Target -OutFile $tempFile
        $process = Start-Process -FilePath $tempFile -ArgumentList $app.InstallCmd -PassThru -NoNewWindow
        
        # 15s timeout for background apps like Lightshot
        $countdown = 15
        while (-not $process.HasExited -and $countdown -gt 0) {
            Start-Sleep -Seconds 1
            $countdown--
        }
        Write-Host " -> Installation complete." -ForegroundColor Green
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
    }
}
Write-Host "`nAll selected tasks complete!" -ForegroundColor Cyan
