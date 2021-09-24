require "luascript/script/game/scene/gamedialog/championshipWar/personalPointShopTab" --个人积分商店
require "luascript/script/game/scene/gamedialog/championshipWar/allianceCoinShopTab" --军团联赛币商店

championshipWarShopDialog = commonDialog:new()

function championshipWarShopDialog:new()
    local nc = {
        tab1 = nil,
        tab2 = nil,
        layerTab1 = nil,
        layerTab2 = nil,
    }
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function championshipWarShopDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelShadeBg:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(self.bgSize.height- 80 - 78)
    
    local index = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        local tabPosY = self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 82
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 20, tabPosY)
        elseif index == 1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 24 + tabBtnItem:getContentSize().width, tabPosY)
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    self.tabNum = SizeOfTable(self.allTabs)
    self:tabClick(0, false)
end

function championshipWarShopDialog:tabClick(idx)
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType1(idx + 1)
end

function championshipWarShopDialog:getDataByType1(type)
    if(type == nil)then
        type = 1
    end
    if(type == 1)then
        if(self.tab1 == nil)then
            self.tab1 = personalPointShopTab:new()
            self.layerTab1 = self.tab1:init(self.layerNum, self)
            self.bgLayer:addChild(self.layerTab1)
            if(self.selectedTabIndex == 0)then
                self:switchTab(1)
            end
        else
            self:switchTab(1)
        end
    elseif(type == 2)then
        if(self.tab2 == nil)then
            self.tab2 = allianceCoinShopTab:new()
            self.layerTab2 = self.tab2:init(self.layerNum, self)
            self.bgLayer:addChild(self.layerTab2)
            if(self.selectedTabIndex == 1)then
                self:switchTab(2)
            end
        else
            self:switchTab(2)
        end
    end
end

function championshipWarShopDialog:switchTab(tabType)
    if tabType == nil then
        tabType = 1
    end
    for i = 1, self.tabNum do
        if(i == tabType)then
            if(self["layerTab"..i] ~= nil)then
                self["layerTab"..i]:setPosition(ccp(0, 0))
                self["layerTab"..i]:setVisible(true)
            end
        else
            if(self["layerTab"..i] ~= nil)then
                self["layerTab"..i]:setPosition(ccp(999333, 0))
                self["layerTab"..i]:setVisible(false)
            end
        end
        if self["tab"..i] and self["tab"..i].updateUI and (i == tabType) then
            self["tab"..i]:updateUI()
        end
    end
end

function championshipWarShopDialog:tick()
    for i = 1, self.tabNum do
        if self["tab"..i] ~= nil and self["tab"..i].tick and self.selectedTabIndex + 1 == i then
            self["tab"..i]:tick()
        end
    end
end

function championshipWarShopDialog:fastTick()
    for i = 1, self.tabNum do
        if self["tab"..i] ~= nil and self["tab"..i].fastTick and self.selectedTabIndex + 1 == i then
            self["tab"..i]:fastTick()
        end
    end
end

function championshipWarShopDialog:dispose()
    for i = 1, self.tabNum do
        if (self["tab"..i] ~= nil and self["tab"..i].dispose) then
            self["tab"..i]:dispose()
        end
    end
    self.tab1 = nil
    self.tab2 = nil
    self.layerTab1 = nil
    self.layerTab2 = nil
    self.tabNum = nil
end
