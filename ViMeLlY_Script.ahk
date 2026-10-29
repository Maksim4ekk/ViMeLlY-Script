#SingleInstance, Force
#Persistent
#NoEnv
#NoTrayIcon

SetTitleMatchMode, 2
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

global version := "v 1.7.1"
global LicenseURL := "aHR0cHM6Ly9naXN0LmdpdGh1YnVzZXJjb250ZW50LmNvbS9NYWtzaW00ZWtrL2Jl`nMmQ0MjE5MzE1NjFkZDAxYjQzM2Y5M2NhNTMyOWQwL3Jhdy9WaU1lTGxZLWtleXMu`ndHh0"


global repID, ansID, ansLogID
global hotkeys := {}
global previousHotkeys := {}
global punishMap := {}
global currentCmdKey := ""
global ChatIsOpen := false
global isHumanInput, reportLog, punishHelperStatus, lastRequest, additionalFeaturesStatus, adminStatsStatus
global autoEditActive := false
global autoBizlistActive := false
global currentSetup, CMDDelay, InputDelay1, InputDelay2, userNickname, guiColor, scriptType
global scriptDir := A_MyDocuments . "\ViMeLlY Script\"
global settingsFile := scriptDir . "settings.ini"
global punishFile := scriptDir . "punish.txt"
global additionalFeaturesFile := scriptDir . "ViMeLlY-Features.ahk"
global statisticFile := scriptDir . "statistic.ini"
global scriptVersion := A_Temp . "\ViMeLlYScript.ver"
global answerRulesFile := scriptDir . "answer-rules.txt"
global answerMap := {}
global answerRulesLoaded := false
global automationQueue := []
global automationBusy := false
global automationLastSent := 0
global answerComplaint, answerCommand, responses
global filePath := FindChatlogPath()
global lastReadLine := checkChatLog()
global lastLineNum
; Request: состояние своей последней /z, чтобы не править посторонние команды.
global requestBusy := false
global requestLastSent := ""
global requestCanRecall := false
global truckerSettings := false
global scriptSettings := false
global isToolTipActive
global today := A_DD . "." . A_MM . "." . A_YYYY
global menuNavItems := []
global menuNavIndex := 0
global menuNavGuiName := ""
global menuNavGuiHwnd := 0
OnMessage(0x21, "MenuMouseActivate") ; кнопки не активируют меню, поля ввода могут получить фокус

; Инициализация выполняется один раз, НЕ зависит от GitHub или обновлений.
SetTimer, InitializeViMeLlY, -50

IniRead, scriptModeStatus, %settingsFile%, Preset, scriptMode
global scriptMode := scriptModeStatus

IniRead, userNickname, %settingsFile%, Preset, userNickname
IniRead, rL, %settingsFile%, Preset, reportLog
IniRead, pH, %settingsFile%, Preset, punishHelperStatus
IniRead, aF, %settingsFile%, Preset, additionalFeaturesStatus
IniRead, aS, %settingsFile%, Preset, adminStatsStatus
IniRead, isToolTipActive, %settingsFile%, Preset, isToolTipActive, 1
; Значение режима необходимо загрузить ДО построения GUI и обработки хоткеев.
IniRead, isHumanInput, %settingsFile%, Preset, isHumanInput, 0
isHumanInput := (isHumanInput = 1) ? 1 : 0

ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Инициализация скрипта...", 300)

reportLog := (rL = "1") ? 1 : 0
punishHelperStatus := (pH = "1") ? 1 : 0
additionalFeaturesStatus := (aF = "1") ? 1 : 0
adminStatsStatus := (aS = "1") ? 1 : 0

; Фонові модулі запускає InitializeViMeLlY після перевірки налаштувань.
; У цьому блоці навмисно немає таймерів чи запуску дочірніх процесів.

Sleep, 300
ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ViMeLlY Script (" . version . ") загружен. Приятного пользования!", 777)

Stub:
Return

; ДИАГНОСТИКА: Ctrl+Shift+F10 — состояние репортов. Ничего не отправляет серверу.
^+F10::
    ReportDiagnostics()
Return

; ============================================================================================================================
; ============================================================================================================================
; #region || ПРОВЕРКА ЛИЦЕНЗИИ
; ============================================================================================================================

global CurrentHWID := ""
global EnteredKey  := ""

; === InitializeViMeLlY: единоразовый запуск независимо от автообновления ===
InitializeViMeLlY() {
    global scriptMode, scriptType, isHumanInput, reportLog, additionalFeaturesStatus
    global additionalFeaturesFile, pid, settingsFile
    global punishHelperStatus, punishFile
    ; Не выполнять повторную проверку Gist каждые 500 миллисекунд.
    scriptSettingsChecker()
    IniRead, savedScriptMode, %settingsFile%, Preset, scriptMode, %scriptType%
    scriptMode := (savedScriptMode = "Admin" || savedScriptMode = "Player") ? savedScriptMode : scriptType
    IniRead, inputMode, %settingsFile%, Preset, isHumanInput, 0
    isHumanInput := (inputMode = 1) ? 1 : 0

    ; Подгрузить карту ответов ПОСЛЕ создания каталога и файла конфигурации.
    LoadAnswerRules()
    ChatlogWatchFromNow("reports")
    ChatlogWatchFromNow("profit")
    LoadHotkeys()
    BindHotkeys()
    if (scriptMode = "Admin") {
        if (reportLog)
            SetTimer, answerLogger, 500
        adminsStatistics()
        SetTimer, adminsStatistics, 60000
        SetTimer, CountAdminActions, 500
        if (punishHelperStatus && FileExist(punishFile))
            SetTimer, punishHelper, -1500
    } else if (scriptMode = "Player") {
        SetTimer, ExpectationOfProfit, 333
    }
    if (additionalFeaturesStatus && FileExist(additionalFeaturesFile))
        Run, %additionalFeaturesFile%, , , pid
    ; Отдельный одноразовый таймер: отказ GitHub никак не блокирует интерфейс/бинды.
    SetTimer, checkUpdates, -1200
}

; === GetHWID: служебная функция ===
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

