; You need nircmd.exe in your windows directory:
; http://www.nirsoft.net/utils/nircmd-x64.zip
; nircmd handles the volume changing

; And you need autohotkey installed to run the script:
; https://www.autohotkey.com/download/ahk-install.exe

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

; Init some stuff
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Pixel, Relative

; Set hotkey
Hotkey, %HOTKEY%, toggleVolume
Hotkey, ^%HOTKEY%, toggleVolume
Hotkey, !%HOTKEY%, toggleVolume
Hotkey, +%HOTKEY%, toggleVolume
Hotkey, +!%HOTKEY%, toggleVolume
Return

; Toggle volume function
normalVolume := true
toggleVolume:
  ; Check for Battlegrounds Window
  if WinExist ("PLAYERUNKNOWN'S BATTLEGROUNDS") {
    WinGet, pid, PID, PLAYERUNKNOWN'S BATTLEGROUNDS
    WinGetPos, X, Y, Width, Height, PLAYERUNKNOWN'S BATTLEGROUNDS
  }

  ; Check for Fortnite Window
  if WinExist ("Fortnite"){
    WinGet, pid, PID, Fortnite
    WinGetPos, X, Y, Width, Height, Fortnite
  }

  ; Toggle volume
  if (normalVolume) {
    ToolTip, EARPLUGS IN, ((Width / 2) - 48), (Height - (Height / 5))
    run, nircmd.exe setappvolume /%pid% %EARPLUGVOL%
    normalVolume := false
  } else {
    ToolTip
    run, nircmd.exe setappvolume /%pid% 1
    normalVolume := true
  }
Return

; Auto reconnect
#MaxThreadsPerHotkey 3
Del::
  #MaxThreadsPerHotkey 1 WinGetPos, X, Y, Width, Height, PLAYERUNKNOWN'S BATTLEGROUNDS
  try = 0
  if (keepConnecting){
    keepConnecting := false
    Return
  }
  keepConnecting := true
  Loop
  {
      Tooltip, Connecting..., ((Width / 2) - 48), (Height - (Height / 5))

      ; Check for black at top left corner - ie. not connected
      PixelSearch, Px2, Py2, 0, 0, 10, 10, 0x000000, 0, Fast
      if (ErrorLevel){
        Tooltip, Connected! After %try% tries., ((Width / 2) - 48), (Height - (Height / 5))
        Sleep, 3000
        ToolTip
        Break
      }

      Sleep, 100

      ; Check for yellow of reconnect button at center of screen
      PixelSearch, Px, Py, Width/2-10, Height/2-10, Width/2+10, Height/2+10, 0x005377, 3, Fast
      if (!ErrorLevel){
        Click %Px%, %Py%
        try++
        ToolTip, Try number %try%..., ((Width / 2) - 48), (Height - (Height / 5))
        Sleep, 3000
      }

      ; Stop if toggled off
      if (!keepConnecting){
        ToolTip
        Break
      }
  }
  keepConnecting := false
Return
