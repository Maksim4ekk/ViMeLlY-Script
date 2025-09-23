#SingleInstance, Force
#Persistent
#NoEnv
#NoTrayIcon

SetTitleMatchMode, 2
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

global version := "v 1.5.6"

; === Хранение ID
global repID, ansID, ansLogID
; === Хранение Горячих клавиш
global hotkeys := {}
global previousHotkeys := {}
global punishMap := {}
global currentCmdKey := ""
; === Хранение статуса Режимов
global isHumanInput, reportLog, punishHelperStatus, autoIssueStatus, lastRequest, additionalFeaturesStatus, adminStatsStatus
global active := 0
; === Хранение информации из конфига
global currentSetup, CMDDelay, InputDelay1, InputDelay2, AUser, guiColor
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
; === Хранение значения ответов
global answerComplaint, answerCommand, responses
; === Хранение значения прочитанных строк ChatLog, пути к нему
global filePath := FindChatlogPath()
global lastLineNum, lastReadLine
; === Хранение даты запуска скрипта
global today := A_DD . "." . A_MM . "." . A_YYYY
global today1 := A_YYYY . "-" . A_MM . "-" . A_DD

;=================================================================================================================================================

;================================================================
;=============== НАЧАЛЬНЫЕ НАСТРОЙКИ/ФУНКЦИИ ====================
;================================================================

ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Инициализация скрипта...

; Загрузка и бинд клавиш
LoadHotkeys()
Sleep, 1000
BindHotkeys()

; === Запуск функций
SetTimer, checkUpdates, -50 ; Проверить наличие обновлений

; === Чтение файла настроек
IniRead, AUser, %settingsFile%, Preset, AUser
IniRead, rL, %settingsFile%, Preset, reportLog
IniRead, aI, %settingsFile%, Preset, autoIssueStatus
IniRead, pH, %settingsFile%, Preset, punishHelperStatus
IniRead, aF, %settingsFile%, Preset, additionalFeaturesStatus
IniRead, aS, %settingsFile%, Preset, adminStatsStatus

reportLog := (rL == "") ? 0 : rL
autoIssueStatus := (aI == "") ? 0 : aI
punishHelperStatus := (pH == "") ? 0 : pH
additionalFeaturesStatus := (aF == "") ? 0 : aF
adminStatsStatus := (aS == "") ? 0 : aS

if (rL && rL != "ERROR") {
    SetTimer, answerLogger, 500 ; Включить лог вопросов (если включен в настройках)
} if (aF && aF != "ERROR") {
    global pid
    Run, %additionalFeaturesFile%, , , pid
}

ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] ViMeLlY Script (%version%) загружен. Приятного пользования!
Sleep, 1771
ToolTip

Stub:  ; Заглушка от активации функций
Return

;=================================================================================================================================================

checkUpdates() {
    if (!FileExist(scriptVersion)) {
        UrlDownloadToFile, https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlYScript.ver, %scriptVersion%
    } if (FileExist(scriptVersion)) {
        FileRead, serverVersion, %scriptVersion%
        updateUrl := "https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlY%20Script.exe"
        if (serverVersion != version) {
            ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Доступно обновление ViMeLlY Script (%serverVersion%)! Начинаю загрузку...
            Sleep, 4774
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
            ExitApp
        } else {
            if (FileExist(A_Temp . "\update.ahk")) {
                FileDelete, %A_Temp%\update.ahk
            }
            SetTimer, scriptSettings, 500 ; Проверять файл настроек
            SetTimer, adminsStatistics, -500 ; Проверить норму
            SetTimer, CountAdminActions, 500 ; Включить счётчик нормы
            SetTimer, punishHelper, 3000 ; Включить чтение файла наказаний
        }
    }
}

