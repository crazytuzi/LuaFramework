--在军团跨服战中点击城市弹出的小面板
serverWarTeamCitySmallDialog=smallDialog:new()

--param cityID: 城市ID, a1到a11
function serverWarTeamCitySmallDialog:new(cityID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.cityID=cityID
	nc.data=serverWarTeamFightVoApi:getCity(cityID)

	nc.dialogWidth=590
	nc.explodeArr={}
	if(nc.data.cfg.type==1)then
		nc.dialogHeight=760
	else
		nc.dialogHeight=720
	end
	return nc
end

function serverWarTeamCitySmallDialog:init(layerNum)
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	self:refreshPlayers()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function serverWarTeamCitySmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self.bgLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.dialogLayer:addChild(self.bgLayer,1)
	self:show()
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleStr=getlocal("serverwarteam_cityName"..self.cityID)
	local titleLb=GetTTFLabel(titleStr,30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local contentBg=CCSprite:createWithSpriteFrameName("platWarPosterBg.jpg")
	contentBg:setScaleX((self.dialogWidth - 20)/contentBg:getContentSize().width)
	contentBg:setScaleY((self.dialogHeight - 185)/contentBg:getContentSize().height)
	contentBg:setAnchorPoint(ccp(0.5,0))
	contentBg:setPosition(self.dialogWidth/2,100)
	dialogBg:addChild(contentBg)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
end

function serverWarTeamCitySmallDialog:initContent()
	local function nilFunc()
	end
	base:addNeedRefresh(self)
	local function eventListener(event,data)
		self:dealEvent(event,data)
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("serverWarTeam.battle",eventListener)
	local posY=self.dialogHeight - 85
	if(self.data.cfg.type==1)then
		local hpBg=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),nilFunc)
		hpBg:setContentSize(CCSizeMake(self.dialogWidth - 20,50))
		hpBg:setAnchorPoint(ccp(0.5,1))
		hpBg:setPosition(self.dialogWidth/2,posY)
		self.bgLayer:addChild(hpBg)
		self.hpLb=GetTTFLabel(getlocal("serverwar_team_baseHp",{self.data.hp,serverWarTeamCfg.baseBlood}),28)
		self.hpLb:setPosition(self.dialogWidth/2,posY - 25)
		self.bgLayer:addChild(self.hpLb)
		posY=posY - 50
	end
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(0,0,120,36),nilFunc)
	titleBg:setContentSize(CCSizeMake(self.dialogWidth - 20,80))
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(titleBg)

	self.vsPic1=CCSprite:createWithSpriteFrameName("v.png")
	self.vsPic2=CCSprite:createWithSpriteFrameName("s.png")
	self.vsPic1:setScale(70/self.vsPic1:getContentSize().width)
	self.vsPic2:setScale(70/self.vsPic2:getContentSize().width)
	self.vsPic1:setPosition(self.dialogWidth/2 - 30,posY - 40)
	self.vsPic2:setPosition(self.dialogWidth/2 + 30,posY - 40)
	self.vsPic1:setVisible(false)
	self.vsPic2:setVisible(false)
	self.bgLayer:addChild(self.vsPic1)
	self.bgLayer:addChild(self.vsPic2)

	local nameTitle1,nameTitle2
	self.selfSide=serverWarTeamFightVoApi:getPlayer().side
	if(self.selfSide==1)then
		nameTitle1=GetTTFLabel(getlocal("local_war_alliance_feat_own"),25)
		nameTitle2=GetTTFLabel(getlocal("plat_war_enemy"),25)
	else
		nameTitle1=GetTTFLabel(getlocal("plat_war_enemy"),25)
		nameTitle2=GetTTFLabel(getlocal("local_war_alliance_feat_own"),25)
	end
	nameTitle1:setTag(101)
	nameTitle1:setColor(G_ColorRed)
	nameTitle1:setVisible(false)
	nameTitle1:setPosition((self.dialogWidth/2 - 150)/2,posY - 20)
	self.bgLayer:addChild(nameTitle1)
	nameTitle2:setTag(102)
	nameTitle2:setColor(G_ColorBlue)
	nameTitle2:setPosition(self.dialogWidth - (self.dialogWidth/2 - 150)/2,posY - 20)
	nameTitle2:setVisible(false)
	self.bgLayer:addChild(nameTitle2)

	self.nameLb1=GetTTFLabel("",25)
	self.nameLb1:setVisible(false)
	self.nameLb1:setPosition((self.dialogWidth/2 - 150)/2,posY - 50)
	self.bgLayer:addChild(self.nameLb1)
	self.nameLb2=GetTTFLabel("",25)
	self.nameLb2:setVisible(false)
	self.nameLb2:setPosition(self.dialogWidth - (self.dialogWidth/2 - 150)/2,posY - 50)
	self.bgLayer:addChild(self.nameLb2)

	if(self.data.cfg.type==3)then
		if(self.selfSide==self.data:getSide())then
			self.peaceLb=GetTTFLabel(getlocal("serverwarteam_occupy1"),25)
		else
			self.peaceLb=GetTTFLabel(getlocal("serverwarteam_occupy2"),25)
		end
	else
		if(self.data:getSide()==0)then
			self.peaceLb=GetTTFLabel(getlocal("local_war_cityStatus2"),25)
		else
			self.peaceLb=GetTTFLabel(getlocal("serverwar_team_noBattle"),25)
		end
	end
	self.peaceLb:setColor(G_ColorYellowPro)
	self.peaceLb:setVisible(false)
	self.peaceLb:setPosition(self.dialogWidth/2,posY - 40)
	self.bgLayer:addChild(self.peaceLb)

	posY=posY - 80 - 40
	local progressBg=CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
	progressBg:setScaleX((self.dialogWidth - 160)/progressBg:getContentSize().width)
	progressBg:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(progressBg)
	local progress1,progress2
	progress1=CCSprite:createWithSpriteFrameName("platWarProgress1.png")
	self.progress=CCProgressTimer:create(progress1)
	self.progress:setType(kCCProgressTimerTypeBar)
	self.progress:setMidpoint(ccp(0,0))
	self.progress:setBarChangeRate(ccp(1,0))
	self.progress:setPosition(ccp(self.dialogWidth/2,posY))
	progress2=CCSprite:createWithSpriteFrameName("platWarProgress2.png")
	progress2:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(progress2)
	self.bgLayer:addChild(self.progress)
	self.progressGray=GraySprite:createWithSpriteFrameName("platWarProgress1.png")
	self.progressGray:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(self.progressGray)
	if(self.data:getSide()>0)then
		self.progressGray:setVisible(false)
	end

	self.tankSp1=CCSprite:create("public/tankShape.png")
	self.tankSp1:setPosition(80,posY)
	self.bgLayer:addChild(self.tankSp1,3)
	self.tankSp2=CCSprite:create("public/tankShape.png")
	self.tankSp2:setFlipX(true)
	self.tankSp2:setPosition(self.dialogWidth - 80,posY)
	self.bgLayer:addChild(self.tankSp2,3)

	posY=posY - 20
	self:initTab(posY)
	local function onOrder()
		serverWarTeamFightVoApi:showCityOrderDialog(self.cityID,self.layerNum + 1)
	end
	local orderItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onOrder,1,getlocal("local_war_command"),25)
	local orderBtn=CCMenu:createWithItem(orderItem)
	local function onGoto()
		self:gotoCity()
	end
	local gotoStr
	local selfCityID=serverWarTeamFightVoApi:getPlayer().cityID
	if(selfCityID==serverWarTeamFightVoApi:getMapCfg().airport[1] or selfCityID==serverWarTeamFightVoApi:getMapCfg().airport[2])then
		local flag=false
		for k,v in pairs(serverWarTeamFightVoApi:getMapCfg().flyCity[selfCityID]) do
			if(v==self.cityID)then
				flag=true
				break
			end
		end
		if(flag)then
			gotoStr=getlocal("serverwarteam_land")
		else
			gotoStr=getlocal("activity_heartOfIron_goto")
		end
	else
		gotoStr=getlocal("activity_heartOfIron_goto")
	end
	local gotoItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onGoto,1,gotoStr,25)
	local gotoBtn=CCMenu:createWithItem(gotoItem)
	gotoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(gotoBtn)
	if(serverWarTeamFightVoApi:getPlayer().role and serverWarTeamFightVoApi:getPlayer().role>0)then
		orderBtn:setPosition(150,50)
		self.bgLayer:addChild(orderBtn)
		gotoBtn:setPosition(self.dialogWidth - 150,50)
	else
		gotoBtn:setPosition(self.dialogWidth/2,50)
	end
	self:tick()
