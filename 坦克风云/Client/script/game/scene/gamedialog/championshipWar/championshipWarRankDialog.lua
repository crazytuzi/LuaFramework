championshipWarRankDialog = commonDialog:new()

function championshipWarRankDialog:new(listData, layerNum, tabIndex)
    local nc = {
        listData = listData,
        layerNum = layerNum,
        selectedTabIndex = tabIndex or 0,
        layerTab1 = nil,
        layerTab2 = nil,
        tab1 = nil,
        tab2 = nil,
    }
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function championshipWarRankDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelShadeBg:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(self.bgSize.height - 80 - 78)
    
    local index = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 20, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 82)
        else
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 24 + tabBtnItem:getContentSize().width, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 82)
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
end

function championshipWarRankDialog:initTableView()
    self:tabClick(self.selectedTabIndex)
end

function championshipWarRankDialog:tabClick(idx)
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            local tabBtnLabel = tolua.cast(v:getChildByTag(31), "CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
        else
            v:setEnabled(true)
            local tabBtnLabel = tolua.cast(v:getChildByTag(31), "CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
        end
    end
    self:switchTab(idx + 1)
end

function championshipWarRankDialog:switchTab(tabType)
    if tabType == nil then
        tabType = 1
    end
    if self["tab" .. tabType] == nil then
        local tab
        if(tabType == 1)then
            tab = championshipWarRankOneDialog:new(self.listData and self.listData.members or nil, self.layerNum)
        else
            tab = championshipWarRankTwoDialog:new(self.listData and self.listData.ranklist or nil, self.layerNum)
        end
        self["tab" .. tabType] = tab
        self["layerTab" .. tabType] = tab:init()
        self.bgLayer:addChild(self["layerTab" .. tabType])
    end
    for i = 1, 2 do
        local _pos = ccp(999333, 0)
        local _visible = false
        if(i == tabType)then
            _pos = ccp(0, 0)
            _visible = true
        end
        if(self["layerTab" .. i] ~= nil)then
            self["layerTab" .. i]:setPosition(_pos)
            self["layerTab" .. i]:setVisible(_visible)
        end
    end
end

function championshipWarRankDialog:dispose()
    if self.tab1 and self.tab1.dispose then
        self.tab1:dispose()
    end
    if self.tab2 and self.tab2.dispose then
        self.tab2:dispose()
    end
    self.layerTab1 = nil
    self.layerTab2 = nil
    self.tab1 = nil
    self.tab2 = nil
    self = nil
end