scriptSettings() {
    if (!FileExist(scriptLogo1) || !FileExist(scriptLogo2) || !FileExist(scriptLogo3) || !FileExist(scriptLogo4) || !FileExist(scriptLogo5) ) {
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1IRUsSOw92CPi7Olkuq3pP13kgQzxfczu&export=download&authuser=0&confirm=t&uuid=d232d00d-d535-4dc5-88e4-e08429256637&at=AN8xHopR-PLqyZs8yJ1OtbBRXRSn:1758379704317, %A_Temp%\ViMeLlYScript_1.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1px54qZCf4zw7SXOGNvzFme4OTFmnP_TQ&export=download&authuser=0&confirm=t&uuid=a591b692-7d58-4220-97a0-47870f1d954e&at=AN8xHoqO47w_bnM5MXEbxR6_O1-w:1758379699137, %A_Temp%\ViMeLlYScript_2.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1PnUALVxeETh2Zwt6lo_OACkTR5ipbafi&export=download&authuser=0&confirm=t&uuid=94c272fa-a6b1-4010-93d5-d7641eb60f1a&at=AN8xHooLAWKRoLQtdnZgr-ZVRy04:1758379692936, %A_Temp%\ViMeLlYScript_3.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1FVUiGqg-8MQ2BE4XI4XOttUreelogqiR&export=download&authuser=0&confirm=t&uuid=035df7bc-4301-4210-8d9e-032968bff93c&at=AN8xHoqDku86yg8xr3NlBkKMxGUR:1758379686118, %A_Temp%\ViMeLlYScript_4.png
        UrlDownloadToFile, https://drive.usercontent.google.com/download?id=1JgvrXuyC3e3yyXJ9L0W8X3q9nlekN6j1&export=download&authuser=0&confirm=t&uuid=909d92a5-838f-462e-8d91-703d94ad79c4&at=AN8xHopXUr5z4lqeghnhxd7mbCom:1758379671208, %A_Temp%\ViMeLlYScript_5.png
    } if (!FileExist(scriptDir)) {
        FileCreateDir, %scriptDir%
    } if (!FileExist(settingsFile)) {
        IniWrite, F2, %settingsFile%, Keys, Menu
        IniWrite, %A_Space%, %settingsFile%, Keys, Watch
        IniWrite, %A_Space%, %settingsFile%, Keys, Request
        IniWrite, %A_Space%, %settingsFile%, Keys, Reply
        IniWrite, %A_Space%, %settingsFile%, Keys, humanReply
        IniWrite, F10, %settingsFile%, Keys, AdminStats
        IniWrite, %A_Space%, %settingsFile%, Keys, CopyAChat
        IniWrite, %A_Space%, %settingsFile%, Keys, autoIssue
        IniWrite, %A_Space%, %settingsFile%, Keys, autoEdit
        IniWrite, %A_Space%, %settingsFile%, Keys, EmergencyDelete
        
        IniWrite, 1, %settingsFile%, Preset, isHumanInput
        IniWrite, Быстро, %settingsFile%, Preset, currentSetup
        IniWrite, 0, %settingsFile%, Preset, reportLog
        IniWrite, 0, %settingsFile%, Preset, autoIssueStatus
        IniWrite, 0, %settingsFile%, Preset, punishHelperStatus
        IniWrite, 0, %settingsFile%, Preset, additionalFeaturesStatus
        IniWrite, 1, %settingsFile%, Preset, adiminStatsStatus

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
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл настроек создан.
        Sleep, 1700

        Reload
    } if (!FileExist(punishFile) && punishHelperStatus) {
        text := "# Тут можно добавлять/удалять/изменять виды наказаний`n# Формат: /команда = /командаНаказания Время Причина`n# Пример: /epp = /jail 60 Езда по полям`n`n"
        FileAppend, %text%, %punishFile%, UTF-8
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл скрипта наказаний создан.
        Sleep, 1700
        ToolTip
    } if (!FileExist(autoIssueFile) && autoIssueStatus) {
        text := "# Тут можно вставить список наказаний, которые нужно выдать в игре. `n# Пример: /offjail Nick_Name 120 Жалоба на игрока 1`n`n"
        FileAppend, %text%, %autoIssueFile%, UTF-8
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл авто-выдачи создан.
        Sleep, 1700
        ToolTip
    } if (!FileExist(additionalFeaturesFile) && additionalFeaturesStatus) {
        text := "#SingleInstance`, Force `; Позволяет запускать лишь 1 скрипт одновременно `n#Persistent `; Оставляет скрипт работающим на постоянной основе.`n#NoEnv `; - Отключает автоматическое наследование переменных окружения Windows.`n#NoTrayIcon `; - Скрывает значок скрипта в системном трее. `n`nSetTitleMatchMode, 2 `; - Устанавливает режим поиска окон по заголовку.`nSetBatchLines, -1 `; - Устанавливает максимальную производительность.`nSendMode Input `; - Устанавливает режим отправки клавиш.`n`n`; === Ваш скрипт`n`n`n`n;================================================================================================================================================="
        FileAppend, %text%, %additionalFeaturesFile%, UTF-8
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл доп. скрипта создан.
        Sleep, 1700
        ToolTip
    } if (!FileExist(statisticFile) && AUser != "ERROR" && adminStatsStatus) {
        IniRead, totalAns, %settingsFile%, %AUser%, totalAns
        IniRead, totalJails, %settingsFile%, %AUser%, totalJails
        
        IniWrite, %totalAns%, %statisticFile%, %today%, totalAns
        IniWrite, %totalJails%, %statisticFile%, %today%, totalJails
    }
}

