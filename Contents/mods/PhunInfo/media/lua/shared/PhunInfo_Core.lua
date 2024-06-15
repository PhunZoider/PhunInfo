PhunInfo = {
    inied = false,
    name = "PhunInfo",
    commands = {
        dataLoaded = "dataLoaded",
        reload = "reload",
        requestData = "requestData"
    },
    infos = {},
    players = {},
    events = {
        OnPhunInfoChanged = "OnPhunInfoChanged",
        OnPhunInfoCurrenciesUpdated = "OnPhunInfoCurrenciesUpdated",
        OnPhunInfoInied = "OnPhunInfoInied",
        OnPhunInfosReceived = "OnPhunInfosReceived"
    },
    clickCommands = {}
}

PhunInfo.clickCommands["discordUrl"] = function()
    Clipboard.setClipboard("https://discord.gg/v2USyAtP6q");
    local w = 300
    local h = 150
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, "Copied to your clipboard", false, nil, nil, nil);
    modal:initialise()
    modal:addToUIManager()
end

for _, event in pairs(PhunInfo.events) do
    if not Events[event] then
        LuaEventManager.AddEvent(event)
    end
end

function PhunInfo:ini()
    if not self.inied then
        self.inied = true
        triggerEvent(self.events.OnPhunInfoInied)
    end
end
