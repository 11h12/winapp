# =====================================================================
# 1. YOUR APP INPUT SECTION (Only edit this part!)
# =====================================================================
$MyApps = @(
    [PSCustomObject]@{
        Name       = "Lightshot"
        Version    = "1.0.5"
        LastUpdate = "2025-01-19"
        InstallCmd = "/S"
        Url        = "https://nas.dpham.one/sharing/pfuxuyFVG"
    },
    [PSCustomObject]@{
        Name       = "Daily App (Mini Trello)"
        Version    = "2.1.0"
        LastUpdate = "2026-01-28"
        InstallCmd = "/S"
        Url        = "https://your-cloud-storage.com/daily-app.exe"
    },
    [PSCustomObject]@{
        Name       = "Jumpserver Client"
        Version    = "3.0.1"
        LastUpdate = "2026-01-18"
        InstallCmd = "/VERYSILENT"
        Url        = "https://your-cloud-storage.com/jumpserver-client.exe"
    }
)

# =====================================================================
# 2. THE ENGINE (Do not edit below this line)
# =====================================================================
Write-Host "Loading your cloud apps..." -ForegroundColor Cyan

# This single line creates a beautiful, clickable Windows grid menu!
$selectedApps = $MyApps | Out-GridView -Title "Select Apps to Install / Update (Hold CTRL to select multiple)" -PassThru

if ($null -eq $selectedApps) {
    Write-Host "No apps selected. Exiting." -ForegroundColor Yellow
    exit
}

$tempDir = "$env:TEMP\MyCloudApps"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

foreach ($app in $selectedApps) {
    Write-Host "`nProcessing: $($app.Name) (v$($app.Version))" -ForegroundColor Cyan
    $fileName = "$tempDir\$($app.Name -replace ' ', '').exe"

    Write-Host " -> Downloading from cloud..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $app.Url -OutFile $fileName

    Write-Host " -> Installing / Updating silently..." -ForegroundColor Yellow
    $process = Start-Process -FilePath $fileName -ArgumentList $app.InstallCmd -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
        Write-Host " -> Success!" -ForegroundColor Green
    } else {
        Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red
    }
}

Write-Host "`nAll selected tasks complete!" -ForegroundColor Green
