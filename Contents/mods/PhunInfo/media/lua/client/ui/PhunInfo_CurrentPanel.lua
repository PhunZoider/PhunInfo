if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunInfoCurrentPanel = ISPanel:derive("PhunInfoCurrentPanel");
local PhunStats = PhunStats

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

function PhunInfoCurrentPanel:initialise()
    ISPanel.initialise(self);

end

function PhunInfoCurrentPanel:new(x, y, width, height, viewer)
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
    PhunInfoCurrentPanel.instance = o;
    return o;
end

-- function PhunIndoCurrentPanel:prerender()
--     ISPanel.prerender(self);
--     local parent = self.parent;
--     self.datas:setWidth(parent.width);
-- end

function PhunInfoCurrentPanel:createChildren()
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
    self.datas:addColumn("Category", 0);
    self.datas:addColumn("Value", 200);

    local currentCatagories = {}

    if SandboxVars.PhunInfo.PhunInfoStatsShowPvP then
        currentCatagories = {
            hours = 0,
            kills = 0,
            bandit_kills = 0,
            car_kills = 0,
            pvp_kills = 0,
            -- damage = 0,
            -- damage_taken = 0,
            sprinters = 0,
            ampules = 0,
            smokes = 0
        }
    else
        currentCatagories = {
            hours = 0,
            kills = 0,
            bandit_kills = 0,
            car_kills = 0,
            sprinters = 0,
            -- damage = 0,
            -- damage_taken = 0,
            ampules = 0,
            smokes = 0
        }
    end

    if SandboxVars.PhunInfo.ShowRunningStats then
        currentCatagories.runDistance = 0
        currentCatagories.runDuration = 0
        currentCatagories.sprintDistance = 0
        currentCatagories.sprintDuration = 0
    end

    for k, v in pairs(currentCatagories) do
        self.datas:addItem(k, {
            name = k,
            value = v
        })
    end
    self:addChild(self.datas);
end

function PhunInfoCurrentPanel:rebuild()
end

function PhunInfoCurrentPanel:drawDatas(y, item, alt)

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

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(getTextOrNull("UI_PhunInfo_" .. item.item.name) or item.item.name, xoffset, y + 4, 1, 1, 1, a,
        self.font);
    self:clearStencilRect()

    local viewer = self.parent.viewer
    local stats = PhunStats.players[viewer:getUsername()] or {
        current = {}
    }
    local value = PhunTools:formatWholeNumber(stats.current[item.item.name] or 0)
    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    return y + self.itemheight;
end
