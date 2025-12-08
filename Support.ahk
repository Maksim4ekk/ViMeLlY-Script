;====================================================================================================================================================

#IfWinActive ahk_exe gta_sa.exe
#Persistent
#NoEnv

SetTitleMatchMode, 2
SendMode Input
SetWorkingDir %A_ScriptDir%

global responses

isActive := false
ID1 := ""
ID2 := ""


;====================================================================================================================================================

;====================================================
;=============== РАБОТА ПО СПЕКУ ====================
;====================================================

F1::
SendInput, {F6}/sp{Space}
Return

;====================================================================================================================================================

;====================================================
;=============== РАБОТА ПО РЕПОРТУ ==================
;====================================================

PgUp::
SendMessage, 0x50,, 0x4190419,, A
response := answerResponses()
l := StrLen(response) + 1
SendInput, {F6}/pm  %response%{left %l%}
Return

PgDn::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}/pm  Не зафиксировал нарушений. Прекращаю наблюдение...{left 51}
Return

ScrollLock::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}/pm{Space}
Return

:?:!оффтоп::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /pm  Убедительная просьба прекратить offtop в /report.{left 50}
Return

:?:!нрпник::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /pm  У вашего аккаунта NonRP NickName. Смените его{!}{left 47}
Return

:?:!наказ::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /pm  Не согласны с наказанием{?} Напишите жалобу на форум.{left 52}
Return

:?:!жб::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /pm  Жалобу на форум RADMIR CRMP - https://forum.radmir.games/{left 58}
Return

:?:!проверка::
Random, number1, 10, 99
Random, number2, 10, 99
result := number1+number2
SendMessage, 0x50,, 0x4190419,, A
SendInput, /pm  Провожу проверку{!} Ответьте. Пример: %number1% {+} %number2% = {?}{left 48}
Return

:?:!поддержка::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /pm  Обратитесь в поддержку. ВК - https://vk.com/hs13sup{left 52}
Return

Pause::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}/spoff{enter}
SendInput, {F6}/pos -5531 -5036 74{enter}
SendInput, {F6}/fly_set 500{enter}
Return

Left::
SendInput, {Left}
Sleep, 333
SendInput, {RShift}
SendInput, {RShift}
SendInput, {RShift}
SendInput, {RShift}
Return

Right::
SendInput, {Right}
Sleep, 333
SendInput, {RShift}
SendInput, {RShift}
SendInput, {RShift}
SendInput, {RShift}
Return

:?:!%::/gethere
:?:!!::/getcar
:?:!"::/flip

;====================================================================
;=============== ПОЛУАВТОМАТИЧЕСКАЯ ВЫДАЧА ==========================
;====================================================================

:?:!качзп::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [Кач. зарплаты] Введите ID:{Space}
Input, ID, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return ; Завершение скрипта при нажатии Esc.
} else if (ID = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendInput, {F6}[Кач. зарплаты] Введите фракцию, ранг:{Space}
Input, rang, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return ; Завершение скрипта при нажатии Esc.
} else if (rang = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendInput, {F6}/jail %ID% 120 Кач.зарплаты (%rang%){Enter}
SendInput, {F6}/kick %ID% Кач.зарплаты (%rang%){Enter}
Return

;====================================================

:?:!оскрод::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [Оск. родни] Введите ID:{Space}
Input, ID, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return ; Завершение скрипта при нажатии Esc.
} else if (ID = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}/fmute %ID% 5760 Оскорбление родных.{Enter}
SendInput, {F6}/rmute %ID% 5760 Оскорбление родных.{Enter}
Return

;====================================================

:?:!оскпроекта::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [Оск. проекта] Введите ID:{Space}
Input, ID, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return ; Завершение скрипта при нажатии Esc.
} else if (ID = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}/fmute %ID% 5760 Оскорбление проекта.{Enter}
SendInput, {F6}/rmute %ID% 5760 Оскорбление проекта.{Enter}
Return

;====================================================

