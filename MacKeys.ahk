#Requires AutoHotkey v2.0
#SingleInstance Force
;==============================================================================
;  MacKeys.ahk - macOS keyboard shortcuts on Windows 11
;  Built for an Akko Air 01 running in MAC mode (hold Fn+O for 3 seconds).
;
;  Physical key positions in Mac mode, left of the spacebar:
;       [ Ctrl ] [ Option ] [ Command ] [ Space ]
;  Windows sees Option as Alt, and Command as the Windows key.
;  This script turns Command into Ctrl, then re-implements the macOS
;  shortcuts that a plain Command->Ctrl swap would otherwise break.
;
;  TOGGLE IT:  Ctrl+Option+K   |   tray icon   |   the MacKeys window
;  Switching off restores stock Windows behaviour instantly.
;==============================================================================

InstallKeybdHook
SendMode "Input"
SetKeyDelay -1, -1
SetWinDelay 0
SetTitleMatchMode 2
#UseHook true

;==============================================================================
;  Settings - live values, loaded from MacKeys.ini, editable in the window
;==============================================================================

g_Ini := A_ScriptDir "\MacKeys.ini"
g_MacMode := true                        ; master on/off
g_AltTabOpen := false
gReady := false                          ; set once the window is built

; Ctrl+Left / Ctrl+Right switch virtual desktops (macOS Spaces behaviour).
CFG_CtrlArrowsSwitchDesktops := true

; Ctrl+Up opens Task View (the macOS Mission Control gesture).
CFG_CtrlUpIsMissionControl := true

; Cmd+Shift+S takes a region screenshot. Shadows "Save As" in some apps.
CFG_CmdShiftSIsScreenshot := true

; Keep the RIGHT Command key as a real Windows key instead of a second Ctrl.
CFG_RightCmdIsWinKey := false

; What Cmd+Shift+Z sends. "^y" is the Windows standard redo.
CFG_RedoKey := "^y"

; Log each step of Cmd+Shift+C to clipboard-debug.log.
CFG_ClipDebug := true

;==============================================================================
;  Window groups
;==============================================================================

GroupAdd "Browsers", "ahk_exe chrome.exe"
GroupAdd "Browsers", "ahk_exe msedge.exe"
GroupAdd "Browsers", "ahk_exe firefox.exe"
GroupAdd "Browsers", "ahk_exe brave.exe"
GroupAdd "Browsers", "ahk_exe opera.exe"
GroupAdd "Browsers", "ahk_exe vivaldi.exe"
GroupAdd "Browsers", "ahk_exe arc.exe"
GroupAdd "Browsers", "ahk_exe explorer.exe"

;==============================================================================
;  Startup
;==============================================================================

firstRun := !FileExist(g_Ini)
LoadSettings()
BuildGui()
ApplyMode(false)
SaveSettings()
if firstRun {
    if !StartupEnabled()
        ToggleStartup()
    ShowGui()
} else if (A_Args.Length && A_Args[1] = "show") {
    ShowGui()
} else {
    TrayTip "Command works like Ctrl. Ctrl+Option+K toggles.", "MacKeys is on", 1
    SetTimer(() => TrayTip(), -3000)
}

;==============================================================================
;  Helpers
;==============================================================================

; Is a physical Command key down? Still readable even though Command is
; remapped, because the keyboard hook tracks the real key independently.
CmdHeld() {
    global CFG_RightCmdIsWinKey
    if GetKeyState("LWin", "P")
        return true
    return GetKeyState("RWin", "P") && !CFG_RightCmdIsWinKey
}

; Is a real Ctrl key - the pinky one - physically down?
RealCtrl() => GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P")

OptHeld() => GetKeyState("LAlt", "P") || GetKeyState("RAlt", "P")

ShiftHeld() => GetKeyState("LShift", "P") || GetKeyState("RShift", "P")

; Re-send a key with whatever modifiers are genuinely held, i.e. behave as
; though this script had never intercepted it.
PassThru(key) => SendInput("{Blind}" key)

