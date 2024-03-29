﻿/*
按键功能
    按住 侧键1：狂单击鼠标左键
    按住 F：狂点 F（捡物品）
    按住 空格：狂按空格（摆脱解除冰冻和跑跳）

    右 Control：鼠标中键（元素视野）
    侧键2：W
    鼠标中键：F
    
    大写锁定 + W：自动按住 W
    大写锁定 + X：强制退出
    大写锁定 + Z：老板键，启动或隐藏原神（自动 ESC）
    大写锁定 + A：启动 AfterBurner
    大写锁定 + O：启动 OBS
    大写锁定 + 空格：按一段时间的空格（离开浪船）
    大写锁定 + O：启动 OBS
*/

; 主要配置
; 时间均为毫秒（ms） 1s = 1000ms

sYuanShenPath := "E:\Genshin Impact\Genshin Impact Game\YuanShen.exe"
sAfterBurnerPath := "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe"
sOBSPath := "C:\Program Files\obs-studio\bin\64bit\obs64.exe"
sOBSWorkingDir := "C:\Program Files\obs-studio\bin\64bit"
bIntA := False
bActive := False


; 固定配置
#SingleInstance
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
DetectHiddenWindows, On

; 以管理员身份启动程序
; https://stackoverflow.com/questions/43298908/how-to-add-administrator-privileges-to-autohotkey-script
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
GroupAdd, ys, ahk_exe YuanShen.exe ahk_class UnityWndClass
GroupAdd, ys, ahk_exe GenshinImpact.exe ahk_class UnityWndClass
Return

WaitUP(waitKey, waitTime := 0.1)
{
    KeyWait, %waitKey%, T%waitTime%
    If Not ErrorLevel
    {
        Return True ; Released
    }
    Return False ; Still down
}


CapsLock & x::
ExitApp
Return

CapsLock & z::
if not WinExist("ahk_group ys")
{
    Run, %sYuanShenPath%
    Return
} else if WinActive("ahk_group ys")
{
    Send, {Esc}
    WinMinimize, ahk_group ys
    WinHide, ahk_group ys
    Return
} else WinShow, ahk_group ys
Return

CapsLock & a::Run, %sAfterBurnerPath%
CapsLock & o::Run, %sOBSPath%, %sOBSWorkingDir%


; 只在游戏窗口活动时有效
#IfWinActive ahk_group ys

~w::
~a::
~s::
~d::
~e::
~q::
bIntA := True
If Not GetKeyState("w", "P")
{
    Send {w up}
}
Return

~w Up::
~s Up::
~a Up::
~d Up::
~e Up::
~q Up::
bIntA := False
Return

*XButton1::
Loop
{
    if !bIntA
        Send, {Blind}{LButton down}{LButton up}
    if WaitUP("XButton1")
        Return
}
Return

MButton::f
XButton2::w
RCtrl::MButton

CapsLock & Space::
Send {Space down}
Sleep, 1000
Send {Space up}
Return

~Space::
if WaitUP("Space", 0.3)
    Return

Loop
{
    Send, {Blind}{Space}
    if WaitUP("Space")
        Return
}
Return

~*f::
Loop
{
    Send, {Blind}f
    if WaitUP("f")
        Return
}
Return

CapsLock & w::
Send, {Blind}{w down}
Return

#IfWinActive