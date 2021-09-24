local tankWarehouseDialog = commonDialog:new()

function tankWarehouseDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function tankWarehouseDialog:createView(layerNum, tabNum)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("scene/tankWarehouse.plist")
    spriteController:addTexture("scene/tankWarehouse.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    self.layerNum = layerNum
    
    self.dialogLayer = CCLayer:create()
    
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function () end)
    self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer)
    
    local function touchLuaSpr()
    end
    local touchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchBg:setPosition(getCenterPoint(self.bgLayer))
    touchBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.bgLayer:addChild(touchBg)
    
    local dialogBg = CCSprite:createWithSpriteFrameName("warehouseLand.png")
    dialogBg:setScaleX((G_VisibleSizeWidth + 60) / dialogBg:getContentSize().width)
    dialogBg:setScaleY(G_VisibleSizeHeight / dialogBg:getContentSize().height)
    dialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(dialogBg)
    
    local useZorder, useTouchNum = 70, 70
    self.useZorder = useZorder
    local upTabBg = CCSprite:createWithSpriteFrameName("warehouseLand.png")
    upTabBg:setScaleX(G_VisibleSizeWidth / upTabBg:getContentSize().width)
    upTabBg:setScaleY(60 / upTabBg:getContentSize().height)
    upTabBg:setAnchorPoint(ccp(0.5, 1))
    upTabBg:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight)
    self.bgLayer:addChild(upTabBg, useZorder - 2)
    
    local tabTb = {
        {tabText = getlocal("repair_factory")},
        {tabText = getlocal("sample_build_name_17")},
    }
    
    local function tabClick(idx)
        self:switchTab(idx)
    end
    local multiTab = G_createMultiTabbed(tabTb, tabClick, "dk_tabBtn.png", "dk_tabBtn_down.png")
    multiTab:setTabTouchPriority(-(self.layerNum - 1) * 20 - useTouchNum)
    multiTab:setTabPosition(0, G_VisibleSizeHeight - 60)
    multiTab:setParent(self.bgLayer, useZorder)
    self.multiTab = multiTab
    
    self.multiTab:tabClick(1)
    if tabNum == 2 then
        self.multiTab:tabClick(2)
    end
    local function close()
        self:close()
    end
    local closeBtn, closeMenu = G_createBotton(self.bgLayer, ccp(0, 0), {}, "closeBtn.png", "closeBtn_Down.png", "closeBtn_Down.png", close, 1, -(self.layerNum - 1) * 20 - useTouchNum - 1, useZorder)
    closeMenu:setPosition(G_VisibleSizeWidth - closeBtn:getContentSize().width / 2, G_VisibleSizeHeight - closeBtn:getContentSize().height / 2)
    
    base:addNeedRefresh(self) --加入刷新队列
    
    self:show()
    
    return self.dialogLayer
end

function tankWarehouseDialog:switchTab(tabType)
    if tabType == nil then
        tabType = 1
    end
    local tab, layer = self["houseTab"..tabType], self["layerTab"..tabType]
    if tab == nil then
        if(tabType == 1)then
            local tankWarehouseRepairTab = require "luascript/script/game/scene/gamedialog/tankWarehouse/tankWarehouseRepairTab"
            tab = tankWarehouseRepairTab:new()
            layer = tab:init(self.useZorder, self)
        elseif(tabType == 2)then
            local tankWarehouseTab = require "luascript/script/game/scene/gamedialog/tankWarehouse/tankWarehouseTab"
            tab = tankWarehouseTab:new()
            layer = tab:show(self.useZorder, self.useZorder)
        end
        -- layer = tab:init(self.layerNum, self)
        self.bgLayer:addChild(layer, 10)
        self["houseTab"..tabType] = tab
        self["layerTab"..tabType] = layer
    end
    
    for i = 1, 2 do
        if(i == tabType)then
            if layer then
                layer:setPosition(ccp(0, 0))
                layer:setVisible(true)
                if tab.updateUI then
                    tab:updateUI()
                end
            end
        else
            local layer = self["layerTab"..i]
            if layer then
                layer:setPosition(ccp(999333, 999333))
                layer:setVisible(false)
            end
        end
    end
end

function tankWarehouseDialog:initTableView()
    
end

function tankWarehouseDialog:show()
    base.allShowedCommonDialog = base.allShowedCommonDialog + 1
    table.insert(base.commonDialogOpened_WeakTb, self)
end

function tankWarehouseDialog:tick()
    for k = 1, 2 do
        if self["houseTab"..k] and self["houseTab"..k].tick then
            self["houseTab"..k]:tick()
        end
    end
end

function tankWarehouseDialog:close()
    base.allShowedCommonDialog = base.allShowedCommonDialog - 1
    for k, v in pairs(base.commonDialogOpened_WeakTb) do
        if v == self then
            table.remove(base.commonDialogOpened_WeakTb, k)
            break
        end
    end
    if base.allShowedCommonDialog < 0 then
        base.allShowedCommonDialog = 0
    end
    if base.allShowedCommonDialog == 0 and storyScene and storyScene.isShowed == false and battleScene and battleScene.isBattleing == false then
        if portScene.clayer ~= nil then
            if sceneController.curIndex == 0 then
                portScene:setShow()
            elseif sceneController.curIndex == 1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex == 2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
    self:dispose()
end

function tankWarehouseDialog:dispose()
    for k = 1, 2 do
        if self["houseTab"..k] and self["houseTab"..k].dispose then
            self["houseTab"..k]:dispose()
        end
    end
    base:removeFromNeedRefresh(self) --移除出刷新队列
    self.dialogLayer:removeFromParentAndCleanup(true)
    self.dialogLayer = nil
    self.bgLayer = nil
    self.layerNum = nil
    self.houseTab1, self.houseTab2 = nil, nil
    self.layerTab1, self.layerTab2 = nil, nil
    if self.multiTab then
        self.multiTab:dispose()
        self.multiTab = nil
    end
    
    self = nil
end

return tankWarehouseDialog
