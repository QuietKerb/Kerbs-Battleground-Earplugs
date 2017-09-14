; You need nircmd.exe in your windows directory:
; http://www.nirsoft.net/utils/nircmd-x64.zip
; nircmd handles the volume changing

; And you need autohotkey installed to run the script:
; https://www.autohotkey.com/download/ahk-install.exe

; Right click the script and run with autohotkey if it doesn't by default
; (Green H icon in system tray when running, right click it and exit to close)

; Press the hotkey (Insert by default) to toggle earplugs in/out

; OPTIONS ----------------------------------------------------------------------

; Change the value of 'HOTKEY' below to change the hotkey
; Here's a list of options:
; https://www.autohotkey.com/docs/KeyList.htm

HOTKEY = INSERT

; Change the Value of 'EARPLUGVOL' below to set the volume % with earplugs in
; 0 = 0%, 0.5 = 50%, etc

EARPLUGVOL := 0.2
--------------------------------------------------------------------------------

; Init some stuff --------------------------------------------------------------
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
normalVolume := true
--------------------------------------------------------------------------------

; Set hotkey -------------------------------------------------------------------
Hotkey, %HOTKEY%, toggleVolume
Return
--------------------------------------------------------------------------------

; Toggle volume ----------------------------------------------------------------
toggleVolume:
WinGet, pid, PID, PLAYERUNKNOWN'S BATTLEGROUNDS
WinGetPos, X, Y, Width, Height, PLAYERUNKNOWN'S BATTLEGROUNDS

if (normalVolume) {
  ToolTip, EARPLUGS IN, ((Width / 2) - 30), (Height - (Height / 5))
  run, nircmd.exe setappvolume /%pid% %EARPLUGVOL%
  normalVolume := false
} else {
  ToolTip
  run, nircmd.exe setappvolume /%pid% 1
  normalVolume := true
}

Return
--------------------------------------------------------------------------------