; === Удаление всей нормы (Вместе с обработанными строками)
adminsStatistics() {
    IniRead, AUser, %settingsFile%, Preset, AUser ; Получаем Nick_Name администратора
    IniRead, savedDate, %settingsFile%, %AUser%, Date ; Получаем сохраненную дату
    IniRead, totalAns, %settingsFile%, %AUser%, totalAns ; Получаем сохраненные /pm | /ans
    IniRead, totalJails, %settingsFile%, %AUser%, totalJails ; Получаем сохраненные /jail | /offjail | /unjail
    adminName := Base64Decode(AUser)
    Sleep, 333
    if ((AUser != "" && AUser != "ERROR") && savedDate != today) { ; Если ник администратора определён - проверяем дату сохраненной статистики, если она новая - сброс
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Сбрасываю статистику...
        IniWrite, %totalAns%, %statisticFile%, %savedDate%, totalAns
        IniWrite, %totalJails%, %statisticFile%, %savedDate%, totalJails
        
        IniWrite, %today%, %settingsFile%, %AUser%, Date
        IniWrite, 0, %settingsFile%, %AUser%, totalAns
        IniWrite, 0, %settingsFile%, %AUser%, totalJails
        IniDelete, %settingsFile%, ProcessedLines
        Sleep, 333
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Ваша статистика сброшена.
        Sleep, 1771
        ToolTip
    } else if (AUser != "" && AUser != "ERROR") { ; Если ник администратора определён - загружаем статистику
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Загружаю статистику...
        Sleep, 1771
        if (totalAns = "" || totalAns = "ERROR") { ; Если при загрузке totalAns произошла ошибка
            IniWrite, 0, %settingsFile%, %AUser%, totalAns
            ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Ошибка при загрузке pm'ок`, сбрасываю значения...
            Sleep, 1771
        } if (totalJails = "" || totalJails = "ERROR") { ; Если при загрузке totalJails произошла ошибка
            IniWrite, 0, %settingsFile%, %AUser%, totalJails
            ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Ошибка при загрузке jail'ов`, сбрасываю значения...
            Sleep, 1771
        }
        IniRead, totalAns, %settingsFile%, %AUser%, totalAns ; Получаем сохраненные /pm | /ans
        IniRead, totalJails, %settingsFile%, %AUser%, totalJails ; Получаем сохраненные /jail | /offjail | /unjail
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата сохраненной статистики: %savedDate% | Текущая: %today%`n↪︎ Статистика загружена. Текущие значения:`n`n★ Администратор %adminName% ⤵︎`n- ✉ Ответов: %totalAns% (/pm)`n- ⚖ Jail'ов: %totalJails% (/jail)
        Sleep, 2772
        ToolTip
    }
}

;=================================================================================================================================================

;====================================================
;=============== МЕНЮ СКРИПТА =======================
;====================================================

;=================================================================================================================================================

guiColorFunc() {
    Random, randomLogo, 1, 5
    if (randomLogo = 1) {
        Gui, ViMeLlY:Color, FFE4E1
        guiColor := "FFE4E1"
    } else if (randomLogo == 2) {
        Gui, ViMeLlY:Color, A9DBD6
        guiColor := "A9DBD6"
    } else if (randomLogo == 3) {
        Gui, ViMeLlY:Color, F3E5AB
        guiColor := "F3E5AB"
    } else if (randomLogo == 4) {
        Gui, ViMeLlY:Color, F5DEB3
        guiColor := "F5DEB3"
    } else {
        Gui, ViMeLlY:Color, D8D8F6
        guiColor := "D8D8F6"
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

    Gui, ViMeLlY:New,, ViMeLlY Script
    Gui, ViMeLlY:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlY:Color, % guiColor
    Gui, ViMeLlY:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Text, w375 Center, ViMeLlY Script
    Gui, ViMeLlY:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Button, yp x325 gReload,⟲
    Gui, ViMeLlY:Add, Button, yp x+1 gStop,⊚
    Gui, ViMeLlY:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlY:Add, Text, y+1 xm w383 Center,‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Главное меню ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧

    Gui, ViMeLlY:Font, s8, Comic Sans MS
    Gui, ViMeLlY:Add, Button, xm y+1 gHotKeys w190,🕹 Настройки клавиш྾
    Gui, ViMeLlY:Add, Button, x+0.5 yp gAnswers w190,⚙️ Настройки ответов྾
    
    Gui, ViMeLlY:Font, s7, Comic Sans MS
    Gui, ViMeLlY:Add, Button, xm y+1 w75 gOpenSettings, 👁️ Настройки
    Gui, ViMeLlY:Add, Button, x+1 yp w80 gOpenAutoIssue, 👁️ Автовыдача
    Gui, ViMeLlY:Add, Button, x+1 yp w130 gOpenPunishHelper, 👁️ Помощник наказаний
    Gui, ViMeLlY:Add, Button, x+1 yp w93 gOpenAdditionalFeatures, 👁️ Доп. скрипт

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
        SetTimer, SaveHotkeys, 150

        IniRead, d_sp, %settingsFile%, Preset, Delay1
        IniRead, d_1, %settingsFile%, Preset, Delay2
        IniRead, d_2, %settingsFile%, Preset, Delay3
        
        Gui, ViMeLlY:Font, s6, Comic Sans MS
        Gui, ViMeLlY:Add, Edit, x17 y+1 w125 vMySetup_sp, %d_sp%
        Gui, ViMeLlY:Add, Edit, x142 yp w120 vMySetup_d1, %d_1%
        Gui, ViMeLlY:Add, Edit, x262 yp w135 vMySetup_d2, %d_2%
    } else {
        SetTimer, SaveHotkeys, Off
    }
    Gui, ViMeLlY:Font, s7, Comic Sans MS
    Gui, ViMeLlY:Add, Button, x17 y+1 w20 vadminStatsButton gToggleAdminStats, %adminStatsSwitch%
    Gui, ViMeLlY:Add, Button, x+1 yp w360 gAdminStatsPanel, Статистика администратора
    Gui, ViMeLlY:Add, Picture, x17 y+1 w380 h190, %A_Temp%\ViMeLlYScript_%randomLogo%.png
    Gui, ViMeLlY:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Link, x45 y+7, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    Gui, ViMeLlY:Show
    WinSet, Transparent, 233, A
Return

;=================================================================================================================================================
;=================================================================================================================================================

;=================================================================================================================================================

;====================================================
;=============== ДЕЙСТВИЯ КНОПОК МЕНЮ ===============
;====================================================

;=================================================================================================================================================

; === Настройки клавиш
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
    IniRead, emergencyDeleteKey, %settingsFile%, Keys, EmergencyDelete

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYHotKeys:New,, ViMeLlY Script
    Gui, ViMeLlYHotKeys:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYHotKeys:Color, % guiColor
    Gui, ViMeLlYHotKeys:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, w400 Center, ViMeLlY Script
    Gui, ViMeLlYHotKeys:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Button, yp x320 gReload,⟲
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gResetHotkeys,🗑️
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYHotKeys:Add, Text, y+1 xm w400 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Назначение клавиш ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧

    Gui, ViMeLlYHotKeys:Font, s8, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🔗｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w115 Center, Меню
    Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Menu x185 yp h18 w100, %menuKey%
    Gui, ViMeLlYHotKeys:Add, Text, yp vHK_MenuText x+10 w130, % "‖ " .  ReadableHotkey(menuKey)

    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center, ° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °

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

    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center, ° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
    
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
    
    
    Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📍｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Автоэдит
    Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_autoEdit x185 yp h18 +0x200 w100, %autoEditKey%
    Gui, ViMeLlYHotKeys:Add, Text, yp vHK_autoEditText x+10 w130, % "‖ " .  ReadableHotkey(autoEditKey)

    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center, ° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
    
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

; === Настройки ответов
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
    Gui, ViMeLlYAnswers:Add, Button, yp x+1 gResetAnswers,🗑️
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
    IniRead, AUser, %settingsFile%, Preset, AUser
    IniRead, totalAns, %settingsFile%, %AUser%, totalAns
    IniRead, totalJails, %settingsFile%, %AUser%, totalJails
    adminName := Base64Decode(AUser)
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
    
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,ℹ️ Изменения за 3 дн
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ # Значения:

    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Мин. » PM: %minAns% | J: %minJails%
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ - Ответов: %totalAns%

    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Макс. » PM: %maxAns% | J: %maxJails%
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ - Jail'ов: %totalJails%
    
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Среднее » PM: %avgAns% | J: %avgJails%
    Gui, ViMeLlYStats:Add, Text, x+5 yp w160,‖ ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
    
    Gui, ViMeLlYStats:Add, Text, x25 y+1 w200,༝Разница с вчерашним днём ⤵︎
    Gui, ViMeLlYStats:Add, Edit, x+6 yp h18 w29 vSearchDay Center, %A_DD%
    Gui, ViMeLlYStats:Add, Edit, x+1 yp h18 w30 vSearchMonth Center, %A_MM%
    Gui, ViMeLlYStats:Add, Edit, x+1 yp h18 w61 vSearchYear Center, %A_YYYY%
    Gui, ViMeLlYStats:Add, Button, x+1 yp h18 w20 gSearchStatsByDate,⤵︎
    
    Gui, ViMeLlYStats:Add, Text, x27 y+1 w200,- PM: %changeAns%
    Gui, ViMeLlYStats:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResult, Пусто

    Gui, ViMeLlYStats:Add, Text, x27 y+1 w200,- Jail'ов: %changeJails%
    Gui, ViMeLlYStats:Add, Button, x+3 yp h18 w145 gClearAnswers, Сбросить статистику
    
    Gui, ViMeLlYStats:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYStats:Add, Link, x45 y+7, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    if (AUser != "ERROR" && AUser != "") {
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

; === Изменение показателя за последний день относительно N дней назад
; === type: "percent" (в процентах) или "delta" (разница)
GetChange(metric, lookback := 1, type := "percent") {
    global statisticFile
    days := []

    ; Секции (даты)
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

    ; Берём последний день и тот, что lookback дней назад
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

SearchStatsByDate:
    Gui, ViMeLlYStats:Submit, NoHide
    searchDate := SearchDay "." SearchMonth "." SearchYear

    IniRead, ansByDate, %statisticFile%, %searchDate%, totalAns
    IniRead, jailsByDate, %statisticFile%, %searchDate%, totalJails

    if ((ansByDate != "ERROR" && ansByDate != "") && (jailsByDate != "ERROR" && jailsByDate != "")) {
        GuiControl,, SearchResult, PM: %ansByDate% | J: %jailsByDate%
    } else {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] По Вашему запросу ничего не найдено.
        Sleep, 2332
        ToolTip
    }
Return

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


; === Перезагрузка скрипта
Reload:
    Reload
Return

Stop:
    Process, Close, %pid%
    ExitApp
Return

; === Сброс настроек клавиш
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
    IniWrite, %A_Space%, %settingsFile%, Keys, EmergencyDelete

    Gosub, Hotkeys
Return
; === Сброс ответов
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

; === Вернуться назад
Back:
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYStats:Destroy
    Gui, ViMeLlY:Show
Return

; === Закрытие менюшек и перезапуск скрипта
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
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл авто-выдачи не создан`, так как функция отключена.
        Sleep, 2000
        ToolTip
    }
Return

OpenPunishHelper:
    if (punishHelperStatus) {
        Run, notepad %punishFile%
    } else {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл помощника наказаний не создан`, так как функция отключена.
        Sleep, 2000
        ToolTip
    }
Return

OpenAdditionalFeatures:
    if (additionalFeaturesStatus) {
        Run, notepad %additionalFeaturesFile%
    } else {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл доп. скрипта не создан`, так как функция отключена.
        Sleep, 2000
        ToolTip
    }
Return

; === Переключение режима автослежки
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

; === Включение/Выключение лога вопросов
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

; === Включение/Выключение авто-выдачи
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

; === Включение/Выключение помощника наказаний
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

; ==== Проверка на бинд ====
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

; === Сохранение горячих клавиш
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
    hotkeys["EmergencyDelete"] := HK_EmergencyDelete

    IniWrite, %HK_Menu%, %settingsFile%, Keys, Menu
    IniWrite, %HK_Watch%, %settingsFile%, Keys, Watch
    IniWrite, %HK_Reply%, %settingsFile%, Keys, Reply
    IniWrite, %HK_Request%, %settingsFile%, Keys, Request
    IniWrite, %HK_humanReply%, %settingsFile%, Keys, humanReply
    IniWrite, %HK_CopyAChat%, %settingsFile%, Keys, CopyAChat
    IniWrite, %HK_AdminStats%, %settingsFile%, Keys, AdminStats
    IniWrite, %HK_autoIssue%, %settingsFile%, Keys, autoIssue
    IniWrite, %HK_autoEdit%, %settingsFile%, Keys, autoEdit
    IniWrite, %HK_EmergencyDelete%, %settingsFile%, Keys, EmergencyDelete

    GuiControl, ViMeLlYHotKeys:, HK_MenuText, % (HK_Menu) ? "‖ " . ReadableHotkey(HK_Menu) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_WatchText, % (HK_Watch) ? "‖ " . ReadableHotkey(HK_Watch) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_ReplyText, % (HK_Reply) ? "‖ " . ReadableHotkey(HK_Reply) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_RequestText, % (HK_Request) ? "‖ " . ReadableHotkey(HK_Request) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_humanReplyText, % (HK_humanReply) ? "‖ " . ReadableHotkey(HK_humanReply) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_CopyAChatText, % (HK_CopyAChat) ? "‖ " . ReadableHotkey(HK_CopyAChat) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_AdminStatsText, % (HK_AdminStats) ? "‖ " . ReadableHotkey(HK_AdminStats) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_autoIssueText, % (HK_autoIssue) ? "‖ " . ReadableHotkey(HK_autoIssue) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_autoEditText, % (HK_autoEdit) ? "‖ " . ReadableHotkey(HK_autoEdit) : "‖ Клавиша не назначена"
    GuiControl, ViMeLlYHotKeys:, HK_EmergencyDeleteText, % (HK_EmergencyDelete) ? "‖ " . ReadableHotkey(HK_EmergencyDelete) : "‖ Клавиша не назначена"

    IniWrite, %isHumanInput%, %settingsFile%, Preset, isHumanInput
    IniWrite, %reportLog%, %settingsFile%, Preset, reportLog
    IniWrite, %currentSetup%, %settingsFile%, Preset, currentSetup

    if (currentSetup == "Настраиваемый") {
        if (MySetup_sp != "")
            IniWrite, %MySetup_sp%, %settingsFile%, Preset, Delay1
        if (MySetup_d1 != "")
            IniWrite, %MySetup_d1%, %settingsFile%, Preset, Delay2
        if (MySetup_d2 != "")
            IniWrite, %MySetup_d2%, %settingsFile%, Preset, Delay3
    }
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

; === Обнулить статистику
ClearAnswers: ; Удаление нормы (обработанные строки не удаляются, чтобы не считались заново)
    IniRead, AUser, %settingsFile%, Preset, AUser ; Получаем Nick_Name администратора
    IniRead, savedDate, %settingsFile%, %AUser%, Date ; Получаем сохраненную дату
    IniRead, totalAns, %settingsFile%, %AUser%, totalAns ; Получаем сохраненные /pm | /ans
    IniRead, totalJails, %settingsFile%, %AUser%, totalJails ; Получаем сохраненные /jail | /offjail | /unjail
    Sleep, 333
    if (AUser != "" && AUser != "ERROR") { ; Если ник администратора определён
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Сбрасываю статистику...
        IniWrite, %totalAns%, %statisticFile%, %savedDate%, totalAns
        IniWrite, %totalJails%, %statisticFile%, %savedDate%, totalJails
        
        IniWrite, %today%, %settingsFile%, %AUser%, Date
        IniWrite, 0, %settingsFile%, %AUser%, totalAns
        IniWrite, 0, %settingsFile%, %AUser%, totalJails
        IniDelete, %settingsFile%, ProcessedLines
        Sleep, 333
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Дата предыдущей статистики: %savedDate% | Текущая: %today%`n↪︎ Ваша статистика сброшена.
        Sleep, 1771
        ToolTip
    }
Return

; ==== Метки для сетапов ====
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

;=================================================================================================================================================
;=================================================================================================================================================

;=================================================================================================================================================

;========================================================
;=============== НАЗНАЧЕНИЕ КЛАВИШ ======================
;========================================================

;=================================================================================================================================================

; === Загрузка горячих клавиш
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
    hotkeys["EmergencyDelete"] := (hkEmergencyDelete == "ERROR") ? "" : (hkEmergencyDelete == "" ? "" : hkEmergencyDelete)
}

; === Бинд/Применение горячих клавиш
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

;=================================================================================================================================================
;=================================================================================================================================================

;=================================================================================================================================================

;============================================
;=============== ФУНКЦИИ ====================
;============================================

;=================================================================================================================================================

; === Ответ в начале слежки
WatchKeys() {
    global repID
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") {
            spTimersOff()

            SendMessage, 0x50,, 0x4190419,, A
            sendReply(repID, getAnswer("Spectate")) ; Отправка ответа
            SetTimer, WatchSpectate, 30
        }
    }
}

; === Ответ в конце слежки
WatchSpectate() {
    global repID
    if (hotkeys["Reply"] != "") {
        Loop, 10 {
            key := A_Index = 10 ? "0" : A_Index
            if GetKeyState(hotkeys["Reply"], "P") && GetKeyState(key, "P") {
                spTimersOff()

                SendMessage, 0x50,, 0x4190419,, A
                sendReply(repID, getAnswer("Ans" . key)) ; Отправка ответа
                break
            }
        }
    }
}

; ==== Общая функция выбора сетапа ====
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

; === Детект чат лога
FindChatlogPath() {
    docPath := A_MyDocuments
    targetPath := docPath . "\RADMIR CRMP User Files\SAMP\chatlog.txt"
    ; targetPath := A_ScriptDir . "\chatlog.txt"
    if FileExist(targetPath) {
        return targetPath
    } else {
        MsgBox, [𝐒𝐂𝐑𝐈𝐏𝐓] Файл chatlog.txt не найден по пути:`n↪︎ %targetPath%
        return ""
    }
}

