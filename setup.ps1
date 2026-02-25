# =====================================================================
# 1. YOUR APP INPUT SECTION (Mix Winget and Direct Links here!)
# =====================================================================
$MyApps = @(
    # --- WINGET APPS (Public Software) ---
    [PSCustomObject]@{
        Name       = "Lightshot (Screenshot Tool)"
        Type       = "Winget"
        Target     = "Skillbrains.Lightshot" # The official Winget ID
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
    
    # --- DIRECT LINK APPS (Your Private Cloud Files) ---
    [PSCustomObject]@{
        Name       = "Daily App (Mini Trello)"
        Type       = "DirectLink"
        Target     = "https://your-cloud-storage.com/daily-app.exe"
        InstallCmd = "/S" # Only needed for Direct Links
    },
    [PSCustomObject]@{
        Name       = "Jumpserver Client"
        Type       = "DirectLink"
        Target     = "https://your-cloud-storage.com/jumpserver-client.exe"
        InstallCmd = "/VERYSILENT" 
    }
)

# =====================================================================
# 2. THE HYBRID ENGINE (Do not edit below this line)
# =====================================================================
Write-Host "Loading your setup menu..." -ForegroundColor Cyan

# Display the GUI table
$selectedApps = $MyApps | Out-GridView -Title "Select Apps to Install (Hold CTRL to select multiple)" -PassThru

if ($null -eq $selectedApps) {
    Write-Host "No apps selected. Exiting." -ForegroundColor Yellow
    exit
}

$tempDir = "$env:TEMP\MyCloudApps"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

foreach ($app in $selectedApps) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $($app.Name)" -ForegroundColor Cyan
    
    # --- IF IT IS A WINGET APP ---
    if ($app.Type -eq "Winget") {
        Write-Host " -> Installing via Winget..." -ForegroundColor Yellow
        # Winget automatically handles silent flags, agreement acceptance, and downloading
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $($app.Target) -e --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Host " -> Success!" -ForegroundColor Green
        } else {
            Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red
        }
    }
    
    # --- IF IT IS A DIRECT LINK APP ---
    elseif ($app.Type -eq "DirectLink") {
        $fileName = "$tempDir\$($app.Name -replace ' ', '').exe"

        Write-Host " -> Downloading from cloud..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $app.Target -OutFile $fileName

        Write-Host " -> Installing silently..." -ForegroundColor Yellow
        $process = Start-Process -FilePath $fileName -ArgumentList $app.InstallCmd -PassThru -NoNewWindow
        
        # 15-second bulletproof timer to prevent freezing
        $countdown = 15
        while (-not $process.HasExited -and $countdown -gt 0) {
            Start-Sleep -Seconds 1
            $countdown--
        }
        
        if (-not $process.HasExited) {
            Write-Host " -> App launched in background. Moving on..." -ForegroundColor Green
        } elseif ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Host " -> Success!" -ForegroundColor Green
        } else {
            Write-Host " -> Failed. Exit code: $($process.ExitCode)" -ForegroundColor Red
        }
    }
}

Write-Host "`nAll selected tasks complete!" -ForegroundColor Green
