if not isClient() then
    return
end
require "ISUI/ISCollapsableWindowJoypad"
require("ui/PhunInfo_InfoPanel.lua")
require("ui/PhunInfo_StatsPanel.lua")
require("ui/PhunInfo_LeaderboardPanel.lua")
require("ui/PhunInfo_PlayersPanel.lua")
PhunInfoUI = ISCollapsableWindowJoypad:derive("PhunInfoUI");
PhunInfoUI.instances = {}
local PhunZones = PhunZones

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local function getLabel(text, x, y, w, h)
    local lbl = ISLabel:new(x, y, FONT_HGT_LARGE, text, 1, 1, 1, 1, UIFont.Large, true)
    lbl:initialise();
    lbl:instantiate();
    return lbl
end

function PhunInfoUI.OnOpenPanel(playerObj)

    local pNum = playerObj:getPlayerNum()

    if PhunInfoUI.instances[pNum] then
        if not PhunInfoUI.instances[pNum]:isVisible() then
            PhunInfoUI.instances[pNum]:addToUIManager();
            PhunInfoUI.instances[pNum]:setVisible(true);
            return
        elseif PhunInfoUI.instances[pNum].isCollapsed then
            PhunInfoUI.instances[pNum].isCollapsed = false
            return
        end
        return
    end

    local core = getCore()
    local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
    local core = getCore()
    local width = 400 * FONT_SCALE
    local height = 500 * FONT_SCALE
    local x = (core:getScreenWidth() - width) - 20
    local y = (core:getScreenHeight() / 2) - (height / 2)

    local pIndex = playerObj:getPlayerNum()
    PhunInfoUI.instances[pIndex] = PhunInfoUI:new(x, y - 200, width, height, playerObj);
    PhunInfoUI.instances[pIndex]:initialise();

    PhunInfoUI.instances[pIndex]:addToUIManager();
    triggerEvent(PhunZones.events.OnPhunZoneWelcomeOpened, PhunInfoUI.instances[pIndex])
    if PhunInfoUI.instances[pIndex] and PhunInfoUI.instances[pIndex].rebuild then
        PhunInfoUI.instances[pIndex]:rebuild()
    end

    ISLayoutManager.RegisterWindow('PhunInfoUI', PhunInfoUI, PhunInfoUI.instances[pIndex])

    return PhunInfoUI.instances[pIndex];

end

function PhunInfoUI:close()
    self:removeFromUIManager();
    PhunInfoUI.instances[self.pIndex] = nil
end

function PhunInfoUI:setSelected(tabName, row)
    self.selected = row
    self.selectedTab = tabName
end

function PhunInfoUI:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local selfWidth = self.width

    local selfHeight = self.height
    if not self.isCollapsed then
        local background = getTexture("media/textures/PhunInfo_Background_1.png")
        if background then
            local backgroundWidth = background:getWidth()
            local backgroundHeight = background:getHeight()

            local width = math.max(selfWidth, backgroundWidth)
            local height = width * (backgroundHeight / backgroundWidth)
            self:drawTextureScaledAspect(background, selfWidth - width, th, width, height, 0.7);
        end
    end

    self.tabPanel:setWidth(selfWidth - (self.tabPanel.x * 2))
    self.tabPanel:setHeight(selfHeight - self.tabPanel.y - (self.tabPanel.x * 2))

    for i, viewObject in ipairs(self.tabPanel.viewList) do
        viewObject.view:setY(self.tabPanel.tabHeight)
        viewObject.view:setWidth(self.tabPanel.width)
        viewObject.view:setHeight(self.tabPanel.height - self.tabPanel.tabHeight)
    end
end

function PhunInfoUI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self);
    self:setScrollChildren(true)
    self:addScrollBars()
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    self:addChild(getLabel(SandboxVars.PhunInfo.PhunInfoServerName or "", 10, th + 25, 400, FONT_HGT_MEDIUM))

    if isAdmin() then
        self.refreshButton = ISButton:new(self.width - 60, th + 10, 50, 25, "Refresh", self, function()
            -- self.infoPanel:clearChildren()
            sendClientCommand(self.player, PhunInfo.name, PhunInfo.commands.reload, {})
        end)
        self.refreshButton:initialise()
        self:addChild(self.refreshButton)
    end

    self.tabPanel = ISTabPanel:new(10, 75, self.width - 20, self.height - 75)
    self.tabPanel:initialise()
    self.tabPanel.tabFont = UIFont.Medium
    self.tabPanel.tabHeight = FONT_HGT_MEDIUM + 6
    self.tabPanel.activateView = function(self, viewname)
        ISTabPanel.activateView(self, viewname)
        self.parent:setSelected(viewname, self.activeView.view.selected)
    end
    self.tabPanel.render = self.tabsRender

    self:addChild(self.tabPanel)

    local x = 0
    local y = 50
    local w = self.tabPanel.width
    local h = self.tabPanel.height - y

    self.infoPanel = PhunInfoInfoPanel:new(x, y, w, h, self.player)
    self.statsPanel = PhunInfoStatsPanel:new(x, y, w, h, self.player)
    self.leaderboardPanel = PhunInfoLeaderPanel:new(x, y, w, h, self.player)
    self.recentPlayersPanel = PhunInfoPlayersPanel:new(x, y, w, h, self.player)

    self.tabPanel:addView(getText("UI_PhunInfo_Info"), self.infoPanel)
    self.tabPanel:addView(getText("UI_PhunInfo_Stats"), self.statsPanel)
    self.tabPanel:addView(getText("UI_PhunInfo_Leaderboard"), self.leaderboardPanel)
    self.tabPanel:addView(getText("UI_PhunInfo_Players"), self.recentPlayersPanel)

