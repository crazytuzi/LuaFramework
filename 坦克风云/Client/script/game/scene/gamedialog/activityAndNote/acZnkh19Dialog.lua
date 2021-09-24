require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh19LotteryTab"
require "luascript/script/game/scene/gamedialog/activityAndNote/acZnkh19ExchangeTab"
acZnkh19Dialog = commonDialog:new()

function acZnkh19Dialog:new()
    local nc = {
        layerTab1 = nil,
        layerTab2 = nil,
        
        znkhTab1 = nil,
        znkhTab2 = nil,
    }
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acZnkh19Dialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acZnkh2019_images1.plist")
    spriteController:addTexture("public/acZnkh2019_images1.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local index = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2, G_VisibleSize.height - tabBtnItem:getContentSize().height / 2 - 82)
        elseif index == 1 then
            tabBtnItem:setPosition(G_VisibleSize.width - tabBtnItem:getContentSize().width / 2, G_VisibleSize.height - tabBtnItem:getContentSize().height / 2 - 82)
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    self:tabClick(0, false)
end

function acZnkh19Dialog:doUserHandler()
end

function acZnkh19Dialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.closeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
    
    --活动时间
    local tvh, posy, fs = 35, G_VisibleSizeHeight - 142 - 40, 22
    local timeStr = acZnkh19VoApi:getTimeStr()
    local rewardTimeStr = acZnkh19VoApi:getRewardTimeStr()
    local moveBgStarStr, timeLb1, timeLb2 = G_LabelRollView(CCSizeMake(G_VisibleSizeWidth - 100, tvh), timeStr, fs, kCCTextAlignmentCenter, G_ColorGreen, nil, rewardTimeStr, G_ColorYellowPro, 2, 2, 2, nil)
    moveBgStarStr:setAnchorPoint(ccp(0, 0))
    moveBgStarStr:setPosition(50, posy)
    self.bgLayer:addChild(moveBgStarStr, 10)
    self.timeLb1 = timeLb1
    self.timeLb2 = timeLb2
end

function acZnkh19Dialog:tabClick(idx, isEffect)
    if isEffect == false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    local function realSwitchSubTab()
        for k, v in pairs(self.allTabs) do
            if v:getTag() == idx then
                v:setEnabled(false)
                self.selectedTabIndex = idx
            else
                v:setEnabled(true)
            end
        end
        self:switchTab(idx + 1)
    end
    
    if idx == 0 then
        acZnkh19VoApi:znkhGet(realSwitchSubTab)
    else
        realSwitchSubTab()
    end
end

function acZnkh19Dialog:switchTab(tabType)
    if tabType == nil then
        tabType = 1
    end
    if self["znkhTab"..tabType] == nil then
        local tab
        if(tabType == 1)then
            tab = acZnkh19ExchangeTab:new()
        else
            tab = acZnkh19LotteryTab:new()
        end
        self["znkhTab"..tabType] = tab
        self["layerTab"..tabType] = tab:init(self.layerNum, self)
        self.bgLayer:addChild(self["layerTab"..tabType], 3)
    end
    for i = 1, 2 do
        if(i == tabType)then
            if(self["layerTab"..i] ~= nil)then
                self["layerTab"..i]:setPosition(ccp(0, 0))
                self["layerTab"..i]:setVisible(true)
                if self["znkhTab"..tabType].updateUI then
                    self["znkhTab"..tabType]:updateUI()
                end
            end
        else
            if(self["layerTab"..i] ~= nil)then
                self["layerTab"..i]:setPosition(ccp(999333, 0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function acZnkh19Dialog:tick()
    if acZnkh19VoApi:isEnd() == true then
        self:close()
        G_closeAllSmallDialog()
        do return end
    end
    
    if self.timeLb1 and tolua.cast(self.timeLb1, "CCLabelTTF") then
        self.timeLb1:setString(acZnkh19VoApi:getTimeStr())
    end
    if self.timeLb2 and tolua.cast(self.timeLb2, "CCLabelTTF") then
        self.timeLb2:setString(acZnkh19VoApi:getRewardTimeStr())
    end
    
    if self and self.bgLayer then
        for i = 1, 2 do
            if self["znkhTab"..i] ~= nil and self["znkhTab"..i].tick then
                self["znkhTab"..i]:tick()
            end
        end
    end
end

function acZnkh19Dialog:dispose()
    if self.znkhTab1 then
        self.znkhTab1:dispose()
        self.znkhTab1 = nil
    end
    if self.znkhTab2 then
        self.znkhTab2:dispose()
        self.znkhTab2 = nil
    end
    
    self.layerTab1 = nil
    self.layerTab2 = nil
    spriteController:removePlist("public/acZnkh2019_images1.plist")
    spriteController:removeTexture("public/acZnkh2019_images1.png")
end