; Send something with the Command-remap's Ctrl lifted out of the way, then put
; Ctrl back if Command is still held - otherwise a second press of the same
; Command chord would arrive with no modifier at all.
SendAsCmd(keys, blind := false) {
    SendInput "{LCtrl up}{RCtrl up}"
    SendInput (blind ? "{Blind}" : "") keys
    if CmdHeld()
        SendInput "{LCtrl down}"
}

Snip() => SendAsCmd("{LWin down}{LShift down}s{LShift up}{LWin up}")

SwitchDesktop(dir) => SendAsCmd("{LWin down}{LCtrl down}{" dir "}{LCtrl up}{LWin up}")

; Win+Left/Right snaps the window to that half of the current screen; adding
; Shift throws it to the next display instead. Shift is lifted first because
; the chord is holding it, then pressed back only when it is wanted.
SnapWindow(dir, toDisplay) {
    SendAsCmd("{LShift up}{RShift up}{LWin down}"
            . (toDisplay ? "{LShift down}{" dir "}{LShift up}" : "{" dir "}")
            . "{LWin up}")
}

;==============================================================================
;  THE CORE SWAP - Command behaves as Ctrl
;  Because the Windows key is swallowed here, OS-reserved combos like Win+L,
;  Win+R, Win+E and Win+G can never fire by accident, so Cmd+L, Cmd+R, Cmd+E
;  and Cmd+G reach the application the way they do on a Mac.
;==============================================================================

LWin::LCtrl

#HotIf !CFG_RightCmdIsWinKey
RWin::RCtrl
#HotIf

;==============================================================================
;  Cmd+Tab - application switcher
;  Holds Alt down so the switcher stays open while Command is held, exactly
;  like macOS. Tab and Shift+Tab keep cycling; releasing Command commits.
;==============================================================================

*^Tab::
{
    global g_AltTabOpen
    if !CmdHeld() {
        PassThru("{Tab}")
        return
    }
    if !g_AltTabOpen {
        SendInput "{LCtrl up}{RCtrl up}"
        SendInput "{LAlt down}"
        g_AltTabOpen := true
        SetTimer WatchAltTab, 40
    }
    PassThru("{Tab}")
}

WatchAltTab() {
    global g_AltTabOpen
    if CmdHeld()
        return
    SendInput "{LAlt up}"
    g_AltTabOpen := false
    SetTimer WatchAltTab, 0
}

