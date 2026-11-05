#SingleInstance, Force
#Persistent
#NoEnv
#NoTrayIcon

SetTitleMatchMode, 2
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

global version := "v 1.7.3"
global LicenseURL := "aHR0cHM6Ly9naXN0LmdpdGh1YnVzZXJjb250ZW50LmNvbS9NYWtzaW00ZWtrL2Jl`nMmQ0MjE5MzE1NjFkZDAxYjQzM2Y5M2NhNTMyOWQwL3Jhdy9WaU1lTGxZLWtleXMu`ndHh0"

global repID, ansID, ansLogID
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
global today := A_DD . "." . A_MM . "." . A_YYYY
global menuNavItems := []
global menuNavIndex := 0
global menuNavGuiName := ""
global menuNavGuiHwnd := 0
global CurrentHWID, EnteredKey, onOrder
OnMessage(0x21, "MenuMouseActivate")

SetTimer, InitializeViMeLlY, -50

IniRead, scriptModeStatus, %settingsFile%, Preset, scriptMode
global scriptMode := scriptModeStatus

IniRead, userNickname, %settingsFile%, Preset, userNickname
IniRead, rL, %settingsFile%, Preset, reportLog
IniRead, pH, %settingsFile%, Preset, punishHelperStatus
IniRead, aF, %settingsFile%, Preset, additionalFeaturesStatus
IniRead, aS, %settingsFile%, Preset, adminStatsStatus
IniRead, isToolTipActive, %settingsFile%, Preset, isToolTipActive, 1
IniRead, ntfCorner, %settingsFile%, Preset, ntfCorner, 3
ntfCorner := (ntfCorner >= 1 && ntfCorner <= 5) ? ntfCorner + 0 : 3
IniRead, isHumanInput, %settingsFile%, Preset, isHumanInput, 0
isHumanInput := (isHumanInput = 1) ? 1 : 0
IniRead, autoSpMode, %settingsFile%, Preset, autoSpMode, 1
autoSpMode := (autoSpMode = 2 || autoSpMode = 3) ? autoSpMode + 0 : 1
IniRead, autoSpPool, %settingsFile%, Preset, autoSpPool, 5
autoSpPool := (autoSpPool >= 1 && autoSpPool <= 10) ? autoSpPool + 0 : 5

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
    IniRead, inputMode, %settingsFile%, Preset, isHumanInput, 0
    isHumanInput := (inputMode = 1) ? 1 : 0

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
    global NtfEnd31, NtfEnd32, NtfEnd33, NtfEnd34, NtfEnd35, NtfEnd36, NtfEnd37, NtfEnd38, NtfEnd39, NtfBar39
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
        action := "➜  /rmute " . item.id . " " . item.reply
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

    IniRead, CS, %settingsFile%, Preset, currentSetup
    IniRead, d1, %settingsFile%, Preset, Delay1
    IniRead, d2, %settingsFile%, Preset, Delay2
    IniRead, d3, %settingsFile%, Preset, Delay3
    
    SetPreset(CS, d1, d2, d3)
}


; ====================================================================================================================
; СТАТИСТИКА
; ====================================================================================================================

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
    if (settingsOpen) {
        Gosub, SaveCustomDelays
        settingsOpen := false
    }
    SetTimer, SaveCustomDelays, Off
    Gui, ViMeLlYSettings:Destroy
}


