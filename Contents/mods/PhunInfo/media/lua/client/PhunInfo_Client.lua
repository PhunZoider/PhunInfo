if isServer() then
    return
end
local PhunInfo = PhunInfo

local function setup()
    Events.EveryOneMinute.Remove(setup)
    for i = 1, getOnlinePlayers():size() do
        local p = getOnlinePlayers():get(i - 1)
        if p:isLocalPlayer() then
            PhunInfoUI.OnOpenPanel(p)
        end
    end
    sendClientCommand(PhunInfo.name, PhunInfo.commands.requestData, {})
end

local Commands = {}

Commands[PhunInfo.commands.requestData] = function(arguments)
    PhunInfo.infos = arguments.infos
    triggerEvent(PhunInfo.events.OnPhunInfosReceived, arguments)
end

Events.EveryOneMinute.Add(setup)

Events.OnServerCommand.Add(function(module, command, arguments)
    if module == PhunInfo.name and Commands[command] then
        Commands[command](arguments)
    end
end)

Events[PhunStats.events.OnPhunStatsClientReady].Add(function()
    for _, v in ipairs(PhunInfoUI.instances) do
        if v and v.rebuild then
            v:rebuild()
        end
    end
end)

Events[PhunZones.events.OnPhunZoneWidgetClicked].Add(function(playerObj)
    PhunInfoUI.OnOpenPanel(playerObj)
end)

