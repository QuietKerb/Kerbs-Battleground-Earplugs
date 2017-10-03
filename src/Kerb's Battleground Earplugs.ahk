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

EARPLUGVOL = 0.2
--------------------------------------------------------------------------------

; Init some stuff
#Include VA.ahk
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
  } else {
    ; Check for Fortnite Window
    if WinExist ("Fortnite"){
      WinGet, pid, PID, Fortnite
      WinGetPos, X, Y, Width, Height, Fortnite
    }
  }
  ; Get volume object
  if !(Volume := GetVolumeObject(pid)){
    ToolTip, There was a problem retrieving the application volume interface
  }

  ; Toggle volume
  if (normalVolume) {
    ToolTip, EARPLUGS IN, ((Width / 2) - 48), (Height - (Height / 5))
    VA_ISimpleAudioVolume_SetMasterVolume(Volume, EARPLUGVOL)
    normalVolume := false
  } else {
    ToolTip
    VA_ISimpleAudioVolume_SetMasterVolume(Volume, 1.0)
    normalVolume := true
  }
Return

; Auto reconnect
#MaxThreadsPerHotkey 3
Home::
  #MaxThreadsPerHotkey 1 WinGetPos, X, Y, Width, Height, PLAYERUNKNOWN'S BATTLEGROUNDS
  try = 0
  if (keepConnecting){
    keepConnecting := false
    Return
  }
  keepConnecting := true
  Tooltip, Connecting..., ((Width / 2) - 48), (Height - (Height / 5))
  Loop
  {
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

;-----------------------------------------------------------------------------
; VA stuff - this section written by Kristoffer Tvera - https://github.com/kristoffer-tvera/mute-current-application
;Required for app specific mute
GetVolumeObject(Param = 0)
{
    static IID_IASM2 := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
    , IID_IASC2 := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
    , IID_ISAV := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"

    ; Get PID from process name
    if Param is not Integer
    {
        Process, Exist, %Param%
        Param := ErrorLevel
    }

    ; GetDefaultAudioEndpoint
    DAE := VA_GetDevice()

    ; activate the session manager
    VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)

    ; enumerate sessions for on this device
    VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
    VA_IAudioSessionEnumerator_GetCount(IASE, Count)

    ; search for an audio session with the required name
    Loop, % Count
    {
        ; Get the IAudioSessionControl object
        VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)

        ; Query the IAudioSessionControl for an IAudioSessionControl2 object
        IASC2 := ComObjQuery(IASC, IID_IASC2)
        ObjRelease(IASC)

        ; Get the session's process ID
        VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)

        ; If the process name is the one we are looking for
        if (SPID == Param)
        {
            ; Query for the ISimpleAudioVolume
            ISAV := ComObjQuery(IASC2, IID_ISAV)

            ObjRelease(IASC2)
            break
        }
        ObjRelease(IASC2)
    }
    ObjRelease(IASE)
    ObjRelease(IASM2)
    ObjRelease(DAE)
    return ISAV
}

VA_ISimpleAudioVolume_SetMasterVolume(this, ByRef fLevel, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "float", fLevel, "ptr", VA_GUID(GuidEventContext))
}
VA_ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel) {
    return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "float*", fLevel)
}
;-----------------------------------------------------------------------------
