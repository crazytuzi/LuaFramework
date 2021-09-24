serverWarTeamMapScene=
{
	bgLayer=nil,
	clayer=nil,
	background=nil,
	minScale=1,
	maxScale=1.7,
	isShow=false,
	chatBg=nil,
	airStatus=false,
}

function serverWarTeamMapScene:show(layerNum)
	self.layerNum=layerNum
	self.mapCfg=serverWarTeamFightVoApi:getMapCfg()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWarCityIcon.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/serverWarLocal/serverWarLocalCity.plist")
	spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
	spriteController:addTexture("public/serverWarLocal/serverWarLocal2.png")
	self.bgLayer=CCLayer:create()
	self.touchArr={}
	self:initBackground()
	self:initFunctionBar()
	self:initMap()
	self:initChat()
	self:initPlayer()
	self.isShow=true
	sceneGame:addChild(self.bgLayer,self.layerNum)
	if(self.player.side==1)then
		self.clayer:setPosition(ccp(0,self.functionBarHeight))
	end
	base:addNeedRefresh(self)
	local function eventListener(event,data)
		local eventType=data.type
		if(eventType=="city")then
			self:cityStatusChange(data)
		elseif(eventType=="player")then
			self:playerStatusChange(data)
		elseif(eventType=="buff")then
			self:buffStatusChange()
		elseif(eventType=="points")then
			self:pointStatusChange()
		elseif(eventType=="countryRoad")then
			self:roadStatusChange()
		elseif(eventType=="order")then
			self:showOrder(data.data)
		elseif(eventType=="bomb")then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_airAttacked"),30)
		elseif(eventType=="over")then
			self:close()
		end
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("serverWarTeam.battle",eventListener)
	base.pauseSync=true
	base.allShowedCommonDialog=base.allShowedCommonDialog+1
	table.insert(base.commonDialogOpened_WeakTb,self)
	self:tick()
end

function serverWarTeamMapScene:initBackground()
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(touchDialogBg)

	self:initTitle()
	self.mapSize=serverWarTeamFightVoApi:getMapSize()
	self.clayer=CCLayer:create()
	self.clayer:setTouchEnabled(true)
	local function tmpHandler(...)
		return self:touchEvent(...)
	end
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
	self.clayer:setPosition(ccp(0,G_VisibleSizeHeight - self.titleHeight - self.mapSize.height))
	self.bgLayer:addChild(self.clayer)

	self.background=CCSprite:create("serverWar/serverWarTeamMap.jpg")
	self.background:setAnchorPoint(ccp(0,0))
	self.background:setContentSize(self.mapSize)
	self.background:setPosition(ccp(0,0))
	self.clayer:addChild(self.background)
end

function serverWarTeamMapScene:initTitle()
	local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rechargeDescBg.png",CCRect(50, 54, 10, 8),function ()end)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-8)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,130))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(ccp(0,G_VisibleSizeHeight))
	self.bgLayer:addChild(titleBg,3)
	local titleMiddle=CCSprite:createWithSpriteFrameName("serverWarFunctionBg.png")
	titleMiddle:setScale(130/112)
	titleMiddle:setAnchorPoint(ccp(0.5,1))
	titleMiddle:setPosition(G_VisibleSizeWidth/2,133)
	titleBg:addChild(titleMiddle)
	local function onShowReport()
		serverWarTeamVoApi:showRecordDialog(self.layerNum + 1,serverWarTeamFightVoApi.battleData.roundID,serverWarTeamFightVoApi.battleData.battleID,1)
	end
	local selectN = CCSprite:createWithSpriteFrameName("serverWarTBtn.png")
	local selectS = CCSprite:createWithSpriteFrameName("serverWarTBtn.png")
	selectS:setScale(0.9)
	selectS:setPosition(selectS:getContentSize().width*0.05,selectS:getContentSize().height*0.05)
	local selectD = GraySprite:createWithSpriteFrameName("serverWarTBtn.png")
	local titleItem = CCMenuItemSprite:create(selectN,selectS,selectD)
	titleItem:registerScriptTapHandler(onShowReport)
	local titleBtn=CCMenu:createWithItem(titleItem)
	titleBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	titleBtn:setPosition(G_VisibleSizeWidth/2,55)
	titleBg:addChild(titleBtn)

	self.titleHeight=titleBg:getContentSize().height

	local serverName1=GetTTFLabel(GetServerNameByID(serverWarTeamFightVoApi:getAllianceList()[1].serverID),22)
	serverName1:setAnchorPoint(ccp(0,0.5))
	serverName1:setPosition(20,105)
	titleBg:addChild(serverName1)
	local serverName2=GetTTFLabel(GetServerNameByID(serverWarTeamFightVoApi:getAllianceList()[2].serverID),22)
	serverName2:setAnchorPoint(ccp(1,0.5))
	serverName2:setPosition(G_VisibleSizeWidth - 20,105)
	titleBg:addChild(serverName2)
	local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp1:setScaleX(200/lineSp1:getContentSize().width)
	lineSp1:setPosition(ccp(140,87))
	titleBg:addChild(lineSp1)
	local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp2:setScaleX(200/lineSp2:getContentSize().width)
	lineSp2:setPosition(ccp(G_VisibleSizeWidth - 140,87))
	titleBg:addChild(lineSp2)
	local flag1 = CCSprite:createWithSpriteFrameName("platWarFlag1.png")
	flag1:setScale(0.8)
	flag1:setPosition(ccp(50,50))
	titleBg:addChild(flag1)
	local flag2 = CCSprite:createWithSpriteFrameName("platWarFlag2.png")
	flag2:setScale(0.8)
	flag2:setFlipX(true)
	flag2:setPosition(ccp(G_VisibleSizeWidth - 50,50))
	titleBg:addChild(flag2)
	local allianceName1=GetTTFLabel(serverWarTeamFightVoApi:getAllianceList()[1].name,25)
	allianceName1:setColor(G_ColorRed)
	allianceName1:setAnchorPoint(ccp(0,0.5))
	allianceName1:setPosition(90,72)
	titleBg:addChild(allianceName1)
	local allianceName2=GetTTFLabel(serverWarTeamFightVoApi:getAllianceList()[2].name,25)
	allianceName2:setColor(G_ColorBlue)
	allianceName2:setAnchorPoint(ccp(1,0.5))
	allianceName2:setPosition(G_VisibleSizeWidth - 90,72)
	titleBg:addChild(allianceName2)
	local peopleIcon1=CCSprite:createWithSpriteFrameName("survive1.png")
	peopleIcon1:setScale(30/peopleIcon1:getContentSize().width)
	peopleIcon1:setPosition(100,45)
	titleBg:addChild(peopleIcon1)
	local peopleIcon2=CCSprite:createWithSpriteFrameName("survive1.png")
	peopleIcon2:setScale(30/peopleIcon2:getContentSize().width)
	peopleIcon2:setPosition(G_VisibleSizeWidth - 100,45)
	titleBg:addChild(peopleIcon2)
	self.peopleLb1=GetTTFLabel("",25)
	self.peopleLb1:setAnchorPoint(ccp(0,0.5))
	self.peopleLb1:setPosition(130,45)
	titleBg:addChild(self.peopleLb1)
	self.peopleLb2=GetTTFLabel("",25)
	self.peopleLb2:setAnchorPoint(ccp(1,0.5))
	self.peopleLb2:setPosition(G_VisibleSizeWidth - 130,45)
	titleBg:addChild(self.peopleLb2)


	local progressBg1 = CCSprite:createWithSpriteFrameName("serverWarProgressBg1.png")
	progressBg1:setAnchorPoint(ccp(0,0.5))
	progressBg1:setPosition(ccp(15,20))
	titleBg:addChild(progressBg1)
	local progressSprite = CCSprite:createWithSpriteFrameName("serverWarProgress1.png")
	self.progress1 = CCProgressTimer:create(progressSprite)
	self.progress1:setBarChangeRate(ccp(1, 0))
	self.progress1:setMidpoint(ccp(0,0))
	self.progress1:setType(kCCProgressTimerTypeBar)
	self.progress1:setAnchorPoint(ccp(0,0.5))
	self.progress1:setPosition(ccp(17,20))
	self.progress1:setPercentage(serverWarTeamFightVoApi:getPoints()[1]/serverWarTeamCfg.winPointMax*100)
	titleBg:addChild(self.progress1)
	self.progress1Lb=GetTTFLabel(serverWarTeamFightVoApi:getPoints()[1],17)
	self.progress1Lb:setPosition(getCenterPoint(self.progress1))	
	self.progress1:addChild(self.progress1Lb)
	local progressBg2 = CCSprite:createWithSpriteFrameName("serverWarProgressBg1.png")
	progressBg2:setFlipX(true)
	progressBg2:setAnchorPoint(ccp(1,0.5))
	progressBg2:setPosition(ccp(G_VisibleSizeWidth - 15,20))
	titleBg:addChild(progressBg2)
	local progressSprite = CCSprite:createWithSpriteFrameName("serverWarProgress2.png")
	progressSprite:setFlipX(true)
	self.progress2 = CCProgressTimer:create(progressSprite)
	self.progress2:setBarChangeRate(ccp(1,0))
	self.progress2:setMidpoint(ccp(1,0))
	self.progress2:setType(kCCProgressTimerTypeBar)
	self.progress2:setAnchorPoint(ccp(1,0.5))
	self.progress2:setPosition(ccp(G_VisibleSizeWidth - 17,20))
	self.progress2:setPercentage(serverWarTeamFightVoApi:getPoints()[2]/serverWarTeamCfg.winPointMax*100)
	titleBg:addChild(self.progress2)
	self.progress2Lb=GetTTFLabel(serverWarTeamFightVoApi:getPoints()[2],17)
	self.progress2Lb:setPosition(getCenterPoint(self.progress2))	
	self.progress2:addChild(self.progress2Lb)

	local countdownBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(50,0,20,36),function ( ... )end)
	countdownBg:setContentSize(CCSizeMake(180,60))
	countdownBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - self.titleHeight - 40)
	self.bgLayer:addChild(countdownBg,3)
	self.countdownLb=GetTTFLabelWrap("",23,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.countdownLb:setPosition(90,30)
	countdownBg:addChild(self.countdownLb)
end

function serverWarTeamMapScene:initFunctionBar()
	self.functionBarHeight=170
	local function nilFunc()
	end
	local functionBarBg=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20,20,10,10),nilFunc)
	functionBarBg:setTouchPriority(-(self.layerNum-1)*20-7)
	functionBarBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.functionBarHeight))
	functionBarBg:setAnchorPoint(ccp(0.5,0))
	functionBarBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
	self.bgLayer:addChild(functionBarBg,3)

	local function onAccelerate()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:accelerate()
	end
	local selectN=CCSprite:createWithSpriteFrameName("BtnOkSmall.png")
	local selectS=CCSprite:createWithSpriteFrameName("BtnOkSmall_Down.png");
	local selectD=GraySprite:createWithSpriteFrameName("BtnOkSmall_Down.png")
	self.accItem=CCMenuItemSprite:create(selectN,selectS,selectD)
	self.accItem:registerScriptTapHandler(onAccelerate)
	local accMv=CCSprite:createWithSpriteFrameName("serverWarArrow.png")
	accMv:setPosition(130,selectS:getContentSize().height/2)
	self.accItem:addChild(accMv)
	local fadeOut=CCTintTo:create(0.5,97,97,97)
	local fadeIn=CCTintTo:create(0.5,255,255,255)
	local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
	local repeatForever=CCRepeatForever:create(seq)
	accMv:runAction(repeatForever)
	local lb=GetTTFLabel(getlocal(""),25)
	lb:setTag(518)
	lb:setPosition(selectN:getContentSize().width/2,selectN:getContentSize().height/2)
	self.accItem:addChild(lb)
	local accBtn=CCMenu:createWithItem(self.accItem)
	accBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	accBtn:setPosition(ccp(100,50))
	functionBarBg:addChild(accBtn)

	local function onSelf()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:findSelf()
	end
	local selectN=LuaCCScale9Sprite:createWithSpriteFrameName("BigBtnBlue.png",CCRect(20,0,230,74),onSelf)
	selectN:setContentSize(CCSizeMake(162,74))
	local selectS=LuaCCScale9Sprite:createWithSpriteFrameName("BigBtnBlue_Down.png",CCRect(20,0,230,74),onSelf)
	selectS:setContentSize(CCSizeMake(162,74))
	local selectD=LuaCCScale9Sprite:createWithSpriteFrameName("BigBtnBlue_Down.png",CCRect(20,0,230,74),onSelf)
	selectD:setContentSize(CCSizeMake(162,74))
	self.findSelfItem=CCMenuItemSprite:create(selectN,selectS,selectD)
	self.findSelfItem:registerScriptTapHandler(onSelf)
	local lb=GetTTFLabel(getlocal(""),25)
	lb:setTag(518)
	lb:setPosition(selectN:getContentSize().width/2,selectN:getContentSize().height/2)
	self.findSelfItem:addChild(lb)
	self.findSelfBtn=CCMenu:createWithItem(self.findSelfItem)
	self.findSelfBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	self.findSelfBtn:setPosition(ccp(100,50))
	functionBarBg:addChild(self.findSelfBtn)

	local function onClickSwitchBuffLayer()
		self:switchBuffLayer()
	end
	local switchBuffItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onClickSwitchBuffLayer,1,getlocal("serverwarteam_experts"),25)
	local switchBuffBtn=CCMenu:createWithItem(switchBuffItem)
	switchBuffBtn:setPosition(ccp(G_VisibleSizeWidth/2,50))
	switchBuffBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	functionBarBg:addChild(switchBuffBtn)

	local function onClose()
		self:close()
	end
	local closeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onClose,1,getlocal("exit"),25)
	local closeBtn=CCMenu:createWithItem(closeItem)
	closeBtn:setPosition(ccp(G_VisibleSizeWidth - 100,50))
	closeBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	functionBarBg:addChild(closeBtn)

	self.buffLayer=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20,20,10,10),nilFunc)
	self.buffLayer:setTouchPriority(-(self.layerNum-1)*20-5)
	self.buffLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth - 10,110))
	self.buffLayer:setAnchorPoint(ccp(0.5,0))
	self.buffLayer:setPosition(ccp(G_VisibleSizeWidth/2,60))
	self.bgLayer:addChild(self.buffLayer,2)
	self:initBuff()

	self.listLayer=LuaCCScale9Sprite:createWithSpriteFrameName("fleet_slot_mini_bg.png",CCRect(0,37,120,10),function ( ... )end)
	self.listLayer:setTouchPriority(-(self.layerNum-1)*20-6)
	self.listLayer:setContentSize(CCSizeMake(300,G_VisibleSizeHeight - self.titleHeight - self.functionBarHeight - 110))
	self.listLayer:setAnchorPoint(ccp(1,1))
	self.listLayer:setPosition(ccp(10,G_VisibleSizeHeight - self.titleHeight - 75))
	self.bgLayer:addChild(self.listLayer)
	self:refreshPlayers()

	local function onClickSwitchListLayer()
		self:switchListLayer()
	end
	self.switchItemLeft=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onClickSwitchListLayer,11,nil,nil)
	self.switchItemLeft:setRotation(180)
	local switchBtn=CCMenu:createWithItem(self.switchItemLeft)
	switchBtn:setTag(518)
	switchBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	switchBtn:setPosition(ccp(300 + self.switchItemLeft:getContentSize().width/2 - 10,self.listLayer:getContentSize().height/2))
	self.listLayer:addChild(switchBtn)
