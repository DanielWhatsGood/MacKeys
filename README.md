# macOS keyboard shortcuts on Windows 11

<p align="center">
  <a href="https://github.com/DanielWhatsGood/MacKeys/archive/refs/heads/main.zip">
    <img alt="Download MacKeys"
         src="https://img.shields.io/badge/Download-MacKeys.zip-2ea44f?style=for-the-badge&logo=windows&logoColor=white">
  </a>
</p>

Akko Air 01 + AutoHotkey v2. Nothing is installed system-wide — the folder is
self-contained, and deleting it undoes everything.

## Setting up a new Windows machine

1. Hit the download button above and unzip it anywhere — Documents is fine.
2. Windows marks files from the internet as blocked. Right-click
   `AutoHotkey64.exe` → **Properties** → tick **Unblock** → OK. Skip this and
   the script will not start.
3. Double-click **`MacKeys Settings.cmd`**. The window opens and it starts
   running itself at login from then on.
4. Put the keyboard in Mac mode: hold **Fn + O** for three seconds.

`Ctrl+Option+K` toggles everything off and back on at any time.

<sub>Everything runs from wherever you unzipped it, so the folder can live
anywhere and can be moved later.</sub>

## Files

| File | What it is |
|---|---|
| `MacKeys.ahk` | The remapping script and its window. |
| `AutoHotkey64.exe` | Portable AutoHotkey v2.0.19, straight from the official GitHub release. No installer, no admin rights. |
| `MacKeys Settings.cmd` | Double-click to open the MacKeys window. |
| `Start MacKeys.cmd` | Double-click to start it in the background, no window. |
| `MacKeys.ini` | Your settings, written automatically. Delete it to reset to defaults. |
| `Check Clipboard.cmd` | Diagnoses Win+V when clipboard history refuses to open. |
| `Fix Clipboard.cmd` | Switches clipboard history on properly and restarts its service. |
| `Publish to GitHub.cmd` | Commits this folder and pushes it to the repo. |

On first run it adds a shortcut to your Startup folder so it comes back at every
login. Untick **Start MacKeys when I log in** to stop that.

## Turning it on and off

Three ways, all doing the same thing:

- **Ctrl+Option+K** from anywhere — the fastest one, and it keeps working while
  macOS mode is off, so it always toggles back.
- **The tray icon** (green H near the clock) — right-click it and pick
  *macOS shortcuts*. Double-click the icon to open the window.
- **The MacKeys window** — double-click `MacKeys Settings.cmd`. One button says
  which mode you are in and which one it will switch you to, plus tick-boxes for
  the options below and the full shortcut map.

"Off" means genuinely off: every remap stops, the Windows key is a Windows key
again, and `Ctrl+C` is back to being copy. Useful for games, for remote desktop,
and for lending the machine to someone.

## One-time keyboard setting

The Air 01 must be in **Mac mode**, so that the key beside the spacebar reports
as Command. Hold **Fn + O** for three seconds to switch to Mac mode (Fn + Q
goes back to Windows mode). If your board has a physical Win/Mac switch on the
underside instead, use that — the Fn combos are ignored on those models.

## The map

### Handled by the core swap — Command simply acts as Ctrl

`Cmd+C` `Cmd+V` `Cmd+X` `Cmd+Z` `Cmd+A` `Cmd+S` `Cmd+F` `Cmd+P` `Cmd+N`
`Cmd+T` `Cmd+W` `Cmd+O` `Cmd+R` `Cmd+L` `Cmd+G` `Cmd+1…9`, `Cmd+Shift+T`,
`Cmd+Shift+V`, `Cmd+click`, `Cmd+scroll` to zoom.

Because the script swallows the Windows key entirely, Windows never sees
`Win+L`, `Win+R`, `Win+E` or `Win+G`. That is deliberate: it means `Cmd+L`
reaches the browser address bar instead of locking your screen.

### Rewritten shortcuts

