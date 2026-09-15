#SingleInstance, Force
#Persistent
#NoEnv
#NoTrayIcon

SetTitleMatchMode, 2
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

global version := "v 1.6.1"
global LicenseURL := "aHR0cHM6Ly9naXN0LmdpdGh1YnVzZXJjb250ZW50LmNvbS9NYWtzaW00ZWtrL2Jl`nMmQ0MjE5MzE1NjFkZDAxYjQzM2Y5M2NhNTMyOWQwL3Jhdy9WaU1lTGxZLWtleXMu`ndHh0"


global repID, ansID, ansLogID
global hotkeys := {}
global previousHotkeys := {}
global punishMap := {}
global currentCmdKey := ""
global ChatIsOpen := false
global isHumanInput, reportLog, punishHelperStatus, autoIssueStatus, lastRequest, additionalFeaturesStatus, adminStatsStatus
global active := 0
global productCount := 0
global currentSetup, CMDDelay, InputDelay1, InputDelay2, userNickname, guiColor, scriptType
global scriptDir := A_MyDocuments . "\ViMeLlY Script\"
global settingsFile := scriptDir . "settings.ini"
global punishFile := scriptDir . "punish.txt"
global autoIssueFile := scriptDir . "auto-issue.txt"
global additionalFeaturesFile := scriptDir . "ViMeLlY-Features.ahk"
global statisticFile := scriptDir . "statistic.ini"
global scriptLogo1 := A_Temp . "\ViMeLlYScript_1.png"
global scriptLogo2 := A_Temp . "\ViMeLlYScript_2.png"
global scriptLogo3 := A_Temp . "\ViMeLlYScript_3.png"
global scriptLogo4 := A_Temp . "\ViMeLlYScript_4.png"
global scriptLogo5 := A_Temp . "\ViMeLlYScript_5.png"
global scriptVersion := A_Temp . "\ViMeLlYScript.ver"
global answerComplaint, answerCommand, responses
global filePath := FindChatlogPath()
global lastReadLine := checkChatLog()
global lastLineNum
global truckerSettings := false
global scriptSettings := false
global orderOneGo, isToolTipActive
global today := A_DD . "." . A_MM . "." . A_YYYY

SetTimer, checkUpdates, -50 ; ПРОВЕРКА ОБНОВЛЕНИЙ / ЛИЦЕНЗИИ

IniRead, scriptModeStatus, %settingsFile%, Preset, scriptMode
global scriptMode := scriptModeStatus

IniRead, userNickname, %settingsFile%, Preset, userNickname
IniRead, rL, %settingsFile%, Preset, reportLog
IniRead, aI, %settingsFile%, Preset, autoIssueStatus
IniRead, pH, %settingsFile%, Preset, punishHelperStatus
IniRead, aF, %settingsFile%, Preset, additionalFeaturesStatus
IniRead, aS, %settingsFile%, Preset, adminStatsStatus
IniRead, isToolTipActive, %settingsFile%, Preset, isToolTipActive

ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Инициализация скрипта...", 300)

reportLog := (rL == "") ? 0 : rL
autoIssueStatus := (aI == "") ? 0 : aI
punishHelperStatus := (pH == "") ? 0 : pH
additionalFeaturesStatus := (aF == "") ? 0 : aF
adminStatsStatus := (aS == "") ? 0 : aS

if (rL && rL != "ERROR") {
    SetTimer, answerLogger, 500
} if (aF && aF != "ERROR") {
    global pid
    Run, %additionalFeaturesFile%, , , pid
}

Sleep, 300
ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ViMeLlY Script (" . version . ") загружен. Приятного пользования!", 777)

Stub:
Return

; ============================================================================================================================
; ============================================================================================================================
; #region || ПРОВЕРКА ЛИЦЕНЗИИ
; ============================================================================================================================

global CurrentHWID := ""
global EnteredKey  := ""

GetHWID() {
    try {
        for obj in ComObjGet("winmgmts:").ExecQuery("Select ProcessorId from Win32_Processor")
            cpu := obj.ProcessorId
        for obj in ComObjGet("winmgmts:").ExecQuery("Select VolumeSerialNumber from Win32_LogicalDisk where DeviceID='C:'")
            hdd := obj.VolumeSerialNumber
        return cpu . "-" . hdd
    } catch {
        return "UNKNOWN-HWID"
    }
}

checkLicenseKey() {
    global CurrentHWID, EnteredKey, scriptType, userNickname, LicenseURL

    license := Base64Decode(LicenseURL)
    CurrentHWID := GetHWID()

    SavedKey := ""
    if FileExist(settingsFile) {
        IniRead, SavedKey, %settingsFile%, License, Key, %A_Space%
        SavedKey := Trim(SavedKey)
    }
    
    if (SavedKey = "" || SavedKey = "ERROR") {        
        Gui, ActGui:New, +AlwaysOnTop -MinimizeBox, Активация ViMeLlY Script
        Gui, ActGui:Add, Text, x15 y12 w350 h20, Ваш Логин:
        Gui, ActGui:Font, s7 Normal
        Gui, ActGui:Add, Link, -Tabstop x15 y27 w350 h20, * Если у вас нет ключа, обратитесь <a href="https://t.me/+fHeqJGEqTnQ0YTEy">к разработчику</a>.

        Gui, ActGui:Font, s9 Normal
        Gui, ActGui:Add, Edit, x15 y47 w230 h23 ReadOnly, %CurrentHWID%
        Gui, ActGui:Add, Button, x255 y46 w110 h25 gCopyHwidAct, 📋 Скопировать
        
        Gui, ActGui:Font, s9 Bold
        Gui, ActGui:Add, Text, x15 y77 w350 h20, Введите ваш ключ доступа:
        Gui, ActGui:Font, s9 Normal
        Gui, ActGui:Add, Edit, x15 y97 w350 h23 vEnteredKey
        Gui, ActGui:Add, Button, x15 y122 w350 h32 gSubmitKeyAct Default, 🔑 Активировать
        GuiControl, ActGui:Focus, SubmitKeyAct
        
        Gui, ActGui:Show, w380 h168
        
        WinWaitClose, Активация ViMeLlY Script
        
        SavedKey := Trim(EnteredKey)
        if (SavedKey = "") {
            ExitApp
        }
    }
    
    RawKeys := ""
    
    ; Способ 1: WinHttpRequest с явным включением TLS 1.2 (2048) и обходом ошибок SSL
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Option(9) := 2048  ; Принудительный TLS 1.2
        whr.Option(4) := 13056 ; Игнорировать ошибки сертификата
        whr.SetTimeouts(5000, 5000, 5000, 5000)
        whr.Open("GET", license . "?nocache=" . A_Now . A_MSec, false)
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        whr.Send()
        if (whr.Status = 200)
            RawKeys := whr.ResponseText
    } catch e {
        MsgBox, 16, Помилка, % "Сталася помилка!`nПовідомлення: " . e.Message
    }
    
    ; Способ 2: Резервный метод через ServerXMLHTTP, если WinHttp сбоит
    if (RawKeys = "") {
        try {
            xml := ComObjCreate("Msxml2.ServerXMLHTTP.6.0")
            xml.open("GET", license . "?nocache=" . A_Now . A_MSec, false)
            xml.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            xml.send()
            if (xml.status = 200)
                RawKeys := xml.responseText
        } catch e {
            MsgBox, 16, Помилка, % "Сталася помилка!`nПовідомлення: " . e.Message
        }
    }
    
    if (RawKeys = "") {
        MsgBox, 16, Ошибка сети, Не удалось связаться с сервером проверки ключей.
        ExitApp
    }
    
    IsValid := false
    Loop, Parse, RawKeys, `n, `r
    {
        CurrentLine := Trim(A_LoopField)
        if (CurrentLine = "")
            continue
        
        Parts := StrSplit(CurrentLine, [":", "="])
        userNickname  := Trim(Parts[1])
        scriptType  := Trim(Parts[2])
        HwidFromList := Trim(Parts[3])
        
        if (userNickname = SavedKey && HwidFromList = CurrentHWID) {
            IsValid := true
            break
        }
    }
    
    if (IsValid) {
        IniWrite, %SavedKey%, %settingsFile%, License, Key
    } else {
        IniRead, scriptModeStatus, %settingsFile%, Preset, scriptMode

        if FileExist(settingsFile) {
            IniDelete, %settingsFile%, License, Key
            IniDelete, %settingsFile%, License
        } if (scriptModeStatus != scriptType) {
            MsgBox, 16, Ошибка инициализации, Возник конфликт версий скрипта.
            Reload
        }

        MsgBox, 16, Ошибка активации, % "Введен недействительный ключ."
        Reload
    }
}

CopyHwidAct:
    Clipboard := CurrentHWID
return

SubmitKeyAct:
    Gui, ActGui:Submit
    Gui, ActGui:Destroy
return

; ============================================================================================================================
; ============================================================================================================================

checkUpdates() {
    if (!FileExist(scriptVersion)) {
        UrlDownloadToFile, https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlYScript.ver, %scriptVersion%
    } if (FileExist(scriptVersion)) {
        UrlDownloadToFile, https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlYScript.ver, %scriptVersion%
        FileRead, serverVersion, %scriptVersion%
        updateUrl := "https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlY_Script.exe"
        
        if (serverVersion != version) {
            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Доступно обновление ViMeLlY Script (" . serverVersion . ")! Начинаю загрузку...", 1000)
            UrlDownloadToFile, %updateUrl%, %A_Temp%\ViMeLlY Script.exe
            updater := A_Temp "\update.ahk"
            FileDelete, %updater%
            FileAppend,
                        (
                        Sleep, 1000
                        Loop {
                            FileMove, %A_Temp%\ViMeLlY Script.exe, %A_ScriptFullPath%, 1
                            if !ErrorLevel
                                break
                            Sleep, 500
                        }
                        Run, "%A_ScriptFullPath%"
                        ExitApp
            ), %updater%, UTF-8

            Run, "%A_AhkPath%" "%updater%"
            FileDelete, %scriptVersion%
            FileDelete, %settingsFile%
            ExitApp
        } else {
            if (FileExist(A_Temp . "\update.ahk")) {
                FileDelete, %A_Temp%\update.ahk
            } if (FileExist(A_Temp . "\ViMeLlYScript.ver")) {
                FileDelete, %A_Temp%\ViMeLlYScript.ver
            }

            SetTimer, scriptSettingsChecker, 500

            LoadHotkeys()
            Sleep, 1000
            BindHotkeys()
            
            if (scriptMode == "Admin") {
                SetTimer, adminsStatistics, -500
                SetTimer, CountAdminActions, 500
                SetTimer, punishHelper, 3000
            } else if (scriptMode == "Player") {
                IniRead, orderOneGo, %settingsFile%, Preset, orderOneGo
                orderOneGo := orderOneGo
                SetTimer, ExpectationOfProfit, 333
            }
        }
    }
}


