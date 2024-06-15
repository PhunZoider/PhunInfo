if not isClient() then
    return
end
PhunInfoSummary = ISPanel:derive("PhunInfoSummary");
PhunInfoSummary.instances = {}
local PhunZones = PhunZones
local sandbox = SandboxVars.PhunInfo
local sandboxZones = SandboxVars.PhunZones

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14

function PhunInfoSummary.OnOpenPanel(playerObj)

    local core = getCore()
    local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
    local core = getCore()
    local width = 200 * FONT_SCALE
    local height = 50 * FONT_SCALE
    local x = (core:getScreenWidth() - width) / 2
    local y = 20
    local pIndex = playerObj:getPlayerNum()
    local instances = PhunInfoSummary.instances
    if instances[pIndex] then
        local instance = instances[pIndex]
        if not instance:isVisible() then
            instances[pIndex]:addToUIManager();
            instances[pIndex]:setVisible(true);
        end
        return instance
    end

    PhunInfoSummary.instances[pIndex] = PhunInfoSummary:new(x, y, width, height, playerObj);
    local instance = PhunInfoSummary.instances[pIndex]
    ISLayoutManager.RegisterWindow('phuninfosummary', PhunInfoSummary, instance)
    instance:initialise();
    instance:instantiate();
    instance:addToUIManager();
    if instance.rebuild then
        instance:rebuild()
    end
    return instance;

end

function PhunInfoSummary:initialise()
    ISPanel.initialise(self);
end

function PhunInfoSummary:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PhunInfoSummary.instances[self.pIndex] = nil
end

function PhunInfoSummary:prerender()
    ISPanel.prerender(self);

    -- highlight box if we are hovering over it
    if self:isMouseOver() then
        self.borderColor = self.hoverBorderColor
    else
        self.borderColor = self.normalBorderColor
    end

    local x = 1
    local cached = self.cached or {}
    if cached.pvpTexture then
        self:drawTextureScaledAspect(self.cached.pvpTexture, 1, 1, 30, 30, 1);
        x = 32
    end

    self:drawText(cached.title or "", x, 1, 0.7, 0.7, 0.7, 1.0, UIFont.Medium);

    local y = FONT_HGT_MEDIUM + 1
    -- for pips
    if sandboxZones.PhunZones_Pips and cached.risk then
        local colors = {
            r = 0.1,
            g = 0.1,
            b = 0.1,
            a = 1.0
        }
        if not cached.spawnSprtinters then
            colors.g = 0.9
        elseif cached.risk < 20 then
            colors.g = 0.9
            colors.b = 0.9
        else
            colors.r = 0.9
        end
        for i = 1, 10 do
            if (i * 10) < cached.risk then
                self:drawRect(x + ((i - 1) * 7), y, 5, 5, colors.a, colors.r, colors.g, colors.b);
            else
                break
            end
        end
    end

end

function PhunInfoSummary:render()
    if self:isMouseOver() then
        self:doTooltip()
    end
end

function PhunInfoSummary:rebuild()
    local player = getSpecificPlayer(self.pIndex)
    local pData = player:getModData().PhunZones
    -- PhunRunners:updatePlayer(player)

    if pData and pData.current then
        local data = pData.current

        local title = data.title or ""
        local subtitle = data.subtitle or ""
        if string.len(subtitle) > 0 then
            title = title .. " (" .. subtitle .. ")"
        end
        local pvpTexture = (data.pvp and self.pvpOnTexture) or nil
        local difficulty = data.difficulty or 0
        local titleWidth = getTextManager():MeasureStringX(UIFont.Medium, title)
        local summary = PhunRunners:getSummary(self.player)

        self.cached = {
            title = title,
            pvpTexture = pvpTexture,
            difficulty = difficulty,
            titleWidth = titleWidth,
            risk = summary.risk,
            riskTitle = summary.title,
            riskTitleWidth = getTextManager():MeasureStringX(UIFont.Small, summary.title),
            riskTitleHeight = getTextManager():MeasureStringY(UIFont.Small, summary.title),
            riskDescription = summary.description,
            riskDescriptionWidth = getTextManager():MeasureStringX(UIFont.Small, summary.description),
            riskDescriptionHeight = getTextManager():MeasureStringY(UIFont.Small, summary.description)
        }
    end
end

function PhunInfoSummary:doTooltip()
    local rectWidth = 10;
    local info = PhunRunners:getSummary(self.player)
    local titleLength = self.cached.riskTitleWidth;
    local descriptionLength = self.cached.riskDescriptionWidth;
    local textLength = titleLength;
    if descriptionLength > textLength then
        textLength = descriptionLength
    end

    local titleHeight = self.cached.riskTitleHeight;
    local descriptionHeight = self.cached.riskDescriptionHeight;
    local heightPadding = 2
    local rectHeight = titleHeight + descriptionHeight + (heightPadding * 3);

    local x = self:getMouseX() + 20;
    local y = self:getMouseY() + 20;

    self:drawRect(x, y, rectWidth + textLength, rectHeight, 1.0, 0.0, 0.0, 0.0);
    self:drawRectBorder(x, y, rectWidth + textLength, rectHeight, 0.7, 0.4, 0.4, 0.4);
    self:drawText(self.cached.riskTitle or "???", x + 2, y + 2, 1, 1, 1, 1);
    self:drawText(self.cached.riskDescription or "???", x + 2, y + titleHeight + (heightPadding * 2), 1, 1, 1, 0.7);
end

function PhunInfoSummary:onClick()
    PhunInfoUI:toggleVisibility(self.player)
end

function PhunInfoSummary:onMouseDown(x, y)
    self.downX = self:getMouseX()
    self.downY = self:getMouseY()
    return true
end
function PhunInfoSummary:onMouseUp(x, y)
    self.downY = nil
    self.downX = nil
    if not self.dragging then
        self:onClick()
    else
        self.dragging = false
        self:setCapture(false)
    end

    return true
end

function PhunInfoSummary:onMouseMove(dx, dy)

    if self.downY and self.downX and not self.dragging then
        if math.abs(self.downX - dx) > 4 or math.abs(self.downY - dy) > 4 then
            self.dragging = true
            self:setCapture(true)
        end
    end

    if self.dragging then
        local dx = self:getMouseX() - self.downX
        local dy = self:getMouseY() - self.downY
        self.userPosition = true
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    else
        if self:isMouseOver() then
            self:doTooltip()
        end
    end
end

function PhunInfoSummary:new(x, y, width, height, player)
    local o = {};
    o = ISPanel:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.borderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.0
    };
    o.normalBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.0
    };
    o.hoverBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.0
    };
    o.hoverBackgroundColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.cached = {}
    o.userPosition = false
    o.player = player
    o.pIndex = player:getPlayerNum()
    o.location = {}
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o.moveWithMouse = true;
    o.dragging = false
    o.downX = nil;
    o.downY = nil;
    -- o.rebuild = PhunInfoSummary.rebuild
    o.pvpOnTexture = getTexture("media/ui/pvpicon_on.png")
    o.tooltip = {
        title = "PhunZones",
        description = "Click to open the PhunZones UI"
    }
    return o;
end

function PhunInfoSummary:RestoreLayout(name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
    self.userPosition = layout.userPosition == 'true'
end

function PhunInfoSummary:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    layout.width = nil
    layout.height = nil
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end

