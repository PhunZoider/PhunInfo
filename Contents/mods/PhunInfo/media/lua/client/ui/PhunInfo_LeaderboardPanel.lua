if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunInfoLeaderPanel = ISPanel:derive("PhunInfoLeaderPanel");
local PhunStats = PhunStats

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function PhunInfoLeaderPanel:initialise()
    ISPanel.initialise(self);
end

function PhunInfoLeaderPanel:new(x, y, width, height, viewer)
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
    PhunInfoLeaderPanel.instance = o;
    return o;
end

function PhunInfoLeaderPanel:createChildren()
    ISPanel.createChildren(self);

    self.datas = ISScrollingListBox:new(0, 0, self.width, self.height);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self.datas:addColumn("Category", 0);
    self.datas:addColumn("Player", 125);
    self.datas:addColumn("Value", 250);
    self:addChild(self.datas);

end

function PhunInfoLeaderPanel:rebuild()
    self.datas:clear();
    local stats = PhunStats.leaderboard or {}
    local items = {}
    local currentCatagories = {
        hours = {
            text = "hours",
            label = "Hours",
            value = 0,
            current = true
        },
        totalHours = {
            text = "hours",
            label = "Total hours",
            value = 0
        },
        kills = {
            text = "kills",
            label = "Kills",
            value = 0,
            current = true
        },
        totalKills = {
            text = "kills",
            label = "Total kills",
            value = 0,
            current = false
        },
        carKills = {
            text = "car_kills",
            label = "Car Kills",
            value = 0,
            current = true
        },
        totalCarKills = {
            text = "car_kills",
            label = "Total Car kills",
            value = 0,
            current = false
        },
        sprinters = {
            text = "sprinters",
            label = "Sprinters killed",
            value = 0,
            current = true
        },
        totalSprinters = {
            text = "sprinters",
            label = "Total sprinters killes",
            value = 0,
            current = false
        },
        pvpKills = {
            text = "pvp_kills",
            label = "PvP kills",
            value = 0,
            current = true,
            pvp = true
        },
        totalPvpKills = {
            text = "pvp_kills",
            label = "Total PvP kills",
            value = 0,
            current = false,
            pvp = true
        },
        pvpCarKills = {
            text = "pvp_car_kills",
            label = "PvP car kills",
            value = 0,
            current = true,
            pvp = true
        },
        totalPvpCarKills = {
            text = "pvp_car_kills",
            label = "Total PvP car kills",
            value = 0,
            current = false,
            pvp = true
        },
        deaths = {
            text = "deaths",
            label = "Deaths",
            value = 0,
            current = false
        },
        totalPvpDeaths = {
            text = "pvp_deaths",
            label = "PvP deaths",
            value = 0,
            current = false,
            pvp = true
        },
        ampules = {
            text = "ampules",
            label = "Ampules broken",
            value = 0,
            current = true
        },
        totalAmpules = {
            text = "ampules",
            label = "Total ampules broken",
            value = 0,
            current = false
        },
        smokes = {
            text = "smokes",
            label = "Smoke breaks",
            value = 0,
            current = true
        },
        totalSmokes = {
            text = "smokes",
            label = "Total smoke breaks",
            value = 0,
            current = false
        }

    }

    if SandboxVars.PhunInfo.ShowRunningStats then
        currentCatagories.runDistance = {
            text = "runDistance",
            label = "Run distance",
            value = 0,
            current = true
        }
        currentCatagories.totalRunDistance = {
            text = "runDistance",
            label = "Total run distance",
            value = 0,
            current = false
        }
        currentCatagories.runDuration = {
            text = "runDuration",
            label = "Run duration",
            value = 0,
            current = true
        }
        currentCatagories.totalRunDuration = {
            text = "runDuration",
            label = "Total run duration",
            value = 0,
            current = false
        }
        currentCatagories.sprintDistance = {
            text = "sprintDistance",
            label = "Sprint distance",
            value = 0,
            current = true
        }
        currentCatagories.totalSprintDistance = {
            text = "sprintDistance",
            label = "Total sprint distance",
            value = 0,
            current = false
        }
        currentCatagories.sprintDuration = {
            text = "sprintDuration",
            label = "Sprint duration",
            value = 0,
            current = true
        }
        currentCatagories.totalSprintDuration = {
            text = "sprintDuration",
            label = "Total sprint duration",
            value = 0,
            current = false
        }
    end

    for k, v in pairs(currentCatagories) do
        if not v.pvp or SandboxVars.PhunInfo.PhunInfoStatsShowPvP then
            self.datas:addItem(k, v)
        end
    end
end

function PhunInfoLeaderPanel:prerender()
    local ps = PhunStats
    local stats = ps.leaderboard or {}
    local items = {}
    for i, item in pairs(self.datas.items) do
        local from = "total"
        if item.item.current then
            from = "current"
        end
        local stat = stats[from][item.item.text]
        if stat then
            item.value = PhunTools:formatWholeNumber(stat.value or item.value)
            item.who = stat.who or item.who
            item.label = item.item.label
        end
    end
    ISPanel.prerender(self);

    self.datas:setY(self.datas.fontHgt)
    self.datas:setWidth(self.width);
    self.datas:setHeight(self.height - self.datas.fontHgt);
end

function PhunInfoLeaderPanel:drawDatas(y, item, alt)
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
    self:drawText(getTextOrNull("UI_PhunInfo_" .. item.text) or item.label or item.text, xoffset, y + 4, 1, 1, 1, a,
        self.font);
    self:clearStencilRect()

    clipX = self.columns[2].size
    clipX2 = self.columns[3].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.who or "", clipX + xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.value
    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[3].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    return y + self.itemheight;
end

Events[PhunStats.events.OnPhunStatsLeaderboardUpdated].Add(function(data)
    if PhunInfoLeaderPanel.instance and PhunInfoLeaderPanel.instance.rebuild then
        PhunInfoLeaderPanel.instance:rebuild()
    end
end)
