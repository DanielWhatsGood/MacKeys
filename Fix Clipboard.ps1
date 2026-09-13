$log = Join-Path $PSScriptRoot 'clipboard-fix.log'
Remove-Item $log -ErrorAction SilentlyContinue
function W($s) { Write-Host $s; Add-Content -Path $log -Value $s }

W "Clipboard history fix  -  $(Get-Date)"
W ""

# 1. Set the value the Settings toggle is supposed to write.
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Clipboard'
W "--- Writing the setting ---"
try {
    if (-not (Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
        W "  the Clipboard key did not exist - created it"
    }
    New-ItemProperty -Path $key -Name 'EnableClipboardHistory' -Value 1 `
        -PropertyType DWord -Force | Out-Null
    $now = (Get-ItemProperty -Path $key -Name 'EnableClipboardHistory').EnableClipboardHistory
    W "  EnableClipboardHistory is now $now"
} catch {
    W "  FAILED: $($_.Exception.Message)"
}
W ""

# 2. Restart the clipboard service so it picks the setting up.
W "--- Restarting the Clipboard User Service ---"
foreach ($s in (Get-Service -Name 'cbdhsvc*' -ErrorAction SilentlyContinue)) {
    try {
        Restart-Service $s.Name -Force -ErrorAction Stop
        W "  $($s.Name) restarted"
    } catch {
        W "  $($s.Name) could not be restarted without admin rights."
        W "     Not fatal - a sign out and back in does the same thing."
    }
}
W ""

# 3. Bounce the process that draws the panel. Windows restarts it on demand.
W "--- Restarting the panel process ---"
$p = Get-Process -Name 'TextInputHost' -ErrorAction SilentlyContinue
if ($p) {
    try { $p | Stop-Process -Force -ErrorAction Stop; W "  TextInputHost stopped - Windows will relaunch it" }
    catch { W "  could not stop TextInputHost: $($_.Exception.Message)" }
} else {
    W "  TextInputHost was not running"
}
Start-Sleep -Seconds 2
W ""

# 4. Put something on the clipboard so the panel has a row to show.
W "--- Seeding the clipboard ---"
try {
    Set-Clipboard -Value "MacKeys test - if you can see this in Win+V, clipboard history works."
    W "  copied a test line"
} catch {
    W "  could not set the clipboard: $($_.Exception.Message)"
}
W ""

W "Now press Win+V."
W "  - With MacKeys OFF (Ctrl+Option+K), the Command key IS the Windows key."
W "  - With MacKeys ON, use Cmd+Shift+C."
W ""
W "If it is still silent, sign out of Windows and back in, then try again."
W "Saved to clipboard-fix.log next to this script."
Write-Host ""
Read-Host "Press Enter to close"
