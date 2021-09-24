acDuanWuDialog=commonDialog:new()

function acDuanWuDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	self.panelBg_Shade = nil
	return nc
end

function acDuanWuDialog:resetTab()
	--acDuanWuImage
	require "luascript/script/game/scene/gamedialog/activityAndNote/sellShowSureDialog"
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    spriteController:addPlist("public/acSuperShopImage.plist")
		spriteController:addTexture("public/acSuperShopImage.png")
		spriteController:addPlist("public/acDuanWuImage.plist")--
		spriteController:addTexture("public/acDuanWuImage.png")
		spriteController:addPlist("public/acDouble11_NewImage.plist")
		spriteController:addTexture("public/acDouble11_NewImage.png")
		if acDuanWuVoApi:getVersion( ) ~= 1 then
			spriteController:addPlist("public/youhuaUI4.plist")
		   	spriteController:addTexture("public/youhuaUI4.png")
		end
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
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)

	self.panelBg_Shade=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
	self.panelBg_Shade:setAnchorPoint(ccp(0.5,0))
	self.panelBg_Shade:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
	self.panelBg_Shade:setPosition(G_VisibleSizeWidth * 0.5,5)
	self.bgLayer:addChild(self.panelBg_Shade)

	self:tabClick(0)
end

function acDuanWuDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acDuanWuDialog:tabClick(idx)
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

function acDuanWuDialog:switchTab(type)
	if type==nil then
		type=1
	end

	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acDuanWuTabOne:new(self)
	   		else
	   			tab=acDuanWuTabTwo:new(self)
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

function acDuanWuDialog:refresh( tab )
    -- if tab ==2 then
    --     if self.tab2 then
    --         self.tab2:refresh()
    --     end
    -- end
end
function acDuanWuDialog:doUserHandler()
end

function acDuanWuDialog:tick()
	local acVo = acDuanWuVoApi:getAcVo()
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

function acDuanWuDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then

	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	self.panelBg_Shade = nil
	spriteController:removePlist("public/acDuanWuImage.plist")
	spriteController:removeTexture("public/acDuanWuImage.png")
	spriteController:removePlist("public/acSuperShopImage.plist")
	spriteController:removeTexture("public/acSuperShopImage.png")
	spriteController:removePlist("public/acDouble11_NewImage.plist")
	spriteController:removeTexture("public/acDouble11_NewImage.png")
	if acDuanWuVoApi:getVersion( ) ~= 1 then
		spriteController:removePlist("public/youhuaUI4.plist")
	   	spriteController:removeTexture("public/youhuaUI4.png")
	end
end
