acHljbDialog=commonDialog:new()

function acHljbDialog:new(layerNum)
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

function acHljbDialog:resetTab()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- spriteController:addPlist("public/acHljbImage.plist")
    -- spriteController:addTexture("public/acHljbImage.png")
    spriteController:addPlist("public/acRadar_images.plist")
	spriteController:addTexture("public/acRadar_images.png")
	spriteController:addPlist("public/acHljbImage1.plist")
	spriteController:addTexture("public/acHljbImage1.png")
	spriteController:addPlist("public/acHljbImage2.plist")
	spriteController:addTexture("public/acHljbImage2.png")
	spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    spriteController:addPlist("public/believer/believerMain.plist")
    spriteController:addTexture("public/believer/believerMain.plist")
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

	self.panelLineBg:setVisible(false)
	self.panelShadeBg:setVisible(true)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)

	local iddx = acHljbVoApi:isExTime() and 1 or 0
	self:tabClick(iddx)
	if iddx > 0 then
		self:tabClickColor(iddx)
	end
end

function acHljbDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acHljbDialog:tabClick(idx)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
end

function acHljbDialog:switchTab(type)
	if type==nil then
		type=1
	end

	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acHljbTabOne:new(self)
	   		else
	   			tab=acHljbTabTwo:new(self)
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

function acHljbDialog:refresh( tab )

end
function acHljbDialog:doUserHandler()
end

function acHljbDialog:tick()
	local acVo = acHljbVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
		if self and self.tab1 and self.tab1.tick then
			self.tab1:tick()
		end
		if self and self.tab2 and self.tab2.tick then
			self.tab2:tick()
		end
	else
		self:close()
	end
end

function acHljbDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then

	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	-- spriteController:removePlist("public/acHljbImage.plist")--trackingImage
 --    spriteController:removeTexture("public/acHljbImage.png")
	spriteController:removePlist("public/acRadar_images.plist")
	spriteController:removeTexture("public/acRadar_images.png")
	spriteController:removePlist("public/acHljbImage1.plist")
	spriteController:removeTexture("public/acHljbImage1.png")
	spriteController:removePlist("public/acHljbImage2.plist")
	spriteController:removeTexture("public/acHljbImage2.png")
	spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz") 
    spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
end