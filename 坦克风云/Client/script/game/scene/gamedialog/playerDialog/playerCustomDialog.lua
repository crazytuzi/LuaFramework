playerCustomDialog=commonDialog:new()

function playerCustomDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil

    self.isStop=false
    self.isToday=true

    self.tv=nil
    --在这里加载图片
    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
        spriteController:addPlist("public/chat_image.plist")
        spriteController:addTexture("public/chat_image.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    return nc
end

function playerCustomDialog:resetTab( )
	local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v

        if index==0 then
            tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==1 then
            tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==2 then
            tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        end

         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.selectedTabIndex = 0
end

function playerCustomDialog:initTableView()
    self.panelLineBg:setVisible(false)
    local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
    topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
    topBorder:setAnchorPoint(ccp(0,1))
    topBorder:setPosition(0,G_VisibleSizeHeight - 158)
    self.bgLayer:addChild(topBorder)
    
    local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-200),nil)
    self.tv:setPosition(30, 40)
    self:tabClick(0,true)
end
function playerCustomDialog:tabClick(idx,isEffect)
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
    if idx==0 then
        if self.acTab1==nil then            
            self.acTab1=playerCustomDialogTab1:new(self)
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
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif idx==1 then
        if self.acTab3==nil then
            self.acTab3=playerCustomDialogTab3:new()
            self.layerTab3=self.acTab3:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab3)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        if self.layerTab3 then            
            self.layerTab3:setPosition(ccp(0,0))
            self.layerTab3:setVisible(true)
        end
    elseif idx==2 then
        if self.acTab2==nil then 
			self.acTab2=playerCustomDialogTab2:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
        if self.layerTab2 then            
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
        end
    end
end

function playerCustomDialog:tick( )
    if self and self.acTab1 and self.acTab1.tick then
        self.acTab1:tick()
    end
    if self and self.acTab2 and self.acTab2.tick then
        self.acTab2:tick()
    end
    if self and self.acTab3 and self.acTab3.tick then
        self.acTab3:tick()
    end
end

function playerCustomDialog:dispose( )
	
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

    self.tv =nil
    self =nil
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/chat_image.plist")
    spriteController:removeTexture("public/chat_image.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end