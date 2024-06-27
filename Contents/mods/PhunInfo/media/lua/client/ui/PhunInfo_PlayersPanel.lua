if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunInfoPlayersPanel = ISPanel:derive("PhunInfoPlayersPanel");
local PhunStats = PhunStats

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

function PhunInfoPlayersPanel:initialise()
    ISPanel.initialise(self);
end

function PhunInfoPlayersPanel:new(x, y, width, height, viewer)
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
    PhunInfoPlayersPanel.instance = o;
    return o;
end

function PhunInfoPlayersPanel:createChildren()
    ISPanel.createChildren(self);

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - HEADER_HGT);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self.datas:addColumn("Player", 0);
    self.datas:addColumn("Last Seen (Game Days)", 200);
    self:addChild(self.datas);
end

function PhunInfoPlayersPanel:rebuild()
    self.datas:clear();
    local stats = PhunStats.lastOnlinePlayers or {}
    table.sort(stats, function(a, b)
        return a.lastonline > b.lastonline
    end)
    local items = {}
    for i, item in pairs(stats) do
        self.datas:addItem(i, item)
    end
end

function PhunInfoPlayersPanel:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    local value = getText("UI_PhunInfo_Online")
    local color = {
        r = 1,
        g = 1,
        b = 1,
        a = 0.9
    }
    if item.item.online ~= true then
        value = PhunTools:getWorldAgeDiffAsString(item.item.lastWorldHours)
    else
        color = {
            r = 0,
            g = 1,
            b = 0,
            a = 1
        }
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.username, xoffset, y + 4, color.r, color.g, color.b, color.a, self.font);
    self:clearStencilRect()

    local viewer = self.parent.viewer
    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, color.r, color.g, color.b, color.a, self.font);
    return y + self.itemheight;
end

Events[PhunStats.events.OnPhunStatsPlayersUpdated].Add(function(data)
    if PhunInfoPlayersPanel.instance and PhunInfoPlayersPanel.instance.rebuild then
        PhunInfoPlayersPanel.instance:rebuild()
    end
end)