;==============================================================================
;  Cmd+` - cycle windows of the current app
;==============================================================================

^SC029::
{
    if !CmdHeld() {
        PassThru("{SC029}")
        return
    }
    SendAsCmd("!{Esc}")
}

;==============================================================================
;  Cmd+Space - Spotlight -> Windows Search
;  Cmd+Ctrl+Space - emoji and symbol picker
;==============================================================================

^Space::
{
    if !CmdHeld() {
        PassThru("{Space}")
        return
    }
    if RealCtrl()
        SendAsCmd("{LWin down}.{LWin up}")
    else
        SendAsCmd("{LWin down}s{LWin up}")
}

;==============================================================================
;  Cmd+Q - quit app          Cmd+Ctrl+Q - lock screen
;==============================================================================

^q::
{
    if !CmdHeld() {
        PassThru("q")
        return
    }
    if RealCtrl()
        SendAsCmd("{LWin down}l{LWin up}")
    else
        SendAsCmd("!{F4}")
}

;==============================================================================
;  Cmd+M - minimize          Cmd+Ctrl+F - full screen
;==============================================================================

^m::
{
    if !CmdHeld() {
        PassThru("m")
        return
    }
    SendInput "{LCtrl up}{RCtrl up}"
    try WinMinimize("A")
}

^f::
{
    if CmdHeld() && RealCtrl() {
        SendAsCmd("{F11}")
        return
    }
    PassThru("f")
}

;==============================================================================
;  Screenshots
;    Cmd+Shift+S -> region snip   (switchable in the MacKeys window)
;    Cmd+Shift+4 -> region snip   (macOS muscle memory)
;    Cmd+Shift+5 -> region snip
;    Cmd+Shift+3 -> whole screen, saved to Pictures\Screenshots
;==============================================================================

^+s::
{
    global CFG_CmdShiftSIsScreenshot
    if !CmdHeld() || !CFG_CmdShiftSIsScreenshot {
        PassThru("s")
        return
    }
    Snip()
}

^+4::
{
    if !CmdHeld() {
        PassThru("4")
        return
    }
    Snip()
}

^+5::
{
    if !CmdHeld() {
        PassThru("5")
        return
    }
    Snip()
}

^+3::
{
    if !CmdHeld() {
        PassThru("3")
        return
    }
    SendAsCmd("{LShift up}{LWin down}{PrintScreen}{LWin up}")
}

;==============================================================================
;  The arrow keys
;
;  Every arrow is matched on the bare key, never as ^Left or !Left, and the
;  decision is made from the PHYSICAL keys via CmdHeld / OptHeld / RealCtrl.
;
;  That is deliberate. Command is a remap, so the Ctrl it stands for is
;  synthetic: SendAsCmd lifts it on every send and presses it back afterwards,
;  and it has not always landed yet when an arrow arrives. A hotkey written as
;  ^Left therefore matches only most of the time, which is exactly what made
;  these fire intermittently. Physical key state has no such gap.
;
;    Cmd+Left / Right          -> snap the window to that half of the screen
;    Cmd+Shift+Left / Right    -> throw the window at the next display
;    Cmd+Option+Left / Right   -> start / end of line
;    Option+Left / Right       -> jump a word
;    Cmd+Up / Down             -> top / bottom of document
;    Ctrl+Left / Right         -> switch virtual desktop
;    Ctrl+Up                   -> Task View
;  Adding Shift to any of the text ones selects instead of moving.
;==============================================================================

*Left::  SideArrow("Left",  "Home")
*Right:: SideArrow("Right", "End")

SideArrow(dir, edge) {
    global CFG_CtrlArrowsSwitchDesktops
    shifted := ShiftHeld()

    if CmdHeld() {
        if OptHeld() {                      ; start / end of line
            SendInput "{Blind}{LAlt up}{RAlt up}"
            SendAsCmd(shifted ? "+{" edge "}" : "{" edge "}")
            return
        }
        SnapWindow(dir, shifted)            ; snap, or move to the next display
        return
    }

    if OptHeld() {                          ; jump a word
        SendInput "{Blind}{LAlt up}{RAlt up}"
        SendAsCmd(shifted ? "^+{" dir "}" : "^{" dir "}")
        return
    }

    if RealCtrl() && CFG_CtrlArrowsSwitchDesktops && !shifted {
        SwitchDesktop(dir)
        return
    }

    PassThru("{" dir "}")
}

*Up::
{
    global CFG_CtrlUpIsMissionControl
    if CmdHeld() {
        SendAsCmd(ShiftHeld() ? "^+{Home}" : "^{Home}")
        return
    }
    if RealCtrl() && CFG_CtrlUpIsMissionControl && !OptHeld() {
        SendAsCmd("{LWin down}{Tab}{LWin up}")
        return
    }
    PassThru("{Up}")
}

*Down::
{
    if CmdHeld() {
        SendAsCmd(ShiftHeld() ? "^+{End}" : "^{End}")
        return
    }
    PassThru("{Down}")
}

;==============================================================================
;  Deletion
;==============================================================================

!BS::SendInput "^{BS}"

^BS::
{
    if !CmdHeld() {
        PassThru("{BS}")
        return
    }
    SendAsCmd("+{Home}{BS}")
}

;==============================================================================
;  Browser and window navigation
;==============================================================================

#HotIf CmdHeld() && WinActive("ahk_group Browsers")
^SC01A::SendAsCmd("!{Left}")          ; Cmd+[  back
^SC01B::SendAsCmd("!{Right}")         ; Cmd+]  forward
#HotIf

^+SC01A::
{
    if !CmdHeld() {
        PassThru("{SC01A}")
        return
    }
    SendAsCmd("{LShift up}^{PgUp}")
}

^+SC01B::
{
    if !CmdHeld() {
        PassThru("{SC01B}")
        return
    }
    SendAsCmd("{LShift up}^{PgDn}")
}

^!i::
{
    if !CmdHeld() {
        PassThru("i")
        return
    }
    SendInput "{LAlt up}{RAlt up}"
    SendAsCmd("^+i")
}

^!Esc::
{
    if !CmdHeld() {
        PassThru("{Esc}")
        return
    }
    SendInput "{LAlt up}{RAlt up}"
    SendAsCmd("^+{Esc}")
}

;==============================================================================
;  Redo - Cmd+Shift+Z
;==============================================================================

^+z::
{
    global CFG_RedoKey
    if !CmdHeld() {
        PassThru("z")
        return
    }
    SendAsCmd("{LShift up}" CFG_RedoKey)
}

;==============================================================================
;  Cmd+Shift+C - clipboard history (Win+V)
;
;  The awkward part: Command IS the physical Windows key. The remap makes
;  Windows treat it as Ctrl, but the key itself is still physically down while
;  the chord is held, and the shell checks the real key state when it decides
;  whether to act on Win+V. Injecting a second Win-down on top of a Win key
;  that is already physically down gets ignored.
;
;  So this waits for the chord to be let go, then sends a clean Win+V into a
;  keyboard with no modifiers down at all. In practice that is a few tens of
;  milliseconds after the keys come up, which reads as instant.
;
;  Set CFG_ClipDebug to true to log each step to clipboard-debug.log.
;==============================================================================

^+c::
{
    if !CmdHeld() {
        PassThru("c")
        return
    }
    ClipboardHistory()
}

ClipKey() => "HKCU\Software\Microsoft\Windows\CurrentVersion\Clipboard"

ClipboardHistoryEnabled() {
    try return RegRead(ClipKey(), "EnableClipboardHistory") = 1
    return false
}

ClipDbg(msg) {
    global CFG_ClipDebug
    if !CFG_ClipDebug
        return
    try FileAppend(FormatTime(, "HH:mm:ss") "  " msg "`n",
        A_ScriptDir "\clipboard-debug.log", "UTF-8")
}