:?:!массдм::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [Массовый DM] Введите ID:{Space}
Input, ID, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return ; Завершение скрипта при нажатии Esc.
} else if (ID = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendInput, {F6}/gunban %ID% 12 Массовый DM.{Enter}
SendInput, {F6}/warn %ID% Массовый DM.{Enter}
Return

;====================================================

:?:!дмзз::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [DM in ZZ] Введите ID:{Space}
Input, ID, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return ; Завершение скрипта при нажатии Esc.
} else if (ID = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendInput, {F6}/gunban %ID% 6 DM in ZZ.{Enter}
SendInput, {F6}/warn %ID% DM in ZZ.{Enter}
Return

;====================================================================================================================================================

;=====================================================
;=============== ВЫДАЧА ==============================
;=====================================================

;======================= MUTE's ======================
:?:!рмат::/rmute 120 Мат в /report.{left 19}
:?:!роффтоп::/rmute 30 Offtop in /report.{left 22}
:?:!чмат::/mute 60 Мат/Оскорбление в ООС.{left 26}
:?:!флуд::/mute 30 Flood.{left 10}
:?:!мг::/mute 60 MG.{left 7}
:?:!мг_в::/v_mute 60 MG.{left 7}
:?:!бред_в::/v_mute 60 Бред в голосовой чат.{left 25}
:?:!музыкант::/v_mute 60 Музыка в голосовой чат.{left 27}
:?:!аоск::/rmute 360 Оскорбление администрации.{left 31}
:?:!асок::/rmute 360 Оскорбление администрации.{left 31}
:?:!аоск_ч::/mute 360 Оскорбление администрации.{left 31}
;=====================================================

;======================= JAIL's ======================
:?:!рк::/jail 120 RK.{left 8}
:?:!дмкар::/jail 60 DMcar.{left 10}
:?:!дб::/jail 60 DB.{left 7}
:?:!дм_л::/jail 60 DM.{left 7}
:?:!дм::/jail 120 DM.{left 8}
:?:!дм_в::/jail 180 DM.{left 8}
:?:!пг::/jail 120 PG.{left 8}
:?:!епп::/jail 60 Езда по полям.{left 18}
:?:!объезд::/jail 60 Объезд красного.{left 20}
:?:!встречка::/jail 60 Езда по встречной полосе.{left 29}
:?:!нрпугон::/jail 30 NonRP угон.{left 15}
:?:!нрпказ::/jail 60 NonRP казино.{left 17}
:?:!уходвинту::/jail 240 Уход в интерьер от смерти.{left 31}
:?:!госвказ::/jail 120 Гос. орг. в казино.{left 24}
:?:!госнабу::/jail 120 Гос. орг. на Б/У.{left 22}
:?:!багоюз::/jail 120 Багоюз.{left 12}
:?:!нрпповед::/jail 60 NonRP поведение.{left 20}
:?:!нрд::/jail 60 NonRP drive.{left 16}
;====================================================

;======================= WARN's ======================
:?:!ск::/warn SK.{left 4}
:?:!тк::/warn TK.{left 4}
:?:!таран::/warn NonRP drive(Таран).{left 20}
:?:!дбзз::/warn DB in ZZ.{left 10}
:?:!дминта::/warn DM в интерьере.{left 16}
:?:!дмганг::/warn DM gang.{left 9}
:?:!уход::/warn Уход от Role-Play процесса.{left 28}
:?:!сбив::/warn +С/Отводы/Сбив анимаций/Слайды.{left 31}
:?:!хилл::/warn Средства самолечения в бою.{left 28}
:?:!фр::/warn FR.{left 4}
;=====================================================

;======================= BAN's =======================
:?:!ппв::/sban 0 Передан/Продан/Взломан.{left 26}
:?:!чит::/sban 1 Использование читов.{left 23}
:?:!бот::/sban 1 Использование ботов.{left 23}
;=====================================================

;====================================================================================================================================================

;======================================
;=============== ДРУГОЕ ===============
;======================================

:?:нетп::Не телепортируем(ся).
:?:!мп::Ожидайте. Об проведении Мероприятия уведомят в чате.
:?:!ож::Ожидайте.
:?:!ут::Сформулируйте конкретный вопрос/жалобу.
:?:!слет::Слёт каждый час, с 8:00 до 23:00. Кроме отелей
:?:!рп::/mn - Помощь - База знаний - Основы Role Play - RP терминология.
:?:!свалка::Свалка: 7:00, 11:00, 14:00, 19:00, 23:00.
:?:!конт::Контейнеры: 8:00, 12:00, 16:00, 20:00, 00:00.
:?:!офф::Игрок покинул игру/Был наказан.
:?:!нн::Подобное не наказывается администрацией.
:?:!хз::Не владеем данной информацией.
:?:!ус::Узнайте самостоятельно, RP путем.

;====================================================

:?:!дата::
SendMessage, 0x50,, 0x4190419,, A
Hour := % A_Hour+0
SendInput, Дата: %A_DD%.%A_MM%.%A_YYYY%, время: %Hour%:%A_Min%:%A_Sec%.
Return

;====================================================

:?:!опечатка::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [Опечатка] Введите ID:{Space}
Input, ID1, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return
} else if (ID1 = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendInput, {F6}[Опечатка] Введите ID:{Space}
Input, ID2, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
    
	SendInput, {End}+{Home}{Del}
	Return
} else if (ID2 = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
isActive := true
Return

!2::
if (isActive) {
	SendInput, {F6}/gethere %ID1%{Enter}
	SendInput, {F6}/gethere %ID2%{Enter}
    SendInput, {F6}/debtorsell{Enter}
}
Return

!0::
isActive := false
ID1 := ""
ID2 := ""
Return

;====================================================

:?:!имя::
SendMessage, 0x50,, 0x4190419,, A
SendInput, [Смена NonRP имени] Введите ID:{Space}
Input, ID, V I M, {Enter}{Esc}
if (ErrorLevel = "EndKey:Escape") {
	SendInput, {End}+{Home}{Del}
	Return
} else if (ID = "") {
    SendInput, {End}+{Home}{Del}
    Return
}
SendInput, {End}+{Home}{Del}{Esc}
SendInput, {F6}/freeze %ID%{Enter}
SendInput, {F6}/gethere %ID%{Enter}
Sleep, 3333
SendInput, {F6}{!}Вы тут? Ответьте.{Enter}
Sleep, 5555
SendInput, {F6}{!}/mn - Настройки (шестеренка) - Сменить NonRP имя.{Enter}
SendInput, {F6}{!}Формат: Имя Фамилия.{Enter}
SendInput, {F6}{!}Имя должно быть реальным и/или существующим.{Enter}
SendInput, {F6}{!}Фамилия не содержать матов и/или оскорблений.{Enter}
Return

:?:!имя1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {!}/mn - Настройки (шестеренка) - Сменить NonRP имя.{Enter}
SendInput, {F6}{!}Формат: Имя Фамилия.{Enter}
SendInput, {F6}{!}Имя должно быть реальным и/или существующим.{Enter}
SendInput, {F6}{!}Фамилия не содержать матов и/или оскорблений.{Enter}
Return

;====================================================================================================================================================

answerResponses() {
    currentTime := % A_Hour
    timeAnswer := "Здравствуйте"
    if (currentTime >= 4 && currentTime <= 12) {
        timeAnswer := "Доброе утро"
    } else if (currentTime >= 12 && currentTime <= 17) {
        timeAnswer := "Добрый день"
    } else if (currentTime >= 18 && currentTime <= 22) {
        timeAnswer := "Добрый вечер"
    } else if (currentTime >= 23 && currentTime != 0 && currentTime != 1 && currentTime != 2 && currentTime != 3) {
        timeAnswer := "Доброй ночи"
    }

    Random, rAnswerType, 0, 2
    if (rAnswerType == 0) {
        responses := ["Доброго времени суток, репорт принят. Начинаю работу...", "Ваше обращение принято к сведенью. Веду наблюдение...", "Приветствую{!} Запрос принят. Анализирую ситуацию...", "Здравствуйте, приступаю к обработке вашего запроса.", "Доброго времени суток, запрос принят к исполнению.", "Расправляю драконьи крылья, лечу к вам{!}", "Одеваю костюм ниндзя, веду слежку за игроком...", "Накидываю на себя волшебную мантию, начинаю колдовать{!}", "Мой волшебный компаньйон уже летит к Вам на помощь{!}", "Накидываю плащ-невидимку, наблюдаю за ситуацией...", "Спасибо за обращение. Анализирую ситуацию..."]
        Random, rIndex, 1, % responses.Length()
        response := % responses[rIndex]
        return response
    } else if (rAnswerType == 1 || rAnswerType == 2) {
        responses := [", репорт принят. Начинаю слежку...", ", ваше обращение принято. Веду наблюдение...", ", запрос принят. Анализирую ситуацию...", ", приступаю к обработке вашего запроса.", ", запрос принят к исполнению.", ", благодарю за обращение. Анализирую ситуацию..."]
        Random, rIndex, 1, % responses.Length()
        response := % timeAnswer responses[rIndex]
        return response
    }
}

;====================================================================================================================================================

;====================================================
;=============== FORUM ==============================
;====================================================

#IfWinActive ahk_exe firefox.exe

;=============== Меню проверки форума
Home::
Gui, Main:New,, Меню проверки форума
Gui, Main:Font, s10, Cascadia Mono
Gui, Main:Add, Text, x75, ✧ ≡≡≡≡≡ Главное меню: выберите действие ≡≡≡≡≡ ✧
Gui, Main:Font,, Cascadia Mono
Gui, Main:Add, Picture, x10 w500 h-1, C:\Users\maksy\OneDrive\Изображения\AnimeGirl(AHK).png
Gui, Main:Add, Button, x140 y330 w240 h30, Наказание
Gui, Main:Add, Button, x15 y330 w110 h30, Опровержение
Gui, Main:Add, Button, x395 y330 w110 h30, Выдача
Gui, Main:Add, Button, x20 y365 w480 h30, Закрыть
Gui, Main:Font, s7
Gui, Main:Add, Link, x85, ≣≣≣≣≣ ❤ made by Maksyttaaa | <a href="https://vk.com/id410850476">https://vk.com/id410850476</a> ❤ ≣≣≣≣≣
Gui, Main:Show
Return

MainButtonНаказание:
    Gui, Main:Hide
    Gui, GPunishment:New,, Меню проверки форума: выдача наказаний
    Gui, GPunishment:Font, s10, Cascadia Mono
    Gui, GPunishment:Add, Text, x120, ✧ ≡≡≡≡≡ Меню выдачи наказаний ≡≡≡≡≡ ✧
    Gui, GPunishment:Font,, Cascadia Mono
    Gui, GPunishment:Add, Picture, x10 w500 h-1, C:\Users\maksy\OneDrive\Изображения\AnimeGirl(AHK).png
    Gui, GPunishment:Add, Button, x50 y320 w60, mute
    Gui, GPunishment:Add, Button, x120 y320 w60, v_mute
    Gui, GPunishment:Add, Button, x190 y320 w60, fmute
    Gui, GPunishment:Add, Button, x260 y320 w60, jail
    Gui, GPunishment:Add, Button, x330 y320 w60, warn
    Gui, GPunishment:Add, Button, x400 y320 w60, ban
    Gui, GPunishment:Add, Edit, x60 w400 h150 vPunishment
    Gui, GPunishment:Add, Button, Default x59 y510 w190, Скопировать
    Gui, GPunishment:Add, Button, x269 y510 w190, Назад
    Gui, GPunishment:Add, Button, x59 y540 w190, Очистить
    Gui, GPunishment:Add, Button, x269 y540 w190, Закрыть
    Gui, GPunishment:Add, Button, x59 y570 w400 gTitle, Создатьㅤзаголовокㅤдляㅤтемы
    Gui, GPunishment:Add, Text, x15 y320, | | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| |
    Gui, GPunishment:Add, Text, x475 y320, | | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| |
    Gui, GPunishment:Font, s7, Cascadia Mono
    Gui, GPunishment:Add, Link, x85, ≣≣≣≣≣ ❤ made by Maksyttaaa | <a href="https://vk.com/id410850476">https://vk.com/id410850476</a> ❤ ≣≣≣≣≣
    Gui, GPunishment:Show
    Return

    GPunishmentButtonmute:
        GuiControlGet, Punishment
        Gui, mute:New,, Меню выдачи наказаний: mute
        Gui, mute:Font, s15, Cascadia Mono
        Gui, mute:Add, Text, x90, Введите нужные данные.
        Gui, mute:Font, s10, Cascadia Mono
        Gui, mute:Add, Edit, x20 w120 vNick
        Gui, mute:Add, Edit, x20 w120 vTime
        Gui, mute:Add, Edit, x20 w120 vReason
        Gui, mute:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, mute:Add, Text, x150 y90, <- Введите время затычки чата.
        Gui, mute:Add, Text, x150 y125, <- Введите причину затычки чата.
        Gui, mute:Add, Button, Default x130 w150, Сохранить
        Gui, mute:Show
        Return

        muteButtonСохранить:
            Gui, mute:Hide
            GuiControlGet, Nick
            if (nick = "") {
                Return
            }
            GuiControlGet, Time
            if (time = "") {
                Return
            }
            GuiControlGet, Reason
            if (reason = "") {
                Return
            }
            if (Punishment = "") {
                punish := nick . " будет наказан mute'ом на " . time . " минут за " . reason . "."
            }
            else {
                punish := Punishment . "`n" . nick . " будет наказан mute'ом на " . time . " минут за " . reason . "."
            }
            GuiControl, GPunishment:, Punishment, % punish
            Return
        
    GPunishmentButtonv_mute:
        GuiControlGet, Punishment
        Gui, v_mute:New,, Меню выдачи наказаний: v_mute
        Gui, v_mute:Font, s15, Cascadia Mono
        Gui, v_mute:Add, Text, x130, Введите нужные данные.
        Gui, v_mute:Font, s10, Cascadia Mono
        Gui, v_mute:Add, Edit, x20 w120 vNick
        Gui, v_mute:Add, Edit, x20 w120 vTime
        Gui, v_mute:Add, Edit, x20 w120 vReason
        Gui, v_mute:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, v_mute:Add, Text, x150 y90, <- Введите время затычки голосового чата.
        Gui, v_mute:Add, Text, x150 y125, <- Введите причину затычки голосового чата.
        Gui, v_mute:Add, Button, Default x180 w150, Сохранить
        Gui, v_mute:Show
        Return

        v_muteButtonСохранить:
            Gui, v_mute:Hide
            GuiControlGet, Nick
            if (nick = "") {
                Return
            }
            GuiControlGet, Time
            if (time = "") {
                Return
            }
            GuiControlGet, Reason
            if (reason = "") {
                Return
            }
            if (Punishment = "") {
                punish := nick . " будет наказан v_mute'ом на " . time . " минут за " . reason . "."
            }
            else {
                punish := Punishment . "`n" . nick . " будет наказан v_mute'ом на " . time . " минут за " . reason . "."
            }
            GuiControl, GPunishment:, Punishment, % punish
            Return
        
    GPunishmentButtonfmute:
        GuiControlGet, Punishment
        Gui, fmute:New,, Меню выдачи наказаний: fmute
        Gui, fmute:Font, s15, Cascadia Mono
        Gui, fmute:Add, Text, x120, Введите нужные данные.
        Gui, fmute:Font, s10, Cascadia Mono
        Gui, fmute:Add, Edit, x20 w120 vNick
        Gui, fmute:Add, Edit, x20 w120 vTime
        Gui, fmute:Add, Edit, x20 w120 vReason
        Gui, fmute:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, fmute:Add, Text, x150 y90, <- Введите время полной затычки чата.
        Gui, fmute:Add, Text, x150 y125, <- Введите причину полной затычки чата.
        Gui, fmute:Add, Button, Default x160 w150, Сохранить 
        Gui, fmute:Show
        Return

        fmuteButtonСохранить:
            Gui, fmute:Hide
            GuiControlGet, Nick
            if (nick = "") {
                Return
            }
            GuiControlGet, Time
            if (time = "") {
                Return
            }
            GuiControlGet, Reason
            if (reason = "") {
                Return
            }
            if (Punishment = "") {
                punish := nick . " будет наказан fmute'ом на " . time . " минут за " . reason . "."
            }
            else {
                punish := Punishment . "`n" . nick . " будет наказан fmute'ом на " . time . " минут за " . reason . "."
            }
            GuiControl, GPunishment:, Punishment, % punish
            Return

    GPunishmentButtonjail:
        GuiControlGet, Punishment
        Gui, jail:New,, Меню выдачи наказаний: jail
        Gui, jail:Font, s15, Cascadia Mono
        Gui, jail:Add, Text, x170, Введите нужные данные.
        Gui, jail:Font, s10, Cascadia Mono
        Gui, jail:Add, Edit, x20 w120 vNick
        Gui, jail:Add, Edit, x20 w120 vTime
        Gui, jail:Add, Edit, x20 w120 vReason
        Gui, jail:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, jail:Add, Text, x150 y90, <- Введите время, которое игрок проведет в тюрьме.
        Gui, jail:Add, Text, x150 y125, <- Введите причину, по которой игрок попадет в тюрьму.
        Gui, jail:Add, Button, Default x220 w150, Сохранить 
        Gui, jail:Show
        Return

        jailButtonСохранить:
            Gui, jail:Hide
            GuiControlGet, Nick
            if (nick = "") {
                Return
            }
            GuiControlGet, Time
            if (time = "") {
                Return
            }
            GuiControlGet, Reason
            if (reason = "") {
                Return
            }
            if (Punishment = "") {
                punish := nick . " будет наказан jail'ом на " . time . " минут за " . reason . "."
            }
            else {
                punish := Punishment . "`n" . nick . " будет наказан jail'ом на " . time . " минут за " . reason . "."
            }
            GuiControl, GPunishment:, Punishment, % punish
            Return

    GPunishmentButtonwarn:
        GuiControlGet, Punishment
        Gui, warn:New,, Меню выдачи наказаний: warn
        Gui, warn:Font, s15, Cascadia Mono
        Gui, warn:Add, Text, x90, Введите нужные данные.
        Gui, warn:Font, s10, Cascadia Mono
        Gui, warn:Add, Edit, x20 w120 vNick
        Gui, warn:Add, Edit, x20 w120 vReason
        Gui, warn:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, warn:Add, Text, x150 y90, <- Введите причину предупреждения.
        Gui, warn:Add, Button, Default x130 w150, Сохранить 
        Gui, warn:Show
        Return

        warnButtonСохранить:
            Gui, warn:Hide
            GuiControlGet, Nick
            if (nick = "") {
                Return
            }
            GuiControlGet, Reason
            if (reason = "") {
                Return
            }
            if (Punishment = "") {
                punish := nick . " будет наказан warn'ом за " . reason . "."
            }
            else {
                punish := Punishment . "`n" . nick . " будет наказан warn'ом за " . reason . "."
            }
            GuiControl, GPunishment:, Punishment, % punish
            Return

    GPunishmentButtonban:
        GuiControlGet, Punishment
        Gui, ban:New,, Меню выдачи наказаний: ban
        Gui, ban:Font, s15, Cascadia Mono
        Gui, ban:Add, Text, x80, Введите нужные данные.
        Gui, ban:Font, s10, Cascadia Mono
        Gui, ban:Add, Edit, x20 w120 vNick
        Gui, ban:Add, Edit, x20 w120 vTime
        Gui, ban:Add, Edit, x20 w120 vReason
        Gui, ban:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, ban:Add, Text, x150 y90, <- Введите время блокировки.
        Gui, ban:Add, Text, x150 y125, <- Введите причину блокировки.
        Gui, ban:Add, Button, Default x130 w150, Сохранить 
        Gui, ban:Show
        Return

        banButtonСохранить:
            Gui, ban:Hide
            GuiControlGet, Nick
            if (nick = "") {
                Return
            }
            GuiControlGet, Time
            if (time = "") {
                Return
            }
            else if (time = "-1") {
                time := " навсегда"
            }
            else {
                if (time = 1 or time = 21) {
                    time := " на " . time . " день"
                }
                else if (time <= 4 or time >= 22 and time <= 24) {
                    time := " на " . time " дня"
                }
                else if (time >= 5 and time <= 20 or time >= 25 and time <= 30) {
                    time := " на " . time . " дней"
                }
            }
            GuiControlGet, Reason
            if (reason = "") {
                Return
            }
            if (Punishment = "") {
                punish := nick . " будет наказан ban'ом" . time . " за " . reason . "."
            }
            else {
                punish := Punishment . "`n" . nick . " будет наказан ban'ом" . time . " за " . reason . "."
            }
            GuiControl, GPunishment:, Punishment, % punish
            Return

    GPunishmentButtonСкопировать:
        GuiControlGet, Punishment
        clipboard := "[CENTER][FONT=Courier New]❤ Доброго времени суток! ❤`n" . "`n" . "[I]" . Punishment . "[/I]" . "`n" . "`n[COLOR=#b30000]Закрыто.[/COLOR] Приятной игры на [COLOR=#b3b300]RADMIR Role Play | Server 13[/COLOR] ❤[/FONT][/CENTER]"
        GuiControl, Text, Скопировать, ✅ Скопировано
        sleep 1300
        GuiControl, Text, ✅ Скопировано, Скопировать
        Return

    GPunishmentButtonОчистить:
        GuiControl, Text, Punishment
        GuiControl, Text, Очистить, ✅ Очищено!
        sleep 1300
        GuiControl, Text, ✅ Очищено!, Очистить
        Return

    GPunishmentButtonНазад:
        Gui, GPunishment:Hide
        Gui, Main:Show
        Return

    GPunishmentButtonЗакрыть:
        Gui, GPunishment:Hide
        Return
    
    Title:
        GuiControl, Text, Создатьㅤзаголовокㅤдляㅤтемы, ⇪ Создатьㅤзаголовокㅤдляㅤтемы ⇪
        Gui, title:New,, Меню выдачи наказаний: создание заголовка для темы
        Gui, title:Font, s15, Cascadia Mono
        Gui, title:Add, Text, x160, Введите нужные данные.
        Gui, title:Font, s10, Cascadia Mono
        Gui, title:Add, Edit, x25 w120 vNick, %nick%
        Gui, title:Add, Edit, x25 w120 vReason, %reason%
        Gui, title:Add, Edit, x25 w120 vNumb
        Gui, title:Add, Text, x150 y50, <- Введите ник игрока, на которого подана жалоба.
        Gui, title:Add, Text, x150 y90, <- Введите причину, по которой будет наказан игрок.
        Gui, title:Add, Text, x150 y125, <- Введите номер для этой жалобы.
        Gui, title:Add, Button, Default x80 w400, Скопировать
        Gui, title:Show
        sleep 1200
        GuiControl, GPunishment:, ⇪ Создатьㅤзаголовокㅤдляㅤтемы ⇪, Создатьㅤзаголовокㅤдляㅤтемы
        Return

        titleButtonСкопировать:
            GuiControlGet, Nick
            GuiControlGet, Reason
            GuiControlGet, Numb
            if (nick = "" or reason = "" or numb = "") {
                Return
            }
            clipboard := "Жалоба на игрока: " . nick . " | Причина: " . reason . " | " . numb
            Gui, title:hide
            Return

; Кнопка "Опровержение"

MainButtonОпровержение:
    Gui, Main:Hide
    Gui, GRefutation:New,, Меню проверки форума: запрос опровержения
    Gui, GRefutation:Font, s10, Cascadia Mono
    Gui, GRefutation:Add, Text, x100, ✧ ≡≡≡≡≡ Меню запроса опровержения ≡≡≡≡≡ ✧
    Gui, GRefutation:Font,, Cascadia Mono
    Gui, GRefutation:Add, Picture, x10 w500 h-1, C:\Users\maksy\OneDrive\Изображения\AnimeGirl(AHK).png
    Gui, GRefutation:Add, Edit, x20 w150 y320 vNick
    Gui, GRefutation:Add, Edit, x20 w150 y350 vReason
    Gui, GRefutation:Add, Text, x190 y320, <- Введите ник игрока.
    Gui, GRefutation:Add, Text, x190 y350, <- На что запросить опру?
    Gui, GRefutation:Add, Button, x50 w200 y380, Скопировать
    Gui, GRefutation:Add, Button, x260 w200 y380, Назад
    Gui, GRefutation:Add, Button, x50 w200 y410, Заголовок
    Gui, GRefutation:Add, Button, x260 w200 y410, Закрыть
    Gui, GRefutation:Font, s7, Cascadia Mono
    Gui, GRefutation:Add, Link, x85, ≣≣≣≣≣ ❤ made by Maksyttaaa | <a href="https://vk.com/id410850476">https://vk.com/id410850476</a> ❤ ≣≣≣≣≣
    Gui, GRefutation:Show
    Days = % A_DD + 2
    Date = %Days%.%A_MM%.%A_YYYY%
    Time = %A_Hour%:%A_Min%
    Return

    GRefutationButtonСкопировать:
        GuiControlGet, Nick
        GuiControlGet, Reason
        clipboard := "[CENTER][FONT=Times New Roman][I][B][SIZE=3]Доброго времени суток. ❤[/SIZE][/B][/I]`n" . "[I][B][SIZE=3][/SIZE][/B][/I]`n" . "[I][B][SIZE=3]У " . nick . " есть [U]48 часов[/U], чтобы прикрепить опровержение на [U]" . reason . "[/U].[/SIZE][/B][/I]`n" . "[I][B][SIZE=3]Составлять строго по указанной форме:[/SIZE][/B][/I]`n" . "[I][B][SIZE=3][/SIZE][/B][/I][/FONT][/CENTER]`n" . "[INDENT][INDENT][INDENT][INDENT][INDENT][LEFT][INDENT][LIST=1]`n" . "[*][FONT=Times New Roman][SIZE=3]Ваш никнейм:[/SIZE][/FONT]`n" . "[*][FONT=Times New Roman][SIZE=3]Скриншот вашей статистики (/mn + /c 060):[/SIZE][/FONT]`n" . "[*][FONT=Times New Roman][SIZE=3]Ссылка на опровержение (На нем должно быть /c 060):[/SIZE][/FONT]`n" . "[*][FONT=Times New Roman][SIZE=3]Комментарий (Не обязательно):[/SIZE][/FONT]`n" . "[/LIST][/INDENT][/LEFT][/INDENT][/INDENT][/INDENT][/INDENT][/INDENT]`n" . "[CENTER][FONT=Times New Roman][I][B][SIZE=3][/SIZE][/B][/I]`n" . "[I][B][SIZE=3]В случае отсутствия доказательств " . date . " в " . time . " сотрудник будет наказан.[/SIZE][/B][/I]`n" . "[SPOILER=""Пункт из RadmirRP |  Правила для гос. структур""]`n" . "[I][B][FONT=Times New Roman][SIZE=3]Каждый сотрудник ДПС/ППС/ФСИН обязан записывать видео нарушения игроков перед выдачей звезд/повышении срока/убийством нарушителей, в случае подачи жалобы на сотрудника у него будет 3 дня на предоставление доказательств в определенной теме, если сотрудник гос. структуры проигнорирует, его накажут варном.[/FONT][/SIZE][/B][/I]`n" . "[/SPOILER][/FONT][/CENTER]"
        GuiControl, Text, Скопировать, ✅ Скопировано
        sleep 1300
        GuiControl, Text, ✅ Скопировано, Скопировать
        Return
    
    GRefutationButtonЗаголовок:
        GuiControlGet, Nick
        clipboard := "Ожидаю опровержение от: " . Nick . " | Истечение: " . Date . " в " . Time . "."
        GuiControl, Text, Заголовок, ✅ Скопировано
        sleep 1300
        GuiControl, Text, ✅ Скопировано, Заголовок
        Return
    
    GRefutationButtonНазад:
        Gui, GRefutation:Hide
        Gui, Main:Show
        Return
    
    GRefutationButtonЗакрыть:
        Gui, GRefutation:Hide
        Return

MainButtonВыдача:
    Gui, Main:Hide
    Gui, GIssuing:New,, Меню проверки форума: список выдачи наказаний
    Gui, GIssuing:Font, s10, Cascadia Mono
    Gui, GIssuing:Add, Text, x70, ✧ ≡≡≡≡≡ Меню создания списка выдачи наказаний ≡≡≡≡≡ ✧
    Gui, GIssuing:Font,, Cascadia Mono
    Gui, GIssuing:Add, Picture, x10 w500 h-1, C:\Users\maksy\OneDrive\Изображения\AnimeGirl(AHK).png
    Gui, GIssuing:Add, Button, x50 y320 w60, mute
    Gui, GIssuing:Add, Button, x120 y320 w60, v_mute
    Gui, GIssuing:Add, Button, x190 y320 w60, fmute
    Gui, GIssuing:Add, Button, x260 y320 w60, jail
    Gui, GIssuing:Add, Button, x330 y320 w60, warn
    Gui, GIssuing:Add, Button, x400 y320 w60, ban
    Gui, GIssuing:Add, Edit, x60 w400 h150 vPunishment
    Gui, GIssuing:Add, Button, Default x59 y510 w190, Скопировать
    Gui, GIssuing:Add, Button, x269 y510 w190, Назад
    Gui, GIssuing:Add, Button, x59 y540 w190, Очистить
    Gui, GIssuing:Add, Button, x269 y540 w190, Закрыть
    Gui, GIssuing:Add, Text, x15 y320, | | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| |
    Gui, GIssuing:Add, Text, x475 y320, | | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| | `n| |
    Gui, GIssuing:Font, s7, Cascadia Mono
    Gui, GIssuing:Add, Link, x85, ≣≣≣≣≣ ❤ made by Maksyttaaa | <a href="https://vk.com/id410850476">https://vk.com/id410850476</a> ❤ ≣≣≣≣≣
    Gui, GIssuing:Show
    Return

    GIssuingButtonmute:
        GuiControlGet, Punishment
        Gui, Lmute:New,, Меню списка выдачи наказаний: mute
        Gui, Lmute:Font, s15, Cascadia Mono
        Gui, Lmute:Add, Text, x130, Введите нужные данные.
        Gui, Lmute:Font, s10, Cascadia Mono
        Gui, Lmute:Add, Edit, x20 w120 vNick
        Gui, Lmute:Add, Edit, x20 w120 vTime
        Gui, Lmute:Add, Edit, x20 w120 vReason
        Gui, Lmute:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, Lmute:Add, Text, x150 y90, <- Введите время затычки чата.
        Gui, Lmute:Add, Text, x150 y125, <- Введите номер жалобы.
        Gui, Lmute:Add, CheckBox, x25 y155 vKick, Кикать игроков при выдаче (Если в сети)
        Gui, Lmute:Add, Button, x10 y180 gNeSost, Жб на не сост.
        Gui, Lmute:Add, Button, x135 y180 gSostGos, Жб на сост в гос.
        Gui, Lmute:Add, Button, x285 y180 gMVD, Жб на МВД.
        Gui, Lmute:Add, Button, x380 y180 gGangs, Жб на банды.
        Gui, Lmute:Add, Button, x11 w477 y212, Закрыть
        Gui, Lmute:Show
        Return

        NeSost:
            Gui, Lmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := "/mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        SostGos:
            Gui, Lmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := "/mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        MVD:
            Gui, Lmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := "/mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        Gangs:
            Gui, Lmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/mute " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := "/mute " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/mute " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/mute " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        LmuteButtonЗакрыть:
            Gui, Lmute:Hide
            Return
        
    GIssuingButtonv_mute:
        GuiControlGet, Punishment
        Gui, Lv_mute:New,, Меню выдачи наказаний: v_mute
        Gui, Lv_mute:Font, s15, Cascadia Mono
        Gui, Lv_mute:Add, Text, x130, Введите нужные данные.
        Gui, Lv_mute:Font, s10, Cascadia Mono
        Gui, Lv_mute:Add, Edit, x20 w120 vNick
        Gui, Lv_mute:Add, Edit, x20 w120 vTime
        Gui, Lv_mute:Add, Edit, x20 w120 vReason
        Gui, Lv_mute:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, Lv_mute:Add, Text, x150 y90, <- Введите время затычки голосового чата.
        Gui, Lv_mute:Add, Text, x150 y125, <- Введите номер жалобы.
        Gui, Lv_mute:Add, CheckBox, x25 y155 vKick, Кикать игроков при выдаче (Если в сети)
        Gui, Lv_mute:Add, Button, x10 y180 gNeSost2, Жб на не сост.
        Gui, Lv_mute:Add, Button, x135 y180 gSostGos2, Жб на сост в гос.
        Gui, Lv_mute:Add, Button, x285 y180 gMVD2, Жб на МВД.
        Gui, Lv_mute:Add, Button, x380 y180 gGangs2, Жб на банды.
        Gui, Lv_mute:Add, Button, x11 w477 y212, Закрыть
        Gui, Lv_mute:Show
        Return

        NeSost2:
            Gui, Lv_mute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/v_mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := "/v_mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/v_mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/v_mute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        SostGos2:
            Gui, Lv_mute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/v_mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := "/v_mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/v_mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/v_mute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        MVD2:
            Gui, Lv_mute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/v_mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := "/v_mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/v_mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/v_mute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        Gangs2:
            Gui, Lv_mute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/v_mute " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := "/v_mute " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/v_mute " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/v_mute " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        Lv_muteButtonЗакрыть:
            Gui, Lv_mute:Hide
            Return
        
    GIssuingButtonfmute:
        GuiControlGet, Punishment
        Gui, Lfmute:New,, Меню выдачи наказаний: fmute
        Gui, Lfmute:Font, s15, Cascadia Mono
        Gui, Lfmute:Add, Text, x130, Введите нужные данные.
        Gui, Lfmute:Font, s10, Cascadia Mono
        Gui, Lfmute:Add, Edit, x20 w120 vNick
        Gui, Lfmute:Add, Edit, x20 w120 vTime
        Gui, Lfmute:Add, Edit, x20 w120 vReason
        Gui, Lfmute:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, Lfmute:Add, Text, x150 y90, <- Введите время полной затычки чата.
        Gui, Lfmute:Add, Text, x150 y125, <- Введите номер жалобы.
        Gui, Lfmute:Add, CheckBox, x25 y155 vKick, Кикать игроков при выдаче (Если в сети)
        Gui, Lfmute:Add, Button, x10 y180 gNeSost3, Жб на не сост.
        Gui, Lfmute:Add, Button, x135 y180 gSostGos3, Жб на сост в гос.
        Gui, Lfmute:Add, Button, x285 y180 gMVD3, Жб на МВД.
        Gui, Lfmute:Add, Button, x380 y180 gGangs3, Жб на банды.
        Gui, Lfmute:Add, Button, x11 w477 y212, Закрыть
        Gui, Lfmute:Show
        Return

        NeSost3:
            Gui, Lfmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/fmute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := "/fmute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/fmute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/fmute " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        SostGos3:
            Gui, Lfmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/fmute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := "/fmute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/fmute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/fmute " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        MVD3:
            Gui, Lfmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/fmute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := "/fmute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/fmute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/fmute " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        Gangs3:
            Gui, Lfmute:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/fmute " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := "/fmute " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/fmute " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/fmute " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        LfmuteButtonЗакрыть:
            Gui, Lfmute:Hide
            Return

    GIssuingButtonjail:
        GuiControlGet, Punishment
        Gui, Ljail:New,, Меню выдачи наказаний: jail
        Gui, Ljail:Font, s15, Cascadia Mono
        Gui, Ljail:Add, Text, x160, Введите нужные данные.
        Gui, Ljail:Font, s10, Cascadia Mono
        Gui, Ljail:Add, Edit, x20 w120 vNick
        Gui, Ljail:Add, Edit, x20 w120 vTime
        Gui, Ljail:Add, Edit, x20 w120 vReason
        Gui, Ljail:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, Ljail:Add, Text, x150 y90, <- Введите время, которое игрок проведет в тюрьме.
        Gui, Ljail:Add, Text, x150 y125, <- Введите номер жалобы.
        Gui, Ljail:Add, CheckBox, x25 y155 vKick, Кикать игроков при выдаче (Если в сети)
        Gui, Ljail:Add, Button, x40 y180 gNeSost4, Жб на не сост.
        Gui, Ljail:Add, Button, x165 y180 gSostGos4, Жб на сост в гос.
        Gui, Ljail:Add, Button, x315 y180 gMVD4, Жб на МВД.
        Gui, Ljail:Add, Button, x410 y180 gGangs4, Жб на банды.
        Gui, Ljail:Add, Button, x41 w477 y212, Закрыть
        Gui, Ljail:Show
        Return

        NeSost4:
            Gui, Ljail:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offjail " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := "/offjail " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offjail " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offjail " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        SostGos4:
            Gui, Ljail:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offjail " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := "/offjail " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offjail " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offjail " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        MVD4:
            Gui, Ljail:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offjail " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := "/offjail " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offjail " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offjail " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        Gangs4:
            Gui, Ljail:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offjail " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := "/offjail " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offjail " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offjail " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        LjailButtonЗакрыть:
            Gui, Ljail:Hide
            Return

    GIssuingButtonwarn:
        GuiControlGet, Punishment
        Gui, Lwarn:New,, Меню выдачи наказаний: warn
        Gui, Lwarn:Font, s15, Cascadia Mono
        Gui, Lwarn:Add, Text, x130, Введите нужные данные.
        Gui, Lwarn:Font, s10, Cascadia Mono
        Gui, Lwarn:Add, Edit, x20 w120 vNick
        Gui, Lwarn:Add, Edit, x20 w120 vReason
        Gui, Lwarn:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, Lwarn:Add, Text, x150 y90, <- Введите номер жалобы.
        Gui, Lwarn:Add, CheckBox, x25 y120 vKick, Кикать игроков при выдаче (Если в сети)
        Gui, Lwarn:Add, Button, x10 y150 gNeSost5, Жб на не сост.
        Gui, Lwarn:Add, Button, x135 y150 gSostGos5, Жб на сост в гос.
        Gui, Lwarn:Add, Button, x285 y150 gMVD5, Жб на МВД.
        Gui, Lwarn:Add, Button, x380 y150 gGangs5, Жб на банды.
        Gui, Lwarn:Add, Button, x11 w477 y182, Закрыть
        Gui, Lwarn:Show
        Return

        NeSost5:
            Gui, Lwarn:Submit
            GuiControlGet, Nick
            GuiControlGet, Reason
            if (Nick = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offwarn " . nick . " Жалоба на не сост. #" . reason
                }
                else {
                    punish := "/offwarn " . nick . " Жалоба на не сост. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offwarn " . nick . " Жалоба на не сост. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offwarn " . nick . " Жалоба на не сост. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        SostGos5:
            Gui, Lwarn:Submit
            GuiControlGet, Nick
            GuiControlGet, Reason
            if (Nick = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offwarn " . nick . " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := "/offwarn " . nick . " Жалоба на сост. в гос. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offwarn " . nick . " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offwarn " . nick . " Жалоба на сост. в гос. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        MVD5:
            Gui, Lwarn:Submit
            GuiControlGet, Nick
            GuiControlGet, Reason
            if (Nick = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offwarn " . nick . " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := "/offwarn " . nick . " Жалоба на сотрудника МВД #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offwarn " . nick . " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offwarn " . nick . " Жалоба на сотрудника МВД #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        Gangs5:
            Gui, Lwarn:Submit
            GuiControlGet, Nick
            GuiControlGet, Reason
            if (Nick = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/offwarn " . nick . " Жалоба на банды #" . reason
                }
                else {
                    punish := "/offwarn " . nick . " Жалоба на банды #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/offwarn " . nick . " Жалоба на банды #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/offwarn " . nick . " Жалоба на банды #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        LwarnButtonЗакрыть:
            Gui, Lwarn:Hide
            Return

    GIssuingButtonban:
        GuiControlGet, Punishment
        Gui, Lban:New,, Меню выдачи наказаний: ban
        Gui, Lban:Font, s15, Cascadia Mono
        Gui, Lban:Add, Text, x130, Введите нужные данные.
        Gui, Lban:Font, s10, Cascadia Mono
        Gui, Lban:Add, Edit, x20 w120 vNick
        Gui, Lban:Add, Edit, x20 w120 vTime
        Gui, Lban:Add, Edit, x20 w120 vReason
        Gui, Lban:Add, Text, x150 y50, <- Введите ник нарушителя.
        Gui, Lban:Add, Text, x150 y90, <- Введите время блокировки.
        Gui, Lban:Add, Text, x150 y125, <- Введите номер жалобы.
        Gui, Lban:Add, CheckBox, x25 y155 vKick, Кикать игроков при выдаче (Если в сети)
        Gui, Lban:Add, Button, x10 y180 gNeSost6, Жб на не сост.
        Gui, Lban:Add, Button, x135 y180 gSostGos6, Жб на сост в гос.
        Gui, Lban:Add, Button, x285 y180 gMVD6, Жб на МВД.
        Gui, Lban:Add, Button, x380 y180 gGangs6, Жб на банды.
        Gui, Lban:Add, Button, x11 w477 y212, Закрыть
        Gui, Lban:Show
        Return

        NeSost6:
            Gui, Lban:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/soffban " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := "/soffban " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/soffban " . nick . " " . time " Жалоба на не сост. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/soffban " . nick . " " . time " Жалоба на не сост. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        SostGos6:
            Gui, Lban:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/soffban " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := "/soffban " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/soffban " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/soffban " . nick . " " . time " Жалоба на сост. в гос. #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        MVD6:
            Gui, Lban:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/soffban " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := "/soffban " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/soffban " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/soffban " . nick . " " . time " Жалоба на сотрудника МВД #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return

        Gangs6:
            Gui, Lban:Submit
            GuiControlGet, Nick
            GuiControlGet, Time
            GuiControlGet, Reason
            if (Nick = "" or Time = "" or Reason = "") {
                Return
            }
            if (Punishment = "") {
                if (Kick) {
                    punish := "{kick}" . "/soffban " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := "/soffban " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            else {
                if (Kick) {
                    punish := Punishment . "`n" . "{kick}" . "/soffban " . nick . " " . time " Жалоба на банды #" . reason
                }
                else {
                    punish := Punishment . "`n" . "/soffban " . nick . " " . time " Жалоба на банды #" . reason
                }
            }
            GuiControl, GIssuing:, Punishment, % punish
            Return
        
        LbanButtonЗакрыть:
            Gui, Lban:Hide
            Return

    GIssuingButtonСкопировать:
        GuiControlGet, Punishment
        clipboard := Punishment
        GuiControl, Text, Скопировать, ✅ Скопировано
        sleep 1300
        GuiControl, Text, ✅ Скопировано, Скопировать
        Return

    GIssuingButtonОчистить:
        GuiControl, Text, Punishment
        GuiControl, Text, Очистить, ✅ Очищено!
        sleep 1300
        GuiControl, Text, ✅ Очищено!, Очистить
        Return

    GIssuingButtonНазад:
        Gui, GIssuing:Hide
        Gui, Main:Show
        Return

    GIssuingButtonЗакрыть:
        Gui, GIssuing:Hide
        Return

