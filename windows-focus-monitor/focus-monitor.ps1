#!/usr/bin/env pwsh
#
# title         : focus-monitor.ps1
# description   : Monitors the active window, and logs to console when the focus changes, and what process now have the focus.
# author        : Anders Dramstad
# date          : 28022024
# version       : 0.1
# usage         : Powershell, run as administrator. Run .\focus-monitor.ps1
#

Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern int GetWindowThreadProcessId(IntPtr handle, out int processId);
}
"@

$activeWindowTitle = $null
$processId = 0

while ($true) {
    $handle = [Win32]::GetForegroundWindow()
    $null = [Win32]::GetWindowThreadProcessId($handle, [ref]$processId)
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($process.MainWindowTitle -ne $activeWindowTitle) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $activeWindowTitle = $process.MainWindowTitle
        Write-Host "$timestamp - Active window changed to: $processId - $($process.Name) - $($process.MainWindowTitle)"
    }
    Start-Sleep -Milliseconds 100
}