ClipboardHistory() {
    ClipDbg("hotkey fired - cmd=" (CmdHeld() ? 1 : 0)
          . " shift=" (GetKeyState("LShift", "P") || GetKeyState("RShift", "P") ? 1 : 0)
          . " histOn=" (ClipboardHistoryEnabled() ? 1 : 0))

    if !ClipboardHistoryEnabled() {
        if MsgBox("Windows clipboard history is switched off, so Win+V has "
                . "nothing to open.`n`nTurn it on now?", "MacKeys", "YesNo Icon?") != "Yes"
            return
        try {
            RegWrite(1, "REG_DWORD", ClipKey(), "EnableClipboardHistory")
        } catch as e {
            MsgBox("Couldn't switch it on.`n`n" e.Message
                 . "`n`nSettings > System > Clipboard does the same thing.", "MacKeys", "Icon!")
            return
        }
        Sleep 400
    }

    ; Drop the Ctrl the Command remap is holding right away, so nothing is
    ; left stuck while we wait for the user's fingers to come off the chord.
    SendInput "{Blind}{LCtrl up}{RCtrl up}"
    SetTimer FireClipboardHistory, 20
}

FireClipboardHistory() {
    static waited := 0

    if CmdHeld() || GetKeyState("LShift", "P") || GetKeyState("RShift", "P") {
        if (waited += 20) < 1500
            return
        ClipDbg("chord still held after 1.5s - sending anyway")
    }

    SetTimer(, 0)
    held := waited
    waited := 0

    ; Every send below is blind. A non-blind one would notice the Win key we
    ; just put down, decide it is a stray modifier, and lift it again before
    ; the V arrives - which is how you end up sending a plain "v".
    SendInput "{Blind}{LCtrl up}{RCtrl up}{LShift up}{RShift up}{LAlt up}{RAlt up}"
    Sleep 20
    SendInput "{Blind}{LWin down}"
    Sleep 30
    SendInput "{Blind}{vk56}"          ; V by virtual key, layout-independent
    Sleep 30
    SendInput "{Blind}{LWin up}"

    ClipDbg("sent Win+V after " held "ms - active window now: " ClipActiveDesc())
}

