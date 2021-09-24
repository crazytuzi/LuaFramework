ltzdzTotalDialog=commonDialog:new()

function ltzdzTotalDialog:new( layerNum )
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

    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    spriteController:addPlist("public/ltzdz/ltzdzSegImages.plist")
    spriteController:addTexture("public/ltzdz/ltzdzSegImages.png")
    spriteController:addPlist("public/vipFinal.plist")
    spriteController:addTexture("public/vipFinal.plist")
    spriteController:addPlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:addTexture("public/ltzdz/ltzdzSegImages2.png")


    return nc
end

function ltzdzTotalDialog:resetTab( )

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

function ltzdzTotalDialog:tabClick(idx,isEffect)
	if isEffect==nil then
		isEffect=true
	end
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
end
function ltzdzTotalDialog:getDataByType(type)
    if(type==nil)then
      type=1
    end 
    if type==1 then
        if self.layerTab1 ==nil then
            self.acTab1=ltzdzTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,1)
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))

        self.acTab1:refreshEnable(true)
        
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
            self.acTab2=ltzdzTab2:new(self.layerNum,self)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2,1);
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
            self.acTab1:refreshEnable(false)
        end

        if self.layerTab3~=nil then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end    
    elseif type==3 then
        if self.layerTab3 ==nil then
            self.acTab3=ltzdzTab3:new(self.layerNum)
            self.layerTab3=self.acTab3:init()
            self.bgLayer:addChild(self.layerTab3,1)
        end
        self.layerTab3:setVisible(true)
        self.layerTab3:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
            self.acTab1:refreshEnable(false)
        end

        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        
    end
    if self["acTab"..type] and self["acTab"..type].updateUI then
        self["acTab"..type]:updateUI()
    end
end



function ltzdzTotalDialog:initTableView()
    ltzdzFightApi:disconnectSocket2() --进入功能前先断掉其他功能的跨服连接

    ltzdzVoApi.layerNum=self.layerNum
    local function callback( ... )
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-65-120),nil)

    self:tabClick(0)

    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-155)

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

    -- for i=1,6 do
    --     local smallLv=1
    --     if i==6 then
    --         smallLv=1250
    --     end
    --     local segSp=ltzdzVoApi:getSegIcon(i,smallLv,nil,2)
    --     segSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-80-(i-1)*170)
    --     self.bgLayer:addChild(segSp,10)
    -- end
end

function ltzdzTotalDialog:tick()
    if self.acTab1 then
        local isActive, dt = ltzdzVoApi:checkIsActive()
        if isActive == false then
            self:close()
            do return end
        end
        self.acTab1:tick()
    end
end

function ltzdzTotalDialog:fastTick()
end

function ltzdzTotalDialog:refresh()
end

function ltzdzTotalDialog:update()

end

function ltzdzTotalDialog:dispose()
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
    self.layerNum=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.bgLayer=nil
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("public/ltzdz/ltzdzSegImages.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegImages.png")
    spriteController:removePlist("public/vipFinal.plist")
    spriteController:removeTexture("public/vipFinal.plist")
    spriteController:removePlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegImages2.png")
    
    ltzdzFightApi:disconnectSocket2() --退出功能时断开跨服连接
end