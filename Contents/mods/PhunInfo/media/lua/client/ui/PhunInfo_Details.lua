if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunInfoDetailsUI = ISPanel:derive("PhunInfoDetailsUI");
PhunInfoDetailsUI.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local cache = {
    label = {},
    texture = {}
}

function PhunInfoDetailsUI.OnOpenPanel(playerObj, data)

    if PhunInfoDetailsUI.instance == nil then
        PhunInfoDetailsUI.instance = PhunInfoDetailsUI:new(100, 100, 400, 400, playerObj, data);
        PhunInfoDetailsUI.instance:initialise();
        PhunInfoDetailsUI.instance:instantiate();
    end
    PhunInfoDetailsUI.instance:setData(data)
    ISLayoutManager.RegisterWindow('PhunInfoDetailsUI', PhunInfoDetailsUI, PhunInfoDetailsUI.instance)
    PhunInfoDetailsUI.instance:addToUIManager();
    PhunInfoDetailsUI.instance:setVisible(true);
    return PhunInfoDetailsUI.instance;

end

function PhunInfoDetailsUI:new(x, y, width, height, viewer, data)
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
    o.key = key
    o.items = {};
    PhunInfoDetailsUI.instance = o;
    return o;
end

function PhunInfoDetailsUI:createChildren()
    ISPanel.createChildren(self);

    local x = 10
    local y = 10
    local h = FONT_HGT_MEDIUM;

    self.closeButton = ISButton:new(self.width - 25 - x, y, 25, 25, "X", self, function()
        PhunInfoDetailsUI.OnOpenPanel():close()
    end);
    self.closeButton:initialise();
    self:addChild(self.closeButton);

    y = y + h + x + 20

    self.container = ISPanel:new(x, y, self.width - 20, self.height - y - 20);
    self.container:initialise();
    self.container:instantiate();
    self:addChild(self.container);

    self.richText = ISRichTextPanel:new(1, 1, self.container.width - 2, self.container.height - 2);
    self.richText:initialise();
    self.richText.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.4
    };
    self.container:addChild(self.richText)

    self.richText:initialise();
    self.richText.text = "Loading..."
    self.richText.textDirty = true;
    self.richText.autosetheight = false;
    self.richText.clip = true
    self.richText:addScrollBars();

end

function PhunInfoDetailsUI:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PhunInfoDetailsUI.instance = nil
end

function PhunInfoDetailsUI:setData(data)
    self.data = data
    if self.data and self:isVisible() then
        local txt = ""
        if self.data.title then
            txt = txt .. "<H1> <LEFT> " .. self.data.title .. " <BR> "
        end
        if self.data.value then
            txt = txt .. " <TEXT> <LEFT> " .. self.data.value
        end
        self.richText.text = txt
        self.richText.textDirty = true;
        self.richText:paginate();
    end
end

function PhunInfoDetailsUI:RestoreLayout(name, layout)
    if name == "PhunInfoDetailsUI" then
        ISLayoutManager.DefaultRestoreWindow(self, layout)
        self.userPosition = layout.userPosition == 'true'
    end
end

function PhunInfoDetailsUI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    layout.width = nil
    layout.height = nil
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end

function PhunInfoDetailsUI:prerender()

    self.container:setHeight(self.height - self.container.y - 10)

    local x, y, x2, y2 = self.container.x, self.container.y, self.container.width, self.container.height

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    if self.data then

        if self.data.backgroundImage then

            self.richText.backgroundImage = getTexture(self.data.backgroundImage)

            local twidth = self.richText.backgroundImage:getWidth()
            local left = self.richText.width - twidth

            local bgX = left + 1
            local bgY = y + 1
            self:setStencilRect(x + 1, y, x2 - 2, y2)

            self:drawTexture(self.richText.backgroundImage, bgX, bgY, 0.5, 0.7, 0.7, 0.7);
            self:clearStencilRect()

        end
    end

end

function PhunInfoDetailsUI:onMouseDown(x, y)
    self.downX = self:getMouseX()
    self.downY = self:getMouseY()
    return true
end
function PhunInfoDetailsUI:onMouseUp(x, y)
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

function PhunInfoDetailsUI:onMouseMove(dx, dy)

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
    end
end
