acUserFundDialog=commonDialog:new()

function acUserFundDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.userFundTab1=nil
    self.userFundTab2=nil

    self.isStop=false
    self.isToday=true
    
    return nc
end

--设置或修改每个Tab页签
function acUserFundDialog:resetTab()
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

function acUserFundDialog:initTableView()
    local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight - 460 - 30),nil)
    self.tv:setPosition(ccp(10,110))

    self:switchTab(1)
    local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
    if ifInRewardDay==true then
        self:tabClick(1)
    end

    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight - 395 + 50))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
end

function acUserFundDialog:hideTabAll()
    if self.layerTab1 then
        self.layerTab1:setPosition(ccp(999333,0))
        self.layerTab1:setVisible(false)
    end
    if self.layerTab2 then
        self.layerTab2:setPosition(ccp(999333,0))
        self.layerTab2:setVisible(false)
    end
end

function acUserFundDialog:tabClickColor(idx)

end

--点击tab页签 idx:索引
function acUserFundDialog:tabClick(idx)
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

function acUserFundDialog:switchTab(type)
    if type==nil then
        type=1
    end
    if type==1 then
        if self.userFundTab1==nil then
            self.userFundTab1=acUserFundDialogTab1:new(self)
            self.layerTab1=self.userFundTab1:init(self.layerNum,0,self)
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
        if self.userFundTab2==nil then
            self.userFundTab2=acUserFundDialogTab2:new(self)
            self.layerTab2=self.userFundTab2:init(self.layerNum,1,self)
            self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
        end
    end
end


function acUserFundDialog:tick()
    local vo=acUserFundVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if self.userFundTab1 then
        self.userFundTab1:tick()
    end
    if self.userFundTab2 then
        self.userFundTab2:tick()
    end

end

function acUserFundDialog:refresh(type)
    if self~=nil then
        if type==nil then
            if self.userFundTab1 then
                self.userFundTab1:refresh()
            end
            if self.userFundTab2 then
                self.userFundTab2:refresh()
            end
        else
            if type==1 and self.userFundTab1 then
                self.userFundTab1:refresh()
            elseif type==2 and self.userFundTab2 then
                self.userFundTab2:refresh()
            end
        end
    end
end

function acUserFundDialog:dispose()
    if self.userFundTab1 then
        self.userFundTab1:dispose()
    end
    if self.userFundTab2 then
        self.userFundTab2:dispose()
    end

    self.bgLayer=nil
    self.layerNum=nil
    self.layerTab1=nil
    self.layerTab2=nil

    self.userFundTab1=nil
    self.userFundTab2=nil

    self.isStop=nil
    self.isToday=nil

end