acQxtwDialog=commonDialog:new()

function acQxtwDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil
    
    spriteController:addPlist("public/acQxtwImage.plist")
    spriteController:addTexture("public/acQxtwImage.png")
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")

    local function addPlist()
        spriteController:addPlist("public/acNewYearsEva.plist")
        spriteController:addTexture("public/acNewYearsEva.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function acQxtwDialog:resetTab()
    local index=0
    local vo=acQxtwVoApi:getAcVo()
    if not G_isToday(acQxtwVoApi.lastCheckTs) then
        acQxtwVoApi:refreshClear()
        local function callBack()
            if self.acTab1 then
                self.acTab1:refresh()
            end
            if self.acTab2 then
                self.acTab2:refresh()
            end
            self:setIconTipVisibleByIdx(acQxtwVoApi:checkTab2Tip(),2)
        end
        if(self.checkingTs==nil or self.checkingTs<base.serverTime)then
            self.checkingTs=base.serverTime + 10
        end
        local cmd="active.quanxiantuwei.checkqxtw"
        acQxtwVoApi:socketQxtw(cmd,nil,nil,callBack)
    end
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
end
--设置对话框里的tableView
function acQxtwDialog:initTableView()
    
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)
end



--点击tab页签 idx:索引
function acQxtwDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
        else
            v:setEnabled(true)
        end
    end
    
    if idx==1 then
        if self.layerTab2 ==nil then
            self.acTab2=acQxtwTab2:new(self.layerNum,self)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2,1);
        else
            self.acTab2:refresh()
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end
        self:resetForbidLayer(G_VisibleSizeHeight-175,175,115)
    elseif idx==0 then
        if self.layerTab1 ==nil then
            if acQxtwVoApi:isMustR() then
                require "luascript/script/game/scene/gamedialog/activityAndNote/acQxtwTabNew1"
                self.acTab1=acQxtwTabNew1:new(self.layerNum)
            else
                self.acTab1=acQxtwTab1:new(self.layerNum)
            end
            -- self.acTab1=acQxtwTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,1);
        else
            self.acTab1:refresh()
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end

        self:resetForbidLayer(G_VisibleSizeHeight-175,175,110)
    end
end

function acQxtwDialog:refresh(acVo)
    if not G_isToday(acVo.lastTime) then
        acQxtwVoApi:refreshClear()
        if self.acTab1 then
            self.acTab1:refresh()
        end
        if self.acTab2 then
            self.acTab2:refresh()
        end
    end
end

function acQxtwDialog:tick()
    local acVo = acQxtwVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if(G_isToday(acVo.lastTime)==false)then
            local function callBack()
                if self.acTab1 then
                    self.acTab1:refresh()
                end
                if self.acTab2 then
                    self.acTab2:refresh()
                end                
            end
            if(self.checkingTs==nil or self.checkingTs<base.serverTime)then
                self.checkingTs=base.serverTime + 10
            end
            local cmd="active.quanxiantuwei.checkqxtw"
            acQxtwVoApi:socketQxtw(cmd,nil,nil,callBack)
        else
            self:refresh(acVo)
        end
        self:setIconTipVisibleByIdx(acQxtwVoApi:checkTab2Tip(),2)
    else
        self:close()
    end
    if(self.acTab1 and self.acTab1.tick)then
        self.acTab1:tick()
    end
end

function acQxtwDialog:fastTick()
    if self.acTab1 then
        self.acTab1:fastTick()
    end
end

function acQxtwDialog:resetForbidLayer(posY1,height1,height2)
    if posY1 and height1 and height2 then
        -- self.topforbidSp:setVisible(true)
        -- self.bottomforbidSp:setVisible(true)
        self.topforbidSp:setPosition(0,posY1)
        self.bottomforbidSp:setPosition(0,0)
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height1))
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height2))
    end
    
    
end

function acQxtwDialog:dispose()
    if self.layerTab1~=nil then
        self.acTab1:dispose()
    end
    if self.layerTab2~=nil then
        self.acTab2:dispose()
    end
    self.layerTab1 = nil
    self.acTab1 = nil
    self.layerTab2 = nil
    self.acTab2 = nil
    self.layerNum = nil

    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acQxtwImage.plist")
    spriteController:removeTexture("public/acQxtwImage.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end