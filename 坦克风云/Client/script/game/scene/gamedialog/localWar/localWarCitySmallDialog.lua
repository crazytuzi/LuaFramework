--在区域战中点击城市弹出的小面板
localWarCitySmallDialog=smallDialog:new()

--param cityID: 城市ID, a1到a11
function localWarCitySmallDialog:new(cityID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.cityID=cityID
	nc.data=localWarFightVoApi:getCity(cityID)
	nc.allTabs={}
	nc.tab1=nil
	nc.tab2=nil
	nc.tab3=nil
	nc.dialogWidth=550
	nc.explodeArr={}
	nc.dialogHeight=750
	nc.refreshFlag=false
	return nc
end

function localWarCitySmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self.defenderList=localWarFightVoApi:getDefendersInCity(self.cityID)
	self.attackerList=localWarFightVoApi:getAttackersInCity(self.cityID)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTankjianianhua.plist")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/newTankImage/t20newImage.plist")
	self:initBackground()
	self:initTabs()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	base:addNeedRefresh(self)
	local function eventListener(event,data)
		self:dealEvent(event,data)
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("localWar.battle",eventListener)
	return self.dialogLayer
end

function localWarCitySmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
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
	
	local titleStr
	local isHome=false
	local homeBaseID
	for baseID,homeID in pairs(localWarMapCfg.homeID) do
		if(homeID==k)then
			isHome=true
			homeBaseID=baseID
			break
		end
	end
	if(isHome and localWarFightVoApi:getCityList()[homeBaseID]:isDestroyed())then
		titleStr=getlocal("local_war_destroyed")
	else
		titleStr=getlocal("local_war_cityName_"..self.cityID)
	end
	local titleLb=GetTTFLabel(titleStr,30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)

	self.countdownDesc=GetTTFLabel(getlocal("local_war_battleCountDown"),23)
	self.countdownDesc:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 160))
	self.bgLayer:addChild(self.countdownDesc,1)

	self.battleCountDown=GetTTFLabel(math.max(localWarFightVoApi:getNextBattleTime() - base.serverTime,0),28)
	self.battleCountDown:setColor(G_ColorYellowPro)
	self.battleCountDown:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 185))
	self.bgLayer:addChild(self.battleCountDown,1)
end

function localWarCitySmallDialog:initTabs()
	local tabIndex=0
	local tabStr={getlocal("local_war_cityInfo"),getlocal("local_war_battleQueue"),getlocal("local_war_waitQueue")}
	for i=1,3 do
		local tabBtnItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		local function tabClick(idx)
			return self:tabClick(idx)
		end
		tabBtnItem:registerScriptTapHandler(tabClick)
		local lb=GetTTFLabelWrap(tabStr[i],20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
		tabBtnItem:addChild(lb)
		self.allTabs[i]=tabBtnItem
		local tabBtn=CCMenu:create()
		tabBtn:addChild(tabBtnItem)
		tabBtnItem:setTag(tabIndex)
		if i==1 then
			tabBtn:setPosition(100,self.dialogHeight - tabBtnItem:getContentSize().height/2 - 85)
		elseif i==2 then
			tabBtn:setPosition(248,self.dialogHeight - tabBtnItem:getContentSize().height/2 - 85)
		elseif i==3 then
			tabBtn:setPosition(394,self.dialogHeight - tabBtnItem:getContentSize().height/2 - 85)
		end
		tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(tabBtn)
		tabIndex=tabIndex+1
	end
	self:tabClick(0)
end

function localWarCitySmallDialog:tabClick(idx)
	if self.selectedTabIndex == idx then
		return
	end
	self.selectedTabIndex=idx
	local type=idx + 1
	for k,v in pairs(self.allTabs) do
		if k==type then
			v:setEnabled(false)
		else
			v:setEnabled(true)
		end
	end
	for i=1,3 do
		if(type==i)then
			if(self["tab"..i]==nil)then
				self:initTab(i)
				self.bgLayer:addChild(self["tab"..i])
			end
			self["tab"..i]:setPosition(ccp(20,20))
			self["tab"..i]:setVisible(true)
		else
			if(self["tab"..i])then
				self["tab"..i]:setPosition(ccp(999333,0))
				self["tab"..i]:setVisible(false)
			end
		end
	end
	if(type==1 or type==2)then
		if(self.countdownDesc)then
			self.countdownDesc:setPositionX(self.dialogWidth/2)
			self.countdownDesc:setVisible(true)
		end
		if(self.battleCountDown)then
			self.battleCountDown:setPositionX(self.dialogWidth/2)
			self.battleCountDown:setVisible(true)
		end
	else
		if(self.countdownDesc)then
			self.countdownDesc:setPositionX(999333)
			self.countdownDesc:setVisible(false)
		end
		if(self.battleCountDown)then
			self.battleCountDown:setPositionX(999333)
			self.battleCountDown:setVisible(false)
		end
	end
end

function localWarCitySmallDialog:initTab(type)
	local function nilFunc()
	end
	self["tab"..type]=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunc)
	self["tab"..type]:setContentSize(CCSizeMake(self.dialogWidth - 40,self.dialogHeight - 150))
	self["tab"..type]:setAnchorPoint(ccp(0,0))
	if(type==1)then
		self:initTab1()
	elseif(type==2)then
		self:initTab2()
	else
		self:initTab3()
	end
