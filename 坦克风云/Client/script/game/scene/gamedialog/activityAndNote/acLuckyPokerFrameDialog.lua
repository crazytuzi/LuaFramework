acLuckyPokerFrameDialog=commonDialog:new()

function acLuckyPokerFrameDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil

	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	spriteController:addPlist("public/acNewYearsEva.plist")
	spriteController:addTexture("public/acNewYearsEva.png")
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	spriteController:addTexture("public/allianceWar2/allianceWar2.png")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFeixutansuo.plist")
	return nc
end

function acLuckyPokerFrameDialog:resetTab()
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

function acLuckyPokerFrameDialog:initTableView()
	
	local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
	self:tabClick(0,false)
end
function acLuckyPokerFrameDialog:tabClick(idx,isEffect)
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
			self.acTab1=acLuckyPokerNewDialog:new()			
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
			self.acTab2=acLuckyPokerTankReformDialog:new()
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
		end
	end
end
function acLuckyPokerFrameDialog:tick()
	local vo=acLuckyPokerVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
		self.acTab1:tick()
	end
	if self and self.bgLayer and self.acTab2 and self.acTab2.tick then 
		self.acTab2:tick()
	end
end
function acLuckyPokerFrameDialog:fastTick()
    if self.acTab1 then
        self.acTab1:fastTick()
    end
end

function acLuckyPokerFrameDialog:dispose()
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
	spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end