@echo off
cd /d "%~dp0"
"%~dp0AutoHotkey64.exe" /ErrorStdOut /validate "%~dp0MacKeys.ahk" > "%~dp0error.log" 2>&1
echo EXIT=%ERRORLEVEL%>>"%~dp0error.log"
