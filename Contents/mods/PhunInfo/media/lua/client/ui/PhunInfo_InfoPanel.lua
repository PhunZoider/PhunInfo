if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunInfoInfoPanel = ISPanel:derive("PhunInfoInfoPanel");
local PhunStats = PhunStats

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

function PhunInfoInfoPanel:initialise()
    ISPanel.initialise(self);
end

function PhunInfoInfoPanel:new(x, y, width, height, viewer)
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
    o.infos = {}
    o.viewer = viewer
    o.title = "PhunInfo"
    PhunInfoInfoPanel.instance = o;
    return o;
end

function PhunInfoInfoPanel:createChildren()
    ISPanel.createChildren(self);
    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - HEADER_HGT);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_MEDIUM + 4 * 2
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.Medium;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self.datas.onmousedown = function(_, row)
        -- PhunInfoDetailsUI.OnOpenPanel(self.viewer, row.info)
        if row and row.info and row.info.onclick and PhunInfo.clickCommands[row.info.onclick] then
            PhunInfo.clickCommands[row.info.onclick](row.info)
        end
    end
    self:addChild(self.datas);
    self.datas:setScrollWidth(0);

end

function PhunInfoInfoPanel:rebuild()
    self.datas:clear()

    local data = PhunInfo.infos or {}
    for i, news in pairs(data) do
        local item = {}
        item.info = news
        item.richText = ISRichTextLayout:new(self.width);
        item.richText.marginLeft = 10
        item.richText.marginTop = 10
        item.richText.marginRight = 10
        item.richText.marginBottom = 10

        local txt = ""
        if news.title then
            txt = txt .. "<H1> <LEFT> " .. news.title .. " <BR> "
        end
        if news.value then
            txt = txt .. " <TEXT> <LEFT> " .. news.value
        end
        if news.backgroundImage then
            item.richText.backgroundImage = getTexture(news.backgroundImage)
        end
        item.richText:setText(txt)
        item.richText.textDirty = true;
        item.richText.autosetheight = true
        item.clip = true
        item.richText:initialise()
        item.richText:paginate()
        self.datas:addItem(news.title or "Hellos" .. i, item)
    end
    self:setScrollWidth(0);
    self:updateScrollbars();
end

function PhunInfoInfoPanel:drawDatas(y, item, alt)
    local padding = 10
    local messageHeight = math.max(item.item.richText:getHeight() + 4, self.itemheight)
    messageHeight = messageHeight + (padding * 2)
    if y + self:getYScroll() + messageHeight < 0 or y + self:getYScroll() >= self.height then
        return y + messageHeight
    end

    self:drawRectBorder(0, (y), self:getWidth(), item.height, self.borderColor.a, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    local info = item.item.info
    local clipX = 0
    local clipX2 = self:getWidth()
    if self:isVScrollBarVisible() then
        clipX2 = clipX2 - self.vscroll:getWidth()
    end

    local clipY = y
    local clipY2 = y + item.item.richText:getHeight()

    if info.backgroundImage then

        local cy = (y + self:getYScroll())
        local cy2 = messageHeight
        if cy < 0 then
            cy = 0
            cy2 = cy2 + (y + self:getYScroll())
        end
        if cy + messageHeight > self.height then
            cy2 = self.height - cy
        end
        local vscrollWidth = self.vscroll:getWidth()
        local width = self.width
        local twidth = item.item.richText.backgroundImage:getWidth()
        local left = width - twidth
        self:setStencilRect(clipX, cy, clipX2, cy2)
        local bgX = left + 1
        local bgY = y + 1
        self:drawTexture(item.item.richText.backgroundImage, bgX, bgY, 0.5, 0.7, 0.7, 0.7);
        item.item.richText:render(0, y + padding, self)
        self:clearStencilRect()

    else
        item.item.richText:render(0, y + padding, self)
    end

    return y + messageHeight
end

Events[PhunInfo.events.OnPhunInfosReceived].Add(function(data)
    if PhunInfoInfoPanel.instance and PhunInfoInfoPanel.instance.rebuild then
        PhunInfoInfoPanel.instance:rebuild()
    end
end)
