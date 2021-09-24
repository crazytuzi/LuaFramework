acBanzhangshilianDialog=commonDialog:new()

function acBanzhangshilianDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.dialogTab1=nil
    self.dialogTab2=nil
    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
    return nc
end

--设置或修改每个Tab页签
function acBanzhangshilianDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end

         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.selectedTabIndex=0
end

function acBanzhangshilianDialog:initTableView()
    local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,G_VisibleSizeHeight),nil)
    -- self.tv:setPosition(ccp(0,0))

    self:switchTab(1)
    -- local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
    -- if ifInRewardDay==true then
    --     self:tabClick(1)
    -- end

    -- self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight - 395 + 50))
    -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
end

function acBanzhangshilianDialog:tabClickColor(idx)

end

--点击tab页签 idx:索引
function acBanzhangshilianDialog:tabClick(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
            self:switchTab(idx+1)
        else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
        end
    end

end

function acBanzhangshilianDialog:switchTab(type)
    if type==nil then
        type=1
    end
    if type==1 then
        if self.dialogTab1==nil then
            self.dialogTab1=acBanzhangshilianTab1:new()
            self.layerTab1=self.dialogTab1:init(self.layerNum,0,self)
            self.bgLayer:addChild(self.layerTab1)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
    elseif type==2 then
        if self.dialogTab2==nil then
            local function callback()
                self.dialogTab2=acBanzhangshilianTab2:new()
                self.layerTab2=self.dialogTab2:init(self.layerNum,1,self)
                self.bgLayer:addChild(self.layerTab2)
                self:refresh(2)
            end
            acBanzhangshilianVoApi:getSocketRankList(callback)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            local function callback()
                self.layerTab2:setPosition(ccp(0,0))
                self.layerTab2:setVisible(true)
                self:refresh(2)
            end
            acBanzhangshilianVoApi:getSocketRankList(callback)
        end
    end
end


function acBanzhangshilianDialog:tick()
    local vo=acBanzhangshilianVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if self.dialogTab1 and self.dialogTab1.tick then
        self.dialogTab1:tick()
    end
    if self.dialogTab2 and self.dialogTab2.tick then
        self.dialogTab2:tick()
    end

end

function acBanzhangshilianDialog:refresh(type)
    if self~=nil then
        if type==nil then
            if self.dialogTab1 and self.dialogTab1.refresh then
                self.dialogTab1:refresh()
            end
            if self.dialogTab2 and self.dialogTab2.refresh then
                self.dialogTab2:refresh()
            end
        else
            if type==1 and self.dialogTab1 and self.dialogTab1.refresh then
                self.dialogTab1:refresh()
            elseif type==2 and self.dialogTab2 and self.dialogTab2.refresh then
                self.dialogTab2:refresh()
            end
        end
    end
end

function acBanzhangshilianDialog:dispose()
    if self.dialogTab1 then
        self.dialogTab1:dispose()
    end
    if self.dialogTab2 then
        self.dialogTab2:dispose()
    end

    self.bgLayer=nil
    self.layerNum=nil
    self.layerTab1=nil
    self.layerTab2=nil

    self.dialogTab1=nil
    self.dialogTab2=nil
end