end

function localWarCitySmallDialog:initTab1()
	local bgWidth=self.dialogWidth - 40
	local bgHeight=self.dialogHeight - 150
	local landBg=CCSprite:create("scene/world_map_mi.jpg")
	landBg:setScaleX((bgWidth - 2)/landBg:getContentSize().width)
	landBg:setScaleY(190/landBg:getContentSize().height)
	landBg:setAnchorPoint(ccp(0.5,1))
	landBg:setPosition(ccp(bgWidth/2,bgHeight - 1))
	self.tab1:addChild(landBg)
	local gradualBg=CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
	gradualBg:setScaleX(190/gradualBg:getContentSize().width)
	gradualBg:setScaleY((bgWidth - 2)*0.6/gradualBg:getContentSize().height)
	gradualBg:setRotation(-90)
	gradualBg:setAnchorPoint(ccp(1,1))
	gradualBg:setPosition(ccp(1,bgHeight - 1))
	self.tab1:addChild(gradualBg,1)
	local function nilFunc( ... )
	end
	local borderBg=LuaCCScale9Sprite:createWithSpriteFrameName("localWar_dialogBg.png",CCRect(20,20,20,20),nilFunc)
	borderBg:setContentSize(CCSizeMake(bgWidth,190))
	borderBg:setAnchorPoint(ccp(0.5,1))
	borderBg:setPosition(ccp(bgWidth/2,bgHeight - 1))
	self.tab1:addChild(borderBg,1)
	local cityIcon=CCSprite:createWithSpriteFrameName(self.data.cfg.icon)
	if(self.data.cfg.pos[1]>localWarMapScene.mapSize.width/2)then
		cityIcon:setFlipX(true)
	end
	cityIcon:setScale(130/cityIcon:getContentSize().height)
	cityIcon:setPosition(ccp(100,self.dialogHeight - 240))
	self.tab1:addChild(cityIcon,1)

	local status
	if(self.data.allianceID==0)then
		status=2
	elseif(#self.attackerList>0)then
		status=1
	else
		status=3
	end
	local statusLb=GetTTFLabel(getlocal("local_war_cityStatus"..status),25)
	statusLb:setColor(G_ColorYellowPro)
	statusLb:setTag(101)
	self.tab1:addChild(statusLb,2)
	local cityStatusBg=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),nilFunc)
	cityStatusBg:setTag(102)
	cityStatusBg:setContentSize(CCSizeMake(statusLb:getContentSize().width + 60,statusLb:getContentSize().height + 10))
	if(self.data.cfg.type==2)then
		statusLb:setPosition(ccp(100,self.dialogHeight - 300))
		cityStatusBg:setPosition(ccp(100,self.dialogHeight - 300))
	else
		statusLb:setPosition(ccp(100,self.dialogHeight - 280))
		cityStatusBg:setPosition(ccp(100,self.dialogHeight - 280))
	end
	self.tab1:addChild(cityStatusBg,1)

	self.statusIconList={}
	local smoke11=CCSprite:createWithSpriteFrameName("smoke_10.png")
	smoke11:setScale(0.8)
	smoke11:setPosition(ccp(bgWidth - 55,bgHeight - 50))
	self.tab1:addChild(smoke11,1)
	local tank11=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10005).."_1.png")
	tank11:setScale(0.5)
	tank11:setPosition(ccp(bgWidth - 55,bgHeight - 50))
	self.tab1:addChild(tank11,1)
	local fire11=CCSprite:createWithSpriteFrameName("fire2_4.png")
	fire11:setScale(0.7)
	fire11:setRotation(-10)
	fire11:setPosition(ccp(bgWidth - 97,bgHeight - 68))
	self.tab1:addChild(fire11,1)
	local tank12=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10035).."_2.png")
	tank12:setScale(0.5)
	tank12:setPosition(ccp(bgWidth - 160,bgHeight - 120))
	self.tab1:addChild(tank12,1)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(250/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(bgWidth - 107,bgHeight - 90))
	lineSp:setRotation(30)
	self.tab1:addChild(lineSp)
	self.statusIconList[1]={smoke11,tank11,fire11,tank12,lineSp}

	local tank21=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10035).."_1.png")
	tank21:setScale(0.5)
	tank21:setPosition(ccp(bgWidth - 55,bgHeight - 50))
	self.tab1:addChild(tank21)
	local tank22=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10005).."_1.png")
	tank22:setScale(0.5)
	tank22:setPosition(ccp(bgWidth - 160,bgHeight - 50))
	self.tab1:addChild(tank22)
	local tank23=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10025).."_1.png")
	tank23:setScale(0.5)
	tank23:setPosition(ccp(bgWidth - 55,bgHeight - 120))
	self.tab1:addChild(tank23)
	local tank23_1=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10025).."_1_1.png");
	tank23_1:setPosition(getCenterPoint(tank23))
	tank23:addChild(tank23_1)
	local tank24=CCSprite:createWithSpriteFrameName("t"..GetTankOrderByTankId(10015).."_1.png")
	tank24:setScale(0.5)
	tank24:setPosition(ccp(bgWidth - 160,bgHeight - 120))
	self.tab1:addChild(tank24)

	self.statusIconList[2]={tank21,tank22,tank23,tank24}
	if(status==1)then
		for k,v in pairs(self.statusIconList[2]) do
			v:setVisible(false)
		end
	else
		for k,v in pairs(self.statusIconList[1]) do
			v:setVisible(false)
		end
	end

	local posY
	if(self.data.cfg.type~=2)then
		local progressBg=CCSprite:createWithSpriteFrameName("TimeBg.png")
		progressBg:setScaleX((bgWidth - 15)/progressBg:getContentSize().width)
		progressBg:setScaleY(1.1)
		progressBg:setPosition(ccp(bgWidth/2,bgHeight - 170))
		self.tab1:addChild(progressBg,1)
		self.hpProgress=CCProgressTimer:create(CCSprite:createWithSpriteFrameName("AllXpBar.png"))
		self.hpProgress:setScaleX((bgWidth - 20)/self.hpProgress:getContentSize().width)
		self.hpProgress:setScaleY(1.1)
		self.hpProgress:setType(kCCProgressTimerTypeBar)
		self.hpProgress:setMidpoint(ccp(0,0))
		self.hpProgress:setBarChangeRate(ccp(1,0))
		self.hpProgress:setPosition(ccp(bgWidth/2,bgHeight - 170))
		self.hpProgress:setPercentage(self.data:getHp()/self.data:getMaxHp()*100)
		self.tab1:addChild(self.hpProgress,1)
		self.hpLb=GetTTFLabel(self.data:getHp().."/"..self.data:getMaxHp(),22)
		self.hpLb:setPosition(ccp(bgWidth/2,bgHeight - 170))
		self.tab1:addChild(self.hpLb,1)
	end
	posY = bgHeight - 190
	local isHome=false
	local homeBaseID
	for baseID,homeID in pairs(localWarMapCfg.homeID) do
		if(homeID==k)then
			isHome=true
			break
		end
	end
	local conditionTitle=GetTTFLabel(getlocal("local_war_occupyConditionTitle"),23)
	conditionTitle:setColor(G_ColorYellowPro)
	conditionTitle:setAnchorPoint(ccp(0,1))
	conditionTitle:setPosition(ccp(10,posY - 5))
	self.tab1:addChild(conditionTitle,1)
	if(isHome)then
		conditionTitle:setVisible(false)
	end

	posY=posY - 35
	local conditionLb
	if(isHome)then
		conditionLb=GetTTFLabelWrap(getlocal("local_war_homeDesc"),23,CCSizeMake(bgWidth - 20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	elseif(self.data.cfg.type==2)then
		conditionLb=GetTTFLabelWrap(getlocal("local_war_occupyCondition2"),23,CCSizeMake(bgWidth - 20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	else
		conditionLb=GetTTFLabelWrap(getlocal("local_war_occupyCondition1"),23,CCSizeMake(bgWidth - 20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	end
	conditionLb:setAnchorPoint(ccp(0,1))
	conditionLb:setPosition(ccp(10,posY))
	self.tab1:addChild(conditionLb,1)

	posY=posY - conditionLb:getContentSize().height - 10
	local blackBg=CCSprite:createWithSpriteFrameName("BlackBg.png")
	blackBg:setScaleX((bgWidth - 2)/blackBg:getContentSize().width)
	blackBg:setScaleY((bgHeight - 190 - posY)/blackBg:getContentSize().height)
	blackBg:setAnchorPoint(ccp(0.5,1))
	blackBg:setPosition(ccp(bgWidth/2,bgHeight - 190))
	self.tab1:addChild(blackBg)

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(bgWidth/2,posY))
	self.tab1:addChild(lineSp)


	posY=posY - 15
	local landTypeLb=GetTTFLabel(getlocal("BossBattle_ground")..": "..getlocal("world_ground_name_"..self.data.cfg.landType),23)
	landTypeLb:setAnchorPoint(ccp(0,1))
	landTypeLb:setPosition(ccp(10,posY))
	self.tab1:addChild(landTypeLb)

	posY=posY - 30
	local allianceName=""
	if(self.data.allianceID==0 or self.data.allianceID==nil)then
		allianceName=getlocal("alliance_info_content")
	else
		if(localWarFightVoApi:getDefenderAlliance() and localWarFightVoApi:getDefenderAlliance().id==self.data.allianceID)then
			allianceName=localWarFightVoApi:getDefenderAlliance().name
		else
			for k,v in pairs(localWarFightVoApi:getAllianceList()) do
				if(v.id==self.data.allianceID)then
					allianceName=v.name
					break
				end
			end
		end
	end
	local ownerLb=GetTTFLabel(getlocal("local_war_belongTo")..": "..allianceName,23)
	ownerLb:setTag(103)
	ownerLb:setAnchorPoint(ccp(0,1))
	ownerLb:setPosition(ccp(10,posY))
	self.tab1:addChild(ownerLb)

	posY=posY - 30
	local effectTitleLb=GetTTFLabel(getlocal("effect"),23)
	effectTitleLb:setAnchorPoint(ccp(0,1))
	effectTitleLb:setPosition(ccp(10,posY))
	self.tab1:addChild(effectTitleLb)

	local effectStr=""
	for k,v in pairs(self.data.cfg.buff) do
		local nameStr=getlocal(buffEffectCfg[k].name);
		local valueStr=tostring(v*100).."%%"
		effectStr=effectStr..getlocal("local_war_cityEffect",{nameStr,valueStr}).."\n"
	end
	if(effectStr=="")then
		effectStr=getlocal("alliance_info_content")
	end
	local effectValueLb=GetTTFLabelWrap(effectStr,23,CCSizeMake(bgWidth - 20 - effectTitleLb:getContentSize().width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	effectValueLb:setColor(G_ColorGreen)
	effectValueLb:setAnchorPoint(ccp(0,1))
	effectValueLb:setPosition(ccp(10 + effectTitleLb:getContentSize().width,posY))
	self.tab1:addChild(effectValueLb)

	posY=posY - effectValueLb:getContentSize().height
	local effectWarning=GetTTFLabel(getlocal("local_war_cityEffectDesc"),23)
	effectWarning:setColor(G_ColorRed)
	effectWarning:setAnchorPoint(ccp(0,1))
	effectWarning:setPosition(10,posY)
	self.tab1:addChild(effectWarning)

	local function onGoto()
		if(localWarFightVoApi:checkBaseBlock())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4202"),30)
			do return end
		end
		if(localWarMapScene and localWarMapScene.player==nil)then
			local function onConfirm()
				localWarVoApi:showTroopsDialog(self.layerNum+1)
			end
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("local_war_cantMove0"),nil,self.layerNum+2,nil,onConfirm)
			do return end
		end
		self:gotoCity()
	end
	local function onView()
		if(localWarFightVoApi:checkBaseBlock())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4202"),30)
			do return end
		end
		self:viewDamage()
	end
	local function onCommand()
		if(localWarFightVoApi:checkBaseBlock())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4202"),30)
			do return end
		end
		if(localWarMapScene and localWarMapScene.player==nil)then
			local function onConfirm()
				localWarVoApi:showTroopsDialog(self.layerNum+1)
			end
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("local_war_cantMove0"),nil,self.layerNum+2,nil,onConfirm)
			do return end
		end
		localWarFightVoApi:showCityOrderDialog(self.data.id,self.layerNum + 1)
	end
	local gotoItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onGoto,1,getlocal("activity_heartOfIron_goto"),25)
	gotoItem:setScale(0.9)
	local gotoBtn=CCMenu:createWithItem(gotoItem)
	gotoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	local commandItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onCommand,1,getlocal("local_war_command"),25)
	commandItem:setScale(0.9)
	local commandBtn=CCMenu:createWithItem(commandItem)
	commandBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	local viewItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onView,1,getlocal("local_war_battleStatus"),25)
	viewItem:setScale(0.9)
	local viewBtn=CCMenu:createWithItem(viewItem)
	viewBtn:setTouchPriority(-(self.layerNum-1)*20-2)

	local btnTb={}
	local role=tonumber(allianceVoApi:getSelfAlliance().role)
	if(self.data.cfg.type==2)then
		if(allianceVoApi:getSelfAlliance() and (role==1 or role==2))then
			btnTb={commandBtn,gotoBtn}
		else
			btnTb={gotoBtn}
		end
	else
		if(allianceVoApi:getSelfAlliance() and (role==1 or role==2))then
			btnTb={viewBtn,commandBtn,gotoBtn}
		else
			btnTb={viewBtn,gotoBtn}
		end
	end
	local count=#btnTb
	for i=1,count do
		if(count==3)then
			if(i==1)then
				btnTb[i]:setPosition(ccp(80,40))
			elseif(i==3)then
				btnTb[i]:setPosition(ccp(bgWidth - 80,40))
			else
				btnTb[i]:setPosition(ccp(bgWidth*i/(count + 1),40))
			end
		else
			btnTb[i]:setPosition(ccp(bgWidth*i/(count + 1),40))
		end
		self.tab1:addChild(btnTb[i])
	end
end

function localWarCitySmallDialog:initTab2()
	local bgWidth=self.dialogWidth - 40
	local bgHeight=self.dialogHeight - 150
	local fighterBgHeight=bgHeight - 150
	local fighterBgWidth=(bgWidth - 80)/2
	local attackerTitle=GetTTFLabel(getlocal("tankAtk"),25)
	attackerTitle:setColor(G_ColorYellowPro)
	attackerTitle:setPosition(ccp(5 + fighterBgWidth/2,bgHeight - 80))
	self.tab2:addChild(attackerTitle)
	local defenderTitle=GetTTFLabel(getlocal("fight_content_defende_type"),25)
	defenderTitle:setColor(G_ColorYellowPro)
	defenderTitle:setPosition(ccp(bgWidth - 5 - fighterBgWidth/2,bgHeight - 80))
	self.tab2:addChild(defenderTitle)

	local function nilFunc()
	end
	local attackerBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	attackerBg:setContentSize(CCSizeMake(fighterBgWidth,fighterBgHeight))
	attackerBg:setAnchorPoint(ccp(0,0))
	attackerBg:setPosition(ccp(5,50))
	self.tab2:addChild(attackerBg)
	local defenderBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	defenderBg:setContentSize(CCSizeMake(fighterBgWidth,fighterBgHeight))
	defenderBg:setAnchorPoint(ccp(1,0))
	defenderBg:setPosition(ccp(bgWidth - 5,50))
	self.tab2:addChild(defenderBg)

	local attackerNum=0
	local defenderNum=0
	for i=1,5 do
		local lineY=50 + fighterBgHeight - 10 - (fighterBgHeight - 20)*i/5
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale(bgWidth/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(bgWidth/2,lineY))
		self.tab2:addChild(lineSp)

		local fighterIndex=GetTTFLabel(i,25)
		fighterIndex:setColor(G_ColorYellowPro)
		fighterIndex:setPosition(ccp(bgWidth/2,lineY + 40))
		self.tab2:addChild(fighterIndex)

		local lbSize1 = 20
	    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
	        lbSize1 =25
	    end
		local attackerStr
		if(self.attackerList[i])then
			attackerStr=self.attackerList[i].allianceName.."\n"..self.attackerList[i].name
			attackerNum=attackerNum + 1
		else
			attackerStr=""
		end
		local attackerName=GetTTFLabelWrap(attackerStr,lbSize1,CCSizeMake(fighterBgWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		attackerName:setTag(201 + i*10)
		attackerName:setAnchorPoint(ccp(0.5,0))
		attackerName:setPosition(ccp(5 + fighterBgWidth/2,lineY + 5))
		self.tab2:addChild(attackerName)
		local defenderStr
		if(self.defenderList[i])then
			defenderStr=self.defenderList[i].allianceName.."\n"..self.defenderList[i].name
			defenderNum=defenderNum + 1
		else
			defenderStr=""
		end

		local defenderName=GetTTFLabelWrap(defenderStr,lbSize1,CCSizeMake(fighterBgWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		defenderName:setTag(202 + i*10)
		defenderName:setAnchorPoint(ccp(0.5,0))
		defenderName:setPosition(ccp(bgWidth - 5 - fighterBgWidth/2,lineY + 5))
		self.tab2:addChild(defenderName)
	end
	local attackerNumLb=GetTTFLabel(attackerNum.."/5",25)
	attackerNumLb:setTag(203)
	if(attackerNum>4)then
		attackerNumLb:setColor(G_ColorYellowPro)
	end
	attackerNumLb:setPosition(ccp(5 + fighterBgWidth/2,25))
	self.tab2:addChild(attackerNumLb)
	local defenderNumLb=GetTTFLabel(defenderNum.."/5",25)
	defenderNumLb:setTag(204)
	if(defenderNum>4)then
		defenderNumLb:setColor(G_ColorYellowPro)
	end
	defenderNumLb:setPosition(ccp(bgWidth - 5 - fighterBgWidth/2,25))
	self.tab2:addChild(defenderNumLb)
end

function localWarCitySmallDialog:initTab3()
	local bgWidth=self.dialogWidth - 40
	local bgHeight=self.dialogHeight - 150
	local fighterBgHeight=bgHeight - 150
	local fighterBgWidth=(bgWidth - 80)/2
	local attackerTitle=GetTTFLabel(getlocal("tankAtk"),25)
	attackerTitle:setColor(G_ColorYellowPro)
	attackerTitle:setPosition(ccp(5 + fighterBgWidth/2,bgHeight - 80))
	self.tab3:addChild(attackerTitle)
	local defenderTitle=GetTTFLabel(getlocal("fight_content_defende_type"),25)
	defenderTitle:setColor(G_ColorYellowPro)
	defenderTitle:setPosition(ccp(bgWidth - 5 - fighterBgWidth/2,bgHeight - 80))
	self.tab3:addChild(defenderTitle)

	local function nilFunc()
	end
	local attackerBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	attackerBg:setContentSize(CCSizeMake(fighterBgWidth,fighterBgHeight))
	attackerBg:setAnchorPoint(ccp(0,0))
	attackerBg:setPosition(ccp(5,50))
	self.tab3:addChild(attackerBg)
	local defenderBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	defenderBg:setContentSize(CCSizeMake(fighterBgWidth,fighterBgHeight))
	defenderBg:setAnchorPoint(ccp(1,0))
	defenderBg:setPosition(ccp(bgWidth - 5,50))
	self.tab3:addChild(defenderBg)

	local function callBack(...)
		return self:eventHandlerFighter(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth,fighterBgHeight - 10),nil)
	tv:setTag(301)
	tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	tv:setMaxDisToBottomOrTop(80)
	tv:setPosition(5,55)
	self.tab3:addChild(tv,1)

	local attackerNum=math.max(0,(#self.attackerList) - 5)
	local defenderNum=math.max(0,(#self.defenderList) - 5)
	local attackerNumLb=GetTTFLabel(attackerNum,25)
	attackerNumLb:setTag(303)
	attackerNumLb:setPosition(ccp(5 + fighterBgWidth/2,25))
	self.tab3:addChild(attackerNumLb)
	local defenderNumLb=GetTTFLabel(defenderNum,25)
	defenderNumLb:setTag(304)
	defenderNumLb:setPosition(ccp(bgWidth - 5 - fighterBgWidth/2,25))
	self.tab3:addChild(defenderNumLb)
end

function localWarCitySmallDialog:eventHandlerFighter(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.max((#self.defenderList) - 5,(#self.attackerList) - 5,0)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.dialogWidth - 40,(self.dialogHeight - 150 - 150 - 20)/5)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local bgWidth=self.dialogWidth - 40
		local bgHeight=self.dialogHeight - 150
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale((self.dialogWidth - 40)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(bgWidth/2,0))
		cell:addChild(lineSp)

		local fighterIndex=idx + 6
		local fighterBgWidth=(bgWidth - 80)/2
		if(self.attackerList[fighterIndex])then
			local attackerName=GetTTFLabelWrap(self.attackerList[fighterIndex].allianceName.."\n"..self.attackerList[fighterIndex].name,25,CCSizeMake(fighterBgWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			attackerName:setAnchorPoint(ccp(0.5,0))
			attackerName:setPosition(ccp(5 + fighterBgWidth/2,15))
			cell:addChild(attackerName)
		end

		if(self.defenderList[fighterIndex])then
			local defenderName=GetTTFLabelWrap(self.defenderList[fighterIndex].allianceName.."\n"..self.defenderList[fighterIndex].name,25,CCSizeMake(fighterBgWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			defenderName:setAnchorPoint(ccp(0.5,0))
			defenderName:setPosition(ccp(bgWidth - 5 - fighterBgWidth/2,15))
			cell:addChild(defenderName)
		end

		local fighterIndex=GetTTFLabel(idx+1,25)
		fighterIndex:setColor(G_ColorYellowPro)
		fighterIndex:setPosition(ccp(bgWidth/2,40))
		cell:addChild(fighterIndex)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function localWarCitySmallDialog:tick()
	if(self.battleCountDown)then
		self.battleCountDown:setString(math.max(localWarFightVoApi:getNextBattleTime() - base.serverTime,0))
	end
	if(self.refreshFlag==true)then
		self:refresh()
		self.refreshFlag=false
	end
end

function localWarCitySmallDialog:gotoCity()
	local canReach=localWarFightVoApi:checkCityCanReach(self.cityID)
	--如果是其他情况不能移动的话就飘字提示
	if(canReach~=0 and canReach~=1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_moveError"..canReach),30)
		do return end
	--如果是没复活的话就弹提示是否花钱复活
	elseif(canReach==1)then
		-- local function onConfirm()
		-- 	local costGems=(self.player.canMoveTime - base.serverTime) + localWarCfg.reviveCost
		-- 	if(playerVoApi:getGems()<costGems)then
		-- 		local needGem=costGems - playerVoApi:getGems()
		-- 		GemsNotEnoughDialog(nil,nil,needGem,self.layerNum+1,costGems)
		-- 		do return end
		-- 	end
		-- 	local function callback()
		-- 		local function callback1()
		-- 			localWarMapScene:userMove()
		-- 		end
		-- 		localWarFightVoApi:move(self.cityID,callback1)
		-- 		self:close()
		-- 	end
		-- 	localWarFightVoApi:revive(callback)
		-- end
		-- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_reviveAndMove"),nil,self.layerNum+1)
	
		local reviveTime=localWarFightVoApi:getPlayer().canMoveTime
		local function reviveCallback()
			local function callback1()
				localWarMapScene:userMove()
			end
			localWarFightVoApi:move(self.cityID,callback1)
			self:close()
		end
		localWarVoApi:showRepairDialog(reviveTime,self.layerNum+1,reviveCallback)
	else
		if(base.serverTime<localWarFightVoApi:getPlayer().arriveTime + 5)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_moveWait"),30)
			do return end
		end
		local function callback()
			localWarMapScene:userMove()
		end
		localWarFightVoApi:move(self.cityID,callback)
		self:close()
	end
end

function localWarCitySmallDialog:viewDamage()
	local function hideDamage()
		if(self.damageLayer)then
			self.damageLayer:removeFromParentAndCleanup(true)
			self.damageLayer=nil
		end
	end
	if(self.damageLayer)then
		hideDamage()
		do return end
	end
	local layerNum=self.layerNum + 1
	self.damageLayer=CCLayer:create()
	self.dialogLayer:addChild(self.damageLayer,5)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),hideDamage)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.damageLayer:addChild(touchDialogBg)
	local dialogWidth,dialogHeight=500,470
	local damageDialog=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),hideDamage)
	damageDialog:setContentSize(CCSizeMake(dialogWidth,dialogHeight))
	damageDialog:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.damageLayer:addChild(damageDialog,1)
	local titleLb=GetTTFLabel(getlocal("local_war_battleStatus"),25)
	titleLb:setPosition(ccp(dialogWidth/2,dialogHeight - 40))
	damageDialog:addChild(titleLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(dialogWidth/2,dialogHeight - 60))
	damageDialog:addChild(lineSp)
	local blackBg=CCSprite:createWithSpriteFrameName("BlackBg.png")
	blackBg:setScaleX((dialogWidth - 20)/blackBg:getContentSize().width)
	blackBg:setScaleY(40/blackBg:getContentSize().height)
	blackBg:setAnchorPoint(ccp(0.5,1))
	blackBg:setPosition(ccp(dialogWidth/2,dialogHeight - 62))
	damageDialog:addChild(blackBg)
	local rankTitle=GetTTFLabel(getlocal("rank"),25)
	rankTitle:setColor(G_ColorGreen)
	rankTitle:setPosition(ccp(100,dialogHeight - 82))
	damageDialog:addChild(rankTitle)
	local allianceTitle=GetTTFLabel(getlocal("alliance_list_scene_name"),25)
	allianceTitle:setColor(G_ColorGreen)
	allianceTitle:setPosition(ccp(dialogWidth/2,dialogHeight - 82))
	damageDialog:addChild(allianceTitle)
	local damageTitle=GetTTFLabel(getlocal("BossBattle_damagePoint"),25)
	damageTitle:setColor(G_ColorGreen)
	damageTitle:setPosition(ccp(400,dialogHeight - 82))
	damageDialog:addChild(damageTitle)
	local tmpList=localWarFightVoApi:getCityDamageList(self.cityID)
	local damageList={}
	for k,v in pairs(tmpList) do
		local id=tonumber(k)
		local name
		if(localWarFightVoApi:getDefenderAlliance() and localWarFightVoApi:getDefenderAlliance().id==id)then
			name=localWarFightVoApi:getDefenderAlliance().name
		else
			for key,allianceVo in pairs(localWarFightVoApi:getAllianceList()) do
				if(allianceVo.id==id)then
					name=allianceVo.name
					break
				end
			end
		end
		table.insert(damageList,{id=id,damage=v,name=name})
	end
	local function sortFunc(a,b)
		if(a.damage==b.damage)then
			if(localWarFightVoApi:getDefenderAlliance() and localWarFightVoApi:getDefenderAlliance().id==a.id)then
				return false
			else
				for k,v in pairs(localWarFightVoApi:getAllianceList()) do
					if(v.id==a.id)then
						return true
					end
					if(v.id==b.id)then
						return false
					end
				end
				return a.id<b.id
			end
		else
			return a.damage>b.damage
		end
	end
	table.sort(damageList,sortFunc)
	for k,v in pairs(damageList) do
		local rankLogo
		if(k<4)then
			rankLogo=CCSprite:createWithSpriteFrameName("top"..k..".png")
			rankLogo:setScale(0.8)
		else
			rankLogo=GetTTFLabel(k,25)
		end
		rankLogo:setPosition(ccp(100,dialogHeight - 90 - k*60))
		damageDialog:addChild(rankLogo)
		local nameLb=GetTTFLabel(v.name,25)
		nameLb:setPosition(ccp(dialogWidth/2,dialogHeight - 90 - k*60))
		damageDialog:addChild(nameLb)
		local damageLb=GetTTFLabel(v.damage,25)
		damageLb:setPosition(ccp(400,dialogHeight - 90 - k*60))
		damageDialog:addChild(damageLb)
	end
	local descLb=GetTTFLabelWrap(getlocal("local_war_damageListDesc"),25,CCSizeMake(dialogWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setColor(G_ColorRed)
	descLb:setPosition(ccp(dialogWidth/2,50))
	damageDialog:addChild(descLb)
end

function localWarCitySmallDialog:dealEvent(event,data)
	if(data.type=="over")then
		self.refreshFlag=false
		self:close()
	elseif(data.type=="player")then
		local cityID=self.data.id
		for k,v in pairs(data.data) do
			if(v.cityID==cityID or v.battleCity==cityID or v.lastCityID==cityID)then
				self.refreshFlag=true
				break
			end
		end
	elseif(data.type=="city")then
		for k,cityVo in pairs(data.data) do
			if(cityVo.id==self.cityID)then
				self.refreshFlag=true
				break
			end
		end
	end
end

function localWarCitySmallDialog:refresh()
	self.defenderList=localWarFightVoApi:getDefendersInCity(self.cityID)
	self.attackerList=localWarFightVoApi:getAttackersInCity(self.cityID)
	if(self.hpProgress)then
		self.hpProgress:setPercentage(self.data:getHp()/self.data:getMaxHp()*100)
	end
	if(self.hpLb)then
		self.hpLb:setString(self.data:getHp().."/"..self.data:getMaxHp())
	end
	local status
	if(self.data.allianceID==0)then
		status=2
	elseif(#self.attackerList>0)then
		status=1
	else
		status=3
	end
	local statusLb=tolua.cast(self.tab1:getChildByTag(101),"CCLabelTTF")
	if(statusLb)then
		statusLb:setString(getlocal("local_war_cityStatus"..status))
		local statusBg=tolua.cast(self.tab1:getChildByTag(102),"CCScale9Sprite")
		statusBg:setContentSize(CCSizeMake(statusLb:getContentSize().width + 60,statusLb:getContentSize().height + 10))
	end
	if(status==1)then
		for k,v in pairs(self.statusIconList[1]) do
			v:setVisible(true)
		end
		for k,v in pairs(self.statusIconList[2]) do
			v:setVisible(false)
		end
	else
		for k,v in pairs(self.statusIconList[1]) do
			v:setVisible(false)
		end
		for k,v in pairs(self.statusIconList[2]) do
			v:setVisible(true)
		end
	end
	local ownerLb=tolua.cast(self.tab1:getChildByTag(103),"CCLabelTTF")
	if(ownerLb)then
		local allianceName=""
		if(self.data.allianceID==0 or self.data.allianceID==nil)then
			allianceName=getlocal("alliance_info_content")
		else
			if(localWarFightVoApi:getDefenderAlliance() and localWarFightVoApi:getDefenderAlliance().id==self.data.allianceID)then
				allianceName=localWarFightVoApi:getDefenderAlliance().name
			else
				for k,v in pairs(localWarFightVoApi:getAllianceList()) do
					if(v.id==self.data.allianceID)then
						allianceName=v.name
						break
					end
				end
			end
		end
		ownerLb:setString(getlocal("local_war_belongTo")..": "..allianceName)
	end
	if(self.tab2)then
		local attackerNum=0
		local defenderNum=0
		for i=1,5 do
			local attackerName=tolua.cast(self.tab2:getChildByTag(201 + i*10),"CCLabelTTF")
			if(attackerName)then
				local attackerStr
				if(self.attackerList[i])then
					attackerStr=self.attackerList[i].allianceName.."\n"..self.attackerList[i].name
					attackerNum=attackerNum + 1
				else
					attackerStr=""
				end
				attackerName:setString(attackerStr)
			end
			local defenderName=tolua.cast(self.tab2:getChildByTag(202 + i*10),"CCLabelTTF")
			if(defenderName)then
				local defenderStr
				if(self.defenderList[i])then
					defenderStr=self.defenderList[i].allianceName.."\n"..self.defenderList[i].name
					defenderNum=defenderNum + 1
				else
					defenderStr=""
				end
				defenderName:setString(defenderStr)
			end
		end
		local attackerNumLb=tolua.cast(self.tab2:getChildByTag(203),"CCLabelTTF")
		if(attackerNumLb)then
			attackerNumLb:setString(attackerNum.."/5")
			if(attackerNum>4)then
				attackerNumLb:setColor(G_ColorYellowPro)
			else
				attackerNumLb:setColor(G_ColorWhite)
			end
		end
		local defenderNumLb=tolua.cast(self.tab2:getChildByTag(204),"CCLabelTTF")
		if(defenderNumLb)then
			defenderNumLb:setString(defenderNum.."/5")
			if(defenderNum>4)then
				defenderNumLb:setColor(G_ColorYellowPro)
			else
				defenderNumLb:setColor(G_ColorWhite)
			end
		end
	end
	if(self.tab3)then
		local tv=tolua.cast(self.tab3:getChildByTag(301),"LuaCCTableView")
		if(tv)then
			tv:reloadData()
		end
		local attackerNum=math.max(0,(#self.attackerList) - 5)
		local defenderNum=math.max(0,(#self.defenderList) - 5)
		local attackerNumLb=tolua.cast(self.tab3:getChildByTag(303),"CCLabelTTF")
		if(attackerNumLb)then
			attackerNumLb:setString(attackerNum)
		end
		local defenderNumLb=tolua.cast(self.tab3:getChildByTag(304),"CCLabelTTF")
		if(defenderNumLb)then
			defenderNumLb:setString(defenderNum)
		end
	end
end

function localWarCitySmallDialog:dispose()
	self.refreshFlag=false
	self.data=nil
	localWarFightVoApi.cityDialog=nil
	base:removeFromNeedRefresh(self)
	eventDispatcher:removeEventListener("localWar.battle",self.eventListener)
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/newTankImage/t20newImage.plist")
end