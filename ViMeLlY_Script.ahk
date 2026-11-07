#SingleInstance, Force
#Persistent
#NoEnv
#NoTrayIcon

SetTitleMatchMode, 2
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

global version := "v 1.7.6"
global LicenseURL := "aHR0cHM6Ly9naXN0LmdpdGh1YnVzZXJjb250ZW50LmNvbS9NYWtzaW00ZWtrL2Jl`nMmQ0MjE5MzE1NjFkZDAxYjQzM2Y5M2NhNTMyOWQwL3Jhdy9WaU1lTGxZLWtleXMu`ndHh0"
; Соль хэша лицензии. Должна совпадать с солью в ViMeLlY_LicenseTool.ahk. После выхода версии с хэшами не менять.
global LicenseSalt := "ViMeLlY-lic-v1"

global repID, ansID, ansLogID
global spReplyTarget := ""
global menuHoverHwnd := 0
global spActiveSeq := 0, spActiveUntil := 0, spStage := 0, spTargetTitle := "", spSpecID := ""
global reportPanelHidden := false
global helpMenu := "", helpKey := "", helpReturn := "", helpDirect := false
global helpBtnMap := {}
global serverUTCOffset := 3
global reportPanelEnabled := 1
global reportPanelNum := 41
global reportPanelSig := ""
global reportPanelRows := []
global reportPanelAgeHwnds := []
global autoSpSeq := 0
global interactID := ""
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
global punishWordsFile := scriptDir . "punish-words.txt"
global autoIssueFile := scriptDir . "auto-issue.txt"
global issueRunning := false
global issueAbort := false
global issueState := {}
global autoSpMode := 1
global autoSpPool := 5
global autoSpReports := []
global autoSpSeeded := false
global ntfList := []
global ntfHint := ""
global hintQueue := []
global hintArmKind := ""
global answerSeen := {}
global answerSeenOrder := []
global answerRulesMTime := ""
global autoSpMaxAge := 180
global settingsOpen := false
global offlineTarget := ""
global offlineText := ""
global offlineUntil := 0
global intSaved := {}
global intOpen := false
global answerMap := {}
global answerRulesLoaded := false
global punishWordsList := []
global punishWordsLoaded := false
global punishWordsMTime := ""
global automationQueue := []
global automationBusy := false
global automationLastSent := 0
global answerComplaint, answerCommand, responses
global filePath := FindChatlogPath()
global lastReadLine := checkChatLog()
global lastLineNum
global requestBusy := false
global requestLastSent := ""
global requestCanRecall := false
global truckerSettings := false
global scriptSettings := false
global isToolTipActive
global ntfCorner := 3
global punishConfirmEnabled := 1
global punishConfirmState := ""
global punishConfirmArmed := false
global today := StatsToday()
global menuNavItems := []
global menuNavIndex := 0
global menuNavGuiName := ""
global menuNavGuiHwnd := 0
global CurrentHWID, EnteredKey, onOrder
OnMessage(0x21, "MenuMouseActivate")
OnMessage(0x200, "MenuMouseMove")

SetTimer, InitializeViMeLlY, -50

IniRead, scriptModeStatus, %settingsFile%, Preset, scriptMode
global scriptMode := scriptModeStatus

IniRead, userNickname, %settingsFile%, Preset, userNickname
IniRead, rL, %settingsFile%, Preset, reportLog
IniRead, pH, %settingsFile%, Preset, punishHelperStatus
IniRead, aF, %settingsFile%, Preset, additionalFeaturesStatus
IniRead, aS, %settingsFile%, Preset, adminStatsStatus
IniRead, isToolTipActive, %settingsFile%, Preset, isToolTipActive, 1
IniRead, punishConfirmEnabled, %settingsFile%, Preset, punishConfirm, 1
punishConfirmEnabled := (punishConfirmEnabled = 0) ? 0 : 1
IniRead, ntfCorner, %settingsFile%, Preset, ntfCorner, 3
ntfCorner := (ntfCorner >= 1 && ntfCorner <= 5) ? ntfCorner + 0 : 3
isHumanInput := (IniReadRetry("Preset", "isHumanInput", 0) = 1) ? 1 : 0
IniRead, autoSpMode, %settingsFile%, Preset, autoSpMode, 1
autoSpMode := (autoSpMode = 2 || autoSpMode = 3) ? autoSpMode + 0 : 1
IniRead, autoSpPool, %settingsFile%, Preset, autoSpPool, 5
autoSpPool := (autoSpPool >= 1 && autoSpPool <= 10) ? autoSpPool + 0 : 5
IniRead, autoSpMaxAge, %settingsFile%, Preset, autoSpMaxAge, 180
autoSpMaxAge := (autoSpMaxAge = 30 || autoSpMaxAge = 60 || autoSpMaxAge = 120 || autoSpMaxAge = 180 || autoSpMaxAge = 300) ? autoSpMaxAge + 0 : 180
IniRead, reportPanelEnabled, %settingsFile%, Preset, reportPanel, 1
reportPanelEnabled := (reportPanelEnabled = 0) ? 0 : 1
IniRead, serverUTCOffset, %settingsFile%, Preset, serverUTCOffset, 3
serverUTCOffset := (RegExMatch(serverUTCOffset, "^-?\d+$") && serverUTCOffset >= -12 && serverUTCOffset <= 14) ? serverUTCOffset + 0 : 3

ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Инициализация скрипта...", 300)

reportLog := (rL = "1") ? 1 : 0
punishHelperStatus := (pH = "1") ? 1 : 0
additionalFeaturesStatus := (aF = "1") ? 1 : 0
adminStatsStatus := (aS = "1") ? 1 : 0

Sleep, 300
ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ViMeLlY Script (" . version . ") загружен. Приятного пользования!", 777)

Stub:
Return


; ====================================================================================================================
; ИНИЦИАЛИЗАЦИЯ
; ====================================================================================================================

