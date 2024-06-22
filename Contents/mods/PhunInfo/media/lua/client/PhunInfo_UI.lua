if not isClient() then
    return
end
require "ISUI/ISPanelJoypad"
require("ui/PhunInfo_InfoPanel.lua")
require("ui/PhunInfo_StatsPanel.lua")
require("ui/PhunInfo_LeaderboardPanel.lua")
require("ui/PhunInfo_PlayersPanel.lua")
PhunInfoUI = ISPanelJoypad:derive("PhunInfoUI");
PhunInfoUI.instances = {}
local PhunZones = PhunZones

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14

local function getLabel(text, x, y, w, h)
    local lbl = ISLabel:new(x, y, FONT_HGT_LARGE, text, 1, 1, 1, 1, UIFont.Large, true)
    lbl:initialise();
    lbl:instantiate();
    return lbl
end

function PhunInfoUI:toggleVisibility(playerObj)
    local win = PhunInfoUI.instances[playerObj:getPlayerNum()]
    if win and win:isVisible() then
        win:close()
    else
        PhunInfoUI.OnOpenPanel(playerObj)
    end
end

function PhunInfoUI.OnOpenPanel(playerObj)

    local pNum = playerObj:getPlayerNum()

    if PhunInfoUI.instances[pNum] then
        triggerEvent(PhunZones.events.OnPhunZoneWelcomeOpened, PhunInfoUI.instances[pNum])
        if PhunInfoUI.instances[pNum] and PhunInfoUI.instances[pNum].rebuild then
            PhunInfoUI.instances[pNum]:rebuild()
        end
        return PhunInfoUI.instances[pNum]
    end

    local core = getCore()
    local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
    local core = getCore()
    local width = 400 * FONT_SCALE
    local height = 600 * FONT_SCALE
    local x = (core:getScreenWidth() - width) - 20
    local y = (core:getScreenHeight() / 2) - (height / 2)

    local pIndex = playerObj:getPlayerNum()
    PhunInfoUI.instances[pIndex] = PhunInfoUI:new(x, y - 200, width, height, playerObj);
    PhunInfoUI.instances[pIndex]:initialise();
    PhunInfoUI.instances[pIndex]:instantiate();

    PhunInfoUI.instances[pIndex]:addToUIManager();
    triggerEvent(PhunZones.events.OnPhunZoneWelcomeOpened, PhunInfoUI.instances[pIndex])
    if PhunInfoUI.instances[pIndex] and PhunInfoUI.instances[pIndex].rebuild then
        PhunInfoUI.instances[pIndex]:rebuild()
    end

    if playerObj:getPlayerNum() == 0 then
        ISLayoutManager.RegisterWindow('PhunInfoUI', PhunInfoUI, PhunInfoUI.instances[pIndex])
    end

    return PhunInfoUI.instances[pIndex];

end

function PhunInfoUI:initialise()
    ISPanelJoypad.initialise(self);
end

function PhunInfoUI:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PhunInfoUI.instances[self.pIndex] = nil
end

function PhunInfoUI:setSelected(tabName, row)
    self.selected = row
    self.selectedTab = tabName
end

function PhunInfoUI:onMouseWheel(del)
    self:setYScroll(self:getYScroll() - del * 30)
    return true
end

function PhunInfoUI:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData);
    self.joypadIndex = nil
    self.barWithTooltip = nil
end

function PhunInfoUI:onMouseDown(x, y)
    self.downX = self:getMouseX()
    self.downY = self:getMouseY()
    return true
end
function PhunInfoUI:onMouseUp(x, y)
    self.downY = nil
    self.downX = nil
    if not self.dragging then
        if self.onClick then
            self:onClick()
        end
    else
        self.dragging = false
        self:setCapture(false)
    end
    return true
end

function PhunInfoUI:onMouseMove(dx, dy)

    if self.downY and self.downX and not self.dragging then
        if math.abs(self.downX - dx) > 4 or math.abs(self.downY - dy) > 4 then
            self.dragging = true
            self:setCapture(true)
        end
    elseif self.dragging then
        self.dragging = false
    end

    if self.dragging then
        local dx = self:getMouseX() - self.downX
        local dy = self:getMouseY() - self.downY
        self.userPosition = true
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
end

