platWarPlayerListDialog=commonDialog:new()

function platWarPlayerListDialog:new(platID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.platID=platID
	nc.playerList=platWarVoApi:getPlayerList()[platID]
	return nc
end

function platWarPlayerListDialog:resetTab()
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	local posY=G_VisibleSizeHeight - 130
	local rankLb=GetTTFLabel(getlocal("alliance_scene_rank"),25)
	rankLb:setColor(G_ColorGreen)
	rankLb:setPosition(ccp(70,posY))
	self.bgLayer:addChild(rankLb)
	local nameLb=GetTTFLabel(getlocal("RankScene_name"),25)
	nameLb:setColor(G_ColorGreen)
	nameLb:setPosition(ccp(250,posY))
	self.bgLayer:addChild(nameLb)
	local serverLb=GetTTFLabel(getlocal("serverwar_server_name"),25)
	serverLb:setColor(G_ColorGreen)
	serverLb:setPosition(ccp(430,posY))
	self.bgLayer:addChild(serverLb)
	local powerLb=GetTTFLabel(getlocal("showAttackRank"),25)
	powerLb:setColor(G_ColorGreen)
	powerLb:setPosition(ccp(550,posY))
	self.bgLayer:addChild(powerLb)
	local selfPowerLb=GetTTFLabel(getlocal("plat_war_myPower",{FormatNumber(playerVoApi:getPlayerPower())}),25)
	selfPowerLb:setColor(G_ColorYellowPro)
	selfPowerLb:setAnchorPoint(ccp(0,0))
	selfPowerLb:setPosition(ccp(40,70))
	self.bgLayer:addChild(selfPowerLb)
	if(self.platID==base.serverPlatID)then
		local selfPlayer=platWarVoApi:getPlayer()
		local selfRank
		if(selfPlayer)then
			selfRank=selfPlayer.rank
		else
			selfRank="100+"
		end
		local selfRankLb=GetTTFLabel(getlocal("plat_war_my_rank",{selfRank}),25)
		selfRankLb:setColor(G_ColorYellowPro)
		selfRankLb:setAnchorPoint(ccp(0,0))
		selfRankLb:setPosition(ccp(40,30))
		self.bgLayer:addChild(selfRankLb)
	else
		selfPowerLb:setPosition(ccp(40,50))
	end
	local function onHelp( ... )
		PlayEffect(audioCfg.mouseClick)
		local tabStr = {"\n",getlocal("plat_war_playerHelp"),"\n"}
		local tabColor = {nil,G_ColorYellow,nil}
		local sd=smallDialog:new()
		local dialogLayer=sd:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum + 1,tabStr,25,tabColor)
		sceneGame:addChild(dialogLayer,self.layerNum+1)
	end
	local helpBtn=LuaCCSprite:createWithSpriteFrameName("SlotInfor.png",onHelp)
	helpBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	helpBtn:setPosition(ccp(G_VisibleSizeWidth - 100,60))
	self.bgLayer:addChild(helpBtn)
end

function platWarPlayerListDialog:initTableView( ... )
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function() end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 250))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(ccp(30, 100))
	self.bgLayer:addChild(tvBg)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 260),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,105))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

function platWarPlayerListDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.playerList
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(G_VisibleSizeWidth - 60,100)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSP:setScaleX((G_VisibleSizeWidth - 60)/lineSP:getContentSize().width)
		lineSP:setPosition(ccp((G_VisibleSizeWidth - 60)/2,0))
		cell:addChild(lineSP)
		local playerVo=self.playerList[idx + 1]
		local rankSp
		if(playerVo.rank<=3)then
			rankSp=CCSprite:createWithSpriteFrameName("top"..playerVo.rank..".png")
		else
			rankSp=GetTTFLabel(playerVo.rank,25)
		end
		rankSp:setPosition(ccp(40,50))
		cell:addChild(rankSp)
		local nameLb=GetTTFLabel(playerVo.name,25)
		nameLb:setPosition(ccp(220,50))
		cell:addChild(nameLb)
		local serverLb=GetTTFLabel(playerVo.serverID,25)
		serverLb:setPosition(ccp(400,50))
		cell:addChild(serverLb)
		local powerLb=GetTTFLabel(FormatNumber(playerVo.power),25)
		powerLb:setPosition(ccp(520,50))
		cell:addChild(powerLb)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
	end
end