| macOS | Does | Windows equivalent sent |
|---|---|---|
| `Cmd+Tab` | App switcher, stays open while Command is held | Alt+Tab |
| `Cmd+Shift+Tab` | Backwards through it | Alt+Shift+Tab |
| `` Cmd+` `` | Cycle windows of the current app | Alt+Esc |
| `Cmd+Space` | Search | Win+S |
| `Cmd+Ctrl+Space` | Emoji picker | Win+. |
| `Cmd+Q` | Quit app | Alt+F4 |
| `Cmd+Ctrl+Q` | Lock screen | Win+L |
| `Cmd+M` | Minimize window | — |
| `Cmd+Ctrl+F` | Full screen | F11 |
| `Cmd+Shift+S` | Region screenshot | Win+Shift+S |
| `Cmd+Shift+4` / `Cmd+Shift+5` | Region screenshot | Win+Shift+S |
| `Cmd+Shift+3` | Whole screen to `Pictures\Screenshots` | Win+PrtSc |
| `Cmd+Shift+C` | Clipboard history | Win+V |
| `Cmd+Left` / `Cmd+Right` | Snap window to that half of the screen | Win+Left / Win+Right |
| `Cmd+Shift+Left` / `Cmd+Shift+Right` | Move window to the next display | Win+Shift+Left / Right |
| `Cmd+Up` / `Cmd+Down` | Top / bottom of document | Ctrl+Home / Ctrl+End |
| `Cmd+Backspace` | Delete to start of line | Shift+Home, Backspace |
| `Option+Left` / `Option+Right` | Jump a word | Ctrl+Left / Ctrl+Right |
| `Option+Backspace` | Delete previous word | Ctrl+Backspace |
| `Cmd+Option+Left/Right` | Start / end of line (Shift selects) | Home / End |
| `Cmd+Shift+[` / `Cmd+Shift+]` | Previous / next tab | Ctrl+PgUp / Ctrl+PgDn |
| `Cmd+[` / `Cmd+]` | Back / forward (browsers + Explorer only) | Alt+Left / Alt+Right |
| `Cmd+Shift+Z` | Redo | Ctrl+Y |
| `Cmd+Option+I` | Developer tools | Ctrl+Shift+I |
| `Cmd+Option+Esc` | Force Quit → Task Manager | Ctrl+Shift+Esc |
| `Ctrl+Left` / `Ctrl+Right` | Step to the previous / next window, like moving between full-screen Spaces | — (or Win+Ctrl+Left / Right for virtual desktops) |
| `Ctrl+Up` | Mission Control → Task View | Win+Tab |

Adding Shift to `Cmd+Option+arrow` or `Option+arrow` selects instead of moving.
Adding Shift to a plain `Cmd+arrow` snap throws the window to the next display
instead.

### Getting at Windows-only things

There is no Windows key on the board any more. Two ways back in:

- **Ctrl+Esc** opens the Start menu (that is a native Windows shortcut).
- **Cmd+Space** opens search, which is what you actually wanted the Win key for.

If you miss having a real Windows key, set `CFG_RightCmdIsWinKey := true` in the
CONFIG block and the right-hand Command key becomes one.

## Known trade-offs

These are real conflicts, not oversights. The first two can be changed in the
MacKeys window.

1. **`Cmd+Shift+S` shadows "Save As."** You asked for it as screenshot, so
   screenshot wins. Untick it to get Save As back; `Cmd+Shift+4` still snips.
2. **`Ctrl+Left/Right` no longer does word navigation.** It steps through your
   open windows the way macOS steps through Spaces: windows keep a fixed
   left-to-right order, new ones join on the right, minimized ones are skipped,
   and it wraps at either end. The drop-down in the MacKeys window can switch
   it to virtual desktops instead, or turn it off. Word navigation moved to
   `Option+arrow`, matching macOS.
3. **`Cmd+H` is still Ctrl+H**, not "hide window." Ctrl+H is find-and-replace in
   too many apps to take over.
4. **Elevated windows ignore the script.** Anything running as administrator —
   Task Manager, an admin terminal — won't receive the remaps, because the script
   itself runs unelevated. See below if that bothers you.
5. **Alt+Left is no longer "back."** `Cmd+[` is, matching macOS.
6. **`Cmd+Left/Right` snaps windows rather than jumping to start/end of line.**
   Line navigation moved to `Cmd+Option+Left/Right`. Previous/next tab, which
   used to live there, is still on `Cmd+Shift+[` and `Cmd+Shift+]`.
7. **`Cmd+Shift+C` shadows Ctrl+Shift+C.** That is "inspect element" in
   browsers and "copy as path" in File Explorer. Clipboard history wins;
   `Cmd+Option+I` still opens developer tools.
8. **`Cmd+Shift+C` needs Windows clipboard history switched on.** It is off by
   default. The first time you press the chord MacKeys offers to turn it on;
   Settings > System > Clipboard does the same thing.

## Making it work in admin windows

Optional. Untick **Start MacKeys when I log in** first, then open PowerShell **as
administrator** and run this — it replaces the Startup shortcut with a scheduled
task that launches the script elevated at logon:

```powershell
$exe = "$env:USERPROFILE\Documents\MacKeys\AutoHotkey64.exe"
$ahk = "$env:USERPROFILE\Documents\MacKeys\MacKeys.ahk"
$a = New-ScheduledTaskAction -Execute $exe -Argument "`"$ahk`""
$t = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$p = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
Register-ScheduledTask -TaskName "MacKeys" -Action $a -Trigger $t -Principal $p -Settings $s -Force
```

## Uninstalling

Untick **Start MacKeys when I log in**, choose **Quit MacKeys** from the tray,
and delete this folder.