; === InitializeViMeLlY: единоразовый запуск независимо от автообновления ===
InitializeViMeLlY() {
    global scriptMode, scriptType, isHumanInput, reportLog, additionalFeaturesStatus
    global additionalFeaturesFile, pid, settingsFile
    global punishHelperStatus, punishFile
    scriptSettingsChecker()
    IniRead, savedScriptMode, %settingsFile%, Preset, scriptMode, %scriptType%
    scriptMode := (savedScriptMode = "Admin" || savedScriptMode = "Player") ? savedScriptMode : scriptType
    isHumanInput := (IniReadRetry("Preset", "isHumanInput", isHumanInput) = 1) ? 1 : 0

    LoadAnswerRules()
    ChatlogWatchFromNow("reports")
    ChatlogWatchFromNow("profit")
    LoadHotkeys()
    BindHotkeys()
    SetTimer, ChatStateWatch, 300
    SetTimer, InputSettingsGuard, 5000
    if (scriptMode = "Admin") {
        ReportPanelApply()
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
    SetTimer, checkUpdates, -1200
}


; ====================================================================================================================
; ЛИЦЕНЗИЯ И ОБНОВЛЕНИЕ
; ====================================================================================================================

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
    
    RawKeys := SecureHttpText(license)
    if (RawKeys = "") {
        MsgBox, 16, Ошибка сети, Сервер лицензий недоступен или TLS не прошёл проверку.`nПроверьте интернет и системное время. Ключ не удалён.
        ExitApp
    }
    IsValid := false
    scriptType := ""
    keyHash := LicenseHash(SavedKey, CurrentHWID)
    Loop, Parse, RawKeys, `n, `r
    {
        CurrentLine := Trim(A_LoopField)
        if (CurrentLine = "" || SubStr(CurrentLine, 1, 1) = "#")
            continue
        Parts := StrSplit(CurrentLine, [":", "="])
        ; Запись «хэш:Тип»: ник и HWID в списке не хранятся, хэш считается от ключа и HWID этого компьютера.
        ; Старые версии скрипта такие строки пропускают (в них меньше трёх частей).
        if (Parts.Length() = 2 && RegExMatch(Trim(Parts[1]), "i)^[0-9a-f]{64}$")) {
            hashType := Trim(Parts[2])
            if (keyHash != "" && Trim(Parts[1]) = keyHash && (hashType == "Admin" || hashType == "Player")) {
                IsValid := true
                userNickname := LicenseNicknameB64(SavedKey)
                scriptType := hashType
                break
            }
            continue
        }
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

; === checkUpdates: обновление скрипта ===
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
            MsgBox, 64, ViMeLlY Script, % "Найдена версия " . serverVersion . ". Обновления отключены для исходного .ahk."
        } else {
            MsgBox, 36, ViMeLlY Script, % "Доступна новая версия " . serverVersion . ". Загрузить и установить?"
            IfMsgBox, Yes
                SecureInstallUpdate(remoteExeUrl)
        }
    }
    return
}

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

; ====================================================================================================================
; СЛУЖЕБНЫЕ ФУНКЦИИ
; ====================================================================================================================

; === ToolTip: показ уведомления с учётом настроек ===
ToolTip(text, delay) {
    global isToolTipActive
    if (!isToolTipActive)
        return
    title := "ViMeLlY"
    body := text
    if (RegExMatch(text, "s)^\[([^\]]+)\]\s*(.*)$", m)) {
        title := m1
        body := m2
    }
    if (StrLen(body) > 260)
        body := SubStr(body, 1, 260) . "…"
    low := body
    StringLower, low, low
    accent := "4C8DFF"
    if (RegExMatch(low, "(не найден|не записан|нет ответа|отмен|истекло|не удалось|ошибк|лимит|пропущена)"))
        accent := "FF9F43"
    else if (RegExMatch(low, "(успешно|записан:|выдано|дан ответ|был наказан|готово|загружен|запущен)"))
        accent := "2ECC71"
    NtfShow(title, title, body, accent, delay)
}

clearToolTip() {
    ToolTip
}

; ============================== Плашки-уведомления на GUI ==============================
; Все сообщения скрипта (бывшие ToolTip) показываются плашками в выбранном месте окна игры (по умолчанию — слева по центру;
; меняется в настройках скрипта, параметр ntfCorner). Плашки не забирают фокус
; и пропускают клики мыши. Сообщение с тем же тегом [ТЕГ] заменяет прежнее. Подсказка-ответ (репорт/оффлайн) — отдельная
; плашка сверху с обратным отсчётом; следующая подсказка из очереди показывается, когда текущая закрыта или истекла.

; === NtfAnchor: область окна игры (или всего экрана): левый верхний угол, ширина и высота ===
NtfAnchor(ByRef ax, ByRef ay, ByRef aw, ByRef ah) {
    ax := 0
    ay := 0
    aw := A_ScreenWidth
    ah := A_ScreenHeight
    WinGetPos, gx, gy, gw, gh, ahk_exe gta_sa.exe
    if (gw > 200 && gh > 200 && gx > -30000) {
        ax := gx
        ay := gy
        aw := gw
        ah := gh
    }
}


; === NtfBuild: строит окно плашки (скрытым) и возвращает {hwnd, w, h} ===
NtfBuild(num, w, title, body, action, foot, accent, bar) {
    ; Переменные контролов внутри функции обязаны быть глобальными (иначе ошибка «control's variable must be global or static»).
    global NtfEnd31, NtfEnd32, NtfEnd33, NtfEnd34, NtfEnd35, NtfEnd36, NtfEnd37, NtfEnd38, NtfEnd39, NtfBar39, NtfEnd40, NtfBar40
    Gui, %num%:Destroy
    Gui, %num%:New, +AlwaysOnTop -Caption +ToolWindow +E0x08000020 +HwndhNtf
    Gui, %num%:Margin, 0, 0
    Gui, %num%:Color, 15181E
    tw := w - 32
    Gui, %num%:Font, s8 Bold c%accent%, Segoe UI
    Gui, %num%:Add, Text, x18 y9 w%tw% +0x80 BackgroundTrans, %title%
    Gui, %num%:Font, s9 Norm cEDEFF2, Segoe UI
    Gui, %num%:Add, Text, x18 y+3 w%tw% +0x80 BackgroundTrans, %body%
    if (action != "") {
        Gui, %num%:Font, s9 Bold cFFFFFF, Segoe UI
        Gui, %num%:Add, Text, x18 y+6 w%tw% +0x80 BackgroundTrans, %action%
    }
    if (foot != "") {
        Gui, %num%:Font, s8 Norm c8E97A6, Segoe UI
        Gui, %num%:Add, Text, x18 y+5 w%tw% +0x80 BackgroundTrans, %foot%
    }
    if (bar)
        Gui, %num%:Add, Progress, x18 y+7 w%tw% h3 -Theme Background2A2F38 c%accent% vNtfBar%num%, 100
    Gui, %num%:Add, Text, x0 y+9 w1 h1 vNtfEnd%num%
    GuiControlGet, endPos, %num%:Pos, NtfEnd%num%
    h := endPosY + 1
    Gui, %num%:Add, Progress, x0 y0 w4 h%h% -Theme Background%accent% c%accent%, 100
    return {hwnd: hNtf, w: w, h: h}
}


; === NtfPosName / NtfPosText: название положения плашек (1 слева сверху, 2 справа сверху, 3 слева по центру, 4 слева снизу, 5 справа снизу) ===
NtfPosName(corner) {
    names := ["Слева сверху", "Справа сверху", "Слева по центру", "Слева снизу", "Справа снизу"]
    return names[corner]
}

; Текст кнопки в настройках: у выбранного положения галочка.
NtfPosText(corner) {
    global ntfCorner
    arrows := ["↖", "↗", "←", "↙", "↘"]
    return (corner = ntfCorner ? "✔ " : "") . arrows[corner] . " " . NtfPosName(corner)
}


; === NtfLayout: расставляет плашки столбцом в выбранном месте окна игры (подсказка-ответ всегда сверху столбца) ===
; Сверху — столбец растёт вниз от верхнего края; снизу — прижат к нижнему краю и растёт вверх; по центру — центруется по вертикали.
NtfLayout() {
    global ntfCorner
    NtfAnchor(ax, ay, aw, ah)
    items := []
    if (IsObject(ntfHint))
        items.Push(ntfHint)
    for _, n in ntfList
        items.Push(n)
    totalH := 0
    shownCount := 0
    for _, it in items {
        if (it.nogui)
            continue
        totalH += it.h
        shownCount++
    }
    if (shownCount > 1)
        totalH += (shownCount - 1) * 8
    if (ntfCorner = 1 || ntfCorner = 2)
        y := ay + 16
    else if (ntfCorner = 4 || ntfCorner = 5)
        y := ay + ah - 16 - totalH
    else
        y := ay + (ah - totalH) // 2
    if (y < ay + 8)
        y := ay + 8
    toRight := (ntfCorner = 2 || ntfCorner = 5)
    for _, it in items {
        if (it.nogui)
            continue
        x := toRight ? ax + aw - it.w - 16 : ax + 16
        w := it.w
        h := it.h
        hw := it.hwnd
        if (!it.shown) {
            num := it.num
            Gui, %num%:Show, NA x%x% y%y% w%w% h%h%
            WinSet, Region, 0-0 W%w% H%h% R10-10, ahk_id %hw%
            WinSet, Transparent, 240, ahk_id %hw%
            it.shown := true
        } else {
            WinMove, ahk_id %hw%,, %x%, %y%
        }
        y += h + 8
    }
}


; === NtfShow: обычная плашка-сообщение (до 8 одновременно; тот же тег — заменяет) ===
NtfShow(tag, title, body, accent, ms) {
    wasCrit := A_IsCritical
    Critical, On
    idx := 0
    for i, n in ntfList {
        if (n.tag = tag) {
            idx := i
            break
        }
    }
    num := 0
    if (idx) {
        num := ntfList[idx].num
        ntfList.RemoveAt(idx)
    } else {
        used := {}
        for _, n in ntfList
            used[n.num] := true
        Loop, 8 {
            c := 30 + A_Index
            if (!used.HasKey(c)) {
                num := c
                break
            }
        }
        if (!num) {
            num := ntfList[1].num
            ntfList.RemoveAt(1)
        }
    }
    item := NtfBuild(num, 340, title, body, "", "", accent, false)
    item.num := num
    item.tag := tag
    item.until := A_TickCount + ms
    item.shown := false
    ntfList.Push(item)
    NtfLayout()
    SetTimer, NtfTick, 100
    Critical, % wasCrit ? "On" : "Off"
}


; === NtfTick: убирает истёкшие плашки и двигает обратный отсчёт подсказки ===
NtfTick() {
    wasCrit := A_IsCritical
    Critical, On
    changed := false
    i := ntfList.Length()
    while (i >= 1) {
        n := ntfList[i]
        if (A_TickCount >= n.until) {
            num := n.num
            Gui, %num%:Destroy
            ntfList.RemoveAt(i)
            changed := true
        }
        i--
    }
    if (IsObject(ntfHint)) {
        left := ntfHint.until - A_TickCount
        if (left <= 0) {
            HintClose()
        } else if (ntfHint.hasBar) {
            pct := Round(left * 100 / ntfHint.total)
            GuiControl, 39:, NtfBar39, %pct%
        }
    }
    if (changed)
        NtfLayout()
    if (ntfList.Length() = 0 && !IsObject(ntfHint))
        SetTimer, NtfTick, Off
    Critical, % wasCrit ? "On" : "Off"
}


; === ShowTip: подсказка-ответ по репорту ставится в очередь (type: Вопрос | МАТ | ОСК; для МАТ и ОСК reply — текст наказания) ===
ShowTip(author, id, text, key, type, reply, note := "") {
    HintEnqueue({kind: type, author: author, id: id, text: text, key: key, reply: reply, note: note})
}


HintEnqueue(item) {
    hintQueue.Push(item)
    while (hintQueue.Length() > 6)
        hintQueue.RemoveAt(1)
    HintPump()
}


HintPump() {
    if (IsObject(ntfHint) || hintQueue.Length() = 0)
        return
    item := hintQueue[1]
    hintQueue.RemoveAt(1)
    HintShow(item)
}


; === HintShowNow: показать подсказку сразу (текущая закрывается, очередь сохраняется) ===
HintShowNow(item) {
    HintClose(false)
    HintShow(item)
}


; === HintClose: закрыть текущую подсказку; pump — показать следующую из очереди ===
HintClose(pump := true) {
    wasCrit := A_IsCritical
    Critical, On
    SetTimer, HintArmWait, Off
    if (IsObject(ntfHint)) {
        if (!ntfHint.nogui)
            Gui, 39:Destroy
        ntfHint := ""
        hintTimersOff()
        SetTimer, OfflineReplyWatch, Off
        NtfLayout()
    }
    Critical, % wasCrit ? "On" : "Off"
    if (pump)
        HintPump()
}


; === HintShow: показать плашку-подсказку и подготовить ответ по Reply + Enter ===
HintShow(item) {
    global isToolTipActive, playerId, ansAuthor
    wasCrit := A_IsCritical
    Critical, On
    kind := item.kind
    accent := (kind = "Вопрос") ? "4C8DFF" : (kind = "МАТ") ? "FF9F43" : (kind = "ОСК") ? "FF5C5C" : "9AA3B2"
    label := (kind = "Вопрос") ? "ВОПРОС" : (kind = "МАТ") ? "МАТ В РЕПОРТЕ" : (kind = "ОСК") ? "ОСКОРБЛЕНИЕ" : "ИГРОК ВЫШЕЛ"
    key := (item.key = "" || item.key = "ERROR") ? "Reply" : item.key
    text := item.text
    if (StrLen(text) > 220)
        text := SubStr(text, 1, 220) . "…"
    title := label . "  ·  " . item.author . "[" . item.id . "]"
    if (kind = "Вопрос") {
        action := "➜  " . item.reply
        foot := key . " + Enter — отправить ответ" . (item.note != "" ? "   ·   правило: " . item.note : "")
    } else if (kind = "Оффлайн") {
        action := "➜  " . item.reply
        foot := key . " + Enter — ответить, что игрок вышел"
    } else {
        punishParts := PunishSplitCommand(item.reply)
        action := "➜  " . punishParts.cmd . " " . item.id . (punishParts.args != "" ? " " . punishParts.args : "")
        foot := key . " + Enter — выдать наказание"
    }
    dur := 7777
    if (isToolTipActive) {
        built := NtfBuild(39, 360, title, text, action, foot, accent, true)
        built.hasBar := true
        built.shown := false
    } else {
        built := {hwnd: 0, w: 0, h: 0, hasBar: false, shown: true, nogui: true}
    }
    built.num := 39
    built.kind := kind
    ; Кому и что отправлять по Reply + Enter: берётся из показанной подсказки, а не из общих переменных.
    built.target := item.id
    built.replyText := item.reply
    built.until := A_TickCount + dur
    built.total := dur
    ntfHint := built
    if (kind = "Вопрос") {
        answerComplaint := item.reply
        playerId := item.id
    } else if (kind = "Оффлайн") {
        offlineTarget := item.id
        offlineText := item.reply
        offlineUntil := A_TickCount + dur
    } else {
        answerCommand := item.reply
    }
    ansLogID := item.id
    ansAuthor := item.author
    hintArmKind := kind
    SetTimer, HintArmWait, 30
    NtfLayout()
    SetTimer, NtfTick, 100
    Critical, % wasCrit ? "On" : "Off"
}


; === HintArmWait: включает ответ по Reply + Enter, когда прежнее нажатие отпущено (чтобы не сработать на то же нажатие) ===
HintArmWait() {
    key := hotkeys["Reply"]
    if (key != "" && GetKeyState(key, "P") && GetKeyState("Enter", "P"))
        return
    SetTimer, HintArmWait, Off
    if (!IsObject(ntfHint))
        return
    if (hintArmKind = "Вопрос")
        SetTimer, respondComplaint, 30
    else if (hintArmKind = "МАТ" || hintArmKind = "ОСК")
        SetTimer, respondCommand, 30
    else if (hintArmKind = "Оффлайн")
        SetTimer, OfflineReplyWatch, 30
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

IsGTAOpen() {
    Process, Exist, gta_sa.exe
    
    return (ErrorLevel != 0)
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

; === SHA256Hex: SHA-256 строки (UTF-8) в виде 64 hex-символов; пусто при ошибке CryptoAPI ===
SHA256Hex(str) {
    VarSetCapacity(bin, StrPut(str, "UTF-8"), 0)
    len := StrPut(str, &bin, "UTF-8") - 1
    hProv := 0
    hHash := 0
    result := ""
    if (!DllCall("advapi32\CryptAcquireContextW", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000, "Int"))
        return ""
    if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", 0x800C, "Ptr", 0, "UInt", 0, "Ptr*", hHash, "Int")) {
        if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", &bin, "UInt", len, "UInt", 0, "Int")) {
            size := 32
            VarSetCapacity(hashBin, 32, 0)
            if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hashBin, "UInt*", size, "UInt", 0, "Int")) {
                Loop, 32 {
                    b := NumGet(hashBin, A_Index - 1, "UChar")
                    result .= SubStr("0123456789abcdef", (b >> 4) + 1, 1) . SubStr("0123456789abcdef", (b & 15) + 1, 1)
                }
            }
        }
        DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
    }
    DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    return result
}

; === LicenseHash: хэш записи лицензии = SHA-256(соль | ключ в нижнем регистре | HWID) ===
LicenseHash(key, hwid) {
    global LicenseSalt
    k := Trim(key)
    StringLower, k, k
    return SHA256Hex(LicenseSalt . "|" . k . "|" . Trim(hwid))
}

; === LicenseNicknameB64: ник в Base64 для статистики и сравнения с чатом ===
; Если в настройках уже сохранён ник (тот же, с точностью до регистра), берётся он: имя секции статистики не меняется.
LicenseNicknameB64(key) {
    global settingsFile
    IniRead, stored, %settingsFile%, Preset, userNickname, %A_Space%
    stored := Trim(stored)
    if (stored != "" && stored != "ERROR" && Base64Decode(stored) = key)
        return stored
    return Trim(Base64Encode(key), " `t`r`n")
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


; ====================================================================================================================
; ЧАТЛОГ
; ====================================================================================================================

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

; Совместимость с ручными функциями, которым нужен номер строки.
checkChatLog() {
    global filePath
    count := 0
    if (filePath = "" || !FileExist(filePath))
        return count
    Loop, Read, %filePath%
        count := A_Index
    return count
}

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
ChatlogRememberProbe(f, state) {
    state.probePos := (state.pos > 96) ? state.pos - 96 : 0
    state.probe := ChatlogFingerprint(f, state.probePos, state.pos - state.probePos)
}

; Сравнение сырых байтов, а не символов UTF-8 (без ложных сбросов на кириллице).
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
ChatlogWatchFromNow(channel) {
    return ChatlogReadNew(channel, "tail", true)
}


; ====================================================================================================================
; ОТПРАВКА КОМАНД В ЧАТ
; ====================================================================================================================

; Только ответы/наблюдение; наказания и команды меню остаются ручными.
; Очередь не отправляет старые команды после потери фокуса надолго.
; === AutomationQueueChat: очередь команд чата ===
AutomationQueueChat(command, allowAny := false) {
    global automationQueue
    if (!allowAny && SubStr(command, 1, 4) != "/pm " && SubStr(command, 1, 4) != "/sp ")
        return false
    if (automationQueue.Length() >= 4)
        return false
    automationQueue.Push({cmd:command, queued:A_TickCount})
    SetTimer, AutomationProcessQueue, 40
    return true
}

; === ChatStateWatch: сбрасывает признак «чат открыт», когда игра потеряла фокус ===
; Признак ставится по T/F6 и снимается только по Enter/Esc в игре. Если уйти в другое приложение с открытым чатом,
; он оставался включённым и блокировал автозапрос, автоответ и автоотправку команд, пока не нажать Enter/Esc.
ChatStateWatch() {
    global ChatIsOpen, requestBusy, requestCanRecall
    if (ChatIsOpen && !requestBusy && !WinActive("ahk_exe gta_sa.exe")) {
        ChatIsOpen := false
        ; Что осталось в чате игры, неизвестно: ↑ для повтора /z больше не используем, пока /z не отправлен заново.
        requestCanRecall := false
    }
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
    SendInput, % "{F6}" . SendEsc(job.cmd) . "{Enter}"
    automationLastSent := A_TickCount
    Critical, Off
    automationBusy := false
    if (automationQueue.Length() > 0)
        SetTimer, AutomationProcessQueue, 40
}

sendReply(playerId, response) {
    global isHumanInput, CMDDelay, InputDelay1, InputDelay2, requestCanRecall
    requestCanRecall := false
    if (isHumanInput) {
        l := StrLen(response) + 1
        esc := SendEsc(response)
        SendInput, {F6}/pm  %esc%{left %l%}
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


; ====================================================================================================================
; НАСТРОЙКИ, ПРЕСЕТЫ И ХОТКЕИ
; ====================================================================================================================

scriptSettingsChecker() {
    if (!FileExist(scriptDir)) {
        FileCreateDir, %scriptDir%
    } if (!FileExist(settingsFile)) {     
        checkLicenseKey()

        IniWrite, F2, %settingsFile%, Keys, Menu
        scriptMode := scriptType
        IniWrite, %scriptMode%, %settingsFile%, Preset, scriptMode
        IniWrite, 0, %settingsFile%, Preset, isHumanInput
        IniWrite, 1, %settingsFile%, Preset, isToolTipActive

        IniWrite, %userNickname%, %settingsFile%, Preset, userNickname

        if (scriptMode == "Admin") {
            IniWrite, %A_Space%, %settingsFile%, Keys, Watch
            IniWrite, %A_Space%, %settingsFile%, Keys, Request
            IniWrite, %A_Space%, %settingsFile%, Keys, Reply
            IniWrite, %A_Space%, %settingsFile%, Keys, humanReply
            IniWrite, %A_Space%, %settingsFile%, Keys, Interact
            IniWrite, %A_Space%, %settingsFile%, Keys, autoIssue
            IniWrite, F10, %settingsFile%, Keys, AdminStats
            IniWrite, %A_Space%, %settingsFile%, Keys, CopyAChat
            IniWrite, Insert, %settingsFile%, Keys, PanelHide
            
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
        checkLicenseKey()
    }
    
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

; === IniReadRetry: чтение настройки с повтором (файл мог быть занят записью статистики в этот момент) ===
IniReadRetry(section, key, default := "") {
    global settingsFile
    Loop, 3 {
        IniRead, v, %settingsFile%, %section%, %key%, __MISSING__
        if (v != "__MISSING__")
            return v
        if (!FileExist(settingsFile))
            break
        Sleep, 30
    }
    return default
}


; === ApplyInputDelays: пресет и паузы ввода из settings.ini с проверкой значений ===
; Известный пресет берётся из таблицы (значения в ini не могут его испортить). «Настраиваемый» — числа из ini в допустимых пределах.
; Если в ini пусто, «ERROR» или мусор — используется «Быстро», а ini исправляется.
ApplyInputDelays(heal := true) {
    global settingsFile
    presets := {"Медленно": [260, 90, 140], "Среднее": [250, 80, 90], "Быстро": [230, 60, 80], "Оч.быстро": [160, 40, 60]}
    name := Trim(IniReadRetry("Preset", "currentSetup", ""))
    vals := ""
    if (presets.HasKey(name)) {
        vals := presets[name]
    } else if (name = "Настраиваемый") {
        c := Trim(IniReadRetry("Preset", "Delay1", ""))
        a := Trim(IniReadRetry("Preset", "Delay2", ""))
        b := Trim(IniReadRetry("Preset", "Delay3", ""))
        if (RegExMatch(c, "^\d{1,4}$") && RegExMatch(a, "^\d{1,4}$") && RegExMatch(b, "^\d{1,4}$")) {
            c := c + 0
            a := a + 0
            b := b + 0
            if (c < 50)
                c := 50
            if (a < 5)
                a := 5
            if (b < a)
                b := a
            vals := [c, a, b]
        }
    }
    if (!IsObject(vals)) {
        name := "Быстро"
        vals := presets[name]
    }
    SetPreset(name, vals[1], vals[2], vals[3])
    if (heal) {
        IniWrite, %name%, %settingsFile%, Preset, currentSetup
        v1 := vals[1]
        v2 := vals[2]
        v3 := vals[3]
        IniWrite, %v1%, %settingsFile%, Preset, Delay1
        IniWrite, %v2%, %settingsFile%, Preset, Delay2
        IniWrite, %v3%, %settingsFile%, Preset, Delay3
    }
}


; === InputSettingsGuard: если паузы ввода в памяти стали пустыми/нечисловыми/вне пределов, они восстанавливаются ===
InputSettingsGuard() {
    global CMDDelay, InputDelay1, InputDelay2, scriptMode
    ok := RegExMatch(CMDDelay . "", "^\d+$") && RegExMatch(InputDelay1 . "", "^\d+$") && RegExMatch(InputDelay2 . "", "^\d+$")
    if (ok)
        ok := (CMDDelay >= 50 && InputDelay1 >= 5 && InputDelay2 >= InputDelay1)
    if (!ok)
        ApplyInputDelays(scriptMode = "Admin")
}


; === CustomDelaysApply: «Настраиваемый» пресет — проверка чисел, запись в ini и применение сразу ===
CustomDelaysApply(sp, d1, d2) {
    global settingsFile, CMDDelay, InputDelay1, InputDelay2
    if (!RegExMatch(sp, "^\d{1,4}$") || !RegExMatch(d1, "^\d{1,4}$") || !RegExMatch(d2, "^\d{1,4}$"))
        return
    sp := sp + 0
    d1 := d1 + 0
    d2 := d2 + 0
    if (sp < 50)
        sp := 50
    if (d1 < 5)
        d1 := 5
    if (d2 < d1)
        d2 := d1
    if (sp = CMDDelay && d1 = InputDelay1 && d2 = InputDelay2)
        return
    IniWrite, %sp%, %settingsFile%, Preset, Delay1
    IniWrite, %d1%, %settingsFile%, Preset, Delay2
    IniWrite, %d2%, %settingsFile%, Preset, Delay3
    SetPreset("Настраиваемый", sp, d1, d2)
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

LoadHotkeys() {
    global hotkeys, settingsFile
    IniRead, hkWatch, %settingsFile%, Keys, Watch
    IniRead, hkRequest, %settingsFile%, Keys, Request
    IniRead, hkReply, %settingsFile%, Keys, Reply
    IniRead, hkhumanReply, %settingsFile%, Keys, humanReply
    IniRead, hkInteract, %settingsFile%, Keys, Interact
    IniRead, hkAutoIssue, %settingsFile%, Keys, autoIssue
    IniRead, hkCopyAChat, %settingsFile%, Keys, CopyAChat
    IniRead, hkMenu, %settingsFile%, Keys, Menu
    IniRead, hkAdminStats, %settingsFile%, Keys, AdminStats
    IniRead, hkAutoEdit, %settingsFile%, Keys, autoEdit
    IniRead, hkAutoBizlist, %settingsFile%, Keys, autoBizlist
    IniRead, hkEmergencyDelete, %settingsFile%, Keys, EmergencyDelete
    IniRead, hkPanelHide, %settingsFile%, Keys, PanelHide, Insert
    
    hotkeys["Watch"] := hkWatch != "ERROR" ? hkWatch : ""
    hotkeys["Request"] := hkRequest != "ERROR" ? hkRequest : ""
    hotkeys["Reply"] := hkReply != "ERROR" ? hkReply : ""
    hotkeys["humanReply"] := hkhumanReply != "ERROR" ? hkhumanReply : ""
    hotkeys["Interact"] := hkInteract != "ERROR" ? hkInteract : ""
    hotkeys["autoIssue"] := hkAutoIssue != "ERROR" ? hkAutoIssue : ""
    hotkeys["CopyAChat"] := hkCopyAChat != "ERROR" ? hkCopyAChat : ""
    hotkeys["Menu"] := (hkMenu == "ERROR") ? "" : (hkMenu == "" ? "F2" : hkMenu)
    hotkeys["AdminStats"] := (hkAdminStats == "ERROR") ? "" : (hkAdminStats == "" ? "F10" : hkAdminStats)
    hotkeys["autoEdit"] := (hkAutoEdit == "ERROR") ? "" : (hkAutoEdit == "" ? "" : hkAutoEdit)
    hotkeys["autoBizlist"] := (hkAutoBizlist == "ERROR") ? "" : (hkAutoBizlist == "" ? "" : hkAutoBizlist)
    hotkeys["EmergencyDelete"] := (hkEmergencyDelete == "ERROR") ? "" : (hkEmergencyDelete == "" ? "" : hkEmergencyDelete)
    hotkeys["PanelHide"] := (hkPanelHide == "ERROR") ? "" : hkPanelHide
}

BindHotkeys() {
    global previousHotkeys, hotkeys, settingsFile, scriptMode

    for action, oldKey in previousHotkeys {
        if (oldKey != "" && !(action = "Reply" || action = "Interact" || action = "")) {
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
        if (newKey != "" && !(action = "Reply" || action = "Interact" || action = "")) {
            try {
                Hotkey, %newKey%, %action%, On
                previousHotkeys[action] := newKey
                
                successLog .= "Дія: " . action . " -> Клавіша: " . newKey . "`n"
            } catch e {
                continue
            }
        }
    }

    ; Паузы ввода берутся из проверенной таблицы пресетов; «ERROR»/пустые значения больше не попадают в Sleep.
    ApplyInputDelays(scriptMode = "Admin")
}


; ====================================================================================================================
; СТАТИСТИКА
; ====================================================================================================================

; === StatsToday: актуальная календарная дата, не кэшируется с момента запуска ===
; Игровой день считается по времени сервера (МСК, UTC+3), а не по часам компьютера: летом Киев = МСК, зимой Киев на час позади,
; поэтому норма сбрасывается в 23:00 по Киеву. Сдвиг можно изменить ключом serverUTCOffset в [Preset] settings.ini.
StatsServerNow() {
    global serverUTCOffset
    t := A_NowUTC
    EnvAdd, t, %serverUTCOffset%, Hours
    return t
}

StatsToday() {
    t := StatsServerNow()
    FormatTime, dateText, %t%, dd.MM.yyyy
    return dateText
}

; === StatsLineServerDate: игровая дата строки чатлога [ЧЧ:ММ:СС] (время в чате — по часам компьютера) ===
StatsLineServerDate(h, m, s) {
    global serverUTCOffset
    localNow := A_Now
    utcNow := A_NowUTC
    off := localNow
    EnvSub, off, %utcNow%, Seconds
    off := Round(off / 900) * 900
    stamp := SubStr(localNow, 1, 8) . h . m . s
    ; Время строки позже текущего — строка со вчерашнего дня.
    if ((h * 3600 + m * 60 + s) > (A_Hour * 3600 + A_Min * 60 + A_Sec + 120))
        EnvAdd, stamp, -1, Days
    shift := serverUTCOffset * 3600 - off
    EnvAdd, stamp, %shift%, Seconds
    FormatTime, dateText, %stamp%, dd.MM.yyyy
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
            ; Считаем только строки текущего игрового дня (МСК): после 23:00 по Киеву зимой начинается новый день.
            if (StatsLineServerDate(t1, t2, t3) != StatsToday())
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


; ====================================================================================================================
; GUI: ФУНКЦИИ МЕНЮ И КЛАВИАТУРНАЯ НАВИГАЦИЯ
; ====================================================================================================================

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
    global menuNavItems, menuNavIndex, menuNavGuiName, menuHoverHwnd

    menuHoverHwnd := 0
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
        menuNavItems.Push({hwnd: controlHwnd, text: controlText, type: controlType, help: MenuHelpKey(controlText, menuNavGuiName)})
    }

    if (menuNavItems.Length())
        MenuKeyboardSelect(1)
    else
        MenuKeyboardUpdateHint("")
}

; === MenuKeyboardSelect: выбрать элемент и подсветить текущую кнопку ===
MenuKeyboardSelect(index) {
    global menuNavItems, menuNavIndex, menuHoverHwnd

    menuHoverHwnd := 0
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

    MenuKeyboardUpdateHint(selected.text, selected.help)
}

; === MenuKeyboardUpdateHint: внизу меню — краткое описание выбранной (наведённой) кнопки ===
MenuKeyboardUpdateHint(selectedText, helpKey := "") {
    global menuNavGuiName
    if (menuNavGuiName = "")
        return
    if (selectedText = "") {
        selectionText := "Наведите курсор или выберите кнопку стрелками — здесь появится описание"
    } else {
        info := MenuHelpInfo(helpKey)
        if (IsObject(info))
            selectionText := info.t . " — " . MenuHelpFill(info.s)
        else
            selectionText := "Выбрано: " . selectedText
    }
    selectionText := RegExReplace(selectionText, "&", "&&")
    GuiControl, %menuNavGuiName%:, MenuKeyboardSelection, %selectionText%
}

; === MenuRefreshHint: обновить описание выбранной кнопки после её нажатия (текст кнопки мог измениться) ===
MenuRefreshHint() {
    global menuNavIndex
    if (menuNavIndex >= 1)
        MenuKeyboardSelect(menuNavIndex)
}

; === MenuMouseMove: наведение курсора на кнопку показывает её описание внизу окна ===
MenuMouseMove(wParam, lParam, msg, hwnd) {
    global menuNavItems, menuNavGuiHwnd, menuHoverHwnd
    if (!menuNavGuiHwnd || !hwnd || hwnd = menuHoverHwnd)
        return
    for i, item in menuNavItems {
        if (item.hwnd = hwnd) {
            MenuKeyboardSelect(i)
            menuHoverHwnd := hwnd
            return
        }
    }
}

; === MenuKeyboardEnabled: клавиатурное управление активно только для видимого меню ===
MenuKeyboardEnabled() {
    global menuNavGuiHwnd
    if (!menuNavGuiHwnd || !WinExist("ahk_id " . menuNavGuiHwnd))
        return false
    WinGet, windowStyle, Style, ahk_id %menuNavGuiHwnd%
    if (!(windowStyle & 0x10000000))
        return false
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
; === SendEsc: экранирует { } ^ ! + # для SendInput (ответы и команды с этими знаками не превращаются в сочетания клавиш) ===
SendEsc(text) {
    return RegExReplace(text, "([{}^!+#])", "{$1}")
}


; ====================================================================================================================
; СПРАВКА: описания кнопок и функций
; Краткое описание появляется внизу окна при выборе кнопки стрелками или наведении курсора.
; Подробности: кнопка ❓ в шапке окна (список тем) и F1 на выбранной кнопке (сразу нужная тема).
; ====================================================================================================================

HAdd(d, key, menu, title, short, long) {
    d[key] := {t: title, s: short, l: long, m: menu}
}

; === MenuHelpData: все темы справки (ключ -> заголовок, краткое и подробное описание) ===
MenuHelpData() {
    static d := ""
    if (IsObject(d))
        return d
    d := {}
    HAdd(d, "h_all", "*", "Кнопки в шапке окна", "Перезапуск, остановка, закрытие, назад, справка и сброс.", "⟲ — перезапустить скрипт. Настройки сохраняются, файлы правил перечитываются.`n⊚ — полностью остановить скрипт.`n✘ — закрыть меню (скрипт продолжает работать).`n⮐ — вернуться в предыдущее меню.`n❓ — открыть эту справку для текущего окна.`n♻️ — сбросить значения окна к стандартным (есть в окнах клавиш, ответов и взаимодействия).`n`nНаведите курсор на кнопку или выберите её стрелками — краткое описание появится внизу окна. F1 открывает справку по выбранной кнопке.")
    HAdd(d, "h_reload", "*", "⟲ Перезапуск", "Перезапускает скрипт. Настройки сохраняются, файлы правил перечитываются.", "Полностью перезапускает скрипт. Все настройки сохраняются. Нажимайте после правки файлов (правила ответов, слова МАТ/ОСК, умные наказания, настройки), если изменения не подхватились сами.")
    HAdd(d, "h_stop", "*", "⊚ Остановить скрипт", "Полностью останавливает скрипт. Запустить снова — ярлыком или файлом.", "Завершает работу скрипта. Чтобы запустить его снова, откройте ярлык или файл скрипта.")
    HAdd(d, "h_close", "*", "✘ Закрыть меню", "Закрывает меню. Скрипт продолжает работать.", "Закрывает все окна меню. Скрипт при этом остаётся включённым. Меню открывается клавишей из «Настроек клавиш».")
    HAdd(d, "h_back", "*", "⮐ Назад", "Возврат в предыдущее меню (Esc делает то же самое).", "Возвращает в предыдущее меню. Клавиша Esc работает так же.")
    HAdd(d, "h_help", "*", "❓ Справка", "Справка по окну. F1 — справка по выбранной кнопке.", "Открывает список тем по текущему окну. Чтобы сразу прочитать про конкретную кнопку, выберите её и нажмите F1. Внутри справки Esc возвращает на шаг назад.")
    HAdd(d, "h_reset_keys", "*", "♻️ Сбросить клавиши", "Возвращает клавиши к стандартным: меню — F2, статистика — F10, остальные не назначены.", "Сбрасывает все назначения клавиш: меню получает F2, статистика — F10, остальные клавиши становятся не назначены. Действие применяется сразу и без подтверждения.")
    HAdd(d, "h_reset_answers", "*", "♻️ Сбросить ответы", "Возвращает тексты ответов к стандартным. Действует сразу, без подтверждения.", "Заменяет все ваши фразы ответов стандартными. Действие применяется сразу и без подтверждения, отменить его нельзя.")
    HAdd(d, "h_reset_interact", "*", "♻️ Очистить слоты", "Очищает все 10 слотов взаимодействия. Действует сразу.", "Очищает команды и тексты во всех десяти слотах взаимодействия. Действие применяется сразу и без подтверждения.")
    HAdd(d, "sp_mode", "main", "⇄ Автослежка берёт", "Какой репорт берёт автослежка: последний, случайный или самый старый. Сейчас: {mode}. Нажмите — переключить.", "Автослежка (/sp) берёт репорт из чата и сразу заходит в слежку. Здесь выбирается, какой именно репорт она берёт. Нажатие переключает режим по кругу.`n`n• Последняя — самый новый репорт.`n• Случайная — любой из подходящих репортов.`n• Самая старая — самый давний из подходящих, чтобы никто не ждал дольше всех.`n`nВ режимах «случайная» и «самая старая» учитываются только подходящие репорты: в пределах области видимости, не старше области досягаемости, без ответа и те, за которыми вы ещё не заходили. Режим «последняя» берёт самый новый репорт без этих проверок.")
    HAdd(d, "sp_pool", "main", "🧠 Область видимости", "Сколько последних репортов учитывает автослежка. Сейчас: {pool}. Нажмите — изменить.", "Область видимости — сколько последних репортов автослежка рассматривает в режимах «случайная» и «самая старая». Значение переключается по кругу: 2, 3, 4, 5, 7, 10.`n`nТолько из этих репортов автослежка может выбрать репорт. В панели репортов остальные показываются как история.")
    HAdd(d, "sp_age", "main", "⏱ Область досягаемости", "Максимальный возраст репорта для автослежки: от 30 сек до 5 мин. Сейчас: {age}.", "Область досягаемости — насколько свежим должен быть репорт, чтобы автослежка взяла его в режимах «случайная» и «самая старая». Более старые репорты считаются устаревшими: они остаются в панели репортов, но автослежка их пропускает. В режиме «последняя» возраст не проверяется.`n`nВарианты: 30 сек, 1, 2, 3 и 5 мин. Галочка стоит у выбранного значения.")
    HAdd(d, "report_hints", "main", "💡 Подсказки по репортам", "Скрипт читает новые репорты и показывает готовый ответ или наказание. Нажмите — включить или выключить.", "Когда в чат приходит репорт, скрипт сопоставляет его текст с вашими правилами ответов и со словами МАТ/ОСК. При совпадении на экране появляется подсказка с готовым ответом или наказанием; отправить её можно клавишей Reply + Enter. Если репортов много, подсказки выстраиваются в очередь.`n`nПравила меняются кнопками «Правила ответов» и «Слова МАТ/ОСК».")
    HAdd(d, "punish_helper", "main", "⚖ Умные наказания", "Короткие команды наказаний: пишете сокращение и ID, скрипт проверяет игрока и выдаёт наказание. Включить / выключить.", "Вы набираете сокращённую команду из файла наказаний (например /epp) и ID игрока. Скрипт командой /id проверяет игрока — в том числе если он в маске, тогда берётся его реальный ник, — подставляет полную команду из файла и отправляет её. Для игроков до 5 уровня включительно наказание смягчается: бан заменяется варном, варн — джейлом на 120, срок остальных наказаний сокращается вдвое. Если включено подтверждение наказаний, перед отправкой появится плашка: Enter — выдать, Esc — отмена.`n`nСокращения задаются в файле умных наказаний. Эта кнопка включает и выключает функцию.")
    HAdd(d, "hotkeys_btn", "main", "🕹 Настройки клавиш", "Какими клавишами запускаются функции: слежка, ответы, запросы, статистика и другие.", "Открывает окно назначения клавиш. Для каждой функции выберите клавишу в поле; изменения сохраняются сразу. Описание каждой функции — в справке этого окна (кнопка ❓).")
    HAdd(d, "answers_btn", "main", "⚙️ Настройки ответов", "Тексты быстрых ответов: приветствие при слежке, Reply + 1…0 и «игрок вышел».", "Здесь редактируются фразы, которые скрипт отправляет игрокам: приветствие при слежке, десять быстрых ответов на Reply + 1…0 и ответ на случай, когда игрок вышел из игры. Изменения сохраняются сразу.")
    HAdd(d, "interact_btn", "main", "🎯 Взаимодействие с игроком", "Десять команд на игрока, за которым вы следите: клавиша Interact + 1…0.", "Настройка десяти слотов команд для игрока, за которым вы следите. В каждом слоте слева — команда (например /mute), справа — текст, который идёт после ID. В игре: клавиша Interact + цифра 1…9 или 0 отправляет команду с ID игрока. Команду можно писать в русской раскладке через точку: .пуемур = /getveh. Пустая команда — слот выключен.")
    HAdd(d, "punish_file", "main", "📄 Файл умных наказаний", "Открывает файл с сокращениями наказаний (punish.txt) в Блокноте.", "В файле каждая строка — одно правило вида «/сокращение = полная команда», например /epp = /jail 60 Езда по полям. Строки с # — комментарии. Если изменения не подхватились, нажмите ⟲. Файл доступен, когда включены умные наказания.")
    HAdd(d, "script_settings", "main", "⚙️ Настройки скрипта", "Ввод команд, скорость, уведомления, панель репортов, подтверждения и системные кнопки.", "Общие параметры работы скрипта: способ ввода команд и его скорость, уведомления на экране, панель репортов, подтверждение наказаний, дополнительный модуль и системные действия.")
    HAdd(d, "answer_rules", "main", "📝 Правила ответов", "Файл answer-rules.txt: по каким словам в репорте скрипт подсказывает ответ.", "Откройте файл и добавьте свои слова и ответы по образцу встроенных правил — их использует функция «Подсказки по репортам». Если изменения не подхватились, нажмите ⟲.")
    HAdd(d, "punish_words", "main", "📝 Слова МАТ/ОСК", "Файл punish-words.txt: слова, за которые скрипт предлагает наказание.", "Список слов мата и оскорблений и наказаний за них. Функция «Подсказки по репортам» использует его, чтобы предложить наказание. Если изменения не подхватились, нажмите ⟲.")
    HAdd(d, "stats_toggle", "main", "✔ Подсчёт статистики", "Включает и выключает подсчёт ваших ответов (/pm) и джейлов. Накопленное сохраняется.", "Пока подсчёт включён, скрипт по чатлогу считает ваши ответы игрокам (/pm) и выданные джейлы. При выключении подсчёт останавливается, а накопленная история остаётся. Игровой день для статистики считается по времени сервера (МСК).")
    HAdd(d, "stats_btn", "main", "📊 Статистика администратора", "Ответы и джейлы за сегодня и последние 3 дня, сравнение с выбранной датой.", "Показывает ваши ответы (PM) и джейлы (J): сегодня, минимум, максимум и среднее за 3 дня, а также разницу с выбранной датой. День меняется в 00:00 по МСК (зимой это 23:00 по Киеву).")
    HAdd(d, "trucker_btn", "main_player", "🛠️ Секунды ловли заказа", "Показывает или скрывает поля настройки секунд ловли заказа.", "Открывает два поля настройки секунд ловли заказа дальнобойщика. Значения сохраняются сразу.")
    HAdd(d, "search_date", "main_player", "⤵︎ Поиск по дате", "Показывает доход за выбранную дату (день, месяц, год).", "Введите день, месяц и год и нажмите кнопку: ниже появится заработок за эту дату по видам работы. Если данных нет, будет написано «Пусто».")
    HAdd(d, "input_mode", "settings", "⚡ Ввод команд", "Как скрипт вводит команды: Автоматический — сразу, Ручной — по символам с паузами. Нажмите — переключить.", "Автоматический: команда вводится в чат сразу целиком. Ручной (имитация): символы вводятся по одному с паузами; скорость выбирается ниже кнопками «Медленно» … «Оч.быстро» или «Настраиваемый». Выбор сохраняется и действует для функций скрипта, которые вводят команды в чат.")
    HAdd(d, "speed", "settings", "Скорость ввода", "Паузы при ручном вводе. Чем быстрее, тем выше риск потерять символ.", "Работает только в ручном режиме ввода. Готовые наборы (пауза после команды / между символами):`n• Медленно — 260 / 90–140 мс`n• Среднее — 250 / 80–90 мс`n• Быстро — 230 / 60–80 мс`n• Оч.быстро — 160 / 40–60 мс`n`n«Настраиваемый» открывает три поля: пауза после команды и пределы паузы между символами. Значения применяются сразу. Если в чате теряются символы, выберите пресет помедленнее. Ошибочные значения скрипт сам заменяет на безопасные.")
    HAdd(d, "tooltips", "settings", "💬 Уведомления на экране", "Плашки скрипта на экране: статус, результаты, ошибки. Нажмите — включить или выключить.", "Включает и выключает всплывающие сообщения скрипта: статус, результаты действий и ошибки.")
    HAdd(d, "ntf_pos", "settings", "↖ Положение уведомлений", "Где на экране появляются плашки. Выберите место — покажется пробная плашка.", "Пять вариантов: слева сверху, справа сверху, слева по центру, слева снизу, справа снизу. Плашки ставятся столбцом от выбранного края, подсказка-ответ всегда сверху столбца. Панель репортов автоматически занимает противоположную сторону, чтобы не перекрывать уведомления.")
    HAdd(d, "report_panel", "settings", "📋 Панель репортов", "Меню в игре: репорты, их статусы и доступные сейчас действия. Нажмите — включить или выключить.", "Плашка в игре показывает до 10 последних репортов. Сверху — репорт, по которому вы сейчас в слежке, и те, что можно взять автослежкой; ниже — история.`n`nСтатусы:`n✉︎ Ожидает ответа — репорт можно взять.`n♯ Обрабатывается — вы сейчас в слежке по этому репорту (одновременно только один; при заходе за другим игроком прежний теряет статус).`n↷ Пропущен — заходили, но не ответили.`n✘ Игрок вышел — игрока из репорта не оказалось в игре.`n✘ Следит другой — за игроком уже следил другой админ.`n✔ Обработан — ответили вы. ✎ Имя — ответил другой администратор.`n☣ Устарел — старше области досягаемости.`n✘ Вручную — в режиме «последняя» автослежка берёт только самый новый репорт.`n✘ Вне окна — за пределами области видимости.`n`n▶ — этот репорт возьмёт автослежка, ◇ — репорт входит в выборку.`n`nВнизу блок «ДЕЙСТВИЯ»: какие клавиши работают прямо сейчас — подсказка по репорту (Reply + Enter), после захода в слежку приветствие (Reply), затем быстрые ответы (Reply + 1…0) и команды на игрока (Interact + 1…0), а также автослежка и скрытие панели. Показываются только назначенные клавиши.`n`nПанель можно временно скрыть клавишей из «Настроек клавиш» (по умолчанию Insert). Если слежка не продолжается более 10 минут, статус «Обрабатывается» снимается сам. Панель видна, только пока активно окно игры, не перехватывает клики и показывается с противоположной от уведомлений стороны.")
    HAdd(d, "confirm", "settings", "🛡 Подтверждение наказаний", "Перед выдачей показывает итоговую команду: Enter — выдать, Esc — отмена.", "Работает для умных наказаний и автовыдачи. Перед отправкой появляется плашка с итоговой командой. Enter — выдать, Esc — отмена; в игру эти клавиши в этот момент не передаются. Выключите, если хотите, чтобы наказания отправлялись сразу.")
    HAdd(d, "extras", "settings", "➕ Доп. возможности", "Запускает ваш файл дополнений ViMeLlY-Features.ahk вместе со скриптом.", "Включите, если у вас есть свой дополнительный AHK-файл: он запускается вместе со скриптом. Выключение не удаляет файл.")
    HAdd(d, "extras_file", "settings", "📄 Файл дополнений", "Открывает файл дополнений в Блокноте (когда функция включена).", "Открывает ваш файл дополнений в Блокноте. Кнопка работает, когда включены дополнительные возможности. После правки нажмите ⟲.")
    HAdd(d, "open_settings", "settings", "📂 Открыть файл настроек", "Открывает settings.ini в Блокноте.", "Все настройки скрипта хранятся в этом файле. Правьте его, только если понимаете, что меняете. После правки нажмите ⟲, чтобы скрипт перечитал файл.")
    HAdd(d, "reset_license", "settings", "🔑 Сбросить ключ доступа", "Удаляет сохранённый ключ и перезапускает скрипт: ключ придётся ввести заново.", "Перед сбросом скрипт спросит подтверждение. После подтверждения сохранённый ключ удаляется, скрипт перезапускается и просит ввести ключ снова.")
    HAdd(d, "k_menu", "keys", "｢🔗｣ Меню", "Открывает и закрывает меню скрипта.", "Клавиша вызова меню скрипта.")
    HAdd(d, "k_watch", "keys", "｢🪬｣ Автослежка (/sp)", "Берёт репорт по выбранному режиму и заходит в слежку за игроком.", "Берёт репорт из чата по режиму из главного меню (последняя, случайная или самая старая) и заходит в слежку /sp. После этого клавиша автоответа отправляет репортёру приветствие, а она же с цифрами 1…0 — быстрые ответы. Клавиша взаимодействия с цифрами отправляет команды на игрока, за которым вы следите.")
    HAdd(d, "k_request", "keys", "｢📑｣ Автозапрос (/z)", "Быстрая отправка /z по номеру обращения. Shift + клавиша — ввести номер заново.", "Первое нажатие просит ввести ID обращения прямо в чате; дальше скрипт отправляет /z, не набирая команду заново. Shift + клавиша — ввести номер заново.")
    HAdd(d, "k_reply", "keys", "｢📝｣ Автоответ (/pm)", "Reply — приветствие после слежки, Reply + 1…0 — быстрые ответы, Reply + Enter — ответ по подсказке.", "Это клавиша Reply. После автослежки одно нажатие отправляет приветствие репортёру. Reply + 1…0 — быстрые ответы из «Настроек ответов». Приветствие и быстрые ответы уходят репортёру, за которым вы зашли, — новые репорты его не подменяют. Reply + Enter — ответ по показанной подсказке.")
    HAdd(d, "k_human", "keys", "｢🖋｣ Ручный ответ (/pm)", "Вводит /pm и ID игрока из последнего репорта — текст вы пишете сами.", "Подставляет в чат команду /pm и ID игрока из последнего репорта. Текст ответа вы набираете сами.")
    HAdd(d, "k_interact", "keys", "｢🎯｣ Взаимодействие", "Interact + 1…0 — команды на игрока, за которым вы следите.", "Клавиша вместе с цифрой 1…9 или 0 отправляет команду из соответствующего слота меню «Взаимодействие» на игрока, за которым вы следите.")
    HAdd(d, "k_issue", "keys", "｢📜｣ Автовыдача", "Выдаёт наказания списком из файла auto-issue.txt; перед началом просит подтверждение.", "Читает файл auto-issue.txt (если его нет — создаёт). Строки вида «/команда ник [время] [причина]»; пустые строки и комментарии (;, #, //, --) пропускаются. Перед выдачей показывается плашка со списком: подтвердите или отмените.")
    HAdd(d, "k_stats", "keys", "｢📊｣ Статистика", "Показывает на экране ваши ответы (/pm) и джейлы.", "Показывает подсказку со статистикой: сколько ответов и джейлов у вас за сегодня.")
    HAdd(d, "k_copy", "keys", "｢📂｣ Копирование", "Вставляет в чат последнюю команду из админ-чата [A].", "Берёт последнюю команду, написанную в админ-чате [A], и вставляет её в строку чата игры. Останется нажать Enter.")
    HAdd(d, "k_panel", "keys", "｢👁｣ Панель репортов", "Временно скрывает и показывает панель репортов. По умолчанию — Insert.", "Нажатие скрывает панель, повторное — показывает. Скрытие действует до перезапуска скрипта, репорты при этом продолжают учитываться. Насовсем панель отключается кнопкой в настройках скрипта.")
    HAdd(d, "k_emergency", "keys", "｢🛑｣ Аварийное удаление", "Мгновенно останавливает скрипт.", "Аварийная клавиша: сразу завершает работу скрипта. Запустить его снова можно ярлыком или файлом.")
    HAdd(d, "k_exit", "keys", "｢⏹｣ Отключение скрипта", "Фиксированное сочетание Ctrl + Alt + Esc отключает скрипт.", "Сочетание Ctrl + Alt + Esc отключает скрипт. Его нельзя изменить.")
    HAdd(d, "k_autoedit", "keys_player", "｢📍｣ Автоэдит", "Включает и выключает AutoEdit: ожидание нового объявления.", "Первое нажатие включает ожидание нового объявления (AutoEdit), повторное — выключает. О состоянии сообщает подсказка на экране.")
    HAdd(d, "k_bizlist", "keys_player", "｢🚛｣ Авто Bizlist", "Включает и выключает ожидание нового заказа.", "Первое нажатие включает ожидание нового заказа (AutoBizlist), повторное — выключает. О состоянии сообщает подсказка на экране.")
    HAdd(d, "a_greet", "answers", "Приветствие (Reply)", "Фраза, которую скрипт отправляет репортёру при слежке.", "Отправляется клавишей Reply после того, как вы зашли в слежку по репорту.")
    HAdd(d, "a_quick", "answers", "Быстрые ответы (Reply + 1…0)", "Десять готовых фраз: Reply + цифра отправляет выбранную.", "Каждой цифре 1…9 и 0 соответствует своя фраза. Reply + цифра отправляет её репортёру, за которым вы зашли.")
    HAdd(d, "a_offline", "answers", "Offline", "Ответ, если игрок из репорта вышел из игры.", "Когда игрок из репорта не найден в игре, скрипт показывает подсказку с этой фразой: отправить её репортёру можно клавишей Reply + Enter.")
    HAdd(d, "st_view", "stats", "Показатели", "PM — ответы, J — джейлы: сегодня, минимум, максимум и среднее за 3 дня.", "Показатели за сегодня и последние три дня: минимум, максимум, среднее. День меняется в 00:00 по МСК (зимой — 23:00 по Киеву).")
    HAdd(d, "st_search", "stats", "⤵︎ Сравнение с датой", "Введите день, месяц и год — ниже появится разница.", "Введите дату и нажмите кнопку: в поле ниже появятся ответы и джейлы за эту дату. Если данных нет, будет сообщение «ничего не найдено».")
    HAdd(d, "st_reset", "stats", "Сбросить статистику", "Переносит сегодняшние значения в архив и обнуляет счётчики.", "Текущие значения сохраняются в архив под сегодняшней игровой датой, а счётчики за сегодня обнуляются. Подтверждения нет.")
    HAdd(d, "i_slots", "interact", "Слоты команд", "Слева команда, справа текст после ID. Пустая команда — слот выключен.", "Десять слотов соответствуют клавишам Interact + 1…9 и 0. Слева — команда (например /mute), справа — текст, который идёт после ID игрока. Итоговая команда: команда, ID, текст.")
    HAdd(d, "i_ru", "interact", "Русская раскладка", "Команду можно писать через точку: .пуемур = /getveh.", "Если команда начинается с точки, скрипт переведёт её из русской раскладки в английскую: .пуемур станет /getveh.")
    return d
}


; === MenuHelpOrder: порядок тем справки для окна ===
MenuHelpOrder(menuId) {
    global scriptMode
    o := {}
    o["main"] := ["sp_mode", "sp_pool", "sp_age", "report_hints", "punish_helper", "hotkeys_btn", "answers_btn", "interact_btn", "punish_file", "script_settings", "answer_rules", "punish_words", "stats_toggle", "stats_btn", "h_all"]
    o["main_player"] := ["trucker_btn", "search_date", "hotkeys_btn", "script_settings", "h_all"]
    o["settings"] := ["input_mode", "speed", "tooltips", "ntf_pos", "report_panel", "confirm", "extras", "extras_file", "open_settings", "reset_license", "h_all"]
    o["keys"] := ["k_menu", "k_watch", "k_request", "k_reply", "k_human", "k_interact", "k_issue", "k_stats", "k_copy", "k_panel", "k_emergency", "k_exit", "h_all"]
    o["keys_player"] := ["k_menu", "k_autoedit", "k_bizlist", "k_emergency", "k_exit", "h_all"]
    o["answers"] := ["a_greet", "a_quick", "a_offline", "h_all"]
    o["stats"] := ["st_view", "st_search", "st_reset", "h_all"]
    o["interact"] := ["i_slots", "i_ru", "h_all"]
    if (menuId = "main" && scriptMode != "Admin")
        menuId := "main_player"
    if (menuId = "keys" && scriptMode != "Admin")
        menuId := "keys_player"
    return o[menuId]
}


; === MenuHelpInfo / MenuHelpFill: тема по ключу; подстановка текущих значений в описание ===
MenuHelpInfo(key) {
    if (key = "")
        return ""
    d := MenuHelpData()
    return d.HasKey(key) ? d[key] : ""
}

MenuHelpFill(text) {
    global autoSpMode, autoSpPool, autoSpMaxAge
    if (!InStr(text, "{"))
        return text
    text := StrReplace(text, "{mode}", AutoSpModeName(autoSpMode))
    text := StrReplace(text, "{pool}", autoSpPool)
    text := StrReplace(text, "{age}", AutoSpAgeText(autoSpMaxAge))
    return text
}

; === MenuHelpKey: тема справки по тексту кнопки (текст кнопок с галочками и статусами сопоставляется по названию) ===
MenuHelpKey(text, guiName) {
    global helpBtnMap
    t := Trim(text)
    if (t = "")
        return ""
    if (guiName = "ViMeLlYHelp" && IsObject(helpBtnMap) && helpBtnMap.HasKey(t))
        return helpBtnMap[t]
    if (RegExMatch(t, "^⟲"))
        return "h_reload"
    if (RegExMatch(t, "^⊚"))
        return "h_stop"
    if (RegExMatch(t, "^✘$"))
        return "h_close"
    if (RegExMatch(t, "^⮐"))
        return "h_back"
    if (RegExMatch(t, "^❓"))
        return "h_help"
    if (RegExMatch(t, "^♻")) {
        if (guiName = "ViMeLlYHotKeys")
            return "h_reset_keys"
        if (guiName = "ViMeLlYAnswers")
            return "h_reset_answers"
        return "h_reset_interact"
    }
    if (InStr(t, "Автослежка берёт"))
        return "sp_mode"
    if (InStr(t, "Видимость"))
        return "sp_pool"
    if (RegExMatch(t, "^(✔ )?\d+ (сек|мин)$"))
        return "sp_age"
    if (InStr(t, "Подсказки по репортам"))
        return "report_hints"
    if (InStr(t, "Умные наказания"))
        return "punish_helper"
    if (InStr(t, "Настройки клавиш"))
        return "hotkeys_btn"
    if (InStr(t, "Настройки ответов"))
        return "answers_btn"
    if (InStr(t, "Взаимодействие с игроком"))
        return "interact_btn"
    if (InStr(t, "Файл умных наказаний"))
        return "punish_file"
    if (InStr(t, "Настройки скрипта"))
        return "script_settings"
    if (InStr(t, "Правила ответов"))
        return "answer_rules"
    if (InStr(t, "Слова МАТ"))
        return "punish_words"
    if (RegExMatch(t, "^[✔✘] Подсчёт"))
        return "stats_toggle"
    if (InStr(t, "Статистика администратора"))
        return "stats_btn"
    if (InStr(t, "Ввод команд"))
        return "input_mode"
    if (RegExMatch(t, "^(✔ )?(Медленно|Среднее|Быстро|Оч\.быстро|Настраиваемый)$"))
        return "speed"
    if (InStr(t, "Уведомления на экране"))
        return "tooltips"
    if (RegExMatch(t, "^(✔ )?[↖↗←↙↘] "))
        return "ntf_pos"
    if (InStr(t, "Панель репортов"))
        return "report_panel"
    if (InStr(t, "Подтверждение наказаний"))
        return "confirm"
    if (InStr(t, "Доп. возможности"))
        return "extras"
    if (InStr(t, "Файл дополнений"))
        return "extras_file"
    if (InStr(t, "Открыть файл настроек"))
        return "open_settings"
    if (InStr(t, "Сбросить ключ"))
        return "reset_license"
    if (InStr(t, "Сбросить статистику"))
        return "st_reset"
    if (RegExMatch(t, "^🛠"))
        return "trucker_btn"
    if (RegExMatch(t, "^⤵")) {
        if (guiName = "ViMeLlYStats")
            return "st_search"
        return "search_date"
    }
    return ""
}

; === MenuHelpContext: какое окно открыто -> раздел справки и метка, куда вернуться ===
MenuHelpContext(guiName, ByRef menuId, ByRef retLabel) {
    menuId := ""
    retLabel := ""
    if (guiName = "ViMeLlY") {
        menuId := "main"
        retLabel := "Menu"
    } else if (guiName = "ViMeLlYSettings") {
        menuId := "settings"
        retLabel := "ScriptSettings"
    } else if (guiName = "ViMeLlYHotKeys") {
        menuId := "keys"
        retLabel := "HotKeys"
    } else if (guiName = "ViMeLlYAnswers") {
        menuId := "answers"
        retLabel := "Answers"
    } else if (guiName = "ViMeLlYStats") {
        menuId := "stats"
        retLabel := "AdminStatsPanel"
    } else if (guiName = "ViMeLlYInteract") {
        menuId := "interact"
        retLabel := "InteractMenu"
    }
}

; === MenuHelpOpen: открыть справку из текущего окна (пустой ключ — список тем, иначе — сразу тема) ===
MenuHelpOpen(topicKey := "") {
    global menuNavGuiName
    guiName := menuNavGuiName
    MenuHelpContext(guiName, menuId, retLabel)
    if (menuId = "")
        return
    if (guiName = "ViMeLlYHotKeys") {
        Gosub, SaveHotKeys
        SetTimer, SaveHotkeys, Off
        Gui, ViMeLlYHotKeys:Destroy
    } else if (guiName = "ViMeLlYAnswers") {
        Gosub, SaveAnswers
        SetTimer, SaveAnswers, Off
        Gui, ViMeLlYAnswers:Destroy
    } else if (guiName = "ViMeLlYStats") {
        Gui, ViMeLlYStats:Destroy
    } else if (guiName = "ViMeLlYInteract") {
        InteractWindowClose()
    } else if (guiName = "ViMeLlYSettings") {
        SettingsWindowClose()
    }
    Gui, ViMeLlY:Hide
    MenuHelpShow(menuId, topicKey, retLabel, topicKey != "")
}

; === MenuHelpSelected: F1 — справка по выбранной кнопке ===
MenuHelpSelected() {
    global menuNavGuiName, menuNavItems, menuNavIndex
    if (!MenuKeyboardEnabled() || menuNavGuiName = "ViMeLlYHelp")
        return
    key := ""
    if (menuNavIndex >= 1 && menuNavIndex <= menuNavItems.Length())
        key := menuNavItems[menuNavIndex].help
    MenuHelpOpen(key)
}

; === MenuHelpNeighbor: предыдущая/следующая тема раздела ===
MenuHelpNeighbor(menuId, key, step) {
    order := MenuHelpOrder(menuId)
    n := order.Length()
    idx := 0
    for i, k in order {
        if (k = key)
            idx := i
    }
    if (idx = 0)
        return order[step > 0 ? 1 : n]
    idx += step
    if (idx < 1)
        idx := n
    if (idx > n)
        idx := 1
    return order[idx]
}

; === MenuHelpShow: окно справки: список тем раздела или текст одной темы ===
MenuHelpShow(menuId, key, retLabel, direct) {
    global helpMenu, helpKey, helpReturn, helpDirect, helpBtnMap, guiColor, version
    helpMenu := menuId
    helpKey := key
    helpReturn := retLabel
    helpDirect := direct
    helpBtnMap := {}
    titles := {main: "Главная", settings: "Настройки скрипта", keys: "Назначение клавиш", answers: "Ответы", stats: "Статистика", interact: "Взаимодействие"}
    sectionTitle := "Справка · " . titles[menuId]

    Gui, ViMeLlYHelp:Destroy
    Gui, ViMeLlYHelp:New,, ViMeLlY Script
    Gui, ViMeLlYHelp:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYHelp:Color, % guiColor
    Gui, ViMeLlYHelp:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYHelp:Add, Text, w345 Center, ViMeLlY Script
    Gui, ViMeLlYHelp:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYHelp:Add, Button, yp x344 gHelpBack,⮐
    Gui, ViMeLlYHelp:Add, Button, yp x+1 gClose,✘
    MenuSection("ViMeLlYHelp", sectionTitle)

    data := MenuHelpData()
    if (key = "") {
        Gui, ViMeLlYHelp:Font, s8, Segoe UI
        for _, k in MenuHelpOrder(menuId) {
            btnText := data[k].t
            helpBtnMap[btnText] := k
            Gui, ViMeLlYHelp:Add, Button, x17 y+2 w381 gHelpTopic, %btnText%
        }
    } else {
        info := data[key]
        titleTxt := RegExReplace(info.t, "&", "&&")
        longTxt := RegExReplace(MenuHelpFill(info.l), "&", "&&")
        Gui, ViMeLlYHelp:Font, s10 Bold, Segoe UI
        Gui, ViMeLlYHelp:Add, Text, x17 y+8 w381, %titleTxt%
        Gui, ViMeLlYHelp:Font, s9 Norm, Segoe UI
        Gui, ViMeLlYHelp:Add, Text, x17 y+6 w381, %longTxt%
        Gui, ViMeLlYHelp:Font, s8, Segoe UI
        Gui, ViMeLlYHelp:Add, Button, x17 y+10 w126 gHelpPrev, ◀ Предыдущая
        Gui, ViMeLlYHelp:Add, Button, x+1 yp w127 gHelpList, ☰ Все темы
        Gui, ViMeLlYHelp:Add, Button, x+1 yp w127 gHelpNext, Следующая ▶
    }
    Gui, ViMeLlYHelp:Font, s8, Segoe UI
    Gui, ViMeLlYHelp:Add, Text, x17 y+6 w381 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlYHelp:Font, s7, Comic Sans MS
    Gui, ViMeLlYHelp:Add, Text, x17 y+2 w381 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад
    Gui, ViMeLlYHelp:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYHelp:Add, Link, x25 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    ShowMenuNoActivate("ViMeLlYHelp")
}

; === MenuHelpBack: из темы — к списку (или в меню, если открывали по F1); из списка — в меню ===
MenuHelpBack() {
    global helpKey, helpDirect, helpMenu, helpReturn
    if (helpKey != "" && !helpDirect)
        MenuHelpShow(helpMenu, "", helpReturn, false)
    else
        MenuHelpLeave()
}

MenuHelpLeave() {
    global helpReturn
    ret := helpReturn
    Gui, ViMeLlYHelp:Destroy
    if (ret != "")
        Gosub, %ret%
}


; === MenuSection: заголовок раздела в окне меню ===
MenuSection(guiName, title) {
    Gui, %guiName%:Font, s9 Bold, Segoe UI
    Gui, %guiName%:Add, Text, x17 y+6 w381 Center, ‧ ‧ ‧ ‧ ‧‧‧‧‧‧‧ %title% ‧‧‧‧‧‧‧ ‧ ‧ ‧ ‧
}


; === MainStatusText: строка состояния на главной ===
MainStatusText() {
    return "Режим: " . scriptMode . " · Ввод: " . (isHumanInput ? "ручной" : "автоматический")
}


; === SettingsWindowClose: закрыть окно «Настройки скрипта» (последние значения паузы сохраняются) ===
SettingsWindowClose() {
    global settingsOpen
    if (settingsOpen) {
        Gosub, SaveCustomDelays
        settingsOpen := false
    }
    SetTimer, SaveCustomDelays, Off
    Gui, ViMeLlYSettings:Destroy
}


InteractWindowClose() {
    global intOpen
    if (intOpen) {
        Gosub, SaveInteract
        intOpen := false
    }
    SetTimer, SaveInteract, Off
    Gui, ViMeLlYInteract:Destroy
}


ReturnToMainMenu() {
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYStats:Destroy
    Gui, ViMeLlYHelp:Destroy
    InteractWindowClose()
    SettingsWindowClose()
    ShowMenuNoActivate("ViMeLlY")
}

; === CloseMenuWindows: закрыть меню, не завершая работу скрипта ===
CloseMenuWindows() {
    global menuNavGuiName, menuNavGuiHwnd, menuNavItems, menuNavIndex
    Gui, ViMeLlY:Destroy
    Gui, ViMeLlYHotKeys:Destroy
    Gui, ViMeLlYAnswers:Destroy
    Gui, ViMeLlYStats:Destroy
    Gui, ViMeLlYHelp:Destroy
    InteractWindowClose()
    SettingsWindowClose()
    SetTimer, SaveHotkeys, Off
    SetTimer, SaveAnswers, Off
    menuNavGuiName := ""
    menuNavGuiHwnd := 0
    menuNavItems := []
    menuNavIndex := 0
}

; === MenuKeyboardEscape: Esc closes main menu or returns from a submenu ===
MenuKeyboardEscape() {
    global menuNavGuiName
    if (!MenuKeyboardEnabled())
        return
    if (menuNavGuiName = "ViMeLlYHelp") {
        MenuHelpBack()
        return
    }
    if (menuNavGuiName = "ViMeLlY")
        CloseMenuWindows()
    else
        ReturnToMainMenu()
}


; ====================================================================================================================
; GUI: ОБРАБОТЧИКИ (МЕТКИ)
; ====================================================================================================================

Menu:
    guiColorFunc()
    ansLogStatus := reportLog ? "✔ Подсказки по репортам" : "✘ Подсказки по репортам"
    autoSpModeName := AutoSpModeName(autoSpMode)
    punishHelperSwitch := punishHelperStatus ? "✔ Умные наказания" : "✘ Умные наказания"
    adminStatsSwitch := adminStatsStatus ? "✔ Подсчёт" : "✘ Подсчёт"

    Gui, ViMeLlY:New,, ViMeLlY Script
    Gui, ViMeLlY:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlY:Color, % guiColor
    Gui, ViMeLlY:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Text, w345 Center, ViMeLlY Script - Главная
    Gui, ViMeLlY:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlY:Add, Button, yp x288 gHelpOpen,❓
    Gui, ViMeLlY:Add, Button, yp x+1 gReload,⟲
    Gui, ViMeLlY:Add, Button, yp x+1 gStop,⊚
    Gui, ViMeLlY:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlY:Font, s8, Segoe UI
    Gui, ViMeLlY:Add, Text, x17 y+1 w381 Center vMainStatusLine, % MainStatusText()

    if (scriptMode == "Admin") {
        MenuSection("ViMeLlY", "Помощник по репортам")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w271 gAutoSpMode_Cycle vAutoSpModeButton, ⇄ Автослежка берёт: %autoSpModeName%
        Gui, ViMeLlY:Add, Button, x+1 yp w109 gAutoSpPool_Cycle vAutoSpPoolButton, 🧠 Видимость: %autoSpPool%
        Gui, ViMeLlY:Add, Text, x17 y+4 w381, ⏱ Область досягаемости репорта:
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+1 w75 gAutoSpAgeSelect vAutoSpAge1, % AutoSpAgeBtnText(1)
        Gui, ViMeLlY:Add, Button, x+1 yp w75 gAutoSpAgeSelect vAutoSpAge2, % AutoSpAgeBtnText(2)
        Gui, ViMeLlY:Add, Button, x+1 yp w75 gAutoSpAgeSelect vAutoSpAge3, % AutoSpAgeBtnText(3)
        Gui, ViMeLlY:Add, Button, x+1 yp w75 gAutoSpAgeSelect vAutoSpAge4, % AutoSpAgeBtnText(4)
        Gui, ViMeLlY:Add, Button, x+1 yp w77 gAutoSpAgeSelect vAutoSpAge5, % AutoSpAgeBtnText(5)
        Gui, ViMeLlY:Add, Button, x17 y+1 w190 gReportLog_ToggleStatus vStatusLogButton, %ansLogStatus%
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gPunishHelper_ToggleStatus vPunishHelperButton, %punishHelperSwitch%

        MenuSection("ViMeLlY", "Настройки")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w190 gHotKeys,🕹 Настройки клавиш྾
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gAnswers,⚙️ Настройки ответов྾
        Gui, ViMeLlY:Add, Button, x17 y+1 w381 gInteractMenu, 🎯 Взаимодействие с игроком
        Gui, ViMeLlY:Add, Button, x17 y+1 w190 gOpenPunishHelper, 📄 Файл умных наказаний
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gScriptSettings,⚙️ Настройки скрипта྾
        Gui, ViMeLlY:Add, Button, x17 y+1 w190 gOpenAnswerRules, 📝 Правила ответов
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gOpenPunishWords, 📝 Слова МАТ/ОСК

        MenuSection("ViMeLlY", "Статистика")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w100 vadminStatsButton gToggleAdminStats, %adminStatsSwitch%
        Gui, ViMeLlY:Add, Button, x+1 yp w280 gAdminStatsPanel, 📊 Статистика администратора
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

        MenuSection("ViMeLlY", "Настройки")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w190 gHotKeys,🕹 Настройки клавиш྾
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gScriptSettings,⚙️ Настройки скрипта྾
    }

    Gui, ViMeLlY:Font, s8, Segoe UI
    Gui, ViMeLlY:Add, Text, x17 y+6 w381 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlY:Font, s7, Comic Sans MS
    Gui, ViMeLlY:Add, Text, x17 y+2 w381 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • F1 — справка • Esc — назад
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
    IniRead, interactKey, %settingsFile%, Keys, Interact, %A_Space%
    IniRead, autoIssueKey, %settingsFile%, Keys, autoIssue, %A_Space%
    IniRead, copyAChatKey, %settingsFile%, Keys, CopyAChat
    IniRead, statsKey, %settingsFile%, Keys, AdminStats
    IniRead, autoEditKey, %settingsFile%, Keys, autoEdit
    IniRead, autoBizlistKey, %settingsFile%, Keys, autoBizlist
    IniRead, emergencyDeleteKey, %settingsFile%, Keys, EmergencyDelete
    IniRead, panelHideKey, %settingsFile%, Keys, PanelHide, Insert

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYHotKeys:New,, ViMeLlY Script
    Gui, ViMeLlYHotKeys:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYHotKeys:Color, % guiColor
    Gui, ViMeLlYHotKeys:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, w400 Center, ViMeLlY Script
    Gui, ViMeLlYHotKeys:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Button, yp x291 gHelpOpen,❓
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gReload,⟲
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gResetHotkeys,♻️
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYHotKeys:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYHotKeys:Add, Text, y+1 xm w400 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Назначение клавиш ‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
    Gui, ViMeLlYHotKeys:Font, s8, Segoe UI
    Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🔗｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w115 Center, Меню
    Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Menu x185 yp h18 w100, %menuKey%
    Gui, ViMeLlYHotKeys:Add, Text, yp vHK_MenuText x+10 w130, % "‖ " .  ReadableHotkey(menuKey)
    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center, % "° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡ " . (scriptMode == "Admin" ? "Слежка, ответы и выдача" : "Игровые функции") . " ≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °"

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
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢🎯｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Взаимодействие
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_Interact gValidateKey x185 yp h18 +0x200 w100, %interactKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_InteractText x+10 w130, % "‖ " .  ReadableHotkey(interactKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📜｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Автовыдача
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_autoIssue gValidateKey x185 yp h18 +0x200 w100, %autoIssueKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_autoIssueText x+10 w130, % "‖ " .  ReadableHotkey(autoIssueKey)
        Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡ Прочее ≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
        Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢📊｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Статистика
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_AdminStats x185 yp h18 +0x200 w100, %statsKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_AdminStatsText x+10 w130, % "‖ " .  ReadableHotkey(statsKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+3 x25 w30, ｢📂｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Копирование
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_CopyAChat x185 yp h18 +0x200 w100, %copyAChatKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_CopyAChatText x+10 w130, % "‖ " .  ReadableHotkey(copyAChatKey)
        Gui, ViMeLlYHotKeys:Add, Text, y+3 x25 w30, ｢👁｣
        Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Панель репортов
        Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_PanelHide gValidateKey x185 yp h18 +0x200 w100, %panelHideKey%
        Gui, ViMeLlYHotKeys:Add, Text, yp vHK_PanelHideText x+10 w130, % "‖ " .  ReadableHotkey(panelHideKey)
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

    Gui, ViMeLlYHotKeys:Add, Text, x25 y+3 w400 Center,° ≡≡≡≡≡≡≡≡≡≡≡≡≡≡ Аварийные ≡≡≡≡≡≡≡≡≡≡≡≡≡≡ °
    Gui, ViMeLlYHotKeys:Add, Text, y+3 x25 w30, ｢🛑｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Аварийное удаление
    Gui, ViMeLlYHotKeys:Add, Hotkey, vHK_EmergencyDelete x185 yp h18 +0x200 w100 Center, %emergencyDeleteKey%
    Gui, ViMeLlYHotKeys:Add, Text, yp vHK_EmergencyDeleteText x+10 w130, % "‖ " .  ReadableHotkey(emergencyDeleteKey)
    Gui, ViMeLlYHotKeys:Add, Text, y+5 x25 w30, ｢⏹｣
    Gui, ViMeLlYHotKeys:Add, Text, yp x+0 w125 Center,Отключение скрипта
    Gui, ViMeLlYHotKeys:Add, Edit, x185 yp h18 +0x200 w100 ReadOnly, Ctrl + Alt + Esc
    Gui, ViMeLlYHotKeys:Add, Text, yp x+10, ‖ Ctrl + Alt + Esc
    Gui, ViMeLlYHotKeys:Font, s8, Segoe UI
    Gui, ViMeLlYHotKeys:Add, Text, x25 y+6 w400 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlYHotKeys:Font, s7, Comic Sans MS
    Gui, ViMeLlYHotKeys:Add, Text, x25 y+2 w400 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • F1 — справка • Esc — назад
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
    Gui, ViMeLlYAnswers:Add, Button, yp x271 gHelpOpen,❓
    Gui, ViMeLlYAnswers:Add, Button, yp x+1 gReload,⟲
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
    Gui, ViMeLlYAnswers:Font, s8, Segoe UI
    Gui, ViMeLlYAnswers:Add, Text, x25 y+6 w380 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlYAnswers:Font, s7, Comic Sans MS
    Gui, ViMeLlYAnswers:Add, Text, x25 y+2 w380 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • F1 — справка • Esc — назад
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
    Gui, ViMeLlYStats:Add, Button, yp x281 gHelpOpen,❓
    Gui, ViMeLlYStats:Add, Button, yp x+1 gReload,⟲
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
    Gui, ViMeLlYStats:Font, s8, Segoe UI
    Gui, ViMeLlYStats:Add, Text, x25 y+6 w380 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlYStats:Font, s7, Comic Sans MS
    Gui, ViMeLlYStats:Add, Text, x25 y+2 w380 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • F1 — справка • Esc — назад
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
    guiColorFunc()
    inputBtnText := isHumanInput ? "✋ Ввод команд: Ручной (имитация) ☺" : "⚡ Ввод команд: Автоматический ♛"
    tipBtnText := isToolTipActive ? "💬 Уведомления на экране: ✔ Включены" : "💬 Уведомления на экране: ✘ Выключены"
    addBtnText := additionalFeaturesStatus ? "➕ Доп. возможности: ✔ Включены" : "➕ Доп. возможности: ✘ Выключены"

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYSettings:New,, ViMeLlY Script
    Gui, ViMeLlYSettings:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYSettings:Color, % guiColor
    Gui, ViMeLlYSettings:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Text, w345 Center, ViMeLlY Script
    Gui, ViMeLlYSettings:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Button, yp x288 gHelpOpen,❓
    Gui, ViMeLlYSettings:Add, Button, yp x+1 gReload,⟲
    Gui, ViMeLlYSettings:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYSettings:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYSettings:Add, Text, y+1 x17 w381 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Настройки скрипта ‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧

    MenuSection("ViMeLlYSettings", "Ввод команд")
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w381 gToggleInputMode vInputModeButton, %inputBtnText%
    if (scriptMode == "Admin") {
        Gui, ViMeLlYSettings:Font, s8, Segoe UI
        Gui, ViMeLlYSettings:Add, Text, x17 y+5 w381, Скорость ручного ввода:
        Gui, ViMeLlYSettings:Add, Button, x17 y+1 w75 gSetup1 vSetup_1, % (currentSetup = "Медленно" ? "✔ Медленно" : "Медленно")
        Gui, ViMeLlYSettings:Add, Button, x+1 yp w65 gSetup2 vSetup_2, % (currentSetup = "Среднее" ? "✔ Среднее" : "Среднее")
        Gui, ViMeLlYSettings:Add, Button, x+1 yp w65 gSetup3 vSetup_3, % (currentSetup = "Быстро" ? "✔ Быстро" : "Быстро")
        Gui, ViMeLlYSettings:Add, Button, x+1 yp w70 gSetup4 vSetup_4, % (currentSetup = "Оч.быстро" ? "✔ Оч.быстро" : "Оч.быстро")
        Gui, ViMeLlYSettings:Add, Button, x+1 yp w102 gSetup5 vSetup_5, % (currentSetup = "Настраиваемый" ? "✔ Настраиваемый" : "Настраиваемый")
        Gui, ViMeLlYSettings:Font, s7, Segoe UI
        if (currentSetup == "Настраиваемый") {
            IniRead, d_sp, %settingsFile%, Preset, Delay1
            IniRead, d_1, %settingsFile%, Preset, Delay2
            IniRead, d_2, %settingsFile%, Preset, Delay3
            Gui, ViMeLlYSettings:Font, s8, Segoe UI
            Gui, ViMeLlYSettings:Add, Text, x17 y+5 w300, Пауза после команды, мс:
            Gui, ViMeLlYSettings:Add, Edit, x+0 yp-3 w80 h18 Center vMySetup_sp, %d_sp%
            Gui, ViMeLlYSettings:Add, Text, x17 y+5 w300, Пауза между символами, от (мс):
            Gui, ViMeLlYSettings:Add, Edit, x+0 yp-3 w80 h18 Center vMySetup_d1, %d_1%
            Gui, ViMeLlYSettings:Add, Text, x17 y+5 w300, Пауза между символами, до (мс):
            Gui, ViMeLlYSettings:Add, Edit, x+0 yp-3 w80 h18 Center vMySetup_d2, %d_2%
            SetTimer, SaveCustomDelays, 150
        } else {
            SetTimer, SaveCustomDelays, Off
        }
    }

    MenuSection("ViMeLlYSettings", "Уведомления")
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w381 gToggleToolTips vToolTipsButton, %tipBtnText%
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Text, x17 y+5 w381, Где показывать уведомления:
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w190 gNtfPosSelect vNtfPos1, % NtfPosText(1)
    Gui, ViMeLlYSettings:Add, Button, x+1 yp w190 gNtfPosSelect vNtfPos2, % NtfPosText(2)
    Gui, ViMeLlYSettings:Add, Button, x17 y+1 w381 gNtfPosSelect vNtfPos3, % NtfPosText(3)
    Gui, ViMeLlYSettings:Add, Button, x17 y+1 w190 gNtfPosSelect vNtfPos4, % NtfPosText(4)
    Gui, ViMeLlYSettings:Add, Button, x+1 yp w190 gNtfPosSelect vNtfPos5, % NtfPosText(5)

    if (scriptMode == "Admin") {
        MenuSection("ViMeLlYSettings", "Панель репортов")
        Gui, ViMeLlYSettings:Font, s8, Segoe UI
        Gui, ViMeLlYSettings:Add, Button, x17 y+2 w381 gToggleReportPanel vReportPanelButton, % ReportPanelBtnText()
        MenuSection("ViMeLlYSettings", "Наказания")
        Gui, ViMeLlYSettings:Font, s8, Segoe UI
        Gui, ViMeLlYSettings:Add, Button, x17 y+2 w381 gToggleConfirm vPunishConfirmButton, % PunishConfirmBtnText()
        MenuSection("ViMeLlYSettings", "Дополнения")
        Gui, ViMeLlYSettings:Font, s8, Segoe UI
        Gui, ViMeLlYSettings:Add, Button, x17 y+2 w250 gAdditionalFeatures_ToggleStatus vAdditionalFeaturesButton, %addBtnText%
        Gui, ViMeLlYSettings:Add, Button, x+1 yp w130 gOpenAdditionalFeatures, 📄 Файл дополнений
    }

    MenuSection("ViMeLlYSettings", "Система")
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w190 gOpenSettings, 📂 Открыть файл настроек
    Gui, ViMeLlYSettings:Add, Button, x+1 yp w190 gResetLicenseKey, 🔑 Сбросить ключ доступа

    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Text, x17 y+6 w381 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlYSettings:Font, s7, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Text, x17 y+2 w381 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • F1 — справка • Esc — назад
    Gui, ViMeLlYSettings:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Link, x25 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    ShowMenuNoActivate("ViMeLlYSettings")
    settingsOpen := true
Return

ToggleInputMode:
    isHumanInput := !isHumanInput
    IniWrite, %isHumanInput%, %settingsFile%, Preset, isHumanInput
    newInputText := isHumanInput ? "✋ Ввод команд: Ручной (имитация) ☺" : "⚡ Ввод команд: Автоматический ♛"
    GuiControl, ViMeLlYSettings:, InputModeButton, %newInputText%
    GuiControl, ViMeLlY:, MainStatusLine, % MainStatusText()
Return

ToggleToolTips:
    isToolTipActive := !isToolTipActive
    IniWrite, %isToolTipActive%, %settingsFile%, Preset, isToolTipActive
    newTipText := isToolTipActive ? "💬 Уведомления на экране: ✔ Включены" : "💬 Уведомления на экране: ✘ Выключены"
    GuiControl, ViMeLlYSettings:, ToolTipsButton, %newTipText%
Return

ToggleReportPanel:
    reportPanelEnabled := reportPanelEnabled ? 0 : 1
    IniWrite, %reportPanelEnabled%, %settingsFile%, Preset, reportPanel
    GuiControl, ViMeLlYSettings:, ReportPanelButton, % ReportPanelBtnText()
    ReportPanelApply()
Return

ToggleConfirm:
    punishConfirmEnabled := punishConfirmEnabled ? 0 : 1
    IniWrite, %punishConfirmEnabled%, %settingsFile%, Preset, punishConfirm
    GuiControl, ViMeLlYSettings:, PunishConfirmButton, % PunishConfirmBtnText()
Return

; === NtfPosSelect: выбор положения плашек (кнопки NtfPos1…NtfPos5 в настройках) ===
NtfPosSelect:
    newCorner := SubStr(A_GuiControl, 0) + 0
    if (newCorner < 1 || newCorner > 5)
        Return
    ntfCorner := newCorner
    IniWrite, %ntfCorner%, %settingsFile%, Preset, ntfCorner
    Loop, 5
        GuiControl, ViMeLlYSettings:, NtfPos%A_Index%, % NtfPosText(A_Index)
    ; Показанные сейчас плашки переезжают сами (NtfLayout), пробная плашка показывает новое место.
    NtfShow("NtfPosPreview", "Плашки", "Теперь плашки здесь: " . NtfPosName(ntfCorner) . ".", "4C8DFF", 3500)
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
    IniDelete, %settingsFile%, Keys, Interact
    IniDelete, %settingsFile%, Keys, autoIssue
    IniDelete, %settingsFile%, Keys, AdminStats
    IniDelete, %settingsFile%, Keys, CopyAChat
    IniDelete, %settingsFile%, Keys, autoEdit
    IniDelete, %settingsFile%, Keys, autoBizlist
    IniDelete, %settingsFile%, Keys, EmergencyDelete
    IniDelete, %settingsFile%, Keys, PanelHide

    IniWrite, F2, %settingsFile%, Keys, Menu
    IniWrite, %A_Space%, %settingsFile%, Keys, Watch
    IniWrite, %A_Space%, %settingsFile%, Keys, Request
    IniWrite, %A_Space%, %settingsFile%, Keys, Reply
    IniWrite, %A_Space%, %settingsFile%, Keys, humanReply
    IniWrite, %A_Space%, %settingsFile%, Keys, Interact
    IniWrite, %A_Space%, %settingsFile%, Keys, autoIssue
    IniWrite, F10, %settingsFile%, Keys, AdminStats
    IniWrite, %A_Space%, %settingsFile%, Keys, CopyAChat
        IniWrite, %A_Space%, %settingsFile%, Keys, autoEdit
    IniWrite, %A_Space%, %settingsFile%, Keys, autoBizlist
    IniWrite, %A_Space%, %settingsFile%, Keys, EmergencyDelete
    IniWrite, Insert, %settingsFile%, Keys, PanelHide

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

HelpOpen:
    MenuHelpOpen("")
Return

HelpBack:
    MenuHelpBack()
Return

HelpTopic:
    helpPickedKey := helpBtnMap[A_GuiControl]
    if (helpPickedKey != "")
        MenuHelpShow(helpMenu, helpPickedKey, helpReturn, false)
Return

HelpList:
    MenuHelpShow(helpMenu, "", helpReturn, false)
Return

HelpPrev:
    MenuHelpShow(helpMenu, MenuHelpNeighbor(helpMenu, helpKey, -1), helpReturn, helpDirect)
Return

HelpNext:
    MenuHelpShow(helpMenu, MenuHelpNeighbor(helpMenu, helpKey, 1), helpReturn, helpDirect)
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

OpenAnswerRules:
    if (EnsureAnswerRulesFile())
        Run, notepad %answerRulesFile%
    else
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Не удалось создать answer-rules.txt.", 2500)
Return

OpenPunishWords:
    if (EnsurePunishWordsFile())
        Run, notepad %punishWordsFile%
    else
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Не удалось создать punish-words.txt.", 2500)
Return

OpenAdditionalFeatures:
    if (additionalFeaturesStatus) {
        Run, notepad %additionalFeaturesFile%
    } else {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Файл доп. скрипта не создан`, так как функция отключена.", 2000)
    }
Return

AutoSpMode_Cycle:
    autoSpMode := (autoSpMode >= 3) ? 1 : autoSpMode + 1
    IniWrite, %autoSpMode%, %settingsFile%, Preset, autoSpMode
    autoSpModeName := AutoSpModeName(autoSpMode)
    GuiControl,, AutoSpModeButton, ⇄ Автослежка берёт: %autoSpModeName%
    MenuRefreshHint()
Return

AutoSpPool_Cycle:
    autoSpPool := AutoSpNextPool(autoSpPool)
    IniWrite, %autoSpPool%, %settingsFile%, Preset, autoSpPool
    GuiControl,, AutoSpPoolButton, 🧠 Видимость: %autoSpPool%
    MenuRefreshHint()
Return

; === AutoSpAgeSelect: выбор времени, которое скрипт помнит репорт (кнопки AutoSpAge1…AutoSpAge5 на главной) ===
AutoSpAgeSelect:
    ageIndex := SubStr(A_GuiControl, 0) + 0
    ageList := AutoSpAgeList()
    if (ageIndex < 1 || ageIndex > ageList.Length())
        Return
    autoSpMaxAge := ageList[ageIndex]
    IniWrite, %autoSpMaxAge%, %settingsFile%, Preset, autoSpMaxAge
    Loop, 5
        GuiControl, ViMeLlY:, AutoSpAge%A_Index%, % AutoSpAgeBtnText(A_Index)
    MenuRefreshHint()
Return

InteractMenu:
    IniRead, kI, %settingsFile%, Keys, Interact, %A_Space%
    kI := (kI == "") ? "Нет" : ReadableHotkey(kI)
    intSaved := {}

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYInteract:New,, ViMeLlY Script
    Gui, ViMeLlYInteract:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYInteract:Color, % guiColor
    Gui, ViMeLlYInteract:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYInteract:Add, Text, w380 Center, ViMeLlY Script
    Gui, ViMeLlYInteract:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYInteract:Add, Button, yp x271 gHelpOpen,❓
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gReload,⟲
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gResetInteract,♻️
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYInteract:Add, Text, y+1 xm w380 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧ Взаимодействие с игроком ‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
    Gui, ViMeLlYInteract:Font, s8, Segoe UI
    Gui, ViMeLlYInteract:Add, Text, x100 y+3 w110, Команда
    Gui, ViMeLlYInteract:Add, Text, x+5 yp w175, Текст после ID
    Gui, ViMeLlYInteract:Font, s8, Cascadia Mono
    Loop, 10
    {
        iS := A_Index
        iK := (iS = 10) ? 0 : iS
        IniRead, iC, %settingsFile%, Interact, Cmd%iS%, %A_Space%
        IniRead, iA, %settingsFile%, Interact, Args%iS%, %A_Space%
        iC := Trim(iC)
        iA := Trim(iA)
        intSaved["C" . iS] := iC
        intSaved["A" . iS] := iA
        Gui, ViMeLlYInteract:Add, Text, y+1 x25, %kI% + %iK% »
        Gui, ViMeLlYInteract:Add, Edit, x100 yp h17 Limit64 +0x200 w110 vIntCmd%iS%, %iC%
        Gui, ViMeLlYInteract:Add, Edit, x+5 yp h17 Limit128 +0x200 w175 vIntArgs%iS%, %iA%
    }
    Gui, ViMeLlYInteract:Font, s8, Segoe UI
    Gui, ViMeLlYInteract:Add, Text, x25 y+6 w380 h32 Center vMenuKeyboardSelection, Наведите курсор или выберите кнопку стрелками — здесь появится описание
    Gui, ViMeLlYInteract:Font, s7, Comic Sans MS
    Gui, ViMeLlYInteract:Add, Text, x25 y+2 w380 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • F1 — справка • Esc — назад
    Gui, ViMeLlYInteract:Font, s7 Bold, Comic Sans MS
    Gui, ViMeLlYInteract:Add, Link, x45 y+5, ≣≣≣ ❤ <a href="https://t.me/+1eeJ_8vhugYyNmMy">ViMeLlY Script (%version%)</a> | Приятного пользования. ❤ ≣≣≣
    ShowMenuNoActivate("ViMeLlYInteract")
    intOpen := true

    SetTimer, SaveInteract, 300
Return

SaveInteract:
    Gui, ViMeLlYInteract:Submit, NoHide
    Loop, 10
    {
        iS := A_Index
        iC := IntCmd%iS%
        iA := IntArgs%iS%
        iC := Trim(iC)
        iA := Trim(iA)
        if (!(iC == intSaved["C" . iS])) {
            IniWrite, %iC%, %settingsFile%, Interact, Cmd%iS%
            intSaved["C" . iS] := iC
        }
        if (!(iA == intSaved["A" . iS])) {
            IniWrite, %iA%, %settingsFile%, Interact, Args%iS%
            intSaved["A" . iS] := iA
        }
    }
Return

ResetInteract:
    SetTimer, SaveInteract, Off
    Loop, 10
    {
        IniWrite, %A_Space%, %settingsFile%, Interact, Cmd%A_Index%
        IniWrite, %A_Space%, %settingsFile%, Interact, Args%A_Index%
    }
    Gosub, InteractMenu
Return

ReportLog_ToggleStatus:
    reportLog := !reportLog
    newStatus := reportLog ? "✔ Подсказки по репортам" : "✘ Подсказки по репортам"
    
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
    newStatus3 := additionalFeaturesStatus ? "➕ Доп. возможности: ✔ Включены" : "➕ Доп. возможности: ✘ Выключены"
    
    GuiControl, ViMeLlYSettings:, AdditionalFeaturesButton, %newStatus3%
    
    if (additionalFeaturesStatus) {
        IniWrite, 1, %settingsFile%, Preset, additionalFeaturesStatus
    } else {
        IniWrite, 0, %settingsFile%, Preset, additionalFeaturesStatus
        ; Не удаляем пользовательский дополнительный модуль.
    }
Return

ToggleAdminStats:
    adminStatsStatus := !adminStatsStatus
    newStatus4 := adminStatsStatus ? "✔ Подсчёт" : "✘ Подсчёт"
    
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
    if (truckerSettings) {
        if (MinutesOfCatching1 != "") {
            IniWrite, %MinutesOfCatching1%, %settingsFile%, Preset, minutesOfCatching1
        } if (MinutesOfCatching2 != "") {
            IniWrite, %MinutesOfCatching2%, %settingsFile%, Preset, minutesOfCatching2
        }
    }
Return

SaveCustomDelays:
    if (currentSetup != "Настраиваемый")
        Return
    Gui, ViMeLlYSettings:Submit, NoHide
    CustomDelaysApply(MySetup_sp, MySetup_d1, MySetup_d2)
Return

SaveHotKeys:
    Gui, ViMeLlYHotKeys:Submit, NoHide
    Gui, ViMeLlY:Submit, NoHide

    hotkeys["Watch"] := HK_Watch
    hotkeys["Request"] := HK_Request
    hotkeys["Reply"] := HK_Reply
    hotkeys["humanReply"] := HK_humanReply
    hotkeys["Interact"] := HK_Interact
    hotkeys["autoIssue"] := HK_autoIssue
    hotkeys["CopyAChat"] := HK_CopyAChat
    hotkeys["Menu"] := HK_Menu
    hotkeys["AdminStats"] := HK_AdminStats
    hotkeys["autoEdit"] := HK_autoEdit
    hotkeys["autoBizlist"] := HK_autoBizlist
    hotkeys["EmergencyDelete"] := HK_EmergencyDelete
    hotkeys["PanelHide"] := HK_PanelHide

    IniWrite, %HK_Menu%, %settingsFile%, Keys, Menu

    if (scriptMode == "Admin") {
        IniWrite, %HK_Watch%, %settingsFile%, Keys, Watch
        IniWrite, %HK_Reply%, %settingsFile%, Keys, Reply
        IniWrite, %HK_Request%, %settingsFile%, Keys, Request
        IniWrite, %HK_humanReply%, %settingsFile%, Keys, humanReply
        IniWrite, %HK_Interact%, %settingsFile%, Keys, Interact
        IniWrite, %HK_autoIssue%, %settingsFile%, Keys, autoIssue
        IniWrite, %HK_CopyAChat%, %settingsFile%, Keys, CopyAChat
        IniWrite, %HK_AdminStats%, %settingsFile%, Keys, AdminStats
        IniWrite, %HK_PanelHide%, %settingsFile%, Keys, PanelHide
        GuiControl, ViMeLlYHotKeys:, HK_PanelHideText, % (HK_PanelHide) ? "‖ " . ReadableHotkey(HK_PanelHide) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_WatchText, % (HK_Watch) ? "‖ " . ReadableHotkey(HK_Watch) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_ReplyText, % (HK_Reply) ? "‖ " . ReadableHotkey(HK_Reply) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_RequestText, % (HK_Request) ? "‖ " . ReadableHotkey(HK_Request) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_humanReplyText, % (HK_humanReply) ? "‖ " . ReadableHotkey(HK_humanReply) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_InteractText, % (HK_Interact) ? "‖ " . ReadableHotkey(HK_Interact) : "‖ Не назначена"
        GuiControl, ViMeLlYHotKeys:, HK_autoIssueText, % (HK_autoIssue) ? "‖ " . ReadableHotkey(HK_autoIssue) : "‖ Не назначена"
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
    
    Gosub, ScriptSettings
Return

Setup2:
    SetPreset("Среднее", 250, 80, 90)
    
    IniWrite, Среднее, %settingsFile%, Preset, currentSetup
    IniWrite, 250, %settingsFile%, Preset, Delay1
    IniWrite, 80, %settingsFile%, Preset, Delay2
    IniWrite, 90, %settingsFile%, Preset, Delay3
    
    Gosub, ScriptSettings
Return

Setup3:
    SetPreset("Быстро", 230, 60, 80)
    
    IniWrite, Быстро, %settingsFile%, Preset, currentSetup
    IniWrite, 230, %settingsFile%, Preset, Delay1
    IniWrite, 60, %settingsFile%, Preset, Delay2
    IniWrite, 80, %settingsFile%, Preset, Delay3
    
    Gosub, ScriptSettings
Return

Setup4:
    SetPreset("Оч.быстро", 160, 40, 60)
    
    IniWrite, Оч.быстро, %settingsFile%, Preset, currentSetup
    IniWrite, 160, %settingsFile%, Preset, Delay1
    IniWrite, 40, %settingsFile%, Preset, Delay2
    IniWrite, 60, %settingsFile%, Preset, Delay3
    
    Gosub, ScriptSettings
Return

Setup5:
    IniWrite, Настраиваемый, %settingsFile%, Preset, currentSetup
    
    currentSetup := "Настраиваемый"
    
    Gosub, ScriptSettings
Return

EmergencyDelete:
ExitApp


; ====================================================================================================================
; АДМИН: СЛЕЖКА, ЗАПРОСЫ И ВЗАИМОДЕЙСТВИЕ
; ====================================================================================================================

getAnswer(val) {
    global settingsFile
    IniRead, result, %settingsFile%, Answers, %val%
    
    Return result
}

hintTimersOff() {
    SetTimer, respondComplaint, Off
    SetTimer, respondCommand, Off
}

; spStage: 0 — слежки нет, 1 — доступно приветствие (Reply), 2 — быстрые ответы (Reply + 1…0), 3 — ответные клавиши уже отработали.
spTimersOff() {
    global spStage
    SetTimer, WatchKeys, Off
    SetTimer, WatchSpectate, Off
    spStage := 3
}

WatchKeys() {
    global spReplyTarget, spStage, spActiveUntil

    ; Reply + Enter — ответ на подсказку нового репорта (respondComplaint), а не на жалобу, за которой следим.
    if (spReplyTarget = "" || GetKeyState("Enter", "P"))
        return
    if hotkeys["Reply"] != "" {
        if GetKeyState(hotkeys["Reply"], "P") {
            ; Адресат фиксируется в момент /sp и не меняется от новых репортов.
            target := spReplyTarget
            spTimersOff()
            SendMessage, 0x50,, 0x4190419,, A
            sendReply(target, getAnswer("Spectate"))
            SetTimer, WatchSpectate, 30
            spStage := 2
            spActiveUntil := A_TickCount + 600000
        }
    }
}

WatchSpectate() {
    global spReplyTarget, spActiveUntil

    if (spReplyTarget = "" || GetKeyState("Enter", "P"))
        return
    if (hotkeys["Reply"] != "") {
        Loop, 10 {
            key := A_Index = 10 ? "0" : A_Index

            if GetKeyState(hotkeys["Reply"], "P") && GetKeyState(key, "P") {
                spTimersOff()
                SendMessage, 0x50,, 0x4190419,, A
                sendReply(spReplyTarget, getAnswer("Ans" . key))
                spActiveUntil := A_TickCount + 600000
                break
            }
        }
    }
}

; === WatchInteract: бинды взаимодействия с игроком из репорта (клавиша Interact + 1..5) ===
WatchInteract() {
    key := hotkeys["Interact"]
    if (scriptMode != "Admin" || interactID = "" || key = "" || key = hotkeys["Reply"])
        return
    if (ChatIsOpen || !WinActive("ahk_exe gta_sa.exe") || !GetKeyState(key, "P"))
        return

    Loop, 10 {
        slot := A_Index
        digit := (slot = 10) ? "0" : slot
        if GetKeyState(digit, "P") {
            InteractCommand(slot)
            KeyWait, %digit%, T5
            return
        }
    }
}

; === RuLayoutToEn: текст, набранный в русской раскладке, -> те же клавиши в английской (.пуемур -> /getveh) ===
RuLayoutToEn(text) {
    ru := "йцукенгшщзхъфывапролджэячсмитьбю"
    en := "qwertyuiop[]asdfghjkl;'zxcvbnm,."
    out := ""
    Loop, Parse, text
    {
        ch := A_LoopField
        pos := (ch = ".") ? 0 : InStr(ru, ch)
        if (ch = ".") {
            out .= "/"
        } else if (pos) {
            lo := SubStr(en, pos, 1)
            StringLower, chLow, ch
            if (!(ch == chLow))
                StringUpper, lo, lo
            out .= lo
        } else {
            out .= ch
        }
    }
    return out
}


; === InteractCommand: команда слота 1..10 (клавиши 1..9, 0) на игрока interactID. Команды задаются в меню «Взаимодействие» ===
; Итоговая команда: <cmd> <ID> <args>. Пустой cmd = слот не заполнен, ничего не отправляется.
InteractCommand(slot) {
    global isHumanInput, CMDDelay, InputDelay1, InputDelay2, requestCanRecall, interactID

    IniRead, cmd, %settingsFile%, Interact, Cmd%slot%, %A_Space%
    IniRead, args, %settingsFile%, Interact, Args%slot%, %A_Space%
    cmd := Trim(cmd)
    args := Trim(args)
    if (SubStr(cmd, 1, 1) = ".")
        cmd := RuLayoutToEn(cmd)

    if (cmd = "") {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Слот " . (slot = 10 ? 0 : slot) . " не заполнен.", 1500)
        return
    }
    if (SubStr(cmd, 1, 1) != "/")
        cmd := "/" . cmd

    ; Для прямого ввода экранируем спецсимволы SendInput; очередь чата экранирует сама.
    cmdE := SendEsc(cmd)
    argsE := SendEsc(args)
    requestCanRecall := false

    if (isHumanInput) {
        SendInput, {F6}%cmdE%{Space}
        Sleep, %CMDDelay%

        Loop, Parse, interactID
        {
            SendInput, %A_LoopField%
            Random, rDelay1, %InputDelay1%, %InputDelay2%
            Sleep, rDelay1
        }

        if (args != "")
            SendInput, {Space}%argsE%

        SendInput, {Enter down}
        Sleep, 50
        SendInput, {Enter up}
    } else {
        AutomationQueueChat(cmd . " " . interactID . (args != "" ? " " . args : ""), true)
    }
}

; === PanelHide: временно скрыть или показать панель репортов (до перезапуска скрипта) ===
PanelHide:
    if (!reportPanelEnabled || scriptMode != "Admin") {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Панель репортов выключена в настройках скрипта.", 1800)
        Return
    }
    reportPanelHidden := !reportPanelHidden
    if (reportPanelHidden) {
        ReportPanelHide()
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Панель репортов скрыта. Показать: " . ReadableHotkey(hotkeys["PanelHide"]), 1800)
    } else {
        ReportPanelRefresh()
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Панель репортов показана.", 1200)
    }
Return

Watch:
    spTimersOff()
    Sleep, 50
    autoSpectate()
Return

; === AutoSpParse: репорт из строки чатлога (разбор тот же, что и раньше; дополнительно — текст жалобы и порядковый номер) ===
AutoSpParse(line) {
    global autoSpSeq
    at := -1
    if (RegExMatch(line, "^\[(\d{2}):(\d{2}):(\d{2})\]", t))
        at := t1 * 3600 + t2 * 60 + t3
    txt := ""
    if (RegExMatch(line, "\[(?:RADMIR|HASSLE)\] (?:\w+_\w+)?\[\d+\]:\s*(.*)$", tm))
        txt := Trim(RegExReplace(tm1, "\{[0-9A-Fa-f]{6}\}"))
    if (RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]:.*?\b(\d{1,3})\b", m)) {
        autoSpSeq++
        return {line: line, at: at, nick: m2, rep: m3, spec: m4, text: txt, seq: autoSpSeq, taken: false, answered: false, answeredBy: "", answeredMe: false}
    }
    if (RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]:", m)) {
        autoSpSeq++
        return {line: line, at: at, nick: m2, rep: m3, spec: m3, text: txt, seq: autoSpSeq, taken: false, answered: false, answeredBy: "", answeredMe: false}
    }
    return ""
}


; === AutoSpHintText: пояснение под кнопкой выбора жалобы ===
AutoSpHintText() {
    return "Случайная и самая старая — из " . autoSpPool . " последних жалоб, не старше " . AutoSpAgeText(autoSpMaxAge)
}


; === AutoSpAgeList / AutoSpAgeText / AutoSpAgeBtnText: варианты времени, которое скрипт помнит репорт (в секундах) ===
AutoSpAgeList() {
    return [30, 60, 120, 180, 300]
}

AutoSpAgeText(seconds) {
    return (seconds < 60) ? seconds . " сек" : (seconds // 60) . " мин"
}

; Текст кнопки в меню: у выбранного значения галочка.
AutoSpAgeBtnText(index) {
    global autoSpMaxAge
    ages := AutoSpAgeList()
    return (ages[index] = autoSpMaxAge ? "✔ " : "") . AutoSpAgeText(ages[index])
}


; === AutoSpNextPool: следующее значение окна жалоб (сколько последних жалоб помнит скрипт) ===
AutoSpNextPool(cur) {
    for _, v in [2, 3, 4, 5, 7, 10] {
        if (v > cur)
            return v
    }
    return 2
}


; === AutoSpModeName: название режима выбора репорта ===
AutoSpModeName(mode) {
    if (mode = 2)
        return "случайная"
    if (mode = 3)
        return "самая старая"
    return "последняя"
}


; === AutoSpAgeSec: возраст репорта в секундах (по метке времени строки; без метки — 0) ===
AutoSpAgeSec(e) {
    if (e.at < 0)
        return 0
    diff := A_Hour * 3600 + A_Min * 60 + A_Sec - e.at
    if (diff < -120)
        diff += 86400
    else if (diff < 0)
        diff := 0
    return diff
}


; === AutoSpIsFresh: репорт не старше autoSpMaxAge секунд (без метки времени — считается свежим) ===
AutoSpIsFresh(e) {
    global autoSpMaxAge
    return AutoSpAgeSec(e) <= autoSpMaxAge
}


; === AutoSpMarkAnswered: на репорты этого игрока, пришедшие до ответа админа, ответ уже дан (запоминаем, кто ответил) ===
AutoSpMarkAnswered(nick, id, admin := "", myName := "") {
    global autoSpReports
    mine := (admin != "" && myName != "" && admin = myName)
    for _, e in autoSpReports {
        if (e.answered)
            continue
        if ((e.nick != "" && e.nick = nick) || (e.nick = "" && e.rep = id)) {
            e.answered := true
            e.answeredBy := admin
            e.answeredMe := mine
        }
    }
}


; === AutoSpIngest: дочитывает новые строки чатлога: новые репорты и ответы администраторов ===
; Вызывается и при выборе репорта (Watch), и фоновым таймером панели репортов; состояние общее.
AutoSpIngest() {
    global autoSpSeeded, autoSpReports, userNickname
    wasCrit := A_IsCritical
    Critical, On
    if (!autoSpSeeded) {
        ChatlogReadNew("autosp_list", "all")
        autoSpSeeded := true
    }
    myName := Base64Decode(userNickname)
    for _, line in ChatlogReadNew("autosp_list") {
        if (InStr(line, "{FFCD00}")) {
            entry := AutoSpParse(line)
            if (IsObject(entry))
                autoSpReports.Push(entry)
        } else if (RegExMatch(line, "(?:Администратор|Агент поддержки) (\w+(?:_\w+)*)(?:\[\d+\])? для (\w+(?:_\w+)*)\[(\d+)\]:", ans)) {
            AutoSpMarkAnswered(ans2, ans3, ans1, myName)
        }
    }
    while (autoSpReports.Length() > 60)
        autoSpReports.RemoveAt(1)
    Critical, % wasCrit ? "On" : "Off"
}


; === AutoSpCandidates: кандидаты для режимов 2 и 3 (окно autoSpPool последних; свежие, без ответа, не взятые), от новых к старым ===
AutoSpCandidates() {
    global autoSpReports, autoSpPool
    cand := []
    count := autoSpReports.Length()
    Loop, % (count < autoSpPool ? count : autoSpPool)
    {
        entry := autoSpReports[count - A_Index + 1]
        if (!entry.taken && !entry.answered && AutoSpIsFresh(entry))
            cand.Push(entry)
    }
    return cand
}


; === AutoSpPickReport: выбор репорта по режиму autoSpMode (1 — последний, 2 — случайный, 3 — самый старый). В режимах 2 и 3 — только свежие (autoSpMaxAge) ===
; В режимах 2 и 3 пропускаются репорты, за которыми уже заходили, и те, на которые уже ответил любой администратор.
AutoSpPickReport() {
    AutoSpIngest()

    count := autoSpReports.Length()
    if (count = 0) {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ℹ️ ID не найдено.", 300)
        return ""
    }

    if (autoSpMode = 2 || autoSpMode = 3) {
        cand := AutoSpCandidates()
        if (cand.Length() = 0) {
            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ℹ️ Новых репортов нет (свежие, без ответа и не взятые, за " . AutoSpAgeText(autoSpMaxAge) . ").", 1500)
            return ""
        }
        if (autoSpMode = 3) {
            pick := cand[cand.Length()]
        } else {
            Random, r, 1, % cand.Length()
            pick := cand[r]
        }
    } else {
        pick := autoSpReports[count]
    }
    pick.taken := true
    return pick
}


; ====================================================================================================================
; ПАНЕЛЬ РЕПОРТОВ: плашка-меню в реальном времени (включается в настройках скрипта)
; ====================================================================================================================
; Показывает до 10 последних репортов: сверху те, что можно взять через Watch (окно autoSpPool), ниже история: в работе (вы наблюдаете) / ответил другой админ / ответили вы.
; ▶ — репорт, который возьмёт кнопка Watch в текущем режиме; ◇ — репорты, из которых режим выбирает случайно.
; Панель видна только когда активно окно игры, не перехватывает клики и стоит с противоположной от плашек-уведомлений стороны.

ReportPanelBtnText() {
    global reportPanelEnabled
    return "📋 Панель репортов: " . (reportPanelEnabled ? "✔ Включена" : "✘ Выключена")
}


; === ReportPanelApply: запускает или останавливает фоновое обновление панели по настройке ===
ReportPanelApply() {
    global reportPanelEnabled, scriptMode
    if (reportPanelEnabled && scriptMode = "Admin") {
        SetTimer, ReportPanelTick, 500
    } else {
        SetTimer, ReportPanelTick, Off
        ReportPanelHide()
    }
}


ReportPanelHide() {
    global reportPanelSig, reportPanelRows
    Gui, 41:Destroy
    Gui, 42:Destroy
    reportPanelSig := ""
    reportPanelRows := []
}


; === ReportPanelTick: разбор новых строк чатлога и обновление панели ===
ReportPanelTick() {
    global reportPanelEnabled, scriptMode
    if (!reportPanelEnabled || scriptMode != "Admin") {
        ReportPanelHide()
        return
    }
    AutoSpIngest()
    ReportPanelRefresh()
}


ReportPanelAgeText(age) {
    if (age < 60)
        return age . "с"
    sec := Mod(age, 60)
    return (age // 60) . "м " . (sec < 10 ? "0" : "") . sec . "с"
}


; === ReportPanelRows: до 10 последних репортов; сначала те, на которые можно ответить через Watch, затем история ===
; «Можно ответить» ставится только если Watch реально может взять репорт в текущем режиме:
;   режим 1 (последняя) — только самый новый репорт; режимы 2 и 3 — свежие, без ответа и не взятые из окна autoSpPool.
; Всё остальное (ответили, взяты, устарели, вне окна, недоступны Watch) — история.
ReportPanelRows() {
    global autoSpReports, autoSpMode, autoSpMaxAge, autoSpPool, spActiveSeq
    list := []
    actv := []
    rest := []
    count := autoSpReports.Length()
    if (count = 0)
        return list
    pickSeq := 0
    inPool := {}
    if (autoSpMode = 1) {
        pickSeq := autoSpReports[count].seq
    } else {
        cands := AutoSpCandidates()
        for _, c in cands
            inPool[c.seq] := true
        if (autoSpMode = 3 && cands.Length())
            pickSeq := cands[cands.Length()].seq
    }
    shown := (count < 10) ? count : 10
    Loop, %shown%
    {
        pos := A_Index
        e := autoSpReports[count - pos + 1]
        age := AutoSpAgeSec(e)
        if (e.answered && e.answeredMe) {
            key := "me"
            label := "✔ Обработан"
            color := "2ECC71"
        } else if (e.answered) {
            key := "other"
            label := "✎ " . (e.answeredBy != "" ? SubStr(e.answeredBy, 1, 20) : "админ")
            color := "FF9F43"
        } else if (e.seq = spActiveSeq && SpIsActive()) {
            key := "active"
            label := "♯ Обрабатывается"
            color := "4C8DFF"
        } else if (e.skip = "offline") {
            key := "gone"
            label := "✘ Игрок вышел"
            color := "7C8594"
        } else if (e.skip = "busy") {
            key := "busy"
            label := "✘ Следит другой"
            color := "7C8594"
        } else if (e.taken) {
            key := "skipped"
            label := "↷ Пропущен"
            color := "9AA3B2"
        } else if (autoSpMode = 1) {
            if (e.seq = pickSeq) {
                key := "free"
                label := "✉︎ Ожидает ответа"
                color := "2ECC71"
            } else {
                key := "manual"
                label := "✘ Вручную"
                color := "7C8594"
            }
        } else if (inPool.HasKey(e.seq)) {
            key := "free"
            label := "✉︎ Ожидает ответа"
            color := "2ECC71"
        } else if (pos <= autoSpPool) {
            key := "stale"
            label := "☣ Устарел"
            color := "7C8594"
        } else {
            key := "out"
            label := "✘ Вне окна"
            color := "7C8594"
        }
        mark := (e.seq = pickSeq) ? "▶" : (inPool.HasKey(e.seq) ? "◇" : "")
        title := (e.nick != "" ? e.nick : "ID") . "[" . e.rep . "]"
        snippet := RegExReplace(e.text, "\s+", " ")
        if (snippet = "")
            snippet := "(без текста)"
        if (StrLen(snippet) > 40)
            snippet := SubStr(snippet, 1, 40) . "…"
        snippet := RegExReplace(snippet, "&", "&&")
        row := {seq: e.seq, key: key, label: label, color: color, mark: mark, title: title, snippet: snippet, ageText: ReportPanelAgeText(age), hist: (key != "free" && key != "active")}
        if (key = "active")
            actv.Push(row)
        else if (key = "free")
            list.Push(row)
        else
            rest.Push(row)
    }
    ; Порядок: текущая слежка, затем то, что можно взять, затем история.
    out := []
    for _, r in actv
        out.Push(r)
    for _, r in list
        out.Push(r)
    for _, r in rest
        out.Push(r)
    return out
}


; === SpIsActive: идёт ли слежка по репорту (статус «обрабатывается» снимается через 10 минут без действий) ===
SpIsActive() {
    global spActiveSeq, spActiveUntil
    return (spActiveSeq != 0 && A_TickCount < spActiveUntil)
}


; === ReportPanelActions: что можно нажать прямо сейчас (клавиши из настроек; неназначенные не показываются) ===
ReportPanelActions() {
    global hotkeys, spStage, spTargetTitle, spSpecID, ntfHint
    acts := []
    reply := hotkeys["Reply"]
    if (reply != "" && IsObject(ntfHint)) {
        kind := ntfHint.kind
        if (kind = "Вопрос")
            hd := "Ответить на вопрос игроку с ID "
        else if (kind = "Оффлайн")
            hd := "Ответить: игрок вышел"
        else
            hd := "Выдать наказание"
        acts.Push({k: ReadableHotkey(reply) . " + Enter", d: hd . ntfHint.target, c: "FFCD00"})
    }
    if (SpIsActive()) {
        if (reply != "" && spStage = 1)
            acts.Push({k: ReadableHotkey(reply), d: "Приветствие — " . spTargetTitle, c: "2ECC71"})
        else if (reply != "" && spStage = 2)
            acts.Push({k: ReadableHotkey(reply) . " + 1…0", d: "Быстрый ответ — " . spTargetTitle, c: "2ECC71"})
        ik := hotkeys["Interact"]
        if (ik != "" && ik != reply)
            acts.Push({k: ReadableHotkey(ik) . " + 1…0", d: "Взаим. c " . spTargetTitle . "[" . spSpecID . "]", c: "4C8DFF"})
        hr := hotkeys["humanReply"]
        if (hr != "")
            acts.Push({k: ReadableHotkey(hr), d: "Ручной ответ — " . spTargetTitle . "[" . spSpecID . "]", c: "EDEFF2"})
    }
    wk := hotkeys["Watch"]
    if (wk != "")
        acts.Push({k: ReadableHotkey(wk), d: "Зайти в слежку", c: "EDEFF2"})
    ph := hotkeys["PanelHide"]
    if (ph != "")
        acts.Push({k: ReadableHotkey(ph), d: "Скрыть панель", c: "8E97A6"})
    for _, a in acts {
        if (StrLen(a.d) > 34)
            a.d := SubStr(a.d, 1, 33) . "…"
    }
    return acts
}


; === ReportPanelRefresh: показывает панель, пересобирает при изменении состава/статусов, иначе обновляет только возраст ===
ReportPanelRefresh() {
    global reportPanelNum, reportPanelSig, reportPanelRows, reportPanelAgeHwnds, autoSpMode, autoSpPool, autoSpMaxAge, ntfCorner, reportPanelHidden
    if (reportPanelHidden) {
        if (reportPanelSig != "")
            ReportPanelHide()
        return
    }
    if (!WinActive("ahk_exe gta_sa.exe")) {
        if (reportPanelSig != "")
            ReportPanelHide()
        return
    }
    rows := ReportPanelRows()
    sig := autoSpMode . "|" . autoSpPool . "|" . autoSpMaxAge . "|" . ntfCorner . "|"
    for _, r in rows
        sig .= r.seq . r.key . r.mark . r.label . ";"
    acts := ReportPanelActions()
    for _, a in acts
        sig .= "|" . a.k . a.d
    if (sig = reportPanelSig) {
        for i, r in rows {
            if (r.ageText != reportPanelRows[i].ageText)
                DllCall("SetWindowText", "Ptr", reportPanelAgeHwnds[i], "Str", r.ageText)
        }
        reportPanelRows := rows
        return
    }
    ReportPanelBuild(rows, sig, acts)
}


; === ReportPanelBuild: строит новую плашку в соседнем окне (41/42) и только потом убирает старую — без мерцания ===
; Вид: заголовок и режим, окно выборки, цветные счётчики. Блок «МОЖНО ОТВЕТИТЬ» — карточки в две строки (ник и статус,
; текст жалобы и возраст) с цветной полоской. Блок «ИСТОРИЯ» — компактные приглушённые строки (ник, кто ответил, возраст).
ReportPanelBuild(rows, sig, acts) {
    global reportPanelNum, reportPanelSig, reportPanelRows, reportPanelAgeHwnds, autoSpMode, autoSpPool, autoSpMaxAge, ntfCorner
    DetectHiddenWindows, On
    oldNum := reportPanelNum
    num := (oldNum = 41) ? 42 : 41
    w := 380
    cw := w - 32
    freeN := 0
    takenN := 0
    otherN := 0
    histN := 0
    topN := 0
    for _, r in rows {
        if (r.key = "free")
            freeN++
        else if (r.key = "active")
            takenN++
        else if (r.key = "other")
            otherN++
        if (r.hist)
            histN++
        else
            topN++
    }
    modeTxt := "Режим: " . AutoSpModeName(autoSpMode)
    memTxt := "Область видимости: " . autoSpPool . " rep  ·  Область досягаемости: " . AutoSpAgeText(autoSpMaxAge)
    freeTxt := "● Доступно: " . freeN
    takenTxt := "● В работе: " . takenN
    otherTxt := "● Не отвечено: " . otherN

    Gui, %num%:Destroy
    Gui, %num%:New, +AlwaysOnTop -Caption +ToolWindow +E0x08000020 +HwndhRP
    Gui, %num%:Margin, 0, 0
    Gui, %num%:Color, 15181E
    Gui, %num%:Font, s11 Bold cEDEFF2, Segoe UI
    Gui, %num%:Add, Text, x16 y10 w150, Репорты
    Gui, %num%:Font, s8 Bold c4C8DFF, Segoe UI
    Gui, %num%:Add, Text, x166 yp+5 w198 Right, %modeTxt%
    Gui, %num%:Font, s8 Norm c8E97A6, Segoe UI
    Gui, %num%:Add, Text, x16 y+5 w%cw%, %memTxt%
    Gui, %num%:Font, s8 Bold c2ECC71, Segoe UI
    Gui, %num%:Add, Text, x16 y+8 w100, %freeTxt%
    Gui, %num%:Font, s8 Bold c4C8DFF, Segoe UI
    Gui, %num%:Add, Text, x+0 yp w100, %takenTxt%
    Gui, %num%:Font, s8 Bold cFF9F43, Segoe UI
    Gui, %num%:Add, Text, x+0 yp w148, %otherTxt%
    Gui, %num%:Add, Progress, x16 y+8 w%cw% h1 -Theme Background2A2F38 c2A2F38, 100

    ages := []
    rowTop := []
    rowBot := []
    if (rows.Length() = 0) {
        Gui, %num%:Font, s9 Norm cEDEFF2, Segoe UI
        Gui, %num%:Add, Text, x16 y+14 w%cw% Center, Репортов пока нет
        Gui, %num%:Font, s8 Norm c8E97A6, Segoe UI
        Gui, %num%:Add, Text, x16 y+2 w%cw% Center, Новые появятся здесь автоматически
    } else {
        ; --- Блок «МОЖНО ОТВЕТИТЬ» ---
        Gui, %num%:Font, s7 Bold c2ECC71, Segoe UI
        Gui, %num%:Add, Text, x16 y+10 w%cw%, МОЖНО ОТВЕТИТЬ
        if (topN = 0) {
            Gui, %num%:Font, s8 Norm c8E97A6, Segoe UI
            Gui, %num%:Add, Text, x24 y+6 w340, Сейчас нет репортов, на которые можно ответить
        }
        for i, r in rows {
            if (r.hist)
                continue
            col := r.color
            markCol := (r.mark = "▶") ? "FFCD00" : "8E97A6"
            markTxt := r.mark
            titleTxt := r.title
            statusTxt := r.label
            snipTxt := r.snippet
            ageTxt := r.ageText
            Gui, %num%:Font, s9 Bold c%markCol%, Segoe UI
            Gui, %num%:Add, Text, x24 y+8 w14 +HwndhTop, %markTxt%
            Gui, %num%:Font, s9 Bold cFFFFFF, Segoe UI
            Gui, %num%:Add, Text, x40 yp w156, %titleTxt%
            Gui, %num%:Font, s8 Bold c%col%, Segoe UI
            Gui, %num%:Add, Text, x198 yp+1 w166 Right, %statusTxt%
            Gui, %num%:Font, s8 Norm cB4BBC8, Segoe UI
            Gui, %num%:Add, Text, x40 y+4 w250 +HwndhBot, %snipTxt%
            Gui, %num%:Font, s8 Norm c8E97A6, Segoe UI
            Gui, %num%:Add, Text, x294 yp w70 Right +HwndhAge, %ageTxt%
            ages[i] := hAge
            rowTop[i] := hTop
            rowBot[i] := hBot
        }
        ; --- Блок «ИСТОРИЯ» ---
        if (histN > 0) {
            Gui, %num%:Font, s7 Bold c6B7483, Segoe UI
            Gui, %num%:Add, Text, x16 y+14 w%cw%, ИСТОРИЯ
            for i, r in rows {
                if (!r.hist)
                    continue
                col := r.color
                titleTxt := r.title
                statusTxt := r.label
                ageTxt := r.ageText
                Gui, %num%:Font, s9 Norm c9AA3B2, Segoe UI
                Gui, %num%:Add, Text, x24 y+6 w150 +HwndhTop, %titleTxt%
                Gui, %num%:Font, s8 Bold c%col%, Segoe UI
                Gui, %num%:Add, Text, x176 yp+1 w132 Right, %statusTxt%
                Gui, %num%:Font, s8 Norm c6B7483, Segoe UI
                Gui, %num%:Add, Text, x312 yp w52 Right +HwndhAge, %ageTxt%
                ages[i] := hAge
                rowTop[i] := hTop
                rowBot[i] := hTop
            }
        }
    }
    ; --- Блок «ДЕЙСТВИЯ»: какие клавиши работают прямо сейчас ---
    if (acts.Length() > 0) {
        Gui, %num%:Add, Progress, x16 y+12 w%cw% h1 -Theme Background2A2F38 c2A2F38, 100
        Gui, %num%:Font, s7 Bold c6B7483, Segoe UI
        Gui, %num%:Add, Text, x16 y+6 w%cw%, ДЕЙСТВИЯ
        for _, a in acts {
            keyTxt := RegExReplace(a.k, "&", "&&")
            descTxt := RegExReplace(a.d, "&", "&&")
            keyCol := a.c
            Gui, %num%:Font, s8 Bold c%keyCol%, Segoe UI
            Gui, %num%:Add, Text, x16 y+4 w126, %keyTxt%
            Gui, %num%:Font, s8 Norm cB4BBC8, Segoe UI
            Gui, %num%:Add, Text, x144 yp w220, %descTxt%
        }
    }
    Gui, %num%:Add, Text, x0 y+12 w1 h1
    Gui, %num%:Show, NA AutoSize Hide
    WinGetPos,,, gw, gh, ahk_id %hRP%
    if (gh < 60)
        gh := 60

    ; Цветные полоски статуса слева от каждой строки (по границам её текста).
    for i, r in rows {
        hT := rowTop[i]
        hB := rowBot[i]
        if (!hT || !hB)
            continue
        ControlGetPos,, ty,, th, , ahk_id %hT%
        ControlGetPos,, by,, bh, , ahk_id %hB%
        sh := (by + bh) - ty
        if (sh < 8)
            continue
        col := r.color
        Gui, %num%:Add, Progress, x16 y%ty% w3 h%sh% -Theme Background%col% c%col%, 100
    }

    NtfAnchor(ax, ay, aw, ah)
    ; Уведомления слева (углы 1, 3, 4) — панель справа по центру; уведомления справа (2, 5) — панель слева по центру.
    toRight := (ntfCorner = 1 || ntfCorner = 3 || ntfCorner = 4)
    x := toRight ? ax + aw - w - 16 : ax + 16
    y := ay + (ah - gh) // 2
    if (y < ay + 8)
        y := ay + 8
    Gui, %num%:Show, NA x%x% y%y% w%w% h%gh%
    WinSet, Region, 0-0 W%w% H%gh% R12-12, ahk_id %hRP%
    WinSet, Transparent, 238, ahk_id %hRP%
    Gui, %oldNum%:Destroy

    reportPanelNum := num
    reportPanelSig := sig
    reportPanelRows := rows
    reportPanelAgeHwnds := ages
}


; === OfflinePrompt: игрок из репорта не найден — подсказка с ответом репортёру по Reply + Enter (как в логе жалоб) ===
OfflinePrompt(rep) {
    spTimersOff()
    IniRead, ans, %settingsFile%, Answers, ansOffline, %A_Space%
    ans := Trim(ans)
    key := hotkeys["Reply"]
    author := (rep.nick != "") ? rep.nick : "Игрок"
    if (ans = "" || key = "") {
        HintClose(false)
        head := "[𝐎𝐅𝐅𝐋𝐈𝐍𝐄] " . author . "[" . rep.rep . "]: игрок с ID " . rep.spec . " не найден (вышел)"
        ToolTip(head . (ans = "" ? "`n↪︎ Ответ «Offline» не задан в настройках ответов." : "`n↪︎ Клавиша Reply не назначена."), 5000)
        return
    }
    HintShowNow({kind: "Оффлайн", author: author, id: rep.rep, text: "Игрок с ID " . rep.spec . " не найден в сети.", key: key, reply: ans, note: ""})
}


; === OfflineReplyWatch: ждёт Reply + Enter (до 7.8 с) и отправляет репортёру ответ «игрок вышел» ===
OfflineReplyWatch() {
    if (A_TickCount > offlineUntil) {
        SetTimer, OfflineReplyWatch, Off
        return
    }
    key := hotkeys["Reply"]
    if (key = "" || !GetKeyState(key, "P") || !GetKeyState("Enter", "P"))
        return
    target := offlineTarget
    text := offlineText
    HintClose(false)
    Sleep, 100
    SendMessage, 0x50,, 0x4190419,, A
    sendReply(target, text)
    ToolTip("[𝐑𝐄𝐏𝐋𝐘] Игроку был дан ответ.", 3300)
    HintPump()
}


autoSpectate() {
    ; Без global присваивание создавало бы локальные копии, и таймеры ответа/взаимодействия не видели бы нужный ID.
    global repID, spReplyTarget, interactID, requestCanRecall
    global spActiveSeq, spActiveUntil, spStage, spTargetTitle, spSpecID
    if (IsObject(ntfHint) && ntfHint.kind = "Оффлайн")
        HintClose()
    rep := AutoSpPickReport()
    if (!IsObject(rep))
        return
    repID := rep.rep
    specID := rep.spec
    info := RegExReplace(rep.line, "^.*?\[(RADMIR|HASSLE)\] ", "")
    info := RegExReplace(info, "\{[0-9A-Fa-f]{6}\}", "")
    if (StrLen(info) > 70)
        info := SubStr(info, 1, 70) . "…"
    ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Жалоба (" . AutoSpModeName(autoSpMode) . "): " . info . "`n↪︎ /sp " . specID, 3000)

    ChatlogWatchFromNow("autosp")
    if (isHumanInput) {
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

    for _, line in ChatlogReadNew("autosp") {
        if InStr(line, "Такого игрока нет") {
            foundAdmin := true
            rep.skip := "offline"
            OfflinePrompt(rep)
            break
        } if RegExMatch(line, "\* За этим игроком уже следит администратор (\w+_\w+)\[\d+\]", match) {
            foundAdmin := (match1 != Base64Decode(userNickname))
            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] За игроком с ID " . specID . " уже следит другой администратор...", 300)
            break
        } if RegExMatch(line, "\* За этим игроком уже следит администратор (\w+_\w+)", match) {
            foundAdmin := (match1 != Base64Decode(userNickname))
            break
        }
    }
    if (foundAdmin && rep.skip = "")
        rep.skip := "busy"
    if (!foundAdmin) {
        ; Слежка началась: адресат ответа и статус «обрабатывается» переходят на этот репорт, предыдущий становится «пропущенным».
        spReplyTarget := rep.rep
        spActiveSeq := rep.seq
        spActiveUntil := A_TickCount + 600000
        spStage := 1
        spTargetTitle := (rep.nick != "" ? rep.nick : "ID") . "[" . rep.rep . "]"
        spSpecID := specID
        rep.skip := ""
        SetTimer, WatchKeys, 30
        interactID := specID
        SetTimer, WatchInteract, 30
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

; === Request: следующий /z без повторного набора всей команды ===
Request:
    if (requestBusy || ChatIsOpen || !WinActive("ahk_exe gta_sa.exe"))
        Return

    requestBusy := true

    ; Shift + клавиша — ввести ID запроса заново.
    if (!InStr(A_ThisHotkey, "+") && GetKeyState("Shift", "P")) {
        lastRequest := ""
        requestLastSent := ""
        requestCanRecall := false
    }

    ; Первый запуск: ID вводится прямо в чате игры (строка выглядит как обычная команда /z).
    if (lastRequest == "") {
        requestCanRecall := false
        requestLastSent := ""
        SendMessage, 0x50,, 0x4190419,, A
        SendInput, {F6}/z (ид запроса вводится){Space}
        idRead := RequestReadId()
        ; Очистка ввода в чате без лишнего Esc (не открыть pause menu). Только при активной игре:
        ; иначе Ctrl+A и Backspace стёрли бы текст в другом приложении.
        if (WinActive("ahk_exe gta_sa.exe"))
            SendInput, ^a{Backspace}
        if (idRead.status != "enter" || !RegExMatch(idRead.id, "^[1-9][0-9]{0,11}$")) {
            lastRequest := ""
            requestBusy := false
            if (idRead.status = "away")
                ToolTip("[REQUEST] Ввод ID прерван: окно игры не в фокусе.", 2500)
            else if (idRead.status = "esc")
                ToolTip("[REQUEST] Ввод ID отменён.", 2000)
            else if (idRead.status = "timeout")
                ToolTip("[REQUEST] Время ожидания ID истекло.", 2500)
            else
                ToolTip("[REQUEST] ID не записан (получено: «" . idRead.id . "»). Нужно число и Enter.", 3000)
            Return
        }
        lastRequest := idRead.id
        ChatIsOpen := false
        requestBusy := false
        ToolTip("[REQUEST] ID запроса записан: №" . lastRequest . ". Следующее нажатие отправит /z " . lastRequest . ". Shift + клавиша — ввести заново.", 4000)
        Return
    }

    nextRequest := "" . lastRequest
    ; Отправлять только положительные числа (проверка состояния счётчика).
    if (!RegExMatch(nextRequest, "^[1-9][0-9]{0,11}$")) {
        ToolTip("[REQUEST] Некорректный ID. Перезапустите скрипт для сброса.", 2500)
        requestBusy := false
        Return
    }

    ; Курсор чатлога — на конец файла: ответ сервера ищется только среди строк, появившихся после отправки.
    ChatlogWatchFromNow("request")

    if (isHumanInput) {
        if (requestLastSent != "") {
            change := RequestChangeDigits(requestLastSent, nextRequest)
            SendInput, {F6}
            Sleep, 90
            if (!WinActive("ahk_exe gta_sa.exe")) {
                ToolTip("[REQUEST] Окно игры потеряло фокус, запрос прерван.", 2500)
                requestBusy := false
                Return
            }
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
        ; Enter — только если игра всё ещё в фокусе (иначе он ушёл бы в другое приложение, а счётчик сдвинулся бы зря).
        if (!WinActive("ahk_exe gta_sa.exe")) {
            ToolTip("[REQUEST] Окно игры потеряло фокус, запрос не отправлен.", 2500)
            requestBusy := false
            Return
        }
        SendInput, {Enter}
    } else {
        ; Автоматический режим не меняем.
        SendInput, {F6}/z %nextRequest%{Enter}
    }

    requestLastSent := nextRequest
    requestCanRecall := true
    ; Если такого обращения не существует, счётчик не двигаем: следующее нажатие отправит тот же ID.
    if (RequestRejected())
        ToolTip("[REQUEST] Обращение №" . nextRequest . " не существует.", 2500)
    else
        lastRequest := nextRequest + 1
    ChatIsOpen := false
    requestBusy := false
Return

; === RequestRejected: после отправки /z ждёт до 0.7 с ответ сервера «Указанное Вами обращение не существует» ===
; Возврат: true — сообщение появилось в чате (обращение не существует), false — не появилось.
RequestRejected() {
    end := A_TickCount + 700
    while (A_TickCount < end) {
        for _, line in ChatlogReadNew("request") {
            clean := RegExReplace(line, "\{[0-9A-Fa-f]{6,8}\}", "")
            if (InStr(clean, "Указанное Вами обращение не существует"))
                return true
        }
        Sleep, 30
    }
    return false
}

; === RequestReadId: читает ID, который администратор набирает в чате (Enter — готово, Esc — отмена, 40 с на ввод) ===
; Работает опросом физических клавиш, а не командой Input: так на ввод не влияют хоткеи Enter/Esc этого скрипта.
; Если окно игры потеряло фокус (переключились в другое приложение) — ввод прерывается, а не ждёт все 40 с и не читает клавиши чужого окна.
; Возврат: {id: набранные цифры, status: "enter" | "esc" | "timeout" | "away"}.
RequestReadId() {
    prev := {}
    for _, n in StrSplit("1,2,3,4,5,6,7,8,9,0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,Numpad0,Backspace,Enter,NumpadEnter,Escape", ",") {
        k := "" . n
        prev[k] := GetKeyState(k, "P") ? 1 : 0
    }
    digits := ""
    end := A_TickCount + 40000
    Loop {
        if (A_TickCount > end)
            return {id: digits, status: "timeout"}
        if (!WinActive("ahk_exe gta_sa.exe"))
            return {id: digits, status: "away"}
        modifier := (GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P"))
        for name, was in prev {
            k := "" . name
            now := GetKeyState(k, "P") ? 1 : 0
            if (now && !was) {
                if (k = "Enter" || k = "NumpadEnter")
                    return {id: digits, status: "enter"}
                if (k = "Escape")
                    return {id: digits, status: "esc"}
                if (k = "Backspace")
                    digits := SubStr(digits, 1, StrLen(digits) - 1)
                else if (!modifier && StrLen(digits) < 12)
                    digits .= SubStr(k, 0)
            }
            prev[name] := now
        }
        Sleep, 10
    }
}


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
        if (!WinActive("ahk_exe gta_sa.exe"))
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
        ; Скопированную команду пользователь отправит сам: после неё повтор /z через ↑ запрещён.
        requestCanRecall := false
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


; ====================================================================================================================
; АДМИН: РЕПОРТЫ, ПРАВИЛА ОТВЕТОВ И НАКАЗАНИЯ
; ====================================================================================================================

; === answerLogger: обработка новых репортов ===
; === AnswerPrepare: текст репорта -> слова для сопоставления с правилами ===
; Нижний регистр, ё -> е, цвета и знаки убираются. Ники вида Name_Surname (с «_») не считаются текстом.
AnswerPrepare(text) {
    t := text
    StringLower, t, t
    t := StrReplace(t, "ё", "е")
    t := RegExReplace(t, "\{[0-9a-f]{6}\}", " ")
    t := RegExReplace(t, "[^a-z0-9а-я_/]+", " ")
    tokens := []
    flat := " "
    Loop, Parse, t, %A_Space%
    {
        w := A_LoopField
        if (w = "")
            continue
        if (InStr(w, "_") && SubStr(w, 1, 1) != "/")
            continue
        tokens.Push(w)
        flat .= w . " "
    }
    return {tokens: tokens, flat: flat}
}


; === AnswerMatch: насколько ключ подходит тексту (0 — не подходит; больше — точнее) ===
; Ключ — слова через пробел, все должны встретиться. Слово ключа — начало слова в тексте («акс» не найдёт «Максим»).
; Слово с * в начале («*чин») ищется внутри слова. Счёт: число слов ключа и их длина — точные правила побеждают общие.
; Слово с ! в начале («!родн», «!*родн») — исключение: если оно есть в тексте, ключ не подходит. В счёт исключения не входят.
AnswerMatch(key, prep) {
    score := 0
    Loop, Parse, key, %A_Space%
    {
        part := A_LoopField
        if (part = "")
            continue
        StringLower, part, part
        part := StrReplace(part, "ё", "е")
        negate := (SubStr(part, 1, 1) = "!")
        if (negate)
            part := SubStr(part, 2)
        loose := (SubStr(part, 1, 1) = "*")
        if (loose)
            part := SubStr(part, 2)
        if (part = "")
            continue
        found := false
        if (loose) {
            found := InStr(prep.flat, part) ? true : false
        } else {
            len := StrLen(part)
            for _, tok in prep.tokens {
                if (SubStr(tok, 1, len) = part) {
                    found := true
                    break
                }
            }
        }
        if (negate) {
            if (found)
                return 0
            continue
        }
        if (!found)
            return 0
        score += 100 + StrLen(part)
    }
    return score
}


answerLogger() {
    global settingsFile, answerMap, answerRulesLoaded, answerRulesFile, answerRulesMTime, reportLog
    global answerComplaint, answerCommand
    global adminName, targetID, targetPunish
    global answerSeen, answerSeenOrder
    global punishWordsLoaded, punishWordsFile, punishWordsMTime
    if (!reportLog)
        return
    if (!answerRulesLoaded)
        LoadAnswerRules()
    if (!punishWordsLoaded)
        LoadPunishWords()
    targetPunish := ""
    for _, line in ChatlogReadNew("reports") {
        if RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]: (.+)", match) {
            Reports := match4
            ; Автор и ID репорта — только локально: общие playerId/ansLogID перезаписывались каждым новым репортом,
            ; и Reply + Enter отвечал не на тот репорт, который показан в подсказке. Адресат хранится в самой подсказке (ntfHint).
            repId := match3
            repAuthor := match2
            Reports := RegExReplace(Reports, "\{[A-F0-9]{6}\}")
            ; Обработанные строки хранятся в памяти (раньше — в ini, где список только разрастался).
            hash := HashLine(line)
            if (answerSeen.HasKey(hash))
                continue
            answerSeen[hash] := true
            answerSeenOrder.Push(hash)
            if (answerSeenOrder.Length() > 400) {
                oldHash := answerSeenOrder[1]
                answerSeenOrder.RemoveAt(1)
                answerSeen.Delete(oldHash)
            }

            ; Файл правил можно править на лету: изменился — перечитываем.
            FileGetTime, rulesTime, %answerRulesFile%, M
            if (rulesTime != answerRulesMTime)
                LoadAnswerRules()
            FileGetTime, wordsTime, %punishWordsFile%, M
            if (wordsTime != punishWordsMTime)
                LoadPunishWords()

            IniRead, kR, %settingsFile%, Keys, Reply
            prep := AnswerPrepare(match4)

            bestKey := "", bestReply := "", bestScore := 0
            for key, reply in answerMap {
                score := AnswerMatch(key, prep)
                if (score > bestScore) {
                    bestScore := score
                    bestKey := key
                    bestReply := reply
                }
            }
            if (bestScore > 0 && IsGTAOpen())
                ShowTip(repAuthor, repId, Reports, kR, "Вопрос", bestReply, bestKey)

            ; МАТ и ОСК: слова и наказания берутся из punish-words.txt (ОСК проверяется раньше МАТ).
            hit := PunishWordsMatch(prep)
            if (IsObject(hit) && IsGTAOpen())
                ShowTip(repAuthor, repId, Reports, kR, hit.kind, hit.punish)
        }
    }
}

respondComplaint() {
    global hotkeys
    if (hotkeys["Reply"] = "")
        return
    if (!IsObject(ntfHint) || ntfHint.kind != "Вопрос") {
        SetTimer, respondComplaint, Off
        return
    }
    if (GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P")) {
        target := ntfHint.target
        text := ntfHint.replyText
        HintClose(false)
        Sleep, 100
        SendMessage, 0x50,, 0x4190419,, A
        sendReply(target, text)
        ToolTip("[𝐑𝐄𝐏𝐋𝐘] Игроку был дан ответ.", 3300)
        HintPump()
    }
}

respondCommand() {
    global hotkeys, isHumanInput, requestCanRecall
    global CMDDelay, InputDelay1, InputDelay2
    if (hotkeys["Reply"] = "")
        return
    if (!IsObject(ntfHint) || (ntfHint.kind != "МАТ" && ntfHint.kind != "ОСК")) {
        SetTimer, respondCommand, Off
        return
    }
    if (GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P")) {
        target := ntfHint.target
        parts := PunishSplitCommand(ntfHint.replyText)
        cmdName := parts.cmd
        cmdArgs := SendEsc(parts.args)
        HintClose(false)
        Sleep, 100
        SendMessage, 0x50,, 0x4190419,, A
        ; Наказание уходит в историю чата: автозапрос не должен вызывать его стрелкой ↑ вместо своего /z.
        requestCanRecall := false
        if (isHumanInput) {
            l := StrLen(parts.args) + 1
            SendInput, {F6}%cmdName%  %cmdArgs%{left %l%}
            Sleep, %CMDDelay%
            Loop, Parse, target
            {
                SendInput, %A_LoopField%
                Random, rDelay1, %InputDelay1%, %InputDelay2%
                Sleep, rDelay1
            }
            SendInput, {Enter down}
            Sleep, 50
            SendInput, {Enter up}
        } else {
            SendInput, {F6}%cmdName% %target% %cmdArgs%{Enter}
        }
        ToolTip("[𝐏𝐔𝐍𝐈𝐒𝐇𝐌𝐄𝐍𝐓] Игрок был наказан.", 3300)
        HintPump()
    }
}

; === DefaultAnswerRulesText: встроенные правила ответа для первого запуска (93 ключа в 76 записях) ===
DefaultAnswerRulesText() {
    rules := ""
    rules .= "# ViMeLlY Script: ключ = ответ`r`n"
    rules .= "# UTF-8, одна запись на строку. Не удаляйте сам файл.`r`n"
    rules .= "# Не используйте знак = в ключе.`r`n"
    rules .= "# Слово ключа — начало слова в репорте (акс найдёт «аксессуары», но не «Максим»). *слово — искать внутри слова.`r`n"
    rules .= "# Ключ из нескольких слов: все слова должны встретиться. Побеждает самое точное правило. Файл можно править на лету.`r`n"
    rules .= "# Один ответ на несколько ключей: ключ1 | ключ2 | ключ3 = ответ. Общая часть: акс {дом|биз} = ответ (это акс дом и акс биз).`r`n"
    rules .= "# Исключения: !слово — правило не сработает, если это слово есть в репорте. Пример: {мат|оск} !родн = ответ (на «оск родни» не реагирует).`r`n"
    rules .= "# Исключение относится к своему варианту: в «мат | оск !родн» оно действует только на «оск». Чтобы на все — группа: {мат|оск} !родн.`r`n"
    rules .= ""
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

; === AnswerExpandKey: запись ключа -> список обычных ключей ===
; «а | б | в» — отдельные ключи с общим ответом. «x {а|б} y» — группа: «x а y» и «x б y». Можно сочетать: «акс {дом|биз} | аксессуары дом».
; Ключ без | и {} возвращается как есть, поэтому прежние файлы правил работают без изменений. Предел — 256 вариантов на запись.
AnswerExpandKey(key) {
    pending := [key]
    done := []
    while (pending.Length() > 0) {
        cur := pending.Pop()
        openPos := InStr(cur, "{")
        closePos := openPos ? InStr(cur, "}", false, openPos + 1) : 0
        if (!openPos || !closePos) {
            done.Push(cur)
            continue
        }
        head := SubStr(cur, 1, openPos - 1)
        tail := SubStr(cur, closePos + 1)
        group := SubStr(cur, openPos + 1, closePos - openPos - 1)
        Loop, Parse, group, |
            pending.Push(head . A_LoopField . tail)
        if (pending.Length() + done.Length() > 256)
            break
    }
    result := []
    for _, item in done {
        Loop, Parse, item, |
        {
            alt := Trim(RegExReplace(A_LoopField, "\s+", " "))
            if (alt != "")
                result.Push(alt)
        }
    }
    return result
}

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
        if (key = "" || value = "")
            continue
        ; Одна запись может задавать несколько ключей («а | б», «акс {дом|биз}») с одним ответом.
        for _, alt in AnswerExpandKey(key)
            updated[alt] := value
    }
    ; Совместимость: «чин»/«чен» раньше находили «починить» внутри слова, теперь ключ — начало слова.
    if (updated.HasKey("чин") && !updated.HasKey("почин"))
        updated["почин"] := updated["чин"]
    if (updated.HasKey("чен") && !updated.HasKey("почен"))
        updated["почен"] := updated["чен"]
    FileGetTime, answerRulesMTime, %answerRulesFile%, M
    ; Атомарно заменить таблицу, чтобы частичная запись не пропала при ошибке чтения.
    answerMap := updated
    answerRulesLoaded := true
    return true
}

; === DefaultPunishWordsText: слова МАТ/ОСК и наказания для первого запуска ===
DefaultPunishWordsText() {
    t := ""
    t .= "# ViMeLlY Script: слова, по которым в репортах появляется подсказка МАТ или ОСК, и наказания к ним.`r`n"
    t .= "# UTF-8. Файл можно править на лету: скрипт перечитает его сам. Не удаляйте сам файл.`r`n"
    t .= "#`r`n"
    t .= "# Раздел: [ОСК] или [МАТ], после него — наказание по умолчанию для всех строк раздела (время и причина для /rmute).`r`n"
    t .= "# Разделов может быть несколько, например второй [ОСК] с другим наказанием для особых слов.`r`n"
    t .= "# Если наказание начинается с команды (/jail 120 Причина), оно выдаётся этой командой вместо /rmute.`r`n"
    t .= "#`r`n"
    t .= "# Строка: слова [= особое наказание только для этой строки].`r`n"
    t .= "#   слово — начало слова в репорте; *слово — искать внутри слова (так заданы корни мата);`r`n"
    t .= "#   !слово — исключение: строка не сработает, если это слово есть в репорте;`r`n"
    t .= "#   несколько слов через пробел — должны встретиться все; | — варианты; {а|б} — общая часть.`r`n"
    t .= "#   Пример с исключениями и своим наказанием: оск !родн !мам = 240 Оскорбление`r`n"
    t .= "#`r`n"
    t .= "# ОСК проверяется раньше МАТ. Из нескольких подошедших строк берётся самая точная`r`n"
    t .= "# (больше слов, длиннее слова), при равенстве — та, что выше в файле.`r`n"
    t .= "`r`n"
    t .= "[ОСК] 360 Оскорбление администрации.`r`n"
    t .= "даун | пидор | пидар | шлюх | *ебла | *ебал | кончен | рот *ебал | *ебан | нищи | пош нах | лох | дебил | дура`r`n"
    t .= "`r`n"
    t .= "[МАТ] 120 Мат в /report.`r`n"
    t .= "*блят | *сук | *ебат | *ебал | *ебла | *хуй | *пизд | *пидо | *бляд | *долб | *заеб | *неху | *схуя | *наеб | *ахуе | *охуе | *поху | *хуе`r`n"
    return t
}


; === EnsurePunishWordsFile: создаёт punish-words.txt со встроенным списком, если файла нет (существующий не трогает) ===
EnsurePunishWordsFile() {
    global scriptDir, punishWordsFile
    if (FileExist(punishWordsFile))
        return true
    if (!FileExist(scriptDir)) {
        FileCreateDir, %scriptDir%
        if (ErrorLevel)
            return false
    }
    text := DefaultPunishWordsText()
    tempPath := punishWordsFile . ".tmp." . A_TickCount
    FileDelete, %tempPath%
    FileAppend, %text%, %tempPath%, UTF-8
    if (ErrorLevel) {
        FileDelete, %tempPath%
        return false
    }
    FileMove, %tempPath%, %punishWordsFile%, 0
    if (ErrorLevel)
        FileDelete, %tempPath%
    return FileExist(punishWordsFile) ? true : false
}


; === ParsePunishWords: текст файла -> список записей {kind: МАТ|ОСК, key, punish} ===
; Строки до первого раздела игнорируются. Неизвестный заголовок [...] отключает строки до следующего корректного раздела.
; Наказание строки = то, что после «=»; без него — наказание раздела; без него — встроенное для типа.
ParsePunishWords(content) {
    list := []
    section := ""
    sectionPunish := ""
    Loop, Parse, content, `n, `r
    {
        line := LTrim(Trim(A_LoopField, " `t"), Chr(0xFEFF))
        if (line = "" || SubStr(line, 1, 1) = "#" || SubStr(line, 1, 1) = ";")
            continue
        if (RegExMatch(line, "^\[([^\]]+)\]\s*(.*)$", h)) {
            head := Trim(h1)
            StringUpper, head, head
            section := (head = "МАТ" || head = "ОСК") ? head : ""
            sectionPunish := Trim(h2)
            continue
        }
        if (section = "")
            continue
        separator := InStr(line, "=")
        keys := separator ? Trim(SubStr(line, 1, separator - 1)) : line
        punish := separator ? Trim(SubStr(line, separator + 1)) : ""
        if (punish = "")
            punish := sectionPunish
        if (punish = "")
            punish := (section = "МАТ") ? "120 Мат в /report." : "360 Оскорбление администрации."
        if (keys = "")
            continue
        for _, alt in AnswerExpandKey(keys)
            list.Push({kind: section, key: alt, punish: punish})
    }
    return list
}


; === LoadPunishWords: читает punish-words.txt (при отсутствии создаёт). Если файл создать нельзя — работает встроенный список ===
LoadPunishWords() {
    global punishWordsList, punishWordsFile, punishWordsLoaded, punishWordsMTime
    if (!EnsurePunishWordsFile()) {
        punishWordsList := ParsePunishWords(DefaultPunishWordsText())
        punishWordsLoaded := true
        return false
    }
    FileRead, content, *P65001 %punishWordsFile%
    if (ErrorLevel)
        return false
    punishWordsList := ParsePunishWords(content)
    FileGetTime, punishWordsMTime, %punishWordsFile%, M
    punishWordsLoaded := true
    return true
}


; === PunishWordsMatch: подбор наказания по тексту репорта ===
; ОСК проверяется раньше МАТ; внутри типа побеждает самая точная строка (AnswerMatch), при равенстве — первая в файле.
; Возврат: {kind: "ОСК"|"МАТ", punish: текст наказания} или "" — если ничего не подошло.
PunishWordsMatch(prep) {
    global punishWordsList
    for _, kind in ["ОСК", "МАТ"] {
        bestScore := 0
        best := ""
        for _, entry in punishWordsList {
            if (entry.kind != kind)
                continue
            score := AnswerMatch(entry.key, prep)
            if (score > bestScore) {
                bestScore := score
                best := entry
            }
        }
        if (IsObject(best))
            return {kind: kind, punish: best.punish}
    }
    return ""
}


; === PunishSplitCommand: наказание -> команда и аргументы. «360 Причина» -> /rmute; «/jail 120 Причина» -> /jail ===
PunishSplitCommand(text) {
    if (RegExMatch(text, "^(/\w+)(?:\s+(.*))?$", m))
        return {cmd: m1, args: m2}
    return {cmd: "/rmute", args: text}
}


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

; === PunishConfirm: плашка подтверждения выдачи наказаний ===
; Показывает плашку и ждёт: Enter — подтвердить, Esc — отмена. Отмена и по таймеру (ms), и если игра потеряла фокус.
; Пока плашка на экране, Enter/Esc не передаются игре. Нажатия в первые 0.35 с и пока Enter/Space ещё зажаты игнорируются,
; чтобы не подтвердить случайным повтором Enter после ввода ID. Плашка показывается и при выключенных подсказках.
; Возврат: true — подтверждено (или подтверждение выключено в настройках), false — отменено.
PunishConfirm(title, body, action, ms := 15000, accent := "FF9F43") {
    global punishConfirmEnabled, punishConfirmState, punishConfirmArmed, ntfList
    if (!punishConfirmEnabled)
        return true
    if (punishConfirmState != "")
        return false
    punishConfirmState := "wait"
    punishConfirmArmed := false

    wasCrit := A_IsCritical
    Critical, On
    item := NtfBuild(40, 380, title, body, action, "Enter — выдать   ·   Esc — отмена", accent, true)
    item.num := 40
    item.tag := "PunishConfirm"
    item.until := A_TickCount + ms + 5000
    item.shown := false
    ntfList.Push(item)
    NtfLayout()
    SetTimer, NtfTick, 100
    Critical, % wasCrit ? "On" : "Off"

    start := A_TickCount
    result := false
    Loop {
        if (punishConfirmState = "yes") {
            result := true
            break
        }
        if (punishConfirmState = "no")
            break
        elapsed := A_TickCount - start
        if (elapsed >= ms || !WinActive("ahk_exe gta_sa.exe"))
            break
        if (!punishConfirmArmed && elapsed >= 350 && !GetKeyState("Enter", "P") && !GetKeyState("NumpadEnter", "P") && !GetKeyState("Space", "P"))
            punishConfirmArmed := true
        pct := 100 - (elapsed * 100) // ms
        GuiControl, 40:, NtfBar40, %pct%
        Sleep, 25
    }

    punishConfirmState := ""
    punishConfirmArmed := false
    Critical, On
    i := ntfList.Length()
    while (i >= 1) {
        if (ntfList[i].tag = "PunishConfirm")
            ntfList.RemoveAt(i)
        i--
    }
    Gui, 40:Destroy
    NtfLayout()
    Critical, % wasCrit ? "On" : "Off"
    return result
}


; === PunishConfirmPress: обработка Enter (yes) и Esc (no) на время подтверждения ===
; Возврат: true — клавиша поглощена подтверждением и в игру не передаётся.
PunishConfirmPress(choice) {
    global punishConfirmState, punishConfirmArmed
    if (punishConfirmState != "wait")
        return false
    if (punishConfirmArmed)
        punishConfirmState := choice
    return true
}


; === PunishConfirmBtnText: текст кнопки подтверждения в настройках ===
PunishConfirmBtnText() {
    global punishConfirmEnabled
    return "🛡 Подтверждение наказаний: " . (punishConfirmEnabled ? "✔ Включено" : "✘ Выключено")
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
    global requestCanRecall
    playerName := "", playerDetectId := "", playerLvl := "", maskName := ""
    SendInput, ^a {BackSpace}{Enter}
    Sleep, 70
    requestCanRecall := false
    ; Читаем только строки, появившиеся ПОСЛЕ отправки /id: старые ответы /id (другой игрок с тем же ID) не учитываются.
    ChatlogWatchFromNow("punish")
    SendInput, {F6}/id %playerId%{Enter}
    Sleep, 250
    deadline := A_TickCount + 1500
    while (playerLvl = "" && A_TickCount < deadline) {
        for _, line in ChatlogReadNew("punish") {
            ; Обычный ник:  Nick_Name[143], ID: 143, уровень: 44, ...
            ; В маске:      Mask_809883[143] (реальное имя: Max_Gossnik), ID: 143, уровень: 44, ...
            if !RegExMatch(line, "(\w+)(?:\[\d+\])?(?:\s*\([^:)]*:\s*(\w+)\))?,\s*ID:\s*(\d+),\s*[^:,]+:\s*(\d+)", m)
                continue
            if ((m3 + 0) != (playerId + 0)) {
                playerDetectId := m3
                continue
            }
            playerDetectId := m3
            playerLvl := m4
            if (m2 != "") {
                maskName := m1
                playerName := m2
            } else {
                playerName := m1
            }
        }
        if (playerLvl = "")
            Sleep, 100
    }
    if (maskName != "")
        playerName := playerName . " (маска " . maskName . ")"
    if (playerLvl != "") {
        fullCmd := punishMap[cmdKey]
        RegExMatch(fullCmd, "^(\/\w+)\s+(\d+)?\s*(.+)?", p)
        cmd := p1
        duration := p2
        reason := p3
        origCmd := cmd
        origDuration := duration

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
        ; Подтверждение: показывается итоговая команда (уже с поправкой на уровень игрока).
        confirmNote := (cmd != origCmd || duration != origDuration) ? "   ·   смягчено: уровень ≤ 5" : ""
        if (maskName != "")
            confirmNote .= "   ·   игрок в маске"
        confirmCmd := Trim(cmd . " " . playerId . " " . duration . " " . reason)
        if (!PunishConfirm("НАКАЗАНИЕ  ·  " . playerName . "[" . playerId . "]", "Уровень игрока: " . playerLvl . confirmNote, "➜  " . confirmCmd)) {
            ToolTip("[PUNISH] Выдача отменена, наказание не отправлено.", 2500)
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
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Введенный ID: " . playerId . ". " . (playerDetectId != "" ? "В ответе /id другой ID: " . playerDetectId . "." : "Игрок в ответе /id не найден.") . "`n↪︎ Выдача наказания приостановлена.", 2332)
    }
}


; ====================================================================================================================
; АДМИН: АВТОВЫДАЧА НАКАЗАНИЙ (auto-issue.txt)
; ====================================================================================================================

; Формат строки в auto-issue.txt: /команда Nick_Name [время] [причина]. Строки с ; # // -- игнорируются.
; Выдача идёт строго по одной команде: ответ сервера читается только из строк, появившихся ПОСЛЕ отправки.
; Остановить выдачу — нажать клавишу «Автовыдача» ещё раз. Невыданные строки остаются в файле.

autoIssue:
    AutoIssueRun()
Return


; === IssueCfg: лимиты команды. Команды одного семейства делят один счётчик (защита от слёта админки) ===
; Формат таблицы: семейство:команды:лимит:пауза_между_командами_мс:ожидание_после_лимита_мс
IssueCfg(cmdType) {
    static fam := ""
    static lim := ""
    if (!IsObject(fam)) {
        fam := {}, lim := {}
        table := "jail:/jail,/offjail:4:800:70000|ban:/soffban,/offban,/sban,/ban:2:800:90000|warn:/offwarn,/warn:2:800:80000"
        table .= "|mute:/mute,/v_mute,/rmute:2:800:75000|fmute:/fmute:1:800:75000|kick:/kick:5:800:60000|gunban:/gunban:3:800:60000|msg:/msg:50:2050:2050"
        for _, row in StrSplit(table, "|") {
            p := StrSplit(row, ":")
            lim[p[1]] := [p[3] + 0, p[4] + 0, p[5] + 0]
            for _, c in StrSplit(p[2], ",")
                fam[c] := p[1]
        }
    }
    f := fam.HasKey(cmdType) ? fam[cmdType] : cmdType
    l := lim.HasKey(f) ? lim[f] : [3, 800, 80000]
    return {fam: f, limit: l[1], delay: l[2], wait: l[3]}
}


; === IssueSlotLeft: через сколько мс можно отправить команду этого семейства (0 — можно сейчас) ===
IssueSlotLeft(cmdType) {
    cfg := IssueCfg(cmdType)
    st := issueState[cfg.fam]
    if (!IsObject(st))
        return 0
    elapsed := A_TickCount - st.t
    if (elapsed >= cfg.wait)
        return 0
    if (st.n >= cfg.limit)
        return cfg.wait - elapsed
    return (elapsed < cfg.delay) ? cfg.delay - elapsed : 0
}


; === IssueRecord: учесть принятую сервером команду в лимите семейства ===
IssueRecord(cmdType, tick) {
    cfg := IssueCfg(cmdType)
    st := issueState[cfg.fam]
    if (!IsObject(st))
        st := {n: 0, t: 0}
    if (tick - st.t >= cfg.wait)
        st.n := 0
    st.n++
    st.t := tick
    issueState[cfg.fam] := st
}


; === IssueAcquire: дождаться свободного слота лимита. false — выдача остановлена ===
IssueAcquire(cmdType) {
    Loop {
        left := IssueSlotLeft(cmdType)
        if (left <= 0)
            return !IssueAborted()
        if (left > 1500)
            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Лимит для " . cmdType . ". Ожидаю " . Ceil(left / 1000) . " сек...", 1200)
        if (!IssueSleep(left < 1000 ? left : 1000))
            return false
    }
}


; === IssueAborted / IssueSleep / IssueReady: остановка клавишей и ожидание готовности игры ===
IssueAborted() {
    key := hotkeys["autoIssue"]
    if (!issueAbort && key != "" && GetKeyState(key, "P"))
        issueAbort := true
    return issueAbort
}

IssueSleep(ms) {
    end := A_TickCount + ms
    while (A_TickCount < end) {
        if (IssueAborted())
            return false
        Sleep, 50
    }
    return !IssueAborted()
}

IssueReady() {
    t := A_TickCount
    while (!WinActive("ahk_exe gta_sa.exe") || ChatIsOpen) {
        if (IssueAborted())
            return false
        if (A_TickCount - t > 10000) {
            issueAbort := true
            return false
        }
        Sleep, 100
    }
    return true
}


; === IssueSend: ввод команды в чат (кириллица — как в HandlePunishment: RU-раскладка + SendEvent {Raw}) ===
IssueSend(text) {
    if (!IssueReady())
        return false
    requestCanRecall := false
    SendMessage, 0x50,, 0x4190419,, A
    SendInput, ^a {BackSpace}{Enter}
    Sleep, 70
    Critical, On
    if (RegExMatch(text, "[^\x00-\x7F]")) {
        SendInput, {F6}
        Sleep, 85
        SetKeyDelay, 25, 15
        SendEvent, % "{Raw}" . text
        Sleep, 80
        SendEvent, {Enter}
    } else {
        SendInput, {F6}
        Sleep, 40
        SendInput, % "{Raw}" . text
        Sleep, 40
        SendInput, {Enter}
    }
    Critical, Off
    ChatIsOpen := false
    return true
}


; === IssueClassify: разбор ответа сервера на только что отправленную команду (~0.7 с) ===
; Возврат: "" — ошибок нет, "online", "jailed", "muted", "banned" или "abort".
IssueClassify(cmdType) {
    skipOnline := (cmdType = "/kick" || cmdType = "/msg" || cmdType = "/gunban" || cmdType = "/mute" || cmdType = "/v_mute" || cmdType = "/fmute" || cmdType = "/rmute")
    isJail := (cmdType = "/jail" || cmdType = "/offjail" || cmdType = "/kjail")
    isMute := (cmdType = "/mute" || cmdType = "/rmute" || cmdType = "/fmute")
    end := A_TickCount + 700
    while (A_TickCount < end) {
        for _, line in ChatlogReadNew("issue") {
            line := RegExReplace(line, "\{[0-9A-Fa-f]{6,8}\}", "")
            if (!skipOnline && RegExMatch(line, "Игрок с таким именем находится на сервере, используйте\s+\S"))
                return "online"
            if (isJail && InStr(line, "Этот игрок уже находится в тюрьме"))
                return "jailed"
            if (isMute && InStr(line, "У этого игрока уже есть блокировка"))
                return "muted"
            if (InStr(line, "Аккаунт с таким именем уже находится в бане"))
                return "banned"
        }
        if (IssueAborted())
            return "abort"
        Sleep, 50
    }
    return ""
}


; === IssueRemaining: /time — сколько осталось до конца наказания. Число; -1 — нет ответа; -2 — остановлено ===
IssueRemaining(nick, kind) {
    ChatlogWatchFromNow("issue")
    if (!IssueSend("/time " . nick))
        return -2
    pattern := (kind = "jailed") ? "Время до выхода на свободу:\s*(\d+):\d+" : "Время до разблокировки (?:чата|репорта):\s*(\d+):\d+"
    end := A_TickCount + 1500
    while (A_TickCount < end) {
        for _, line in ChatlogReadNew("issue") {
            line := RegExReplace(line, "\{[0-9A-Fa-f]{6,8}\}", "")
            if (RegExMatch(line, pattern, m))
                return m1
        }
        if (IssueAborted())
            return -2
        Sleep, 50
    }
    return -1
}


; === IssueProcess: выдача одной команды. Возврат: "done", "banned", "fail" или "abort" ===
IssueProcess(it) {
    cmdType := it.type, nick := it.nick, line := it.line
    issueTime := it.time, reason := it.reason
    kicked := false, reissued := false
    ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Ввожу команду: " . line, 1500)
    Loop {
        if (!IssueAcquire(cmdType))
            return "abort"
        ChatlogWatchFromNow("issue")
        if (!IssueSend(line))
            return "abort"
        sentAt := A_TickCount
        r := IssueClassify(cmdType)
        if (r = "abort")
            return "abort"
        if (r = "") {
            IssueRecord(cmdType, sentAt)
            return "done"
        }
        if (r = "banned")
            return "banned"
        if (r = "online" && !kicked) {
            kicked := true
            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] " . line . "`n↪️ Игрок " . nick . " на сервере. Исключаю игрока...", 1500)
            if (!IssueAcquire("/kick"))
                return "abort"
            if (!IssueSend("/kick " . nick . " Ожидайте наказания."))
                return "abort"
            IssueRecord("/kick", A_TickCount)
            if (!IssueSleep(IssueCfg("/kick").delay))
                return "abort"
            continue
        }
        if ((r = "jailed" || r = "muted") && !reissued) {
            reissued := true
            ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] " . line . "`n↪️ У игрока " . nick . " уже есть наказание. Получаю оставшееся время...", 1500)
            rem := IssueRemaining(nick, r)
            if (rem = -2)
                return "abort"
            if (rem < 0) {
                ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Нет ответа на /time для " . nick . ". Команда пропущена.", 3000)
                return "fail"
            }
            if (r = "jailed")
                unCmd := "/unjail"
            else
                unCmd := (cmdType = "/mute") ? "/unmute" : (cmdType = "/fmute") ? "/unfmute" : "/unrmute"
            if (!IssueSend(unCmd . " " . nick))
                return "abort"
            if (!IssueSleep(IssueCfg(cmdType).delay))
                return "abort"
            issueTime := (issueTime = "" ? 0 : issueTime) + rem
            reason := reason . "(перевыдано)"
            line := Trim(cmdType . " " . nick . " " . issueTime . " " . reason)
            continue
        }
        return "fail"
    }
}


; === IssueReadFile: текст auto-issue.txt (UTF-8, при ошибках — CP1251). Создаёт шаблон, если файла нет ===
IssueReadFile() {
    if (!FileExist(autoIssueFile)) {
        text := "# Список наказаний для автовыдачи: одна команда на строку.`n# Пример: /offjail Nick_Name 120 Жалоба на игрока 1`n`n"
        FileAppend, %text%, %autoIssueFile%, UTF-8
        return ""
    }
    f := FileOpen(autoIssueFile, "r", "UTF-8")
    if (!IsObject(f))
        return ""
    content := f.Read()
    f.Close()
    if (InStr(content, Chr(0xFFFD))) {
        f := FileOpen(autoIssueFile, "r", "CP1251")
        if (!IsObject(f))
            return ""
        content := f.Read()
        f.Close()
    }
    return content
}


; === AutoIssueConfirm: плашка подтверждения перед автовыдачей (одна на весь список; первые 5 команд + сколько ещё) ===
AutoIssueConfirm(items) {
    total := items.Length()
    shown := total < 5 ? total : 5
    body := ""
    Loop, %shown%
    {
        line := items[A_Index].line
        if (StrLen(line) > 58)
            line := SubStr(line, 1, 58) . "…"
        body .= (A_Index > 1 ? "`n" : "") . line
    }
    if (total > shown)
        body .= "`n…и ещё " . (total - shown)
    return PunishConfirm("АВТОВЫДАЧА  ·  наказаний: " . total, body, "➜  Выдавать по очереди с паузами. Остановить — клавиша «Автовыдача».", 30000, "FF5C5C")
}


; === AutoIssueRun: автовыдача наказаний из auto-issue.txt ===
AutoIssueRun() {
    if (scriptMode != "Admin" || issueRunning || !WinActive("ahk_exe gta_sa.exe"))
        return
    issueRunning := true
    issueAbort := false
    key := hotkeys["autoIssue"]
    if (key != "")
        KeyWait, %key%, T2

    existed := FileExist(autoIssueFile) ? true : false
    content := IssueReadFile()
    fileLines := [], items := [], bad := 0
    Loop, Parse, content, `n, `r
    {
        fileLines.Push(A_LoopField)
        t := Trim(LTrim(A_LoopField, Chr(0xFEFF)), " `t")
        if (t = "" || RegExMatch(t, "^(;|#|//|--)"))
            continue
        if (!RegExMatch(t, "^(/\w+)\s+(\S+)(?:\s+(\d+))?\s*(.*)$", m)) {
            bad++
            continue
        }
        items.Push({idx: fileLines.MaxIndex(), line: t, type: m1, nick: m2, time: m3, reason: m4})
    }

    ; Подтверждение всего списка перед началом: при отмене ничего не отправляется и файл не меняется.
    if (items.Length() > 0 && !AutoIssueConfirm(items)) {
        ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Выдача отменена, список не изменён.", 3000)
        issueRunning := false
        return
    }

    total := items.Length(), doneCount := 0, okCount := 0, bannedCount := 0
    done := {}
    if (total = 0) {
        ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] " . (existed ? "Список пуст." : "Создан файл " . autoIssueFile . ". Заполните его и нажмите клавишу снова."), 4000)
    } else {
        pending := items.Clone()
        while (pending.Length() > 0) {
            pick := 0, minLeft := 2147483647
            for i, cand in pending {
                left := IssueSlotLeft(cand.type)
                if (left <= 0) {
                    pick := i
                    break
                }
                if (left < minLeft)
                    minLeft := left
            }
            if (!pick) {
                ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] Лимит наказаний. Ожидаю " . Ceil(minLeft / 1000) . " сек. Осталось команд: " . pending.Length(), 1200)
                if (!IssueSleep(minLeft < 1000 ? minLeft : 1000))
                    break
                continue
            }
            it := pending[pick]
            pending.RemoveAt(pick)
            res := IssueProcess(it)
            if (res = "abort")
                break
            if (res = "done" || res = "banned") {
                done[it.idx] := true
                doneCount++
                if (res = "done")
                    okCount++
                else
                    bannedCount++
            }
        }

        if (doneCount > 0) {
            out := ""
            for i, ln in fileLines
                if (!done.HasKey(i))
                    out .= ln . "`r`n"
            out := RTrim(out, "`r`n") . "`r`n"
            tmp := autoIssueFile . ".tmp"
            FileDelete, %tmp%
            FileAppend, %out%, %tmp%, UTF-8
            FileMove, %tmp%, %autoIssueFile%, 1
        }
        ToolTip("[𝐀𝐔𝐓𝐎-𝐈𝐒𝐒𝐔𝐄] " . (issueAbort ? "Остановлено. " : "Готово. ") . "Выдано: " . okCount . ", уже забанены: " . bannedCount . ", осталось в файле: " . (total - doneCount) . (bad ? ", неверный формат: " . bad : "") . ".", 7000)
    }
    issueRunning := false
}


; ====================================================================================================================
; ИГРОК: АВТОЭДИТ, BIZLIST И ЗАРАБОТОК
; ====================================================================================================================

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
        ; Таймер работает часто, но отправляем не чаще раза в 1 секунду.
        if (lastBizlistAttempt && (A_TickCount - lastBizlistAttempt) < 1000)
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
        }
    }
}


; ====================================================================================================================
; ГОРЯЧИЕ КЛАВИШИ И ХОТКЕИ ИГРЫ
; ====================================================================================================================

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
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] Таймер запущен на " . time . " мин.", 3000)
        SetTimer, TimerFunc, %timeMs%
    } else {
        SendInput, {End}+{Home}{Del}{Esc}
    }
Return

~F6::
~t::
    ChatIsOpen := true
return

Enter::
    ; Плашка подтверждения наказания поглощает Enter (выдать).
    if (PunishConfirmPress("yes"))
        return
    ; Пока меню открыто, Enter выполняет выбранную кнопку и не передаётся игре.
    if (MenuKeyboardEnabled()) {
        MenuActivateSelected()
        return
    }
    ; Любой Enter в игре мог отправить в чат что-то своё (в том числе когда признак ChatIsOpen не поймал открытие чата):
    ; повтор /z через ↑ после этого запрещён, иначе автозапрос подставил бы и изменил чужую команду.
    if (!requestBusy)
        requestCanRecall := false
    ChatIsOpen := false
    SendInput, {Enter}
return

Escape::
    ; Плашка подтверждения наказания поглощает Esc (отмена): в игру он не уходит и pause menu не открывается.
    if (PunishConfirmPress("no"))
        return
    ; Esc закрывает меню/возвращает назад, иначе передаётся игре.
    if (MenuKeyboardEnabled()) {
        MenuKeyboardEscape()
        return
    }
    ChatIsOpen := false
    SendInput, {Escape}
return

#If

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
F1::MenuHelpSelected()
#If