; Кнопка "Закрыть"

MainButtonЗакрыть:
    Gui, Main:Hide
    Return
;====================================================================================================================================================

;====================================================================================================================================================

;--- Мероприятие "Выживание"
:?:!Выживание:: ; Выдать себе оружие
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 1 1{Enter}
Sleep 400
SendInput, {F6}/tp{Enter}
Sleep 400
SendInput, {Enter}
Sleep 400
SendInput, {F6}/mp_team 2{Enter}
Sleep 400
SendInput, {F6}/mp_gun 1 24 777{Enter}
Sleep 400
SendInput, {F6}/mp_gun 1 31 3333{Enter}
Return

:?:!Выживание_оруж:: ; Выдать другим оружие
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_team 2{Enter}
Sleep 400
SendInput, {F6}/mp_gun 1 24 777{Enter}
Sleep 400
SendInput, {F6}/mp_gun 1 31 3333{Enter}
Sleep 400
SendInput, {F6}/mp_gun 2 24 777{Enter}
Sleep 400
SendInput, {F6}/mp_gun 2 31 3333{Enter}
Return

:?:!Выживание1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 1 2{Enter}
Sleep 400
SendInput, {F6}/mp_tp 100 1{Enter}
Sleep 400
SendInput, {F6}/msg [MP] Уважаемые игроки, минуточку внимания.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Проходит набор на участие в Мероприятии "Выживание"{Enter}
;Sleep 2100
;SendInput, {F6}/msg [MP] Призовой фонд победителю: 25.000 руб{!}{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Желающие поучаствовать вводите /tp{!} Количество мест: 100.{Enter}
Return

:?:!Выживание2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 100 2{Enter}
Sleep 400
SendInput, {F6}/msg [MP] Точка телепортации более неактивна.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Игрокам на Мероприятии советую разбежаться по территории.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Через несколько секунд начнется игра на Выживание{!} Желаю удачи.{Enter}
Return


; --- Мероприятие "Counter Strike"
:?:!кс_мп::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 50 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Уважаемые игроки минуточку внимания.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Проходит набор на участие в Мероприятии "Counter Strike"{Enter}
;Sleep 2100
;SendInput, {F6}/msg [MP] Призовой фонд победителю: 25.000 руб{!}{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Желающие поучаствовать вводите /tp{!} Количество мест: 50.{Enter}
Return

:?:!кс_мп1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 50 2{Enter}
Sleep 400
SendInput, {F6}/mp_freeze 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Точка телепортации более неактивна.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Игрокам на Мероприятии приготовиться.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Через несколько секунд начнется игра{!} Желаю удачи.{Enter}
sleep 550
SendInput, {F6}/mp_team 2{Enter}
Sleep 550
SendInput, {F6}/mp_gun 1 24 35{Enter}
Sleep 550
SendInput, {F6}/mp_gun 1 31 150{Enter}
Sleep 550
SendInput, {F6}/mp_gun 2 24 35{Enter}
Sleep 550
SendInput, {F6}/mp_gun 2 31 150{Enter}
Sleep 800
SendInput, {F6}/mp_skin 1 30{Enter}
Sleep 800
SendInput, {F6}/mp_skin 2 3{Enter}
Return

:?:!кс_раунд::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /msg [MP] Перераспределение команд...{Enter}
Sleep 550
SendInput, {F6}/mp_team 2{Enter}
Sleep 550
SendInput, {F6}/mp_gun 1 24 35{Enter}
Sleep 550
SendInput, {F6}/mp_gun 1 31 150{Enter}
Sleep 550
SendInput, {F6}/mp_gun 2 24 35{Enter}
Sleep 550
SendInput, {F6}/mp_gun 2 31 150{Enter}
Sleep 800
SendInput, {F6}/mp_skin 1 30{Enter}
Sleep 800
SendInput, {F6}/mp_skin 2 3{Enter}
Return

; --- Мероприятие "Король Desert Eagle"
:?:!король_дигла::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 100 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Уважаемые игроки минуточку внимания.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Проходит набор на участие в Мероприятии "Король Desert Eagle"{Enter}
;Sleep 2100
;SendInput, {F6}/msg [MP] Призовой фонд победителю: 25.000 руб{!}{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Желающие поучаствовать вводите /tp{!} Количество мест: 100.{Enter}
Return

:?:!король_дигла1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 100 2{Enter}
Sleep 400
SendInput, {F6}/mp_freeze 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Точка телепортации более неактивна.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Игрокам на Мероприятии приготовиться.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Через несколько секунд начнется игра{!} Желаю удачи.{Enter}
sleep 550
SendInput, {F6}/mp_team 2{Enter}
Sleep 550
SendInput, {F6}/mp_gun 1 24 70{Enter}
Sleep 550
SendInput, {F6}/mp_gun 2 24 70{Enter}
Sleep 550
SendInput, {F6}/mp_skin 1 86{Enter}
Sleep 800
SendInput, {F6}/mp_skin 2 86{Enter}
Return

; --- Мероприятие "Король M4"
:?:!король_м4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 100 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Уважаемые игроки минуточку внимания.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Проходит набор на участие в Мероприятии "Король M4"{Enter}
;Sleep 2100
;SendInput, {F6}/msg [MP] Призовой фонд победителю: 25.000 руб{!}{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Желающие поучаствовать вводите /tp{!} Количество мест: 100.{Enter}
Return

:?:!король_м41::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 100 2{Enter}
Sleep 400
SendInput, {F6}/mp_freeze 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Точка телепортации более неактивна.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Игрокам на Мероприятии приготовиться.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Через несколько секунд начнется игра{!} Желаю удачи.{Enter}
sleep 550
SendInput, {F6}/mp_team 2{Enter}
Sleep 550
SendInput, {F6}/mp_gun 1 31 500{Enter}
Sleep 550
SendInput, {F6}/mp_gun 2 31 500{Enter}
Sleep 550
SendInput, {F6}/mp_skin 1 86{Enter}
Sleep 800
SendInput, {F6}/mp_skin 2 86{Enter}
Return

; --- Мероприятие "Догони администратора"
:?:!догони_адм::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 7 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Уважаемые игроки минуточку внимания.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Проходит набор на участие в Мероприятии "Догони администратора"{Enter}
;Sleep 2100
;SendInput, {F6}/msg [MP] Призовой фонд победителю: 25.000 руб{!}{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Желающие поучаствовать вводите /tp{!} Количество мест: 7.{Enter}
Return

:?:!догони_адм1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 7 2{Enter}
Sleep 400
SendInput, {F6}/mp_freeze 1{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Точка телепортации более неактивна.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Игрокам на Мероприятии приготовиться.{Enter}
Sleep 2100
SendInput, {F6}/msg [MP] Следуйте инструкциям проводящего{!} Желаю удачи.{Enter}
sleep 550
SendInput, {F6}/mp_team 3{Enter}
Sleep 550
SendInput, {F6}/mp_skin 1 98{Enter}
Sleep 800
SendInput, {F6}/mp_skin 2 98{Enter}
Sleep 800
SendInput, {F6}/mp_skin 3 98{Enter}
Return


:?:!!кар1::/veh 533 136 136 0 0 0{Enter}
:?:!!кар2::/veh 15175 136 136 1 1 1{Enter}


:?:!!мп_тп::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_get 1{enter}
SendInput, {f6}/mp_get 2{enter}
SendInput, {f6}/mp_get 3{enter}
SendInput, {f6}/mp_get 4{enter}
Return

; --- Конец мероприятия
:?:!Конец_мп::
SendMessage, 0x50,, 0x4190419,, A
SendInput, /mp_tp 1 1{Enter}
Sleep 400
SendInput, {F6}/mp_end{Enter}
Sleep 400
SendInput, {F6}/mp_tp 1 2{Enter}
Sleep 400
SendInput, {F6}/msg [MP] Победителем мероприятия стал {!} Поздравим его.{left 16}
Return

;====================================================================================================================================================