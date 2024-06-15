if not isServer() then
    return
end
local PhunInfo = PhunInfo

local function buildInfos(data)
    local result = {}
    local ordinal = 1
    for _, v in ipairs(data) do
        local formatted = {
            type = v.type or "text",
            value = v.value,
            title = v.title or nil,
            sticky = v.sticky == true,
            icon = v.icon or nil,
            ordinal = v.ordinal or ordinal,
            backgroundImage = v.backgroundImage or nil,
            backgroundColour = v.backgroundColour or nil,
            onclick = v.onclick or nil
        }
        ordinal = ordinal + 1
        table.insert(result, formatted)
        table.sort(result, function(a, b)
            if a.sticky and not b.sticky then
                return true
            elseif not a.sticky and b.sticky then
                return false
            elseif a.sticky and b.sticky then
                return a.ordinal < b.ordinal
            else
                return a.ordinal < b.ordinal
            end
        end)
    end
    return result
end

function PhunInfo:reload()

    local data = PhunTools:loadTable("PhunInfo.lua")
    local infos = buildInfos(data)
    if infos then
        self.infos = infos
    end
    return infos
end

local Commands = {}

Commands[PhunInfo.commands.requestData] = function(playerObj, arguments)
    sendServerCommand(playerObj, PhunInfo.name, PhunInfo.commands.requestData, {
        playerIndex = playerObj:getPlayerNum(),
        playerName = playerObj:getUsername(),
        infos = PhunInfo.infos
    })
end

Commands[PhunInfo.commands.reload] = function(playerObj, arguments)
    PhunInfo:reload()
    sendServerCommand(playerObj, PhunInfo.name, PhunInfo.commands.requestData, {
        playerIndex = playerObj:getPlayerNum(),
        playerName = playerObj:getUsername(),
        infos = PhunInfo.infos
    })
end

Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
    if module == PhunInfo.name and Commands[command] then
        Commands[command](playerObj, arguments)
    end
end)
Events.OnGameStart.Add(function()

end)

Events.OnCharacterDeath.Add(function(playerObj)

end)

Events.OnInitGlobalModData.Add(function()
    PhunInfo:ini()
    PhunInfo:reload()
end)

Events.EveryTenMinutes.Add(function()

end)

Events.EveryHours.Add(function()

end)