ClipActiveDesc() {
    try {
        Sleep 250
        return WinGetClass("A") " / " WinGetTitle("A")
    }
    return "unreadable"
}

;==============================================================================
;  Everything else rides on the Command->Ctrl remap and needs no special case:
;  Cmd+C/V/X/Z/A/S/F/P/N/T/W/O/R/L/1-9, Cmd+Shift+T, Cmd+Shift+V,
;  Cmd+click, Cmd+scroll to zoom.
;==============================================================================


;##############################################################################
;  TOGGLE, TRAY AND WINDOW
;  Everything below stays alive even when the remaps are switched off.
;##############################################################################

#SuspendExempt
^!k::ToggleMac()
#SuspendExempt false

ToggleMac(*) {
    global g_MacMode
    g_MacMode := !g_MacMode
    ApplyMode(true)
    SaveSettings()
}

ApplyMode(notify) {
    global g_MacMode
    Suspend(!g_MacMode)
    state := g_MacMode ? "ON" : "OFF"
    A_IconTip := "MacKeys - macOS shortcuts " state "`nCtrl+Option+K to toggle"
    BuildTrayMenu()
    RefreshGui()
    if notify {
        body := g_MacMode ? "Command acts as Ctrl again." : "Stock Windows shortcuts are back."
        TrayTip(body, "macOS shortcuts " state, 1)
        SetTimer(() => TrayTip(), -2200)
    }
}

;------------------------------------------------------------------ tray menu

BuildTrayMenu() {
    global g_MacMode
    tm := A_TrayMenu
    tm.Delete()
    tm.Add("macOS shortcuts", ToggleMac)
    if g_MacMode
        tm.Check("macOS shortcuts")
    tm.Add()
    tm.Add("Open MacKeys window", (*) => ShowGui())
    tm.Add("Start with Windows", (*) => ToggleStartup())
    if StartupEnabled()
        tm.Check("Start with Windows")
    tm.Add()
    tm.Add("Reload", (*) => Reload())
    tm.Add("Quit MacKeys", (*) => ExitApp())
    tm.Default := "Open MacKeys window"
}

;------------------------------------------------------------- run at startup

StartupLink() => A_Startup "\MacKeys.lnk"

StartupEnabled() => FileExist(StartupLink()) ? true : false

ToggleStartup(*) {
    try {
        if StartupEnabled()
            FileDelete(StartupLink())
        else
            FileCreateShortcut(A_AhkPath, StartupLink(), A_ScriptDir,
                '"' A_ScriptFullPath '"', "macOS keyboard shortcuts for Windows")
    } catch as e {
        MsgBox("Couldn't change the startup entry.`n`n" e.Message, "MacKeys", "Icon!")
    }
    BuildTrayMenu()
    RefreshGui()
}

;------------------------------------------------------------------ settings

LoadSettings() {
    global
    g_MacMode                       := IniRead(g_Ini, "State",   "MacMode",        "1") = "1"
    CFG_CtrlArrowsSwitchDesktops    := IniRead(g_Ini, "Options", "CtrlArrowsDesk", "1") = "1"
    CFG_CtrlUpIsMissionControl      := IniRead(g_Ini, "Options", "CtrlUpTaskView", "1") = "1"
    CFG_CmdShiftSIsScreenshot       := IniRead(g_Ini, "Options", "CmdShiftSSnip",  "1") = "1"
    CFG_RightCmdIsWinKey            := IniRead(g_Ini, "Options", "RightCmdIsWin",  "0") = "1"
    CFG_RedoKey                     := IniRead(g_Ini, "Options", "RedoKey",       "^y")
}

