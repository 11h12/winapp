# 1. Load the Windows GUI modules into PowerShell
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 2. Create the main popup window
$form = New-Object System.Windows.Forms.Form
$form.Text = "My Custom Cloud App Installer"
$form.Size = New-Object System.Drawing.Size(350, 250)
$form.StartPosition = "CenterScreen"

# 3. Create Checkbox for App 1
$checkbox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.Location = New-Object System.Drawing.Point(20, 20)
$checkbox1.Size = New-Object System.Drawing.Size(250, 20)
$checkbox1.Text = "Install App 1 (e.g., My Cloud Tool)"
$form.Controls.Add($checkbox1)

# 4. Create Checkbox for App 2
$checkbox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.Location = New-Object System.Drawing.Point(20, 50)
$checkbox2.Size = New-Object System.Drawing.Size(250, 20)
$checkbox2.Text = "Install App 2 (e.g., Custom VPN)"
$form.Controls.Add($checkbox2)

# 5. Create the "Install" Button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(20, 100)
$installButton.Size = New-Object System.Drawing.Size(120, 30)
$installButton.Text = "Install Selected"

# 6. Define what happens when you click the button
$installButton.Add_Click({
    $form.Close() # Hide the menu and go back to the blue PowerShell screen
    
    $tempDir = "$env:TEMP\MyCloudApps"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    # If Checkbox 1 was ticked, download and install App 1
    if ($checkbox1.Checked) {
        Write-Host "Downloading and Installing App 1..." -ForegroundColor Yellow
        $url1 = "https://your-cloud-link.com/app1.exe"
        Invoke-WebRequest -Uri $url1 -OutFile "$tempDir\app1.exe"
        Start-Process -FilePath "$tempDir\app1.exe" -ArgumentList "/S" -Wait -NoNewWindow
        Write-Host "App 1 Installed!" -ForegroundColor Green
    }

    # If Checkbox 2 was ticked, download and install App 2
    if ($checkbox2.Checked) {
        Write-Host "Downloading and Installing App 2..." -ForegroundColor Yellow
        $url2 = "https://your-cloud-link.com/app2.exe"
        Invoke-WebRequest -Uri $url2 -OutFile "$tempDir\app2.exe"
        Start-Process -FilePath "$tempDir\app2.exe" -ArgumentList "/S" -Wait -NoNewWindow
        Write-Host "App 2 Installed!" -ForegroundColor Green
    }

    Write-Host "All selected apps are installed!" -ForegroundColor Cyan
})
$form.Controls.Add($installButton)

# 7. Display the window to the user
$form.ShowDialog()
