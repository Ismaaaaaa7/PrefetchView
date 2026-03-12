Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "`n67 Clicker Loaded`n" -ForegroundColor Cyan

if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32 {

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extraInfo);

    public const int LEFTDOWN = 0x02;
    public const int LEFTUP = 0x04;
    public const int RIGHTDOWN = 0x08;
    public const int RIGHTUP = 0x10;
}
"@
}

# ==============================
# Script Variables
# ==============================

$script:isEnabled = $false
$script:cps = 12
$script:randomization = 2
$script:leftLastClick = 0
$script:rightLastClick = 0

$script:hotkeyVK = 0x52
$script:hotkeyName = "R"

# ==============================
# Click Function
# ==============================

function Invoke-Click {
param([string]$Button)

if ($Button -eq "Left") {

[Win32]::mouse_event([Win32]::LEFTDOWN,0,0,0,[UIntPtr]::Zero)
Start-Sleep -Milliseconds 1
[Win32]::mouse_event([Win32]::LEFTUP,0,0,0,[UIntPtr]::Zero)

}

elseif ($Button -eq "Right") {

[Win32]::mouse_event([Win32]::RIGHTDOWN,0,0,0,[UIntPtr]::Zero)
Start-Sleep -Milliseconds 1
[Win32]::mouse_event([Win32]::RIGHTUP,0,0,0,[UIntPtr]::Zero)

}

}

# ==============================
# GUI
# ==============================

$form = New-Object Windows.Forms.Form
$form.Text = "67 Clicker"
$form.Size = New-Object Drawing.Size(260,180)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Title

$title = New-Object Windows.Forms.Label
$title.Text = "67 AutoClicker"
$title.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$title.Location = New-Object Drawing.Point(50,10)
$title.AutoSize = $true

$form.Controls.Add($title)

# CPS Label

$cpsLabel = New-Object Windows.Forms.Label
$cpsLabel.Text = "CPS:"
$cpsLabel.Location = New-Object Drawing.Point(20,50)
$cpsLabel.AutoSize = $true
$form.Controls.Add($cpsLabel)

# CPS Box

$cpsBox = New-Object Windows.Forms.NumericUpDown
$cpsBox.Minimum = 1
$cpsBox.Maximum = 25
$cpsBox.Value = 12
$cpsBox.Location = New-Object Drawing.Point(70,48)

$form.Controls.Add($cpsBox)

# Randomization Label

$randLabel = New-Object Windows.Forms.Label
$randLabel.Text = "Random:"
$randLabel.Location = New-Object Drawing.Point(20,80)
$randLabel.AutoSize = $true

$form.Controls.Add($randLabel)

# Randomization Box

$randBox = New-Object Windows.Forms.NumericUpDown
$randBox.Minimum = 0
$randBox.Maximum = 5
$randBox.Value = 2
$randBox.Location = New-Object Drawing.Point(70,78)

$form.Controls.Add($randBox)

# Status

$status = New-Object Windows.Forms.Label
$status.Text = "Status: OFF"
$status.ForeColor = "Red"
$status.Location = New-Object Drawing.Point(20,120)
$status.AutoSize = $true

$form.Controls.Add($status)

# Hotkey Label

$hotkeyLabel = New-Object Windows.Forms.Label
$hotkeyLabel.Text = "Hotkey: R"
$hotkeyLabel.Location = New-Object Drawing.Point(150,120)
$hotkeyLabel.AutoSize = $true

$form.Controls.Add($hotkeyLabel)

# ==============================
# Timers
# ==============================

$mainTimer = New-Object Windows.Forms.Timer
$mainTimer.Interval = 1

$hotkeyTimer = New-Object Windows.Forms.Timer
$hotkeyTimer.Interval = 50

# ==============================
# Hotkey Detection
# ==============================

$hotkeyTimer.Add_Tick({

if ([Win32]::GetAsyncKeyState($script:hotkeyVK) -band 0x8000) {

$script:isEnabled = -not $script:isEnabled

if ($script:isEnabled) {

$status.Text = "Status: ON"
$status.ForeColor = "Green"

}
else {

$status.Text = "Status: OFF"
$status.ForeColor = "Red"

}

Start-Sleep -Milliseconds 200

}

})

# ==============================
# Clicking Logic
# ==============================

$mainTimer.Add_Tick({

if (-not $script:isEnabled) { return }

$script:cps = [int]$cpsBox.Value
$script:randomization = [int]$randBox.Value

$randomCPS = Get-Random -Minimum ($script:cps - $script:randomization) -Maximum ($script:cps + $script:randomization + 1)

if ($randomCPS -lt 1) { $randomCPS = 1 }

$interval = 1000 / $randomCPS

$currentTime = [Environment]::TickCount

if (($currentTime - $script:leftLastClick) -ge $interval) {

Invoke-Click "Left"
$script:leftLastClick = $currentTime

}

})

# ==============================
# Start Timers
# ==============================

$mainTimer.Start()
$hotkeyTimer.Start()

$form.Controls.AddRange(@())

$form.ShowDialog()