end

function serverWarTeamMapScene:initBuff()
	local function onClickBuff(object,name,tag)
		local buffID="b"..tag
		serverWarTeamFightVoApi:showBuffDialog(buffID,self.layerNum+1)
	end
	local index=0
	self.tipLvTb={}
	for i=1,4 do
		local buffCfg=serverWarTeamCfg.buffSkill["b"..i]
		local buffIcon=LuaCCSprite:createWithSpriteFrameName(buffCfg.icon,onClickBuff)
		buffIcon:setTag(i)
		buffIcon:setPosition(200 + index*(buffIcon:getContentSize().width + 10),self.buffLayer:getContentSize().height/2)
		buffIcon:setTouchPriority(-(self.layerNum-1)*20-6)
		buffIcon:setScale(0.9)
		self.buffLayer:addChild(buffIcon)
		local lvTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
		local lvLb=GetTTFLabel(serverWarTeamFightVoApi:getBuffData()["b"..i],30)
		self.tipLvTb["b"..i]=lvLb
		lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))
		lvTip:setScale(0.6)
		lvTip:addChild(lvLb)
		lvTip:setPosition(ccp(15,buffIcon:getContentSize().height-10))
		buffIcon:addChild(lvTip)
		index=index + 1
	end
	local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldSp:setAnchorPoint(ccp(0,0))
	goldSp:setPosition(ccp(20,20))
	self.buffLayer:addChild(goldSp)
	self.gemLb=GetTTFLabel(serverWarTeamFightVoApi:getGems(),25)
	self.gemLb:setAnchorPoint(ccp(0,0))
	self.gemLb:setPosition(50,22)
	self.buffLayer:addChild(self.gemLb)
end

function serverWarTeamMapScene:refreshPlayers()
	self.friends={}
	self.friendsLiveNum=0
	self.enemyNum=0
	local selfSide=serverWarTeamFightVoApi:getPlayer().side
	for id,player in pairs(serverWarTeamFightVoApi:getPlayers()) do
		if(player.side==selfSide)then
			table.insert(self.friends,player)
			if(player.canMoveTime<=base.serverTime)then
				self.friendsLiveNum=self.friendsLiveNum + 1
			end
		else
			self.enemyNum=self.enemyNum + 1
		end
	end
	local function sortFunc(a,b)
		return a.uid<b.uid
	end
	table.sort(self.friends,sortFunc)
	local num1,num2
	if(selfSide==1)then
		num1=#self.friends
		num2=self.enemyNum
	else
		num1=self.enemyNum
		num2=#self.friends
	end
	if(self.peopleLb1)then
		self.peopleLb1:setString(num1)
	end
	if(self.peopleLb2)then
		self.peopleLb2:setString(num2)
	end
	if(self.listTv==nil)then
		local function callBack(...)
			return self:eventHandler(...)
		end
		local hd= LuaEventHandler:createHandler(callBack)
		self.listTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.listLayer:getContentSize().width - 20,self.listLayer:getContentSize().height - 20),nil)
		self.listTv:setTableViewTouchPriority(-(self.layerNum-1)*20-8)
		self.listTv:setMaxDisToBottomOrTop(20)
		self.listTv:setPosition(10,10)
		self.listLayer:addChild(self.listTv)
	else
		self.listTv:reloadData()
	end
end

