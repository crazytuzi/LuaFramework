acWpbdDialog=commonDialog:new()

function acWpbdDialog:new(layerNum)
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

function acWpbdDialog:resetTab()
	require "luascript/script/game/scene/gamedialog/activityAndNote/sellShowSureDialog"
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/addOtherImage.plist")
	spriteController:addTexture("public/addOtherImage.png")
	spriteController:addPlist("public/acWpbdImage.plist")
	spriteController:addTexture("public/acWpbdImage.png")
	spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")
    spriteController:addPlist("public/juntuanCityBtns.plist")
    spriteController:addTexture("public/juntuanCityBtns.png")
    spriteController:addPlist("public/acSuperShopImage.plist")
	spriteController:addTexture("public/acSuperShopImage.png")
	spriteController:addPlist("public/bgFireImage.plist")
    spriteController:addTexture("public/bgFireImage.png")
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
	-- local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	-- topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	-- topBorder:setAnchorPoint(ccp(0,1))
	-- topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	-- self.bgLayer:addChild(topBorder)

	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
    self.bgLayer:addChild(tabLine,5)
	
	self.panelBg_Shade=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
	self.panelBg_Shade:setAnchorPoint(ccp(0.5,0))
	self.panelBg_Shade:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
	self.panelBg_Shade:setPosition(G_VisibleSizeWidth * 0.5,5)
	self.bgLayer:addChild(self.panelBg_Shade)

	self:tabClick(0)
end

function acWpbdDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acWpbdDialog:tabClick(idx)
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

function acWpbdDialog:switchTab(type)
	if type==nil then
		type=1
	end

	self.useTipSp =  tolua.cast(self.allTabs[2]:getChildByTag(101),"CCSprite")
	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acWpbdTabOne:new(self)
	   		else
	   			tab=acWpbdTabTwo:new(self)
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
	if type== 2 then
		self:refresh(type)
	end
end

function acWpbdDialog:refresh( tab )
    if tab ==2 then
        if self.tab2 then
            self.tab2:refresh()
        end
    end
end
function acWpbdDialog:doUserHandler()
end

function acWpbdDialog:tick()
	local acVo = acWpbdVoApi:getAcVo()
	if activityVoApi:isStart(acVo)==true then
		if self and self.tab1 and self.tab1.tick then
			self.tab1:tick()
		end
		if self and self.tab2 and self.tab2.tick then
			self.tab2:tick()
		end

		if acWpbdVoApi:canExchange( ) then
			self.useTipSp:setVisible(true)	
		else
			self.useTipSp:setVisible(false)	
		end
	else
		self:close()
	end
end
function acWpbdDialog:fastTick( )
	local acVo = acWpbdVoApi:getAcVo()
	if activityVoApi:isStart(acVo)==true then
		if self and self.tab1 and self.tab1.fastTick then
			self.tab1:fastTick()
		end
	else
		self:close()
	end
end

function acWpbdDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then
		self.tab2:dispose()
	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	self.panelBg_Shade = nil
	spriteController:removePlist("public/addOtherImage.plist")
	spriteController:removeTexture("public/addOtherImage.png")
	spriteController:removePlist("public/acWpbdImage.plist")
	spriteController:removeTexture("public/acWpbdImage.png")
	spriteController:removePlist("public/juntuanCityBtns.plist")
	spriteController:removeTexture("public/juntuanCityBtns.png")
	spriteController:removePlist("public/acSuperShopImage.plist")
	spriteController:removeTexture("public/acSuperShopImage.png")
	spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removeTexture("public/bgFireImage.plist")
    spriteController:removeTexture("public/bgFireImage.png")
end
