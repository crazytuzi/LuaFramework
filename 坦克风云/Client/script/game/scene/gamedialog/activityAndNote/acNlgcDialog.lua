require "luascript/script/game/scene/gamedialog/activityAndNote/acNlgcTab1"
require "luascript/script/game/scene/gamedialog/activityAndNote/acNlgcTab2"
acNlgcDialog = commonDialog:new()

function acNlgcDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.acTab1 = nil
    self.acTab2 = nil
    self.layerTab1 = nil
    self.layerTab2 = nil
    return nc
end

function acNlgcDialog:resetTab()
    local index = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        local sc = 1.05
        tabBtnItem:setScale(sc)
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width * 0.5 * sc + 5, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80)
        elseif index == 1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width * 1.5 * sc + 10, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80)
        end
        
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    self.selectedTabIndex = 0
end

function acNlgcDialog:initTableView()
    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acDouble11ver5Image.plist")
    spriteController:addTexture("public/acDouble11ver5Image.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/acMonthlySign.plist")
    spriteController:addTexture("public/acMonthlySign.png")
    
    self:tabClick(0, false)
    
    local vo = acNlgcVoApi:getAcVo()
    if vo then
        local timeLb = GetTTFLabel(acNlgcVoApi:getTimeStr(), 22)
        timeLb:setAnchorPoint(ccp(0.5, 0.5))
        timeLb:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 192)
        self.bgLayer:addChild(timeLb, 3)
        timeLb:setColor(G_ColorYellow)
        self.timeLb = timeLb
    end
end
function acNlgcDialog:tabClick(idx, isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    
    local function realSwitchSubTab(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true and sData.data.nlgc then
            acNlgcVoApi:updateData(sData.data.nlgc)
            if self.bgLayer == nil then
                do return end
            end
            for k, v in pairs(self.allTabs) do
                if v:getTag() == idx then
                    v:setEnabled(false)
                    self.selectedTabIndex = idx
                else
                    v:setEnabled(true)
                end
            end
            local function callFun()
                self:tabClick(1, false)
            end
            if(idx == 0)then
                if(self.acTab1 == nil)then
                    self.acTab1 = acNlgcTab1:new(callFun)
                    self.layerTab1 = self.acTab1:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab1)
                end
                if self.layerTab1 then
                    self.acTab1:updateUI()
                    self.layerTab1:setPosition(ccp(0, 0))
                    self.layerTab1:setVisible(true)
                end
                if self.layerTab2 then
                    self.layerTab2:setPosition(ccp(999333, 0))
                    self.layerTab2:setVisible(false)
                end
            elseif(idx == 1)then
                if(self.acTab2 == nil)then
                    self.acTab2 = acNlgcTab2:new()
                    self.layerTab2 = self.acTab2:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab2)
                end
                if self.layerTab1 then
                    self.layerTab1:setPosition(ccp(999333, 0))
                    self.layerTab1:setVisible(false)
                end
                if self.layerTab2 then
                    self.acTab2:updateUI()
                    self.layerTab2:setPosition(ccp(0, 0))
                    self.layerTab2:setVisible(true)
                end
            end
        end
    end
    socketHelper:nlgc_refresh(realSwitchSubTab)
end

function acNlgcDialog:update()
    if self.acTab1 and self.acTab1.updateUI then
        self.acTab1:updateUI()
    end
    if self.acTab2 and self.acTab2.updateUI then
        self.acTab2:updateUI()
    end
end

function acNlgcDialog:fastTick()
    -- if self.acTab1 and self.acTab1.fastTick then
    --     self.acTab1:fastTick()
    -- end
end

function acNlgcDialog:tick()
    local vo = acNlgcVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    else
        -- if self.acTab1 and self.acTab1.tick then
        --   self.acTab1:tick()
        -- end
    end
    self:updateAcTime()
end

function acNlgcDialog:updateAcTime()
    local acVo = acNlgcVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acNlgcVoApi:getTimeStr())
    end
end

function acNlgcDialog:dispose()
    if self.acTab1 and self.acTab1.dispose then
        self.acTab1:dispose()
    end
    if self.acTab2 and self.acTab2.dispose then
        self.acTab2:dispose()
    end
    self.layerTab1 = nil
    self.layerTab2 = nil
    self.acTab1 = nil
    self.acTab2 = nil
    spriteController:removePlist("public/acDouble11ver5Image.plist")
    spriteController:removeTexture("public/acDouble11ver5Image.png")
    spriteController:removePlist("public/acMonthlySign.plist")
    spriteController:removeTexture("public/acMonthlySign.png")
end