function PhunInfoUI:onLoseJoypadFocus(joypadData)
    ISPanelJoypad.onLoseJoypadFocus(self, joypadData);
end

function PhunInfoUI:onJoypadDown(button)
    if button == Joypad.AButton then
    end
    if button == Joypad.YButton then
    end
    if button == Joypad.BButton then
    end
    if button == Joypad.LBumper then
        getPlayerInfoPanel(self.playerNum):onJoypadDown(button)
    end
    if button == Joypad.RBumper then
        getPlayerInfoPanel(self.playerNum):onJoypadDown(button)
    end
end

function PhunInfoUI:onJoypadDirDown()
    self.joypadIndex = self.joypadIndex + 1
    self:ensureVisible()
    self:updateTooltipForJoypad()
end

function PhunInfoUI:onJoypadDirLeft()
end

function PhunInfoUI:onJoypadDirRight()
end

function PhunInfoUI:prerender()
    ISPanelJoypad.prerender(self)

    local background = getTexture("media/textures/PhunInfo_Background_1.png")
    if background then
        local maxWidth = self.width
        local shrinkage = background:getWidth() / maxWidth
        self:drawTextureScaledAspect(background, 1, 1, self.width - 2, (background:getHeight() / shrinkage) - 2, 0.7);

    end

    self:setStencilRect(0, 0, self.width, self.height)
end

function PhunInfoUI:createChildren()
    self:setScrollChildren(true)
    self:addScrollBars()

    self:addChild(getLabel(SandboxVars.PhunInfo.PhunInfoServerName or "", 10, 25, 400, FONT_HGT_MEDIUM))

    self.closeButton = ISButton:new(self.width - 35, 10, 25, 25, "X", self, self.close)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    -- self.refreshButton = ISButton:new(self.width - 100, 10, 50, 25, "Refresh", self, function()
    --     -- self.infoPanel:clearChildren()
    --     sendClientCommand(self.player, PhunInfo.name, PhunInfo.commands.reload, {})
    -- end)
    -- self.refreshButton:initialise()
    -- self:addChild(self.refreshButton)

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

function PhunInfoUI:render()
    self:clearStencilRect()
end

function PhunInfoUI:tabsRender()
    -- ISScrollingListBox.render(self)
    local inset = 1
    local x = inset + self.scrollX
    local widthOfAllTabs = self:getWidthOfAllTabs()
    local overflowLeft = self.scrollX < 0
    local overflowRight = x + widthOfAllTabs > self.width
    if widthOfAllTabs > self:getWidth() then
        self:setStencilRect(0, 0, self:getWidth(), self.tabHeight)
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
        self:drawRect(self:getWidth() - inset - butWid, 0, butWid, self.tabHeight - 1, 1, 0, 0, 0)
        self:drawRectBorder(self:getWidth() - inset - butWid, -1, butWid, self.tabHeight + 1, 1, 0.4, 0.4, 0.4)
        self:drawTexture(tex, self:getWidth() - butWid + butPadX, (self.tabHeight - tex:getHeightOrig()) / 2, 1, 1, 1, 1)
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

function PhunInfoUI:new(x, y, width, height, player)
    local o = {};
    o = ISPanel:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;

    o.autoCloseTimestamp = getTimestamp() + (5);
    o.alphaBits = 0
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
    o.data = {
        stats = {
            current = {},
            total = {}
        },
        leaderboard = {}
    }
    o.player = player
    o.pIndex = player:getPlayerNum()
    o.userPosition = false
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o.moveWithMouse = true;
    return o;
end

function PhunInfoUI:RestoreLayout(name, layout)
    if name == "PhunInfoUI" then
        -- layout.visible = true
        ISLayoutManager.DefaultRestoreWindow(self, layout)
        self.userPosition = layout.userPosition == 'true'
        self:setVisible(true)
    end
end

function PhunInfoUI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    layout.width = nil
    layout.height = nil
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end
