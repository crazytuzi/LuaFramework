--周年庆活动
acZhanyoujijieDialog=commonDialog:new()

function acZhanyoujijieDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.acTab1=nil
    nc.acTab2=nil
    nc.layerTab1=nil
    nc.layerTab2=nil
    nc.isToday=true
    spriteController:addPlist("public/acAnniversary.plist")
	spriteController:addTexture("public/acAnniversary.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
    spriteController:addPlist("public/acChunjiepansheng3.plist")
    spriteController:addTexture("public/acChunjiepansheng3.png")
    spriteController:addPlist("public/acRechargeBag_images.plist")
    spriteController:addTexture("public/acRechargeBag_images.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/acolympic_images.plist")
    spriteController:addTexture("public/acolympic_images.png")

	return nc
end

function acZhanyoujijieDialog:resetTab()
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

 --    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	-- self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	-- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function acZhanyoujijieDialog:initTableView()
    local function callback( ... )
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    
    local function initCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data and sData.data.zhanyoujijie then
                acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                self:tabClick(0,false)
            end
        end
    end
    local acVo=acZhanyoujijieVoApi:getAcVo()
    if acVo then
        if acZhanyoujijieVoApi:isLevelLimit()==false and acVo.isAfk==nil then
            socketHelper:activeZhanyoujijieInit(initCallback)
        else
            self:tabClick(0,false)
        end
    end
end

function acZhanyoujijieDialog:tabClick(idx,isEffect)
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
            self.acTab1=acZhanyoujijieTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum,self)
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
            self.acTab2=acZhanyoujijieTab2:new()
            self.layerTab2=self.acTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
            self:refresh(2)
        end
    end
end

function acZhanyoujijieDialog:tick()
    local vo=acZhanyoujijieVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if self.acTab1 then
        self.acTab1:tick()
    end
    if self.acTab2 then
        self.acTab2:tick()
    end
end
function acZhanyoujijieDialog:refresh( tab )
    -- if tab ==2 then
    --     if self.acTab2 then
    --         self.acTab2:refresh()
    --     end
    -- end
end

function acZhanyoujijieDialog:dispose()
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
    self.isToday=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acYuebingshencha.plist")
    spriteController:removePlist("public/acAnniversary.plist")
	spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar.pvr.ccz")
    spriteController:removePlist("public/acChunjiepansheng3.plist")
    spriteController:removeTexture("public/acChunjiepansheng3.png")
    spriteController:removePlist("public/acolympic_images.plist")
    spriteController:removeTexture("public/acolympic_images.png")
    spriteController:removePlist("public/acRechargeBag_images.plist")
    spriteController:removeTexture("public/acRechargeBag_images.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
end
