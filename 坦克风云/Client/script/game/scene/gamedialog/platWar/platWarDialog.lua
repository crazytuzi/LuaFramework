require "luascript/script/game/scene/gamedialog/platWar/platWarDialogTab1"
require "luascript/script/game/scene/gamedialog/platWar/platWarDialogTab2"
require "luascript/script/game/scene/gamedialog/platWar/platWarDialogTab3"
platWarDialog=commonDialog:new()

function platWarDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarPIcon.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWar.plist")
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarFireMv.plist")
	return nc
end

function platWarDialog:resetTab()
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
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function platWarDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)

	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:getDataByType(idx+1)
end

function platWarDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			local function getWarInfoHandler()
				self.tab1=platWarDialogTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
			end
			platWarVoApi:getWarInfo(getWarInfoHandler)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			local function getInfoHandler()
				self.tab2=platWarDialogTab2:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			end
			platWarVoApi:getInfo(getInfoHandler)
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			local function getInfoHandler()
				local function formatPointDetailHandler()
					self.tab3=platWarDialogTab3:new()
					self.layerTab3=self.tab3:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab3)
					if(self.selectedTabIndex==2)then
						self:switchTab(3)
					end
				end
				platWarVoApi:formatPointDetail(formatPointDetailHandler)
			end
			platWarVoApi:getInfo(getInfoHandler)
		else
			self:switchTab(3)
		end
	end
end

function platWarDialog:switchTab(type)
	if type==nil then
		type=1
	end
	for i=1,3 do
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

function platWarDialog:tick()
	if(self["tab"..(self.selectedTabIndex + 1)] and self["tab"..(self.selectedTabIndex + 1)].tick)then
		self["tab"..(self.selectedTabIndex + 1)]:tick()
	end
end

function platWarDialog:dispose()
	if platWarVoApi:checkStatus()<30 then
		platWarVoApi:setTroopsFlag(-1)
	end
	for i=1,3 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarPIcon.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarPIcon.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarFireMv.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarFireMv.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end