; === Ответ /pm
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

; === Визуал для меню скрипта
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
        return "Клавиша не назначена"
    } return full
}

Join(delim, arr*) {
    out := ""
    for i, val in arr
        out .= (i > 1 ? delim : "") . val
    return out
}

; === Сохранение обработанных строк для счётчика
HashLine(str) {
    hash := 0
    Loop, Parse, str
        hash := Mod(hash * 31 + Asc(A_LoopField), 1000000007)
    return hash
}

checkChatLog() {
	Loop, Read, %filePath%
	{
		LineNumber++
	}
	return LineNumber
}

Base64Encode(str) {
    VarSetCapacity(bin, StrPut(str, "UTF-8"))
    len := StrPut(str, &bin, "UTF-8") - 1

    ; Получаем размер буфера
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

; === Получение ответа из Конфига
getAnswer(val) {
    IniRead, result, %settingsFile%, Answers, %val%
    Return result
}

; === Детект имени администратора
FindNick(pattern) {
    Loop, Read, %filePath%
        if RegExMatch(A_LoopReadLine, pattern, m)
            return m1
    return ""
}
getAdminName() {
    Random, rNumber, 300, 1400
    SendInput, {F6}/a %rNumber%{Enter}
    Sleep, 430
    lastLine := FindNick(".*\[A\] (\w+_\w+)\[(\d+)\]: " . rNumber)
    if (lastLine = "") {
        SendInput, {F6}{!}%rNumber%{Enter}
        Sleep, 430
        lastLine := FindNick("\{v:(\w+_\w+)\}\[\d+\]: " . rNumber)
    } if (lastLine != "") {
        AUser := Base64Encode(lastLine)
        IniWrite, %AUser%, %settingsFile%, Preset, AUser
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] ✔ Ваш Nickname идентифицирован как: %lastLine%.
        Sleep, 2332
        ToolTip
    }
}