function serverWarTeamMapScene:touchEvent(fn,x,y,touch)
	if fn=="began" then
		if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 then
			return 0
		end
		self.isMoved=false
		self.touchArr[touch]=touch
		local touchIndex=0
		for k,v in pairs(self.touchArr) do
			local temTouch= tolua.cast(v,"CCTouch")
			if self and temTouch then
				if touchIndex==0 then
					self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
				else
					self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
				end
			end
			touchIndex=touchIndex+1
		end
		if touchIndex==1 then
			self.secondOldPos=nil
			self.lastTouchDownPoint=self.firstOldPos
		end
		if SizeOfTable(self.touchArr)>1 then
			self.multTouch=true
		else
			self.multTouch=false
		end
		return 1
	elseif fn=="moved" then
		if self.touchEnable==false then
			do return end
		end
		self.isMoved=true
		if self.multTouch==true then --双点触摸
			self.zoomMidPosForBackground=self.background:convertToNodeSpace(ccpMidpoint(self.firstOldPos,self.secondOldPos))
			self.zoomMidPosForLayer=ccpMidpoint(self.firstOldPos,self.secondOldPos)
			local beforeZoomDis=ccpDistance(self.firstOldPos,self.secondOldPos)
			local pIndex=0
			local curFirstPos
			local curSecondPos
			for k,v in pairs(self.touchArr) do
				if v==touch then
					if pIndex==0 then
						curFirstPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
					else 
						curSecondPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
					end
					do break end
				end
				pIndex=pIndex+1
			end
			local afterZoomDis
			if curFirstPos~=nil then
				afterZoomDis=ccpDistance(curFirstPos,self.secondOldPos)
				self.firstOldPos=curFirstPos
			elseif curSecondPos~=nil then
				afterZoomDis=ccpDistance(self.firstOldPos,curSecondPos)
				self.secondOldPos=curSecondPos
			end
			local subDis=0
			local sl=1
			if afterZoomDis==nil or beforeZoomDis==nil then
				afterZoomDis=0
				beforeZoomDis=0
			end
			if afterZoomDis>beforeZoomDis then --放大
				subDis=afterZoomDis-beforeZoomDis  
				sl=(subDis/200)*0.2
				self.background:setScale(math.min(self.maxScale,sl+self.background:getScale()))
			else --缩小
				subDis=afterZoomDis-beforeZoomDis  
				sl=(subDis/200)*0.2
				self.background:setScale(math.max(self.minScale,sl+self.background:getScale()))   
			end
			local newPosForBackgroundToLayer=self.background:convertToWorldSpace(self.zoomMidPosForBackground)
			local newAddPos=ccpSub(newPosForBackgroundToLayer,self.zoomMidPosForLayer)
			local newClayerPos=ccpSub(ccp(self.clayer:getPosition()),newAddPos)
			self.clayer:setPosition(newClayerPos)
			self:checkBound()
		else --单点触摸
			local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
			local moveDisPos=ccpSub(curPos,self.firstOldPos)
			local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
			if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
				self.isMoved=false
				do return end
			end
			self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)
			local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),moveDisPos)
			self.clayer:setPosition(tmpPos)
			self:checkBound()
			self.firstOldPos=curPos
			self.isMoving=true
		end
	elseif fn=="ended" then
		if self.touchEnable==false then
			do
				return
			end
		end
		if self.touchArr[touch]~=nil then
			self.touchArr[touch]=nil
			local touchIndex=0
			for k,v in pairs(self.touchArr) do
				if touchIndex==0 then
					self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
				else
					self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
				end
				touchIndex=touchIndex+1
			end
			if touchIndex==1 then
				self.secondOldPos=nil
			end
			if SizeOfTable(self.touchArr)>1 then
				self.multTouch=true
			else
				self.multTouch=false
			end
		end
		if self.isMoving==true then
			self.isMoving=false
			local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
			tmpToPos=self:checkBound(tmpToPos)

			local moveTo=CCMoveTo:create(0.15,tmpToPos)
			local cceaseOut=CCEaseOut:create(moveTo,3)
			self.clayer:runAction(cceaseOut)
		end
	else
		self.touchArr=nil
		self.touchArr={}
	end
end

function serverWarTeamMapScene:checkBound(pos)
	local tmpPos
	if pos==nil then
		tmpPos= ccp(self.clayer:getPosition())
	else
		tmpPos=pos
	end
	if tmpPos.x>0 then
		tmpPos.x=0
	elseif tmpPos.x<G_VisibleSizeWidth - self.background:boundingBox().size.width then
		tmpPos.x=G_VisibleSizeWidth - self.background:boundingBox().size.width
	end
	if tmpPos.y>=self.functionBarHeight then
		tmpPos.y=self.functionBarHeight
	elseif tmpPos.y<G_VisibleSizeHeight - self.titleHeight - self.background:boundingBox().size.height then
		tmpPos.y=G_VisibleSizeHeight - self.titleHeight - self.background:boundingBox().size.height
	end
	if pos==nil then
		self.clayer:setPosition(tmpPos)
	else
		return tmpPos
	end
end

function serverWarTeamMapScene:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.friends + 2
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.listLayer:getContentSize().width - 30,45)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local lb
		local posX
		if(idx==0)then
            local lbSize=30
            if G_getCurChoseLanguage()=="de" then
                lbSize =25
            end
			lb=GetTTFLabel(getlocal("serverwarteam_friendPeople",{self.friendsLiveNum,#self.friends}),lbSize)
			lb:setPosition((self.listLayer:getContentSize().width - 30)/2,23)
		elseif(idx==1)then
			local function onShowMyTroops()
				if(self.listTv:getIsScrolled()==false)then
					serverWarTeamFightVoApi:showSelfTroopDialog(self.layerNum + 1)
				end
			end
			local clickBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),onShowMyTroops)
			clickBg:setContentSize(CCSizeMake(self.listLayer:getContentSize().width,45))
			clickBg:setTouchPriority(-(self.layerNum-1)*20-8)
			clickBg:setOpacity(0)
			clickBg:setAnchorPoint(ccp(0,0))
			clickBg:setPosition(0,0)
			cell:addChild(clickBg)
			local lineUp=CCSprite:createWithSpriteFrameName("LineCross.png")
			lineUp:setScaleX(300/lineUp:getContentSize().width)
			lineUp:setPosition((self.listLayer:getContentSize().width - 30)/2,45)
			cell:addChild(lineUp)
			local lineDown=CCSprite:createWithSpriteFrameName("LineCross.png")
			lineDown:setScaleX(300/lineDown:getContentSize().width)
			lineDown:setPosition((self.listLayer:getContentSize().width - 30)/2,0)
			cell:addChild(lineDown)
			lb=GetTTFLabel(getlocal("local_war_my_troops"),25)
			lb:setColor(G_ColorGreen)
			lb:setAnchorPoint(ccp(0,0.5))
			lb:setPosition(20,23)
			local arrowSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
			arrowSp:setScale(45/arrowSp:getContentSize().height)
			arrowSp:setFlipX(true)
			arrowSp:setPosition((self.listLayer:getContentSize().width - 30 - 30),23)
			cell:addChild(arrowSp)
		else
			lb=GetTTFLabel(self.friends[idx - 1].name,25)
			if(self.friends[idx - 1].canMoveTime>base.serverTime)then
				lb:setColor(G_ColorRed)
			end
			lb:setAnchorPoint(ccp(0,0.5))
			lb:setPosition(20,23)
		end
		cell:addChild(lb)
		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded"  then
	end
end

function serverWarTeamMapScene:initMap()
	--摆城市
	local function onClickCity(object,name,tag)
		if(self.isMoved)then
			return
		end
		if(serverWarTeamFightVoApi:getStartTime()>base.serverTime)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_battleNotStart"),30)
			do return end
		end
		local cityID = "a"..tag
		serverWarTeamFightVoApi:showCityDialog(cityID,self.layerNum + 1)
	end
	self.cityList=serverWarTeamFightVoApi:getCityList()
	self.cityNameList={}
	local selfSide=serverWarTeamFightVoApi:getPlayer().side
	for k,v in pairs(self.cityList) do
		local cityIcon=LuaCCSprite:createWithSpriteFrameName(v.cfg.icon,onClickCity)
		if(k=="a1")then
			cityIcon:setFlipX(true)
		end
		if(v.cfg.type==1)then
			cityIcon:setScale(170/cityIcon:getContentSize().width)
		elseif(k=="a8")then
			cityIcon:setScale(200/cityIcon:getContentSize().width)
		else
			cityIcon:setScale(130/cityIcon:getContentSize().width)
		end
		cityIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		cityIcon:setTag(tonumber(string.sub(v.id,2)))
		cityIcon:setPosition(ccp(v.cfg.pos[1],v.cfg.pos[2]))
		self.background:addChild(cityIcon,2)
		if((k=="a2" and selfSide==1) or (k=="a14" and selfSide==2))then
			local icon2=CCSprite:createWithSpriteFrameName(serverWarTeamFightVoApi:getMapCfg().airportSp)
			icon2:setVisible(false)
			icon2:setScale(150/icon2:getContentSize().width)
			icon2:setTag(101)
			icon2:setPosition(getCenterPoint(cityIcon))
			cityIcon:addChild(icon2)
			if(v.allianceID~=0)then
				local playerNum=0
				for id,player in pairs(serverWarTeamFightVoApi:getPlayers()) do
					if(player.arriveTime<=base.serverTime and player.cityID==k)then
						playerNum=playerNum + 1
					end
					if(playerNum>=serverWarTeamFightVoApi:getMapCfg().flyNeed)then
						icon2:setVisible(true)
						cityIcon:setOpacity(0)
						self.airStatus=true
						break
					end
				end
			end
		end

		local cityNameBg=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
		cityNameBg:setOpacity(0)
		cityNameBg:setPosition(v.cfg.pos[1],v.cfg.pos[2] - 50)
		self.background:addChild(cityNameBg,3)
		local centerPoint=getCenterPoint(cityNameBg)
		local bg1=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_enemybg.png",CCRect(15,8,153,28),onClickCity)
		bg1:setPosition(centerPoint)
		cityNameBg:addChild(bg1)
		local bg2=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarCityNameBg.png",CCRect(15,8,153,28),onClickCity)
		bg2:setPosition(centerPoint)
		cityNameBg:addChild(bg2)
		local bg3=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),onClickCity)
		bg3:setPosition(centerPoint)
		cityNameBg:addChild(bg3)
		local cityNameLb=GetTTFLabelWrap(getlocal(v.cfg.name),15,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		cityNameLb:setPosition(getCenterPoint(cityNameBg))
		cityNameBg:addChild(cityNameLb)
		local size=CCSizeMake(cityNameLb:getContentSize().width + 40,cityNameLb:getContentSize().height + 20)
		bg1:setContentSize(size)
		bg2:setContentSize(size)
		bg3:setContentSize(size)
		if(v:getSide()==1)then
			bg2:setVisible(false)
			bg3:setVisible(false)
		elseif(v:getSide()==2)then
			bg1:setVisible(false)
			bg3:setVisible(false)
		else
			bg1:setVisible(false)
			bg2:setVisible(false)
		end
		self.cityNameList[k]={bg1,bg2,bg3}
	end
	local showCountryRoad=serverWarTeamFightVoApi:checkShowCountryRoad()
	if(showCountryRoad==false)then
		self.barricade1=CCSprite:createWithSpriteFrameName("serverWarBarricade.png")
		self.barricade1:setPosition(ccp(590,600))
		self.background:addChild(self.barricade1,3)
		local countdownStr=GetTimeStr(serverWarTeamFightVoApi:getStartTime() + serverWarTeamCfg.countryRoadTime - base.serverTime)
		local countdownLb1=GetTTFLabel(getlocal("activity_double11_countdownStr"),22)
		local countdownLb2=GetTTFLabel(countdownStr,22)
		local countdownBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),onClickCity)
		countdownBg:setContentSize(CCSizeMake(math.max(countdownLb1:getContentSize().width,countdownLb2:getContentSize().width) + 30,countdownLb1:getContentSize().height + countdownLb2:getContentSize().height + 20))
		countdownLb1:setPosition(countdownBg:getContentSize().width/2,countdownBg:getContentSize().height/2 + 13)
		countdownBg:addChild(countdownLb1)
		countdownLb2:setTag(101)
		countdownLb2:setPosition(countdownBg:getContentSize().width/2,countdownBg:getContentSize().height/2 - 13)
		countdownBg:addChild(countdownLb2)
		countdownBg:setTag(101)
		countdownBg:setAnchorPoint(ccp(1,0))
		countdownBg:setPosition(self.barricade1:getContentSize().width,self.barricade1:getContentSize().height + 10)
		self.barricade1:addChild(countdownBg)

		self.barricade2=CCSprite:createWithSpriteFrameName("serverWarBarricade.png")
		self.barricade2:setPosition(ccp(50,360))
		self.background:addChild(self.barricade2,3)
		local countdownStr=GetTimeStr(serverWarTeamFightVoApi:getStartTime() + serverWarTeamCfg.countryRoadTime - base.serverTime)
		local countdownLb1=GetTTFLabel(getlocal("activity_double11_countdownStr"),22)
		local countdownLb2=GetTTFLabel(countdownStr,22)
		local countdownBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),onClickCity)
		countdownBg:setContentSize(CCSizeMake(math.max(countdownLb1:getContentSize().width,countdownLb2:getContentSize().width) + 30,countdownLb1:getContentSize().height + countdownLb2:getContentSize().height + 20))
		countdownLb1:setPosition(countdownBg:getContentSize().width/2,countdownBg:getContentSize().height/2 + 13)
		countdownBg:addChild(countdownLb1)
		countdownLb2:setTag(101)
		countdownLb2:setPosition(countdownBg:getContentSize().width/2,countdownBg:getContentSize().height/2 - 13)
		countdownBg:addChild(countdownLb2)
		countdownBg:setTag(101)
		countdownBg:setAnchorPoint(ccp(0,1))
		countdownBg:setPosition(0,-10)
		self.barricade2:addChild(countdownBg)
	end
	self:showOrder(serverWarTeamFightVoApi.order)
	self:showCountryRoadDirect()