SaveSettings() {
    global
    try {
        IniWrite(g_MacMode                    ? 1 : 0, g_Ini, "State",   "MacMode")
        IniWrite(CFG_CtrlArrowsSwitchDesktops ? 1 : 0, g_Ini, "Options", "CtrlArrowsDesk")
        IniWrite(CFG_CtrlUpIsMissionControl   ? 1 : 0, g_Ini, "Options", "CtrlUpTaskView")
        IniWrite(CFG_CmdShiftSIsScreenshot    ? 1 : 0, g_Ini, "Options", "CmdShiftSSnip")
        IniWrite(CFG_RightCmdIsWinKey         ? 1 : 0, g_Ini, "Options", "RightCmdIsWin")
        IniWrite(CFG_RedoKey,                          g_Ini, "Options", "RedoKey")
    } catch {
        ; read-only folder, nothing worth interrupting the user over
    }
}

;--------------------------------------------------------------------- window


BuildGui() {
    global
    ; Fixed light palette. AutoHotkey's common controls don't follow the
    ; Windows dark theme, so a half-dark window ends up looking worse than
    ; an honestly light one.
    gBack := "FFFFFF"
    gFg   := "1A1A1A"
    gDim  := "777777"
    gOk   := "0F7B3D"
    gBad  := "B3261E"

    gG := Gui("-MinimizeBox -MaximizeBox", "MacKeys")
    gG.BackColor := gBack
    gG.MarginX := 22
    gG.MarginY := 18
    gG.SetFont("s10", "Segoe UI")

    gG.SetFont("s19 w600 c" gFg)
    gG.Add("Text", "w470", "Keyboard mode")

    gG.SetFont("s11 w600 c" gFg)
    gState := gG.Add("Text", "w470 h24 y+6", "")

    gG.SetFont("s11 w600")
    gBtn := gG.Add("Button", "w470 h46 y+12", "")
    gBtn.OnEvent("Click", ToggleMac)

    gG.SetFont("s9 w400 c" gDim)
    gHint := gG.Add("Text", "w470 y+8 Center",
        "Ctrl+Option+K toggles from anywhere, as does the tray icon.")

    gG.SetFont("s10 w400 c" gFg)
    gG.Add("Text", "w470 h1 y+18 0x10")                  ; horizontal rule
    gG.SetFont("s12 w600 c" gFg)
    gG.Add("Text", "w470 y+12", "Options")
    gG.SetFont("s10 w400 c" gFg)

    gChkDesk := gG.Add("CheckBox", "w470 y+10",
        "Ctrl+Left / Ctrl+Right switch virtual desktops (macOS Spaces)")
    gChkTask := gG.Add("CheckBox", "w470 y+6",
        "Ctrl+Up opens Task View (Mission Control)")
    gChkSnip := gG.Add("CheckBox", "w470 y+6",
        "Cmd+Shift+S takes a screenshot (shadows Save As)")
    gChkRWin := gG.Add("CheckBox", "w470 y+6",
        "Keep the right Command key as a real Windows key")
    gChkRun  := gG.Add("CheckBox", "w470 y+6",
        "Start MacKeys when I log in")

    for c in [gChkDesk, gChkTask, gChkSnip, gChkRWin]
        c.OnEvent("Click", OptionChanged)
    gChkRun.OnEvent("Click", (*) => ToggleStartup())

    gG.SetFont("s12 w600 c" gFg)
    gG.Add("Text", "w470 y+18", "Shortcut map")
    gG.SetFont("s9 w400 c" gFg)
    lv := gG.Add("ListView", "w470 h230 y+8 -Multi Grid NoSortHdr Background" gBack,
        ["On the Mac keyboard", "What Windows gets"])
    for row in ShortcutMap()
        lv.Add(, row[1], row[2])
    lv.ModifyCol(1, 210)
    lv.ModifyCol(2, 240)

    gG.SetFont("s9 c" gDim)
    gG.Add("Text", "w470 y+14",
        "Closing this window leaves MacKeys running in the tray. "
      . "Quit it from there.")

    gG.OnEvent("Close", (*) => gG.Hide())
    gG.OnEvent("Escape", (*) => gG.Hide())
    gReady := true
}