; === Показ подсказки при обнаружении Вопроса/Матерного слова/Оскорбления в /report
ShowTip(author, id, text, key, type, reply) {
    if (type == "Вопрос") {
        prefix := "[𝐐𝐔𝐄𝐒𝐓𝐈𝐎𝐍]"
        answer := "`n`n[𝐀𝐍𝐒𝐖𝐄𝐑] " . reply
    } else if (type = "МАТ") {
        prefix := "[𝐌𝐀𝐓]"
    }
    else if (type = "ОСК") {
        prefix := "[𝐎𝐒𝐊]"
    }
    ToolTip, %prefix% %author%[%id%]: %text% `n↪︎ Чтобы отреагировать ▸ %key% + Enter %answer%
    Sleep, 7777
    ToolTip
    logTimersOff() ; Отключение возможности ответа, когда пропадает подсказка
}

; === Счетчик нормы
CountAdminActions() {
    global adminAns, adminJails, today
    adminName := Base64Decode(AUser)
    Loop, Read, %filePath%
    {
        line := A_LoopReadLine
        if RegExMatch(line, "^\[(\d{2}):(\d{2}):(\d{2})\]", t) {
            lineTime := t1 * 3600 + t2 * 60 + t3
            currentTime := A_Hour * 3600 + A_Min * 60 + A_Sec
            currentDate := A_DD . "." . A_MM . "." . A_YYYY
            if (lineTime > currentTime) ; === Счет с 00:00 до текущего времени
                continue
            if (currentDate != today) {
                GoSub, ClearAnswers
            }
        }
        ; === Счет /pm
        if RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? для (\w+(?:_\w+)*)\[(\d+)\]:") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            if (seen == "ERROR") {
                IniRead, totalAns, %settingsFile%, %AUser%, totalAns
                totalAns++
                IniWrite, %totalAns%, %settingsFile%, %AUser%, totalAns

                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        }
        ; === Счёт /jail
        if RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? посадил в тюрьму игрока (\w+(?:_\w+)*)")
            || RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? оффлайн посадил в тюрьму игрока (\w+(?:_\w+)*)") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            if (seen == "ERROR") {
                IniRead, totalJails, %settingsFile%, %AUser%, totalJails
                totalJails++
                IniWrite, %totalJails%, %settingsFile%, %AUser%, totalJails

                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        }
        ; === Счет /unjail
        if RegExMatch(line, adminName . "(?:\[(\d+)\])? выпустил игрока (\w+(?:_\w+)*)\[(\d+)\] из тюрьмы") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            if (seen == "ERROR") {
                IniRead, totalJails, %settingsFile%, %AUser%, totalJails
                totalJails--
                IniWrite, %totalJails%, %settingsFile%, %AUser%, totalJails

                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        }
    }
}

; === Перевод латинских символов в русские
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
            if (m2 == playerId) { ; Если введенный ID совпадает с найденным
                playerName := m1 ; Nick_Name игрока
                playerDetectId := m2 ; ID игрока
                playerLvl := m3 ; Lvl игрока
            } else { ; Если введенный ID не совпадает с найденным
                playerName := m1 ; Nick_Name игрока
                playerDetectId := m2 ; ID игрока
            }
        } if RegExMatch(A_LoopReadLine, "(\w+_\w+)(?:\[(\d+)\]?), ID: (\d+), уровень: (\d+)", m) {
            if (m3 == playerId) { ; Если введенный ID совпадает с найденным
                playerName := m1 ; Nick_Name игрока
                playerDetectId := m3 ; ID игрока
                playerLvl := m4 ; Lvl игрока
            } else { ; Если введенный ID не совпадает с найденным
                playerName := m1 ; Nick_Name игрока
                playerDetectId := m3 ; ID игрока
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
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Игрок %playerName%[%playerId%] определён. Уровень: %playerLvl%.`n↪︎ Выдаю: %cmd% %playerId% %duration% %reason%
        SendInput, {F6}%cmd% %playerId% %duration% %reason%{Enter}
        Sleep, 2332
        ToolTip
    } else {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Введенный ID: %playerId%. Определенный игрок: %playerName%[%playerDetectId%]`n↪︎ Выдача наказания приостановлена.
        Sleep, 2332
        ToolTip
    }
}

; === Проверка на то, запущена ли GTA
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

;=================================================================================================================================================

;===============================================================
;=============== ПОМОЩНИК РАБОТЫ ПО /report ====================
;===============================================================

;=================================================================================================================================================

; === Ручной ответ /pm
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
        ToolTip, ℹ️ ID не найдено.
        Sleep, 300
        ToolTip
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

; === Активация автослежки
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
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] ℹ️ ID не найдено.
        Sleep, 300
        ToolTip
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
                foundAdmin := (match1 != Base64Decode(AUser))
                ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] За игроком с ID %specID% уже следит другой администратор...
                Sleep, 300
                ToolTip
                break
            } if RegExMatch(A_LoopReadLine, "\* За этим игроком уже следит администратор (\w+_\w+)", match) {
                foundAdmin := (match1 != Base64Decode(AUser))
                break
            }
        }
    } if (!foundAdmin) {
        SetTimer, WatchKeys, 30
    } if (!AUser || AUser == "ERROR") {
        getAdminName()
    }
}

; === Авто-запрос
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
    } if (lastLine != "") {
        SendInput, {F6}%lastLine%
    }
Return

; === Статистика админа
AdminStats:
    IniRead, totalAns, %settingsFile%, %AUser%, totalAns
    IniRead, totalJails, %settingsFile%, %AUser%, totalJails
    if ((totalAns != "ERROR" && totalJails != "ERROR") && (AUser != "" || AUser != "ERROR")) {
        adminName := Base64Decode(AUser)
        ToolTip, ★ Администратор %adminName% ⤵︎`n- ✉ Ответов: %totalAns% (/pm)`n- ⚖ Jail'ов: %totalJails% (/jail)
        Sleep, 3000
        ToolTip
    } else if (AUser = "" || AUser = "ERROR") {
        ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] ⚠️ Не удалось получить статистику`, ник администратора не определён.
        Sleep, 3000
        Reload
    }
