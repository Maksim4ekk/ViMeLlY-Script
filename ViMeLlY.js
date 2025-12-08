const teleportCommands = [
    { cmd: "/tc", pos: "/pos 3237.419,-34.286,5.718", label: "Торговый Центр" },
    { cmd: "/kaz1", pos: "/pos 1922.009,-1943.568,32.123", label: "Казино г.Южный" },
    { cmd: "/kaz2", pos: "/pos -2198.302,-300.226,23.819", label: "Казино г.Лыткарино" },
    { cmd: "/sto1", pos: "/pos -309.136,321.007,13.493", label: "СТО г.Арзамас" },
    { cmd: "/sto2", pos: "/pos 2158.888,-1833.998,19.155", label: "СТО г.Южный" },
    { cmd: "/sto3", pos: "/pos -2522.404,1110.744,9.101", label: "СТО г.Лыткарино" },
    { cmd: "/ferma1", pos: "/pos 1624.242,664.231,16.252", label: "Ферма пгт.Батырево" },
    { cmd: "/ferma2", pos: "/pos -1151.839,-858.596,51.486", label: "Ферма пгт.Бусаево" },
    { cmd: "/os1", pos: "/pos -3227.146,831.302,6.793", label: "Западный Особняк" },
    { cmd: "/os2", pos: "/pos 4044.197,3806.151,6.710", label: "Северный Особняк" },
    { cmd: "/os3", pos: "/pos 2312.244,1531.557,11.625", label: "База Паши Пэла" },
    { cmd: "/os4", pos: "/pos 1951.199,15.470,8.439", label: "Центральный особняк" },
    { cmd: "/br1", pos: "/pos 2709.736,-2449.409,22.157", label: "БУ среднего" },
    { cmd: "/br2", pos: "/pos -1908.622,1912.594,175.589", label: "БУ высокого" }
];

let sendCommands = window.sendChatInput
window.sendChatInput = function(message) {
    let args = message.split(" ")
    const teleport = teleportCommands.find(t => t.cmd === args[0]);
    if (teleport) {
        sendChatInput(teleport.pos);
        hudMsg(`Телепортируемся к "${teleport.label}"`);
    } if (args[0] === "/ldmsg") {
        const messages = [
            "Устал быть просто игроком? Время взять игру в свои руки!",
            "Лидер — это не просто статус, а возможность управлять судьбой команды.",
            "Ты будешь принимать решения, вести организацию к успеху и строить стратегию.",
            "Настоящий лидер не следует за толпой — он сам создаёт правила.",
            "Докажи, что ты достоин этого поста и сможешь привести всех к победе!",
            "Не упускай возможность! Чтобы подать заявку, переходи:",
            "https://forum.radmir.games/ → RADMIR RolePlay | Сервер: 01 → Заявления на пост лидера"
        ];
        const actions = messages.map(text => () => window.sendChatInput(`/msg ${text}`));
        callWithDelay(actions, 2000);
        return;
    } if (args[0] === "/supmsg") {
        const messages = [
            "Уважаемые игроки, прошу минуточку внимания...",
            "На данный момент открыты заявления на пост \"Агент поддержки\"",
            "Какие преимущества у этой должности? Их множество!",
            "От слежки за порядком на сервере до получения реальных денег.",
            "Критерии: возраст 13 +; 8+ уровень; VK страница, которой больше года; доступ к Discord;",
            "Критерии: знание RP терминов; команд, /gps сервера; адекватность, грамотность.",
            "Чтобы вступить в ряды Агентов поддержки, переходи:",
            "https://forum.radmir.games/ → RADMIR RolePlay | Сервер: 01 → Заявления на пост саппорта"
        ];
        const actions = messages.map(text => () => window.sendChatInput(`/msg ${text}`));
        callWithDelay(actions, 2000);
        return;
    } if (args[0] === "/promo") {
        if (args.length < 2) {
            hudMsg(`Использование: ${args[0]} <Промокод>. Пример: /promo RADMIR`)
            return;
        } else {
            sendChatInput(`/msg [PROMO] Доступен новый промокод ${args[1]}, используйте его через /pcode.`)
            return;
        }
    }
	sendCommands.call(this, message)
}

function hudMsg(text) {
    window.interface("Hud")?.$refs?.chat?.add(`{ff00ff}[ViMeLlY] {ffffff} ${text}`, "FFFFFF");
}

function callWithDelay(actions, delay) {
    let total = 0;
    actions.forEach(action => {
        if (typeof action === "function") {
            setTimeout(action, total);
            total += delay;
        }
    });
}
