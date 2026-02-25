# =====================================================================
# 0. ADMINISTRATOR CHECK
# =====================================================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[ERROR] You must run this script as an Administrator!" -ForegroundColor Red
    Write-Host "Please close this window, right-click Start, select 'Terminal (Admin)', and run again.`n" -ForegroundColor Yellow
    exit
}

# =====================================================================
# 1. YOUR APP INPUT SECTION
# =====================================================================
$MyApps = @(
    # --- WINGET APPS (Public Software) ---
    [PSCustomObject]@{
        Name       = "Lightshot"
        Type       = "Winget"
        Target     = "Skillbrains.Lightshot"
    },
    [PSCustomObject]@{
        Name       = "Notion"
        Type       = "Winget"
        Target     = "Notion.Notion"
    },
    [PSCustomObject]@{
        Name       = "Google Chrome"
        Type       = "Winget"
        Target     = "Google.Chrome"
    },
    
    # --- DIRECT LINK APPS (Private Cloud/GitHub Releases) ---
    [PSCustomObject]@{
        Name       = "Daily App (Mini Trello)"
        Type       = "DirectLink"
        Target     = "https://github.com/11h12/winapp/releases/download/v1.0/daily-app-setup.exe"
        InstallCmd = "/S" 
    },
    [PSCustomObject]@{
        Name       = "Jumpserver Client"
        Type       = "DirectLink"
        Target     = "https://github.com/11h12/winapp/releases/download/v1.0/jumpserver-client.exe"
        InstallCmd = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-" 
    }
)

# =====================================================================
# 2. THE HYBRID ENGINE
# =====================================================================
Write-Host "Loading your setup menu..." -ForegroundColor Cyan

# Use Out-GridView for the "Chris Titus" style selection
$selectedApps = $MyApps | Out-GridView -Title "Select Apps to Install (Hold CTRL to select multiple)" -PassThru

if ($null -eq $selectedApps) {
    Write-Host "No apps selected. Exiting." -ForegroundColor Yellow
    exit
}

$tempDir = "$env:TEMP\MyCloudApps"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }

foreach ($app in $selectedApps) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $($app.Name)" -ForegroundColor Cyan
    
    # --- WINGET LOGIC ---
    if ($app.Type -eq "Winget") {
        Write-Host " -> Checking/Installing via Winget..." -ForegroundColor Yellow
        
        # We run this with SilentlyContinue to prevent the red text if it's already installed
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $($app.Target) -e --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Host " -> Success!" -ForegroundColor Green
        } elseif ($process.ExitCode -eq -1978335189) {
            Write-Host " -> Already installed and up to date!" -ForegroundColor Green
        } else {
            Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red
        }
    }
    
    # --- DIRECT LINK LOGIC ---
    elseif ($app.Type -eq "DirectLink") {
        $fileName = "$tempDir\$($app.Name -replace ' ', '').exe"

        Write-Host " -> Downloading from cloud..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $app.Target -OutFile $fileName -ErrorAction Stop
        } catch {
            Write-Host " -> Download Failed! Check your URL." -ForegroundColor Red
            continue
        }

        Write-Host " -> Installing silently..." -ForegroundColor Yellow
        $process = Start-Process -FilePath $fileName -ArgumentList $app.InstallCmd -PassThru -NoNewWindow
        
        # 15-second countdown timer
        $countdown = 15
        while (-not $process.HasExited -and $countdown -gt 0) {
            Start-Sleep -Seconds 1
            $countdown--
        }
        
        if (-not $process.HasExited) {
            Write-Host " -> Timeout: App is likely running in tray. Moving on..." -ForegroundColor Green
        } elseif ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Host " -> Success!" -ForegroundColor Green
        } else {
            Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red
        }
        
        if (Test-Path $fileName) { Remove-Item -Path $fileName -Force }
    }
}

Write-Host "`nSetup process finished!" -ForegroundColor Cyan