end

function serverWarTeamMapScene:showOrder(order)
	local diff=false
	if(self.orderTipList)then
		for k,v in pairs(order) do
			local cityID=v[1]
			local cityOrder=v[2]
			if(self.orderTipList[cityID]~=cityOrder)then
				diff=true
				break
			end
		end
		if(diff==false)then
			do return end
		end
		for cityID,tip in pairs(self.orderTipList) do
			tip=tolua.cast(tip,"CCScale9Sprite")
			if(tip)then
				tip:removeFromParentAndCleanup(true)
			end
		end
	end
	self.orderTipList={}
	for k,v in pairs(order) do
		local cityID=v[1]
		local cityOrder=v[2]
		local lb=GetTTFLabelWrap(getlocal("local_war_order"..cityOrder),25,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		local function nilFunc( ... )
		end
		local tip=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(20, 20, 10, 10),nilFunc)
		tip:setContentSize(CCSizeMake(170,lb:getContentSize().height + 10))
		lb:setPosition(getCenterPoint(tip))
		tip:addChild(lb)
		tip:setPosition(ccp(self.cityList[cityID].cfg.pos[1],self.cityList[cityID].cfg.pos[2] + 100))
		self.orderTipList[cityID]=tip
		self.background:addChild(tip,4)
	end
end

function serverWarTeamMapScene:showCountryRoadDirect()
	local showCountryRoad=serverWarTeamFightVoApi:checkShowCountryRoad()
	if(showCountryRoad==true and G_isShowLineSprite())then
		if(self.roadDirect1==nil)then
			self.roadDirect1=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
			self.roadDirect1:setOpacity(0)
			local cityVo=self.cityList[serverWarTeamFightVoApi:getMapCfg().railWayCity[1]]
			self.roadDirect1:setPosition(cityVo.cfg.pos[1],cityVo.cfg.pos[2])
			self.background:addChild(self.roadDirect1,1)
			local line1=LineSprite:create("public/green_line.png")
			line1:setSpeed(0.13)
			line1:setLine(ccp(51.5,0),ccp(51.5,384.5))
			self.roadDirect1:addChild(line1)
			local line2=LineSprite:create("public/green_line.png")
			line2:setSpeed(0.13)
			line2:setLine(ccp(51.5,384.5),ccp(-88.5,524.5))
			self.roadDirect1:addChild(line2)
		end
		if(self.roadDirect2==nil)then
			self.roadDirect2=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
			self.roadDirect2:setOpacity(0)
			local cityVo=self.cityList[serverWarTeamFightVoApi:getMapCfg().railWayCity[2]]
			self.roadDirect2:setPosition(cityVo.cfg.pos[1],cityVo.cfg.pos[2])
			self.background:addChild(self.roadDirect2,1)
			local line1=LineSprite:create("public/green_line.png")
			line1:setSpeed(0.13)
			line1:setLine(ccp(-7.5,0),ccp(-7.5,-370))
			self.roadDirect2:addChild(line1)
			local line2=LineSprite:create("public/green_line.png")
			line2:setSpeed(0.13)
			line2:setLine(ccp(-7.5,-371.5),ccp(157.5,-521.5))
			self.roadDirect2:addChild(line2)
		end
	end
end

function serverWarTeamMapScene:switchBuffLayer()
	local posY
	if(self.buffLayerShow)then
		self.buffLayerShow=false
		posY=60
	else
		self.buffLayerShow=true
		posY=self.functionBarHeight
	end
	self.buffLayer:stopAllActions()
	local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSizeWidth/2,posY))
	self.buffLayer:runAction(moveTo)
end

function serverWarTeamMapScene:switchListLayer()
	local posX
	if(self.listLayerShow)then
		self.listLayerShow=false
		self.switchItemLeft:setRotation(180)
		posX=10
	else
		self.listLayerShow=true
		self.switchItemLeft:setRotation(0)
		posX=300
	end
	self.listLayer:stopAllActions()
	local moveTo=CCMoveTo:create(0.3,CCPointMake(posX,G_VisibleSizeHeight - self.titleHeight - 75))
	self.listLayer:runAction(moveTo)
end

function serverWarTeamMapScene:initPlayer()
	self.player=serverWarTeamFightVoApi:getPlayer()
	local photoName=playerVoApi:getPersonPhotoName()
	local headFrameId = playerVoApi:getHfid()
	local playerPic = playerVoApi:GetPlayerBgIcon(photoName,nil,nil,nil,nil,headFrameId)
	playerPic:setTag(101)
	self.playerIcon=CCSprite:createWithSpriteFrameName("ProductTankDialog.png")
	playerPic:setPosition(ccp(self.playerIcon:getContentSize().width/2-0.5,self.playerIcon:getContentSize().height/2+6))
	self.playerIcon:setAnchorPoint(ccp(0.5,0))
	self.playerIcon:addChild(playerPic)
	local pos
	if(self.player.arriveTime<=base.serverTime)then
		pos=self.cityList[self.player.cityID].cfg.pos
	else
		pos=self.cityList[self.player.lastCityID].cfg.pos
	end
	self.playerIcon:setPosition(pos[1],pos[2])
	self.background:addChild(self.playerIcon,4)
	self:userMove()
	self:checkShowLanding()
end

