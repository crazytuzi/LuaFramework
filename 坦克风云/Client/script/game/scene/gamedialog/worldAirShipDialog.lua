worldAirShipDialog = commonDialog:new()

function worldAirShipDialog:new(landData, layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.landData = landData
	self.layerNum = layerNum
	-- G_addResource8888(function()
 --        spriteController:addPlist("public/acMemoryServerImage.plist")
 --        spriteController:addTexture("public/acMemoryServerImage.png")
 --    end)
	return nc
end

function worldAirShipDialog:resetTab()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelShadeBg:setVisible(true)
    require "luascript/script/game/scene/gamedialog/worldAirShipTabOne"
    require "luascript/script/game/scene/gamedialog/worldAirShipTabTwo"
    self.tabObj = { worldAirShipTabOne, worldAirShipTabTwo }
	self.tabNum = SizeOfTable(self.tabObj)
    local index = 0
    local tabBtnItemSpaceX = 3
    for k, tabBtnItem in pairs(self.allTabs) do
        local btnItemFirstPosX = (G_VisibleSizeWidth - (tabBtnItem:getContentSize().width * self.tabNum + tabBtnItemSpaceX * (self.tabNum - 1))) / 2 + (tabBtnItem:getContentSize().width / 2)
        local btnItemPosY = G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 80
        tabBtnItem:setPosition(btnItemFirstPosX + index * (tabBtnItem:getContentSize().width + tabBtnItemSpaceX), btnItemPosY)
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    self.selectedTabIndex = 0
end

function worldAirShipDialog:initTableView()
	self:tabClick(self.selectedTabIndex)
end

function worldAirShipDialog:tabClick(idx)
	for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
        	v:setEnabled(true)
        end
    end
    local tabIndex = idx + 1
    if self["tab" .. tabIndex] == nil then
        local tab = self.tabObj[tabIndex]:new(self)
        self["tab" .. tabIndex] = tab
        self["layerTab" .. tabIndex] = tab:init()
        self.bgLayer:addChild(self["layerTab" .. tabIndex], 1)
    end
    for i = 1, self.tabNum do
        local tabPos = ccp(999333, 0)
        local tabVisible = false
        if i == tabIndex then
            tabPos = ccp(0, 0)
            tabVisible = true
        end
        if self["layerTab" .. i] ~= nil then
            self["layerTab" .. i]:setPosition(tabPos)
            self["layerTab" .. i]:setVisible(tabVisible)
        end
    end
end

function worldAirShipDialog:tick()
	if self then
    	if self.tabNum then
            for i = 1, self.tabNum do
                if self["tab" .. i] and type(self["tab" .. i].tick) == "function" then
                    self["tab" .. i]:tick()
                end
            end
        end
    end
end

function worldAirShipDialog:dispose()
	if self.tabNum then
		for i = 1, self.tabNum do
	        if self["tab" .. i] and type(self["tab" .. i].dispose) == "function" then
	            self["tab" .. i]:dispose()
	        end
	        self["layerTab" .. i] = nil
	        self["tab" .. i] = nil
	    end
	end
	self = nil
end