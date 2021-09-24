acSmcjDialog=commonDialog:new()

function acSmcjDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	return nc
end

function acSmcjDialog:resetTab()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
	spriteController:addPlist("public/taskYouhua.plist")
	spriteController:addTexture("public/taskYouhua.png")
	spriteController:addPlist("public/acRadar_images.plist")
	spriteController:addTexture("public/acRadar_images.png")
	spriteController:addPlist("public/newTopBgImage1.plist")
	spriteController:addTexture("public/newTopBgImage1.png")
	spriteController:addPlist("public/acSmcjIconImage.plist")
	spriteController:addTexture("public/acSmcjIconImage.png")
	spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local index=0
	for k,v in pairs(self.allTabs) do
		 local  tabBtnItem=v

		 if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		else
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		 end
		 if index==self.selectedTabIndex then
			 tabBtnItem:setEnabled(false)
		 end
		 index=index+1
	end

	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)

	if acSmcjVoApi:isRewardTime() then
		self:tabClick(1)
	else
		self:tabClick(0)
	end
end

function acSmcjDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acSmcjDialog:tabClick(idx)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
	if idx + 1 == 2 then
		local function callback( )
			self["tab2"]:updataRank()
		end 
		acSmcjVoApi:socketRank(callback)
	end
end

function acSmcjDialog:switchTab(type)
	if type==nil then
		type=1
	end

	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acSmcjTabOne:new(self)
	   		else
	   			tab=acSmcjTabTwo:new(self)
	   		end
		   	self["tab"..type]=tab
		   	self["layerTab"..type]=tab:init(self.layerNum)
		   	self.bgLayer:addChild(self["layerTab"..type])
	   	end
		for i=1,2 do
			if(i==type)then
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(0,0))
					self["layerTab"..i]:setVisible(true)
				end
			else
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(999333,0))
					self["layerTab"..i]:setVisible(false)
				end
			end
		end
	end 

	showTab()
end

function acSmcjDialog:refresh( tab )

end
function acSmcjDialog:doUserHandler()
end

function acSmcjDialog:tick()
	if acSmcjVoApi:isEnd()==true then
        self:close()
        do return end
    end

	if self and self.tab1 and self.tab1.tick then
		self.tab1:tick()
	end
	if self and self.tab2 and self.tab2.tick then
		self.tab2:tick()
	end
end

function acSmcjDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then

	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	spriteController:removePlist("public/taskYouhua.plist")
	spriteController:removeTexture("public/taskYouhua.png")
	spriteController:removePlist("public/acRadar_images.plist")
	spriteController:removeTexture("public/acRadar_images.png")
	spriteController:removePlist("public/newTopBgImage1.plist")
	spriteController:removeTexture("public/newTopBgImage1.png")
	spriteController:removePlist("public/acSmcjIconImage.plist")
	spriteController:removeTexture("public/acSmcjIconImage.png")
	spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
end