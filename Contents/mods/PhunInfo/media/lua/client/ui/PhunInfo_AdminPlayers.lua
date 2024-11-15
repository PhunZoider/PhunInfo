PhunInfoAdminPlayersUI = ISPanel:derive("PhunInfoAdminPlayersUI");
PhunInfoAdminPlayersUI.instance = nil;

local PhunTools = PhunTools
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function PhunInfoAdminPlayersUI.OnOpenPanel(item)
    if isAdmin() then
        if PhunInfoAdminPlayersUI.instance == nil then
            PhunInfoAdminPlayersUI.instance = PhunInfoAdminPlayersUI:new(100, 100, 400, 400, item, getPlayer());
            PhunInfoAdminPlayersUI.instance:initialise();
            PhunInfoAdminPlayersUI.instance:instantiate();
        else
            PhunInfoAdminPlayersUI.instance.item = item;
        end

        PhunInfoAdminPlayersUI.instance:addToUIManager();
        PhunInfoAdminPlayersUI.instance:setVisible(true);

        return PhunInfoAdminPlayersUI.instance;
    end
end

local function getLabel(text, x, y, w, h)
    local lbl = ISLabel:new(x, y, FONT_HGT_MEDIUM, text, 1, 1, 1, 1, UIFont.medium, true)
    lbl:initialise();
    lbl:instantiate();
    return lbl
end

function PhunInfoAdminPlayersUI:createChildren()
    ISPanel.createChildren(self);

    local x = 10
    local y = 10
    local h = FONT_HGT_MEDIUM;
    local w = self.width - 20;
    self.title = ISLabel:new(x, y, h, "Tools", 1, 1, 1, 1, UIFont.Medium, true);
    self.title:initialise();
    self.title:instantiate();
    self:addChild(self.title);

    self.closeButton = ISButton:new(self.width - 25 - x, y, 25, 25, "X", self, function()
        PhunInfoAdminPlayersUI.OnOpenPanel():close()
    end);
    self.closeButton:initialise();
    self:addChild(self.closeButton);

    y = y + h + x + 10
    self:addChild(getLabel("Last Online", x, y, w, h))
    y = y + h + x
    self.lastonline = ISTextEntryBox:new(tostring(self.item.lastonline or ""), x, y, 280, h)
    self.lastonline:initialise()
    self:addChild(self.lastonline)

    y = y + h + x + 5
    self:addChild(getLabel("Last Day", x, y, w, h))
    y = y + h + x
    self.lastgameday = ISTextEntryBox:new(tostring(self.item.lastgameday or ""), x, y, 280, h)
    self.lastgameday:initialise()
    self:addChild(self.lastgameday)

    y = y + h + x + 5
    self:addChild(getLabel("Last Month", x, y, w, h))
    y = y + h + x
    self.lastgamemonth = ISTextEntryBox:new(tostring(self.item.lastgamemonth or ""), x, y, 280, h)
    self.lastgamemonth:initialise()
    self:addChild(self.lastgamemonth)

    y = y + h + x + 5
    self:addChild(getLabel("Last Year", x, y, w, h))
    y = y + h + x
    self.lastgameyear = ISTextEntryBox:new(tostring(self.item.lastgameyear or ""), x, y, 280, h)
    self.lastgameyear:initialise()
    self:addChild(self.lastgameyear)

    y = y + h + x + 5
    self:addChild(getLabel("Last World Hours", x, y, w, h))
    y = y + h + x
    self.lastWorldHours = ISTextEntryBox:new(tostring(self.item.lastWorldHours or ""), x, y, 280, h)
    self.lastWorldHours:initialise()
    self:addChild(self.lastWorldHours)

    y = y + h + x + 5

    self.save = ISButton:new(x, y, 100, h, "Save", self, PhunInfoAdminPlayersUI.save);
    self.save.internal = "SAVE";
    self.save:initialise();
    self:addChild(self.save);

end

function PhunInfoAdminPlayersUI:save()
    local data = {
        playerName = self.item.username,
        lastonline = tonumber(self.lastonline:getText()),
        lastgameday = tonumber(self.lastgameday:getText()),
        lastgamemonth = tonumber(self.lastgamemonth:getText()),
        lastgameyear = tonumber(self.lastgameyear:getText()),
        lastWorldHours = tonumber(self.lastWorldHours:getText())
    }
    sendClientCommand(getPlayer(), PhunStats.name, PhunStats.commands.adminUpdatePlayerOnline, data)
    self:close()
end

function PhunInfoAdminPlayersUI:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PhunInfoAdminPlayersUI.instance = nil
end

function PhunInfoAdminPlayersUI:new(x, y, width, height, item, player)
    local o = {};
    o = ISPanel:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;
    o.viewer = player
    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o.item = item;
    return o;
end