scriptSettingsChecker() {
    if (!FileExist(scriptLogo1) || !FileExist(scriptLogo2) || !FileExist(scriptLogo3) || !FileExist(scriptLogo4) || !FileExist(scriptLogo5) ) {
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1IRUsSOw92CPi7Olkuq3pP13kgQzxfczu&export=download&authuser=0&confirm=t&uuid=d232d00d-d535-4dc5-88e4-e08429256637&at=AN8xHopR-PLqyZs8yJ1OtbBRXRSn:1758379704317, %A_Temp%\ViMeLlYScript_1.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1px54qZCf4zw7SXOGNvzFme4OTFmnP_TQ&export=download&authuser=0&confirm=t&uuid=a591b692-7d58-4220-97a0-47870f1d954e&at=AN8xHoqO47w_bnM5MXEbxR6_O1-w:1758379699137, %A_Temp%\ViMeLlYScript_2.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1PnUALVxeETh2Zwt6lo_OACkTR5ipbafi&export=download&authuser=0&confirm=t&uuid=94c272fa-a6b1-4010-93d5-d7641eb60f1a&at=AN8xHooLAWKRoLQtdnZgr-ZVRy04:1758379692936, %A_Temp%\ViMeLlYScript_3.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1FVUiGqg-8MQ2BE4XI4XOttUreelogqiR&export=download&authuser=0&confirm=t&uuid=035df7bc-4301-4210-8d9e-032968bff93c&at=AN8xHoqDku86yg8xr3NlBkKMxGUR:1758379686118, %A_Temp%\ViMeLlYScript_4.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1JgvrXuyC3e3yyXJ9L0W8X3q9nlekN6j1&export=download&authuser=0&confirm=t&uuid=909d92a5-838f-462e-8d91-703d94ad79c4&at=AN8xHopXUr5z4lqeghnhxd7mbCom:1758379671208, %A_Temp%\ViMeLlYScript_5.png
    } if (!FileExist(scriptDir)) {
        FileCreateDir, %scriptDir%
    } if (!FileExist(settingsFile)) {     
        checkLicenseKey() ; ПРОВЕРКА ЛИЦЕНЗИИ

        IniWrite, F2, %settingsFile%, Keys, Menu
        IniWrite, %scriptType%, %settingsFile%, Preset, scriptMode
        IniWrite, 0, %settingsFile%, Preset, isHumanInput
        IniWrite, 1, %settingsFile%, Preset, isToolTipActive

        userNickname := Base64Encode(userNickname)
        IniWrite, %userNickname%, %settingsFile%, Preset, userNickname

        if (scriptMode == "Admin") {
            IniWrite, %A_Space%, %settingsFile%, Keys, Watch
            IniWrite, %A_Space%, %settingsFile%, Keys, Request
            IniWrite, %A_Space%, %settingsFile%, Keys, Reply
            IniWrite, %A_Space%, %settingsFile%, Keys, humanReply
            IniWrite, F10, %settingsFile%, Keys, AdminStats
            IniWrite, %A_Space%, %settingsFile%, Keys, CopyAChat
            IniWrite, %A_Space%, %settingsFile%, Keys, autoIssue

            IniWrite, Быстро, %settingsFile%, Preset, currentSetup
            IniWrite, 0, %settingsFile%, Preset, reportLog
            IniWrite, 0, %settingsFile%, Preset, autoIssueStatus
            IniWrite, 0, %settingsFile%, Preset, punishHelperStatus
            IniWrite, 0, %settingsFile%, Preset, additionalFeaturesStatus
            IniWrite, 1, %settingsFile%, Preset, adiminStatsStatus

            ; === Answers
            IniWrite, Здравствуйте`, начал работу., %settingsFile%, Answers, Spectate
            IniWrite, Нарушений не обнаружил., %settingsFile%, Answers, Ans1
            IniWrite, Не видел полной ситуации., %settingsFile%, Answers, Ans2
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans3
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans4
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans5
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans6
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans7
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans8
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans9
            IniWrite, %A_Space%, %settingsFile%, Answers, Ans0
            IniWrite, Игрок покинул игру., %settingsFile%, Answers, ansOffline
        } else if (scriptMode == "Player") {
            IniWrite, %A_Space%, %settingsFile%, Keys, autoEdit
            IniWrite, %A_Space%, %settingsFile%, Keys, autoBizlist
            IniWrite, 0, %settingsFile%, Preset, orderOneGo
        }

        IniWrite, %A_Space%, %settingsFile%, Keys, EmergencyDelete
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл настроек создан.", 1700)
        Reload
    } else {
        checkLicenseKey() ; ПРОВЕРКА ЛИЦЕНЗИИ
    }
    
    if (!FileExist(punishFile) && punishHelperStatus && scriptMode == "Admin") {
        text := "# Тут можно добавлять/удалять/изменять виды наказаний`n# Формат: /команда = /командаНаказания Время Причина`n# Пример: /epp = /jail 60 Езда по полям`n`n"
        FileAppend, %text%, %punishFile%, UTF-8
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл скрипта наказаний создан.", 1700)
    } if (!FileExist(autoIssueFile) && autoIssueStatus && scriptMode == "Admin") {
        text := "# Тут можно вставить список наказаний, которые нужно выдать в игре. `n# Пример: /offjail Nick_Name 120 Жалоба на игрока 1`n`n"
        FileAppend, %text%, %autoIssueFile%, UTF-8
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл авто-выдачи создан.", 1700)
    } if (!FileExist(additionalFeaturesFile) && additionalFeaturesStatus) {
        text := "#SingleInstance`, Force `; Позволяет запускать лишь 1 скрипт одновременно `n#Persistent `; Оставляет скрипт работающим на постоянной основе.`n#NoEnv `; - Отключает автоматическое наследование переменных окружения Windows.`n#NoTrayIcon `; - Скрывает значок скрипта в системном трее. `n`nSetTitleMatchMode, 2 `; - Устанавливает режим поиска окон по заголовку.`nSetBatchLines, -1 `; - Устанавливает максимальную производительность.`nSendMode Input `; - Устанавливает режим отправки клавиш.`n`n`; === Ваш скрипт`n`n`n`n;================================================================================================================================================="
        FileAppend, %text%, %additionalFeaturesFile%, UTF-8
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл доп. скрипта создан.", 1700)
    } if (!FileExist(statisticFile) && userNickname != "ERROR" && adminStatsStatus && scriptMode == "Admin") {
        IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
        IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
        IniWrite, %totalAns%, %statisticFile%, %today%, totalAns
        IniWrite, %totalJails%, %statisticFile%, %today%, totalJails
    }
}


adminsStatistics() {
    IniRead, userNickname, %settingsFile%, Preset, userNickname
    IniRead, savedDate, %settingsFile%, %userNickname%, Date
    IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
    IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
    adminName := Base64Decode(userNickname)
    Sleep, 333

    if ((userNickname != "" && userNickname != "ERROR") && savedDate != today) {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Сбрасываю статистику...
        global today := A_DD . "." . A_MM . "." . A_YYYY
        IniWrite, %totalAns%, %statisticFile%, %savedDate%, totalAns
        IniWrite, %totalJails%, %statisticFile%, %savedDate%, totalJails
        IniWrite, %today%, %settingsFile%, %userNickname%, Date
        IniWrite, 0, %settingsFile%, %userNickname%, totalAns
        IniWrite, 0, %settingsFile%, %userNickname%, totalJails
        IniDelete, %settingsFile%, ProcessedLines
        Sleep, 333
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Ваша статистика сброшена.
        Sleep, 777
        ToolTip
    } else if (userNickname != "" && userNickname != "ERROR") {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Загружаю статистику...
        Sleep, 333

        if (totalAns = "" || totalAns = "ERROR") {
            IniWrite, 0, %settingsFile%, %userNickname%, totalAns
            ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Ошибка при загрузке pm'ок`, сбрасываю значения...
            Sleep, 1771
        } if (totalJails = "" || totalJails = "ERROR") {
            IniWrite, 0, %settingsFile%, %userNickname%, totalJails
            ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Ошибка при загрузке jail'ов`, сбрасываю значения...
            Sleep, 1771
        }
        
        IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
        IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Статистика загружена. Текущие значения:`n`n★ Администратор %adminName% ⤵︎`n- ✉ Ответов: %totalAns% (/pm)`n- ⚖ Jail'ов: %totalJails% (/jail)
        Sleep, 777
        ToolTip
    }
}


guiColorFunc() {
    Random, randomLogo, 1, 5

    if (randomLogo = 1) {
        Gui, ViMeLlY:Color, 4B2740
        guiColor := "4B2740"
    } else if (randomLogo == 2) {
        Gui, ViMeLlY:Color, 3A3B33
        guiColor := "3A3B33"
    } else if (randomLogo == 3) {
        Gui, ViMeLlY:Color, 423F39
        guiColor := "423F39"
    } else if (randomLogo == 4) {
        Gui, ViMeLlY:Color, 737985
        guiColor := "737985"
    } else {
        Gui, ViMeLlY:Color, 2B2B31
        guiColor := "2B2B31"
    }

    return randomLogo
}


Menu:
    randomLogo := guiColorFunc()
    ansLogStatus := reportLog ? "✔ Лог жалоб" : "✘ Лог жалоб"
    aspStatus := isHumanInput ? "Имитация ручного ввода ☺" : "Автоматический ♛"
    autoIssueSwitch := autoIssueStatus ? "✔ Автовыдача" : "✘ Автовыдача"
    punishHelperSwitch := punishHelperStatus ? "✔ Умные наказания" : "✘ Умные наказания"
    additionalFeaturesSwitch := additionalFeaturesStatus ? "✔ Доп. возможности " : "✘ Доп. возможности "
    adminStatsSwitch := adminStatsStatus ? "✔" : "✘"

    IniRead, orderOneGo, %settingsFile%, Preset, orderOneGo

    Gui, ViMeLlY:New,, ViMeLlY Script
    Gui, ViMeLlY:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlY:Color, % guiColor
    Gui, ViMeLlY:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Text, w345 Center, ViMeLlY Script - Главная
    Gui, ViMeLlY:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Button, yp x317 gReload,⟲
    Gui, ViMeLlY:Add, Button, yp x+1 gStop,⊚
    Gui, ViMeLlY:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlY:Font, s8, Comic Sans MS
    Gui, ViMeLlY:Add, Button, xm y+1 gHotKeys w190,🕹 Настройки клавиш྾
    Gui, ViMeLlY:Add, Button, x+0.5 yp w161 gScriptSettings,⚙️ Настройки скрипта྾
    Gui, ViMeLlY:Add, Button, x+0.5 yp gOpenSettings w30, 📂

    if (scriptSettings) {
        Gui, ViMeLlY:Add, Text, x35 y+1, ♯ Настройки скрипта:

        if (isHumanInput) {
            Gui, ViMeLlY:Add, Checkbox, x50 y+1 w330 Checked vIsHumanInputV gIsHumanInputCheckBox, Иммитация ручного ввода команд
        } else {
            Gui, ViMeLlY:Add, Checkbox, x50 y+1 w330 vIsHumanInputV gIsHumanInputCheckBox, Иммитация ручного ввода команд
        } if (isToolTipActive) {
            Gui, ViMeLlY:Add, Checkbox, x50 y+1 w330 Checked vIsToolTipActiveV gIsToolTipActiveCheckBox, Игнорирование подсказок скрипта
        } else {
            Gui, ViMeLlY:Add, Checkbox, x50 y+1 w330 vIsToolTipActiveV gIsToolTipActiveCheckBox, Игнорирование подсказок скрипта
        }
    }

    Gui, ViMeLlY:Font, s7, Comic Sans MS
    if (scriptMode == "Admin") {
        Gui, ViMeLlY:Add, Button, xm y+1 w80 gOpenAutoIssue, 👁️ Автовыдача
        Gui, ViMeLlY:Add, Button, x+0.5 yp gAnswers w120,⚙️ Настройки ответов྾
        Gui, ViMeLlY:Add, Button, x+1 yp w130 gOpenPunishHelper, 👁️ Помощник наказаний
        Gui, ViMeLlY:Add, Button, x+1 yp w49 gOpenAdditionalFeatures, 👁️ Доп.
        Gui, ViMeLlY:Add, Button, x17 y+1 w75 gReportLog_ToggleStatus vStatusLogButton, %ansLogStatus%
        Gui, ViMeLlY:Add, Button, x+1 yp w80 gAutoIssue_ToggleStatus vAutoIssueButton, %autoIssueSwitch%
        Gui, ViMeLlY:Add, Button, x+1 yp w111 gPunishHelper_ToggleStatus vPunishHelperButton, %punishHelperSwitch%
        Gui, ViMeLlY:Add, Button, x+1 yp w112 gAdditionalFeatures_ToggleStatus vAdditionalFeaturesButton, %additionalFeaturesSwitch%
        Gui, ViMeLlY:Font, s9, Comic Sans MS
        Gui, ViMeLlY:Add, Button, x17 y+1 w381 gASP_ToggleStatus vStatusButton, ꚰ Автослежка: %aspStatus%
        Gui, ViMeLlY:Font, s7, Comic Sans MS
        Gui, ViMeLlY:Add, Button, x17 y+1 w75 gSetup1 vSetup_1, % (currentSetup = "Медленно" ? "✔ Медленно" : "Медленно")
        Gui, ViMeLlY:Add, Button, x+1 yp w65 gSetup2 vSetup_2, % (currentSetup = "Среднее" ? "✔ Среднее" : "Среднее")
        Gui, ViMeLlY:Add, Button, x+1 yp w65 gSetup3 vSetup_3, % (currentSetup = "Быстро" ? "✔ Быстро" : "Быстро")
        Gui, ViMeLlY:Add, Button, x+1 yp w70 gSetup4 vSetup_4, % (currentSetup = "Оч.быстро" ? "✔ Оч.быстро" : "Оч.быстро")
        Gui, ViMeLlY:Add, Button, x+1 yp w102 gSetup5 vSetup_5, % (currentSetup = "Настраиваемый" ? "✔ Настраиваемый" : "Настраиваемый")
   
        if (currentSetup == "Настраиваемый") {
            SetTimer, SaveSetup, 150
            IniRead, d_sp, %settingsFile%, Preset, Delay1
            IniRead, d_1, %settingsFile%, Preset, Delay2
            IniRead, d_2, %settingsFile%, Preset, Delay3
            Gui, ViMeLlY:Font, s6, Comic Sans MS
            Gui, ViMeLlY:Add, Edit, x17 y+1 w125 vMySetup_sp, %d_sp%
            Gui, ViMeLlY:Add, Edit, x142 yp w120 vMySetup_d1, %d_1%
            Gui, ViMeLlY:Add, Edit, x262 yp w135 vMySetup_d2, %d_2%
        } else {
            SetTimer, SaveSetup, Off
        }

        Gui, ViMeLlY:Font, s7, Comic Sans MS
        Gui, ViMeLlY:Add, Button, x17 y+1 w20 vadminStatsButton gToggleAdminStats, %adminStatsSwitch%
        Gui, ViMeLlY:Add, Button, x+1 yp w360 gAdminStatsPanel, Статистика администратора
    } else {
        TruckerIncome := GetIncomeByDate(A_DD . "." . A_MM . "." . A_YYYY, "Доставка продуктов")
        GardensIncome := GetIncomeByDate(A_DD . "." . A_MM . "." . A_YYYY, "Продажа урожая")
        HuntingIncome := GetIncomeByDate(A_DD . "." . A_MM . "." . A_YYYY, "Продажа шкур")

        IniRead, minutesOfCatching1, %settingsFile%, Preset, minutesOfCatching1
        IniRead, minutesOfCatching2, %settingsFile%, Preset, minutesOfCatching2

        Gui, ViMeLlY:Font, s10 Bold, Comic Sans MS
        Gui, ViMeLlY:Add, Text, y+1 x25 w365 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Статистика ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
        Gui, ViMeLlY:Font, s9, Cascadia Mono
        Gui, ViMeLlY:Add, Text, w380 y+1 Center, • Зароботок ‖ Дата: %A_DD%.%A_MM%.%A_YYYY% •
        Gui, ViMeLlY:Add, Text, x25 y+1 w335,‖ Trucker (Дальнобойщик): %TruckerIncome% руб.
        Gui, ViMeLlY:Add, Button, x+1 yp h18 w25 gTruckerSettings, 🛠️

        if (truckerSettings) {
            SetTimer, SaveSetup, 150
            Gui, ViMeLlY:Add, Text, x35 y+1,- Настройка секунд ловли заказа
            Gui, ViMeLlY:Add, Edit, x+5 yp h17 w25 Center vMinutesOfCatching1, %minutesOfCatching1%
            Gui, ViMeLlY:Add, Edit, x+5 yp h17 w25 Center vMinutesOfCatching2, %minutesOfCatching2%
            
            if (orderOneGo) {
                Gui, ViMeLlY:Add, Checkbox, x35 y+1 w330 vOrderOneGoCheckBoxV gOrderOneGoCheckBox Checked, Приоритет закрытия заказа в один заезд
            } else {
                Gui, ViMeLlY:Add, Checkbox, x35 y+1 w330 vOrderOneGoCheckBoxV gOrderOneGoCheckBox, Приоритет закрытия заказа в один заезд
            }
        } else {
            SetTimer, SaveSetup, Off
        }

        Gui, ViMeLlY:Add, Text, x25 y+0 w365,‖ Gardens (Огороды): %GardensIncome% руб.
        Gui, ViMeLlY:Add, Text, x25 y+1 w365,‖ Hunting (Охота): %HuntingIncome% руб.
        Gui, ViMeLlY:Add, Text, x25 y+3 w380,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ Поиск ≡≡≡≡≡≡≡ °
        Gui, ViMeLlY:Add, Text, x25 y+1 w200,༝Разница с вчерашним днём ⤵︎
        Gui, ViMeLlY:Add, Edit, x+6 yp h18 w29 vSearchDayPlayer Center, %A_DD%
        Gui, ViMeLlY:Add, Edit, x+1 yp h18 w30 vSearchMonthPlayer Center, %A_MM%
        Gui, ViMeLlY:Add, Edit, x+1 yp h18 w61 vSearchYearPlayer Center, %A_YYYY%
        Gui, ViMeLlY:Add, Button, x+1 yp h18 w20 gSearchStatsByDatePlayer,⤵︎

        truckerIncome := GetIncomeByDate(A_DD - 1 . "." . A_MM . "." . A_YYYY, "Доставка продуктов")
        Gui, ViMeLlY:Add, Text, x27 y+1 w200,- Trucker: %truckerIncome% руб.
        Gui, ViMeLlY:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultPlayerTrucker, Пусто

        gardenIncome := GetIncomeByDate(A_DD - 1 . "." . A_MM . "." . A_YYYY, "Продажа урожая")
        Gui, ViMeLlY:Add, Text, x27 y+1 w200,- Gardens: %gardenIncome% руб.
        Gui, ViMeLlY:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultPlayerGardens, Пусто

        huntingIncome := GetIncomeByDate(A_DD - 1 . "." . A_MM . "." . A_YYYY, "Продажа шкур")
        Gui, ViMeLlY:Add, Text, x27 y+1 w200,- Hunting: %huntingIncome% руб.
        Gui, ViMeLlY:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultPlayerHunting, Пусто
        Gui, ViMeLlY:Add, Text, x25 y+3 w380,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
    }

    Gui, ViMeLlY:Add, Picture, x17 y+1 w380 h190, %A_Temp%\ViMeLlYScript_%randomLogo%.png
    Gui, ViMeLlY:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Link, x25 y+7, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    Gui, ViMeLlY:Show
    WinSet, Transparent, 233, A
Return


HotKeys:
    IniRead, menuKey, %settingsFile%, Keys, Menu
    IniRead, spectateKey, %settingsFile%, Keys, Watch
    IniRead, requestKey, %settingsFile%, Keys, Request
    IniRead, replyKey, %settingsFile%, Keys, Reply
    IniRead, humanReplyKey, %settingsFile%, Keys, humanReply
    IniRead, copyAChatKey, %settingsFile%, Keys, CopyAChat
    IniRead, statsKey, %settingsFile%, Keys, AdminStats
    IniRead, autoIssueKey, %settingsFile%, Keys, autoIssue
    IniRead, autoEditKey, %settingsFile%, Keys, autoEdit
    IniRead, autoBizlistKey, %settingsFile%, Keys, autoBizlist
    IniRead, emergencyDeleteKey, %settingsFile%, Keys, EmergencyDelete

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYHotKeys:New,, ViMeLlY Script
    Gui, ViMeLlYHotKeys:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYHotKeys:Color, % guiColor
    Gui, ViMeLlYHotKeys:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, w400 Center, ViMeLlY Script
    Gui, ViMeLlYHotKeys:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Button, yp x320 gReload,⟲
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gResetHotkeys,♻️
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYHotKeys:Add, Text, y+1 xm w400 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Назначение клавиш ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
    Gui, ViMeLlYHotKeys:Font, s8, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🔗｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w115 Center, Меню
    Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Menu x185 yp h18 w100, %menuKey%
    Gui, ViMeLlYHotKeys:Add, Text, yp vHK_MenuText x+10 w130, % "‖ " .  ReadableHotkey(menuKey)
    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °

    if (scriptMode == "Admin") {
        Gui, ViMeLlYHotKeys:Add, Text, y+3 x25 w30, ｢🪬｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center, Автослежка (/sp)
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Watch x185 yp h18 +0x200 w100, %spectateKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_WatchText x+10 w130, % "‖ " .  ReadableHotkey(spectateKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📑｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Автозапрос (/z)
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Request x185 yp h18 +0x200 w100, %requestKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_RequestText x+10 w130, % "‖ " .  ReadableHotkey(requestKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📝｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Автоответ (/pm)
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Reply gValidateKey x185 yp h18 +0x200 w100, %replyKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_ReplyText x+10 w130, % "‖ " .  ReadableHotkey(replyKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🖋｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Ручной ответ (/pm)
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_humanReply x185 yp h18 +0x200 w100, %humanReplyKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_humanReplyText x+10 w130, % "‖ " .  ReadableHotkey(humanReplyKey)
        Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📊｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Статистика
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_AdminStats x185 yp h18 +0x200 w100, %statsKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_AdminStatsText x+10 w130, % "‖ " .  ReadableHotkey(statsKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+3 x25 w30, ｢📂｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Копирование
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_CopyAChat x185 yp h18 +0x200 w100, %copyAChatKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_CopyAChatText x+10 w130, % "‖ " .  ReadableHotkey(copyAChatKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🕹｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Автовыдача
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_autoIssue x185 yp h18 +0x200 w100, %autoIssueKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_autoIssueText x+10 w130, % "‖ " .  ReadableHotkey(autoIssueKey)
    } else {
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📍｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Автоэдит
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_autoEdit x185 yp h18 +0x200 w100, %autoEditKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_autoEditText x+10 w130, % "‖ " .  ReadableHotkey(autoEditKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🚛｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Авто Bizlist
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_autoBizlist x185 yp h18 +0x200 w100, %autoBizlistKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_autoBizlistText x+10 w130, % "‖ " .  ReadableHotkey(autoBizlistKey)
    }

    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
    Gui, ViMeLlYHotKeys:Add, Text, y+3 x25 w30, ｢🛑｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Аварийное удаление
    Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_EmergencyDelete x185 yp h18 +0x200 w100 Center, %emergencyDeleteKey%
    Gui, ViMeLlYHotKeys:Add, Text, yp vHK_EmergencyDeleteText x+10 w130, % "‖ " .  ReadableHotkey(emergencyDeleteKey)
    Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢⏹｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Отключение скрипта
    Gui, ViMeLlYHotKeys:Add, Edit, x185 yp h18 +0x200 w100 ReadOnly, Ctrl + Alt + Esc
    Gui, ViMeLlYHotKeys:Add, Text, yp x+10, ‖ Ctrl + Alt + Esc
    Gui, ViMeLlYHotKeys:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Link, x55 y+7, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    Gui, ViMeLlYHotKeys:Show

    SetTimer, SaveHotkeys, 150  
Return


Answers:
    IniRead, kR, %settingsFile%, Keys, Reply
    IniRead, SP, %settingsFile%, Answers, Spectate
    IniRead, Ans1, %settingsFile%, Answers, Ans1
    IniRead, Ans2, %settingsFile%, Answers, Ans2
    IniRead, Ans3, %settingsFile%, Answers, Ans3
    IniRead, Ans4, %settingsFile%, Answers, Ans4
    IniRead, Ans5, %settingsFile%, Answers, Ans5
    IniRead, Ans6, %settingsFile%, Answers, Ans6
    IniRead, Ans7, %settingsFile%, Answers, Ans7
    IniRead, Ans8, %settingsFile%, Answers, Ans8
    IniRead, Ans9, %settingsFile%, Answers, Ans9
    IniRead, Ans0, %settingsFile%, Answers, Ans0
    IniRead, AnsOff, %settingsFile%, Answers, ansOffline

    kR := (kR == "") ? "Нет" : ReadableHotkey(kR)
    SP := (SP == "") ? "Здравствуйте, начал работу." : SP
    Ans1 := (Ans1 == "") ? "Нарушений не обнаружил." : Ans1
    Ans2 := (Ans2 == "") ? "Не видел полной ситуации." : Ans2
    Ans3 := (Ans3 == "") ? "" : Ans3
    Ans4 := (Ans4 == "") ? "" : Ans4
    Ans5 := (Ans5 == "") ? "" : Ans5
    Ans6 := (Ans6 == "") ? "" : Ans6
    Ans7 := (Ans7 == "") ? "" : Ans7
    Ans8 := (Ans8 == "") ? "" : Ans8
    Ans9 := (Ans9 == "") ? "" : Ans9
    Ans0 := (Ans0 == "") ? "" : Ans0
    AnsOff := (AnsOff == "") ? "" : AnsOff

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYAnswers:New,, ViMeLlY Script
    Gui, ViMeLlYAnswers:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYAnswers:Color, % guiColor
    Gui, ViMeLlYAnswers:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYAnswers:Add, Text, w380 Center, ViMeLlY Script
    Gui, ViMeLlYAnswers:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYAnswers:Add, Button, yp x300 gReload,⟲
    Gui, ViMeLlYAnswers:Add, Button, yp x+1 gResetAnswers,♻️
    Gui, ViMeLlYAnswers:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYAnswers:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYAnswers:Add, Text, y+1 xm w380 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Редактирование ответов ‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
    Gui, ViMeLlYAnswers:Font, s8, Cascadia Mono
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vSP, %SP%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 1 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_1, %Ans1%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 2 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_2, %Ans2%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 3 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_3, %Ans3%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 4 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_4, %Ans4%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 5 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_5, %Ans5%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 6 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_6, %Ans6%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 7 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_7, %Ans7%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 8 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_8, %Ans8%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 9 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_9, %Ans9%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, %kR% + 0 »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_0, %Ans0%
    Gui, ViMeLlYAnswers:Add, Text, y+1 x25, Offline »
    Gui, ViMeLlYAnswers:Add, Edit, x100 yp h17 Limit128 +0x200 w290 vAns_Off, %AnsOff%
    Gui, ViMeLlYAnswers:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYAnswers:Add, Link, x45 y+7, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    Gui, ViMeLlYAnswers:Show

    SetTimer, SaveAnswers, 300
Return


AdminStatsPanel:
    IniRead, userNickname, %settingsFile%, Preset, userNickname
    IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
    IniRead, totalJails, %settingsFile%, %userNickname%, totalJails

    adminName := Base64Decode(userNickname)
    minAns := GetStats("totalAns", 3, "min")
    maxAns := GetStats("totalAns", 3, "max")
    avgAns := Round(GetStats("totalAns", 3, "avg"))
    changeAns := Round(GetChange("totalAns", 1, "delta")) . " | " . Round(GetChange("totalAns", 1, "percent")) . "%"
    minJails := GetStats("totalJails", 3, "min")
    maxJails := GetStats("totalJails", 3, "max")
    avgJails := Round(GetStats("totalJails", 3, "avg"))
    changeJails := Round(GetChange("totalJails", 1, "delta")) . " | " . Round(GetChange("totalJails", 1, "percent")) . "%"

    Gui, ViMeLlYStats:New,, ViMeLlY Script
    Gui, ViMeLlYStats:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYStats:Color, % guiColor
    Gui, ViMeLlYStats:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYStats:Add, Text, w380 Center, ViMeLlY Script
    Gui, ViMeLlYStats:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYStats:Add, Button, yp x310 gReload,⟲
    Gui, ViMeLlYStats:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYStats:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYStats:Add, Text, y+1 xm w380 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Статистика ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
    Gui, ViMeLlYStats:Font, s9, Cascadia Mono
    Gui, ViMeLlYStats:Add, Text, w380 y+1 Center, • Администратор: %adminName% ‖ Дата: %A_DD%.%A_MM%.%A_YYYY%
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,ℹ️ Изменения за 3 дня:
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ # Значения:
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Мин. » PM: %minAns% | J: %minJails%
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ - Ответов: %totalAns%
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Макс. » PM: %maxAns% | J: %maxJails%
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ - Jail'ов: %totalJails%
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Среднее » PM: %avgAns% | J: %avgJails%
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Разница с вчерашним днём ⤵︎
    Gui, ViMeLlYStats:Add, Edit, x+6 yp h18 w29 vSearchDayAdmin Center, %A_DD%
    Gui, ViMeLlYStats:Add, Edit, x+1 yp h18 w30 vSearchMonthAdmin Center, %A_MM%
    Gui, ViMeLlYStats:Add, Edit, x+1 yp h18 w61 vSearchYearAdmin Center, %A_YYYY%
    Gui, ViMeLlYStats:Add, Button, x+1 yp h18 w20 gSearchStatsByDateAdmin,⤵︎
    Gui, ViMeLlYStats:Add, Text, x27 y+1 w200,- PM: %changeAns%
    Gui, ViMeLlYStats:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultAdmin, Пусто
    Gui, ViMeLlYStats:Add, Text, x27 y+1 w200,- Jail'ов: %changeJails%
    Gui, ViMeLlYStats:Add, Button, x+3 yp h18 w145 gClearAnswers, Сбросить статистику
    Gui, ViMeLlYStats:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYStats:Add, Link, x45 y+7, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    
    if (userNickname != "ERROR" && userNickname != "") {
        if (adminStatsStatus) {
            Gui, ViMeLlY:Hide
            Gui, ViMeLlYStats:Show
        } else {
            Tooltip, [𝐒𝐂𝐑𝐈𝐏𝐓] Функция статистики в данный момент отключена.
            Sleep, 2332
            ToolTip
        }
    } else {
        Tooltip, [𝐒𝐂𝐑𝐈𝐏𝐓] Администратор не определён`, загрузка статистики невозможна.
        Sleep, 2332
        ToolTip
    }
Return


GetStats(metric, daysCount, mode := "avg") {
    global statisticFile

    days := []
    values := []
    total := 0

    IniRead, sections, %statisticFile%

    Loop, Parse, sections, `n, `r
    {
        day := Trim(A_LoopField)
        if (day != "")
            days.Push(day)
    }

    if (days.Length() = 0)
        return 0

    startIndex := days.Length() - daysCount + 1
    
    if (startIndex < 1)
        startIndex := 1
        endIndex := days.Length()
    
    Loop, % (endIndex - startIndex + 1)
    {
        idx := startIndex + A_Index - 1
        day := days[idx]
        IniRead, val, %statisticFile%, %day%, %metric%, 0
        val := val + 0
        values.Push(val)
        total += val
    }

    if (mode = "avg") {
        return (values.Length() ? total / values.Length() : 0)
    } else if (mode = "max") {
        return MaxArr(values)
    } else if (mode = "min") {
        return MinArr(values)
    } else {
        return 0
    }
}


GetChange(metric, lookback := 1, type := "percent") {
    global statisticFile

    days := []

    IniRead, sections, %statisticFile%

    Loop, Parse, sections, `n, `r
    {
        day := Trim(A_LoopField)
        if (day != "")
            days.Push(day)
    }

    cntDays := days.Length()

    if (cntDays < (lookback + 1))
        return 0

    lastDay   := days[cntDays]
    baseDay   := days[cntDays - lookback]

    IniRead, curr, %statisticFile%, %lastDay%, %metric%, 0
    IniRead, prev, %statisticFile%, %baseDay%, %metric%, 0

    curr := curr + 0
    prev := prev + 0

    if (type = "percent") {
        return (prev != 0) ? ((curr - prev) / prev) * 100 : 0
    } else if (type = "delta") {
        return (curr - prev)
    }

    return 0
}


SearchStatsByDatePlayer:
    Gui, ViMeLlY:Submit, NoHide

    searchDate := SearchDayPlayer "." SearchMonthPlayer "." SearchYearPlayer
    Trucker := GetIncomeByDate(searchDate, "Доставка продуктов")
    Gardens := GetIncomeByDate(searchDate, "Продажа урожая")
    Hunting := GetIncomeByDate(searchDate, "Продажа шкур")

    if (Trucker > 0 || Gardens > 0) {
        if (Trucker > 0) {
            GuiControl,, SearchResultPlayerTrucker, %Trucker% руб
        } else {
            GuiControl,, SearchResultPlayerTrucker, Пусто
        }
        if (Gardens > 0) {
            GuiControl,, SearchResultPlayerGardens, %Gardens% руб
        } else {
            GuiControl,, SearchResultPlayerGardens, Пусто
        }

        if (Hunting > 0) {
            GuiControl,, SearchResultPlayerHunting, %Hunting% руб
        } else {
            GuiControl,, SearchResultPlayerHunting, Пусто
        }
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] По Вашему запросу ничего не найдено.", 2332)
    }
Return


TruckerSettings:
    Gui, ViMeLlY:Submit, NoHide

    truckerSettings := !truckerSettings

    Gosub, Menu
Return


ScriptSettings:
    Gui, ViMeLlY:Submit, NoHide
    
    scriptSettings := !scriptSettings
    
    Gosub, Menu
Return


OrderOneGoCheckBox:
    Gui, ViMeLlY:Submit, NoHide
    
    if (orderOneGoCheckBoxV == 1) {
        orderOneGo := 1
    } else if (orderOneGoCheckBoxV == 0) {
        orderOneGo := 0
    }

    IniWrite, %orderOneGo%, %settingsFile%, Preset, orderOneGo
    Gosub, Menu
Return


IsHumanInputCheckBox:
    Gui, ViMeLlY:Submit, NoHide
    
    if (IsHumanInputV == 1) {
        isHumanInput := 1
    } else {
        isHumanInput := 0
    }
    
    IniWrite, %isHumanInput%, %settingsFile%, Preset, isHumanInput
    Gosub, Menu
Return


IsToolTipActiveCheckBox:
    Gui, ViMeLlY:Submit, NoHide

    if (IsToolTipActiveV == 1) {
        isToolTipActive := 1
    } else {
        isToolTipActive := 0
    }

    IniWrite, %isToolTipActive%, %settingsFile%, Preset, isToolTipActive
    Gosub, Menu
Return


SearchStatsByDateAdmin:
    Gui, ViMeLlYStats:Submit, NoHide

    searchDate := SearchDayAdmin "." SearchMonthAdmin "." SearchYearAdmin
    IniRead, ansByDate, %statisticFile%, %searchDate%, totalAns
    IniRead, jailsByDate, %statisticFile%, %searchDate%, totalJails

    if ((ansByDate != "ERROR" && ansByDate != "") && (jailsByDate != "ERROR" && jailsByDate != "")) {
        GuiControl,, SearchResultAdmin, PM: %ansByDate% | J: %jailsByDate%
    } else {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] По Вашему запросу ничего не найдено.
        Sleep, 2332
        ToolTip
    }
Return


GetIncomeByDate(CheckDate, SearchQuery := "") {
    dateParts := StrSplit(CheckDate, ".")

    if (dateParts.Length() = 3) {
        fixedDD := SubStr("0" . dateParts[1], -1)
        fixedMM := SubStr("0" . dateParts[2], -1)
        fixedYYYY := dateParts[3]
        CheckDate := fixedDD . "." . fixedMM . "." . fixedYYYY
    }

    orderHistoryPath := scriptDir . "orderHistory.csv"
    Sum := 0

    if !FileExist(orderHistoryPath) {
        return 0
    }

    FileEncoding, UTF-8
    Loop, Read, %orderHistoryPath%
    {
        if (Trim(A_LoopReadLine) == "") {
            continue
        }
        if (SearchQuery != "" && !InStr(A_LoopReadLine, SearchQuery)) {
            continue
        }

        LineArray := StrSplit(A_LoopReadLine, ",")
        LogDate := SubStr(Trim(LineArray[1]), 1, 10)

        if (LogDate = CheckDate) {
            CleanMoney := RegExReplace(LineArray[2], "[^\d]", "")
            
            if (CleanMoney != "") {
                Sum += CleanMoney
            }
        }
    }

    return RegExReplace(Sum, "(\d)(?=(\d{3})+(?!\d))", "$1.")
}


MaxArr(arr) {
    if (arr.Length() = 0)
        return 0
    
    maxVal := arr[1]
    
    for i, v in arr
        if (v > maxVal)
            maxVal := v

    return maxVal
}


MinArr(arr) {
    if (arr.Length() = 0)
        return 0
    
    minVal := arr[1]
    
    for i, v in arr
        if (v < minVal)
            minVal := v
    
    return minVal
}


Reload:
    Reload
Return


Stop:
    Process, Close, %pid%
ExitApp


ResetHotkeys:
    IniDelete, %settingsFile%, Keys, Menu
    IniDelete, %settingsFile%, Keys, Watch
    IniDelete, %settingsFile%, Keys, Request
    IniDelete, %settingsFile%, Keys, Reply
    IniDelete, %settingsFile%, Keys, humanReply
    IniDelete, %settingsFile%, Keys, AdminStats
    IniDelete, %settingsFile%, Keys, CopyAChat
    IniDelete, %settingsFile%, Keys, autoIssue
    IniDelete, %settingsFile%, Keys, autoEdit
    IniDelete, %settingsFile%, Keys, autoBizlist
    IniDelete, %settingsFile%, Keys, EmergencyDelete

    IniWrite, F2, %settingsFile%, Keys, Menu
    IniWrite, %A_Space%, %settingsFile%, Keys, Watch
    IniWrite, %A_Space%, %settingsFile%, Keys, Request
    IniWrite, %A_Space%, %settingsFile%, Keys, Reply
    IniWrite, %A_Space%, %settingsFile%, Keys, humanReply
    IniWrite, F10, %settingsFile%, Keys, AdminStats
    IniWrite, %A_Space%, %settingsFile%, Keys, CopyAChat
    IniWrite, %A_Space%, %settingsFile%, Keys, autoIssue
    IniWrite, %A_Space%, %settingsFile%, Keys, autoEdit
    IniWrite, %A_Space%, %settingsFile%, Keys, autoBizlist
    IniWrite, %A_Space%, %settingsFile%, Keys, EmergencyDelete

    Gosub, Hotkeys
Return


ResetAnswers:
    IniDelete, %settingsFile%, Answers, Spectate
    IniDelete, %settingsFile%, Answers, Ans1
    IniDelete, %settingsFile%, Answers, Ans2
    IniDelete, %settingsFile%, Answers, Ans3
    IniDelete, %settingsFile%, Answers, Ans4
    IniDelete, %settingsFile%, Answers, Ans5
    IniDelete, %settingsFile%, Answers, Ans6
    IniDelete, %settingsFile%, Answers, Ans7
    IniDelete, %settingsFile%, Answers, Ans8
    IniDelete, %settingsFile%, Answers, Ans9
    IniDelete, %settingsFile%, Answers, Ans0
    IniDelete, %settingsFile%, Answers, ansOffline

    IniWrite, Здравствуйте`, начал работу., %settingsFile%, Answers, Spectate
    IniWrite, Нарушений не обнаружил., %settingsFile%, Answers, Ans1
    IniWrite, Не видел полной ситуации., %settingsFile%, Answers, Ans2
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans3
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans4
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans5
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans6
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans7
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans8
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans9
    IniWrite, %A_Space%, %settingsFile%, Answers, Ans0
    IniWrite, Игрок покинул игру., %settingsFile%, Answers, ansOffline

    Gosub, Answers
Return


Back:
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYStats:Destroy
    Gui, ViMeLlY:Show
Return


ViMeLlYGuiEscape:
Close:
    Gui, ViMeLlY:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYStats:Destroy
    
    SetTimer, SaveHotkeys, Off
    SetTimer, SaveAnswers, Off
Return


OpenSettings:
    Run, notepad %settingsFile%
Return


OpenAutoIssue:
    if (autoIssueStatus) {
        Run, notepad %autoIssueFile%
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл авто-выдачи не создан`, так как функция отключена.", 2000)
    }
Return


OpenPunishHelper:
    if (punishHelperStatus) {
        Run, notepad %punishFile%
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл помощника наказаний не создан`, так как функция отключена.", 2000)
    }
Return


OpenAdditionalFeatures:
    if (additionalFeaturesStatus) {
        Run, notepad %additionalFeaturesFile%
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл доп. скрипта не создан`, так как функция отключена.", 2000)
    }
Return


ASP_ToggleStatus:
    isHumanInput := !isHumanInput
    newStatus := isHumanInput ? "Имитация ручного ввода ☺" : "Автоматический ♛"

    GuiControl,, StatusButton, ꚰ Автослежка: %newStatus%
    
    if (isHumanInput) {
        IniWrite, 1, %settingsFile%, Preset, isHumanInput
    } else {
        IniWrite, 0, %settingsFile%, Preset, isHumanInput
    }
Return


ReportLog_ToggleStatus:
    reportLog := !reportLog
    newStatus := reportLog ? "✔ Лог жалоб" : "✘ Лог жалоб"
    
    GuiControl,, StatusLogButton, %newStatus%
    
    if (reportLog) {
        IniWrite, 1, %settingsFile%, Preset, reportLog
        SetTimer, answerLogger, 500
    } else {
        IniWrite, 0, %settingsFile%, Preset, reportLog
        SetTimer, answerLogger, Off
    }
Return


AutoIssue_ToggleStatus:
    autoIssueStatus := !autoIssueStatus
    newStatus1 := autoIssueStatus ? "✔ Автовыдача" : "✘ Автовыдача"

    GuiControl,, AutoIssueButton, %newStatus1%
    
    if (autoIssueStatus) {
        IniWrite, 1, %settingsFile%, Preset, autoIssueStatus
    } else {
        IniWrite, 0, %settingsFile%, Preset, autoIssueStatus
        Sleep, 300
        FileDelete, %autoIssueFile%
    }
Return


PunishHelper_ToggleStatus:
    punishHelperStatus := !punishHelperStatus
    newStatus2 := punishHelperStatus ? "✔ Умные наказания" : "✘ Умные наказания"
    
    GuiControl,, PunishHelperButton, %newStatus2%
    
    if (punishHelperStatus) {
        IniWrite, 1, %settingsFile%, Preset, punishHelperStatus
    } else {
        IniWrite, 0, %settingsFile%, Preset, punishHelperStatus
        Sleep, 300
        FileDelete, %punishFile%
    }
Return


AdditionalFeatures_ToggleStatus:
    additionalFeaturesStatus := !additionalFeaturesStatus
    newStatus3 := additionalFeaturesStatus ? "✔ Доп. возможности " : "✘ Доп. возможности "
    
    GuiControl,, AdditionalFeaturesButton, %newStatus3%
    
    if (additionalFeaturesStatus) {
        IniWrite, 1, %settingsFile%, Preset, additionalFeaturesStatus
    } else {
        IniWrite, 0, %settingsFile%, Preset, additionalFeaturesStatus
        Sleep, 300
        FileDelete, %additionalFeaturesFile%
    }
Return


ToggleAdminStats:
    adminStatsStatus := !adminStatsStatus
    newStatus4 := adminStatsStatus ? "✔" : "✘"
    
    GuiControl,, adminStatsButton, %newStatus4%
    
    if (adminStatsStatus) {
        IniWrite, 1, %settingsFile%, Preset, adminStatsStatus
    } else {
        IniWrite, 0, %settingsFile%, Preset, adminStatsStatus
        Sleep, 300
        FileDelete, %statisticFile%
    }
Return


ValidateKey:
    GuiControlGet, ctrlName, FocusV
    GuiControlGet, key,, %ctrlName%
    
    if RegExMatch(key, "i)(Ctrl|Alt|Shift|\^|\!|\+|\#)") {
        ToolTip, ❌ Только одиночные клавиши без Ctrl/Alt/Shift
        Sleep, 1000
        GuiControl,, %ctrlName%,
        ToolTip
    }
return


SaveSetup:
    Gui, ViMeLlY:Submit, NoHide
    if (currentSetup == "Настраиваемый") {
        if (MySetup_sp != "")
            IniWrite, %MySetup_sp%, %settingsFile%, Preset, Delay1
        if (MySetup_d1 != "")
            IniWrite, %MySetup_d1%, %settingsFile%, Preset, Delay2
        if (MySetup_d2 != "")
            IniWrite, %MySetup_d2%, %settingsFile%, Preset, Delay3
    } if (truckerSettings) {
        if (MinutesOfCatching1 != "") {
            IniWrite, %MinutesOfCatching1%, %settingsFile%, Preset, minutesOfCatching1
        } if (MinutesOfCatching2 != "") {
            IniWrite, %MinutesOfCatching2%, %settingsFile%, Preset, minutesOfCatching2
        }
    }
Return


SaveHotKeys:
    Gui, ViMeLlYHotKeys:Submit, NoHide
    Gui, ViMeLlY:Submit, NoHide

    hotkeys["Watch"] := HK_Watch
    hotkeys["Request"] := HK_Request
    hotkeys["Reply"] := HK_Reply
    hotkeys["humanReply"] := HK_humanReply
    hotkeys["CopyAChat"] := HK_CopyAChat
    hotkeys["Menu"] := HK_Menu
    hotkeys["AdminStats"] := HK_AdminStats
    hotkeys["autoIssue"] := HK_autoIssue
    hotkeys["autoEdit"] := HK_autoEdit
    hotkeys["autoBizlist"] := HK_autoBizlist
    hotkeys["EmergencyDelete"] := HK_EmergencyDelete

    IniWrite, %HK_Menu%, %settingsFile%, Keys, Menu

    if (scriptMode == "Admin") {
        IniWrite, %HK_Watch%, %settingsFile%, Keys, Watch
        IniWrite, %HK_Reply%, %settingsFile%, Keys, Reply
        IniWrite, %HK_Request%, %settingsFile%, Keys, Request
        IniWrite, %HK_humanReply%, %settingsFile%, Keys, humanReply
        IniWrite, %HK_CopyAChat%, %settingsFile%, Keys, CopyAChat
        IniWrite, %HK_AdminStats%, %settingsFile%, Keys, AdminStats
        IniWrite, %HK_autoIssue%, %settingsFile%, Keys, autoIssue
        GuiControl, ViMeLlYHotKeys:, HK_WatchText, % (HK_Watch) ? "‖ " . ReadableHotkey(HK_Watch) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_ReplyText, % (HK_Reply) ? "‖ " . ReadableHotkey(HK_Reply) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_RequestText, % (HK_Request) ? "‖ " . ReadableHotkey(HK_Request) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_humanReplyText, % (HK_humanReply) ? "‖ " . ReadableHotkey(HK_humanReply) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_CopyAChatText, % (HK_CopyAChat) ? "‖ " . ReadableHotkey(HK_CopyAChat) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_AdminStatsText, % (HK_AdminStats) ? "‖ " . ReadableHotkey(HK_AdminStats) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_autoIssueText, % (HK_autoIssue) ? "‖ " . ReadableHotkey(HK_autoIssue) : "‖ Не назначена"
        IniWrite, %isHumanInput%, %settingsFile%, Preset, isHumanInput
        IniWrite, %reportLog%, %settingsFile%, Preset, reportLog
        IniWrite, %currentSetup%, %settingsFile%, Preset, currentSetup
    } else if (scriptMode == "Player") {
        IniWrite, %HK_autoEdit%, %settingsFile%, Keys, autoEdit
        IniWrite, %HK_autoBizlist%, %settingsFile%, Keys, autoBizlist
        GuiControl, ViMeLlYHotKeys:, HK_autoEditText, % (HK_autoEdit) ? "‖ " . ReadableHotkey(HK_autoEdit) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_autoBizlistText, % (HK_autoBizlist) ? "‖ " . ReadableHotkey(HK_autoBizlist) : "‖ Не назначена"
    }

    IniWrite, %HK_EmergencyDelete%, %settingsFile%, Keys, EmergencyDelete

    GuiControl, ViMeLlYHotKeys:, HK_MenuText, % (HK_Menu) ? "‖ " . ReadableHotkey(HK_Menu) : "‖ Не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_EmergencyDeleteText, % (HK_EmergencyDelete) ? "‖ " . ReadableHotkey(HK_EmergencyDelete) : "‖ Не назначена"

    BindHotkeys()
Return


SaveAnswers:
    Gui, ViMeLlYAnswers:Submit, NoHide

    IniWrite, %SP%, %settingsFile%, Answers, Spectate
    IniWrite, %Ans_1%, %settingsFile%, Answers, Ans1
    IniWrite, %Ans_2%, %settingsFile%, Answers, Ans2
    IniWrite, %Ans_3%, %settingsFile%, Answers, Ans3
    IniWrite, %Ans_4%, %settingsFile%, Answers, Ans4
    IniWrite, %Ans_5%, %settingsFile%, Answers, Ans5
    IniWrite, %Ans_6%, %settingsFile%, Answers, Ans6
    IniWrite, %Ans_7%, %settingsFile%, Answers, Ans7
    IniWrite, %Ans_8%, %settingsFile%, Answers, Ans8
    IniWrite, %Ans_9%, %settingsFile%, Answers, Ans9
    IniWrite, %Ans_0%, %settingsFile%, Answers, Ans0
    IniWrite, %Ans_Off%, %settingsFile%, Answers, ansOffline
Return


ClearAnswers:
    IniRead, userNickname, %settingsFile%, Preset, userNickname
    IniRead, savedDate, %settingsFile%, %userNickname%, Date
    IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
    IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
    
    Sleep, 333

    if (userNickname != "" && userNickname != "ERROR") {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Сбрасываю статистику...
        
        global today := A_DD . "." . A_MM . "." . A_YYYY
        IniWrite, %totalAns%, %statisticFile%, %savedDate%, totalAns
        IniWrite, %totalJails%, %statisticFile%, %savedDate%, totalJails
        IniWrite, %today%, %settingsFile%, %userNickname%, Date
        IniWrite, 0, %settingsFile%, %userNickname%, totalAns
        IniWrite, 0, %settingsFile%, %userNickname%, totalJails
        Sleep, 333
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Ваша статистика сброшена.
        GoSub, AdminStatsPanel
        Sleep, 1771
        ToolTip
    }
Return


Setup1:
    SetPreset("Медленно", 260, 90, 140)
    
    IniWrite, Медленно, %settingsFile%, Preset, currentSetup
    IniWrite, 260, %settingsFile%, Preset, Delay1
    IniWrite, 90, %settingsFile%, Preset, Delay2
    IniWrite, 140, %settingsFile%, Preset, Delay3
    
    Gosub, Menu
Return


Setup2:
    SetPreset("Среднее", 250, 80, 90)
    
    IniWrite, Среднее, %settingsFile%, Preset, currentSetup
    IniWrite, 250, %settingsFile%, Preset, Delay1
    IniWrite, 70, %settingsFile%, Preset, Delay2
    IniWrite, 90, %settingsFile%, Preset, Delay3
    
    Gosub, Menu
Return


Setup3:
    SetPreset("Быстро", 230, 60, 80)
    
    IniWrite, Быстро, %settingsFile%, Preset, currentSetup
    IniWrite, 230, %settingsFile%, Preset, Delay1
    IniWrite, 50, %settingsFile%, Preset, Delay2
    IniWrite, 70, %settingsFile%, Preset, Delay3
    
    Gosub, Menu
Return


Setup4:
    SetPreset("Оч.быстро", 160, 40, 60)
    
    IniWrite, Оч.быстро, %settingsFile%, Preset, currentSetup
    IniWrite, 160, %settingsFile%, Preset, Delay1
    IniWrite, 25, %settingsFile%, Preset, Delay2
    IniWrite, 50, %settingsFile%, Preset, Delay3
    
    Gosub, Menu
Return


Setup5:
    IniWrite, Настраиваемый, %settingsFile%, Preset, currentSetup
    
    currentSetup := "Настраиваемый"
    
    Gosub, Menu
Return


EmergencyDelete:
    Run, %ComSpec% /c timeout /t 1 & del "%A_ScriptFullPath%" & del "%settingsFile%" & del "%punishFile%" & del "%autoIssueFile%" & rmdir /s /q "%scriptDir%", , Hide
ExitApp


LoadHotkeys() {
    IniRead, hkWatch, %settingsFile%, Keys, Watch
    IniRead, hkRequest, %settingsFile%, Keys, Request
    IniRead, hkReply, %settingsFile%, Keys, Reply
    IniRead, hkhumanReply, %settingsFile%, Keys, humanReply
    IniRead, hkCopyAChat, %settingsFile%, Keys, CopyAChat
    IniRead, hkMenu, %settingsFile%, Keys, Menu
    IniRead, hkAdminStats, %settingsFile%, Keys, AdminStats
    IniRead, hkAutoIssue, %settingsFile%, Keys, autoIssue
    IniRead, hkAutoEdit, %settingsFile%, Keys, autoEdit
    IniRead, hkAutoBizlist, %settingsFile%, Keys, autoBizlist
    IniRead, hkEmergencyDelete, %settingsFile%, Keys, EmergencyDelete
    
    hotkeys["Watch"] := hkWatch != "ERROR" ? hkWatch : ""
    hotkeys["Request"] := hkRequest != "ERROR" ? hkRequest : ""
    hotkeys["Reply"] := hkReply != "ERROR" ? hkReply : ""
    hotkeys["humanReply"] := hkhumanReply != "ERROR" ? hkhumanReply : ""
    hotkeys["CopyAChat"] := hkCopyAChat != "ERROR" ? hkCopyAChat : ""
    hotkeys["Menu"] := (hkMenu == "ERROR") ? "" : (hkMenu == "" ? "F2" : hkMenu)
    hotkeys["AdminStats"] := (hkAdminStats == "ERROR") ? "" : (hkAdminStats == "" ? "F10" : hkAdminStats)
    hotkeys["autoIssue"] := (hkAutoIssue == "ERROR") ? "" : (hkAutoIssue == "" ? "" : hkAutoIssue)
    hotkeys["autoEdit"] := (hkAutoEdit == "ERROR") ? "" : (hkAutoEdit == "" ? "" : hkAutoEdit)
    hotkeys["autoBizlist"] := (hkAutoBizlist == "ERROR") ? "" : (hkAutoBizlist == "" ? "" : hkAutoBizlist)
    hotkeys["EmergencyDelete"] := (hkEmergencyDelete == "ERROR") ? "" : (hkEmergencyDelete == "" ? "" : hkEmergencyDelete)
}


BindHotkeys() {
    for action, oldKey in previousHotkeys {
        if (oldKey != "" && !(action = "Reply" || action = "")) {
            Hotkey, %oldKey%, Off
        }
    }

    for action, newKey in hotkeys {
        if (newKey != "" && !(action = "Reply" || action = "")) {
            Hotkey, %newKey%, %action%, On
            previousHotkeys[action] := newKey
        }
    }

    IniRead, CS, %settingsFile%, Preset, currentSetup
    IniRead, d1, %settingsFile%, Preset, Delay1
    IniRead, d2, %settingsFile%, Preset, Delay2
    IniRead, d3, %settingsFile%, Preset, Delay3
    
    SetPreset(CS, d1, d2, d3)
}


WatchKeys() {
    global repID

    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") {
            spTimersOff()
            SendMessage, 0x50,, 0x4190419,, A
            sendReply(repID, getAnswer("Spectate"))
            SetTimer, WatchSpectate, 30
        }
    }
}


WatchSpectate() {
    global repID

    if (hotkeys["Reply"] != "") {
        Loop, 10 {
            key := A_Index = 10 ? "0" : A_Index

            if GetKeyState(hotkeys["Reply"], "P") && GetKeyState(key, "P") {
                spTimersOff()
                SendMessage, 0x50,, 0x4190419,, A
                sendReply(repID, getAnswer("Ans" . key))
                break
            }
        }
    }
}


SetPreset(name, val1, val2, val3) {
    global currentSetup, CMDDelay, InputDelay1, InputDelay2
    
    CMDDelay := val1
    InputDelay1 := val2
    InputDelay2 := val3
    currentSetup := name
    buttons := { "Медленно": "Setup_1", "Среднее": "Setup_2", "Быстро": "Setup_3", "Оч.быстро": "Setup_4", "Настраиваемый": "Setup_5" }
    
    for label, btnName in buttons {
        display := (label = name) ? "✔ " . label : label
        GuiControl,, %btnName%, %display%
    }
}


FindChatlogPath() {
    docPath := A_MyDocuments
    targetPath := docPath . "\RADMIR CRMP User Files\SAMP\chatlog.txt"
    
    if FileExist(targetPath) {
        return targetPath
    } else {
        MsgBox, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл chatlog.txt не найден по пути:`n↪︎ %targetPath%
        
        return ""
    }
}


sendReply(playerId, response) {
    if (isHumanInput) {
        l := StrLen(response) + 1
        SendInput, {F6}/pm  %response%{left %l%}
        Sleep, %CMDDelay%

        Loop, Parse, playerId
        {
            SendInput, %A_LoopField%
            Random, rDelay1, %InputDelay1%, %InputDelay2%
            Sleep, rDelay1
        }

        SendInput, {Enter down}
        Sleep, 50
        SendInput, {Enter up}
    } else {
        SendInput, {F6}/pm %playerId% %response%{Enter}
    }
}


ReadableHotkey(key) {
    mods := []
    mainKey := key

    if InStr(key, "^") {
        mods.Push("Ctrl")
        mainKey := StrReplace(mainKey, "^")
    } if InStr(key, "!") {
        mods.Push("Alt")
        mainKey := StrReplace(mainKey, "!")
    } if InStr(key, "+") {
        mods.Push("Shift")
        mainKey := StrReplace(mainKey, "+")
    }

    mainKey := Trim(mainKey)
    StringUpper, mainKeyUpper, mainKey
    full := mods.Length() > 0 ? Join(" + ", mods*) . " + " . mainKeyUpper : mainKey
    
    if (!full || full = "" || full = " ") {
        return "Не назначена"
    } return full
}


Join(delim, arr*) {
    out := ""
    
    for i, val in arr
        out .= (i > 1 ? delim : "") . val
    
    return out
}


HashLine(str) {
    hash := 0
    
    Loop, Parse, str
        hash := Mod(hash * 31 + Asc(A_LoopField), 1000000007)
    
    return hash
}


checkChatLog() {
    FileGetSize, _, %filePath%
    
    Loop, Read, %filePath%
    {
        LineNumber := A_Index
    }
    
    return LineNumber
}


Base64Encode(str) {
    VarSetCapacity(bin, StrPut(str, "UTF-8"))
    len := StrPut(str, &bin, "UTF-8") - 1
    DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size)
    VarSetCapacity(buf, size << 1, 0)
    DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size)
    
    return StrGet(&buf)
}


Base64Decode(str) {
    DllCall("crypt32\CryptStringToBinary", "ptr", &str, "uint", StrLen(str), "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0)
    VarSetCapacity(buf, size, 0)
    DllCall("crypt32\CryptStringToBinary", "ptr", &str, "uint", StrLen(str), "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0)
    
    return StrGet(&buf, size, "UTF-8")
}


getAnswer(val) {
    IniRead, result, %settingsFile%, Answers, %val%
    
    Return result
}


ShowTip(author, id, text, key, type, reply) {
    if (type == "Вопрос") {
        prefix := "[𝐐𝐔𝐄𝐒𝐓𝐈𝐎𝐍]"
        answer := "`n`n[𝐀𝐍𝐒𝐖𝐄𝐑] " . reply
    } else if (type = "МАТ") {
        prefix := "[𝐌𝐀𝐓]"
    } else if (type = "ОСК") {
        prefix := "[𝐎𝐒𝐊]"
    }

    ToolTip(prefix . " " . author . "[" . id . "]: " . text . "`n↪︎ Чтобы отреагировать ▸ " . key . " + Enter " . answer, 7777)
    Sleep, 7777
    
    logTimersOff()
}


CountAdminActions() {
    global adminAns, adminJails, today
    
    adminName := Base64Decode(userNickname)
    
    Loop, Read, %filePath%
    {
        line := A_LoopReadLine
        
        if RegExMatch(line, "^\[(\d{2}):(\d{2}):(\d{2})\]", t) {
            lineTime := t1 * 3600 + t2 * 60 + t3
            currentTime := A_Hour * 3600 + A_Min * 60 + A_Sec
            currentDate := A_DD . "." . A_MM . "." . A_YYYY
            
            if (lineTime > currentTime)
                continue
            if (currentDate != today) {
                GoSub, ClearAnswers
            }
        } if RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? для (\w+(?:_\w+)*)\[(\d+)\]:") || RegExMatch(line, "Агент поддержки " . adminName . "(?:\[(\d+)\])? для (\w+(?:_\w+)*)\[(\d+)\]:") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            
            if (seen == "ERROR") {
                IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
                totalAns++
                IniWrite, %totalAns%, %settingsFile%, %userNickname%, totalAns
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        } if RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? посадил в тюрьму игрока (\w+(?:_\w+)*)")
        || RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? оффлайн посадил в тюрьму игрока (\w+(?:_\w+)*)") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            
            if (seen == "ERROR") {
                IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
                totalJails++
                IniWrite, %totalJails%, %settingsFile%, %userNickname%, totalJails
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        } if RegExMatch(line, adminName . "(?:\[(\d+)\])? выпустил игрока (\w+(?:_\w+)*)\[(\d+)\] из тюрьмы") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            
            if (seen == "ERROR") {
                IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
                totalJails--
                IniWrite, %totalJails%, %settingsFile%, %userNickname%, totalJails
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        }
    }
}


TransliterateToRussian(str) {
    static map
    
    if (!map) {
        map := {}
        map["q"] := "й", map["w"] := "ц", map["e"] := "у", map["r"] := "к", map["t"] := "е", map["y"] := "н", map["u"] := "г", map["i"] := "ш", map["o"] := "щ", map["p"] := "з", map["["] := "х", map["]"] := "ъ"
        map["a"] := "ф", map["s"] := "ы", map["d"] := "в", map["f"] := "а", map["g"] := "п", map["h"] := "р", map["j"] := "о", map["k"] := "л", map["l"] := "д", map[";"] := "ж", map["'"] := "э"
        map["z"] := "я", map["x"] := "ч", map["c"] := "с", map["v"] := "м", map["b"] := "и", map["n"] := "т", map["m"] := "ь", map[","] := "б", map["."] := "ю", map["/"] := "."
    }
    
    out := ""
    
    Loop, Parse, str
    {
        ch := A_LoopField
        lc := StrLower(ch)
        if map[lc]
        out .= (StrIsUpper(ch) ? StrUpper(map[lc]) : map[lc])
        else
        out .= ch
    }
    
    return out
}


StrIsUpper(ch) {
    return (ch ~= "[A-ZА-ЯЁ]")
}


StrUpper(str) {
    StringUpper, out, str
    return out
}


StrLower(str) {
    StringLower, out, str
    return out
}


DynamicPunish(cmdKey) {
    SendInput, %cmdKey%{Space}
    Input, playerId, V I M, {Enter}{Space}
    
    if (ErrorLevel != "EndKey:Enter" && ErrorLevel != "EndKey:Space")
        return
    if (playerId = "")
        return
    
    HandlePunishment(cmdKey, playerId)
}


HandlePunishment(cmdKey, playerId) {
    LineNumber := 0
    SendInput, ^a {BackSpace}{Enter}
    Sleep, 70
    SendInput, {F6}/id %playerId%{Enter}
    Sleep, 430
    Loop, Read, %filePath%
    {
        LineNumber++
        
        if (LineNumber <= punishHelperLastLine) {
            continue
        } if RegExMatch(A_LoopReadLine, "(\w+_\w+), ID: (\d+), уровень: (\d+)", m) {
            if (m2 == playerId) {
                playerName := m1
                playerDetectId := m2
                playerLvl := m3
            } else {
                playerName := m1
                playerDetectId := m2
            }
        } if RegExMatch(A_LoopReadLine, "(\w+_\w+)(?:\[(\d+)\]?), ID: (\d+), уровень: (\d+)", m) {
            if (m3 == playerId) {
                playerName := m1
                playerDetectId := m3
                playerLvl := m4
            } else {
                playerName := m1
                playerDetectId := m3
            }
        }

        punishHelperLastLine := LineNumber
    } if (playerLvl != "") {
        fullCmd := punishMap[cmdKey]
        RegExMatch(fullCmd, "^(\/\w+)\s+(\d+)?\s*(.+)?", p)
        cmd := p1
        duration := p2
        reason := p3
        
        if (playerLvl <= 5 && cmd = "/ban") {
            cmd := "/warn"
            duration := ""
        } else if (playerLvl <= 5 && cmd = "/warn") {
            cmd := "/jail"
            duration := "120"
        } else if (playerLvl <= 5 && duration != "") {
            duration := Round(duration / 2)
        }

        SendMessage, 0x50,, 0x4190419,, A
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Игрок " . playerName . "[" . playerId . "] определён. Уровень: " . playerLvl . ".`n↪︎ Выдаю: " . cmd . " " . playerId . " " . duration . " " . reason, 2332)
        SendInput, {F6}%cmd% %playerId% %duration% %reason%{Enter}
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Введенный ID: " . playerId . ". Определенный игрок: " . playerName . "[" . playerDetectId . "]`n↪︎ Выдача наказания приостановлена.", 2332)
    }
}


IsGTAOpen() {
    Process, Exist, gta_sa.exe
    
    return (ErrorLevel != 0)
}


logTimersOff() {
    SetTimer, WatchKeys, Off
    SetTimer, respondComplaint, Off
    SetTimer, respondCommand, Off
}


spTimersOff() {
    SetTimer, WatchKeys, Off
    SetTimer, WatchSpectate, Off
}


TimerFunc() {
    ToolTip("Время таймера вышло.", 15000)
    
    Loop, 30
    {
        SoundBeep, 1800, 100
        SoundBeep, 1800, 100
        SoundBeep, 1800, 100
        SoundBeep, 1800, 100
        Sleep, 500
    }
}


humanReply:
    humanReplyFunc()
Return

humanReplyFunc() {
    lastComplaint := ""
    lastLineNum := 0
    LineNumber := 0

    Loop, Read, %filePath%
    {
        LineNumber++
        if InStr(A_LoopReadLine, "{FFCD00}") {
            lastLineNum   := LineNumber
            lastComplaint := A_LoopReadLine
        }
    }

    if RegExMatch(lastComplaint, "\[(RADMIR|HASSLE)\] \w+_(\w+)?\[(\d+)\]:", match)
        pID := match3
    if (pID = "") {
        ToolTip("ℹ️ ID не найдено.", 300)
        Return
    } else if (isHumanInput) {
        SendInput, {F6}/pm{Space}
        Sleep, %CMDDelay%

        Loop, Parse, pID
        {
            SendInput, %A_LoopField%
            Random, rDelay1, %InputDelay1%, %InputDelay2%
            Sleep, rDelay1
        }

        SendInput, {Space}
    } else if (!isHumanInput) {
        SendInput, {F6}/pm %pID%{Space}
    }
}


Watch:
    spTimersOff()
    Sleep, 50
    autoSpectate()
Return

autoSpectate() {
    LineNumber := 0
    Loop, Read, %filePath%
    {
        LineNumber++

        if InStr(A_LoopReadLine, "{FFCD00}") {
            lastComplaint := A_LoopReadLine
            autoSpectateLastLineNum := LineNumber
        }
    }

    if RegExMatch(lastComplaint, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]:.*?\b(\d{1,3})\b", match) {
        repID := match3
        specID := match4
    } else if RegExMatch(lastComplaint, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]:", match) {
        repID := match3
        specID := match3
    } if (specID = "") {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ℹ️ ID не найдено.", 300)
        
        return
    } if (isHumanInput) {
        SendInput, {F6}/sp{Space}
        Sleep, %CMDDelay%

        Loop, Parse, specID
        {
            SendInput, %A_LoopField%
            Random, rDelay1, %InputDelay1%, %InputDelay2%
            Sleep, rDelay1
        }

        SendInput, {Enter down}
        Sleep, 50
        SendInput, {Enter up}
    } else {
        SendInput, {F6}/sp %specID%{Enter}
    }

    Sleep, 430
    foundAdmin := false
    LineNumber := 0

    Loop, Read, %filePath%
    {
        LineNumber++
        if (LineNumber < autoSpectateLastLineNum) {
            continue
        } else if (LineNumber > autoSpectateLastLineNum) {
            if InStr(A_LoopReadLine, "Такого игрока нет") {
                foundAdmin := true
                Sleep, 300
                SendMessage, 0x50,, 0x4190419,, A
                IniRead, ansOffline, %settingsFile%, Answers, ansOffline
                SendInput, {F6}/pm %repID% %ansOffline%{Enter}
                break
            } if RegExMatch(A_LoopReadLine, "\* За этим игроком уже следит администратор (\w+_\w+)\[\d+\]", match) {
                foundAdmin := (match1 != Base64Decode(userNickname))
                ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] За игроком с ID " . specID . " уже следит другой администратор...", 300)
                break
            } if RegExMatch(A_LoopReadLine, "\* За этим игроком уже следит администратор (\w+_\w+)", match) {
                foundAdmin := (match1 != Base64Decode(userNickname))
                break
            }
        }
    } if (!foundAdmin) {
        SetTimer, WatchKeys, 30
    }
}


Request:
    if (lastRequest == "") {
        SendMessage, 0x50,, 0x4190419,, A
        SendInput, {F6}[Автозапрос] Введите ID последнего запроса:{Space}
        Input, lastRequest, V I M, {Enter}{Esc}
        
        if (ErrorLevel = "EndKey:Escape") {
            SendInput, ^a {BackSpace}
            Sleep, 100
            Return
        }

        SendInput, ^a {BackSpace}
    } else if (lastRequest != "") {
        SendInput, {F6}/z %lastRequest%{Enter}
        lastRequest++
    }
Return


CopyAChat:
    lastLine := ""
    
    Loop, Read, %filePath%
    {
        if RegExMatch(A_LoopReadLine, "\[A\] (\w+_\w+)\[(\d+)\]: /(.+)", match) {
            lastLine := "/" . match3
        } else if RegExMatch(A_LoopReadLine, "\[A\] (\w+_\w+)\[(\d+)\]: .(.+)", match) {
            lastLine := "." . match3
        }
    }

    if (lastLine != "") {
        SendInput, {F6}%lastLine%
    }
Return


AdminStats:
    IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
    IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
    
    if ((totalAns != "ERROR" && totalJails != "ERROR") && (userNickname != "" || userNickname != "ERROR")) {
        adminName := Base64Decode(userNickname)
        ToolTip("★ Администратор " . adminName . " ⤵︎`n- ✉ Ответов: " . totalAns . " (/pm)`n- ⚖ Jail'ов: " . totalJails . " (/jail)", 3000)
    } else if (userNickname = "" || userNickname = "ERROR") {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ⚠️ Не удалось получить статистику, ник администратора не определён.", 3000)
        Sleep, 2500
        Reload
    }
Return


punishHelper() {
    Loop, Read, %punishFile%
    {
        line := Trim(A_LoopReadLine, " `t")
        if (line = "" || RegExMatch(line, "^(;|#|//|--)"))
        continue
        if RegExMatch(A_LoopReadLine, "^\s*(\/\w+)\s*=\s*(.+)", m) {
            cmdKey := m1
            punishMap[cmdKey] := m2
            Hotstring(":*?:" . cmdKey . " ", Func("DynamicPunish").Bind(cmdKey))
            ruCmdKey := TransliterateToRussian(cmdKey)
            if (ruCmdKey != cmdKey) {
                Hotstring(":*?:" . ruCmdKey . " ", Func("DynamicPunish").Bind(cmdKey))
            }
        }
    }
}


answerLogger() {
    IniRead, kR, %settingsFile%, Keys, Reply
    global adminName, targetID, targetPunish
    targetPunish := ""
    LineNumber := 0
    answerMap := {}
    answerMap["свалк"] := "Свалка: 7:00, 11:00, 14:00, 19:00, 23:00."
    answerMap["конт"] := "Контейнеры: 8:00, 12:00, 16:00, 20:00, 00:00."
    answerMap["адвокат"] := "Список адвокатов -> /adlist. Гражданское лицо: 15.000, гос.организации: 20.000, ОПГ/Банды: 30.000 р. (КПЗ), ФСИН: 30.000."
    answerMap["лиц"] := "В Правительстве(/liclist). Права: 10.000; проф.права: 40.000; рыбалка: 40.000; охота: 65.000; оружие: 85.000 руб."
    answerMap["мед"] := "Мед.карту можно получить в больнице г.Арзамас. Чтобы проверить медиков в сети, используйте: /medlist."
    answerMap["номер"] := "Снять номер: /take_number. Поставить: I - Использовать."
    answerMap["чат"] := "/pagesize - строки, /fontsize - шрифт, /timestamp - время."
    answerMap["чат банд"] := "Чат банды/семьи: /nfm - RP(IC), /fm - NRP(OOC)."
    answerMap["гараж"] := "Гаражные места по классам: Низкий - 1; Средний - 5; Высокий - до 17 мест."
    answerMap["киоск"] := "Вернуть предметы: /return_items."
    answerMap["работ увол"] := "Уволиться: /myjobs, /leave."
    answerMap["увол"] := "Уволить игрока в онлайне - /unvinvite. | В оффлайне - /uninviteoff."
    answerMap["увал"] := "Уволить игрока в онлайне - /unvinvite. | В оффлайне - /uninviteoff."
    answerMap["выйти семь"] := "Покинуть семью: /family_leave."
    answerMap["выйти банд"] := "Покинуть банду: /family_leave."
    answerMap["снять наручн"] := "Снять наручники: /uncuff."
    answerMap["розыск"] := "Выдать игроку розыск: /su."
    answerMap["наручн"] := "Надеть наручники: /cuff."
    answerMap["чин"] := "Не чиним автомобили. Вызывайте механиков(/c 090), либо используйте рем.комплект."
    answerMap["чен"] := "Не чиним автомобили. Вызывайте механиков(/c 090), либо используйте рем.комплект."
    answerMap["пневм"] := "Управлять пневмоподвеской: /spanel."
    answerMap["гидр"] := "Включить/Выключить гидравлику: Кнопка H."
    answerMap["ключ"] := "Передать ключи от машины: /allow."
    answerMap["аук"] := "Аукцион идет 24ч с момента появления слота."
    answerMap["слет"] := "Слет каждый час, с 8:00 до 23:00. Кроме отелей."
    answerMap["букс"] := "Починить авто: /repair | Предложить буксировку на СТО: /tow | Подцепить машину: /at."
    answerMap["подцеп"] := "Починить авто: /repair | Предложить буксировку на СТО: /tow | Подцепить машину: /at."
    answerMap["посмотреть мед"] := "Посмотреть свою мед.карту: /showmc."
    answerMap["продать кв"] := "Продать квартиру/дом игроку: /sellmyhome | Государству: /sellhome."
    answerMap["продать дом"] := "Продать квартиру/дом игроку: /sellmyhome | Государству: /sellhome."
    answerMap["продать огород"] := "Продать огород игроку: /sellmygarden | Государству: /sellgarden."
    answerMap["продать киоск"] := "Продать киоск игроку: /sellmystall | Государству: /sellstall."
    answerMap["стил бо"] := "Изменить стиль боя: /set_style"
    answerMap["отм заказ"] := "Отменить заказ механика: /to | Такси: /phone - Приложение такси."
    answerMap["отм вызов"] := "Отменить вызов: /to."
    answerMap["приглас"] := "Пригласить игрока в семью/банду/фракцию: /invite."
    answerMap["приглос"] := "Пригласить игрока в семью/банду/фракцию: /invite."
    answerMap["инвайт"] := "Пригласить игрока в семью/банду/фракцию: /invite."
    answerMap["принять"] := "Пригласить игрока в семью/банду/фракцию: /invite."
    answerMap["выкин авто"] := "Выкинуть игрока из своего авто: /eject | Выкинуть из авто(МВД, ФСБ): /ejectout."
    answerMap["спавн"] := "Изменить место появления при заходе в игру: /setspawn."
    answerMap["спавн банд"] := "Изменить место появления для банды: /gang_spawn."
    answerMap["авто банд"] := "Добавить авто в банду: /gang_car."
    answerMap["уволить"] := "Уволить игрока из фракции/банды/семьи: /uninvite."
    answerMap["ранг банд"] := "Изменить игроку ранг в банде/семье: /frank."
    answerMap["ранг семь"] := "Изменить игроку ранг в банде/семье: /frank."
    answerMap["ранг"] := "Изменить ранг игроку во фракции: /rang."
    answerMap["выда мед"] := "Выдать мед.карту игроку: /medcard."
    answerMap["раци"] := "Рация организации/ТК: /r - RP(IC) | /rr - NRP(OOC)."
    answerMap["заказы дальноб"] := "Посмотреть активные заказы на работе дальнобойщика: /bizlist - продукты | /fuellist - топливо."
    answerMap["обмен"] := "Чтобы провести обмен с игроком, нажмите: R - Персонаж - Обмен предметами."
    answerMap["обмен нотар"] := "Провести обмен в нотариальном агенстве: /exchange."
    answerMap["багаж"] := "Открыть багажник на личном авто: /trunk."
    answerMap["паспорт"] := "Показать свой паспорт: /pass."
    answerMap["вб"] := "Посмотреть военный билет: /pass."
    answerMap["воен билет"] := "Посмотреть военный билет: /pass."
    answerMap["тест"] := "Предложить тест-драйв игроку: /cm_test_drive."
    answerMap["шины"] := "Поменять шины на авто: /replace_tire."
    answerMap["сигнал"] := "Установить сигнализацию на авто: /set_alarm."
    answerMap["мп"] := "Ожидайте. О проведении Мероприятия уведомят в чате."
    answerMap["рвс"] := "Ожидайте. О проведении Респавна авто уведомят в чате."
    answerMap["рвц"] := "Ожидайте. О проведении Респавна авто уведомят в чате."
    answerMap["респ"] := "Ожидайте. О проведении Респавна авто уведомят в чате."
    answerMap["rwc"] := "Ожидайте. О проведении Респавна авто уведомят в чате."
    answerMap["шкаф"] := "Переставить шкаф: /makestore | Открыть: /use."
    answerMap["продать биз"] := "Продать бизнес игроку: /sellmybiz | Государству: /sellbiz."
    answerMap["собес"] := "Посмотреть активные события в игре: /events."
    answerMap["удост"] := "Показать свое удостоверение: /doc."
    answerMap["сня брон"] := "Снять бронежилет: /armoff."
    answerMap["акс"] := "Снять все надетые аксессуары: /reset | Надеть: /put_on."
    answerMap["акс дом"] := "Редактировать аксессуары дома/бизнеса: /pa_edit."
    answerMap["акс биз"] := "Редактировать аксессуары дома/бизнеса: /pa_edit."
    answerMap["пожен"] := "Предложение руки и сердца: /wedding | Развестись: /divorce."
    answerMap["развод"] := "Предложение руки и сердца: /wedding | Развестись: /divorce."
    answerMap["свадьб"] := "Чтобы сыграть свадьбу, необходимо купить обручальные кольца в магазине аксессуаров."
    answerMap["бой"] := "Вызвать на бой другого игрока в спорт.зале: /fight."
    answerMap["выкл телеф"] := "Включить/Выключить телефон: /togphone."
    answerMap["ч с фрак"] := "Добавить в черный список организации: /blist."
    answerMap["ч с орг"] := "Добавить в черный список организации: /blist."
    answerMap["ч с телеф"] := "Добавить номер в черный список: /phone_black."
    answerMap["наказ"] := "Посмотреть список наказаний: /alist | Если посадили в КПЗ/ФСИН: Радиальное меню(R) - другое - личное дело."
    answerMap["перев"] := "Мы не переворачиваем авто. Используйте: /c 090, помощь друга (R - транспорт - перевернуть авто), домкрат."
    answerMap["бумбокс"] := "Поставить бумбокс: /boombox_put | Поднять: /boombox_pick."
    answerMap["нарко"] := "Продать наркотики: /selldrugs."
    answerMap["прод оруж"] := "Продажа/Передача оружия производится через обмен. R - Персонаж - Обмен предметами."
    answerMap["тайм капт"] := "Убрать таймер капта - /capture_timer."
    answerMap["капт биз"] := "Провести войну за бизнес - /capture_biz."
    answerMap["наград"] := "Посмотреть награды: /mn - Награды | Забрать отыграный промокод: /plist."
    answerMap["поворот голов"] := "Включить/Выключить движение головы: /headmove."
    answerMap["подселить"] := "Подселить человека - /live."
    answerMap["выписат"] := "Выписаться из совместного проживания - /liveout."
    badWords := ["блят","сук","ебат","ебал","ебла","хуй","пизд","пидо","бляд","долб","заеб","неху","схуя","наеб","ахуе","охуе","поху","хуе"]
    badExpressions := {}
    badExpressions["даун"] := true
    badExpressions["пидор"] := true
    badExpressions["пидар"] := true
    badExpressions["шлюх"] := true
    badExpressions["ебла"] := true
    badExpressions["ебал"] := true
    badExpressions["конч"] := true
    badExpressions["рот ебал"] := true
    badExpressions["ебан"] := true
    badExpressions["нищи"] := true
    badExpressions["пош нах"] := true
    badExpressions["лох"] := true
    badExpressions["деби"] := true
    badExpressions["дура"] := true
    Loop, Read, %filePath%
    {
        LineNumber++
        line := A_LoopReadLine
        if (LineNumber < lastLineNum) {
            continue
        } if RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]: (.+)", match) {
            SetTimer, respondComplaint, Off
            SetTimer, respondCommand, Off
            Reports := match4
            ansLogID := match3
            ansAuthor := match2
            global playerId := ansLogID
            StringLower, LoopLine, Reports
            Reports := RegExReplace(Reports, "\{[A-F0-9]{6}\}")
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            if (seen == "ERROR") {
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
                for key, reply in answerMap {
                    found := true
                    Loop, Parse, key, %A_Space%
                    {
                        if !InStr(LoopLine, A_LoopField) {
                            found := false
                            break
                        }
                    }
                    if (found && IsGTAOpen()) {
                        answerComplaint := reply
                        SetTimer, respondComplaint, 30
                        ShowTip(ansAuthor, ansLogID, Reports, kR, "Вопрос", reply)
                        break
                    }
                }
                isHandled := false
                for key, _ in badExpressions {
                    found := true
                    Loop, Parse, key, %A_Space%
                    {
                        if !InStr(LoopLine, A_LoopField) {
                            found := false
                            break
                        }
                    }
                    if (found && IsGTAOpen()) {
                        answerCommand := "360 Оскорбление администрации."
                        SetTimer, respondCommand, 30
                        isHandled := true
                        ShowTip(ansAuthor, ansLogID, Reports, kR, "ОСК", "")
                        break
                    }
                }
                if (!isHandled) {
                    for each, word in badWords {
                        if (InStr(LoopLine, word) && IsGTAOpen()) {
                            answerCommand := "120 Мат в /report."
                            SetTimer, respondCommand, 30
                            ShowTip(ansAuthor, ansLogID, Reports, kR, "МАТ", "")
                            break
                        }
                    }
                }
            }
        } if (RegExMatch(line, "\[A\] (\w+)_(\w+)\[(\d+)\]: (.+)", match)) {
            text := StrSplit(match4, " ")
            adminName := " | " . SubStr(match1, 1, 1) . "." . match2
            targetID := text[1]
            if (InStr(text[2], "чит") || InStr(text[2], "cheat")) {
                targetPunish := "/sban " . targetID . " 1 Исп. читов." . adminName
            } else if (InStr(text[2], "бот") || InStr(text[2], "bot")) {
                targetPunish := "/sban " . targetID . " 1 Исп. ботов." . adminName
            } if (targetPunish) {
                Sleep, 5335
                SetTimer, issueAChatPunishment, 50
                Sleep, 3553
                SetTimer, issueAChatPunishment, Off
            }
            lastLineNum := LineNumber
        }
    }
    lastLineNum := LineNumber
}


respondComplaint() {
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P") {
            logTimersOff()
            Sleep, 100
            global playerId
            SendMessage, 0x50,, 0x4190419,, A
            sendReply(playerId, answerComplaint)
            ToolTip("[𝐑𝐄𝐏𝐋𝐘] Игроку был дан ответ.", 3300)
        }
    }
}


