# =====================================================================
# 0. ADMINISTRATOR CHECK (Prevents Exit Code 1 / UAC Prompts)
# =====================================================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[ERROR] You must run this script as an Administrator!" -ForegroundColor Red
    Write-Host "Please close this window, right-click your Start Button, select 'Terminal (Admin)', and run the command again.`n" -ForegroundColor Yellow
    exit
}

# =====================================================================
# 1. YOUR APP INPUT SECTION (Mix Winget and Direct Links here!)
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
    
    # --- DIRECT LINK APPS (Your Private Cloud/GitHub Releases) ---
    [PSCustomObject]@{
        Name       = "Daily App (Mini Trello)"
        Type       = "DirectLink"
        Target     = "https://github.com/11h12/winapp/releases/download/v1.0/daily-app-setup.exe" # Replace with real link
        InstallCmd = "/S" 
    },
