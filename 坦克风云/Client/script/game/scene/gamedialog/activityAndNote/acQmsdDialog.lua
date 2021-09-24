acQmsdDialog=commonDialog:new()
function acQmsdDialog:new( layerNum )
    local nc = {}
    setmetatable(nc,self)
    self.__index =self
    nc.acTab1=nil
    nc.acTab2=nil
    nc.acTab3=nil

    nc.layerTab1=nil
    nc.layerTab2=nil
    nc.layerTab3=nil
    nc.layerNum=layerNum

    local function addPlist()--acChrisEveImage
        spriteController:addPlist("public/acQmsdImage.plist")
        spriteController:addTexture("public/acQmsdImage.png")
        spriteController:addPlist("public/activePicUseInNewGuid.plist")
        spriteController:addTexture("public/activePicUseInNewGuid.png")
        spriteController:addPlist("public/acChrisEveImage.plist")
        spriteController:addTexture("public/acChrisEveImage.png")
        spriteController:addPlist("public/activePicUseInNewGuid.plist")
        spriteController:addTexture("public/activePicUseInNewGuid.png")
    end
    G_addResource8888(addPlist)

    return nc
end

function acQmsdDialog:resetTab( )
    -- resetTab 这个方法最先执行，跨天刷数据，防止首次打开板子，创建后再刷新
    self.panelLineBg:setVisible(false)
    local vo=acQmsdVoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        -- acQmsdVoApi:refreshClear()
    end

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function acQmsdDialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    self:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx + 1)

    if self["acTab"..(idx+1)] and self["acTab"..(idx+1)].updateUI then
        self["acTab"..(idx+1)]:updateUI()
    end
end
function acQmsdDialog:getDataByType(type)
    if(type==nil)then
      type=1
    end 
    if type==1 then
        if self.layerTab1 ==nil then
            self.acTab1=acQmsdTabOne:new(self.layerNum)
            self.layerTab1=self.acTab1:init(self)
            self.bgLayer:addChild(self.layerTab1,1);
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        if self.layerTab3~=nil then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif type==2 then

        if self.layerTab2 ==nil then
            self.acTab2=acQmsdTabTwo:new(self.layerNum,self)
            self.layerTab2=self.acTab2:init(self)
            self.bgLayer:addChild(self.layerTab2,1);
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end

        if self.layerTab3~=nil then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end    
    elseif type==3 then
        if self.layerTab3 ==nil then
            self.acTab3=acQmsdTabThree:new(self.layerNum)
            self.layerTab3=self.acTab3:init(self)
            self.bgLayer:addChild(self.layerTab3,1)
        end
        self.layerTab3:setVisible(true)
        self.layerTab3:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end

        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        
    end
end



function acQmsdDialog:initTableView()
    -- local function callback( ... )
    -- end
    -- local hd= LuaEventHandler:createHandler(callback)
    -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-65-120),nil)

    local function rewardRecordShow()
        self:tabClick(0,false)
    end
    local cmdStr = "active.qmsd.getlog"
    acQmsdVoApi:getRechargeRewardSocket(rewardRecordShow,cmdStr)

    -- 蓝底背景
    -- local function addBlueBg()
    --     local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    --     blueBg:setAnchorPoint(ccp(0.5,0))
    --     blueBg:setScaleX(600/blueBg:getContentSize().width)
    --     blueBg:setScaleY((G_VisibleSizeHeight-180)/blueBg:getContentSize().height)
    --     blueBg:setPosition(G_VisibleSizeWidth/2,20)
    --     blueBg:setOpacity(200)
    --     self.bgLayer:addChild(blueBg)
    -- end
    -- G_addResource8888(addBlueBg)
end

function acQmsdDialog:tick()
    local vo=acQmsdVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    -- self:refresh()
    if self.acTab1 then
        self.acTab1:tick()
    end
    if self.acTab2 then
        self.acTab2:tick()
    end
    if self.acTab3 then
        self.acTab3:tick()
    end
    if acQmsdVoApi.curStateTb and SizeOfTable(acQmsdVoApi.curStateTb) > 0 then
        local tipSp =  tolua.cast(self.allTabs[3]:getChildByTag(101),"CCSprite")
        tipSp:setVisible(false)
        for k,v in pairs(acQmsdVoApi.curStateTb) do
            if v["state"] == 2 then
                tipSp:setVisible(true)
            end
        end
    end

    if acQmsdVoApi.curSelfStateTb and SizeOfTable(acQmsdVoApi.curSelfStateTb) > 0 then
        local tipSp =  tolua.cast(self.allTabs[2]:getChildByTag(101),"CCSprite")
        tipSp:setVisible(false)
        for k,v in pairs(acQmsdVoApi.curSelfStateTb) do
            if v["state"] == 2 then
                tipSp:setVisible(true)
            end
        end
    end
end

-- function acQmsdDialog:fastTick()
--     if self.acTab3 then
--         if self.acTab3.fastTick then
--             self.acTab3:fastTick()
--         end
--     end
-- end

-- function acQmsdDialog:refresh()
--     local vo=acQmsdVoApi:getAcVo()
--     if not G_isToday(vo.lastTime) then
--         acQmsdVoApi:refreshClear()
--         if self.acTab1 then
--             self.acTab1:refresh()
--         end
--         if self.acTab2 then
--             self.acTab2:refresh()
--         end
--         if self.acTab3 then
--             self.acTab3:refresh()
--         end
--     end
-- end

function acQmsdDialog:update()

end

function acQmsdDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    if self.layerTab3 then
        self.acTab3:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    spriteController:removePlist("public/acQmsdImage.plist")
    spriteController:removeTexture("public/acQmsdImage.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removePlist("public/acChrisEveImage.plist")
    spriteController:removeTexture("public/acChrisEveImage.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
end