end

function serverWarTeamCitySmallDialog:initTab(posY)
	local function onClickTab1()
		self:switchTab(1)
	end
	self.tabItem1=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
	self.tabItem1:registerScriptTapHandler(onClickTab1)
	local lb=GetTTFLabelWrap(getlocal("local_war_cityInfo"),20,CCSizeMake(self.tabItem1:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	lb:setPosition(getCenterPoint(self.tabItem1))
	self.tabItem1:addChild(lb)
	local tabBtn1=CCMenu:createWithItem(self.tabItem1)
	tabBtn1:setTouchPriority(-(self.layerNum-1)*20-2)
	tabBtn1:setPosition(100,posY - 40)
	self.bgLayer:addChild(tabBtn1)
	local function onClickTab2()
		self:switchTab(2)
	end
	self.tabItem2=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
	self.tabItem2:registerScriptTapHandler(onClickTab2)
	local lb=GetTTFLabelWrap(getlocal("local_war_battleQueue"),20,CCSizeMake(self.tabItem2:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	lb:setPosition(getCenterPoint(self.tabItem2))
	self.tabItem2:addChild(lb)
	local tabBtn2=CCMenu:createWithItem(self.tabItem2)
	tabBtn2:setTouchPriority(-(self.layerNum-1)*20-2)
	tabBtn2:setPosition(240,posY - 40)
	self.bgLayer:addChild(tabBtn2)
	local tabBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(30,30,20,20),onClickTab1)
	tabBg:setContentSize(CCSizeMake(self.dialogWidth - 40,posY - 160))
	tabBg:setAnchorPoint(ccp(0.5,0))
	tabBg:setPosition(self.dialogWidth/2,100)
	self.bgLayer:addChild(tabBg)
	self.tabHeight=posY - 160
	self:switchTab(1)
end

function serverWarTeamCitySmallDialog:switchTab(tabIndex)
	if(self.tabItem1 and self.tabItem2)then
		if(tabIndex==1)then
			self.tabItem1:setEnabled(false)
			self.tabItem2:setEnabled(true)
		else
			self.tabItem1:setEnabled(true)
			self.tabItem2:setEnabled(false)
		end
	end
	self.selectedTab=tabIndex
	if(tabIndex==1)then
		if(self.tab2)then
			self.tab2:setPositionX(999333)
			self.tab2:setVisible(false)
		end
		if(self.tab1)then
			self.tab1:setPositionX(20)
			self.tab1:setVisible(true)
		else
			self:initTab1()
		end
	else
		self.tab1:setPositionX(999333)
		self.tab1:setVisible(false)
		if(self.tab2)then
			self.tab2:setPositionX(20)
			self.tab2:setVisible(true)
		else
			self:initTab2()
		end
	end
end

function serverWarTeamCitySmallDialog:initTab1()
	self.tab1=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	self.tab1:setAnchorPoint(ccp(0,0))
	self.tab1:setPosition(20,100)
	self.tab1:setOpacity(0)
	self.bgLayer:addChild(self.tab1)
	local conditionStr
	if(self.data.cfg.type==1)then
		conditionStr=getlocal("serverwarteam_occupyCondition")
	else
		conditionStr=getlocal("local_war_occupyCondition2")
	end
	local conditionLb1=GetTTFLabel(getlocal("local_war_occupyConditionTitle")..":",25)
	conditionLb1:setAnchorPoint(ccp(0,1))
	conditionLb1:setPosition(10,self.tabHeight - 10)
	self.tab1:addChild(conditionLb1)

	local ownLb1=GetTTFLabel(getlocal("local_war_alliance_belongs",{""}),25)
	local functionLb=GetTTFLabel(getlocal("local_war_help_title7")..": ",25)
	local rightX=10 + math.max(conditionLb1:getContentSize().width,ownLb1:getContentSize().width,functionLb:getContentSize().width)
	local conditionLb2=GetTTFLabelWrap(conditionStr,25,CCSizeMake(self.dialogWidth - 60 - rightX,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionLb2:setAnchorPoint(ccp(0,1))
	conditionLb2:setPosition(rightX,self.tabHeight - 10)
	self.tab1:addChild(conditionLb2)
	local posY=self.tabHeight - 10 - conditionLb2:getContentSize().height - 10
	local ownStr
	if(self.data:getSide()==0)then
		ownStr=getlocal("alliance_info_content")
	else
		if(self.cityID==serverWarTeamFightVoApi:getMapCfg().airport[1])then
			ownStr=serverWarTeamFightVoApi:getAllianceList()[1].name
		elseif(self.cityID==serverWarTeamFightVoApi:getMapCfg().airport[2])then
			ownStr=serverWarTeamFightVoApi:getAllianceList()[2].name
		else
			for k,v in pairs(serverWarTeamFightVoApi:getAllianceList()) do
				if(v.id==self.data.allianceID)then
					ownStr=v.name
					break
				end
			end
		end
		if(ownStr==nil)then
			ownStr=getlocal("alliance_info_content")
		end
	end
	ownLb1:setAnchorPoint(ccp(0,1))
	ownLb1:setPosition(10,posY)
	self.tab1:addChild(ownLb1)
	self.ownLb=GetTTFLabelWrap(ownStr,25,CCSizeMake(self.dialogWidth - 60 - rightX,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.ownLb:setAnchorPoint(ccp(0,1))
	self.ownLb:setPosition(rightX,posY)
	self.tab1:addChild(self.ownLb)
	posY=posY - self.ownLb:getContentSize().height - 10
	functionLb:setAnchorPoint(ccp(0,1))
	functionLb:setPosition(10,posY)
	self.tab1:addChild(functionLb)
	local isAirport
	if(self.data.cfg.type==3)then
		isAirport=true
	else
		isAirport=false
	end
	if(isAirport==false)then
		local functionStr
		if(self.data.cfg.type==1)then
			functionStr=getlocal("serverwarteam_cityFunction1")
		else
			local isRailway=false
			for k,cityID in pairs(serverWarTeamFightVoApi:getMapCfg().railWayCity) do
				if(cityID==self.cityID)then
					isRailway=true
					break
				end
			end
			if(isRailway)then
				functionStr=getlocal("serverwarteam_cityFunction2",{self.data.cfg.winPoint,serverWarTeamCfg.countryRoadTime/60})
			else
				functionStr=getlocal("serverwarteam_cityFunction4",{self.data.cfg.winPoint})
			end
		end
		self.functionLb=GetTTFLabelWrap(functionStr,25,CCSizeMake(self.dialogWidth - 60 - functionLb:getContentSize().width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.functionLb:setColor(G_ColorGreen)
		self.functionLb:setAnchorPoint(ccp(0,1))
		self.functionLb:setPosition(10 + functionLb:getContentSize().width,posY)
		self.tab1:addChild(self.functionLb)
	else
		self.flyIconList={}
		local needPeople=serverWarTeamFightVoApi:getMapCfg().flyNeed
		local posX=10 + functionLb:getContentSize().width + 10
		for i=1,needPeople do
			local icon1=CCSprite:createWithSpriteFrameName("serverWarTIcon1.png")
			icon1:setAnchorPoint(ccp(0,1))
			icon1:setPosition(posX,posY)
			self.tab1:addChild(icon1,1)
			local icon2=CCSprite:createWithSpriteFrameName("serverWarTIcon2.png")
			icon2:setAnchorPoint(ccp(0,1))
			icon2:setPosition(posX,posY)
			self.tab1:addChild(icon2,1)
			icon2:setVisible(false)
			if(i~=needPeople)then
				local line1=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarProgressBg3.png",CCRect(0,2,8,4),function ( ... )end)
				line1:setContentSize(CCSizeMake(52,8))
				line1:setAnchorPoint(ccp(0,0.5))
				line1:setPosition(posX + icon1:getContentSize().width - 2,posY - icon1:getContentSize().height/2)
				self.tab1:addChild(line1)
				local line2=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarProgressBg2.png",CCRect(0,0,4,4),function ( ... )end)
				line2:setContentSize(CCSizeMake(52,6))
				line2:setAnchorPoint(ccp(0,0.5))
				line2:setPosition(posX + icon2:getContentSize().width - 2,posY - icon2:getContentSize().height/2)
				self.tab1:addChild(line2)
				line2:setVisible(false)
				self.flyIconList[i]={icon2,line2}
			else
				self.flyIconList[i]={icon2}
			end
			posX=posX + icon2:getContentSize().width + 48
		end
		self.functionEffectLb=GetTTFLabel("",25)
		self.functionEffectLb:setAnchorPoint(ccp(0,0.5))
		self.functionEffectLb:setPosition(posX - 38,posY - 20)
		self.tab1:addChild(self.functionEffectLb)
		self.functionLb=GetTTFLabelWrap(getlocal("serverwarteam_cityFunction3",{serverWarTeamFightVoApi:getMapCfg().flyNeed,(serverWarTeamFightVoApi:getMapCfg().bombHpPercent*100).."%%"}),25,CCSizeMake(self.dialogWidth - 60 - functionLb:getContentSize().width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.functionLb:setColor(G_ColorGreen)
		self.functionLb:setAnchorPoint(ccp(0,1))
		self.functionLb:setPosition(10 + functionLb:getContentSize().width,posY - 55)
		self.tab1:addChild(self.functionLb)
	end
end

function serverWarTeamCitySmallDialog:initTab2()
	self.tab2=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	self.tab2:setAnchorPoint(ccp(0,0))
	self.tab2:setPosition(20,100)
	self.tab2:setOpacity(0)
	self.bgLayer:addChild(self.tab2)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(50,0,20,36),function ( ... )end)
	titleBg:setContentSize(CCSizeMake(self.dialogWidth - 40,40))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(0,self.tabHeight)
	self.tab2:addChild(titleBg)
	local title1,title2,title3
	if(self.selfSide==1)then
		title1=GetTTFLabel(getlocal("local_war_alliance_feat_own"),25)
		title3=GetTTFLabel(getlocal("plat_war_enemy"),25)
	else
		title1=GetTTFLabel(getlocal("plat_war_enemy"),25)
		title3=GetTTFLabel(getlocal("local_war_alliance_feat_own"),25)
	end
	title2=GetTTFLabel(getlocal("serverwarteam_people"),25)
	title1:setColor(G_ColorRed)
	title2:setColor(G_ColorYellowPro)
	title3:setColor(G_ColorBlue)
	title1:setPosition((self.dialogWidth - 40)/6,self.tabHeight - 20)
	title2:setPosition((self.dialogWidth - 40)/2,self.tabHeight - 20)
	title3:setPosition((self.dialogWidth - 40)*5/6,self.tabHeight - 20)
	self.tab2:addChild(title1)
	self.tab2:addChild(title2)
	self.tab2:addChild(title3)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 40,self.tabHeight - 40),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(0,0))
	self.tv:setMaxDisToBottomOrTop(20)
	self.tab2:addChild(self.tv)
end

function serverWarTeamCitySmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.max(#self.playerList1,#self.playerList2)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.dialogWidth - 40,30)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local playerLb1,indexLb,playerLb2
		local index=idx + 1
		if(self.playerList1[index])then
			playerLb1=GetTTFLabel(self.playerList1[index].name,25)
			if(self.playerList1[index].canMoveTime>base.serverTime)then
				playerLb1:setColor(G_ColorRed)
			end
			playerLb1:setPosition((self.dialogWidth - 40)/6,16)
			cell:addChild(playerLb1)
		end
		if(self.playerList2[index])then
			playerLb2=GetTTFLabel(self.playerList2[index].name,25)
			if(self.playerList2[index].canMoveTime>base.serverTime)then
				playerLb2:setColor(G_ColorRed)
			end
			playerLb2:setPosition((self.dialogWidth - 40)*5/6,16)
			cell:addChild(playerLb2)
		end
		indexLb=GetTTFLabel("-"..index.."-",25)
		indexLb:setColor(G_ColorYellowPro)
		indexLb:setPosition((self.dialogWidth - 40)/2,16)
		cell:addChild(indexLb)
		return cell
	elseif fn=="ccTouchBegan" then
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded"  then
	end
end

function serverWarTeamCitySmallDialog:dealEvent(event,data)
	local eventType=data.type
	if(eventType=="hurt" and self.hpLb)then
		self.hpLb:setString(getlocal("serverwar_team_baseHp",{self.data.hp,serverWarTeamCfg.baseBlood}))
	elseif(eventType=="city")then
		local flag=false
		for k,v in pairs(data) do
			if(v.id==self.cityID)then
				flag=true
				break
			end
		end
		if(flag)then
			local ownStr
			if(self.data.allianceID==0)then
				ownStr=getlocal("alliance_info_content")
			else
				for k,v in pairs(serverWarTeamFightVoApi:getAllianceList()) do
					if(v.id==self.data.allianceID)then
						ownStr=v.name
						break
					end
				end
				if(ownStr==nil)then
					ownStr=getlocal("alliance_info_content")
				end
			end
			self.ownLb:setString(getlocal("local_war_alliance_belongs",{ownStr}))
		end
	elseif(eventType=="player")then
		if(data)then
			local flag=false
			for k,v in pairs(data) do
				if(v.lastCityID==self.cityID or v.cityID==self.cityID)then
					flag=true
					break
				end
			end
			if(flag)then
				self:refreshPlayers()
			end
		end
	elseif(eventType=="npc" and self.data.cfg.type==1)then
		self:refreshPlayers()
	elseif(eventType=="over")then
		self:close()
	end
end

function serverWarTeamCitySmallDialog:refreshPlayers()
	self.playerList1=serverWarTeamFightVoApi:getAllPlayersInCity(self.cityID,1)
	self.playerList2=serverWarTeamFightVoApi:getAllPlayersInCity(self.cityID,2)
	local side=self.data:getSide()
	if(self.data.cfg.type==1)then
		if(side==0)then
			do return end
		end
		for i=serverWarTeamFightVoApi:getBaseTroopsLeft()[side],serverWarTeamFightVoApi:getAllianceList()[side].baseTroops do
			local npcPlayer=serverWarTeamFightVoApi:getPlayer("npc-"..i)
			table.insert(self["playerList"..side],npcPlayer)
		end
	end
	local function sortFunc(a,b)
		if(a.canMoveTime>base.serverTime and b.canMoveTime>base.serverTime)then
			return a.canMoveTime<b.canMoveTime
		elseif(a.canMoveTime>base.serverTime and b.canMoveTime<=base.serverTime)then
			return false
		elseif(a.canMoveTime<=base.serverTime and b.canMoveTime>base.serverTime)then
			return true
		elseif(a.isNpc and b.isNpc==nil)then
			return false
		elseif(a.isNpc==nil and b.isNpc)then
			return true
		elseif(a.isNpc and b.isNpc)then
			return a.uid<b.uid
		elseif(a.arriveTime==b.arriveTime)then
			return a.uid<b.uid
		else
			return a.arriveTime<b.arriveTime
		end
	end
	table.sort(self.playerList1,sortFunc)
	table.sort(self.playerList2,sortFunc)
	local playerNum1=#self.playerList1
	local playerNum2=#self.playerList2
	local totalNum=playerNum1 + playerNum2
	if(totalNum>0)then
		self.progress:setPercentage(playerNum1/totalNum*100)
	else
		if(side==1)then
			self.progress:setPercentage(100)
		elseif(side==2)then
			self.progress:setPercentage(0)
		else
			self.progress:setPercentage(50)
		end
	end
	if(self.data.cfg.type==3)then
		local num
		if(side==1)then
			num=playerNum1
		else
			num=playerNum2
		end
		local needPeople=serverWarTeamFightVoApi:getMapCfg().flyNeed
		for i=1,needPeople do
			if(self.flyIconList and self.flyIconList[i])then
				if(i<=num)then
					if(self.flyIconList[i][1] and self.flyIconList[i][1].setVisible)then
						self.flyIconList[i][1]:setVisible(true)
					end
					if(self.flyIconList[i][2] and self.flyIconList[i][2].setVisible)then
						self.flyIconList[i][2]:setVisible(true)
					end
				else
					if(self.flyIconList[i][1] and self.flyIconList[i][1].setVisible)then
						self.flyIconList[i][1]:setVisible(false)
					end
					if(self.flyIconList[i][2] and self.flyIconList[i][2].setVisible)then
						self.flyIconList[i][2]:setVisible(false)
					end
				end
			end
		end
		if(self.functionEffectLb and self.functionEffectLb.setString)then
			if(num>=needPeople)then
				self.functionEffectLb:setString(getlocal("serverwarteam_activated"))
				self.functionEffectLb:setColor(G_ColorGreen)
			else
				self.functionEffectLb:setString(getlocal("serverwarteam_notActivated"))
				self.functionEffectLb:setColor(G_ColorRed)
			end
		end
	end
	if(self.tv and self.tv.reloadData)then
		if(self.selectedTab==2)then
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		else
			self.tv:reloadData()
		end
	end
end

function serverWarTeamCitySmallDialog:tick()
	local fighter1,fighter2=self:findCurrentFight()
	local side=self.data:getSide()
	if(fighter1 and fighter2)then
		self.nameLb1:setVisible(true)
		self.nameLb1:setString(fighter1.name)
		self.nameLb2:setVisible(true)
		self.nameLb2:setString(fighter2.name)
		self.vsPic1:setVisible(true)
		self.vsPic2:setVisible(true)
		self.peaceLb:setVisible(false)
		local nameTitle1=tolua.cast(self.bgLayer:getChildByTag(101),"CCLabelTTF")
		nameTitle1:setVisible(true)
		local nameTitle2=tolua.cast(self.bgLayer:getChildByTag(102),"CCLabelTTF")
		nameTitle2:setVisible(true)
		self.tankSp1:setVisible(true)
		self.tankSp2:setVisible(true)
	else
		self.nameLb1:setVisible(false)
		self.nameLb2:setVisible(false)
		self.vsPic1:setVisible(false)
		self.vsPic2:setVisible(false)
		self.peaceLb:setVisible(true)
		if(self.data:getSide()>0)then
			self.peaceLb:setString(getlocal("serverwar_team_noBattle"))
		end
		local nameTitle1=tolua.cast(self.bgLayer:getChildByTag(101),"CCLabelTTF")
		nameTitle1:setVisible(false)
		local nameTitle2=tolua.cast(self.bgLayer:getChildByTag(102),"CCLabelTTF")
		nameTitle2:setVisible(false)
		if(side==1)then
			self.tankSp1:setVisible(true)
			self.tankSp2:setVisible(false)
		elseif(side==2)then
			self.tankSp1:setVisible(false)
			self.tankSp2:setVisible(true)
		else
			self.tankSp1:setVisible(false)
			self.tankSp2:setVisible(false)
		end
	end
	if(side>0)then
		self.progressGray:setVisible(false)
	end
end

function serverWarTeamCitySmallDialog:findCurrentFight()
	local playerList=serverWarTeamFightVoApi:getPlayers()
	local fighter1,fighter2
	for id,player in pairs(playerList) do
		if(player.battleTime>=base.serverTime - 5 and player.battleCity==self.cityID)then
			if(player.side==1)then
				fighter1=player
				if(player.lastEnemyID)then
					fighter2=serverWarTeamFightVoApi:getPlayer(player.lastEnemyID)
					break
				end
			else
				fighter2=player
				if(player.lastEnemyID)then
					fighter1=serverWarTeamFightVoApi:getPlayer(player.lastEnemyID)
					break
				end
			end
		end
	end
	return fighter1,fighter2
end

function serverWarTeamCitySmallDialog:gotoCity()
	if(serverWarTeamMapScene.arriveFlag)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_moveWait"),30)
		do return end
	end
	local canReach=serverWarTeamFightVoApi:checkCityCanReach(self.cityID)
	--如果是其他情况不能移动的话就飘字提示
	if(canReach~=0 and canReach~=1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_moveError"..canReach),30)
		do return end
	--如果是没复活的话就弹提示是否花钱复活
	elseif(canReach==1)then
		local function onConfirm()
			local costGems=serverWarTeamCfg.reviveCost
			if(serverWarTeamFightVoApi:getGems()<costGems)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_not_enough_gem"),30)
				do return end
			end
			local function callback()
				serverWarTeamMapScene:refreshPlayers()
				local function callback1()
					serverWarTeamMapScene:userMove()
				end
				serverWarTeamFightVoApi:move(self.cityID,callback1)
				self:close()
			end
			serverWarTeamFightVoApi:revive(callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_reviveAndMove"),nil,self.layerNum+1)
	else
		local function callback()
			serverWarTeamMapScene:userMove()
		end
		serverWarTeamFightVoApi:move(self.cityID,callback)
		self:close()
	end
end

function serverWarTeamCitySmallDialog:dispose()
	base:removeFromNeedRefresh(self)
	eventDispatcher:removeEventListener("serverWarTeam.battle",self.eventListener)
	serverWarTeamFightVoApi.cityDialog=nil
	self.tv=nil
end