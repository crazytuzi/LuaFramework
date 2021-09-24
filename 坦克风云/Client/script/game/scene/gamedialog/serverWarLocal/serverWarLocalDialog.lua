require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalDialogTab1"
require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalDialogTab2"
-- require "luascript/script/config/gameconfig/localWar/localWarMapCfg"
serverWarLocalDialog=commonDialog:new()

function serverWarLocalDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	-- self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	-- self.layerTab3=nil
	self.expireTime=0
	self.exTimeTb=nil
	self.callbackNum=0
	self.isEnd=false
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWarCityIcon.plist")
	return nc
end

function serverWarLocalDialog:resetTab()
	self.panelLineBg:setVisible(false)
	G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-158)
	local index=0
	local tabHeight=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		-- elseif index==2 then
		-- 	tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		end
		if index==self.selectedTabIndex then
	     	tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	-- self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	-- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	self.expireTime=base.serverTime
	local noticeTime = serverWarLocalCfg.getSignUp
	local signuptime=serverWarLocalVoApi.startTime + serverWarLocalCfg.signuptime*3600*24 + noticeTime
	local battleEnd11=serverWarLocalVoApi.startTime + serverWarLocalCfg.signuptime*3600*24 + serverWarLocalCfg.startWarTime["a"][1]*3600 + serverWarLocalCfg.startWarTime["a"][2]*60 + serverWarLocalCfg.maxBattleTime + 300 + noticeTime
	local battleEnd12=serverWarLocalVoApi.startTime + serverWarLocalCfg.signuptime*3600*24 + serverWarLocalCfg.startWarTime["b"][1]*3600 + serverWarLocalCfg.startWarTime["b"][2]*60 + serverWarLocalCfg.maxBattleTime + 300 + noticeTime
	local battleEnd21=battleEnd11+86400
	local battleEnd22=battleEnd12+86400
	self.exTimeTb={signuptime,signuptime+5,signuptime+10,battleEnd11,battleEnd12,battleEnd21,battleEnd22,serverWarLocalVoApi.endTime}
	for k,v in pairs(self.exTimeTb) do
		if base.serverTime<v then
			self.expireTime=v
			break
		end
	end
	self.isEnd=serverWarLocalVoApi:isEndOftwoBattle()
end

function serverWarLocalDialog:tabClick(idx)
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

function serverWarLocalDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			-- local function getWarInfoHandler()
				self.tab1=serverWarLocalDialogTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
			-- end
			-- worldWarVoApi:getWarInfo(getWarInfoHandler)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			self.tab2=serverWarLocalDialogTab2:new(false)
			self.layerTab2=self.tab2:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab2)
			if(self.selectedTabIndex==1)then
				self:switchTab(2)
			end
		else
			self:switchTab(2)
		end
	-- elseif(type==3)then
	-- 	if(self.tab3==nil)then
	-- 		-- local function getWarInfoHandler()
	-- 		-- 	local function callback3()
	-- 				self.tab3=serverWarLocalDialogTab3:new()
	-- 				self.layerTab3=self.tab3:init(self.layerNum,self)
	-- 				self.bgLayer:addChild(self.layerTab3)
	-- 				if(self.selectedTabIndex==2)then
	-- 					self:switchTab(3)
	-- 				end
	-- 		-- 	end
	-- 		-- 	serverWarTeamVoApi:getShopAndBetInfo(callback3)
	-- 		-- end
	-- 		-- serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
	-- 	else
	-- 		self:switchTab(3)
	-- 	end
	end
end

function serverWarLocalDialog:switchTab(type)
	if type==nil then
		type=1
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

function serverWarLocalDialog:tick()
	-- local warStatus=worldWarVoApi:checkStatus()
	-- if(self.warStatus and self.warStatus>0 and warStatus==0)then
	-- 	self:close()
	-- 	do return end
	-- end
	-- self.warStatus=warStatus
	for i=1,2 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end

	-- if self.selectedTabIndex~=2 then
	-- 	local initFlag=worldWarVoApi:getInitFlag()
	-- 	if initFlag and initFlag==1 then
	-- 		local shopHasOpen=worldWarVoApi:getShopHasOpen()
	-- 		if shopHasOpen==false then
	-- 			self:setIconTipVisibleByIdx(true,3)
	-- 		else
	-- 			self:setIconTipVisibleByIdx(false,3)
	-- 		end
	-- 	end
	-- end

	-- print("base.serverTime",base.serverTime)
	-- print("self.expireTime",self.expireTime)
	if (base.serverTime>self.expireTime or self.isEnd~=serverWarLocalVoApi:isEndOftwoBattle()) and self.callbackNum<3 then
		if (self.exTimeTb and SizeOfTable(self.exTimeTb)>0 and base.serverTime<self.exTimeTb[SizeOfTable(self.exTimeTb)]) or self.isEnd~=serverWarLocalVoApi:isEndOftwoBattle() then
			local function initCallback( ... )
				for k,v in pairs(self.exTimeTb) do
					if base.serverTime<v then
						self.expireTime=v
						break
					end
				end
				self.callbackNum=0
				self.isEnd=serverWarLocalVoApi:isEndOftwoBattle()
			end
			serverWarLocalVoApi:getInitData(initCallback)
			self.callbackNum=self.callbackNum+1
			serverWarLocalVoApi:getApplyData()
		end
	end
end

function serverWarLocalDialog:doUserHandler()
	if(serverWarLocalFightVoApi and serverWarLocalFightVoApi.disconnectSocket2)then
		serverWarLocalFightVoApi:disconnectSocket2() --进入功能之前先断掉其他功能的跨服连接
	end
end

function serverWarLocalDialog:dispose()
	for i=1,2 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.tab1=nil
	self.tab2=nil
	-- self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	-- self.layerTab3=nil
	self.expireTime=0
	self.exTimeTb=nil
	self.callbackNum=0
	self.isEnd=false
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWarCityIcon.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWarCityIcon.png")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/slotMachine.plist")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/heroRecruitImage.pvr.ccz")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
	-- CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")

	if G_isCompressResVersion()==true then		
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.png")
	else
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.pvr.ccz")
	end
	if(serverWarLocalFightVoApi and serverWarLocalFightVoApi.disconnectSocket2)then
		serverWarLocalFightVoApi:disconnectSocket2() --退出功能断开跨服连接
	end
end