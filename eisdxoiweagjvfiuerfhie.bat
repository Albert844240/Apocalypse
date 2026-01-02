@echo off
title Ultimate Apocalypse with Panic Mode

:: -------- WARNING 1 --------
powershell -command "[System.Windows.MessageBox]::Show('Ultimate apocalypse preview with panic mode.','Warning 1','OK','Warning')"

:: -------- WARNING 2 (YES / NO) --------
powershell -command ^
"$r=[System.Windows.MessageBox]::Show('Do you want to continue?\nYES = proceed\nNO = exit','Warning 2','YesNo','Warning'); ^
if($r -ne 'Yes'){ exit }"

:: -------- 10 SECOND COUNTDOWN --------
echo Countdown before ultimate apocalypse:
for /L %%i in (10,-1,1) do (
    cls
    echo %%i seconds remaining...
    timeout /t 1 >nul
)
cls
echo Apocalypse starting!

:: -------- APOCALYPSE LOOP WITH PANIC MODE --------
powershell -command ^
"Add-Type @'
using System;
using System;
using System.Runtime.InteropServices;
public class HotKey {
    [DllImport(\"user32.dll\")]
    public static extern bool RegisterHotKey(IntPtr hWnd, int id, int fsModifiers, int vk);
    [DllImport(\"user32.dll\")]
    public static extern bool UnregisterHotKey(IntPtr hWnd, int id);
}
'@;

# Register hotkeys
$MOD_CTRL = 0x2
$MOD_ALT  = 0x1
$VK_S     = 0x53  # Stop
$VK_U     = 0x55  # Increase
$VK_D     = 0x44  # Decrease
$VK_M     = 0x4D  # Max out
$VK_P     = 0x50  # Panic mode

[HotKey]::RegisterHotKey([IntPtr]::Zero,1,$MOD_CTRL -bor $MOD_ALT,$VK_S) | Out-Null
[HotKey]::RegisterHotKey([IntPtr]::Zero,2,$MOD_CTRL -bor $MOD_ALT,$VK_U) | Out-Null
[HotKey]::RegisterHotKey([IntPtr]::Zero,3,$MOD_CTRL -bor $MOD_ALT,$VK_D) | Out-Null
[HotKey]::RegisterHotKey([IntPtr]::Zero,4,$MOD_CTRL -bor $MOD_ALT,$VK_M) | Out-Null
[HotKey]::RegisterHotKey([IntPtr]::Zero,5,$MOD_CTRL -bor $MOD_ALT,$VK_P) | Out-Null

Add-Type -AssemblyName PresentationFramework

$colors = @('Red','Yellow','White','Cyan','Orange','Magenta','Green','Blue')
$fonts = @('Arial','Verdana','Tahoma','Calibri')
$screenWidth = [System.Windows.SystemParameters]::PrimaryScreenWidth
$screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight

$maxPopups = 10
$currentPopups = 1
$batchDelay = 3

while ($true) {
    # Play alert sound
    [System.Media.SystemSounds]::Exclamation.Play()

    # Show current number of popups
    1..$currentPopups | ForEach-Object {
        $window = New-Object System.Windows.Window
        $window.WindowStyle = 'None'
        $window.Topmost = $true
        $window.Width = Get-Random -Minimum 400 -Maximum 800
        $window.Height = Get-Random -Minimum 200 -Maximum 600
        $window.Left = Get-Random -Minimum 0 -Maximum ($screenWidth - $window.Width)
        $window.Top = Get-Random -Minimum 0 -Maximum ($screenHeight - $window.Height)
        $window.Background = (New-Object Media.SolidColorBrush ([Media.Colors]::FromName(($colors | Get-Random))))

        $text = New-Object System.Windows.Controls.TextBlock
        $text.FontSize = Get-Random -Minimum 30 -Maximum 60
        $text.FontFamily = ($fonts | Get-Random)
        $text.HorizontalAlignment = 'Center'
        $text.VerticalAlignment = 'Center'
        $text.TextAlignment = 'Center'

        $window.Content = $text
        $window.Show()
    }

    # Countdown with flashing colors
    for ($i=$batchDelay; $i -ge 0; $i--) {
        1..$currentPopups | ForEach-Object {
            $w = [System.Windows.Application]::Current.Windows[$_-1]
            if ($w -ne $null) {
                $tb = $w.Content
                $tb.Text = 'NOTHING IS WORTH A RISK`nActive popups: '+$currentPopups+'`nNext batch in: '+$i+' s'
                $tb.Foreground = [Media.Brushes]::FromName(($colors | Get-Random))
            }
        }
        Start-Sleep -Seconds 1

        # Hotkey handling
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key.Modifiers -band 'Control' -and $key.Modifiers -band 'Alt') {
                switch ($key.Key) {
                    'S' { exit }                         # Safe stop
                    'U' { if ($currentPopups -lt $maxPopups) { $currentPopups++ } }  # Increase
                    'D' { if ($currentPopups -gt 1) { $currentPopups-- } }          # Decrease
                    'M' { $currentPopups = $maxPopups }                             # Max out
                    'P' { [System.Windows.Application]::Current.Dispatcher.Invoke([Action]{ [System.Windows.Application]::Current.Windows | ForEach-Object { $_.Close() } }); exit } # Panic
                }
            }
        }
    }

    # Close all windows before next batch
    [System.Windows.Application]::Current.Dispatcher.Invoke([Action]{ [System.Windows.Application]::Current.Windows | ForEach-Object { $_.Close() } })

    # Gradual ramp-up if not manually changed
    if ($currentPopups -lt 5) { $currentPopups++ }
}

# Unregister all hotkeys
[HotKey]::UnregisterHotKey([IntPtr]::Zero,1)
[HotKey]::UnregisterHotKey([IntPtr]::Zero,2)
[HotKey]::UnregisterHotKey([IntPtr]::Zero,3)
[HotKey]::UnregisterHotKey([IntPtr]::Zero,4)
[HotKey]::UnregisterHotKey([IntPtr]::Zero,5)
"
