Write-Host "Starting Machine Setup..." -ForegroundColor Cyan

# 1. Install Public Apps via Winget (Fast, reliable, self-updating)
Write-Host "Installing Public Applications..." -ForegroundColor Yellow
$wingetApps = @(
    "OpenJS.NodeJS",       # Node.js and npm
    "Python.Python.3.11",  # Python
    "VNGCorp.Zalo",        # Zalo App
    "SimonTatham.PuTTY",   # SSH Client
    "Google.Chrome"        # Web Browser
)

foreach ($app in $wingetApps) {
    Write-Host "Installing $app..."
    # --accept-package-agreements and --accept-source-agreements ensure it runs silently without prompting you
    winget install --id $app -e --silent --accept-package-agreements --accept-source-agreements
}

# 2. Install Private Cloud Apps
Write-Host "Installing Custom Cloud Applications..." -ForegroundColor Yellow
$tempDir = "$env:TEMP\AppSetup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Define your direct download link
$customAppUrl = "https://your-cloud-storage.com/your-custom-app.exe"
$customAppPath = "$tempDir\custom-app.exe"

Write-Host "Downloading Custom App..."
Invoke-WebRequest -Uri $customAppUrl -OutFile $customAppPath

Write-Host "Installing Custom App silently..."
# Capture the process to ensure reliability and check the exit code
$installProcess = Start-Process -FilePath $customAppPath -ArgumentList "/S" -Wait -PassThru -NoNewWindow

if ($installProcess.ExitCode -eq 0 -or $installProcess.ExitCode -eq 3010) {
    Write-Host "Custom App installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to install Custom App. Exit Code: $($installProcess.ExitCode)" -ForegroundColor Red
}

Write-Host "Setup Complete! Welcome to your new machine." -ForegroundColor Green