end

-- function PhunInfoUI:render()
--     self:clearStencilRect()
-- end

function PhunInfoUI:tabsRender()
    -- ISScrollingListBox.render(self)
    local inset = 1
    local x = inset + self.scrollX
    local widthOfAllTabs = self:getWidthOfAllTabs()
    local overflowLeft = self.scrollX < 0
    local overflowRight = x + widthOfAllTabs > self.width
    if widthOfAllTabs > self:getWidth() then
        self:setStencilRect(0, 0, self:getWidth() - 21, self.tabHeight)
    end
    for i, viewObject in ipairs(self.viewList) do
        local tabWidth = (self.equalTabWidth and self.maxLength or viewObject.tabWidth) + 4
        if viewObject == self.activeView then
            self:drawRect(x, 0, tabWidth, self.tabHeight, 1, 0.4, 0.4, 0.4, 0.7)
        else
            self:drawRect(x + tabWidth, 0, 1, self.tabHeight, 1, 0.4, 0.4, 0.4, 0.9)
            if self:getMouseY() >= 0 and self:getMouseY() < self.tabHeight and self:isMouseOver() and
                self:getTabIndexAtX(self:getMouseX()) == i then
                viewObject.fade:setFadeIn(true)
            else
                viewObject.fade:setFadeIn(false)
            end
            viewObject.fade:update()
            self:drawRect(x, 0, tabWidth, self.tabHeight, 0.2 * viewObject.fade:fraction(), 1, 1, 1, 0.9)
        end
        self:drawTextCentre(viewObject.name, x + (tabWidth / 2), 3, 1, 1, 1, 1, self.tabFont)
        x = x + tabWidth
    end
    self:drawRect(0, self.tabHeight - 1, self:getWidth(), 1, 1, 0.4, 0.4, 0.4)
    local butPadX = 3
    if overflowLeft then
        local tex = getTexture("media/ui/ArrowLeft.png")
        local butWid = tex:getWidthOrig() + butPadX * 2
        self:drawRect(inset, 0, butWid, self.tabHeight - 1, 1, 0, 0, 0)
        self:drawRectBorder(inset, -1, butWid, self.tabHeight + 1, 1, 0.4, 0.4, 0.4)
        self:drawTexture(tex, inset + butPadX, (self.tabHeight - tex:getHeightOrig()) / 2, 1, 1, 1, 1)
    end
    if overflowRight then
        local tex = getTexture("media/ui/ArrowRight.png")
        local butWid = tex:getWidthOrig() + butPadX * 2
        self:drawRect(self:getWidth() - inset - butWid - 20, 0, butWid, self.tabHeight - 1, 1, 0, 0, 0)
        self:drawRectBorder(self:getWidth() - inset - butWid - 20, -1, butWid, self.tabHeight + 1, 1, 0.4, 0.4, 0.4)
        self:drawTexture(tex, self:getWidth() - butWid - 20 + butPadX, (self.tabHeight - tex:getHeightOrig()) / 2, 1, 1,
            1, 1)
    end
    if widthOfAllTabs > self:getWidth() then
        self:clearStencilRect()
    end
    self:drawRect(0, self.height, self.width, 1, 1, 0.4, 0.4, 0.4)

end

function PhunInfoUI:rebuild()

    if self.statsPanel and self.statsPanel.rebuild then
        self.statsPanel:rebuild()
    end
    if self.leaderboardPanel and self.leaderboardPanel.rebuild then
        self.leaderboardPanel:rebuild()
    end
    if self.recentPlayersPanel and self.recentPlayersPanel.rebuild then
        self.recentPlayersPanel:rebuild()
    end
    if self.infoPanel and self.infoPanel.rebuild then
        self.infoPanel:rebuild()
    end

end

function PhunInfo:RestoreLayout(name, layout)

    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if layout.locked == 'false' then
        self.locked = false;
        self.lockButton:setImage(self.chatUnLockedButtonTexture);
    else
        self.locked = true;
        self.lockButton:setImage(self.chatLockedButtonTexture);
    end
    self:recalcSize();
end

function PhunInfoUI:new(x, y, width, height, player)
    local o = {};
    o = ISCollapsableWindowJoypad:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;

    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };

    o.player = player
    o.pIndex = player:getPlayerNum()
    o.pin = true
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setTitle(SandboxVars.PhunInfo.PhunInfoServerName or "")
    return o;
end
