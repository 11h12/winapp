# =====================================================================
# 1. YOUR APP INPUT SECTION
# =====================================================================
$MyApps = @(
    # --- WINGET APPS (Public Software) ---
    [PSCustomObject]@{ Name="Lightshot"; Type="Winget"; Target="Skillbrains.Lightshot"; Version="5.5.0"; Date="2026-02-25" },
    [PSCustomObject]@{ Name="Notion"; Type="Winget"; Target="Notion.Notion"; Version="Latest"; Date="2026-02-20" },
    [PSCustomObject]@{ Name="Google Chrome"; Type="Winget"; Target="Google.Chrome"; Version="Latest"; Date="2026-02-15" },
    [PSCustomObject]@{ Name="VS Code"; Type="Winget"; Target="Microsoft.VisualStudioCode"; Version="Latest"; Date="2026-02-26" },
    [PSCustomObject]@{ Name="GitHub Desktop"; Type="Winget"; Target="GitHub.GitHubDesktop"; Version="Latest"; Date="2026-02-26" },
    
    # --- DIRECT LINK / SPECIAL APPS ---
    [PSCustomObject]@{ 
        Name       = "Daily App (Mini Trello)"
        Type       = "DirectLink"
        Target     = "https://github.com/11h12/winapp/releases/download/v1.0/daily-app-setup.exe"
        InstallCmd = "/S" 
        Version    = "2.1.0"
        Date       = "2026-01-28"
    },
    [PSCustomObject]@{ 
        Name       = "Antigravity Manager"
        Type       = "DirectLink"
        Target     = "https://your-cloud-path/antigravity-manager.py" # Update this to your real link
        InstallCmd = "" # Usually run via python, keep empty to just download
        Version    = "1.0"
        Date       = "2026-01-22"
    }
)

# =====================================================================
# 2. THE HYBRID ENGINE (Updated for better display)
# =====================================================================
Write-Host "Loading your setup menu..." -ForegroundColor Cyan

# This line now shows Version and Date in the popup window
$selectedApps = $MyApps | Select-Object Name, Type, Version, Date, Target | Out-GridView -Title "Select Apps to Install (Hold CTRL to select multiple)" -PassThru
