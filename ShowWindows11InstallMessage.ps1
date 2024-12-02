Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Erstelle ein Vollbildfenster auf allen Monitoren
$screens = [System.Windows.Forms.Screen]::AllScreens
foreach ($screen in $screens) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Installation läuft'
    $form.StartPosition = 'Manual'
    $form.BackColor = 'Blue'
    $form.ForeColor = 'White'
    $form.FormBorderStyle = 'None'
    $form.WindowState = 'Maximized'
    $form.Bounds = $screen.Bounds
    $form.TopMost = $true

    # Erstelle die Nachricht
    $label = New-Object System.Windows.Forms.Label
    $label.Text = 'Die Windows 11 Installation läuft. Bitte schalten Sie den PC nicht aus!'
    $label.Font = New-Object System.Drawing.Font('Arial', 32, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = 'White'
    $label.BackColor = 'Blue'
    $label.AutoSize = $false
    $label.TextAlign = 'MiddleCenter'
    $label.Dock = 'Fill'

    # Füge die Nachricht zum Fenster hinzu
    $form.Controls.Add($label)
    $form.Add_Shown({ $form.Activate() })
    $form.Show()
}

# Halte die Fenster offen
[System.Windows.Forms.Application]::Run()
