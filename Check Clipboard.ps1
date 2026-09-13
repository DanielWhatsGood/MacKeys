$log = Join-Path $PSScriptRoot 'clipboard-check.log'
Remove-Item $log -ErrorAction SilentlyContinue
function W($s) { Write-Host $s; Add-Content -Path $log -Value $s }
function RegVal($path, $name) {
    try { return (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name }
    catch { return '<not set>' }
}

W "Clipboard history check  -  $(Get-Date)"
W "Windows build $([System.Environment]::OSVersion.Version.Build)"
W ""

W "--- Clipboard User Service ---"
$found = $false
foreach ($s in (Get-Service -Name 'cbdhsvc*' -ErrorAction SilentlyContinue)) {
    $found = $true
    $start = try { $s.StartType } catch { '?' }
    W ("  {0,-22} Status={1}  StartType={2}" -f $s.Name, $s.Status, $start)
    if ($s.Status -ne 'Running') {
        W "    -> stopped. Trying to start it..."
        try { Start-Service $s.Name -ErrorAction Stop; W "    -> started OK. Try Win+V now." }
        catch { W "    -> could not start: $($_.Exception.Message)" }
    }
}
if (-not $found) { W "  no cbdhsvc service found at all" }
W ""

W "--- Settings and policy ---"
W ("  EnableClipboardHistory (your setting)  = {0}" -f (RegVal 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Clipboard' 'EnableClipboardHistory'))
W ("  AllowClipboardHistory  (admin policy)  = {0}" -f (RegVal 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowClipboardHistory'))
W ("  NoWinKeys              (admin policy)  = {0}" -f (RegVal 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoWinKeys'))
W ("  DisabledHotkeys                        = {0}" -f (RegVal 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisabledHotkeys'))
W ("  cbdhsvc Start (2=auto, 3=manual, 4=disabled) = {0}" -f (RegVal 'HKLM:\SYSTEM\CurrentControlSet\Services\cbdhsvc' 'Start'))
W ""

W "--- Processes that draw the panel ---"
foreach ($n in 'TextInputHost', 'ShellExperienceHost', 'StartMenuExperienceHost', 'explorer') {
    $p = Get-Process -Name $n -ErrorAction SilentlyContinue
    if ($p) { W ("  {0,-26} running (pid {1})" -f $n, $p[0].Id) }
    else    { W ("  {0,-26} NOT running" -f $n) }
}
W ""

W "--- Windows Input Experience package ---"
$pkg = Get-AppxPackage -Name 'MicrosoftWindows.Client.CBS' -ErrorAction SilentlyContinue
if ($pkg) { W ("  {0}  {1}  Status={2}" -f $pkg.Name, $pkg.Version, $pkg.Status) }
else { W "  MicrosoftWindows.Client.CBS is NOT registered for this user" }
W ""

W "Saved to clipboard-check.log next to this script."
Write-Host ""
Read-Host "Press Enter to close"
