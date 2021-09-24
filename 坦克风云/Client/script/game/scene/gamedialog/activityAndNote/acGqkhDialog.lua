acGqkhDialog = commonDialog:new()

function acGqkhDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil

    self.isStop=false
    self.isToday=true
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")

    -- acGqkh
    return nc
end

function acGqkhDialog:resetTab()
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
    self.selectedTabIndex = 0
end

function acGqkhDialog:initTableView()
    local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSize.height-280),nil)

    local flag=acGqkhVoApi:tipSpVisible()
    if flag then
        self:setIconTipVisibleByIdx(true,2)
    end

    local function visbleChange(event,data)
        local flag=acGqkhVoApi:tipSpVisible()
        if flag then
            self:setIconTipVisibleByIdx(true,2)
        end
    end
    self.gqkhListener1=tipVisibleChange
    eventDispatcher:addEventListener("activity.tipVisibleChange",visbleChange)
    
    self:tabClick(0,false)
end

function acGqkhDialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    if(idx==0)then
        if(self.acTab1==nil)then     
            self.acTab1=acGqkhTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
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
    elseif(idx==1)then
        if(self.acTab2==nil)then
            self.acTab2=acGqkhTab2:new()
            self.layerTab2=self.acTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2)
            self:setIconTipVisibleByIdx(false,2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
            self:setIconTipVisibleByIdx(false,2)
            self:refresh()
        end
    end
end

function acGqkhDialog:tick()
    local acVo = acGqkhVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            if self ~= nil then
                self:close()
                return
            end
        end
    end
    if self.acTab1 then
        self.acTab1:tick()
    end
    
end
function acGqkhDialog:fastTick()
    if self.acTab1 then
        self.acTab1:fastTick()
    end
end

function acGqkhDialog:refresh()
    self.acTab2:refresh()
end

-- setIconTipVisibleByIdx(isVisible,idx)
function acGqkhDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.isStop=nil
    self.isToday=nil
    eventDispatcher:removeEventListener("activity.tipVisibleChange",self.gqkhListener1)
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png") 
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
end