; === checkLicenseKey: проверка ключа через Gist ===
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
    
    ; Лицензия Gist: сертификат обязателен, отсутствие сети != неверный ключ.
    RawKeys := SecureHttpText(license)
    if (RawKeys = "") {
        MsgBox, 16, Ошибка сети, Сервер лицензий недоступен или TLS не прошёл проверку.`nПроверьте интернет и системное время. Ключ не удалён.
        ExitApp
    }
    IsValid := false
    scriptType := ""
    Loop, Parse, RawKeys, `n, `r
    {
        CurrentLine := Trim(A_LoopField)
        if (CurrentLine = "" || SubStr(CurrentLine, 1, 1) = "#")
            continue
        Parts := StrSplit(CurrentLine, [":", "="])
        if (Parts.Length() < 3)
            continue
        candidate := Trim(Parts[1])
        candidateType := Trim(Parts[2])
        HwidFromList := Trim(Parts[3])
        if (candidate = SavedKey && HwidFromList == CurrentHWID && (candidateType == "Admin" || candidateType == "Player")) {
            IsValid := true
            userNickname := Trim(Base64Encode(candidate), " `t`r`n")
            scriptType := candidateType
            break
        }
    }
    if (IsValid) {
        IniWrite, %SavedKey%, %settingsFile%, License, Key
        IniWrite, %scriptType%, %settingsFile%, Preset, scriptMode
        IniRead, storedMode, %settingsFile%, Preset, scriptMode, %A_Space%
        storedMode := Trim(storedMode)
        if (storedMode != "" && storedMode != scriptType) {
            MsgBox, 16, Ошибка лицензии, Указанный режим не соответствует ключу.`nПроверьте настройки с разработчиком.
            ExitApp
        }
    } else {
        ; Нет циклического Reload и очистки файла настроек при проблемах активации.
        MsgBox, 16, Ошибка активации, Ключ или HWID отсутствует в списке лицензий.
        ExitApp
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

; ============================================================================================================================
; #region || БЕЗОПАСНОЕ ОБНОВЛЕНИЕ (только скомпилированный EXE)
; Ошибка сети не блокирует запуск. Установка требует подтверждения.
; === checkUpdates: обновление только EXE ===
checkUpdates() {
    global scriptVersion, version, settingsFile, scriptMode, scriptDir
    remoteVersionUrl := "https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlYScript.ver"
    remoteExeUrl := "https://raw.githubusercontent.com/Maksim4ekk/ViMeLlY-Script/refs/heads/main/ViMeLlY_Script.exe"
    text := SecureHttpText(remoteVersionUrl)
    serverVersion := LTrim(Trim(text, " `t`r`n"), Chr(0xFEFF))
    if (text = "") {
        FileAppend, %A_Now% | Version check failed: cannot reach GitHub (or TLS error).`r`n, %scriptDir%updater.log, UTF-8
        return false
    }
    FileAppend, % A_Now . " | local=" . version . " remote=" . serverVersion . "`r`n", %scriptDir%updater.log, UTF-8
    if (!RegExMatch(serverVersion, "i)^v?\s*\d+\.\d+\.\d+$")) {
        FileAppend, %A_Now% | Invalid .ver format; update skipped.`r`n, %scriptDir%updater.log, UTF-8
        return false
    }
    if (VersionNewer(serverVersion, version)) {
        if (!A_IsCompiled) {
            MsgBox, 64, ViMeLlY Script, % "Найдена версия " . serverVersion . ". Обновления EXE отключены для исходного .ahk."
        } else {
            MsgBox, 36, ViMeLlY Script, % "Доступна новая версия " . serverVersion . ". Загрузить и установить после закрытия скрипта?`nФайл settings.ini не будет удалён."
            IfMsgBox, Yes
                SecureInstallUpdate(remoteExeUrl)
        }
    }

    ; Проверка обновлений никак не управляет запуском игры или хоткеев.
    return
}

; Строгая HTTPS-проверка сертификата. Никаких WinHttpRequestOption_SslErrorIgnoreFlags.
; === SecureHttpText: служебная функция ===
SecureHttpText(url) {
    if (!RegExMatch(url, "i)^https://"))
        return ""
    try {
        req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        req.Option(9) := 2048
        req.SetTimeouts(4000, 4000, 4000, 6000)
        req.Open("GET", url . "?t=" . A_NowUTC, false)
        req.SetRequestHeader("User-Agent", "ViMeLlY-Script")
        req.Send()
        if (req.Status == 200)
            return req.ResponseText
    } catch e {
        return ""
    }
    return ""
}

; === VersionNewer: служебная функция ===
VersionNewer(remote, local) {
    remote := RegExReplace(remote, "i)^v\s*")
    local := RegExReplace(local, "i)^v\s*")
    a := StrSplit(remote, ".")
    b := StrSplit(local, ".")
    if (a.Length() != 3 || b.Length() != 3)
        return false
    Loop, 3 {
        if ((a[A_Index] + 0) > (b[A_Index] + 0))
            return true
        if ((a[A_Index] + 0) < (b[A_Index] + 0))
            return false
    }
    return false
}

; === SecureInstallUpdate: служебная функция ===
SecureInstallUpdate(url) {
    if (!A_IsCompiled || !RegExMatch(url, "i)^https://"))
        return false
    target := A_ScriptFullPath
    download := A_Temp . "\ViMeLlY_Update_" . A_TickCount . ".exe"
    helper := A_Temp . "\ViMeLlY_Update_" . A_TickCount . ".ps1"
    backup := target . ".bak"
    try {
        req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        req.Option(9) := 2048
        req.SetTimeouts(5000, 5000, 12000, 15000)
        req.Open("GET", url, false)
        req.Send()
        if (req.Status != 200)
            throw Exception("HTTP " . req.Status)
        stream := ComObjCreate("ADODB.Stream")
        stream.Type := 1
        stream.Open()
        stream.Write(req.ResponseBody)
        stream.SaveToFile(download, 2)
        stream.Close()
        FileGetSize, bytes, %download%
        f := FileOpen(download, "r")
        if (!IsObject(f) || bytes < 40000 || f.ReadUShort() != 0x5A4D)
            throw Exception("Файл обновления не является допустимым EXE")
        f.Close()
    } catch e {
        FileDelete, %download%
        MsgBox, 16, ViMeLlY Script, % "Ошибка загрузки: " . e.Message
        return false
    }
    ; Файл PowerShell создаётся самим скриптом в %TEMP%, выполняется после выхода EXE.
    ps =
    (
param([string]$Target, [string]$Download, [string]$Backup)
Start-Sleep -Seconds 2
$ok = $false
for ($i=0; $i -lt 20; $i++) {
    try {
        if (Test-Path -LiteralPath $Backup) { Remove-Item -LiteralPath $Backup -Force }
        Move-Item -LiteralPath $Target -Destination $Backup -Force -ErrorAction Stop
        try {
            Move-Item -LiteralPath $Download -Destination $Target -Force -ErrorAction Stop
            $ok = $true
        } catch {
            Move-Item -LiteralPath $Backup -Destination $Target -Force -ErrorAction SilentlyContinue
        }
        break
    } catch { Start-Sleep -Milliseconds 500 }
}
if ($ok) { Start-Process -FilePath $Target }
else { if (Test-Path -LiteralPath $Target) { Start-Process -FilePath $Target } }
    )
    FileDelete, %helper%
    FileAppend, %ps%, %helper%, UTF-8
    if (ErrorLevel) {
        MsgBox, 16, ViMeLlY Script, Не удалось создать служебный файл обновления.
        return false
    }
    args := "-NoProfile -ExecutionPolicy Bypass -File """ . helper . """ -Target """ . target . """ -Download """ . download . """ -Backup """ . backup . """"
    Run, % "powershell.exe " . args, , Hide, updaterPid
    if (ErrorLevel || !updaterPid) {
        MsgBox, 16, ViMeLlY Script, Не удалось запустить установщик обновлений.
        return false
    }
    ExitApp
}

; === scriptSettingsChecker: служебная функция ===
scriptSettingsChecker() {
    ; Загрузка внешних изображений отключена: оригинальная компоновка GUI без Picture.
    if (!FileExist(scriptDir)) {
        FileCreateDir, %scriptDir%
    } if (!FileExist(settingsFile)) {     
        checkLicenseKey() ; ПРОВЕРКА ЛИЦЕНЗИИ

        IniWrite, F2, %settingsFile%, Keys, Menu
        scriptMode := scriptType
        IniWrite, %scriptMode%, %settingsFile%, Preset, scriptMode
        IniWrite, 0, %settingsFile%, Preset, isHumanInput
        IniWrite, 1, %settingsFile%, Preset, isToolTipActive

        ; checkLicenseKey() уже сохранил userNickname в Base64.
        IniWrite, %userNickname%, %settingsFile%, Preset, userNickname

        if (scriptMode == "Admin") {
            IniWrite, %A_Space%, %settingsFile%, Keys, Watch
            IniWrite, %A_Space%, %settingsFile%, Keys, Request
            IniWrite, %A_Space%, %settingsFile%, Keys, Reply
            IniWrite, %A_Space%, %settingsFile%, Keys, humanReply
            IniWrite, F10, %settingsFile%, Keys, AdminStats
            IniWrite, %A_Space%, %settingsFile%, Keys, CopyAChat
            
            IniWrite, Быстро, %settingsFile%, Preset, currentSetup
            IniWrite, 0, %settingsFile%, Preset, reportLog
                        IniWrite, 0, %settingsFile%, Preset, punishHelperStatus
            IniWrite, 0, %settingsFile%, Preset, additionalFeaturesStatus
            IniWrite, 1, %settingsFile%, Preset, adminStatsStatus

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
        }

        IniWrite, %A_Space%, %settingsFile%, Keys, EmergencyDelete
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл настроек создан.", 1700)
        Reload
    } else {
        checkLicenseKey() ; ПРОВЕРКА ЛИЦЕНЗИИ
    }
    
    ; Создание базы ответов работает и из .ahk, и из единого .exe.
    if (!LoadAnswerRules())
        ToolTip("[SCRIPT] Не удалось открыть answer-rules.txt в Документах.", 3600)

    if (!FileExist(punishFile) && punishHelperStatus && scriptMode == "Admin") {
        text := "# Тут можно добавлять/удалять/изменять виды наказаний`n# Формат: /команда = /командаНаказания Время Причина`n# Пример: /epp = /jail 60 Езда по полям`n`n"
        FileAppend, %text%, %punishFile%, UTF-8
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл скрипта наказаний создан.", 1700)
    } if (!FileExist(additionalFeaturesFile) && additionalFeaturesStatus) {
        text := "#SingleInstance`, Force `; Позволяет запускать лишь 1 скрипт одновременно `n#Persistent `; Оставляет скрипт работающим на постоянной основе.`n#NoEnv `; - Отключает автоматическое наследование переменных окружения Windows.`n#NoTrayIcon `; - Скрывает значок скрипта в системном трее. `n`nSetTitleMatchMode, 2 `; - Устанавливает режим поиска окон по заголовку.`nSetBatchLines, -1 `; - Устанавливает максимальную производительность.`nSendMode Input `; - Устанавливает режим отправки клавиш.`n`n`; === Ваш скрипт`n`n`n`n;================================================================================================================================================="
        FileAppend, %text%, %additionalFeaturesFile%, UTF-8
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл доп. скрипта создан.", 1700)
    } if (!FileExist(statisticFile) && userNickname != "ERROR" && adminStatsStatus && scriptMode == "Admin") {
        if (FileExist(settingsFile)) {
            adminName := userNickname

            IniRead, totalAns, %settingsFile%, %adminName%, totalAns, 0
            IniRead, totalJails, %settingsFile%, %adminName%, totalJails, 0
    
            initialStatsDate := StatsToday()
            IniWrite, %totalAns%, %statisticFile%, %initialStatsDate%, totalAns
            IniWrite, %totalJails%, %statisticFile%, %initialStatsDate%, totalJails
        }
    }
}


; === StatsToday: актуальная календарная дата, не кэшируется с момента запуска ===
StatsToday() {
    FormatTime, dateText,, dd.MM.yyyy
    return dateText
}

; === StatsIsDate: запрещает [ERROR] и любые не-даты в statistic.ini ===
StatsIsDate(value) {
    return RegExMatch(Trim(value), "^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.[0-9]{4}$") != 0
}

; === StatsNumber: обрабатывает пустые/ошибочные счетчики без записи слова ERROR ===
StatsNumber(value) {
    value := Trim(value)
    return RegExMatch(value, "^-?[0-9]+$") ? (value + 0) : 0
}

; === StatsArchiveDay: архивирует только дату, проверяя запись перед обнулением ===
StatsArchiveDay(day, answerCount, jailCount) {
    global statisticFile
    if (!StatsIsDate(day))
        return false

    ; Однократная копия старого архива (никогда не перезаписывается).
    if (FileExist(statisticFile) && !FileExist(statisticFile . ".bak")) {
        savedCopy := statisticFile . ".bak"
        FileCopy, %statisticFile%, %savedCopy%, 0
        if (ErrorLevel)
            return false
    }

    answerCount := StatsNumber(answerCount)
    jailCount := StatsNumber(jailCount)
    IniWrite, %answerCount%, %statisticFile%, %day%, totalAns
    if (ErrorLevel)
        return false
    IniWrite, %jailCount%, %statisticFile%, %day%, totalJails
    if (ErrorLevel)
        return false
    return true
}

; === adminsStatistics: корректная инициализация даты и переход между днями ===
adminsStatistics() {
    global settingsFile, statisticFile, userNickname, today

    IniRead, statsAdmin, %settingsFile%, Preset, userNickname, %A_Space%
    statsAdmin := Trim(statsAdmin)
    if (statsAdmin = "" || statsAdmin = "ERROR")
        return false

    currentDate := StatsToday()
    IniRead, savedDate, %settingsFile%, %statsAdmin%, Date, %A_Space%
    savedDate := Trim(savedDate)
    IniRead, totalAns, %settingsFile%, %statsAdmin%, totalAns, 0
    IniRead, totalJails, %settingsFile%, %statsAdmin%, totalJails, 0
    totalAns := StatsNumber(totalAns)
    totalJails := StatsNumber(totalJails)

    ; При первом запуске создаем Date, НЕ списывая уже накопленные счетчики.
    ; Старую секцию [ERROR] намеренно не переносим: ее дата неизвестна.
    if (!StatsIsDate(savedDate)) {
        IniWrite, %currentDate%, %settingsFile%, %statsAdmin%, Date
        if (ErrorLevel)
            return false
        today := currentDate
        return true
    }

    if (savedDate != currentDate) {
        if (!StatsArchiveDay(savedDate, totalAns, totalJails))
            return false

        ; Сперва устанавливаем новую дату, затем сбрасываем счетчики.
        IniWrite, %currentDate%, %settingsFile%, %statsAdmin%, Date
        if (ErrorLevel)
            return false
        IniWrite, 0, %settingsFile%, %statsAdmin%, totalAns
        IniWrite, 0, %settingsFile%, %statsAdmin%, totalJails
        IniDelete, %settingsFile%, ProcessedLines
    }

    today := currentDate
    return true
}

; === StatsListDays: только корректные даты по порядку, без [ERROR] ===
StatsListDays() {
    global statisticFile
    dates := []
    if (!FileExist(statisticFile))
        return dates
    IniRead, sections, %statisticFile%
    if (sections = "ERROR")
        return dates

    Loop, Parse, sections, `n, `r
    {
        day := Trim(A_LoopField)
        if (StatsIsDate(day))
            dates.Push(day)
    }

    count := dates.Length()
    if (count < 2)
        return dates
    Loop, %count%
    {
        Loop, % count - 1
        {
            idx := A_Index
            a := dates[idx]
            b := dates[idx + 1]
            keyA := SubStr(a, 7, 4) . SubStr(a, 4, 2) . SubStr(a, 1, 2)
            keyB := SubStr(b, 7, 4) . SubStr(b, 4, 2) . SubStr(b, 1, 2)
            if (keyA > keyB) {
                dates[idx] := b
                dates[idx + 1] := a
            }
        }
    }
    return dates
}

; === guiColorFunc: служебная функция ===
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


; === ShowMenuNoActivate: показать меню поверх окон, не забирая фокус у игры ===
ShowMenuNoActivate(guiName) {
    global menuNavGuiName, menuNavGuiHwnd

    Gui, %guiName%:+AlwaysOnTop
    Gui, %guiName%:Show, NA AutoSize
    Gui, %guiName%:+LastFound
    hwnd := WinExist()
    if (!hwnd)
        return

    WinGetPos,,, winW, winH, ahk_id %hwnd%
    x := (A_ScreenWidth - winW) // 2
    y := 18
    WinMove, ahk_id %hwnd%,, %x%, %y%
    WinSet, AlwaysOnTop, On, ahk_id %hwnd%
    WinSet, Transparent, 233, ahk_id %hwnd%

    menuNavGuiName := guiName
    menuNavGuiHwnd := hwnd
    InitMenuKeyboard(hwnd)
}


; === InitMenuKeyboard: собрать кнопки текущего меню для клавиатурной навигации ===
InitMenuKeyboard(hwnd) {
    global menuNavItems, menuNavIndex

    menuNavItems := []
    menuNavIndex := 0
    WinGet, controls, ControlList, ahk_id %hwnd%
    Loop, Parse, controls, `n, `r
    {
        controlName := A_LoopField
        if (!RegExMatch(controlName, "i)^Button\d+$"))
            continue

        ControlGet, controlHwnd, Hwnd,, %controlName%, ahk_id %hwnd%
        if (!controlHwnd)
            continue
        ControlGetText, controlText, %controlName%, ahk_id %hwnd%
        WinGet, controlStyle, Style, ahk_id %controlHwnd%
        controlType := controlStyle & 0xF
        menuNavItems.Push({hwnd: controlHwnd, text: controlText, type: controlType})
    }

    if (menuNavItems.Length())
        MenuKeyboardSelect(1)
    else
        MenuKeyboardUpdateHint("")
}


; === MenuKeyboardSelect: выбрать элемент и подсветить текущую кнопку ===
MenuKeyboardSelect(index) {
    global menuNavItems, menuNavIndex

    count := menuNavItems.Length()
    if (!count)
        return

    if (menuNavIndex >= 1 && menuNavIndex <= count) {
        previous := menuNavItems[menuNavIndex]
        if (previous.type = 0 || previous.type = 1) {
            previousHwnd := previous.hwnd
            previousType := previous.type
            SendMessage, 0x00F4, %previousType%, 1,, ahk_id %previousHwnd%
        }
    }

    while (index < 1)
        index += count
    while (index > count)
        index -= count
    menuNavIndex := index

    selected := menuNavItems[menuNavIndex]
    selectedHwnd := selected.hwnd
    if (selected.type = 0 || selected.type = 1)
        SendMessage, 0x00F4, 1, 1,, ahk_id %selectedHwnd%

    MenuKeyboardUpdateHint(selected.text)
}


; === MenuKeyboardUpdateHint: показать выбранный пункт внизу меню ===
MenuKeyboardUpdateHint(selectedText) {
    global menuNavGuiName
    if (menuNavGuiName = "")
        return
    if (selectedText = "")
        selectionText := "Выберите пункт стрелками или Tab"
    else
        selectionText := "Выбрано: " . selectedText
    GuiControl, %menuNavGuiName%:, MenuKeyboardSelection, %selectionText%
}


; === MenuKeyboardEnabled: клавиатурное управление активно только для видимого меню ===
MenuKeyboardEnabled() {
    global menuNavGuiHwnd
    if (!menuNavGuiHwnd || !WinExist("ahk_id " . menuNavGuiHwnd))
        return false
    WinGet, windowStyle, Style, ahk_id %menuNavGuiHwnd%
    if (!(windowStyle & 0x10000000))
        return false

    ; Если пользователь кликнул в поле ввода, клавиатура должна редактировать его,
    ; а не перемещать выбор по кнопкам меню.
    if (WinActive("ahk_id " . menuNavGuiHwnd)) {
        ControlGetFocus, focusedControl, ahk_id %menuNavGuiHwnd%
        if (RegExMatch(focusedControl, "i)^(Edit|msctls_hotkey|ComboBox)"))
            return false
    }
    return true
}


; === MenuMouseActivate: клики по кнопкам не забирают фокус у игры ===
MenuMouseActivate(wParam, lParam, msg, hwnd) {
    global menuNavGuiHwnd
    if (hwnd != menuNavGuiHwnd)
        return

    VarSetCapacity(point, 8, 0)
    if (!DllCall("GetCursorPos", "Ptr", &point))
        return 3
    pointValue := NumGet(point, 0, "Int64")
    childHwnd := DllCall("WindowFromPoint", "Int64", pointValue, "Ptr")
    if (!childHwnd)
        return 3

    WinGetClass, className, ahk_id %childHwnd%
    if (RegExMatch(className, "i)^(Edit|msctls_hotkey|ComboBox)"))
        return 1 ; MA_ACTIVATE — поля редактирования должны получать ввод
    return 3 ; MA_NOACTIVATE — кнопка срабатывает без активации окна
}


; === MenuNavigate: перемещение выбора по кнопкам меню ===
MenuNavigate(step) {
    global menuNavIndex
    if (!MenuKeyboardEnabled())
        return
    MenuKeyboardSelect(menuNavIndex + step)
}


; === MenuActivateSelected: выполнить выбранную кнопку без активации окна игры ===
MenuActivateSelected() {
    global menuNavItems, menuNavIndex
    if (!MenuKeyboardEnabled() || menuNavIndex < 1 || menuNavIndex > menuNavItems.Length())
        return
    selected := menuNavItems[menuNavIndex]
    selectedHwnd := selected.hwnd
    PostMessage, 0x00F5, 0, 0,, ahk_id %selectedHwnd%
}


; === ReturnToMainMenu: вернуться из подменю в главное ===
ReturnToMainMenu() {
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYStats:Destroy
    ShowMenuNoActivate("ViMeLlY")
}


; === CloseMenuWindows: закрыть меню, не завершая работу скрипта ===
CloseMenuWindows() {
    global menuNavGuiName, menuNavGuiHwnd, menuNavItems, menuNavIndex
    Gui, ViMeLlY:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYStats:Destroy
    SetTimer, SaveHotkeys, Off
    SetTimer, SaveAnswers, Off
    menuNavGuiName := ""
    menuNavGuiHwnd := 0
    menuNavItems := []
    menuNavIndex := 0
}


Menu:
    guiColorFunc()
    ansLogStatus := reportLog ? "✔ Лог жалоб" : "✘ Лог жалоб"
    aspStatus := isHumanInput ? "Имитация ручного ввода ☺" : "Автоматический ♛"
    punishHelperSwitch := punishHelperStatus ? "✔ Умные наказания" : "✘ Умные наказания"
    additionalFeaturesSwitch := additionalFeaturesStatus ? "✔ Доп. возможности " : "✘ Доп. возможности "
    adminStatsSwitch := adminStatsStatus ? "✔" : "✘"


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
            Gui, ViMeLlY:Add, Checkbox, x50 y+1 w330 Checked vIsToolTipActiveV gIsToolTipActiveCheckBox, Всплывающие подсказки скрипта
        } else {
            Gui, ViMeLlY:Add, Checkbox, x50 y+1 w330 vIsToolTipActiveV gIsToolTipActiveCheckBox, Всплывающие подсказки скрипта
        }
    }

    Gui, ViMeLlY:Font, s7, Comic Sans MS
    if (scriptMode == "Admin") {
        Gui, ViMeLlY:Add, Button, xm y+1 w143 gAnswers,⚙️ Настройки ответов྾
        Gui, ViMeLlY:Add, Button, x+1 yp w174 gOpenPunishHelper, 👁️ Помощник наказаний
        Gui, ViMeLlY:Add, Button, x+1 yp w61 gOpenAdditionalFeatures, 👁️ Доп.
        Gui, ViMeLlY:Add, Button, x17 y+1 w123 gReportLog_ToggleStatus vStatusLogButton, %ansLogStatus%
        Gui, ViMeLlY:Add, Button, x+1 yp w140 gPunishHelper_ToggleStatus vPunishHelperButton, %punishHelperSwitch%
        Gui, ViMeLlY:Add, Button, x+1 yp w116 gAdditionalFeatures_ToggleStatus vAdditionalFeaturesButton, %additionalFeaturesSwitch%
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

        yesterday := PlayerYesterdayDate()
        truckerIncome := GetIncomeByDate(yesterday, "Доставка продуктов")
        Gui, ViMeLlY:Add, Text, x27 y+1 w200,- Trucker: %truckerIncome% руб.
        Gui, ViMeLlY:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultPlayerTrucker, Пусто

        gardenIncome := GetIncomeByDate(yesterday, "Продажа урожая")
        Gui, ViMeLlY:Add, Text, x27 y+1 w200,- Gardens: %gardenIncome% руб.
        Gui, ViMeLlY:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultPlayerGardens, Пусто

        huntingIncome := GetIncomeByDate(yesterday, "Продажа шкур")
        Gui, ViMeLlY:Add, Text, x27 y+1 w200,- Hunting: %huntingIncome% руб.
        Gui, ViMeLlY:Add, Edit, x+3 h18 yp w145 ReadOnly Center vSearchResultPlayerHunting, Пусто
        Gui, ViMeLlY:Add, Text, x25 y+3 w380,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
    }

    Gui, ViMeLlY:Font, s9, Comic Sans MS
    Gui, ViMeLlY:Add, Text, x17 y+0 w381 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
    Gui, ViMeLlY:Font, s7, Comic Sans MS 
    Gui, ViMeLlY:Add, Text, x17 y+4 w381 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
    Gui, ViMeLlY:Add, Button, x17 y+2 w381 h21 gResetLicenseKey, 🔑 Сбросить ключ доступа
    Gui, ViMeLlY:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Link, x25 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    ShowMenuNoActivate("ViMeLlY")
Return


HotKeys:
    IniRead, menuKey, %settingsFile%, Keys, Menu
    IniRead, spectateKey, %settingsFile%, Keys, Watch
    IniRead, requestKey, %settingsFile%, Keys, Request
    IniRead, replyKey, %settingsFile%, Keys, Reply
    IniRead, humanReplyKey, %settingsFile%, Keys, humanReply
    IniRead, copyAChatKey, %settingsFile%, Keys, CopyAChat
    IniRead, statsKey, %settingsFile%, Keys, AdminStats
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
    Gui, ViMeLlYHotKeys:Font, s7, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, x25 y+4 w400 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
    Gui, ViMeLlYHotKeys:Add, Text, x25 y+0 w400 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
    Gui, ViMeLlYHotKeys:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Link, x55 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    ShowMenuNoActivate("ViMeLlYHotKeys")

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
    Gui, ViMeLlYAnswers:Font, s7, Comic Sans MS
    Gui, ViMeLlYAnswers:Add, Text, x25 y+4 w380 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
    Gui, ViMeLlYAnswers:Add, Text, x25 y+0 w380 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
    Gui, ViMeLlYAnswers:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYAnswers:Add, Link, x45 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    ShowMenuNoActivate("ViMeLlYAnswers")

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
    Gui, ViMeLlYStats:Font, s7, Comic Sans MS
    Gui, ViMeLlYStats:Add, Text, x25 y+4 w380 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
    Gui, ViMeLlYStats:Add, Text, x25 y+0 w380 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
    Gui, ViMeLlYStats:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYStats:Add, Link, x45 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    
    if (userNickname != "ERROR" && userNickname != "") {
        if (adminStatsStatus) {
            Gui, ViMeLlY:Hide
            ShowMenuNoActivate("ViMeLlYStats")
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


; === GetStats: минимум/максимум/среднее только по датированным записям ===
GetStats(metric, daysCount, mode := "avg") {
    global statisticFile
    days := StatsListDays()
    n := days.Length()
    if (n = 0 || daysCount < 1)
        return 0

    first := n - daysCount + 1
    if (first < 1)
        first := 1
    total := 0
    minimum := ""
    maximum := ""
    count := 0
    Loop, % n - first + 1
    {
        day := days[first + A_Index - 1]
        IniRead, rawValue, %statisticFile%, %day%, %metric%, 0
        value := StatsNumber(rawValue)
        total += value
        count++
        if (minimum = "" || value < minimum)
            minimum := value
        if (maximum = "" || value > maximum)
            maximum := value
    }
    if (mode = "avg")
        return count ? total / count : 0
    if (mode = "min")
        return minimum
    if (mode = "max")
        return maximum
    return 0
}

; === GetChange: сравнение только корректных дат, без секции ERROR ===
GetChange(metric, lookback := 1, type := "percent") {
    global statisticFile
    days := StatsListDays()
    n := days.Length()
    if (lookback < 1 || n <= lookback)
        return 0

    lastDay := days[n]
    previousDay := days[n - lookback]
    IniRead, rawCurr, %statisticFile%, %lastDay%, %metric%, 0
    IniRead, rawPrev, %statisticFile%, %previousDay%, %metric%, 0
    curr := StatsNumber(rawCurr)
    prev := StatsNumber(rawPrev)
    if (type = "delta")
        return curr - prev
    if (type = "percent")
        return prev ? ((curr - prev) / prev) * 100 : 0
    return 0
}

SearchStatsByDatePlayer:
    Gui, ViMeLlY:Submit, NoHide

    searchDate := SearchDayPlayer "." SearchMonthPlayer "." SearchYearPlayer
    Trucker := GetIncomeByDate(searchDate, "Доставка продуктов")
    Gardens := GetIncomeByDate(searchDate, "Продажа урожая")
    Hunting := GetIncomeByDate(searchDate, "Продажа шкур")

    ; Сумма может содержать разделители тысяч (например, 1.000), поэтому
    ; для проверки наличия дохода убираем форматирование.
    if (PlayerIncomeNumber(Trucker) > 0 || PlayerIncomeNumber(Gardens) > 0 || PlayerIncomeNumber(Hunting) > 0) {
        if (PlayerIncomeNumber(Trucker) > 0) {
            GuiControl,, SearchResultPlayerTrucker, %Trucker% руб
        } else {
            GuiControl,, SearchResultPlayerTrucker, Пусто
        }
        if (PlayerIncomeNumber(Gardens) > 0) {
            GuiControl,, SearchResultPlayerGardens, %Gardens% руб
        } else {
            GuiControl,, SearchResultPlayerGardens, Пусто
        }

        if (PlayerIncomeNumber(Hunting) > 0) {
            GuiControl,, SearchResultPlayerHunting, %Hunting% руб
        } else {
            GuiControl,, SearchResultPlayerHunting, Пусто
        }
    } else {
        ; Не показывать данные предыдущего поиска вместо пустого результата.
        GuiControl,, SearchResultPlayerTrucker, Пусто
        GuiControl,, SearchResultPlayerGardens, Пусто
        GuiControl,, SearchResultPlayerHunting, Пусто
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


; === GetIncomeByDate: служебная функция ===
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

    ; Не используем FileEncoding: эта команда меняет кодировку глобально
    ; и может повлиять на другие чтения файлов в основном скрипте.
    history := FileOpen(orderHistoryPath, "r", "UTF-8")
    if (!IsObject(history))
        return 0

    while (!history.AtEOF) {
        historyLine := LTrim(Trim(history.ReadLine(), "`r`n"), Chr(0xFEFF))
        if (historyLine = "" || (SearchQuery != "" && !InStr(historyLine, SearchQuery)))
            continue

        LineArray := StrSplit(historyLine, ",")
        if (LineArray.Length() < 2)
            continue
        LogDate := SubStr(Trim(LineArray[1]), 1, 10)
        if (LogDate = CheckDate) {
            CleanMoney := RegExReplace(LineArray[2], "[^\d]", "")
            if (CleanMoney != "")
                Sum += CleanMoney
        }
    }
    history.Close()
    return RegExReplace(Sum, "(\d)(?=(\d{3})+(?!\d))", "$1.")
}

; === PlayerYesterdayDate: календарный вчерашний день, включая границы месяцев и годов ===
PlayerYesterdayDate() {
    yesterday := A_Now
    EnvAdd, yesterday, -1, Days
    FormatTime, formatted, %yesterday%, dd.MM.yyyy
    return formatted
}

; === PlayerIncomeNumber: число без разделителей тысяч для сравнения ===
PlayerIncomeNumber(value) {
    return RegExReplace("" . value, "[^0-9]", "") + 0
}


; === MaxArr: служебная функция ===
MaxArr(arr) {
    if (arr.Length() = 0)
        return 0
    
    maxVal := arr[1]
    
    for i, v in arr
        if (v > maxVal)
            maxVal := v

    return maxVal
}


; === MinArr: служебная функция ===
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
    ReturnToMainMenu()
Return


ViMeLlYGuiEscape:
Close:
    CloseMenuWindows()
Return


ResetLicenseKey:
    MsgBox, 52, Сброс ключа доступа, Удалить сохранённый ключ доступа из настроек?`n`nПосле подтверждения скрипт перезапустится и попросит ввести ключ повторно.
    IfMsgBox, No
        Return

    IniDelete, %settingsFile%, License, Key
    IniDelete, %settingsFile%, Preset, scriptMode
    IniRead, remainingKey, %settingsFile%, License, Key, __MISSING__
    if (remainingKey != "__MISSING__") {
        MsgBox, 16, Ошибка, Не удалось удалить сохранённый ключ доступа.
        Return
    }
    Reload
Return


OpenSettings:
    Run, notepad %settingsFile%
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
        ChatlogWatchFromNow("reports")
        SetTimer, answerLogger, 500
    } else {
        IniWrite, 0, %settingsFile%, Preset, reportLog
        SetTimer, answerLogger, Off
    }
Return


PunishHelper_ToggleStatus:
    punishHelperStatus := !punishHelperStatus
    newStatus2 := punishHelperStatus ? "✔ Умные наказания" : "✘ Умные наказания"
    
    GuiControl,, PunishHelperButton, %newStatus2%
    
    if (punishHelperStatus) {
        IniWrite, 1, %settingsFile%, Preset, punishHelperStatus
        if (!FileExist(punishFile)) {
            template := "# Формат: /epp = /jail 60 Езда по полям`n"
            FileAppend, %template%, %punishFile%, UTF-8
        }
        SetTimer, punishHelper, -100
    } else {
        IniWrite, 0, %settingsFile%, Preset, punishHelperStatus
        ; Файл пользовательских правил наказаний не удаляем при выключении.
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
        ; Не удаляем пользовательский дополнительный модуль.
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
        ; История статистики сохраняется даже при выключении.
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
        GuiControl, ViMeLlYHotKeys:, HK_WatchText, % (HK_Watch) ? "‖ " . ReadableHotkey(HK_Watch) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_ReplyText, % (HK_Reply) ? "‖ " . ReadableHotkey(HK_Reply) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_RequestText, % (HK_Request) ? "‖ " . ReadableHotkey(HK_Request) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_humanReplyText, % (HK_humanReply) ? "‖ " . ReadableHotkey(HK_humanReply) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_CopyAChatText, % (HK_CopyAChat) ? "‖ " . ReadableHotkey(HK_CopyAChat) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_AdminStatsText, % (HK_AdminStats) ? "‖ " . ReadableHotkey(HK_AdminStats) : "‖ Не назначена"
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
    ; Ручной сброс сохраняет текущие счетчики только под реальной датой.
    if (!adminsStatistics()) {
        ToolTip("[STATISTICS] Невозможно определить администратора или дату.", 2300)
        Return
    }

    IniRead, statsKey, %settingsFile%, Preset, userNickname, %A_Space%
    statsKey := Trim(statsKey)
    IniRead, savedDate, %settingsFile%, %statsKey%, Date, %A_Space%
    savedDate := Trim(savedDate)
    if (!StatsIsDate(savedDate)) {
        ToolTip("[STATISTICS] Некорректная дата, сброс отменен.", 2300)
        Return
    }
    IniRead, totalAns, %settingsFile%, %statsKey%, totalAns, 0
    IniRead, totalJails, %settingsFile%, %statsKey%, totalJails, 0
    if (!StatsArchiveDay(savedDate, totalAns, totalJails)) {
        ToolTip("[STATISTICS] Ошибка записи statistic.ini, сброс отменен.", 2500)
        Return
    }
    IniWrite, 0, %settingsFile%, %statsKey%, totalAns
    IniWrite, 0, %settingsFile%, %statsKey%, totalJails
    today := StatsToday()
    ToolTip("[STATISTICS] Данные сохранены за " . savedDate . ". Счетчики обнулены.", 1800)
    GoSub, AdminStatsPanel
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
ExitApp


; === LoadHotkeys: служебная функция ===
LoadHotkeys() {
    global hotkeys, settingsFile
    IniRead, hkWatch, %settingsFile%, Keys, Watch
    IniRead, hkRequest, %settingsFile%, Keys, Request
    IniRead, hkReply, %settingsFile%, Keys, Reply
    IniRead, hkhumanReply, %settingsFile%, Keys, humanReply
    IniRead, hkCopyAChat, %settingsFile%, Keys, CopyAChat
    IniRead, hkMenu, %settingsFile%, Keys, Menu
    IniRead, hkAdminStats, %settingsFile%, Keys, AdminStats
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
    hotkeys["autoEdit"] := (hkAutoEdit == "ERROR") ? "" : (hkAutoEdit == "" ? "" : hkAutoEdit)
    hotkeys["autoBizlist"] := (hkAutoBizlist == "ERROR") ? "" : (hkAutoBizlist == "" ? "" : hkAutoBizlist)
    hotkeys["EmergencyDelete"] := (hkEmergencyDelete == "ERROR") ? "" : (hkEmergencyDelete == "" ? "" : hkEmergencyDelete)
}


; === BindHotkeys: служебная функция ===
BindHotkeys() {
    global previousHotkeys, hotkeys, settingsFile, scriptMode

    for action, oldKey in previousHotkeys {
        if (oldKey != "" && !(action = "Reply" || action = "")) {
            Hotkey, %oldKey%, Off
        }
    }

    ; Не переносим хоткеи другой роли при переключении Admin/Player.
    previousHotkeys := {}
    successLog := ""
    for action, newKey in hotkeys {
        if (scriptMode = "Player" && action != "autoEdit" && action != "autoBizlist"
            && action != "Menu" && action != "EmergencyDelete")
            continue
        if (scriptMode = "Admin" && (action = "autoEdit" || action = "autoBizlist"))
            continue
        if (newKey != "" && !(action = "Reply" || action = "")) {
            try {
                Hotkey, %newKey%, %action%, On
                previousHotkeys[action] := newKey
                
                successLog .= "Дія: " . action . " -> Клавіша: " . newKey . "`n"
            } catch e {
                continue
            }
        }
    }

    IniRead, CS, %settingsFile%, Preset, currentSetup
    IniRead, d1, %settingsFile%, Preset, Delay1
    IniRead, d2, %settingsFile%, Preset, Delay2
    IniRead, d3, %settingsFile%, Preset, Delay3
    
    SetPreset(CS, d1, d2, d3)
}


; === WatchKeys: служебная функция ===
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


; === WatchSpectate: служебная функция ===
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


; === SetPreset: служебная функция ===
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


; === FindChatlogPath: служебная функция ===
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


; ============================================================================================================================
; #region || ОЧЕРЕДЬ БЕЗОПАСНЫХ АВТОКОМАНД
; Только ответы/наблюдение; наказания и команды меню остаются ручными.
; Очередь не отправляет старые команды после потери фокуса надолго.
; === AutomationQueueChat: очередь команд чата ===
AutomationQueueChat(command) {
    global automationQueue
    if (SubStr(command, 1, 4) != "/pm " && SubStr(command, 1, 4) != "/sp ")
        return false
    if (automationQueue.Length() >= 4)
        return false
    automationQueue.Push({cmd:command, queued:A_TickCount})
    SetTimer, AutomationProcessQueue, 40
    return true
}

; === AutomationProcessQueue: последовательная отправка команд ===
AutomationProcessQueue() {
    global automationQueue, automationBusy, automationLastSent, ChatIsOpen, requestCanRecall
    if (automationBusy || automationQueue.Length() = 0) {
        if (automationQueue.Length() = 0)
            SetTimer, AutomationProcessQueue, Off
        return
    }
    job := automationQueue[1]
    if ((A_TickCount - job.queued) > 2500) {
        automationQueue.RemoveAt(1)
        return
    }
    if (!WinActive("ahk_exe gta_sa.exe") || ChatIsOpen || (A_TickCount - automationLastSent < 180))
        return
    automationBusy := true
    automationQueue.RemoveAt(1)
    SetTimer, AutomationProcessQueue, Off
    ; Не разрешаем прерывать набор внутри этой краткой операции.
    Critical, On
    requestCanRecall := false
    SendInput, % "{F6}" . job.cmd . "{Enter}"
    automationLastSent := A_TickCount
    Critical, Off
    automationBusy := false
    if (automationQueue.Length() > 0)
        SetTimer, AutomationProcessQueue, 40
}

; === sendReply: служебная функция ===
sendReply(playerId, response) {
    global isHumanInput, CMDDelay, InputDelay1, InputDelay2, requestCanRecall
    requestCanRecall := false
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
        AutomationQueueChat("/pm " . playerId . " " . response)
    }
}


; === ReadableHotkey: служебная функция ===
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


; === Join: служебная функция ===
Join(delim, arr*) {
    out := ""
    
    for i, val in arr
        out .= (i > 1 ? delim : "") . val
    
    return out
}


; === HashLine: служебная функция ===
HashLine(str) {
    hash := 0
    
    Loop, Parse, str
        hash := Mod(hash * 31 + Asc(A_LoopField), 1000000007)
    
    return hash
}


; ============================================================================================================================
; #region || CHATLOG - инкрементальный читатель с независимыми курсорами
; Позиции выражены в байтах UTF-8; недописанные строки не выдаются обработчикам.
; Если файл сокращён, перезаписан или создан заново, курсор возвращается в начало.
; При отсутствии файла обработчики получают пустой список, не теряя состояние навсегда.
; === ChatlogReadNew: чтение добавленных строк журнала ===
ChatlogReadNew(channel, startAt := "tail", reset := false) {
    global filePath
    static cursors := {}
    result := []
    if (filePath = "")
        filePath := A_MyDocuments . "\RADMIR CRMP User Files\SAMP\chatlog.txt"
    if (!FileExist(filePath)) {
            ; Не забывать канал: после повторного появления файла считывать с начала.
        cursors[channel] := {pos:0, created:"", probe:"", probePos:0}
        return result
    }

    FileGetSize, size, %filePath%
    FileGetTime, created, %filePath%, C
    ; RADMIR/SAMP обычно пишет ANSI/CP1251, а не UTF-8.
    ; При UTF-8 BOM распознаём кодировку автоматически.
    charset := "CP0"
    probe := FileOpen(filePath, "r")
    if (IsObject(probe)) {
        bom := probe.ReadUChar() . ":" . probe.ReadUChar() . ":" . probe.ReadUChar()
        probe.Close()
        if (bom == "239:187:191")
            charset := "UTF-8"
    }
    f := FileOpen(filePath, "r", charset)
    if (!IsObject(f))
        return result

    if (reset || !cursors.HasKey(channel)) {
        state := {pos: startAt = "all" ? 0 : size, created: created, probe: "", probePos: 0}
        cursors[channel] := state
        ChatlogRememberProbe(f, state)
        f.Close()
        return result
    }

    state := cursors[channel]
    replacement := (size < state.pos || created != state.created)
    if (!replacement && state.pos > 0) {
        probeNow := ChatlogFingerprint(f, state.probePos, state.pos - state.probePos)
        if (probeNow != state.probe)
            replacement := true
    }
    if (replacement) {
        state.pos := 0
        state.created := created
        state.probe := ""
        state.probePos := 0
    }

    f.Pos := state.pos
    while (!f.AtEOF) {
        before := f.Pos
        line := f.ReadLine()
        if (SubStr(line, 0) != "`n") {
            f.Pos := before
            break
        }
        result.Push(LTrim(RTrim(line, "`r`n"), Chr(0xFEFF)))
    }
    state.pos := f.Pos
    ChatlogRememberProbe(f, state)
    f.Close()
    return result
}

; Контроль последних байтов: обнаруживает очистку с быстрым заполнением файла.
; === ChatlogRememberProbe: служебная функция ===
ChatlogRememberProbe(f, state) {
    state.probePos := (state.pos > 96) ? state.pos - 96 : 0
    state.probe := ChatlogFingerprint(f, state.probePos, state.pos - state.probePos)
}

; Сравнение сырых байтов, а не символов UTF-8 (без ложных сбросов на кириллице).
; === ChatlogFingerprint: служебная функция ===
ChatlogFingerprint(f, start, bytes) {
    if (bytes <= 0)
        return 0
    f.Pos := start
    VarSetCapacity(buffer, bytes, 0)
    read := f.RawRead(buffer, bytes)
    checksum := 0
    Loop, %read%
        checksum := Mod(checksum * 33 + NumGet(buffer, A_Index - 1, "UChar"), 2147483647)
    return checksum
}

; Принудительная установка курсора на конец файла при включении функции.
; === ChatlogWatchFromNow: служебная функция ===
ChatlogWatchFromNow(channel) {
    return ChatlogReadNew(channel, "tail", true)
}

; Совместимость с ручными функциями, которым нужен номер строки.
; === checkChatLog: служебная функция ===
checkChatLog() {
    global filePath
    count := 0
    if (filePath = "" || !FileExist(filePath))
        return count
    Loop, Read, %filePath%
        count := A_Index
    return count
}


; === Base64Encode: служебная функция ===
Base64Encode(str) {
    VarSetCapacity(bin, StrPut(str, "UTF-8"))
    len := StrPut(str, &bin, "UTF-8") - 1
    DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size)
    VarSetCapacity(buf, size << 1, 0)
    DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size)
    
    return StrGet(&buf)
}


; === Base64Decode: служебная функция ===
Base64Decode(str) {
    DllCall("crypt32\CryptStringToBinary", "ptr", &str, "uint", StrLen(str), "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0)
    VarSetCapacity(buf, size, 0)
    DllCall("crypt32\CryptStringToBinary", "ptr", &str, "uint", StrLen(str), "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0)
    
    return StrGet(&buf, size, "UTF-8")
}


; === getAnswer: служебная функция ===
getAnswer(val) {
    global settingsFile
    IniRead, result, %settingsFile%, Answers, %val%
    
    Return result
}


; === ShowTip: служебная функция ===
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


; === CountAdminActions: учёт действий администратора ===
CountAdminActions() {
    global adminAns, adminJails, today
    global settingsFile, userNickname
    
    adminName := Base64Decode(userNickname)
    ; Автоматически переносим статистику при смене даты, даже без перезапуска.
    if (StatsToday() != today)
        adminsStatistics()
    
    ; Первая обработка читает существующий chatlog (старый учёт сохраняется).
    static initialized := false
    if (!initialized) {
        ChatlogReadNew("stats", "all", true)
        initialized := true
    }
    for _, line in ChatlogReadNew("stats") {
        if RegExMatch(line, "^\[(\d{2}):(\d{2}):(\d{2})\]", t) {
            lineTime := t1 * 3600 + t2 * 60 + t3
            currentTime := A_Hour * 3600 + A_Min * 60 + A_Sec
            currentDate := A_DD . "." . A_MM . "." . A_YYYY
            
            if (lineTime > currentTime)
                continue
            ; Смена дня обрабатывается adminsStatistics(), без GUI и ручного сброса.
        } if RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? для (\w+(?:_\w+)*)\[(\d+)\]:") || RegExMatch(line, "Агент поддержки " . adminName . "(?:\[(\d+)\])? для (\w+(?:_\w+)*)\[(\d+)\]:") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            
            if (seen == "ERROR") {
                IniRead, totalAns, %settingsFile%, %userNickname%, totalAns
                totalAns := ((totalAns = "ERROR") ? 0 : totalAns) + 1
                IniWrite, %totalAns%, %settingsFile%, %userNickname%, totalAns
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        } if RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? посадил в тюрьму игрока (\w+(?:_\w+)*)")
        || RegExMatch(line, "Администратор " . adminName . "(?:\[(\d+)\])? оффлайн посадил в тюрьму игрока (\w+(?:_\w+)*)") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            
            if (seen == "ERROR") {
                IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
                totalJails := ((totalJails = "ERROR") ? 0 : totalJails) + 1
                IniWrite, %totalJails%, %settingsFile%, %userNickname%, totalJails
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        } if RegExMatch(line, adminName . "(?:\[(\d+)\])? выпустил игрока (\w+(?:_\w+)*)\[(\d+)\] из тюрьмы") {
            hash := HashLine(line)
            IniRead, seen, %settingsFile%, ProcessedLines, %hash%
            
            if (seen == "ERROR") {
                IniRead, totalJails, %settingsFile%, %userNickname%, totalJails
                totalJails := ((totalJails = "ERROR") ? 0 : totalJails) - 1
                IniWrite, %totalJails%, %settingsFile%, %userNickname%, totalJails
                IniWrite, %hash%, %settingsFile%, ProcessedLines, %hash%
            }
        }
    }
}


; === TransliterateToRussian: служебная функция ===
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


; === StrIsUpper: служебная функция ===
StrIsUpper(ch) {
    return (ch ~= "[A-ZА-ЯЁ]")
}


; === StrUpper: служебная функция ===
StrUpper(str) {
    StringUpper, out, str
    return out
}


; === StrLower: служебная функция ===
StrLower(str) {
    StringLower, out, str
    return out
}


; === DynamicPunish: служебная функция ===
DynamicPunish(cmdKey) {
    SendInput, %cmdKey%{Space}
    Input, playerId, V I M, {Enter}{Space}
    
    if (ErrorLevel != "EndKey:Enter" && ErrorLevel != "EndKey:Space")
        return
    if (playerId = "")
        return
    
    HandlePunishment(cmdKey, playerId)
}


; === HandlePunishment: служебная функция ===
HandlePunishment(cmdKey, playerId) {
    LineNumber := 0
    SendInput, ^a {BackSpace}{Enter}
    Sleep, 70
    requestCanRecall := false
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

        ; Не отправлять наказание, если причина уже испорчена кодировкой.
        if (InStr(reason, Chr(0xFFFD)) || RegExMatch(reason, "^(\?\s*){2,}$")) {
            ToolTip("[PUNISH] Ошибка кодировки причины. Проверьте punish.txt.", 4500)
            return
        }
        SendMessage, 0x50,, 0x4190419,, A
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Игрок " . playerName . "[" . playerId . "] определён. Уровень: " . playerLvl . ".`n↪︎ Выдаю: " . cmd . " " . playerId . " " . duration . " " . reason, 2332)
        ; SendEvent имитирует клавиши под RU-раскладкой; для GTA это
        ; надёжнее, чем Unicode KEYEVENTF_UNICODE, которым пользуется SendInput.
        fullPunishCommand := Trim(cmd . " " . playerId . " " . duration . " " . reason)
        SendInput, {F6}
        Sleep, 85
        SetKeyDelay, 25, 15
        SendEvent, % "{Raw}" . fullPunishCommand
        Sleep, 80
        SendEvent, {Enter}
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Введенный ID: " . playerId . ". Определенный игрок: " . playerName . "[" . playerDetectId . "]`n↪︎ Выдача наказания приостановлена.", 2332)
    }
}


; === IsGTAOpen: служебная функция ===
IsGTAOpen() {
    Process, Exist, gta_sa.exe
    
    return (ErrorLevel != 0)
}


; === logTimersOff: служебная функция ===
logTimersOff() {
    SetTimer, WatchKeys, Off
    SetTimer, respondComplaint, Off
    SetTimer, respondCommand, Off
}


; === spTimersOff: служебная функция ===
spTimersOff() {
    SetTimer, WatchKeys, Off
    SetTimer, WatchSpectate, Off
}


; === TimerFunc: служебная функция ===
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

; === humanReplyFunc: служебная функция ===
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
        requestCanRecall := false
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
        requestCanRecall := false
        SendInput, {F6}/pm %pID%{Space}
    }
}

Watch:
    spTimersOff()
    Sleep, 50
    autoSpectate()
Return

; === autoSpectate: служебная функция ===
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
        requestCanRecall := false
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
        requestCanRecall := false
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


; === Request: следующий /z без повторного набора всей команды ===
Request:
    if (requestBusy || ChatIsOpen || !WinActive("ahk_exe gta_sa.exe"))
        Return

    requestBusy := true

    ; Оставляем исходный ввод стартового ID прямо в чате игры.
    if (lastRequest == "") {
        requestCanRecall := false
        requestLastSent := ""
        SendMessage, 0x50,, 0x4190419,, A
        SendInput, {F6}[Автозапрос] Введите ID последнего запроса:{Space}
        Input, lastRequest, V I M, {Enter}{NumpadEnter}{Esc}
        inputResult := ErrorLevel
        lastRequest := Trim(lastRequest)
        ; Исходная очистка ввода в чате без лишнего Esc (не открыть pause menu).
        SendInput, ^a{Backspace}
        if ((inputResult != "EndKey:Enter" && inputResult != "EndKey:NumpadEnter") || !RegExMatch(lastRequest, "^[1-9][0-9]{0,11}$")) {
            lastRequest := ""
            requestBusy := false
            Return
        }
        ChatIsOpen := false
        requestBusy := false
        Return
    }

    nextRequest := "" . lastRequest
    ; Отправлять только положительные числа (проверка состояния счётчика).
    if (!RegExMatch(nextRequest, "^[1-9][0-9]{0,11}$")) {
        ToolTip("[REQUEST] Некорректный ID. Перезапустите скрипт для сброса.", 2500)
        requestBusy := false
        Return
    }

    if (isHumanInput) {
        if (requestLastSent != "") {
            change := RequestChangeDigits(requestLastSent, nextRequest)
            SendInput, {F6}
            Sleep, 90
            if (requestCanRecall) {
                ; ↑ поднимает последнюю /z без повторного ввода всей команды.
                SendInput, {Up}{End}
            } else {
                ; После другой команды не редактируем чужую историю.
                ; Восстанавливаем СВОЙ предыдущий /z единым вводом.
                previousCommand := "/z " . requestLastSent
                SendInput, %previousCommand%
            }
            Sleep, 90
            if (change.backspaces > 0) {
                erase := "{Backspace " . change.backspaces . "}"
                SendInput, %erase%
                Sleep, 90
            }
            RequestTypeChangedDigits(change.suffix)
        } else {
            ; Только первый /z ещё неоткуда вызывать стрелкой ↑.
            SendInput, {F6}/z{Space}
            Sleep, 90
            RequestTypeChangedDigits(nextRequest)
        }
        Sleep, 65
        SendInput, {Enter}
    } else {
        ; Автоматический режим не меняем.
        SendInput, {F6}/z %nextRequest%{Enter}
    }

    requestLastSent := nextRequest
    requestCanRecall := true
    lastRequest := nextRequest + 1
    ChatIsOpen := false
    requestBusy := false
Return

; === RequestChangeDigits: минимальная замена суффикса (9 -> 10, 99 -> 100) ===
RequestChangeDigits(previous, next) {
    previous := "" . previous
    next := "" . next
    same := 0
    n := StrLen(previous) < StrLen(next) ? StrLen(previous) : StrLen(next)
    Loop, %n%
    {
        if (SubStr(previous, A_Index, 1) != SubStr(next, A_Index, 1))
            break
        same := A_Index
    }
    return {backspaces: StrLen(previous) - same, suffix: SubStr(next, same + 1)}
}

; === RequestTypeChangedDigits: медленно печатаем ТОЛЬКО изменившиеся цифры ===
RequestTypeChangedDigits(digits) {
    global InputDelay1, InputDelay2
    dMin := InputDelay1 + 0
    dMax := InputDelay2 + 0
    if (dMin < 35 || dMin > 1000)
        dMin := 100
    if (dMax < dMin || dMax > 1500)
        dMax := dMin + 80
    Loop, Parse, digits
    {
        digit := A_LoopField
        if (!RegExMatch(digit, "^[0-9]$"))
            return false
        SendInput, %digit%
        Random, pauseMs, %dMin%, %dMax%
        Sleep, %pauseMs%
    }
    return true
}


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
    ; nickname уже закодирован, его нельзя кодировать повторно.
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


; === punishHelper: служебная функция ===
punishHelper() {
    global punishHelperStatus, punishFile, punishMap
    static initialized := false
    if (initialized || !punishHelperStatus || !FileExist(punishFile))
        return

    newMap := PunishReadConfig(punishFile)
    if (!IsObject(newMap) || newMap.Count() = 0) {
        ToolTip("[PUNISH] Не найдены правила или не удалось прочитать punish.txt", 3000)
        return
    }
    punishMap := newMap
    for cmdKey, fullCmd in punishMap {
        Hotstring(":*?:" . cmdKey . " ", Func("DynamicPunish").Bind(cmdKey))
        ruCmdKey := TransliterateToRussian(cmdKey)
        if (ruCmdKey != cmdKey)
            Hotstring(":*?:" . ruCmdKey . " ", Func("DynamicPunish").Bind(cmdKey))
    }
    initialized := true
}

; === PunishReadConfig: UTF-8 / резервное чтение старого CP1251 ===
PunishReadConfig(path) {
    source := FileOpen(path, "r", "UTF-8")
    if (!IsObject(source))
        return ""
    content := source.Read()
    source.Close()

    ; Для ANSI (CP1251) UTF-8-декодер ставит символы замены U+FFFD.
    if (InStr(content, Chr(0xFFFD))) {
        source := FileOpen(path, "r", "CP1251")
        if (!IsObject(source))
            return ""
        content := source.Read()
        source.Close()
    }

    newMap := {}
    Loop, Parse, content, `n, `r
    {
        line := Trim(A_LoopField, " `t")
        line := LTrim(line, Chr(0xFEFF))
        if (line = "" || RegExMatch(line, "^(;|#|//|--)"))
            continue
        if RegExMatch(line, "^\s*(/\w+)\s*=\s*(.+)$", m) {
            cmdKey := m1
            cmdValue := Trim(m2)
            if (cmdValue != "")
                newMap[cmdKey] := cmdValue
        }
    }
    return newMap
}



; ============================================================================================================================
; #region || ОТВЕТЫ РЕПОРТОВ: answer-rules.txt (ключ = ответ)
; === DefaultAnswerRulesText: встроенные 91 правило ответа для первого запуска ===
DefaultAnswerRulesText() {
    rules := ""
    rules .= "# ViMeLlY Script: ключ = ответ`r`n"
    rules .= "# UTF-8, одна запись на строку. Не удаляйте сам файл.`r`n"
    rules .= "# Не используйте знак = в ключе.`r`n"
    rules .= "свалк = Свалка: 7:00, 11:00, 14:00, 19:00, 23:00.`r`n"
    rules .= "конт = Контейнеры: 8:00, 12:00, 16:00, 20:00, 00:00.`r`n"
    rules .= "адвокат = Список адвокатов -> /adlist. Гражданское лицо: 15.000, гос.организации: 20.000, ОПГ/Банды: 30.000 р. (КПЗ), ФСИН: 30.000.`r`n"
    rules .= "лиц = В Правительстве(/liclist). Права: 10.000; проф.права: 40.000; рыбалка: 40.000; охота: 65.000; оружие: 85.000 руб.`r`n"
    rules .= "мед = Мед.карту можно получить в больнице г.Арзамас. Чтобы проверить медиков в сети, используйте: /medlist.`r`n"
    rules .= "номер = Снять номер: /take_number. Поставить: I - Использовать.`r`n"
    rules .= "чат = /pagesize - строки, /fontsize - шрифт, /timestamp - время.`r`n"
    rules .= "чат банд = Чат банды/семьи: /nfm - RP(IC), /fm - NRP(OOC).`r`n"
    rules .= "гараж = Гаражные места по классам: Низкий - 1; Средний - 5; Высокий - до 17 мест.`r`n"
    rules .= "киоск = Вернуть предметы: /return_items.`r`n"
    rules .= "работ увол = Уволиться: /myjobs, /leave.`r`n"
    rules .= "увол = Уволить игрока в онлайне - /unvinvite. | В оффлайне - /uninviteoff.`r`n"
    rules .= "увал = Уволить игрока в онлайне - /unvinvite. | В оффлайне - /uninviteoff.`r`n"
    rules .= "выйти семь = Покинуть семью: /family_leave.`r`n"
    rules .= "выйти банд = Покинуть банду: /family_leave.`r`n"
    rules .= "снять наручн = Снять наручники: /uncuff.`r`n"
    rules .= "розыск = Выдать игроку розыск: /su.`r`n"
    rules .= "наручн = Надеть наручники: /cuff.`r`n"
    rules .= "чин = Не чиним автомобили. Вызывайте механиков(/c 090), либо используйте рем.комплект.`r`n"
    rules .= "чен = Не чиним автомобили. Вызывайте механиков(/c 090), либо используйте рем.комплект.`r`n"
    rules .= "пневм = Управлять пневмоподвеской: /spanel.`r`n"
    rules .= "гидр = Включить/Выключить гидравлику: Кнопка H.`r`n"
    rules .= "ключ = Передать ключи от машины: /allow.`r`n"
    rules .= "аук = Аукцион идет 24ч с момента появления слота.`r`n"
    rules .= "слет = Слет каждый час, с 8:00 до 23:00. Кроме отелей.`r`n"
    rules .= "букс = Починить авто: /repair | Предложить буксировку на СТО: /tow | Подцепить машину: /at.`r`n"
    rules .= "подцеп = Починить авто: /repair | Предложить буксировку на СТО: /tow | Подцепить машину: /at.`r`n"
    rules .= "посмотреть мед = Посмотреть свою мед.карту: /showmc.`r`n"
    rules .= "продать кв = Продать квартиру/дом игроку: /sellmyhome | Государству: /sellhome.`r`n"
    rules .= "продать дом = Продать квартиру/дом игроку: /sellmyhome | Государству: /sellhome.`r`n"
    rules .= "продать огород = Продать огород игроку: /sellmygarden | Государству: /sellgarden.`r`n"
    rules .= "продать киоск = Продать киоск игроку: /sellmystall | Государству: /sellstall.`r`n"
    rules .= "стил бо = Изменить стиль боя: /set_style`r`n"
    rules .= "отм заказ = Отменить заказ механика: /to | Такси: /phone - Приложение такси.`r`n"
    rules .= "отм вызов = Отменить вызов: /to.`r`n"
    rules .= "приглас = Пригласить игрока в семью/банду/фракцию: /invite.`r`n"
    rules .= "приглос = Пригласить игрока в семью/банду/фракцию: /invite.`r`n"
    rules .= "инвайт = Пригласить игрока в семью/банду/фракцию: /invite.`r`n"
    rules .= "принять = Пригласить игрока в семью/банду/фракцию: /invite.`r`n"
    rules .= "выкин авто = Выкинуть игрока из своего авто: /eject | Выкинуть из авто(МВД, ФСБ): /ejectout.`r`n"
    rules .= "спавн = Изменить место появления при заходе в игру: /setspawn.`r`n"
    rules .= "спавн банд = Изменить место появления для банды: /gang_spawn.`r`n"
    rules .= "авто банд = Добавить авто в банду: /gang_car.`r`n"
    rules .= "уволить = Уволить игрока из фракции/банды/семьи: /uninvite.`r`n"
    rules .= "ранг банд = Изменить игроку ранг в банде/семье: /frank.`r`n"
    rules .= "ранг семь = Изменить игроку ранг в банде/семье: /frank.`r`n"
    rules .= "ранг = Изменить ранг игроку во фракции: /rang.`r`n"
    rules .= "выда мед = Выдать мед.карту игроку: /medcard.`r`n"
    rules .= "раци = Рация организации/ТК: /r - RP(IC) | /rr - NRP(OOC).`r`n"
    rules .= "заказы дальноб = Посмотреть активные заказы на работе дальнобойщика: /bizlist - продукты | /fuellist - топливо.`r`n"
    rules .= "обмен = Чтобы провести обмен с игроком, нажмите: R - Персонаж - Обмен предметами.`r`n"
    rules .= "обмен нотар = Провести обмен в нотариальном агенстве: /exchange.`r`n"
    rules .= "багаж = Открыть багажник на личном авто: /trunk.`r`n"
    rules .= "паспорт = Показать свой паспорт: /pass.`r`n"
    rules .= "вб = Посмотреть военный билет: /pass.`r`n"
    rules .= "воен билет = Посмотреть военный билет: /pass.`r`n"
    rules .= "тест = Предложить тест-драйв игроку: /cm_test_drive.`r`n"
    rules .= "шины = Поменять шины на авто: /replace_tire.`r`n"
    rules .= "сигнал = Установить сигнализацию на авто: /set_alarm.`r`n"
    rules .= "мп = Ожидайте. О проведении Мероприятия уведомят в чате.`r`n"
    rules .= "рвс = Ожидайте. О проведении Респавна авто уведомят в чате.`r`n"
    rules .= "рвц = Ожидайте. О проведении Респавна авто уведомят в чате.`r`n"
    rules .= "респ = Ожидайте. О проведении Респавна авто уведомят в чате.`r`n"
    rules .= "rwc = Ожидайте. О проведении Респавна авто уведомят в чате.`r`n"
    rules .= "шкаф = Переставить шкаф: /makestore | Открыть: /use.`r`n"
    rules .= "продать биз = Продать бизнес игроку: /sellmybiz | Государству: /sellbiz.`r`n"
    rules .= "собес = Посмотреть активные события в игре: /events.`r`n"
    rules .= "удост = Показать свое удостоверение: /doc.`r`n"
    rules .= "сня брон = Снять бронежилет: /armoff.`r`n"
    rules .= "акс = Снять все надетые аксессуары: /reset | Надеть: /put_on.`r`n"
    rules .= "акс дом = Редактировать аксессуары дома/бизнеса: /pa_edit.`r`n"
    rules .= "акс биз = Редактировать аксессуары дома/бизнеса: /pa_edit.`r`n"
    rules .= "пожен = Предложение руки и сердца: /wedding | Развестись: /divorce.`r`n"
    rules .= "развод = Предложение руки и сердца: /wedding | Развестись: /divorce.`r`n"
    rules .= "свадьб = Чтобы сыграть свадьбу, необходимо купить обручальные кольца в магазине аксессуаров.`r`n"
    rules .= "бой = Вызвать на бой другого игрока в спорт.зале: /fight.`r`n"
    rules .= "выкл телеф = Включить/Выключить телефон: /togphone.`r`n"
    rules .= "ч с фрак = Добавить в черный список организации: /blist.`r`n"
    rules .= "ч с орг = Добавить в черный список организации: /blist.`r`n"
    rules .= "ч с телеф = Добавить номер в черный список: /phone_black.`r`n"
    rules .= "наказ = Посмотреть список наказаний: /alist | Если посадили в КПЗ/ФСИН: Радиальное меню(R) - другое - личное дело.`r`n"
    rules .= "перев = Мы не переворачиваем авто. Используйте: /c 090, помощь друга (R - транспорт - перевернуть авто), домкрат.`r`n"
    rules .= "бумбокс = Поставить бумбокс: /boombox_put | Поднять: /boombox_pick.`r`n"
    rules .= "нарко = Продать наркотики: /selldrugs.`r`n"
    rules .= "прод оруж = Продажа/Передача оружия производится через обмен. R - Персонаж - Обмен предметами.`r`n"
    rules .= "тайм капт = Убрать таймер капта - /capture_timer.`r`n"
    rules .= "капт биз = Провести войну за бизнес - /capture_biz.`r`n"
    rules .= "наград = Посмотреть награды: /mn - Награды | Забрать отыграный промокод: /plist.`r`n"
    rules .= "поворот голов = Включить/Выключить движение головы: /headmove.`r`n"
    rules .= "подселить = Подселить человека - /live.`r`n"
    rules .= "выписат = Выписаться из совместного проживания - /liveout.`r`n"
    return rules
}

; === EnsureAnswerRulesFile: создает конфиг в Документах при отсутствии ===
EnsureAnswerRulesFile() {
    global scriptDir, answerRulesFile

    ; Пользовательский файл никогда не перезаписываем — даже пустой.
    if (FileExist(answerRulesFile))
        return true

    if (!FileExist(scriptDir)) {
        FileCreateDir, %scriptDir%
        if (ErrorLevel)
            return false
    }

    ; Совместимость со старыми установками: перенести конфиг рядом с EXE/AHK.
    legacyPath := A_ScriptDir . "\answer-rules.txt"
    if (FileExist(legacyPath)) {
        FileCopy, %legacyPath%, %answerRulesFile%, 0
        if (FileExist(answerRulesFile))
            return true
    }

    ; Для чистой установки всё встроено в ОДИН AHK/EXE.
    defaultRules := DefaultAnswerRulesText()
    if (defaultRules = "")
        return false

    ; Запись во временный файл: не оставлять обрезанный answer-rules.txt.
    tempPath := answerRulesFile . ".tmp." . A_TickCount
    FileDelete, %tempPath%
    FileAppend, %defaultRules%, %tempPath%, UTF-8
    if (ErrorLevel) {
        FileDelete, %tempPath%
        return false
    }

    ; Flag=0: ни при каких обстоятельствах не заменять существующий файл.
    FileMove, %tempPath%, %answerRulesFile%, 0
    moved := !ErrorLevel
    if (!moved)
        FileDelete, %tempPath%
    return FileExist(answerRulesFile) ? true : false
}


; === LoadAnswerRules: служебная функция ===
LoadAnswerRules() {
    global answerMap, answerRulesFile, answerRulesLoaded, scriptDir
    ; При необходимости создаёт встроенную базу при первом запуске.
    if (!EnsureAnswerRulesFile()) {
        answerRulesLoaded := false
        return false
    }

    if (!FileExist(answerRulesFile)) {
        answerRulesLoaded := false
        return false
    }
    FileRead, rulesContent, *P65001 %answerRulesFile%
    if (ErrorLevel)
        return false
    updated := {}
    Loop, Parse, rulesContent, `n, `r
    {
        line := LTrim(Trim(A_LoopField, " `t"), Chr(0xFEFF))
        if (line = "" || SubStr(line, 1, 1) = "#" || SubStr(line, 1, 1) = ";")
            continue
        separator := InStr(line, "=")
        if (!separator)
            continue
        key := Trim(SubStr(line, 1, separator - 1))
        value := Trim(SubStr(line, separator + 1))
        if (key != "" && value != "")
            updated[key] := value
    }
    ; Атомарно заменить таблицу, чтобы частичная запись не пропала при ошибке чтения.
    answerMap := updated
    answerRulesLoaded := true
    return true
}

; === answerLogger: обработка новых репортов ===
answerLogger() {
    global settingsFile, answerMap, answerRulesLoaded, reportLog
    global answerComplaint, answerCommand, ansLogID, ansAuthor, playerId
    global adminName, targetID, targetPunish
    if (!reportLog)
        return
    if (!answerRulesLoaded)
        LoadAnswerRules()
    IniRead, kR, %settingsFile%, Keys, Reply
    targetPunish := ""
    ; Карта правил загружается при старте; повторного чтения в каждом тике нет.
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
    for _, line in ChatlogReadNew("reports") {
        if RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]: (.+)", match) {
            SetTimer, respondComplaint, Off
            SetTimer, respondCommand, Off
            Reports := match4
            ansLogID := match3
            ansAuthor := match2
            playerId := ansLogID
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
        }
    }
}


; === respondComplaint: служебная функция ===
respondComplaint() {
    global hotkeys, answerComplaint, playerId
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P") {
            logTimersOff()
            Sleep, 100
            SendMessage, 0x50,, 0x4190419,, A
            sendReply(playerId, answerComplaint)
            ToolTip("[𝐑𝐄𝐏𝐋𝐘] Игроку был дан ответ.", 3300)
        }
    }
}


; === respondCommand: служебная функция ===
respondCommand() {
    global hotkeys, answerCommand, ansLogID, isHumanInput
    global CMDDelay, InputDelay1, InputDelay2
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



autoEdit:
    ; AutoEdit и AutoBizlist имеют разные флаги — не выключают друг друга.
    if (!autoEditActive) {
        ChatlogWatchFromNow("autoedit")
        autoEditActive := true
        SetTimer, autoEditFunc, 150
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoEdit включена. Ожидание нового объявления...", 2332)
    } else {
        SetTimer, autoEditFunc, Off
        autoEditActive := false
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoEdit выключена.", 2000)
    }
Return


; === autoEditFunc: служебная функция ===
autoEditFunc() {
    global autoEditActive, ChatIsOpen, requestCanRecall
    ; Не отправлять /edit, если игра не активна или пользователь пишет в чат.
    if (!autoEditActive || !WinActive("ahk_exe gta_sa.exe") || ChatIsOpen)
        return
    for _, line in ChatlogReadNew("autoedit") {
        if (InStr(line, "Добавлено новое объявление. Используйте: /edit для модерации")) {
            requestCanRecall := false
            SendInput, {F6}/edit{Enter}
            Sleep, 250
            SendInput, {Enter}
            Sleep, 250
            SendInput, {Enter}
            Sleep, 250
            SendInput, {Down}
            Sleep, 250
            SendInput, {Enter}
            autoEditActive := false
            SetTimer, autoEditFunc, Off
            break
        }
    }
}


global onOrder := false


autoBizlist:
    if (!autoBizlistActive && !onOrder) {
        ChatlogWatchFromNow("orders")
        autoBizlistActive := true

        SetTimer, CatchingAnOrder, 250
        SetTimer, WaitingForOrderInChat, 250
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoBizlist включена. Ожидание нового заказа...", 2332)
    } else {
        autoBizlistActive := false
        onOrder := false

        SetTimer, CatchingAnOrder, Off
        SetTimer, WaitingForOrderInChat, Off

        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Функция AutoBizlist выключена.", 2332)
    }
Return


; === CatchingAnOrder: ловля заказа по времени ===
CatchingAnOrder() {
    global autoBizlistActive, onOrder, ChatIsOpen, isHumanInput, requestCanRecall
    static lastBizlistAttempt := 0
    if (!autoBizlistActive || onOrder || ChatIsOpen || !WinActive("ahk_exe gta_sa.exe"))
        return

    IniRead, minutesOfCatching1, %settingsFile%, Preset, minutesOfCatching1, ERROR
    IniRead, minutesOfCatching2, %settingsFile%, Preset, minutesOfCatching2, ERROR
    ; Пока обе секунды не настроены, автоматизация молчит, а не спамит /bizlist.
    if (!RegExMatch(minutesOfCatching1, "^\d{1,2}$") || !RegExMatch(minutesOfCatching2, "^\d{1,2}$"))
        return
    if (minutesOfCatching1 < 0 || minutesOfCatching1 > 59 || minutesOfCatching2 < 0 || minutesOfCatching2 > 59)
        return
    isEven := (Mod(A_Min, 2) = 0)
    if ((!isEven && A_Sec >= minutesOfCatching1) || (isEven && A_Sec < minutesOfCatching2)) {
        ; Таймер работает часто, но отправляем не чаще раза в 5 секунд.
        if (lastBizlistAttempt && (A_TickCount - lastBizlistAttempt) < 5000)
            return
        lastBizlistAttempt := A_TickCount
        if (isHumanInput) {
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
            requestCanRecall := false
            SendInput, {F6}/bizlist{Enter}
            Sleep, 150
            SendInput, {Enter}
            Sleep, 165
            SendInput, {Enter}
            Sleep, 350
        }
    }
}


; === WaitingForOrderInChat: ловля заказа по сообщению из чата ===
WaitingForOrderInChat() {
    global autoBizlistActive, ChatIsOpen, requestCanRecall
    if (!autoBizlistActive || ChatIsOpen || !WinActive("ahk_exe gta_sa.exe"))
        return
    for _, line in ChatlogReadNew("orders") {
        if (IsNewTruckerOrderMessage(line)) {
            autoBizlistActive := false
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
                requestCanRecall := false
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


; === IsNewTruckerOrderMessage: распознавание нового формата уведомления ТК ===
; Пример: [22:51:58] [Транспортная компания] {ffffff}Поступил новый заказ: продукци — 4320 ед. для Аптека 'Оптимальная'
; Цветовые коды не влияют на распознавание; количество определяет сама игра.
IsNewTruckerOrderMessage(line) {
    clean := RegExReplace(line, "\{[0-9A-Fa-f]{6,8}\}", "")
    if (!InStr(clean, "[Транспортная компания]"))
        return false
    return !!RegExMatch(clean, "Поступил новый заказ:\s*продукц[^0-9\r\n]*\d+\s*ед\.\s*для\s*\S")
}


; === ExpectationOfProfit: Таблица заработка ===
ExpectationOfProfit() {
    global onOrder, autoBizlistActive
    
    ; Экономика также обрабатывает только новые полные строки после запуска.
    for _, line in ChatlogReadNew("profit") {
        if (InStr(line, "Вы продали")) {
            if (RegExMatch(line, "\{FFFFFF\}""(.*?)"" .*?\{FFFFFF\}(\d+) .*?\{FFFFFF\}(\d+)", match)) {
                itemName  := match1
                itemCount := match2
                itemPrice := match3
                FormatTime, CurrentTime,, dd.MM.yyyy HH:mm:ss
                LogString := CurrentTime . ", " . itemPrice . " руб, " . (InStr(itemName, "Шкур") ? """Продажа шкур" : """Продажа урожая") . ", " . itemName . ": " . itemCount . " шт.""`n"
                FileAppend, %LogString%, %scriptDir%\orderHistory.csv, UTF-8
                earnings := RegExReplace(itemPrice, "(\d)(?=(\d{3})+(?!\d))", "$1.")
                ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Продано " . itemCount . " шт. Заработано: " . earnings . " руб.", 2000)
            }
        } else if (InStr(line, "Вы доставили")) {
            ; Не записывать случайные строки "Вы доставили" с пустой/старой суммой.
            matchedDelivery := false
            if RegExMatch(line, "доставили\s\{[a-z0-9]{6}\}(\d+).*?«\{[a-z0-9]{6}\}(.*?)\{[a-z0-9]{6}\}».*?получили\s\{[a-z0-9]{6}\}(\d+)", match) {
                itemCount := match1
                shopName := match2
                earnings := match3
                matchedDelivery := true
            } else if RegExMatch(line, "Вы доставили\s\{[a-z0-9]{6}\}(\d+).*?получили за работу\s\{[a-z0-9]{6}\}(\d+)", match) {
                itemCount := match1
                shopName := "Стройка 'Южный'"
                earnings := match2
                matchedDelivery := true
            }
            if (!matchedDelivery)
                continue

            ; После подтвержденной доставки можно ловить следующий заказ.
            onOrder := false
            FormatTime, CurrentTime,, dd.MM.yyyy HH:mm:ss
            LogString := CurrentTime . ", " . earnings . " руб, " . """Доставка продуктов, " . shopName . ": " . itemCount . " ед.""`n"
            FileAppend, %LogString%, %scriptDir%\orderHistory.csv, UTF-8
            TruckerIncome := GetIncomeByDate(A_DD . "." . A_MM . "." . A_YYYY, "Доставка продуктов")
            
            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Доставлено " . itemCount . " ед. товара п/п: " . shopName . ". Прибыль: " . earnings . " руб. `n↪︎Общая прибыль за сегодня: " . TruckerIncome . " руб.", 11111)
        } else if (InStr(line, "Вы начали выполнение заказа.")) {
            SetTimer, WaitingForOrderInChat, Off
            SetTimer, CatchingAnOrder, Off

            onOrder := true
            autoBizlistActive := false

            SoundBeep, 1800, 100
            SoundBeep, 1800, 100
            SoundBeep, 1800, 100
            SoundBeep, 1800, 100
            Sleep, 333
            
            if (ChatIsOpen) {
                SendInput, {BS 128}{Esc}
                ChatIsOpen := false
            }

            ; Загрузка и ввод количества выполняются игрой автоматически.
            ; Никаких дополнительных /bizlist, цифр или RShift после принятия заказа.
        }
    }
}

; === ToolTip: показ уведомления с учётом настроек ===
ToolTip(text, delay) {
    global isToolTipActive
    if (isToolTipActive) {
        ToolTip, %text%
        SetTimer, clearToolTip, -%delay%
    }
}


; === clearToolTip: служебная функция ===
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


Enter::
    ; Пока меню открыто, Enter выполняет выбранную кнопку и не передаётся игре.
    if (MenuKeyboardEnabled()) {
        MenuActivateSelected()
        return
    }
    ; В обычном режиме сохраняем исходное поведение игрового Enter.
    if (ChatIsOpen && !requestBusy)
        requestCanRecall := false
    ChatIsOpen := false
    SendInput, {Enter}
return

NumpadEnter::
    if (MenuKeyboardEnabled()) {
        MenuActivateSelected()
        return
    }
    if (ChatIsOpen && !requestBusy)
        requestCanRecall := false
    ChatIsOpen := false
    SendInput, {NumpadEnter}
return

Escape::
    ; Esc закрывает меню/возвращает назад, иначе передаётся игре.
    if (MenuKeyboardEnabled()) {
        MenuKeyboardEscape()
        return
    }
    ChatIsOpen := false
    SendInput, {Escape}
return



#If

; === ReportDiagnostics: проверка настроек, таблицы ответов и последних строк ===
; Ctrl+Shift+F10 не меняет курсор штатного читателя репортов.
ReportDiagnostics() {
    global filePath, settingsFile, reportLog, scriptMode, answerMap, answerRulesLoaded
    global answerRulesFile, isToolTipActive
    IniRead, storedReport, %settingsFile%, Preset, reportLog, ERROR
    IniRead, storedMode, %settingsFile%, Preset, scriptMode, ERROR

    ruleCount := IsObject(answerMap) ? answerMap.Count() : 0
    fileState := FileExist(filePath) ? "файл найден" : "ФАЙЛ НЕ НАЙДЕН"
    phantomFound := "нет"
    reportParsed := "нет"
    processedState := "нет репорта для проверки"
    fileReadable := "нет"

    if (FileExist(filePath)) {
        source := FileOpen(filePath, 0x300, "CP0")
        if (IsObject(source)) {
            fileReadable := "да"
            ; Берём последние 16 КБ, не двигая рабочий курсор ChatlogReadNew.
            source.Pos := (source.Length > 16384) ? source.Length - 16384 : 0
            tail := source.Read()
            source.Close()
            if (InStr(tail, "Debug_Player[99]"))
                phantomFound := "да"
            lastTestLine := ""
            Loop, Parse, tail, `n, `r
                if (InStr(A_LoopField, "Debug_Player[99]"))
                    lastTestLine := A_LoopField
            if (lastTestLine != "") {
                lastTestHash := HashLine(lastTestLine)
                IniRead, wasSeen, %settingsFile%, ProcessedLines, %lastTestHash%, ERROR
                processedState := (wasSeen = "ERROR") ? "ещё не отмечен" : "отмечен как обработанный"
            }
            if (RegExMatch(tail, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]: (.+)"))
                reportParsed := "да"
        }
    }
    result := "ПУТЬ: " . filePath
      . "`nФайл: " . fileState . ", чтение: " . fileReadable
      . "`nФантом найден в последних 16 КБ: " . phantomFound
      . "`nФантом в ProcessedLines: " . processedState
      . "`nЕсть строка формата RADMIR: " . reportParsed
      . "`nРежим: " . scriptMode . " (INI: " . storedMode . ")"
      . "`nЛог жалоб: " . reportLog . " (INI: " . storedReport . ")"
      . "`nОтветы загружены: " . answerRulesLoaded . "; правил: " . ruleCount
      . "`nФайл правил: " . answerRulesFile
      . "`nПодсказки: " . isToolTipActive
    MsgBox, 64, ViMeLlY Report Diagnostics, %result%
}


; === Keyboard navigation for non-activating always-on-top menus ===
#If MenuKeyboardEnabled()
Up::MenuNavigate(-1)
Down::MenuNavigate(1)
Left::MenuNavigate(-1)
Right::MenuNavigate(1)
Tab::MenuNavigate(1)
+Tab::MenuNavigate(-1)
Enter::MenuActivateSelected()
NumpadEnter::MenuActivateSelected()
Esc::MenuKeyboardEscape()
#If

; === MenuKeyboardEscape: Esc closes main menu or returns from a submenu ===
MenuKeyboardEscape() {
    global menuNavGuiName
    if (!MenuKeyboardEnabled())
        return
    if (menuNavGuiName = "ViMeLlY")
        CloseMenuWindows()
    else
        ReturnToMainMenu()
}
