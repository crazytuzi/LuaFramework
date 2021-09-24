acYjtsgDialog=commonDialog:new()

function acYjtsgDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFeixutansuo.plist")
    spriteController:addPlist("public/acYjtsgImage.plist")
    spriteController:addTexture("public/acYjtsgImage.png")
    spriteController:addPlist("public/acOpenyearImage.plist")
    spriteController:addTexture("public/acOpenyearImage.png")
    local function addPlist()
        spriteController:addPlist("public/activePicUseInNewGuid.plist")
        spriteController:addTexture("public/activePicUseInNewGuid.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/serverWarLocal/serverWarLocalCity.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acYijizaitan.plist")
    return nc
end

function acYjtsgDialog:resetTab()
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
--设置对话框里的tableView
function acYjtsgDialog:initTableView()
    
    local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
  
    local function callback(fn,data)
          local ret,sData=base:checkServerData(data)
          if ret==true then
            local acName=acYjtsgVoApi:getActiveName()
            if sData.data[acName]["list"] then
                acYjtsgVoApi:setRewardList(sData.data[acName]["list"])
                self:update()
            end
          end
    end

    if acYjtsgVoApi:getRewardList()==nil then
        socketHelper:activityYjtsgRewardList(callback)
    end
    self:tabClick(0,false)
end



--点击tab页签 idx:索引
function acYjtsgDialog:tabClick(idx,isEffect)
    if isEffect==nil then
        isEffect=true
    end
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
            -- if base.mustmodel==1 and acYjtsgVoApi:getMustMode() then
            --     self.acTab1=acYijizaitanTab1New:new()
            -- else
                self.acTab1=acYjtsgTab1:new()
            -- end
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
            self.acTab2=acYjtsgTab2:new()
            self.layerTab2=self.acTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
            self.acTab2:refresh()
        end
    end
end

function acYjtsgDialog:refresh()
    if self.tab1 and self.tab1.refresh then
        self.tab1:refresh()
    end
end

function acYjtsgDialog:tick()
    local vo=acYjtsgVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
        self.acTab1:tick()
    end
end

function acYjtsgDialog:doUserHandler()
    -- 蓝底背景
    local function addBlueBg()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,0))
        -- blueBg:setScaleX(600/blueBg:getContentSize().width)
        blueBg:setScaleY((G_VisibleSizeHeight-180)/blueBg:getContentSize().height)
        blueBg:setPosition(G_VisibleSizeWidth/2,20)
        blueBg:setOpacity(200)
        -- blueBg:setAnchorPoint(ccp(0,0))
        -- blueBg:setPosition(ccp(0,0))
        self.bgLayer:addChild(blueBg)
    end
    G_addResource8888(addBlueBg)
end

function acYjtsgDialog:fastTick()
    if self.acTab1 then
        self.acTab1:fastTick()
    end
end

function acYjtsgDialog:update()
    if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
        self.acTab1:updateShowTv()
    end
end

function acYjtsgDialog:dispose()
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
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFeixutansuo.plist")
    spriteController:removePlist("public/acYjtsgImage.plist")
    spriteController:removeTexture("public/acYjtsgImage.png")
    spriteController:removePlist("public/acOpenyearImage.plist")
    spriteController:removeTexture("public/acOpenyearImage.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/serverWarLocal/serverWarLocalCity.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acYijizaitan.plist")
end