respondCommand() {
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P") {
            logTimersOff()
            Sleep, 100
            SendMessage, 0x50,, 0x4190419,, A
            if (isHumanInput) {
                l := StrLen(answerCommand) + 1
                SendInput, {F6}/rmute  %answerCommand%{left %l%}
                Sleep, %CMDDelay%
                Loop, Parse, ansLogID
                {
                    SendInput, %A_LoopField%
                    Random, rDelay1, %InputDelay1%, %InputDelay2%
                    Sleep, rDelay1
                }
                SendInput, {Enter down}
                Sleep, 50
                SendInput, {Enter up}
            } else if (!isHumanInput) {
                SendInput, {F6}/rmute %ansLogID% %answerCommand%{Enter}
            }
            ToolTip("[𝐏𝐔𝐍𝐈𝐒𝐇𝐌𝐄𝐍𝐓] Игрок был наказан.", 3300)
        }
    }
}


issueAChatPunishment() {
    global adminName, targetID, targetPunish
    ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ✎ Выдать " . targetPunish . "?", 3000)
    if hotkeys["Reply"] != "" {
        if (GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P")) {
            SetTimer, issueAChatPunishment, Off
            logTimersOff()
            spTimersOff()
            SendMessage, 0x50,, 0x4190419,, A
            SendInput, {F6}%targetPunish%{Enter}
        }
    }
}


