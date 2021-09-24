acWsjdzzIIDialog=commonDialog:new()

function acWsjdzzIIDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil
    
    spriteController:addPlist("public/acolympic_images.plist")
    spriteController:addTexture("public/acolympic_images.png")
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    -- spriteController:addPlist("public/acBlessWords.plist")
    -- spriteController:addTexture("public/acBlessWords.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/wsjdzzImage.plist")
    spriteController:addTexture("public/wsjdzzImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function acWsjdzzIIDialog:doUserHandler( ... )
    if acWsjdzzIIVoApi:getVersion() == 3 then
        self.panelLineBg:setVisible(false)
        self.panelTopLine:setVisible(false)
    
        local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
        tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
        tabLine:setAnchorPoint(ccp(0.5,1))
        tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
        self.bgLayer:addChild(tabLine,5)
    
        -- 去渐变线
        local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
        panelBg:setAnchorPoint(ccp(0.5,0))
        panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
        panelBg:setPosition(G_VisibleSizeWidth/2,5)
        self.bgLayer:addChild(panelBg)
    end
end
function acWsjdzzIIDialog:resetTab()

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
end
--设置对话框里的tableView
function acWsjdzzIIDialog:initTableView()
    

    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setPosition(ccp(30,30))

end

--点击tab页签 idx:索引
function acWsjdzzIIDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        do return end
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

        if self.layer2==nil then
            self.tab2=acWsjdzzIITabTwo:new(self)
            self.layer2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer2)
        else
            self.layer2:setVisible(true)
        end
        
        
        if self.layer1 ~= nil then
            self.layer1:setVisible(false)
            self.layer1:setPosition(ccp(10000,0))
        end
        
        self.layer2:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.layer2~=nil then
            self.layer2:setPosition(ccp(999333,0))
            self.layer2:setVisible(false)
        end
        
        if self.layer1==nil then
            self.tab1=acWsjdzzIITabOne:new()
            self.layer1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer1)
        else
            self.layer1:setVisible(true)
        end

        self.layer1:setPosition(ccp(0,0))
    end
end

function acWsjdzzIIDialog:refresh()
    for i=1,2 do
        if self["tab"..i] and self["tab"..i].refresh then
            self["tab"..i]:refresh()
        end
    end
end

function acWsjdzzIIDialog:tick()
    local acVo = acWsjdzzIIVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        for i=1,2 do
            if self["tab"..i] and self["tab"..i].tick then
                self["tab"..i]:tick()
            end
        end
        local taskCanReward=acWsjdzzIIVoApi:taskCanReward()
        if taskCanReward==true then
            self:setIconTipVisibleByIdx(true,2)
        else
            self:setIconTipVisibleByIdx(false,2)
        end
    else
        self:close()
    end
end

function acWsjdzzIIDialog:dispose()
    if self.tab1~=nil then
        self.tab1:dispose()
    end
    if self.tab2~=nil then
        self.tab2:dispose()
    end
    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil
    self.layerNum = nil
    spriteController:removePlist("public/wsjdzzImage.plist")
    spriteController:removeTexture("public/wsjdzzImage.png")
    spriteController:removePlist("public/acolympic_images.plist")
    spriteController:removeTexture("public/acolympic_images.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    -- spriteController:removePlist("public/acBlessWords.plist")
    -- spriteController:removeTexture("public/acBlessWords.png")

end