InteractWindowClose() {
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
    Gui, ViMeLlY:Font, s8, Segoe UI
    Gui, ViMeLlY:Add, Text, x17 y+1 w381 Center vMainStatusLine, % MainStatusText()

    if (scriptMode == "Admin") {
        MenuSection("ViMeLlY", "Помощник по репортам")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w271 gAutoSpMode_Cycle vAutoSpModeButton, ⇄ Выбор жалобы: %autoSpModeName%
        Gui, ViMeLlY:Add, Button, x+1 yp w109 gAutoSpPool_Cycle vAutoSpPoolButton, 🧠 Помнит: %autoSpPool%
        Gui, ViMeLlY:Add, Button, x17 y+1 w190 gReportLog_ToggleStatus vStatusLogButton, %ansLogStatus%
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gPunishHelper_ToggleStatus vPunishHelperButton, %punishHelperSwitch%
        Gui, ViMeLlY:Font, s7, Segoe UI
        Gui, ViMeLlY:Add, Text, x17 y+2 w381 Center vAutoSpHint, % AutoSpHintText()

        MenuSection("ViMeLlY", "Настройки")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w190 gHotKeys,🕹 Настройки клавиш྾
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gAnswers,⚙️ Настройки ответов྾
        Gui, ViMeLlY:Add, Button, x17 y+1 w381 gInteractMenu, 🎯 Взаимодействие с игроком
        Gui, ViMeLlY:Add, Button, x17 y+1 w190 gOpenPunishHelper, 📄 Файл умных наказаний
        Gui, ViMeLlY:Add, Button, x+1 yp w190 gScriptSettings,⚙️ Настройки скрипта྾

        MenuSection("ViMeLlY", "Статистика")
        Gui, ViMeLlY:Font, s8, Segoe UI
        Gui, ViMeLlY:Add, Button, x17 y+2 w20 vadminStatsButton gToggleAdminStats, %adminStatsSwitch%
        Gui, ViMeLlY:Add, Button, x+1 yp w360 gAdminStatsPanel, 📊 Статистика администратора
        Gui, ViMeLlY:Font, s7, Segoe UI
        Gui, ViMeLlY:Add, Text, x17 y+2 w381 Center, Кнопка слева включает или выключает подсчёт ответов и джейлов
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

    Gui, ViMeLlY:Font, s9, Comic Sans MS
    Gui, ViMeLlY:Add, Text, x17 y+0 w381 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
    Gui, ViMeLlY:Font, s7, Comic Sans MS 
    Gui, ViMeLlY:Add, Text, x17 y+4 w381 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
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
    Gui, ViMeLlYHotKeys:Font, s7, Segoe UI
    Gui, ViMeLlYHotKeys:Add, Text, xm y+2 w400 Center, Автоответ — это клавиша Reply: после слежки приветствие, Reply + Enter — ответ по подсказке, Reply + 1…0 — быстрые ответы.
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
    Gui, ViMeLlYAnswers:Font, s7, Segoe UI
    Gui, ViMeLlYAnswers:Add, Text, xm y+2 w380 Center, Reply — приветствие при слежке, Reply + 1…0 — быстрые ответы, Offline — игрок вышел.
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
    Gui, ViMeLlYStats:Font, s7, Segoe UI
    Gui, ViMeLlYStats:Add, Text, xm y+2 w380 Center, Ответы (PM) и джейлы (J) за сегодня и последние 3 дня.
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
    tipBtnText := isToolTipActive ? "💬 Всплывающие подсказки: ✔ Включены" : "💬 Всплывающие подсказки: ✘ Выключены"
    addBtnText := additionalFeaturesStatus ? "➕ Доп. возможности: ✔ Включены" : "➕ Доп. возможности: ✘ Выключены"

    Gui, ViMeLlY:Hide
    Gui, ViMeLlYSettings:New,, ViMeLlY Script
    Gui, ViMeLlYSettings:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, ViMeLlYSettings:Color, % guiColor
    Gui, ViMeLlYSettings:Font, s14 Bold, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Text, w345 Center, ViMeLlY Script
    Gui, ViMeLlYSettings:Font, s10 Bold, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Button, yp x317 gReload,⟲
    Gui, ViMeLlYSettings:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYSettings:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYSettings:Add, Text, y+1 x17 w381 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧‧‧‧‧‧‧ Настройки скрипта ‧‧‧‧‧‧‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧

    MenuSection("ViMeLlYSettings", "Ввод команд")
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w381 gToggleInputMode vInputModeButton, %inputBtnText%
    Gui, ViMeLlYSettings:Font, s7, Segoe UI
    Gui, ViMeLlYSettings:Add, Text, x17 y+2 w381 Center, Ручной — команды печатаются по символам с паузами. Автоматический — мгновенно.
    if (scriptMode == "Admin") {
        Gui, ViMeLlYSettings:Font, s8, Segoe UI
        Gui, ViMeLlYSettings:Add, Text, x17 y+5 w381, Скорость ввода (паузы при ручном вводе):
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
            Gui, ViMeLlYSettings:Font, s7, Segoe UI
            Gui, ViMeLlYSettings:Add, Text, x17 y+3 w381 Center, Меньше значения — быстрее, но выше риск потерять символ. Применяется после ⟲.
            SetTimer, SaveCustomDelays, 150
        } else {
            SetTimer, SaveCustomDelays, Off
            Gui, ViMeLlYSettings:Add, Text, x17 y+2 w381 Center, Готовые наборы пауз между символами. «Настраиваемый» — свои значения.
        }
    }

    MenuSection("ViMeLlYSettings", "Подсказки")
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w381 gToggleToolTips vToolTipsButton, %tipBtnText%
    Gui, ViMeLlYSettings:Font, s7, Segoe UI
    Gui, ViMeLlYSettings:Add, Text, x17 y+2 w381 Center, Сообщения скрипта плашками на экране: статус, ответы, ошибки.
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+4 w190 gNtfPosSelect vNtfPos1, % NtfPosText(1)
    Gui, ViMeLlYSettings:Add, Button, x+1 yp w190 gNtfPosSelect vNtfPos2, % NtfPosText(2)
    Gui, ViMeLlYSettings:Add, Button, x17 y+1 w381 gNtfPosSelect vNtfPos3, % NtfPosText(3)
    Gui, ViMeLlYSettings:Add, Button, x17 y+1 w190 gNtfPosSelect vNtfPos4, % NtfPosText(4)
    Gui, ViMeLlYSettings:Add, Button, x+1 yp w190 gNtfPosSelect vNtfPos5, % NtfPosText(5)
    Gui, ViMeLlYSettings:Font, s7, Segoe UI
    Gui, ViMeLlYSettings:Add, Text, x17 y+2 w381 Center, Положение плашек: выберите угол или середину слева, на экране появится пробная плашка.

    if (scriptMode == "Admin") {
        MenuSection("ViMeLlYSettings", "Дополнения")
        Gui, ViMeLlYSettings:Font, s8, Segoe UI
        Gui, ViMeLlYSettings:Add, Button, x17 y+2 w290 gAdditionalFeatures_ToggleStatus vAdditionalFeaturesButton, %addBtnText%
        Gui, ViMeLlYSettings:Add, Button, x+1 yp w90 gOpenAdditionalFeatures, 📄 Файл
        Gui, ViMeLlYSettings:Font, s7, Segoe UI
        Gui, ViMeLlYSettings:Add, Text, x17 y+2 w381 Center, Запускает ваш файл дополнений вместе со скриптом.
    }

    MenuSection("ViMeLlYSettings", "Система")
    Gui, ViMeLlYSettings:Font, s8, Segoe UI
    Gui, ViMeLlYSettings:Add, Button, x17 y+2 w190 gOpenSettings, 📂 Открыть файл настроек
    Gui, ViMeLlYSettings:Add, Button, x+1 yp w190 gResetLicenseKey, 🔑 Сбросить ключ доступа

    Gui, ViMeLlYSettings:Font, s9, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Text, x17 y+4 w381 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
    Gui, ViMeLlYSettings:Font, s7, Comic Sans MS
    Gui, ViMeLlYSettings:Add, Text, x17 y+4 w381 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
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
    newTipText := isToolTipActive ? "💬 Всплывающие подсказки: ✔ Включены" : "💬 Всплывающие подсказки: ✘ Выключены"
    GuiControl, ViMeLlYSettings:, ToolTipsButton, %newTipText%
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

AutoSpMode_Cycle:
    autoSpMode := (autoSpMode >= 3) ? 1 : autoSpMode + 1
    IniWrite, %autoSpMode%, %settingsFile%, Preset, autoSpMode
    autoSpModeName := AutoSpModeName(autoSpMode)
    GuiControl,, AutoSpModeButton, ⇄ Выбор жалобы: %autoSpModeName%
Return

AutoSpPool_Cycle:
    autoSpPool := AutoSpNextPool(autoSpPool)
    IniWrite, %autoSpPool%, %settingsFile%, Preset, autoSpPool
    GuiControl,, AutoSpPoolButton, 🧠 Помнит: %autoSpPool%
    GuiControl,, AutoSpHint, % AutoSpHintText()
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
    Gui, ViMeLlYInteract:Add, Button, yp x300 gReload,⟲
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gResetInteract,♻️
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gBack,⮐
    Gui, ViMeLlYInteract:Add, Button, yp x+1 gClose,✘
    Gui, ViMeLlYInteract:Add, Text, y+1 xm w380 Center, ‧  ‧ ‧ ‧ ‧‧‧‧‧‧‧‧ Взаимодействие с игроком ‧‧‧‧‧‧‧‧ ‧  ‧ ‧ ‧
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
    Gui, ViMeLlYInteract:Font, s7, Segoe UI
    Gui, ViMeLlYInteract:Add, Text, x25 y+4 w365 Center, Слева — команда (например /mute), справа — текст после ID. Пустая команда — слот выключен.
    Gui, ViMeLlYInteract:Add, Text, x25 y+1 w365 Center, Команду можно писать через точку в русской раскладке: .пуемур = /getveh
    Gui, ViMeLlYInteract:Font, s7, Comic Sans MS
    Gui, ViMeLlYInteract:Add, Text, x25 y+4 w380 h14 Center vMenuKeyboardHint, ↑ ↓ ← → / Tab — выбор • Enter — выполнить • Esc — назад/закрыть
    Gui, ViMeLlYInteract:Add, Text, x25 y+0 w380 h14 Center vMenuKeyboardSelection, Выберите пункт стрелками или Tab
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
    if (MySetup_sp != "")
        IniWrite, %MySetup_sp%, %settingsFile%, Preset, Delay1
    if (MySetup_d1 != "")
        IniWrite, %MySetup_d1%, %settingsFile%, Preset, Delay2
    if (MySetup_d2 != "")
        IniWrite, %MySetup_d2%, %settingsFile%, Preset, Delay3
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

spTimersOff() {
    SetTimer, WatchKeys, Off
    SetTimer, WatchSpectate, Off
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

Watch:
    spTimersOff()
    Sleep, 50
    autoSpectate()
Return

; === AutoSpParse: репорт из строки чатлога (разбор тот же, что и раньше) ===
AutoSpParse(line) {
    at := -1
    if (RegExMatch(line, "^\[(\d{2}):(\d{2}):(\d{2})\]", t))
        at := t1 * 3600 + t2 * 60 + t3
    if (RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]:.*?\b(\d{1,3})\b", m))
        return {line: line, at: at, nick: m2, rep: m3, spec: m4, taken: false, answered: false}
    if (RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]:", m))
        return {line: line, at: at, nick: m2, rep: m3, spec: m3, taken: false, answered: false}
    return ""
}


; === AutoSpHintText: пояснение под кнопкой выбора жалобы ===
AutoSpHintText() {
    return "Случайная и самая старая — из " . autoSpPool . " последних жалоб, не старше " . Round(autoSpMaxAge / 60) . " мин"
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


; === AutoSpIsFresh: репорт не старше autoSpMaxAge секунд (по метке времени строки; без метки — считается свежим) ===
AutoSpIsFresh(e) {
    if (e.at < 0)
        return true
    diff := A_Hour * 3600 + A_Min * 60 + A_Sec - e.at
    if (diff < -120)
        diff += 86400
    else if (diff < 0)
        diff := 0
    return diff <= autoSpMaxAge
}


; === AutoSpMarkAnswered: на репорты этого игрока, пришедшие до ответа админа, ответ уже дан ===
AutoSpMarkAnswered(nick, id) {
    for _, e in autoSpReports {
        if (e.answered)
            continue
        if ((e.nick != "" && e.nick = nick) || (e.nick = "" && e.rep = id))
            e.answered := true
    }
}


; === AutoSpPickReport: выбор репорта по режиму autoSpMode (1 — последний, 2 — случайный, 3 — самый старый). В режимах 2 и 3 — только свежие (autoSpMaxAge) ===
; Чатлог читается только дочитыванием новых строк. В режимах 2 и 3 пропускаются репорты, за которыми уже заходили, и те, на которые уже ответил любой администратор.
AutoSpPickReport() {
    if (!autoSpSeeded) {
        ChatlogReadNew("autosp_list", "all")
        autoSpSeeded := true
    }
    for _, line in ChatlogReadNew("autosp_list") {
        if (InStr(line, "{FFCD00}")) {
            entry := AutoSpParse(line)
            if (IsObject(entry))
                autoSpReports.Push(entry)
        } else if (RegExMatch(line, "(?:Администратор|Агент поддержки) \w+(?:_\w+)*(?:\[\d+\])? для (\w+(?:_\w+)*)\[(\d+)\]:", ans)) {
            AutoSpMarkAnswered(ans1, ans2)
        }
    }
    while (autoSpReports.Length() > 60)
        autoSpReports.RemoveAt(1)

    count := autoSpReports.Length()
    if (count = 0) {
        ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ℹ️ ID не найдено.", 300)
        return ""
    }

    if (autoSpMode = 2 || autoSpMode = 3) {
        cand := []
        Loop, % (count < autoSpPool ? count : autoSpPool)
        {
            entry := autoSpReports[count - A_Index + 1]
            if (!entry.taken && !entry.answered && AutoSpIsFresh(entry))
                cand.Push(entry)
        }
        if (cand.Length() = 0) {
            ToolTip("[𝐒𝐂𝐑𝐈𝐏𝐓] ℹ️ Новых репортов нет (свежие, без ответа и не взятые, за " . Round(autoSpMaxAge / 60) . " мин).", 1500)
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
    } if (!foundAdmin) {
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
        ; Очистка ввода в чате без лишнего Esc (не открыть pause menu).
        SendInput, ^a{Backspace}
        if (idRead.status != "enter" || !RegExMatch(idRead.id, "^[1-9][0-9]{0,11}$")) {
            lastRequest := ""
            requestBusy := false
            if (idRead.status = "esc")
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
        ToolTip("[REQUEST] ID запроса записан: " . lastRequest . ". Следующее нажатие отправит /z " . lastRequest . ". Shift + клавиша — ввести заново.", 4000)
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
    ; Если такого обращения не существует, счётчик не двигаем: следующее нажатие отправит тот же ID.
    if (RequestRejected())
        ToolTip("[REQUEST] Обращение " . nextRequest . " не существует. Счётчик не изменён.", 2500)
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
; Возврат: {id: набранные цифры, status: "enter" | "esc" | "timeout"}.
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
AnswerMatch(key, prep) {
    score := 0
    Loop, Parse, key, %A_Space%
    {
        part := A_LoopField
        if (part = "")
            continue
        StringLower, part, part
        part := StrReplace(part, "ё", "е")
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
        if (!found)
            return 0
        score += 100 + StrLen(part)
    }
    return score
}


answerLogger() {
    global settingsFile, answerMap, answerRulesLoaded, answerRulesFile, answerRulesMTime, reportLog
    global answerComplaint, answerCommand, ansLogID, ansAuthor, playerId
    global adminName, targetID, targetPunish
    global answerSeen, answerSeenOrder
    static badWords := ""
    static badExpressions := ""
    if (!reportLog)
        return
    if (!IsObject(badWords)) {
        ; Корни мата ищутся внутри слов. В выражениях слова — начало слова, * — внутри слова.
        badWords := ["блят","сук","ебат","ебал","ебла","хуй","пизд","пидо","бляд","долб","заеб","неху","схуя","наеб","ахуе","охуе","поху","хуе"]
        badExpressions := ["даун","пидор","пидар","шлюх","*ебла","*ебал","кончен","рот *ебал","*ебан","нищи","пош нах","лох","дебил","дура"]
    }
    if (!answerRulesLoaded)
        LoadAnswerRules()
    targetPunish := ""
    for _, line in ChatlogReadNew("reports") {
        if RegExMatch(line, "\[(RADMIR|HASSLE)\] (\w+_\w+)?\[(\d+)\]: (.+)", match) {
            Reports := match4
            ansLogID := match3
            ansAuthor := match2
            playerId := ansLogID
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
                ShowTip(ansAuthor, ansLogID, Reports, kR, "Вопрос", bestReply, bestKey)

            isHandled := false
            for _, expr in badExpressions {
                if (AnswerMatch(expr, prep) > 0 && IsGTAOpen()) {
                    isHandled := true
                    ShowTip(ansAuthor, ansLogID, Reports, kR, "ОСК", "360 Оскорбление администрации.")
                    break
                }
            }
            if (!isHandled) {
                for _, word in badWords {
                    if (InStr(prep.flat, word) && IsGTAOpen()) {
                        ShowTip(ansAuthor, ansLogID, Reports, kR, "МАТ", "120 Мат в /report.")
                        break
                    }
                }
            }
        }
    }
}

respondComplaint() {
    global hotkeys, answerComplaint, playerId
    if (hotkeys["Reply"] = "")
        return
    if (GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P")) {
        target := playerId
        text := answerComplaint
        HintClose(false)
        Sleep, 100
        SendMessage, 0x50,, 0x4190419,, A
        sendReply(target, text)
        ToolTip("[𝐑𝐄𝐏𝐋𝐘] Игроку был дан ответ.", 3300)
        HintPump()
    }
}

respondCommand() {
    global hotkeys, answerCommand, ansLogID, isHumanInput
    global CMDDelay, InputDelay1, InputDelay2
    if (hotkeys["Reply"] = "")
        return
    if (GetKeyState(hotkeys["Reply"], "P") && GetKeyState("Enter", "P")) {
        target := ansLogID
        cmdText := answerCommand
        HintClose(false)
        Sleep, 100
        SendMessage, 0x50,, 0x4190419,, A
        if (isHumanInput) {
            l := StrLen(cmdText) + 1
            SendInput, {F6}/rmute  %cmdText%{left %l%}
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
            SendInput, {F6}/rmute %target% %cmdText%{Enter}
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
    rules .= "увол | увал = Уволить игрока в онлайне - /unvinvite. | В оффлайне - /uninviteoff.`r`n"
    rules .= "выйти семь = Покинуть семью: /family_leave.`r`n"
    rules .= "выйти банд = Покинуть банду: /family_leave.`r`n"
    rules .= "снять наручн = Снять наручники: /uncuff.`r`n"
    rules .= "розыск = Выдать игроку розыск: /su.`r`n"
    rules .= "наручн = Надеть наручники: /cuff.`r`n"
    rules .= "чин | чен | почин | почен = Не чиним автомобили. Вызывайте механиков(/c 090), либо используйте рем.комплект.`r`n"
    rules .= "пневм = Управлять пневмоподвеской: /spanel.`r`n"
    rules .= "гидр = Включить/Выключить гидравлику: Кнопка H.`r`n"
    rules .= "ключ = Передать ключи от машины: /allow.`r`n"
    rules .= "аук = Аукцион идет 24ч с момента появления слота.`r`n"
    rules .= "слет = Слет каждый час, с 8:00 до 23:00. Кроме отелей.`r`n"
    rules .= "букс | подцеп = Починить авто: /repair | Предложить буксировку на СТО: /tow | Подцепить машину: /at.`r`n"
    rules .= "посмотреть мед = Посмотреть свою мед.карту: /showmc.`r`n"
    rules .= "продать {кв|дом} = Продать квартиру/дом игроку: /sellmyhome | Государству: /sellhome.`r`n"
    rules .= "продать огород = Продать огород игроку: /sellmygarden | Государству: /sellgarden.`r`n"
    rules .= "продать киоск = Продать киоск игроку: /sellmystall | Государству: /sellstall.`r`n"
    rules .= "стил бо = Изменить стиль боя: /set_style`r`n"
    rules .= "отм заказ = Отменить заказ механика: /to | Такси: /phone - Приложение такси.`r`n"
    rules .= "отм вызов = Отменить вызов: /to.`r`n"
    rules .= "приглас | приглос | инвайт | принять = Пригласить игрока в семью/банду/фракцию: /invite.`r`n"
    rules .= "выкин авто = Выкинуть игрока из своего авто: /eject | Выкинуть из авто(МВД, ФСБ): /ejectout.`r`n"
    rules .= "спавн = Изменить место появления при заходе в игру: /setspawn.`r`n"
    rules .= "спавн банд = Изменить место появления для банды: /gang_spawn.`r`n"
    rules .= "авто банд = Добавить авто в банду: /gang_car.`r`n"
    rules .= "уволить = Уволить игрока из фракции/банды/семьи: /uninvite.`r`n"
    rules .= "ранг {банд|семь} = Изменить игроку ранг в банде/семье: /frank.`r`n"
    rules .= "ранг = Изменить ранг игроку во фракции: /rang.`r`n"
    rules .= "выда мед = Выдать мед.карту игроку: /medcard.`r`n"
    rules .= "раци = Рация организации/ТК: /r - RP(IC) | /rr - NRP(OOC).`r`n"
    rules .= "заказы дальноб = Посмотреть активные заказы на работе дальнобойщика: /bizlist - продукты | /fuellist - топливо.`r`n"
    rules .= "обмен = Чтобы провести обмен с игроком, нажмите: R - Персонаж - Обмен предметами.`r`n"
    rules .= "обмен нотар = Провести обмен в нотариальном агенстве: /exchange.`r`n"
    rules .= "багаж = Открыть багажник на личном авто: /trunk.`r`n"
    rules .= "паспорт = Показать свой паспорт: /pass.`r`n"
    rules .= "вб | воен билет = Посмотреть военный билет: /pass.`r`n"
    rules .= "тест = Предложить тест-драйв игроку: /cm_test_drive.`r`n"
    rules .= "шины = Поменять шины на авто: /replace_tire.`r`n"
    rules .= "сигнал = Установить сигнализацию на авто: /set_alarm.`r`n"
    rules .= "мп = Ожидайте. О проведении Мероприятия уведомят в чате.`r`n"
    rules .= "рвс | рвц | респ | rwc = Ожидайте. О проведении Респавна авто уведомят в чате.`r`n"
    rules .= "шкаф = Переставить шкаф: /makestore | Открыть: /use.`r`n"
    rules .= "продать биз = Продать бизнес игроку: /sellmybiz | Государству: /sellbiz.`r`n"
    rules .= "собес = Посмотреть активные события в игре: /events.`r`n"
    rules .= "удост = Показать свое удостоверение: /doc.`r`n"
    rules .= "сня брон = Снять бронежилет: /armoff.`r`n"
    rules .= "акс = Снять все надетые аксессуары: /reset | Надеть: /put_on.`r`n"
    rules .= "акс {дом|биз} = Редактировать аксессуары дома/бизнеса: /pa_edit.`r`n"
    rules .= "пожен | развод = Предложение руки и сердца: /wedding | Развестись: /divorce.`r`n"
    rules .= "свадьб = Чтобы сыграть свадьбу, необходимо купить обручальные кольца в магазине аксессуаров.`r`n"
    rules .= "бой = Вызвать на бой другого игрока в спорт.зале: /fight.`r`n"
    rules .= "выкл телеф = Включить/Выключить телефон: /togphone.`r`n"
    rules .= "ч с {фрак|орг} = Добавить в черный список организации: /blist.`r`n"
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