Return

; === Помощник выдачи наказаний
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
            ; Добавляем хотстринг для русской раскладки
            ruCmdKey := TransliterateToRussian(cmdKey)
            if (ruCmdKey != cmdKey) {
                Hotstring(":*?:" . ruCmdKey . " ", Func("DynamicPunish").Bind(cmdKey))
            }
        }
    }
}

; === Детект Вопросов/Матерных слов/Оскорблений в /report | Жалоб от других админов в /a
answerLogger() {
    IniRead, kR, %settingsFile%, Keys, Reply
    global adminName, targetID, targetPunish
    targetPunish := ""
    LineNumber := 0
    ; === Ответы по ключевым словам ===
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
    ; === Матерные слова ===
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
            ; === Обработка ответов по ключевым словам ===
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
                ; === Обработка оскорблений ===
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
                ; === Обработка матерных слов ===
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
                ToolTip
            }
            lastLineNum := LineNumber
        }
    }
    lastLineNum := LineNumber
}

; === Ответ на вопрос
respondComplaint() {
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P") {
            logTimersOff() ; Выключение всех других таймеров
            Sleep, 100
            global playerId

            SendMessage, 0x50,, 0x4190419,, A
            sendReply(playerId, answerComplaint)
            ToolTip, [𝐑𝐄𝐏𝐋𝐘] Игроку был дан ответ.
            Sleep, 3300
            ToolTip
        }
    }
}

