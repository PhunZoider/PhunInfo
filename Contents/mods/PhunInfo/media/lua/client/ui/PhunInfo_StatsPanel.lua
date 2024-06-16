if not isClient() then
    return
end

require "ISUI/ISPanel"
require "ui/PhunInfo_CurrentPanel"
require "ui/PhunInfo_TotalsPanel"
PhunInfoStatsPanel = ISPanel:derive("PhunInfoStatsPanel");
local PhunStats = PhunStats

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

function PhunInfoStatsPanel:initialise()
    ISPanel.initialise(self);
end

function PhunInfoStatsPanel:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.listHeaderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0.3
    };
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.totalResult = 0;
    o.filterWidgets = {};
    o.filterWidgetMap = {}
    o.viewer = viewer
    PhunInfoStatsPanel.instance = o;
    return o;
end

function PhunInfoStatsPanel:createChildren()
    ISPanel.createChildren(self);

    local y = 10
    local gridHeight = (self.height - FONT_HGT_LARGE - 60) / 2
    self.currentLabel = ISLabel:new(0, y, FONT_HGT_LARGE, getText("UI_PhunInfo_Character_Stats"), 1, 1, 1, 1,
        UIFont.Large, true)
    self.currentLabel:initialise();
    self.currentLabel:instantiate();
    self:addChild(self.currentLabel);

    y = y + FONT_HGT_LARGE + 10

    self.current = PhunInfoCurrentPanel:new(0, y, self.width, gridHeight, self.viewer);
    self.current:initialise();
    self.current:instantiate();
    self:addChild(self.current);

    y = y + gridHeight + 10

    self.totalsLabel = ISLabel:new(0, y, FONT_HGT_LARGE, getText("UI_PhunInfo_Total_Stats"), 1, 1, 1, 1, UIFont.Large,
        true)
    self.totalsLabel:initialise();
    self.totalsLabel:instantiate();
    self:addChild(self.totalsLabel);

    y = y + FONT_HGT_LARGE + 10

    self.totals = PhunInfoTotalsPanel:new(0, y, self.width, gridHeight, self.viewer);
    self.totals:initialise();
    self.totals:instantiate();
    self:addChild(self.totals);

end

function PhunInfoStatsPanel:rebuild()
end