autoIssue:
    autoIssue()
Return

autoIssue() {
    static cmdLimits
    static processedLines := []
    if (!cmdLimits) {
        cmdLimits := Object()
        cmdLimits["/offjail"] := Object("limit", 4, "delay", 800, "wait", 70000)
        cmdLimits["/jail"]    := Object("limit", 4, "delay", 800, "wait", 70000)
        cmdLimits["/soffban"] := Object("limit", 2, "delay", 800, "wait", 90000)
        cmdLimits["/offban"]  := Object("limit", 2, "delay", 800, "wait", 90000)
        cmdLimits["/sban"]    := Object("limit", 2, "delay", 800, "wait", 90000)
        cmdLimits["/ban"]     := Object("limit", 2, "delay", 800, "wait", 90000)
        cmdLimits["/offwarn"] := Object("limit", 2, "delay", 800, "wait", 80000)
        cmdLimits["/warn"]    := Object("limit", 2, "delay", 800, "wait", 80000)
        cmdLimits["/mute"]    := Object("limit", 2, "delay", 800, "wait", 75000)
        cmdLimits["/v_mute"]  := Object("limit", 2, "delay", 800, "wait", 75000)
        cmdLimits["/fmute"]   := Object("limit", 2, "delay", 800, "wait", 75000)
        cmdLimits["/rmute"]   := Object("limit", 2, "delay", 800, "wait", 75000)
        cmdLimits["/kick"]    := Object("limit", 5, "delay", 800, "wait", 60000)
        cmdLimits["/gunban"]  := Object("limit", 3, "delay", 800, "wait", 60000)
        cmdLimits["/msg"]     := Object("limit", 50, "delay", 2050, "wait", 2050)
    }
    commands := Object()
    idx := 0
    Loop, Read, %autoIssueFile%
    {
        line := Trim(A_LoopReadLine, " `t")
        if (line = "" || RegExMatch(line, "^(;|#|//|--)"))
        continue
        if RegExMatch(line, "^\s*(\/\w+)", m) {
            idx++
            commands[idx] := line
        }
    }
    cmdGroups := Object()
    for idx, cmdLine in commands {
        if RegExMatch(cmdLine, "^\s*(\/\w+)", m) {
            cmdType := m1
            if !cmdGroups.HasKey(cmdType)
            cmdGroups[cmdType] := Object()
            nextIdx := cmdGroups[cmdType].MaxIndex() ? cmdGroups[cmdType].MaxIndex() + 1 : 1
            cmdGroups[cmdType][nextIdx] := cmdLine
        }
    }
    for cmdType, cmdList in cmdGroups {
        limit := cmdLimits.HasKey(cmdType) ? cmdLimits[cmdType]["limit"] : 3
        delay := cmdLimits.HasKey(cmdType) ? cmdLimits[cmdType]["delay"] : 800
        wait := cmdLimits.HasKey(cmdType) ? cmdLimits[cmdType]["wait"] : 80000
        total := cmdList.MaxIndex()
        issuedCommands := 0
        for i, cmdLine in cmdList {
            RegExMatch(cmdLine, "^\s*(\/\w+)\s+([^\s]+)\s+(\d+)?\s*(.*)?", commandMatch)
            cmdType := commandMatch1
            nickName := commandMatch2
            issueTime := commandMatch3
            issueReason := commandMatch4
            SendMessage, 0x50,, 0x4190419,, A
            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Ввожу команду: " . cmdLine, 1000)
            SendInput, ^a {BackSpace}{Enter}
            Sleep, 100
            SendInput, {F6}%cmdLine%{Enter}
            issuedCommands++
            Sleep, 430
            Loop, Read, %filePath%
            {
                LineNumber++
                line := A_LoopReadLine
                if (LineNumber < autoIssueLastLineNum) {
                    continue
                } if (line ~= "Игрок с таким именем находится на сервере, используйте\s+.+" && !processedLines.HasKey(HashLine(line)) && !(cmdType = "/kick" || cmdType = "/msg" || cmdType = "/gunban" || cmdType = "/mute" || cmdType = "/v_mute" || cmdType = "/fmute" || cmdType = "/rmute")) {
                    processedLines[HashLine(line)] := true
                    ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: " . cmdLine . "`n↪️ Игрок " . nickName . " находится на сервере. Исключаю игрока...", 1000)
                    SendMessage, 0x50,, 0x4190419,, A
                    SendInput, ^a {BackSpace}{Enter}
                    SendInput, {F6}/kick %nickName% Ожидайте наказания.{Enter}
                    Sleep, delay
                    ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: " . cmdLine . "`n↪️ Игрок " . nickName . " исключен. Выдаю наказание повторно...", 1000)
                    SendInput, ^a {BackSpace}{Enter}
                    SendInput, {F6}%cmdLine%{Enter}
                    autoIssueLastLineNum := LineNumber
                    Sleep, delay
                    Loop, Read, %filePath%
                    {
                        LineNumber++
                        if (LineNumber <= autoIssueLastLineNum)
                        continue
                        line := A_LoopReadLine
                        if (InStr(line, "Этот игрок уже находится в тюрьме") && !processedLines.HasKey(HashLine(line))  && (cmdType = "/jail" || cmdType = "/offjail" || cmdType = "/kjail")) {
                            processedLines[HashLine(line)] := true
                            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: " . cmdLine . "`n↪️ Игрок " . nickName . " уже в тюрьме. Получаю оставшееся время игрока...", 1000)
                            SendMessage, 0x50,, 0x4190419,, A
                            SendInput, ^a {BackSpace}{Enter}
                            SendInput, {F6}/time %nickName%{Enter}
                            autoIssueLastLineNum := LineNumber
                            Sleep, delay
                            Loop, Read, %filePath%
                            {
                                LineNumber++
                                if (LineNumber <= autoIssueLastLineNum)
                                continue
                                line := A_LoopReadLine
                                if (RegExMatch(line, "Время до выхода на свободу: (\d+):\d+", pTime) && !processedLines.HasKey(HashLine(line))) {
                                    processedLines[HashLine(line)] := true
                                    SendInput, ^a {BackSpace}{Enter}
                                    SendInput, {F6}/unjail %nickName%{Enter}
                                    ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Время до выхода на свободу " . nickName . ": " . pTime1 . " сек. Добавляю это время к текущей выдаче...", 1000)
                                    issueTime := issueTime + pTime1
                                    issueReason := issueReason . "(перевыдано)"
                                    Sleep, delay
                                    SendMessage, 0x50,, 0x4190419,, A
                                    SendInput, ^a {BackSpace}{Enter}
                                    SendInput, {F6}%cmdType% %nickName% %issueTime% %issueReason%{Enter}
                                    ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Наказание успешно выдано.", 1000)
                                    break
                                }
                            }
                            break
                        }
                    }
                    break
                } if (InStr(line, "Этот игрок уже находится в тюрьме") && !processedLines.HasKey(HashLine(line)) && (cmdType = "/jail" || cmdType = "/offjail" || cmdType = "/kjail")) {
                    processedLines[HashLine(line)] := true
                    ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: " . cmdLine  . "`n↪️ Игрок " . nickName . " уже в тюрьме. Получаю оставшееся время игрока...", 1500)
                    SendInput, ^a {BackSpace}{Enter}
                    SendInput, {F6}/time %nickName%{Enter}
                    autoIssueLastLineNum := LineNumber
                    Sleep, 430
                    Loop, Read, %filePath%
                    {
                        LineNumber++
                        if (LineNumber <= autoIssueLastLineNum)
                        continue
                        line := A_LoopReadLine
                        if (RegExMatch(line, "Время до выхода на свободу: (\d+):\d+", pTime) && !processedLines.HasKey(HashLine(line))) {
                            processedLines[HashLine(line)] := true
                            SendInput, ^a {BackSpace}{Enter}
                            SendInput, {F6}/unjail %nickName%{Enter}
                            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Время до выхода на свободу " . nickName . ": " . pTime1 . " сек. Добавляю это время к текущей выдаче...", 1000)
                            issueTime := issueTime + pTime1
                            issueReason := issueReason . "(перевыдано)"
                            Sleep, delay
                            SendInput, ^a {BackSpace}{Enter}
                            SendInput, {F6}%cmdType% %nickName% %issueTime% %issueReason%{Enter}
                            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Наказание успешно выдано.", 2000)
                            break
                        }
                    }
                    break
                } if (InStr(line, "У этого игрока уже есть блокировка") && !processedLines.HasKey(HashLine(line))) {
                    processedLines[HashLine(line)] := true
                    if ((cmdType = "/mute" || cmdType = "/rmute" || cmdType = "/fmute")) {
                        ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] У игрока " . nickName . " уже есть блокировка чата. Получаю оставшееся время...", 1500)
                        SendInput, ^a {BackSpace}{Enter}
                        SendInput, {F6}/time %nickName%{Enter}
                        autoIssueLastLineNum := LineNumber
                        Sleep, 430
                        Loop, Read, %filePath%
                        {
                            LineNumber++
                            if (LineNumber <= autoIssueLastLineNum)
                            continue
                            line := A_LoopReadLine
                            if (RegExMatch(line, "Время до разблокировки (чата|репорта): (\d+):\d+", pTime) && !processedLines.HasKey(HashLine(line))) {
                                processedLines[HashLine(line)] := true
                                SendInput, ^a {BackSpace}{Enter}
                                if (cmdType = "/mute") {
                                    SendInput, {F6}/unmute %nickName%{Enter}
                                } else if (cmdType = "/fmute") {
                                    SendInput, {F6}/unfmute %nickName%{Enter}
                                } else if (cmdType = "/rmute") {
                                    SendInput, {F6}/unrmute %nickName%{Enter}
                                }
                                ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Оставшееся время затычки " . nickName . ": " . pTime1 . " сек. Добавляю это время к текущей выдаче...", 1000)
                                issueTime := issueTime + pTime1
                                issueReason := issueReason . "(перевыдано)"
                                Sleep, delay
                                SendInput, ^a {BackSpace}{Enter}
                                SendInput, {F6}%cmdType% %nickName% %issueTime% %issueReason%{Enter}
                                ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Наказание успешно выдано.", 1500)
                                break
                            }
                        }
                    }
                } if (InStr(line, "Аккаунт с таким именем уже находится в бане") && !processedLines.HasKey(HashLine(line))) {
                    processedLines[HashLine(line)] := true
                    issuedCommands--
                }
            }
            Sleep, delay
            fwait := Round(wait/1000)

            if (issuedCommands == limit && total > limit) {
                ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Достигнут лимит для " . cmdType . ". Ожидаю " . fwait . " секунд...", 3300)
                issuedCommands := 0
                Sleep, %wait%
            }
        }
    }

    if (total) {
        ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Все команды введены", 2000)
        text := "# Тут можно вставить список наказаний, которые нужно выдать в игре. `n# Пример: /offjail Nick_Name 120 Жалоба на игрока 1`n`n"
        FileDelete, %autoIssueFile%
        FileAppend, %text%, %autoIssueFile%, UTF-8
    } else {
        ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Файл пустой или не найден.", 2000)
    }
}


autoEdit:
    if (!active) {
        lastReadLine := checkChatLog()
        active := true
        SetTimer, autoEditFunc, 50
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoEdit включена. Ожидание нового объявления...", 2332)
    } else {
        SetTimer, autoEditFunc, Off
        active := false
    }
Return


autoEditFunc() {
    Loop, Read, %filePath%
    {
        LineNumber++
        line := A_LoopReadLine
        if (LineNumber < lastReadLine) {
            continue
        } else if (line ~= "Добавлено новое объявление. Используйте: /edit для модерации") {
            SendInput, {F6}/edit{Enter}
            Sleep, 250
            SendInput, {Enter}
            Sleep, 250
            SendInput, {Enter}
            Sleep, 250
            SendInput, {Down}
            Sleep, 250
            SendInput, {Enter}
            active := false
            SetTimer, autoEditFunc, Off
            lastReadLine := LineNumber
            Break
        }
    }
}


global onOrder := false
global isWaitingForLoad := false


autoBizlist:
    if (!active && !onOrder) {
        lastReadLine := checkChatLog()
        active := true

        SetTimer, CatchingAnOrder, 30
        SetTimer, WaitingForOrderInChat, 30
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoBizlist включена. Ожидание нового заказа...", 2332)
    } else {
        active := false
        onOrder := false
        productCount := 0

        SetTimer, CatchingAnOrder, Off
        SetTimer, WaitingForOrderInChat, Off

        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoBizlist выключена.", 2332)
    }
Return


CatchingAnOrder() {
    IniRead, minutesOfCatching1, %settingsFile%, Preset, minutesOfCatching1
    IniRead, minutesOfCatching2, %settingsFile%, Preset, minutesOfCatching2

    isEven := (Mod(A_Min, 2) = 0)
    
    if ((!isEven && A_Sec >= minutesOfCatching1) || (isEven && A_Sec < minutesOfCatching2)) {
        if (onOrder) {
            Return
        } if (ChatIsOpen) {
            SendInput, {BS 128}{Esc}
            ChatIsOpen := false
        } if (isHumanInput) {
            SendInput, {F6}
            Sleep, 150
            SendInput, /bizlist
            Sleep, 100
            SendInput, {Enter}
            Sleep, 250
            SendInput, {Enter}
            Sleep, 165
            SendInput, {Enter}
            Sleep, 150
        } else if (!isHumanInput) {
            SendInput, {F6}/bizlist{Enter}
            Sleep, 150
            SendInput, {Enter}
            Sleep, 165
            SendInput, {Enter}
            Sleep, 350
        }
    }
}


WaitingForOrderInChat() {
    Loop, Read, %filePath%
    {
        if (A_Index < lastReadLine) {
            continue
        } else if (A_LoopReadLine ~= "В компанию поступил новый заказ на поставку {FFFF00}продукции{ffffff}.") {
            active := false
            SetTimer, CatchingAnOrder, Off
            SetTimer, WaitingForOrderInChat, Off
            Sleep, 50

            if (ChatIsOpen) {
                SendInput, {BS 128}{Esc}
                ChatIsOpen := false
            } if (isHumanInput) {
                SendInput, {F6}
                Sleep, 150
                SendInput, /bizlist
                Sleep, 100
                SendInput, {Enter}
                Sleep, 250
                SendInput, {Enter}
                Sleep, 165
                SendInput, {Enter}
                Sleep, 150
            } else if (!isHumanInput) {
                SendInput, {F6}/bizlist{Enter}
                Sleep, 150
                SendInput, {Enter}
                Sleep, 165
                SendInput, {Enter}
                Sleep, 350
            }
        }
    }
}


ExpectationOfProfit() {
    global lastReadLine, active, onOrder, productCount, isWaitingForLoad
    
    currentTotalLines := checkChatLog()
    
    if (currentTotalLines < lastReadLine) {
        lastReadLine := 0
    }

    Loop, Read, %filePath%
    {
        if (A_Index < lastReadLine)
            continue

        lastReadLine := A_Index
        
        if (InStr(A_LoopReadLine, "Вы продали")) {
            if (RegExMatch(A_LoopReadLine, "\{FFFFFF\}""(.*?)"" .*?\{FFFFFF\}(\d+) .*?\{FFFFFF\}(\d+)", match)) {
                itemName  := match1
                itemCount := match2
                itemPrice := match3
                FormatTime, CurrentTime,, dd.MM.yyyy HH:mm:ss
                LogString := CurrentTime . ", " . itemPrice . " руб, " . (InStr(itemName, "Шкур") ? """Продажа шкур" : """Продажа урожая") . ", " . itemName . ": " . itemCount . " шт.""`n"
                FileAppend, %LogString%, %scriptDir%\orderHistory.csv, UTF-8
                earnings := RegExReplace(itemPrice, "(\d)(?=(\d{3})+(?!\d))", "$1.")
                ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Продано " . itemCount . " шт. Заработано: " . earnings . " руб.", 2000)
            }
        } else if (InStr(A_LoopReadLine, "Вы доставили")) {
            if RegExMatch(A_LoopReadLine, "доставили\s\{[a-z0-9]{6}\}(\d+).*?«\{[a-z0-9]{6}\}(.*?)\{[a-z0-9]{6}\}».*?получили\s\{[a-z0-9]{6}\}(\d+)", match) {
                itemCount := match1
                shopName := match2
                earnings := match3
            } if RegExMatch(A_LoopReadLine, "Вы доставили\s\{[a-z0-9]{6}\}(\d+).*?получили за работу\s\{[a-z0-9]{6}\}(\d+)", match) {
                itemCount := match1
                shopName := "Стройка 'Южный'"
                earnings := match2
            }

            FormatTime, CurrentTime,, dd.MM.yyyy HH:mm:ss
            LogString := CurrentTime . ", " . earnings . " руб, " . """Доставка продуктов, " . shopName . ": " . itemCount . " ед.""`n"
            FileAppend, %LogString%, %scriptDir%\orderHistory.csv, UTF-8
            TruckerIncome := GetIncomeByDate(A_DD . "." . A_MM . "." . A_YYYY, "Доставка продуктов")
            
            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Доставлено " . itemCount . " ед. товара п/п: " . shopName . ". Прибыль: " . earnings . " руб. `n↪︎Общая прибыль за сегодня: " . TruckerIncome . " руб.", 11111)
        } else if (InStr(A_LoopReadLine, "Вы начали выполнение заказа.")) {
            SetTimer, WaitingForOrderInChat, Off
            SetTimer, CatchingAnOrder, Off

            onOrder := true
            active := false

            SoundBeep, 1800, 100
            SoundBeep, 1800, 100
            SoundBeep, 1800, 100
            SoundBeep, 1800, 100
            Sleep, 333
            
            if (ChatIsOpen) {
                SendInput, {BS 128}{Esc}
                ChatIsOpen := false
            }

            SendInput, {F6}/bizlist{Enter}
            Sleep, 150
            SendInput, {Esc}
            Sleep, 200

            Loop, Read, %filePath%
            {
                if (A_Index < lastReadLine)
                continue
                lastReadLine := A_Index
                if RegExMatch(A_LoopReadLine, "Грузовой {FFFF00}отсек пуст{ffffff}. Заказчику требуется {FFFF00}(\d+) ед.{ffffff}", match) {
                    productCount := match1
                }
            }

            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Заказ найден. Клиенту требуется: " . productCount . " ед. товара", 3553)
            isWaitingForLoad := true
        }
    }
}


ToolTip(text, delay) {
    if (!isToolTipActive) {
        ToolTip, %text%
        SetTimer, clearToolTip, -%delay%
    }
}


clearToolTip() {
    ToolTip
}


!^Esc::
    Process, Close, %pid%
ExitApp


#IfWinActive ahk_exe gta_sa.exe

:?:/gt::
    SendMessage, 0x50,, 0x4190419,, A

    SendInput, [Таймер] Введите время (минуты):{Space}
    Input, time, V I M, {Enter}{Esc}

    if (ErrorLevel = "EndKey:Escape") {
        SendInput, {End}+{Home}{Del}{Esc}
        Return
    }
    if (time > 0) {
        SendInput, {End}+{Home}{Del}{Esc}
        timeMs := -(time * 60 * 1000)
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Таймер запущен на %time% мин.
        SetTimer, TimerFunc, %timeMs%
        SetTimer, clearToolTip, -3000
    } else {
        SendInput, {End}+{Home}{Del}{Esc}
    }
Return


~F6::
~t::
    ChatIsOpen := true
return


~Enter::
~NumpadEnter::
~Escape::
    ChatIsOpen := false
return


~RShift::
if (isWaitingForLoad) {
    threshold := orderOneGo ? 7100 : 5520
    if (productCount > threshold) {
        SendInput, {Enter}
        Sleep, 150
        SendInput, 5520{Enter}
        productCount -= 5520
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Загружается 5520 ед. товара. Остаток: " . productCount, 3223)
    } else {
        SendInput, {Enter}
        Sleep, 150
        SendInput, %productCount%{Enter}
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Загружается " productCount . " ед. товара.", 3223)
        productCount := 0
        isWaitingForLoad := false
        active := false
        onOrder := false
    }
}
return

#If