function serverWarTeamMapScene:userMove()
	if(self.player==nil)then
		do return end
	end
	local targetCity=self.cityList[self.player.cityID]
	local startCity=self.cityList[self.player.lastCityID]
	if(self.player.arriveTime<=base.serverTime or startCity==nil)then
		self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
		if(self.landLine)then
			self.landLine:setVisible(false)
		end
		do return end
	end
	local key
	for k,v in pairs(startCity.cfg.adjoin) do
		if(v==targetCity.id)then
			key=k
			break
		end
	end
	if(key==nil)then
		self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
		do return end
	end
	local startPos,endPos
	if(startCity.cfg.movePos)then
		startPos=startCity.cfg.movePos
	else
		startPos=startCity.cfg.pos
	end
	if(targetCity.cfg.movePos)then
		endPos=targetCity.cfg.movePos
	else
		endPos=targetCity.cfg.pos
	end
	if((startCity.id=="a4" and targetCity.id=="a13") or (startCity.id=="a12" and targetCity.id=="a3"))then
		local cornerPos
		if(targetCity.id=="a13")then
			startPos=ccp(590,startCity.cfg.pos[2])
			cornerPos=ccp(590,630)
		else
			startPos=ccp(50,startCity.cfg.pos[2])
			cornerPos=ccp(50,310)
		end
		endPos=ccp(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
		local distance1=self:distance({startPos.x,startPos.y},{cornerPos.x,cornerPos.y})
		local distance2=self:distance({endPos.x,endPos.y},{cornerPos.x,cornerPos.y})
		local totalDistance=distance1 + distance2
		local totalNeedTime=startCity.cfg.distance[key]
		local leftTime=self.player.arriveTime - base.serverTime
		local needTime1=totalNeedTime*distance1/totalDistance
		local needTime2=totalNeedTime*distance2/totalDistance
		if(leftTime<=needTime2)then
			local startPosX=(endPos.x - cornerPos.x)*(needTime2 - leftTime)/needTime2 + cornerPos.x
			local startPosY=(endPos.y - cornerPos.y)*(needTime2 - leftTime)/needTime2 + cornerPos.y
			self.playerIcon:setPosition(startPosX,startPosY)
			local moveTo=CCMoveTo:create(leftTime,endPos)
			self.playerIcon:runAction(moveTo)
		else
			local startPosX=(cornerPos.x - startPos.x)*(totalNeedTime - leftTime)/needTime1 + startPos.x
			local startPosY=(cornerPos.y - startPos.y)*(totalNeedTime - leftTime)/needTime1 + startPos.y
			self.playerIcon:setPosition(startPosX,startPosY)
			local moveTo1=CCMoveTo:create(leftTime - needTime2,cornerPos)
			local moveTo2=CCMoveTo:create(needTime2,endPos)
			local seq=CCSequence:createWithTwoActions(moveTo1,moveTo2)
			self.playerIcon:runAction(seq)
		end
	else
		if(G_isShowLineSprite())then
			local isFly=false
			if(serverWarTeamFightVoApi:getMapCfg().flyCity[startCity.id])then
				for k,v in pairs(serverWarTeamFightVoApi:getMapCfg().flyCity[startCity.id]) do
					if(v==targetCity.id)then
						isFly=true
						break
					end
				end
			end
			if(isFly)then
				if(self.landLine==nil)then
					self.landLine=LineSprite:create("public/green_line.png")
					self.landLine:setSpeed(0.13)
					self.background:addChild(self.landLine,3)
					self.landLine:setLine(ccp(startPos[1],startPos[2]),ccp(endPos[1],endPos[2]))
				end
				self.landLine:setVisible(true)
			end
		end
		local totalNeedTime=startCity.cfg.distance[key]
		local leftTime=self.player.arriveTime - base.serverTime
		local startPosX=(endPos[1] - startPos[1])*(totalNeedTime - leftTime)/totalNeedTime + startPos[1]
		local startPosY=(endPos[2] - startPos[2])*(totalNeedTime - leftTime)/totalNeedTime + startPos[2]
		self.playerIcon:setPosition(ccp(startPosX,startPosY))
		local moveTo=CCMoveTo:create(leftTime,ccp(endPos[1],endPos[2]))
		self.playerIcon:runAction(moveTo)
	end
end

function serverWarTeamMapScene:checkShowLanding()
	if(self.player.arriveTime<=base.serverTime and (self.player.cityID==serverWarTeamFightVoApi:getMapCfg().airport[1] or self.player.cityID==serverWarTeamFightVoApi:getMapCfg().airport[2]))then
		if(self.landSp and self.landSp:isVisible())then
			do return end
		end
		local flyCityID=serverWarTeamFightVoApi:getMapCfg().flyCity[self.player.cityID][1]
		local flyCity=self.cityList[flyCityID]
		if(self.landSp==nil)then
			self.landSp=CCSprite:createWithSpriteFrameName("serverWarLand.png")
			self.landSp:setPosition(flyCity.cfg.pos[1],flyCity.cfg.pos[2])
			self.background:addChild(self.landSp,4)
		end
		self.landSp:setVisible(true)
		local moveUp=CCMoveTo:create(0.7,ccp(flyCity.cfg.pos[1],flyCity.cfg.pos[2] + 20))
		local moveDown=CCMoveTo:create(0.7,ccp(flyCity.cfg.pos[1],flyCity.cfg.pos[2]))
		local seq=CCSequence:createWithTwoActions(moveUp,moveDown)
		self.landSp:runAction(CCRepeatForever:create(seq))
	else
		if(self.landSp)then
			self.landSp:stopAllActions()
			self.landSp:setVisible(false)
		end
	end
end

function serverWarTeamMapScene:distance(pos1,pos2)
	return math.sqrt((pos1[1]-pos2[1])*(pos1[1]-pos2[1])+(pos1[2]-pos2[2])*(pos1[2]-pos2[2]))
end

function serverWarTeamMapScene:cityStatusChange(data)
	if(data and data.data)then
		for k,v in pairs(data.data) do
			if(self.cityNameList[v.id])then
				local side=v:getSide()
				if(side==1)then
					self.cityNameList[v.id][1]:setVisible(true)
					self.cityNameList[v.id][2]:setVisible(false)
					self.cityNameList[v.id][3]:setVisible(false)
				else
					self.cityNameList[v.id][1]:setVisible(false)
					self.cityNameList[v.id][2]:setVisible(true)
					self.cityNameList[v.id][3]:setVisible(false)
				end
			end
		end
	end
end

function serverWarTeamMapScene:playerStatusChange(data)
	if(data.data)then
		for k,v in pairs(data.data) do
			if(v.id==self.player.id)then
				self.player=serverWarTeamFightVoApi:getPlayer()
				if(self.player.canMoveTime>base.serverTime)then
					self.playerIcon:stopAllActions()
					local targetCity=self.cityList[self.player.cityID]
					self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
					if(self.player.lastEnemyID and self.player.battleTime~=self.dieTipTime)then
						--因为有可能同一次死亡消息在refresh和push中重复发了请求, 所以记一个时间, 如果死亡时间相同的话就不再提示
						local enemy=serverWarTeamFightVoApi:getPlayer(self.player.lastEnemyID)
						if(enemy)then
							local function callback()
								smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_youAreKilled",{enemy.name}),nil,self.layerNum+2)
							end
							if(serverWarTeamFightVoApi:checkShowSelfCity())then
								local delay=CCDelayTime:create(4)
								local callFunc=CCCallFunc:create(callback)
								local acArr=CCArray:create()
								acArr:addObject(delay)
								acArr:addObject(callFunc)
								local seq=CCSequence:create(acArr)
								self.bgLayer:runAction(seq)
							else
								callback()
							end
							self.dieTipTime=self.player.battleTime
						end
					end
				end
				if(self.player.cityID==serverWarTeamFightVoApi:getMapCfg().airport[1] or self.player.cityID==serverWarTeamFightVoApi:getMapCfg().airport[2] or self.player.lastCityID==serverWarTeamFightVoApi:getMapCfg().airport[1] or self.player.lastCityID==serverWarTeamFightVoApi:getMapCfg().airport[2])then
					self:checkShowLanding()
				end
				if(self.player.arriveTime<=base.serverTime)then
					self.playerIcon:stopAllActions()
					local targetCity=self.cityList[self.player.cityID]
					self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
					if(self.landLine)then
						self.landLine:setVisible(false)
					end
				end
			end
		end
		self:refreshPlayers()
		local selfSide=serverWarTeamFightVoApi:getPlayer().side
		for i=1,2 do
			local airID=serverWarTeamFightVoApi:getMapCfg().airport[selfSide]
			local airCityIcon=tolua.cast(self.background:getChildByTag(tonumber(string.sub(airID,2))),"CCSprite")
			local airCityIcon1=tolua.cast(airCityIcon:getChildByTag(101),"CCSprite")
			local playerNum=0
			for id,player in pairs(serverWarTeamFightVoApi:getPlayers()) do
				if(player.arriveTime<=base.serverTime and player.cityID==airID)then
					playerNum=playerNum + 1
				end
				if(playerNum>=serverWarTeamFightVoApi:getMapCfg().flyNeed)then
					break
				end
			end
			if(playerNum>=serverWarTeamFightVoApi:getMapCfg().flyNeed)then
				airCityIcon1:setVisible(true)
				airCityIcon:setOpacity(0)
				if(i==selfSide)then
					if(self.airStatus==false)then
						self.airStatus=true
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_airEffectTip1"),30)
					end
				end
			else
				airCityIcon1:setVisible(false)
				airCityIcon:setOpacity(255)
				if(i==selfSide)then
					if(self.airStatus==true)then
						self.airStatus=false
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_airEffectTip2"),30)
					end
				end
			end
		end
	end
end

function serverWarTeamMapScene:buffStatusChange()
	for k,v in pairs(serverWarTeamFightVoApi:getBuffData()) do
		if(self.tipLvTb[k])then
			self.tipLvTb[k]:setString(v)
		end
	end
end

function serverWarTeamMapScene:pointStatusChange()
	self.progress1:setPercentage(serverWarTeamFightVoApi:getPoints()[1]/serverWarTeamCfg.winPointMax*100)
	self.progress2:setPercentage(serverWarTeamFightVoApi:getPoints()[2]/serverWarTeamCfg.winPointMax*100)
	local newPoint1=serverWarTeamFightVoApi:getPoints()[1]
	local newPoint2=serverWarTeamFightVoApi:getPoints()[2]
	local action11=CCTintBy:create(1,125,125,125)
	local action12=CCTintBy:create(1,255,255,255)
	local seq1=CCSequence:createWithTwoActions(action11,action12)
	local action21=CCTintBy:create(1,125,125,125)
	local action22=CCTintBy:create(1,255,255,255)
	local seq2=CCSequence:createWithTwoActions(action21,action22)
	if(newPoint1~=self.oldPoint1)then
		self.progress1:runAction(seq1)
	end
	if(newPoint2~=self.oldPoint2)then
		self.progress2:runAction(seq2)
	end
	self.progress1Lb:setString(serverWarTeamFightVoApi:getPoints()[1])
	self.progress2Lb:setString(serverWarTeamFightVoApi:getPoints()[2])
	self.oldPoint1=serverWarTeamFightVoApi:getPoints()[1]
	self.oldPoint2=serverWarTeamFightVoApi:getPoints()[2]
end

function serverWarTeamMapScene:roadStatusChange()
	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_countryRoadTip"),30)
	if(self.barricade1)then
		self.barricade1:removeFromParentAndCleanup(true)
		self.barricade1=nil
	end
	if(self.barricade2)then
		self.barricade2:removeFromParentAndCleanup(true)
		self.barricade2=nil
	end
	self:showCountryRoadDirect()
end

function serverWarTeamMapScene:accelerate()
	if(serverWarTeamFightVoApi:getStartTime()>base.serverTime)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_moveError5"),30)
		do return end
	end
	if(self.player.canMoveTime>base.serverTime + 1)then
		local costGems=serverWarTeamCfg.reviveCost
		if(serverWarTeamFightVoApi:getGems()<costGems)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_not_enough_gem"),30)
			do return end
		end
		local function onConfirm()
			local function callback()
				self:refreshPlayers()
			end
			serverWarTeamFightVoApi:revive(callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("accelerateGroupDesc",{costGems}),nil,self.layerNum+1)
	elseif(self.player.arriveTime>base.serverTime + 1)then
		local costGems=serverWarTeamCfg.speedBuff.cost[self.player.speedUpNum + 1]
		if(costGems==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_accelerateMax"),30)
			do return end
		end
		if(serverWarTeamFightVoApi:getGems()<costGems)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_not_enough_gem"),30)
			do return end
		end
		local function onConfirm()
			local function callback()
				self.playerIcon:stopAllActions()
				self.player=serverWarTeamFightVoApi:getPlayer()
				local targetCity=self.cityList[self.player.cityID]
				if(self.player.arriveTime<=base.serverTime)then
					self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
				else
					local targetCity=self.cityList[self.player.cityID]
					local startCity=self.cityList[self.player.lastCityID]
					if(startCity and (startCity.id=="a4" and targetCity.id=="a13") or (startCity.id=="a12" and targetCity.id=="a3"))then
						local startPos,cornerPos,endPos
						if(targetCity.id=="a13")then
							startPos=ccp(590,startCity.cfg.pos[2])
							cornerPos=ccp(590,630)
						else
							startPos=ccp(50,startCity.cfg.pos[2])
							cornerPos=ccp(50,310)
						end
						endPos=ccp(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
						local distance1=self:distance({startPos.x,startPos.y},{cornerPos.x,cornerPos.y})
						local distance2=self:distance({endPos.x,endPos.y},{cornerPos.x,cornerPos.y})
						local totalDistance=distance1 + distance2
						local key
						for k,tmpID in pairs(startCity.cfg.adjoin) do
							if(tmpID==targetCity.id)then
								key=k
								break
							end
						end
						local leftTime=self.player.arriveTime - base.serverTime
						local passCorner
						if(targetCity.id=="a13")then
							if(self.playerIcon:getPositionY()>=cornerPos.y)then
								passCorner=true
							else
								passCorner=false
							end
						else
							if(self.playerIcon:getPositionY()<=cornerPos.y)then
								passCorner=true
							else
								passCorner=false
							end
						end
						if(passCorner)then
							local moveTo=CCMoveTo:create(leftTime,endPos)
							self.playerIcon:runAction(moveTo)
						else
							local distance1=self:distance({self.playerIcon:getPositionX(),self.playerIcon:getPositionY()},{cornerPos.x,cornerPos.y})
							local distance2=self:distance({cornerPos.x,cornerPos.y},{endPos.x,endPos.y})
							local totalDistance=distance1 + distance2
							local needTime1=leftTime*distance1/totalDistance
							local needTime2=leftTime*distance2/totalDistance
							local moveTo1=CCMoveTo:create(needTime1,cornerPos)
							local moveTo2=CCMoveTo:create(needTime2,endPos)
							local seq=CCSequence:createWithTwoActions(moveTo1,moveTo2)
							self.playerIcon:runAction(seq)
						end
					else
						local leftTime=self.player.arriveTime - base.serverTime
						local endPos
						if(targetCity.cfg.movePos)then
							endPos=targetCity.cfg.movePos
						else
							endPos=targetCity.cfg.pos
						end
						local moveTo=CCMoveTo:create(leftTime,ccp(endPos[1],endPos[2]))
						self.playerIcon:runAction(moveTo)
					end
				end
			end
			serverWarTeamFightVoApi:accelerate(callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_accelerateConfirm",{costGems}),nil,self.layerNum+1)
	else
		do return end
	end
end

function serverWarTeamMapScene:findSelf()
	if(self.playerIcon)then
		local fadeOut=CCTintTo:create(0.5,97,97,97)
		local fadeIn=CCTintTo:create(0.5,255,255,255)
		local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
		self.playerIcon:runAction(seq)
		local playerPic=tolua.cast(self.playerIcon:getChildByTag(101),"CCSprite")
		local fadeOut=CCTintTo:create(0.5,97,97,97)
		local fadeIn=CCTintTo:create(0.5,255,255,255)
		local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
		playerPic:runAction(seq)
		self.clayer:setPosition(self.mapSize.width/2 - self.playerIcon:getPositionX(),self.mapSize.height/2 - self.playerIcon:getPositionY())
		self:checkBound()
	end
end

--播放飞机轰炸动画
function serverWarTeamMapScene:airAttack()
	self.airAttacking=true
	self.airMvList={}
	self.airMvNum=0
	local function onActionEnd()
		for k,v in pairs(self.airMvList) do
			v:stopAllActions()
			v:removeFromParentAndCleanup(true)
		end
		self.airMvList=nil
		self.airMvNum=0
		self.airAttacking=false
	end
	local callFunc=CCCallFunc:create(onActionEnd)
	local flag1,flag2=true,true
	if(serverWarTeamFightVoApi:checkAirAttackEffective(1))then
		flag1=false
		for i=1,3 do
			local shadowSp=CCSprite:createWithSpriteFrameName("serverWarPlaneShadow.png")
			local planeSp=CCSprite:createWithSpriteFrameName("serverWarPlane1.png")
			local point1,point2,point3,shadowPoint1,shadowPoint2,shadowPoint3,cPoint1,cPoint2,ePoint
			if(i==1)then
				shadowSp:setPosition(ccp(218,-50))
				planeSp:setPosition(ccp(228,-40))
				point1=ccp(203.5,169)
				shadowPoint1=ccp(193.5,159)
				point2=ccp(179,378)
				shadowPoint2=ccp(169,368)
				point3=ccp(154.5,587)
				shadowPoint3=ccp(144.5,577)
				cPoint1=ccp(100,630)
				cPoint2=ccp(40,680)
				ePoint=ccp(-40,722)
			elseif(i==2)then
				shadowSp:setPosition(ccp(188,-90))
				planeSp:setPosition(ccp(198,-80))
				point1=ccp(173.5,129)
				shadowPoint1=ccp(163.5,119)
				point2=ccp(149,338)
				shadowPoint2=ccp(139,328)
				point3=ccp(124.5,547)
				shadowPoint3=ccp(114.5,537)
				cPoint1=ccp(70,590)
				cPoint2=ccp(10,640)
				ePoint=ccp(-70,682)
			else
				shadowSp:setPosition(ccp(248,-90))
				planeSp:setPosition(ccp(258,-80))
				point1=ccp(233.5,129)
				shadowPoint1=ccp(223.5,119)
				point2=ccp(209,338)
				shadowPoint2=ccp(199,328)
				point3=ccp(184.5,547)
				shadowPoint3=ccp(174.5,537)
				cPoint1=ccp(130,590)
				cPoint2=ccp(70,640)
				ePoint=ccp(-40,682)
			end
			shadowSp:setRotation(-7)
			planeSp:setRotation(-7)
			self.background:addChild(shadowSp,5)
			self.background:addChild(planeSp,6)
			table.insert(self.airMvList,shadowSp)
			table.insert(self.airMvList,planeSp)
			local moveTo1=CCMoveTo:create(0.8,point1)
			local moveTo2=CCMoveTo:create(0.8,point2)
			local moveTo3=CCMoveTo:create(0.8,point3)
			local function bomb1()
				self:addBomb(serverWarTeamFightVoApi:getMapCfg().cityCfg["a3"].pos[1],serverWarTeamFightVoApi:getMapCfg().cityCfg["a3"].pos[2] + 30)
				self:addBombTip(1,"a3")
			end
			local bombFunc1=CCCallFunc:create(bomb1)
			local function bomb2()
				self:addBomb(serverWarTeamFightVoApi:getMapCfg().cityCfg["a6"].pos[1],serverWarTeamFightVoApi:getMapCfg().cityCfg["a6"].pos[2] + 30)
				self:addBombTip(1,"a6")
			end
			local bombFunc2=CCCallFunc:create(bomb2)
			local function bomb3()
				self:addBomb(serverWarTeamFightVoApi:getMapCfg().cityCfg["a9"].pos[1],serverWarTeamFightVoApi:getMapCfg().cityCfg["a9"].pos[2] + 30)
				self:addBombTip(1,"a9")
			end
			local bombFunc3=CCCallFunc:create(bomb3)
			local bezier=ccBezierConfig()
			bezier.controlPoint_1=cPoint1
			bezier.controlPoint_2=cPoint2
			bezier.endPosition=ePoint
			local bezierForward=CCBezierTo:create(0.8, bezier)
			local rotateTo=CCRotateTo:create(0.8,-90)
			local rotateArr=CCArray:create()
			rotateArr:addObject(bezierForward)
			rotateArr:addObject(rotateTo)
			local spawn=CCSpawn:create(rotateArr)
			local delay=CCDelayTime:create(0.5)
			local actionArr=CCArray:create()
			actionArr:addObject(moveTo1)
			if(i==1)then
				actionArr:addObject(bombFunc1)
			end
			actionArr:addObject(moveTo2)
			if(i==1)then
				actionArr:addObject(bombFunc2)
			end
			actionArr:addObject(moveTo3)
			if(i==1)then
				actionArr:addObject(bombFunc3)
			end
			actionArr:addObject(spawn)
			actionArr:addObject(delay)
			actionArr:addObject(callFunc)
			local seq=CCSequence:create(actionArr)
			planeSp:runAction(seq)
			local moveTo1=CCMoveTo:create(0.8,shadowPoint1)
			local moveTo2=CCMoveTo:create(0.8,shadowPoint2)
			local moveTo3=CCMoveTo:create(0.8,shadowPoint3)
			local bezier=ccBezierConfig()
			bezier.controlPoint_1=ccp(cPoint1.x - 10,cPoint1.y - 10)
			bezier.controlPoint_2=ccp(cPoint2.x - 10,cPoint2.y - 10)
			bezier.endPosition=ccp(ePoint.x - 10,ePoint.y - 10)
			local bezierForward=CCBezierTo:create(0.8, bezier)
			local rotateTo=CCRotateTo:create(0.8,-90)
			local rotateArr=CCArray:create()
			rotateArr:addObject(bezierForward)
			rotateArr:addObject(rotateTo)
			local spawn=CCSpawn:create(rotateArr)
			local actionArr=CCArray:create()
			actionArr:addObject(moveTo1)
			actionArr:addObject(moveTo2)
			actionArr:addObject(moveTo3)
			actionArr:addObject(spawn)
			local seq=CCSequence:create(actionArr)
			shadowSp:runAction(seq)
		end
		local shadowSp=CCSprite:createWithSpriteFrameName("serverWarPlaneShadow.png")
		shadowSp:setPosition(ccp(-50,74.5))
		shadowSp:setRotation(90)
		self.background:addChild(shadowSp,5)
		table.insert(self.airMvList,shadowSp)
		local planeSp=CCSprite:createWithSpriteFrameName("serverWarPlane1.png")
		planeSp:setPosition(ccp(-40,84.5))
		planeSp:setRotation(90)
		self.background:addChild(planeSp,6)
		table.insert(self.airMvList,planeSp)
		local moveTo1=CCMoveTo:create(2,ccp(544.5,84.5))
		local function bomb()
			self:addBomb(544.5,114.5)
			self:addBombTip(1,"a1")
		end
		local bombFunc=CCCallFunc:create(bomb)
		local moveTo2=CCMoveTo:create(0.6,ccp(690,84.5))
		local acArr=CCArray:create()
		acArr:addObject(moveTo1)
		acArr:addObject(bombFunc)
		acArr:addObject(moveTo2)
		local seq=CCSequence:create(acArr)
		planeSp:runAction(seq)
		local moveTo1=CCMoveTo:create(2,ccp(534.5,74.5))
		local moveTo2=CCMoveTo:create(0.6,ccp(680,74.5))
		local seq=CCSequence:createWithTwoActions(moveTo1,moveTo2)
		shadowSp:runAction(seq)
	end
	if(serverWarTeamFightVoApi:checkAirAttackEffective(2))then
		flag2=false
		for i=1,3 do
			local shadowSp=CCSprite:createWithSpriteFrameName("serverWarPlaneShadow.png")
			local planeSp=CCSprite:createWithSpriteFrameName("serverWarPlane2.png")
			local point1,point2,point3,shadowPoint1,shadowPoint2,shadowPoint3,cPoint1,cPoint2,ePoint
			if(i==1)then
				shadowSp:setPosition(ccp(422,1010))
				planeSp:setPosition(ccp(412,1000))
				point1=ccp(436.5,791)
				shadowPoint1=ccp(446.5,801)
				point2=ccp(461,582)
				shadowPoint2=ccp(471,592)
				point3=ccp(485.5,373)
				shadowPoint3=ccp(495.5,383)
				cPoint1=ccp(540,330)
				cPoint2=ccp(600,280)
				ePoint=ccp(680,238)
			elseif(i==2)then
				shadowSp:setPosition(ccp(452,1050))
				planeSp:setPosition(ccp(442,1040))
				point1=ccp(466.5,831)
				shadowPoint1=ccp(476.5,841)
				point2=ccp(491,622)
				shadowPoint2=ccp(501,632)
				point3=ccp(515.5,413)
				shadowPoint3=ccp(525.5,423)
				cPoint1=ccp(570,370)
				cPoint2=ccp(630,320)
				ePoint=ccp(710,278)
			else
				shadowSp:setPosition(ccp(392,1050))
				planeSp:setPosition(ccp(382,1040))
				point1=ccp(406.5,831)
				shadowPoint1=ccp(416.5,841)
				point2=ccp(431,622)
				shadowPoint2=ccp(441,632)
				point3=ccp(455.5,413)
				shadowPoint3=ccp(465.5,423)
				cPoint1=ccp(510,370)
				cPoint2=ccp(570,320)
				ePoint=ccp(680,278)
			end
			shadowSp:setRotation(173)
			planeSp:setRotation(173)
			self.background:addChild(shadowSp,5)
			self.background:addChild(planeSp,6)
			table.insert(self.airMvList,shadowSp)
			table.insert(self.airMvList,planeSp)
			local moveTo1=CCMoveTo:create(0.8,point1)
			local moveTo2=CCMoveTo:create(0.8,point2)
			local moveTo3=CCMoveTo:create(0.8,point3)
			local function bomb1()
				self:addBomb(serverWarTeamFightVoApi:getMapCfg().cityCfg["a13"].pos[1],serverWarTeamFightVoApi:getMapCfg().cityCfg["a13"].pos[2] + 30)
				self:addBombTip(2,"a13")
			end
			local bombFunc1=CCCallFunc:create(bomb1)
			local function bomb2()
				self:addBomb(serverWarTeamFightVoApi:getMapCfg().cityCfg["a10"].pos[1],serverWarTeamFightVoApi:getMapCfg().cityCfg["a10"].pos[2] + 30)
				self:addBombTip(2,"a10")
			end
			local bombFunc2=CCCallFunc:create(bomb2)
			local function bomb3()
				self:addBomb(serverWarTeamFightVoApi:getMapCfg().cityCfg["a7"].pos[1],serverWarTeamFightVoApi:getMapCfg().cityCfg["a7"].pos[2] + 30)
				self:addBombTip(2,"a7")
			end
			local bombFunc3=CCCallFunc:create(bomb3)
			local bezier=ccBezierConfig()
			bezier.controlPoint_1=cPoint1
			bezier.controlPoint_2=cPoint2
			bezier.endPosition=ePoint
			local bezierForward=CCBezierTo:create(0.8, bezier)
			local rotateTo=CCRotateTo:create(0.8,90)
			local rotateArr=CCArray:create()
			rotateArr:addObject(bezierForward)
			rotateArr:addObject(rotateTo)
			local spawn=CCSpawn:create(rotateArr)
			local delay=CCDelayTime:create(0.5)
			local actionArr=CCArray:create()
			actionArr:addObject(moveTo1)
			if(i==1)then
				actionArr:addObject(bombFunc1)
			end
			actionArr:addObject(moveTo2)
			if(i==1)then
				actionArr:addObject(bombFunc2)
			end
			actionArr:addObject(moveTo3)
			if(i==1)then
				actionArr:addObject(bombFunc3)
			end
			actionArr:addObject(spawn)
			actionArr:addObject(delay)
			actionArr:addObject(callFunc)
			local seq=CCSequence:create(actionArr)
			planeSp:runAction(seq)
			local moveTo1=CCMoveTo:create(0.8,shadowPoint1)
			local moveTo2=CCMoveTo:create(0.8,shadowPoint2)
			local moveTo3=CCMoveTo:create(0.8,shadowPoint3)
			local bezier=ccBezierConfig()
			bezier.controlPoint_1=ccp(cPoint1.x + 10,cPoint1.y + 10)
			bezier.controlPoint_2=ccp(cPoint2.x + 10,cPoint2.y + 10)
			bezier.endPosition=ccp(ePoint.x + 10,ePoint.y + 10)
			local bezierForward=CCBezierTo:create(0.8, bezier)
			local rotateTo=CCRotateTo:create(0.8,90)
			local rotateArr=CCArray:create()
			rotateArr:addObject(bezierForward)
			rotateArr:addObject(rotateTo)
			local spawn=CCSpawn:create(rotateArr)
			local actionArr=CCArray:create()
			actionArr:addObject(moveTo1)
			actionArr:addObject(moveTo2)
			actionArr:addObject(moveTo3)
			actionArr:addObject(spawn)
			local seq=CCSequence:create(actionArr)
			shadowSp:runAction(seq)
		end
		local shadowSp=CCSprite:createWithSpriteFrameName("serverWarPlaneShadow.png")
		shadowSp:setPosition(ccp(690,899.5))
		shadowSp:setRotation(-90)
		self.background:addChild(shadowSp,5)
		table.insert(self.airMvList,shadowSp)
		local planeSp=CCSprite:createWithSpriteFrameName("serverWarPlane2.png")
		planeSp:setPosition(ccp(680,889.5))
		planeSp:setRotation(-90)
		self.background:addChild(planeSp,6)
		table.insert(self.airMvList,planeSp)
		local moveTo1=CCMoveTo:create(2,ccp(90,889.5))
		local function bomb()
			self:addBomb(90,919.5)
			self:addBombTip(2,"a15")
		end
		local bombFunc=CCCallFunc:create(bomb)
		local moveTo2=CCMoveTo:create(0.6,ccp(-50,889.5))
		local acArr=CCArray:create()
		acArr:addObject(moveTo1)
		acArr:addObject(bombFunc)
		acArr:addObject(moveTo2)
		local seq=CCSequence:create(acArr)
		planeSp:runAction(seq)
		local moveTo1=CCMoveTo:create(2,ccp(100,899.5))
		local moveTo2=CCMoveTo:create(0.6,ccp(-40,899.5))
		local seq=CCSequence:createWithTwoActions(moveTo1,moveTo2)
		shadowSp:runAction(seq)
	end
	if(flag1 and flag2)then
		self.airAttacking=false
	end
end

function serverWarTeamMapScene:addBomb(x,y)
	local mzSp=CCSprite:createWithSpriteFrameName("die_1.png")
	mzSp:setScale(0.8)
	mzSp:setPosition(ccp(x,y))
	self.background:addChild(mzSp,4)
	local mzArr=CCArray:create()
	for kk=1,18 do
		local nameStr="die_"..kk..".png"
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		mzArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(mzArr)
	animation:setDelayPerUnit(0.06)
	local animate=CCAnimate:create(animation)
	local function mzEnd()
		mzSp:stopAllActions()
		mzSp:removeFromParentAndCleanup(true)
	end
	local mzfunc=CCCallFuncN:create(mzEnd)
	local acArr=CCArray:create()
	acArr:addObject(animate)
	acArr:addObject(mzfunc)
	local seq=CCSequence:create(acArr)
	mzSp:runAction(seq)
end

function serverWarTeamMapScene:addBombTip(side,cityID)
	if(self.player.side~=side)then
		do return end
	end
	local cityVo=self.cityList[cityID]
	if(cityVo)then
		local enemySide
		if(side==1)then
			enemySide=2
		else
			enemySide=1
		end
		local enemyNum=#serverWarTeamFightVoApi:getLivePlayersInCity(cityID,enemySide)
		if(enemyNum>0)then
			local tipSp=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
			tipSp:setOpacity(0)
			local tipLb=GetTTFLabelWrap(getlocal("serverwarteam_airAttackTip",{(serverWarTeamFightVoApi:getMapCfg().bombHpPercent*100).."%%"}),22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			local tipBg=LuaCCScale9Sprite:createWithSpriteFrameName("tipsBg.png",CCRect(0, 50, 1, 60),function ( ... )end)
			local scale=200/611
			tipBg:setScale(scale)
			tipBg:setContentSize(CCSizeMake(611,(tipLb:getContentSize().height + 30)/scale))
			tipBg:setAnchorPoint(ccp(0.5,0))
			tipBg:setPosition(20,0)
			tipSp:addChild(tipBg)
			tipLb:setAnchorPoint(ccp(0.5,0))
			tipLb:setPosition(20,10)
			tipSp:addChild(tipLb)
			local cityVo=self.cityList[cityID]
			tipSp:setPosition(cityVo.cfg.pos[1],cityVo.cfg.pos[2] + 40)
			self.background:addChild(tipSp,4)
			local moveTo=CCMoveTo:create(0.8,ccp(cityVo.cfg.pos[1],cityVo.cfg.pos[2] + 140))
			local fadeOut=CCFadeOut:create(0.8)
			local spawn=CCSpawn:createWithTwoActions(moveTo,fadeOut)
			local function onEnd()
				tipSp:stopAllActions()
				tipSp:removeFromParentAndCleanup(true)
			end
			local endFunc=CCCallFunc:create(onEnd)
			local seq=CCSequence:createWithTwoActions(spawn,endFunc)
			tipSp:runAction(seq)
		end
	end
end

function serverWarTeamMapScene:initChat()
	local chatBg,chatMenu=G_initChat(self.bgLayer,self.layerNum,true,3,11,100)
	chatBg:setTouchPriority(-(self.layerNum-1)*20-8)
	chatMenu:setTouchPriority(-(self.layerNum-1)*20-8)
	self.chatBg=chatBg
end

function serverWarTeamMapScene:tick()
	if self.chatBg then
		G_setLastChat(self.chatBg,false,3,11)
	end
	if(base.serverTime<serverWarTeamFightVoApi:getStartTime())then
		self.countdownLb:setString(getlocal("serverwar_battleCountDown").."\n"..GetTimeStr(serverWarTeamFightVoApi:getStartTime() - base.serverTime))
	else
		self.countdownLb:setString(getlocal("allianceWar_battleEnd").."\n"..GetTimeStr(serverWarTeamFightVoApi:getStartTime() + serverWarTeamCfg.warTime - base.serverTime))
	end
	local btnLb=tolua.cast(self.accItem:getChildByTag(518),"CCLabelTTF")
	if(self.player.canMoveTime>base.serverTime)then
		self.accItem:setEnabled(true)
		self.findSelfBtn:setPositionX(999333)
		self.findSelfBtn:setVisible(false)
		local countdownStr=math.floor(self.player.canMoveTime - base.serverTime).."s"
		btnLb:setString(countdownStr)
	elseif(self.player.arriveTime>base.serverTime)then
		self.accItem:setEnabled(true)
		self.findSelfBtn:setPositionX(999333)
		self.findSelfBtn:setVisible(false)
		local countdownStr=math.floor(self.player.arriveTime - base.serverTime).."s"
		btnLb:setString(countdownStr)
	elseif(self.player.arriveTime>=base.serverTime - 6)then
		self.accItem:setEnabled(false)
		self.findSelfBtn:setPositionX(100)
		self.findSelfBtn:setVisible(true)
		btnLb:setString(getlocal("serverwarteam_searchBattle"))
		local lb=tolua.cast(self.findSelfItem:getChildByTag(518),"CCLabelTTF")
		lb:setString(getlocal("serverwarteam_searchBattle"))
	else
		self.accItem:setEnabled(false)
		btnLb:setString(getlocal("serverwarteam_staying"))
		self.findSelfBtn:setPositionX(100)
		self.findSelfBtn:setVisible(true)
		local lb=tolua.cast(self.findSelfItem:getChildByTag(518),"CCLabelTTF")
		lb:setString(getlocal("serverwarteam_staying"))
	end
	self.gemLb:setString(serverWarTeamFightVoApi:getGems())
	if(self.barricade1)then
		local countdownBg=tolua.cast(self.barricade1:getChildByTag(101),"LuaCCScale9Sprite")
		local countdownLb=tolua.cast(countdownBg:getChildByTag(101),"CCLabelTTF")
		countdownLb:setString(GetTimeStr(serverWarTeamFightVoApi:getStartTime() + serverWarTeamCfg.countryRoadTime - base.serverTime))
	end
	if(self.barricade2)then
		local countdownBg=tolua.cast(self.barricade2:getChildByTag(101),"LuaCCScale9Sprite")
		local countdownLb=tolua.cast(countdownBg:getChildByTag(101),"CCLabelTTF")
		countdownLb:setString(GetTimeStr(serverWarTeamFightVoApi:getStartTime() + serverWarTeamCfg.countryRoadTime - base.serverTime))
	end
	if(base.serverTime%5==0 and self.airAttacking~=true)then
		self:airAttack()
	end
end

function serverWarTeamMapScene:close()
	self.playerIcon:stopAllActions()
	self.progress1:stopAllActions()
	self.progress2:stopAllActions()
	self.bgLayer:stopAllActions()
	eventDispatcher:removeEventListener("serverWarTeam.battle",self.eventListener)
	self.eventListener=nil
	self.buffLayer:stopAllActions()
	self.listLayer:stopAllActions()
	base:removeFromNeedRefresh(self)
	self.layerNum=nil
	self.mapCfg=nil
	self.isShow=false
	self.clayer=nil
	self.background=nil
	self.mapSize=nil
	self.progress1=nil
	self.progress2=nil
	self.progress1Lb=nil
	self.progress2Lb=nil
	self.accItem=nil
	self.buffLayer=nil
	self.listLayer=nil
	self.switchItemLeft=nil
	self.tipLvTb=nil
	self.gemLb=nil
	self.friends=nil
	self.friendsLiveNum=0
	self.enemyNum=0
	self.listTv=nil
	self.arrowTb=nil
	self.player=nil
	self.playerIcon=nil
	self.arriveFlag=nil
	self.dieTipTime=nil
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.firstOldPos=nil
	self.secondOldPos=nil
	self.touchArr=nil
	self.isShow=false
	self.chatBg=nil
	self.barricade1=nil
	self.barricade2=nil
	self.airAttacking=nil
	self.airMvList=nil
	self.airMvNum=0
	self.airStatus=false
	self.landSp=nil
	self.roadDirect1=nil
	self.roadDirect2=nil
	self.orderTipList=nil
	base.pauseSync=false
	base.allShowedCommonDialog=math.max(base.allShowedCommonDialog-1,0)
	for k,v in pairs(base.commonDialogOpened_WeakTb) do
		if v==self then
			table.remove(base.commonDialogOpened_WeakTb,k)
			break
		end
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWarCityIcon.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWarCityIcon.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/serverWarLocal/serverWarLocalCity.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/serverWarLocal/serverWarLocalCity.png")
	spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
	spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
	CCTextureCache:sharedTextureCache():removeTextureForKey("serverWar/serverWarTeamMap.jpg")
end