OptionChanged(*) {
    global
    CFG_CtrlArrowsSwitchDesktops := gChkDesk.Value ? true : false
    CFG_CtrlUpIsMissionControl   := gChkTask.Value ? true : false
    CFG_CmdShiftSIsScreenshot    := gChkSnip.Value ? true : false
    CFG_RightCmdIsWinKey         := gChkRWin.Value ? true : false
    SaveSettings()
}

RefreshGui() {
    global
    if !gReady
        return
    try {
        gState.Text := g_MacMode ? "macOS shortcuts are ON - Command acts as Ctrl." : "macOS shortcuts are OFF - stock Windows behaviour."
        gState.Opt("c" (g_MacMode ? gOk : gBad))
        gBtn.Text := g_MacMode ? "Switch to Windows shortcuts" : "Switch to macOS shortcuts"
        gChkDesk.Value := CFG_CtrlArrowsSwitchDesktops
        gChkTask.Value := CFG_CtrlUpIsMissionControl
        gChkSnip.Value := CFG_CmdShiftSIsScreenshot
        gChkRWin.Value := CFG_RightCmdIsWinKey
        gChkRun.Value  := StartupEnabled()
        gG.Title := g_MacMode ? "MacKeys - macOS" : "MacKeys - Windows"
        try WinRedraw("ahk_id " gG.Hwnd)     ; no-op while the window is hidden
    } catch as e {
        try FileAppend("RefreshGui: " e.Message " @ line " e.Line "`n", A_ScriptDir "\error.log")
    }
}

ShowGui(*) {
    global gG
    RefreshGui()
    gG.Show()
}

ShortcutMap() {
    m := []
    m.Push(["Cmd + C / V / X / Z / A", "Ctrl + same"])
    m.Push(["Cmd + S / F / P / N / T / W", "Ctrl + same"])
    m.Push(["Cmd + L", "Ctrl+L, not Win+L lock"])
    m.Push(["Cmd + 1 through 9", "Ctrl + same"])
    m.Push(["Cmd + Tab", "Alt+Tab, held open"])
    m.Push(["Cmd + backtick", "Alt+Esc"])
    m.Push(["Cmd + Space", "Win+S search"])
    m.Push(["Cmd + Ctrl + Space", "Win+. emoji picker"])
    m.Push(["Cmd + Q", "Alt+F4 quit"])
    m.Push(["Cmd + Ctrl + Q", "Win+L lock screen"])
    m.Push(["Cmd + M", "Minimize window"])
    m.Push(["Cmd + Ctrl + F", "F11 full screen"])
    m.Push(["Cmd + Shift + S", "Win+Shift+S snip"])
    m.Push(["Cmd + Shift + 4 or 5", "Win+Shift+S snip"])
    m.Push(["Cmd + Shift + 3", "Full screen to Pictures"])
    m.Push(["Cmd + Shift + C", "Win+V clipboard history"])
    m.Push(["Cmd + Left / Right", "Snap window left / right"])
    m.Push(["Cmd + Shift + Left / Right", "Move to next display"])
    m.Push(["Cmd + Up / Down", "Ctrl+Home / Ctrl+End"])
    m.Push(["Cmd + Backspace", "Delete to line start"])
    m.Push(["Option + Left / Right", "Jump a word"])
    m.Push(["Option + Backspace", "Delete previous word"])
    m.Push(["Cmd + Option + Left / Right", "Start / end of line"])
    m.Push(["Cmd + Shift + bracket keys", "Previous / next tab"])
    m.Push(["Cmd + bracket keys", "Back / forward in browsers"])
    m.Push(["Cmd + Shift + Z", "Redo"])
    m.Push(["Cmd + Option + I", "Developer tools"])
    m.Push(["Cmd + Option + Esc", "Task Manager"])
    m.Push(["Ctrl + Left / Right", "Switch virtual desktop"])
    m.Push(["Ctrl + Up", "Task View"])
    m.Push(["Ctrl + Esc", "Start menu"])
    m.Push(["Shift + any of the above", "Selects instead of moves"])
    return m
}

