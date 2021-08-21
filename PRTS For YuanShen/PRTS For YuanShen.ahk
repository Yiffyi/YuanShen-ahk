/*
按键功能
    大写锁定 + W：自动按住 W
    大写锁定 + 左Shift：自动按住 左Shift
    大写锁定 + J：开始循环
    大写锁定 + K：停止循环
    大写锁定 + I：手动断网
    大写锁定 + U：手动联网
*/

; 主要配置
; 时间均为毫秒（ms） 1s = 1000ms

nLoopTime := 25000 ; 完整循环总用时（断网时间+Esc+联网时间）
nOnlineTime := 2000 ; 联网时间
nEscToMenuDelay := 700 ; 联网断网与 Esc 按键的时间差
nEscToLShiftDelay := 700 ; 按下 Esc 到开始前进的时间差
sYuanShenPath := "" ; 游戏路径，留空自动获取（脚本启动时游戏必须已经在运行）
bAutoSprint := True ; 自动恢复冲刺（W 和 左Shift）

; 固定配置
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; 热键模式配置
#InstallKeybdHook
#InstallMouseHook
#MaxThreadsPerHotkey 1
#MaxThreadsBuffer Off
SetKeyDelay, -1
SetMouseDelay, -1

; 以管理员身份启动程序
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try ; leads to having the script re-launching itself as administrator
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

; 适配国服和国际服
GroupAdd, ys, ahk_exe YuanShen.exe
GroupAdd, ys, ahk_exe GenshinImpact.exe

; 复位防火墙
Run, netsh advfirewall reset
Run, netsh advfirewall set allprofiles settings inboundusernotification disable
; 添加原神出站规则
Run, netsh advfirewall firewall add rule name="Out" dir=out action=block enable=no
Return

; 只在游戏窗口活动时有效
#IfWinActive ahk_group ys

; 主流程
NetHack:
Send, {Esc}
if (bAutoSprint) {
    Send, {w up}{LShift up}
}
Sleep, %nEscToMenuDelay%

Gosub, EnableNetwork
Sleep, %nOnlineTime%
Gosub, DropNetwork

Sleep, %nEscToMenuDelay%
Send, {Esc}
if (bAutoSprint) {
    Sleep, %nEscToLShiftDelay%
    Send, {LShift down}{w down}
}
Return

CapsLock & j::
Gosub, NetHack
SetTimer, NetHack, %nLoopTime%
ToolTip, 代理指挥正在工作,800,300,2
Return

CapsLock & k::
Gosub, EnableNetwork
SetTimer, NetHack, Off
Send, {w up}{LShift up}
ToolTip,,,,1
ToolTip,,,,2
Return

CapsLock & u::
EnableNetwork:
ToolTip, 联网
Run, netsh advfirewall firewall set rule name="Out" new enable=no,,Hide
Return

CapsLock & i::
DropNetwork:
ToolTip, 全员断网！
Run, netsh advfirewall firewall set rule name="Out" new enable=yes,,Hide
Return

CapsLock & w::
Send, {w down}
Return

CapsLock & LShift::
Send, {LShift down}
Return

~*s::
If Not GetKeyState("w", "P")
{
    Send {w up}
}
Return

#IfWinActive