; === Наказание игрока
respondCommand() {
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P") {
            logTimersOff() ; Выключение всех других таймеров
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
            ToolTip, [𝐏𝐔𝐍𝐈𝐒𝐇𝐌𝐄𝐍𝐓] Игрок был наказан.
            Sleep, 3300
            ToolTip
        }
    }
}

issueAChatPunishment() {
    global adminName, targetID, targetPunish
    ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] ✎ Выдать %targetPunish%?

    if hotkeys["Reply"] != "" {
        if (GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P")) {
            SetTimer, issueAChatPunishment, Off

            logTimersOff() ; Выключение всех других таймеров
            spTimersOff() ; Выключение всех других таймеров

            SendMessage, 0x50,, 0x4190419,, A
            SendInput, {F6}%targetPunish%{Enter}
            Sleep, 2000
            ToolTip
        }
    }
}

; === Авто-выдача
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
            ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Ввожу команду: %cmdLine%
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
                    ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: %cmdLine%`n↪️ Игрок %nickName% находится на сервере. Исключаю игрока...
                    SendMessage, 0x50,, 0x4190419,, A
                    SendInput, ^a {BackSpace}{Enter}
                    SendInput, {F6}/kick %nickName% Ожидайте наказания.{Enter}
                    Sleep, delay
                    ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: %cmdLine%`n↪️ Игрок %nickName% исключен. Выдаю наказание повторно...
                    SendInput, ^a {BackSpace}{Enter}
                    SendInput, {F6}%cmdLine%{Enter}
                    autoIssueLastLineNum := LineNumber ; Записывает номер строки, чтобы не читать заново
                    Sleep, delay
                    Loop, Read, %filePath%
                    {
                        LineNumber++
                        if (LineNumber <= autoIssueLastLineNum)
                            continue
                        line := A_LoopReadLine
                        if (InStr(line, "Этот игрок уже находится в тюрьме") && !processedLines.HasKey(HashLine(line))  && (cmdType = "/jail" || cmdType = "/offjail" || cmdType = "/kjail")) {
                            processedLines[HashLine(line)] := true
                            ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: %cmdLine%`n↪️ Игрок %nickName% уже в тюрьме. Получаю оставшееся время игрока...
                            SendMessage, 0x50,, 0x4190419,, A
                            SendInput, ^a {BackSpace}{Enter}
                            SendInput, {F6}/time %nickName%{Enter}
                            autoIssueLastLineNum := LineNumber ; Записывает номер строки, чтобы не читать заново
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
                                    ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Время до выхода на свободу %nickName%: %pTime1% сек. Добавляю это время к текущей выдаче...
                                    issueTime := issueTime + pTime1
                                    issueReason := issueReason . "(перевыдано)"
                                    Sleep, delay
                                    SendMessage, 0x50,, 0x4190419,, A
                                    SendInput, ^a {BackSpace}{Enter}
                                    SendInput, {F6}%cmdType% %nickName% %issueTime% %issueReason%{Enter}
                                    ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Наказание успешно выдано.
                                    break
                                }
                            }
                            break
                        }
                    }
                    break
                } if (InStr(line, "Этот игрок уже находится в тюрьме") && !processedLines.HasKey(HashLine(line)) && (cmdType = "/jail" || cmdType = "/offjail" || cmdType = "/kjail")) {
                    processedLines[HashLine(line)] := true
                    ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Введена команда: %cmdLine%`n↪️ Игрок %nickName% уже в тюрьме. Получаю оставшееся время игрока...
                    SendInput, ^a {BackSpace}{Enter}
                    SendInput, {F6}/time %nickName%{Enter}
                    autoIssueLastLineNum := LineNumber ; Записывает номер строки, чтобы не читать заново
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
                            ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Время до выхода на свободу %nickName%: %pTime1% сек. Добавляю это время к текущей выдаче...
                            issueTime := issueTime + pTime1
                            issueReason := issueReason . "(перевыдано)"
                            Sleep, delay
                            SendInput, ^a {BackSpace}{Enter}
                            SendInput, {F6}%cmdType% %nickName% %issueTime% %issueReason%{Enter}
                            ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Наказание успешно выдано.
                            break
                        }
                    }
                    break
                } if (InStr(line, "У этого игрока уже есть блокировка") && !processedLines.HasKey(HashLine(line))) {
                    processedLines[HashLine(line)] := true
                    if ((cmdType = "/mute" || cmdType = "/rmute" || cmdType = "/fmute")) {
                        ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] У игрока %nickName% уже есть блокировка чата. Получаю оставшееся время...
                        SendInput, ^a {BackSpace}{Enter}
                        SendInput, {F6}/time %nickName%{Enter}
                        autoIssueLastLineNum := LineNumber ; Записывает номер строки, чтобы не читать заново
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
                                ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Оставшееся время затычки %nickName%: %pTime1% сек. Добавляю это время к текущей выдаче...
                                issueTime := issueTime + pTime1
                                issueReason := issueReason . "(перевыдано)"
                                Sleep, delay
                                SendInput, ^a {BackSpace}{Enter}
                                SendInput, {F6}%cmdType% %nickName% %issueTime% %issueReason%{Enter}
                                ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Наказание успешно выдано.
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
                ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Достигнут лимит для %cmdType%. Ожидаю %fwait% секунд...
                Sleep, 3300
                ToolTip
                issuedCommands := 0
                Sleep, %wait%
            }
            ToolTip
        }
    }
    if (total) {
        ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Все команды введены
        text := "# Тут можно вставить список наказаний, которые нужно выдать в игре. `n# Пример: /offjail Nick_Name 120 Жалоба на игрока 1`n`n"
        FileDelete, %autoIssueFile%
        FileAppend, %text%, %autoIssueFile%, UTF-8
        Sleep, 3300
        ToolTip
    } else {
        ToolTip, [𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Файл пустой или не найден.
        Sleep, 3300
        ToolTip
    }
}

autoEdit:
    if (!active) {
		lastReadLine := checkChatLog()
		active := true
		SetTimer, autoEditFunc, 50
		ToolTip, [𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoEdit включена. Ожидание нового объявления...
        Sleep, 2332
        ToolTip
	} else {
		SetTimer, autoEditFunc, Off
		active := false
		ToolTip
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
			ToolTip
			lastReadLine := LineNumber
			Break
		}
	}
}

;=================================================================================================================================================

!^Esc::
    Process, Close, %pid%
    ExitApp
Return