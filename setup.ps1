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
    # --- WINGET APPS ---
    [PSCustomObject]@{ Name = "Lightshot"; Type = "Winget"; Target = "Skillbrains.Lightshot"; Version = "5.5.0"; Date = "2026-02-25" },
    [PSCustomObject]@{ Name = "VS Code"; Type = "Winget"; Target = "Microsoft.VisualStudioCode"; Version = "Latest"; Date = "2026-02-26" },
    [PSCustomObject]@{ Name = "GitHub Desktop"; Type = "Winget"; Target = "GitHub.GitHubDesktop"; Version = "Latest"; Date = "2026-02-26" },
    [PSCustomObject]@{ Name = "Git"; Type = "Winget"; Target = "Git.Git"; Version = "Latest"; Date = "2026-02-26" },
    [PSCustomObject]@{ Name = "Google Chrome"; Type = "Winget"; Target = "Google.Chrome"; Version = "Latest"; Date = "2026-02-15" },
    [PSCustomObject]@{ Name = "Visual Studio 2022"; Type = "Winget"; Target = "Microsoft.VisualStudio.2022.Community"; Args = "--override `"--add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.Python --passive --norestart`""; Version = "Latest"; Date = "2026-02-26" },
    
    # --- YOUR REPOSITORY APPS (DirectLink) ---
    [PSCustomObject]@{ 
        Name = "Antigravity IDE"
        Type = "DirectLink"
        Target = "https://github.com/11h12/winapp/releases/download/v1.0/Antigravity.exe" 
        InstallCmd = "/ALLUSERS /S /NORESTART"
        Version = "1.0"; Date = "2026-02-26"
    },
    [PSCustomObject]@{ 
        Name = "Daily App"
        Type = "DirectLink"
        Target = "https://github.com/11h12/winapp/releases/download/v1.0/daily-app-setup.exe"
        InstallCmd = "/S"
        Version = "2.1.0"; Date = "2026-01-28"
    }
)

# =====================================================================
# 2. GUI ENGINE (WPF)
# =====================================================================
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ---------- SELECTION WINDOW ----------
[xml]$SelectionXAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Setup - Select Apps" Height="520" Width="480"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#1E1E2E" Foreground="White" FontFamily="Segoe UI">
    <Window.Resources>
        <!-- Custom CheckBox style with visible tick -->
        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="0,3,0,3"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <Border x:Name="RootBorder" Background="#262637" CornerRadius="8"
                                Padding="14,10" BorderBrush="#313244" BorderThickness="1.5">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="28"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>

                                <!-- Tick box -->
                                <Border x:Name="TickBox" Grid.Column="0"
                                        Width="22" Height="22" CornerRadius="5"
                                        Background="#313244" BorderBrush="#45475A" BorderThickness="1.5"
                                        VerticalAlignment="Center">
                                    <TextBlock x:Name="TickMark" Text="&#x2713;" FontSize="14" FontWeight="Bold"
                                               Foreground="#1E1E2E" HorizontalAlignment="Center" VerticalAlignment="Center"
                                               Visibility="Collapsed"/>
                                </Border>

                                <!-- Content -->
                                <ContentPresenter Grid.Column="1" Margin="10,0,0,0" VerticalAlignment="Center"/>

                                <!-- Type badge -->
                                <Border x:Name="TypeBadge" Grid.Column="2" CornerRadius="4"
                                        Padding="8,3" VerticalAlignment="Center"
                                        Background="#313244">
                                    <TextBlock x:Name="TypeText" FontSize="10" Foreground="#6C7086"
                                               VerticalAlignment="Center"/>
                                </Border>
                            </Grid>
                        </Border>

                        <ControlTemplate.Triggers>
                            <!-- Checked state -->
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="TickBox" Property="Background" Value="#89B4FA"/>
                                <Setter TargetName="TickBox" Property="BorderBrush" Value="#89B4FA"/>
                                <Setter TargetName="TickMark" Property="Visibility" Value="Visible"/>
                                <Setter TargetName="RootBorder" Property="BorderBrush" Value="#89B4FA"/>
                                <Setter TargetName="RootBorder" Property="Background" Value="#1E2030"/>
                            </Trigger>
                            <!-- Hover -->
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="RootBorder" Property="BorderBrush" Value="#585B70"/>
                                <Setter TargetName="RootBorder" Property="Background" Value="#2A2B3D"/>
                            </Trigger>
                            <!-- Hover + Checked -->
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsMouseOver" Value="True"/>
                                    <Condition Property="IsChecked" Value="True"/>
                                </MultiTrigger.Conditions>
                                <Setter TargetName="RootBorder" Property="BorderBrush" Value="#B4D0FB"/>
                                <Setter TargetName="RootBorder" Property="Background" Value="#252638"/>
                            </MultiTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="#89B4FA"/>
            <Setter Property="Foreground" Value="#1E1E2E"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="18,9"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="7" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#B4D0FB"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="&#x2699;  Setup" FontSize="24" FontWeight="Bold" Foreground="#CDD6F4" Margin="0,0,0,4"/>
        <TextBlock Grid.Row="1" Text="Choose the apps you want to install." FontSize="13" Foreground="#A6ADC8" Margin="0,0,0,16"/>

        <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Margin="0,0,0,16">
            <StackPanel x:Name="AppList"/>
        </ScrollViewer>

        <Grid Grid.Row="3">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="CountText" Grid.Column="0" Text="0 selected" FontSize="12" Foreground="#6C7086"
                       VerticalAlignment="Center"/>
            <StackPanel Grid.Column="2" Orientation="Horizontal">
                <Button x:Name="SelectAllBtn" Content="Select All" Margin="0,0,10,0" Background="#45475A" Foreground="#CDD6F4"/>
                <Button x:Name="InstallBtn" Content="Install Selected"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $SelectionXAML)
$selectionWindow = [Windows.Markup.XamlReader]::Load($reader)

$appListPanel = $selectionWindow.FindName("AppList")
$selectAllBtn = $selectionWindow.FindName("SelectAllBtn")
$installBtn = $selectionWindow.FindName("InstallBtn")
$countText = $selectionWindow.FindName("CountText")

# Build checkboxes with rich content
$checkboxes = @()
foreach ($app in $MyApps) {
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Tag = $app

    # Content: name + version stacked
    $contentPanel = New-Object System.Windows.Controls.StackPanel
    $contentPanel.Orientation = 'Vertical'

    $nameBlock = New-Object System.Windows.Controls.TextBlock
    $nameBlock.Text = $app.Name
    $nameBlock.FontSize = 14
    $nameBlock.FontWeight = 'SemiBold'
    $nameBlock.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#CDD6F4')

    $versionBlock = New-Object System.Windows.Controls.TextBlock
    $versionBlock.Text = 'v{0}' -f $app.Version
    $versionBlock.FontSize = 11
    $versionBlock.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6C7086')

    $contentPanel.Children.Add($nameBlock) | Out-Null
    $contentPanel.Children.Add($versionBlock) | Out-Null
    $cb.Content = $contentPanel

    $appListPanel.Children.Add($cb) | Out-Null
    $checkboxes += $cb

    # After adding to visual tree, find TypeText and set type badge
    $cb.ApplyTemplate()
    $tmpl = $cb.Template
    $typeText = $tmpl.FindName('TypeText', $cb)
    if ($typeText) {
        $typeText.Text = $app.Type.ToUpper()
    }
}

# Update count text helper
function Update-CountText {
    $n = @($checkboxes | Where-Object { $_.IsChecked }).Count
    $countText.Text = '{0} selected' -f $n
}

# Wire up Checked/Unchecked events for live count
foreach ($cb in $checkboxes) {
    $cb.Add_Checked({ Update-CountText })
    $cb.Add_Unchecked({ Update-CountText })
}

# Select All toggle
$selectAllBtn.Add_Click({
        $allChecked = ($checkboxes | Where-Object { $_.IsChecked }).Count -eq $checkboxes.Count
        foreach ($cb in $checkboxes) { $cb.IsChecked = -not $allChecked }
        if ($allChecked) { $selectAllBtn.Content = 'Select All' }
        else { $selectAllBtn.Content = 'Deselect All' }
    })

# Install button
$script:selectedApps = @()
$installBtn.Add_Click({
        $script:selectedApps = $checkboxes | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }
        if ($script:selectedApps.Count -eq 0) {
            [System.Windows.MessageBox]::Show('Please select at least one app.', 'Setup', 'OK', 'Warning') | Out-Null
            return
        }
        $selectionWindow.DialogResult = $true
        $selectionWindow.Close()
    })

$result = $selectionWindow.ShowDialog()
if ($result -ne $true -or $script:selectedApps.Count -eq 0) { exit }

# =====================================================================
# 3. PROGRESS WINDOW
# =====================================================================
[xml]$ProgressXAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Setup - Installing" Height="540" Width="540"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#1E1E2E" Foreground="White" FontFamily="Segoe UI">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="&#x1F4E6;  Installing..." FontSize="24" FontWeight="Bold"
                   x:Name="TitleText" Foreground="#CDD6F4" Margin="0,0,0,4"/>
        <TextBlock Grid.Row="1" x:Name="StatusText" Text="Preparing..." FontSize="13"
                   Foreground="#A6ADC8" Margin="0,0,0,12"/>

        <!-- Overall progress -->
        <Grid Grid.Row="2" Margin="0,0,0,6">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <ProgressBar Grid.Column="0" x:Name="ProgressBar" Height="8" Minimum="0"
                         Background="#313244" Foreground="#89B4FA" BorderThickness="0"/>
            <TextBlock Grid.Column="1" x:Name="ProgressPercent" Text="0%" FontSize="12"
                       Foreground="#6C7086" Margin="10,0,0,0" VerticalAlignment="Center"/>
        </Grid>

        <Border Grid.Row="3" Height="1" Background="#313244" Margin="0,10,0,10"/>

        <!-- Per-app rows -->
        <ScrollViewer Grid.Row="4" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="AppRowPanel"/>
        </ScrollViewer>
    </Grid>
</Window>
"@

$reader2 = (New-Object System.Xml.XmlNodeReader $ProgressXAML)
$progressWindow = [Windows.Markup.XamlReader]::Load($reader2)

$titleText = $progressWindow.FindName('TitleText')
$statusText = $progressWindow.FindName('StatusText')
$progressBar = $progressWindow.FindName('ProgressBar')
$progressPercent = $progressWindow.FindName('ProgressPercent')
$appRowPanel = $progressWindow.FindName('AppRowPanel')

$progressBar.Maximum = $script:selectedApps.Count

# Helper: create a per-app row and return references
function New-AppRow {
    param([string]$AppName, [string]$AppVersion, [string]$AppType)

    # Outer card border
    $card = New-Object System.Windows.Controls.Border
    $card.CornerRadius = [System.Windows.CornerRadius]::new(8)
    $card.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#262637')
    $card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#313244')
    $card.BorderThickness = [System.Windows.Thickness]::new(1)
    $card.Margin = [System.Windows.Thickness]::new(0, 3, 0, 3)
    $card.Padding = [System.Windows.Thickness]::new(12, 10, 12, 10)

    $grid = New-Object System.Windows.Controls.Grid

    # Columns: icon | name+detail | status text
    $col0 = New-Object System.Windows.Controls.ColumnDefinition
    $col0.Width = [System.Windows.GridLength]::new(30)
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = [System.Windows.GridLength]::Auto
    $grid.ColumnDefinitions.Add($col0)
    $grid.ColumnDefinitions.Add($col1)
    $grid.ColumnDefinitions.Add($col2)

    # Two rows: top info + bottom mini progress
    $row0 = New-Object System.Windows.Controls.RowDefinition
    $row0.Height = [System.Windows.GridLength]::Auto
    $row1 = New-Object System.Windows.Controls.RowDefinition
    $row1.Height = [System.Windows.GridLength]::Auto
    $grid.RowDefinitions.Add($row0)
    $grid.RowDefinitions.Add($row1)

    # Status icon
    $icon = New-Object System.Windows.Controls.TextBlock
    $icon.Text = [char]0x23F3   # hourglass
    $icon.FontSize = 16
    $icon.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6C7086')
    $icon.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($icon, 0)
    [System.Windows.Controls.Grid]::SetRow($icon, 0)
    $grid.Children.Add($icon) | Out-Null

    # Name + version
    $namePanel = New-Object System.Windows.Controls.StackPanel
    $namePanel.Orientation = 'Horizontal'
    $namePanel.VerticalAlignment = 'Center'
    $namePanel.Margin = [System.Windows.Thickness]::new(4, 0, 0, 0)

    $nameText = New-Object System.Windows.Controls.TextBlock
    $nameText.Text = $AppName
    $nameText.FontSize = 13
    $nameText.FontWeight = 'SemiBold'
    $nameText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#CDD6F4')

    $verText = New-Object System.Windows.Controls.TextBlock
    $verText.Text = '  v{0}' -f $AppVersion
    $verText.FontSize = 11
    $verText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#585B70')
    $verText.VerticalAlignment = 'Bottom'

    $namePanel.Children.Add($nameText) | Out-Null
    $namePanel.Children.Add($verText) | Out-Null
    [System.Windows.Controls.Grid]::SetColumn($namePanel, 1)
    [System.Windows.Controls.Grid]::SetRow($namePanel, 0)
    $grid.Children.Add($namePanel) | Out-Null

    # Status label
    $statusLabel = New-Object System.Windows.Controls.TextBlock
    $statusLabel.Text = 'Pending'
    $statusLabel.FontSize = 11
    $statusLabel.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6C7086')
    $statusLabel.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($statusLabel, 2)
    [System.Windows.Controls.Grid]::SetRow($statusLabel, 0)
    $grid.Children.Add($statusLabel) | Out-Null

    # Mini progress bar (row 1, spanning columns 1-2)
    $miniBar = New-Object System.Windows.Controls.ProgressBar
    $miniBar.Height = 3
    $miniBar.Minimum = 0
    $miniBar.Maximum = 100
    $miniBar.Value = 0
    $miniBar.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#313244')
    $miniBar.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#45475A')
    $miniBar.BorderThickness = [System.Windows.Thickness]::new(0)
    $miniBar.Margin = [System.Windows.Thickness]::new(4, 6, 0, 0)
    [System.Windows.Controls.Grid]::SetColumn($miniBar, 1)
    [System.Windows.Controls.Grid]::SetColumnSpan($miniBar, 2)
    [System.Windows.Controls.Grid]::SetRow($miniBar, 1)
    $grid.Children.Add($miniBar) | Out-Null

    $card.Child = $grid

    return @{
        Card        = $card
        Icon        = $icon
        StatusLabel = $statusLabel
        MiniBar     = $miniBar
        Border      = $card
    }
}

# Pre-populate per-app rows
$appRows = @{}
foreach ($app in $script:selectedApps) {
    $row = New-AppRow -AppName $app.Name -AppVersion $app.Version -AppType $app.Type
    $appRowPanel.Children.Add($row.Card) | Out-Null
    $appRows[$app.Name] = $row
}

# Helper: update a row's state
function Set-AppRowState {
    param(
        [string]$AppName,
        [string]$State,       # 'Installing', 'Success', 'Failed', 'AlreadyInstalled'
        [string]$Detail
    )
    $row = $appRows[$AppName]
    if (-not $row) { return }

    $bc = [System.Windows.Media.BrushConverter]::new()

    switch ($State) {
        'Installing' {
            $row.Icon.Text = [string][char]0x25B6   # play triangle
            $row.Icon.Foreground = $bc.ConvertFromString('#89B4FA')
            $row.StatusLabel.Text = 'Installing...'
            $row.StatusLabel.Foreground = $bc.ConvertFromString('#89B4FA')
            $row.MiniBar.IsIndeterminate = $true
            $row.MiniBar.Foreground = $bc.ConvertFromString('#89B4FA')
            $row.Border.BorderBrush = $bc.ConvertFromString('#89B4FA')
            $row.Border.Background = $bc.ConvertFromString('#1E2030')
        }
        'Success' {
            $row.Icon.Text = [string][char]0x2713   # check mark
            $row.Icon.Foreground = $bc.ConvertFromString('#A6E3A1')
            $label = 'Installed'
            if ($Detail) { $label = $Detail }
            $row.StatusLabel.Text = $label
            $row.StatusLabel.Foreground = $bc.ConvertFromString('#A6E3A1')
            $row.MiniBar.IsIndeterminate = $false
            $row.MiniBar.Value = 100
            $row.MiniBar.Foreground = $bc.ConvertFromString('#A6E3A1')
            $row.Border.BorderBrush = $bc.ConvertFromString('#313244')
            $row.Border.Background = $bc.ConvertFromString('#262637')
        }
        'AlreadyInstalled' {
            $row.Icon.Text = [string][char]0x2713
            $row.Icon.Foreground = $bc.ConvertFromString('#A6E3A1')
            $row.StatusLabel.Text = 'Already installed'
            $row.StatusLabel.Foreground = $bc.ConvertFromString('#6C7086')
            $row.MiniBar.IsIndeterminate = $false
            $row.MiniBar.Value = 100
            $row.MiniBar.Foreground = $bc.ConvertFromString('#6C7086')
            $row.Border.BorderBrush = $bc.ConvertFromString('#313244')
            $row.Border.Background = $bc.ConvertFromString('#262637')
        }
        'Failed' {
            $row.Icon.Text = [string][char]0x2717   # X mark
            $row.Icon.Foreground = $bc.ConvertFromString('#F38BA8')
            $label = 'Failed'
            if ($Detail) { $label = $Detail }
            $row.StatusLabel.Text = $label
            $row.StatusLabel.Foreground = $bc.ConvertFromString('#F38BA8')
            $row.MiniBar.IsIndeterminate = $false
            $row.MiniBar.Value = 100
            $row.MiniBar.Foreground = $bc.ConvertFromString('#F38BA8')
            $row.Border.BorderBrush = $bc.ConvertFromString('#F38BA8')
            $row.Border.Background = $bc.ConvertFromString('#2D1F2B')
        }
    }
}

# Track results
$script:results = @()

# Run installs after window is shown
$progressWindow.Add_ContentRendered({
        $i = 0
        foreach ($app in $script:selectedApps) {
            $i++
            $statusText.Text = 'Installing {0}  ({1} of {2})...' -f $app.Name, $i, $script:selectedApps.Count
            $progressBar.Value = $i - 1
            $pct = [math]::Round((($i - 1) / $script:selectedApps.Count) * 100)
            $progressPercent.Text = '{0}%' -f $pct

            # Mark this app as installing
            Set-AppRowState -AppName $app.Name -State 'Installing'

            # Force UI refresh
            [System.Windows.Forms.Application]::DoEvents()
            $progressWindow.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)

            $success = $false
            $detail = ''

            try {
                if ($app.Type -eq 'Winget') {
                    $argList = 'install --id {0} -e --silent --accept-package-agreements --accept-source-agreements' -f $app.Target
                    if ($app.Args) { $argList += ' ' + $app.Args }
                    $proc = Start-Process -FilePath 'winget' -ArgumentList $argList -Wait -PassThru -NoNewWindow -ErrorAction Stop
                    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                        $success = $true
                    }
                    elseif ($proc.ExitCode -eq -1978335189) {
                        $success = $true
                        $detail = 'already installed'
                    }
                    else {
                        $detail = 'exit code {0}' -f $proc.ExitCode
                    }
                }
                elseif ($app.Type -eq 'DirectLink') {
                    $safeName = $app.Name -replace ' ', ''
                    $tempFile = Join-Path $env:TEMP ($safeName + '.exe')
                    Invoke-WebRequest -Uri $app.Target -OutFile $tempFile -ErrorAction Stop
                    $proc = Start-Process -FilePath $tempFile -ArgumentList $app.InstallCmd -PassThru -NoNewWindow
                    $proc | Wait-Process -Timeout 60 -ErrorAction SilentlyContinue
                    $success = $true
                    if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
                }
            }
            catch {
                $detail = $_.Exception.Message
            }

            $entry = [PSCustomObject]@{ Name = $app.Name; Success = $success; Detail = $detail }
            $script:results += $entry

            # Update the row
            if ($success) {
                if ($detail -eq 'already installed') {
                    Set-AppRowState -AppName $app.Name -State 'AlreadyInstalled'
                }
                else {
                    Set-AppRowState -AppName $app.Name -State 'Success'
                }
            }
            else {
                Set-AppRowState -AppName $app.Name -State 'Failed' -Detail $detail
            }

            # Update overall progress
            $progressBar.Value = $i
            $pct = [math]::Round(($i / $script:selectedApps.Count) * 100)
            $progressPercent.Text = '{0}%' -f $pct

            # Refresh UI
            $progressWindow.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)
        }

        # Final state
        $failedItems = @($script:results | Where-Object { -not $_.Success })
        if ($failedItems.Count -eq 0) {
            $titleText.Text = [char]0x2705 + '  All Done!'
            $statusText.Text = 'All {0} apps installed successfully.' -f $script:selectedApps.Count
            $statusText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#A6E3A1')
        }
        else {
            $titleText.Text = [char]0x26A0 + '  Finished with Errors'
            $statusText.Text = '{0} of {1} apps failed. Check details below.' -f $failedItems.Count, $script:selectedApps.Count
            $statusText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F38BA8')
        }

        $progressWindow.Title = 'Setup - Complete'
    })

$progressWindow.ShowDialog() | Out-Null
