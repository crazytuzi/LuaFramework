--AI部队主页面
require "luascript/script/game/scene/gamedialog/AITroops/AITroopsProduce"
require "luascript/script/game/scene/gamedialog/AITroops/AITroopsListTab"

AITroopsDialog = commonDialog:new()

function AITroopsDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function AITroopsDialog:resetTab()
    local function addRes()
        spriteController:addPlist("public/aiTroopsImage/aitroops_images2.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_images2.png")
        spriteController:addPlist("public/aiTroopsImage/aitroops_main.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_main.png")
    end
    G_addResource8888(addRes)
    
    local index = 0
    local tabHeight = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 20, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
        elseif index == 1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 23 + tabBtnItem:getContentSize().width, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    self:tabClick(0)
end

function AITroopsDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx + 1)
end

function AITroopsDialog:getDataByType(tabType)
    if(tabType == nil)then
        tabType = 1
    end
    if(tabType == 1)then
        if(self.tab1 == nil)then
            self.tab1 = AITroopsProduce:new()
            self.layerTab1 = self.tab1:init(self.layerNum, self)
            self.bgLayer:addChild(self.layerTab1)
            if(self.selectedTabIndex == 0)then
                self:switchTab(1)
            end
        else
            self:switchTab(1)
        end
    elseif(tabType == 2)then
        if(self.tab2 == nil)then
            self.tab2 = AITroopsListTab:new()
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

function AITroopsDialog:switchTab(tabType)
    if tabType == nil then
        tabType = 1
    end
    for i = 1, 2 do
        if(i == tabType)then
            if(self["layerTab"..i] ~= nil)then
                self["layerTab"..i]:setPosition(ccp(0, 0))
                self["layerTab"..i]:setVisible(true)
            end
            if self["tab"..i].updateUI then
                self["tab"..i]:updateUI()
            end
        else
            if(self["layerTab"..i] ~= nil)then
                self["layerTab"..i]:setPosition(ccp(999333, 0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function AITroopsDialog:tick()
    if AITroopsVoApi:checkIsToday() == false then --跨天重置某些数据
        AITroopsVoApi:resetDailyInfo()
        AITroopsVoApi:resetDayTs()
        eventDispatcher:dispatchEvent("aitroops.over.today") --通知各个面板跨天刷新
    end
    for i = 1, 2 do
        if self["tab"..i] ~= nil and self["tab"..i].tick and self.selectedTabIndex + 1 == i then
            self["tab"..i]:tick()
        end
    end
end

function AITroopsDialog:dispose()
    for i = 1, 2 do
        if (self["tab"..i] ~= nil and self["tab"..i].dispose) then
            self["tab"..i]:dispose()
        end
    end
    self.tab1 = nil
    self.tab2 = nil
    self.layerTab1 = nil
    self.layerTab2 = nil
    spriteController:removePlist("public/aiTroopsImage/aitroops_images2.plist")
    spriteController:removeTexture("public/aiTroopsImage/aitroops_images2.png")
    spriteController:removePlist("public/aiTroopsImage/aitroops_main.plist")
    spriteController:removeTexture("public/aiTroopsImage/aitroops_main.png")
end

function AITroopsDialog:initTableView()
    self:setTopLineShow()
end
