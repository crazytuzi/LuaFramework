require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogTab1"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogTab2"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogTab3"
serverWarTeamDialog=commonDialog:new()

function serverWarTeamDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	self.isShowTip=false
	self.status=nil
	return nc
end

function serverWarTeamDialog:resetTab()
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

	self.status=serverWarTeamVoApi:checkStatus()
end

function serverWarTeamDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	if idx==1 then
		local setFleetStatus=serverWarTeamVoApi:getSetFleetStatus()
		if setFleetStatus==0 or setFleetStatus==6 then
		else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_cannot_set_fleet"..setFleetStatus,{serverWarTeamCfg.joinlv}),30)

			for k,v in pairs(self.allTabs) do
				if self.oldSelectedTabIndex==v:getTag() then
					v:setEnabled(false)
				else
					v:setEnabled(true)
				end
			end
			self.selectedTabIndex=self.oldSelectedTabIndex
	        self:tabClickColor(self.selectedTabIndex)
			do return end
		end
	end

	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:resetForbidLayer()
	self:getDataByType(idx+1)

	-- if idx==2 then
	-- 	serverWarTeamVoApi:setShopHasOpen()
	-- 	self:setIconTipVisibleByIdx(false,3)
	-- end
end

function serverWarTeamDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			local function callback11()
				self.tab1=serverWarTeamDialogTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
			end
			serverWarTeamVoApi:getWarInfo(callback11)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			local function callback2()
				self.tab2=serverWarTeamDialogTab2:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			end
			serverWarTeamVoApi:getWarInfo(callback2)
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			local function getWarInfoHandler()
				local function callback3()
					self.tab3=serverWarTeamDialogTab3:new()
					self.layerTab3=self.tab3:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab3)
					if(self.selectedTabIndex==2)then
						self:switchTab(3)
					end
				end
				serverWarTeamVoApi:getShopAndBetInfo(callback3)
			end
			serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
		else
			self:switchTab(3)
		end
	end
end

function serverWarTeamDialog:switchTab(type)
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

function serverWarTeamDialog:tick()
	for i=1,3 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end

	local isAllSet=serverWarTeamVoApi:getIsAllSetFleet()
	if isAllSet==false or serverWarTeamVoApi:getLeftGems()==true then
		self:setIconTipVisibleByIdx(true,2)
	else
		self:setIconTipVisibleByIdx(false,2)
	end

	-- if self.selectedTabIndex~=2 then
	-- 	local shopHasOpen=serverWarTeamVoApi:getShopHasOpen()
	-- 	if shopHasOpen==false then
	-- 		self:setIconTipVisibleByIdx(true,3)
	-- 	else
	-- 		self:setIconTipVisibleByIdx(false,3)
	-- 	end
	-- end

	local shopFlag=serverWarTeamVoApi:getShopFlag()
	if shopFlag==-1 then
		local function getShopAndBetInfoHandler()
			serverWarTeamVoApi:setShopFlag(1)
			serverWarTeamVoApi:formatRankList()
		end
	    serverWarTeamVoApi:getShopAndBetInfo(getShopAndBetInfoHandler)
	end

	local checkStatus=serverWarTeamVoApi:checkStatus()
	if self.status~=checkStatus then
		self.status=checkStatus
		serverWarTeamVoApi:setWarInfoExpireTime(0)
		serverWarTeamVoApi:getWarInfo()
	end
end

function serverWarTeamDialog:doUserHandler()
	if(serverWarTeamFightVoApi and serverWarTeamFightVoApi.disconnectSocket2)then
		serverWarTeamFightVoApi:disconnectSocket2() --进入功能之前先断掉其他功能的跨服连接
	end
end

function serverWarTeamDialog:dispose()
	for i=1,3 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.status=nil
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.pvr.ccz")
	if(serverWarTeamFightVoApi and serverWarTeamFightVoApi.disconnectSocket2)then
		serverWarTeamFightVoApi:disconnectSocket2() --进入功能之前先断掉其他功能的跨服连接
	end
end