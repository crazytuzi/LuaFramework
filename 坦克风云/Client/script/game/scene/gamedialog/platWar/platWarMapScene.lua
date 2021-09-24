--平台战战场场景
platWarMapScene=
{
	bgLayer=nil,
	clayer=nil,
	background=nil,
	minScale=1,
	maxScale=2,
	isShow=false,
	beforeHideIsShow=false, 
	chatBg=nil,
	arrow=nil,
	troopsTipSp=nil,
	refreshTime=0,
}

function platWarMapScene:show(layerNum)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.touchArr={}
	self:initBackground()
	self:initFunctionBar()
	self:initMap()
	if base.pwNoticeSwitch>0 then
		self:initNotice()
	end
	self:initPlayer()
	self.isShow=true
	self.refreshTime=platWarVoApi:getBattleExpireTime()
	sceneGame:addChild(self.bgLayer,self.layerNum)
	base:addNeedRefresh(self)
	base.allShowedCommonDialog=base.allShowedCommonDialog+1
	table.insert(base.commonDialogOpened_WeakTb,self)
end

function platWarMapScene:initBackground()
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(touchDialogBg)

	self:initTitle()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local mapBg=CCSprite:create("public/platWar/platWarMapBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.mapSize=mapBg:getContentSize()
	self.clayer=CCLayer:create()
	self.clayer:setTouchEnabled(true)
	local function tmpHandler(...)
		return self:touchEvent(...)
	end
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
	self.clayer:setPosition(ccp(0,G_VisibleSizeHeight - self.mapSize.height))
	self.bgLayer:addChild(self.clayer)

	self.background=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20,20,10,10),function ( ... )end)
	self.background:setAnchorPoint(ccp(0,0))
	self.background:setTouchPriority(-(self.layerNum-1)*20)
	self.background:setContentSize(mapBg:getContentSize())
	self.background:setPosition(ccp(0,0))
	self.clayer:addChild(self.background)

	mapBg:setAnchorPoint(ccp(0.5,0))
	mapBg:setPosition(ccp(self.mapSize.width/2,0))
	self.background:addChild(mapBg)
end

function platWarMapScene:initTitle()
	local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),function ()end)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-8)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,125))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(ccp(0,G_VisibleSizeHeight + 2))
	self.bgLayer:addChild(titleBg,3)

	self.titleHeight=titleBg:getContentSize().height

	local flag1=CCSprite:createWithSpriteFrameName("platWarFlag1.png")
	flag1:setAnchorPoint(ccp(0,0.5))
	flag1:setPosition(ccp(10,self.titleHeight/2))
	titleBg:addChild(flag1)
	local flag2=CCSprite:createWithSpriteFrameName("platWarFlag2.png")
	flag2:setFlipX(true)
	flag2:setAnchorPoint(ccp(1,0.5))
	flag2:setPosition(ccp(G_VisibleSizeWidth - 10,self.titleHeight/2))
	titleBg:addChild(flag2)

	local platName1=GetTTFLabelWrap(platWarVoApi:getPlatList()[1][2],25,CCSizeMake(190,self.titleHeight + 20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	platName1:setAnchorPoint(ccp(0,0.5))
	platName1:setPosition(ccp(80,self.titleHeight/2 + 20))
	titleBg:addChild(platName1,4)
	local platName2=GetTTFLabelWrap(platWarVoApi:getPlatList()[2][2],25,CCSizeMake(190,self.titleHeight + 20),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
	platName2:setAnchorPoint(ccp(1,0.5))
	platName2:setPosition(ccp(G_VisibleSizeWidth - 80,self.titleHeight/2 + 20))
	titleBg:addChild(platName2,4)
	local vSp=CCSprite:createWithSpriteFrameName("v.png")
	vSp:setScale(0.5)
	vSp:setPosition(ccp(G_VisibleSizeWidth/2 - 30,self.titleHeight/2 + 20))
	titleBg:addChild(vSp,3)
	local sSp=CCSprite:createWithSpriteFrameName("s.png")
	sSp:setScale(0.5)
	sSp:setPosition(ccp(G_VisibleSizeWidth/2 + 30,self.titleHeight/2 + 20))
	titleBg:addChild(sSp,3)

	local progressBg=CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
	progressBg:setPosition(ccp(G_VisibleSizeWidth/2,self.titleHeight/2 - 40))
	titleBg:addChild(progressBg,3)

	self.progress1=CCSprite:createWithSpriteFrameName("platWarProgress1.png")
	self.progress1=CCProgressTimer:create(self.progress1)
	self.progress1:setType(kCCProgressTimerTypeBar)
	self.progress1:setMidpoint(ccp(0,0))
	self.progress1:setBarChangeRate(ccp(1,0))
	self.progress1:setPosition(G_VisibleSizeWidth/2,self.titleHeight/2 - 40)
	self.progress2=CCSprite:createWithSpriteFrameName("platWarProgress2.png")
	self.progress2:setPosition(G_VisibleSizeWidth/2,self.titleHeight/2 - 40)
	titleBg:addChild(self.progress2,3)
	titleBg:addChild(self.progress1,3)
	self.cityList=platWarVoApi:getCityList()
	local num1,num2,num=0,0,0
	for road,tb in pairs(self.cityList) do
		for point,cityVo in pairs(tb) do
			if(cityVo.side==1)then
				num1=num1 + 1
			elseif(cityVo.side==2)then
				num2=num2 + 1
			end
		end
	end
	num=num1 + num2
	self.totalFire=CCSprite:createWithSpriteFrameName("platWarLight1.png")
	titleBg:addChild(self.totalFire,4)
	local fireArr=CCArray:create()
	for i=1,6 do
		local nameStr="platWarLight"..i..".png"
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		fireArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(fireArr)
	animation:setDelayPerUnit(0.03)
	local animate=CCAnimate:create(animation)
	local repeatForever=CCRepeatForever:create(animate)
	self.totalFire:runAction(repeatForever)
	if(num==0)then
		self.progress1:setPercentage(50)
		self.totalFire:setPosition(G_VisibleSizeWidth/2,self.titleHeight/2 - 40)
	else
		self.progress1:setPercentage(num1/num*100)
		self.totalFire:setPosition(G_VisibleSizeWidth/2 - 420/2 + 420*num1/num,self.titleHeight/2 - 40)
	end
	local curRoundBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(10,0,100,36),function ( ... )end)
	curRoundBg:setContentSize(CCSizeMake(G_VisibleSizeWidth/2,40))
	curRoundBg:setPosition(G_VisibleSizeWidth/2,-20)
	titleBg:addChild(curRoundBg)
	local status=platWarVoApi:checkStatus()
	if(status<=0)then
		self.curRoundLb=GetTTFLabel(getlocal("dailyAnswer_tab1_question_title1"),25)
		self.totalFire:setVisible(false)
	elseif(status<20)then
		self.curRoundLb=GetTTFLabel(getlocal("world_war_matchStatus1"),25)
		self.totalFire:setVisible(false)
	elseif(status<30)then
		self.curRoundLb=GetTTFLabel(getlocal("plat_war_cur_round",{platWarVoApi:getCurRound()}),25)
		self.totalFire:setVisible(true)
	else
		self.curRoundLb=GetTTFLabel(getlocal("serverwarteam_all_end"),25)
		self.totalFire:setVisible(false)
	end
	self.curRoundLb:setColor(G_ColorYellowPro)
	self.curRoundLb:setPosition(curRoundBg:getContentSize().width/2,20)
	curRoundBg:addChild(self.curRoundLb)
end

function platWarMapScene:initFunctionBar()
	self.functionBarHeight=112
	local function nilFunc()
	end
	local functionBarBg=LuaCCScale9Sprite:createWithSpriteFrameName("localWar_functionBarBorder.png",CCRect(20,20,50,50),nilFunc)
	functionBarBg:setTouchPriority(-(self.layerNum-1)*20-7)
	functionBarBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.functionBarHeight))
	functionBarBg:setAnchorPoint(ccp(0.5,0))
	functionBarBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
	self.bgLayer:addChild(functionBarBg,5)
	self.functionBar=functionBarBg

	local function onClose()
		PlayEffect(audioCfg.mouseClick)    
		self:close()
	end
	local backBtnBg=LuaCCScale9Sprite:createWithSpriteFrameName("localWar_functionBarBorder.png",CCRect(20,20,50,50),nilFunc)
	backBtnBg:setContentSize(CCSizeMake(G_VisibleSizeWidth/5,self.functionBarHeight))
	backBtnBg:setAnchorPoint(ccp(1,0))
	backBtnBg:setPosition(ccp(G_VisibleSizeWidth,0))
	self.functionBar:addChild(backBtnBg)
	local backBtn=LuaCCSprite:createWithSpriteFrameName("IconReturn-.png",onClose)
	backBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	backBtn:setPosition(ccp(G_VisibleSizeWidth*9/10,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(backBtn)
	local backLb=GetTTFLabel(getlocal("coverFleetBack"),25)
	backLb:setColor(G_ColorYellowPro)
	backLb:setPosition(ccp(G_VisibleSizeWidth*9/10,20))
	functionBarBg:addChild(backLb)

	local functionBarWidth=G_VisibleSizeWidth*4/5
	local function onSetTroops()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if platWarVoApi:checkStatus()>=30 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_end"),30)
			do return end
		end
		platWarVoApi:showTroopsDialog(self.layerNum+1)
	end
	local setTroopsItem=GetButtonItem("mainBtnTeam.png","mainBtnTeam_Down.png","mainBtnTeam_Down.png",onSetTroops,nil,nil,nil)
	local setTroopsBtn=CCMenu:createWithItem(setTroopsItem)
	setTroopsBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	setTroopsBtn:setPosition(ccp(functionBarWidth/6,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(setTroopsBtn)
	local setTroopsLb=GetTTFLabel(getlocal("fleetInfoTitle2"),25)
	setTroopsLb:setColor(G_ColorGreen)
	setTroopsLb:setPosition(ccp(functionBarWidth/6,20))
	functionBarBg:addChild(setTroopsLb)
	self.troopsTipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
    self.troopsTipSp:setAnchorPoint(CCPointMake(1,1))
    self.troopsTipSp:setPosition(ccp(setTroopsItem:getContentSize().width,setTroopsItem:getContentSize().height))
    setTroopsItem:addChild(self.troopsTipSp,5)
	local fleetIndexTb=tankVoApi:getPlatWarFleetIndexTb()
    local isSetAll=tankVoApi:platWarIsAllSetFleet()
    if isSetAll==true and #fleetIndexTb>=3 then
        self.troopsTipSp:setVisible(false)
    else
        self.troopsTipSp:setVisible(true)
    end

	local function onBuff()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if platWarVoApi:checkStatus()>=30 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_end"),30)
			do return end
		end
		local function callback()
			platWarVoApi:showBuyBuffDialog(self.layerNum + 1)
		end		
		platWarVoApi:getInfo(callback)
	end
	local scienceItem=GetButtonItem("mainBtnCheckpoint.png","mainBtnCheckpoint_Down.png","mainBtnCheckpoint_Down.png",onBuff,nil,nil,nil)
	local scienceBtn=CCMenu:createWithItem(scienceItem)
	scienceBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	scienceBtn:setPosition(ccp(functionBarWidth/3,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(scienceBtn)
	local scienceLb=GetTTFLabel(getlocal("alliance_skill"),25)
	scienceLb:setColor(G_ColorGreen)
	scienceLb:setPosition(ccp(functionBarWidth/3,20))
	functionBarBg:addChild(scienceLb)

	local function onBattleReport()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		platWarVoApi:showReportDialog(self.layerNum+1)
	end
	local reportItem=GetButtonItem("mainBtnMail.png","mainBtnMail_Down.png","mainBtnMail_Down.png",onBattleReport,nil,nil,nil)
	local reportBtn=CCMenu:createWithItem(reportItem)
	reportBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	reportBtn:setPosition(ccp(functionBarWidth/2,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(reportBtn)
	self.tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp:setAnchorPoint(CCPointMake(1,0.5))
	self.tipSp:setPosition(ccp(reportItem:getContentSize().width,reportItem:getContentSize().height-15))
	self.tipSp:setVisible(false)
	reportItem:addChild(self.tipSp)
	local reportLb=GetTTFLabel(getlocal("allianceWar_battleReport"),25)
	reportLb:setColor(G_ColorGreen)
	reportLb:setPosition(ccp(functionBarWidth/2,20))
	functionBarBg:addChild(reportLb)

	local function onRankList()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		platWarVoApi:showRewardDialog(self.layerNum+1,1)
	end
	local rankItem=GetButtonItem("mainBtnRank.png","mainBtnRank_Down.png","mainBtnRank_Down.png",onRankList,nil,nil,nil)
	local rankBtn=CCMenu:createWithItem(rankItem)
	rankBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	rankBtn:setPosition(ccp(functionBarWidth*2/3,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(rankBtn)
	local rankLb=GetTTFLabel(getlocal("mainRank"),25)
	rankLb:setColor(G_ColorGreen)
	rankLb:setPosition(ccp(functionBarWidth*2/3,20))
	functionBarBg:addChild(rankLb)

	local function onHelp()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		platWarVoApi:showHelpDialog(self.layerNum+1)
	end
	local helpItem=GetButtonItem("mainBtnHelp.png","mainBtnHelp_Down.png","mainBtnHelp_Down.png",onHelp,nil,nil,nil)
	local helpBtn=CCMenu:createWithItem(helpItem)
	helpBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	helpBtn:setPosition(ccp(functionBarWidth*5/6,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(helpBtn)
	local helpLb=GetTTFLabel(getlocal("help"),25)
	helpLb:setColor(G_ColorGreen)
	helpLb:setPosition(ccp(functionBarWidth*5/6,20))
	functionBarBg:addChild(helpLb)
	--只有参赛选手才能看到设置部队和买buff的按钮
	local selfPlayer=platWarVoApi:getPlayer()
	if(selfPlayer==nil or selfPlayer.rank>platWarCfg.joinLimit)then
		setTroopsBtn:setVisible(false)
		setTroopsBtn:setPositionX(999333)
		setTroopsLb:setVisible(false)
		setTroopsLb:setPositionX(999333)
		scienceBtn:setVisible(false)
		scienceBtn:setPositionX(999333)
		scienceLb:setVisible(false)
		scienceLb:setPositionX(999333)
		reportBtn:setPositionX(functionBarWidth/4)
		reportLb:setPositionX(functionBarWidth/4)
		rankBtn:setPositionX(functionBarWidth/2)
		rankLb:setPositionX(functionBarWidth/2)
		helpBtn:setPositionX(functionBarWidth*3/4)
		helpLb:setPositionX(functionBarWidth*3/4)
	end
end

function platWarMapScene:touchEvent(fn,x,y,touch)
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

			local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
			local cceaseOut=CCEaseOut:create(ccmoveTo,3)
			self.clayer:runAction(cceaseOut)
		end
	else
		self.touchArr=nil
		self.touchArr={}
	end
end

function platWarMapScene:checkBound(pos)
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

function platWarMapScene:initMap()
	--摆城市
	local cityBatchNode=CCSpriteBatchNode:create("public/platWar/platWarImage.png",25)
	self.background:addChild(cityBatchNode,2)
	self.lineList=platWarVoApi:getLineList()
	self.hpList={}
	self.hpBgList={}
	self.lineProgressList={}
	self.cityFlagList={}

	local lineX={101,307,512,715,920}
	local disY=1200/platWarCfg.mapAttr.lineLength
	local posMap={}
	for k,v in pairs(platWarCfg.mapAttr.linePosClient) do
		posMap[v]=k
	end
	local function onClickLine(object,fn,tag)
		if self.isMoved==true or self.touchEnable==false then
			do return end
		end
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local lineID
		if(tag>1000)then
			lineID=math.floor(tag/1000)
		else
			lineID=tag
		end
		self:showLineTroopDialog(lineID)
	end
	for road,tb in pairs(self.cityList) do
		self.hpList[road]={}
		self.hpBgList[road]={}
		self.cityFlagList[road]={}
		for point,cityVo in pairs(tb) do
			local cityIcon=LuaCCSprite:createWithSpriteFrameName(cityVo:getIconName(),onClickLine)
			cityIcon:setTouchPriority(-(self.layerNum-1)*20-4)
			cityIcon:setIsSallow(false)
			cityIcon:setTag(cityVo.lineID*1000 + cityVo.pointID)
			cityIcon:setPosition(ccp(lineX[posMap[cityVo.lineID]],1600 - 217 - cityVo.pointID*disY))
			cityBatchNode:addChild(cityIcon,2)
	
			if(cityVo.type==1 or cityVo.type==2)then
				local progressBg=CCSprite:createWithSpriteFrameName("BlackBg.png")
				progressBg:setScaleX(18/progressBg:getContentSize().width)
				progressBg:setScaleY(93/progressBg:getContentSize().height)
				progressBg:setPosition(ccp(lineX[posMap[cityVo.lineID]] - 80,1600 - 217 - cityVo.pointID*disY))
				self.background:addChild(progressBg,3)
				local hpProgress=CCSprite:createWithSpriteFrameName("BlackBg.png")
				hpProgress:setOpacity(0)
				hpProgress:setAnchorPoint(ccp(0.5,0))
				hpProgress:setPosition(ccp(lineX[posMap[cityVo.lineID]] - 80,1600 - 217 - cityVo.pointID*disY - 44))
				local percentage=cityVo.hp/cityVo.maxHp
				local length=percentage*88
				local gridNum=math.floor(length/10)
				local gridName
				if(percentage>0.8)then
					gridName="platWar_bloodGreen.png"
				elseif(percentage>0.3)then
					gridName="platWar_bloodYellow.png"
				else
					gridName="platWar_bloodRed.png"
				end
				for i=1,gridNum do
					local gridSprite=CCSprite:createWithSpriteFrameName(gridName)
					gridSprite:setScaleX(15/gridSprite:getContentSize().width)
					gridSprite:setScaleY(8/gridSprite:getContentSize().height)
					gridSprite:setAnchorPoint(ccp(0.5,0))
					gridSprite:setPosition(ccp(hpProgress:getContentSize().width/2,10*(i - 1)))
					hpProgress:addChild(gridSprite)
				end
				if(10*gridNum<length)then
					local gridSprite=CCSprite:createWithSpriteFrameName(gridName)
					gridSprite:setScaleX(15/gridSprite:getContentSize().width)
					gridSprite:setScaleY((length - 10*gridNum)/gridSprite:getContentSize().height)
					gridSprite:setAnchorPoint(ccp(0.5,0))
					gridSprite:setPosition(ccp(hpProgress:getContentSize().width/2,10*gridNum))
					hpProgress:addChild(gridSprite)
				end
				self.background:addChild(hpProgress,4)
				self.hpList[road][point]=hpProgress
				self.hpBgList[road][point]=progressBg
				if(cityVo.hp<=0)then
					hpProgress:setVisible(false)
					progressBg:setVisible(false)
				end
			end
			if(cityVo.side and cityVo.side>0)then
				local flag
				if(cityVo.side==1)then
					flag=CCSprite:createWithSpriteFrameName("platWarFlag1.png")
				else
					flag=CCSprite:createWithSpriteFrameName("platWarFlag2.png")
				end
				flag:setPosition(ccp(lineX[posMap[cityVo.lineID]] + 30,1600 - 217 - cityVo.pointID*disY + 50))
				self.background:addChild(flag,4)
				self.cityFlagList[road][point]=flag
			end
		end
	end
	for k,v in pairs(self.lineList) do
		local progressBg=LuaCCSprite:createWithSpriteFrameName("platWarProgressBg.png",onClickLine)
		progressBg:setTag(k)
		progressBg:setTouchPriority(-(self.layerNum-1)*20-4)
		progressBg:setIsSallow(false)
		progressBg:setAnchorPoint(ccp(0,0.5))
		progressBg:setPosition(ccp(lineX[posMap[k]],1600 - 217))
		progressBg:setScaleY(20/progressBg:getContentSize().height)
		progressBg:setScaleX(1200/progressBg:getContentSize().width)
		progressBg:setRotation(90)
		self.background:addChild(progressBg)
		local progress1=CCSprite:createWithSpriteFrameName("lineWhite.png")
		progress1:setColor(G_ColorRed)
		progress1:setScaleY(17/progress1:getContentSize().height)
		progress1:setScaleX(v[1]*disY/progress1:getContentSize().width)
		progress1:setAnchorPoint(ccp(0,0.5))
		progress1:setRotation(90)
		progress1:setPosition(ccp(lineX[posMap[k]],1600 - 217))
		self.background:addChild(progress1,1)
		local progress2=CCSprite:createWithSpriteFrameName("lineWhite.png")
		progress2:setColor(ccc3(46, 46, 254))
		progress2:setScaleY(17/progress2:getContentSize().height)
		progress2:setScaleX((platWarCfg.mapAttr.lineLength - v[2] + 1)*disY/progress2:getContentSize().width)
		progress2:setAnchorPoint(ccp(0,0.5))
		progress2:setRotation(-90)
		progress2:setPosition(ccp(lineX[posMap[k]],1600 - 217 - 1200))
		self.background:addChild(progress2,1)
		if(v[2] - v[1]<=1 and platWarVoApi:getWinnerID()==nil)then
			local fire=CCSprite:createWithSpriteFrameName("platWarFire1.png")
			fire:setPosition(ccp(lineX[posMap[k]],1600 - 217 - v[1]*disY))
			fire:setScale(2)
			self.background:addChild(fire,3)
			self.lineProgressList[k]={progress1,progress2,fire}

			local fireArr=CCArray:create()
			for i=1,14 do
				local nameStr="platWarFire"..i..".png"
				local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				fireArr:addObject(frame)
			end
			local animation=CCAnimation:createWithSpriteFrames(fireArr)
			animation:setDelayPerUnit(0.03)
			local animate=CCAnimate:create(animation)
			local repeatForever=CCRepeatForever:create(animate)
			fire:runAction(repeatForever)
		else
			self.lineProgressList[k]={progress1,progress2}
		end
		if(platWarVoApi:getWinnerID()==nil)then
			local arrow1 = CCSprite:createWithSpriteFrameName("platWarMoveArrow.png")
			arrow1:setOpacity(0)
			arrow1:setPosition(ccp(lineX[posMap[k]],1600 - 217))
			self.background:addChild(arrow1,2)
			local actionArr=CCArray:create()
			local fadeOut=CCFadeTo:create(0.5,255)
			local moveTo=CCMoveTo:create(0.5,ccp(lineX[posMap[k]],1600 - 217 - 120))
			local carray=CCArray:create()
			carray:addObject(fadeOut)
			carray:addObject(moveTo)
			local apear=CCSpawn:create(carray)
			actionArr:addObject(apear)
			local moveTo=CCMoveTo:create(1.5,ccp(lineX[posMap[k]],1600 - 217 - 480))
			actionArr:addObject(moveTo)
			local fadeIn=CCFadeTo:create(0.5,0)
			local moveTo=CCMoveTo:create(0.5,ccp(lineX[posMap[k]],1600 - 217 - 600))
			local carray=CCArray:create()
			carray:addObject(fadeIn)
			carray:addObject(moveTo)
			local disapear=CCSpawn:create(carray)
			actionArr:addObject(disapear)
			local delay=CCDelayTime:create(2.5)
			actionArr:addObject(delay)
			local function onAllEnd()
				arrow1:setPosition(ccp(lineX[posMap[k]],1600 - 217))
			end
			local callFunc=CCCallFunc:create(onAllEnd)
			actionArr:addObject(callFunc)
			local seq=CCSequence:create(actionArr)
			arrow1:runAction(CCRepeatForever:create(seq))
	
			local arrow2 = CCSprite:createWithSpriteFrameName("platWarMoveArrow.png")
			arrow2:setOpacity(0)
			arrow2:setFlipY(true)
			arrow2:setPosition(ccp(lineX[posMap[k]],1600 - 217 - 1200))
			self.background:addChild(arrow2,2)
			local actionArr=CCArray:create()
			local fadeOut=CCFadeTo:create(0.5,255)
			local moveTo=CCMoveTo:create(0.5,ccp(lineX[posMap[k]],1600 - 217 - 1200 + 120))
			local carray=CCArray:create()
			carray:addObject(fadeOut)
			carray:addObject(moveTo)
			local apear=CCSpawn:create(carray)
			actionArr:addObject(apear)
			local moveTo=CCMoveTo:create(1.5,ccp(lineX[posMap[k]],1600 - 217 - 1200 + 480))
			actionArr:addObject(moveTo)
			local fadeIn=CCFadeTo:create(0.5,0)
			local moveTo=CCMoveTo:create(0.5,ccp(lineX[posMap[k]],1600 - 217 - 1200 + 600))
			local carray=CCArray:create()
			carray:addObject(fadeIn)
			carray:addObject(moveTo)
			local disapear=CCSpawn:create(carray)
			actionArr:addObject(disapear)
			local delay=CCDelayTime:create(2.5)
			actionArr:addObject(delay)
			local function onAllEnd()
				arrow2:setPosition(ccp(lineX[posMap[k]],1600 - 217 - 1200))
			end
			local callFunc=CCCallFunc:create(onAllEnd)
			actionArr:addObject(callFunc)
			local seq=CCSequence:create(actionArr)
			arrow2:runAction(CCRepeatForever:create(seq))
		end
	end
end

function platWarMapScene:initPlayer()
	if(self.troopIconList)then
		for k,v in pairs(self.troopIconList) do
			if(v and tolua.cast(v,"CCSprite"))then
				v:removeFromParentAndCleanup(true)
			end
		end
		self.troopIconList=nil
	end
	local selfPlayer=platWarVoApi:getPlayer()
	if(selfPlayer and selfPlayer.rank<=platWarCfg.joinLimit)then
		self.troopIconList={}
		local lineX={101,307,512,715,920}
		local disY=1200/platWarCfg.mapAttr.lineLength
		local posMap={}
		for k,v in pairs(platWarCfg.mapAttr.linePosClient) do
			posMap[v]=k
		end
		local troopInfo=platWarVoApi:getTroopInfo()
		for troopIndex,troopData in pairs(troopInfo) do
			local road=troopData[1]
			local process=troopData[2]
			if(road and process)then
				local tankTb=tankVoApi:getTanksTbByType(20 + troopIndex)
				local length=#tankTb
				local tankID
				for i=1,length do
					if(tankTb[i] and tankTb[i][1] and tankTb[i][2]>0)then
						tankID=tankTb[i][1]
						break
					end
				end
				if(tankID)then
					local tankPic=CCSprite:createWithSpriteFrameName(tankCfg[tankID].icon)
					tankPic:setScale(60/tankPic:getContentSize().width)
					self.troopIconList[troopIndex]=CCSprite:createWithSpriteFrameName("ProductTankDialog.png")
					tankPic:setPosition(ccp(self.troopIconList[troopIndex]:getContentSize().width/2,self.troopIconList[troopIndex]:getContentSize().height/2+6))
					self.troopIconList[troopIndex]:setAnchorPoint(ccp(0.5,0))
					self.troopIconList[troopIndex]:addChild(tankPic)
					self.troopIconList[troopIndex]:setPosition(ccp(lineX[posMap[road]],1600 - 217 - process*disY))
					self.background:addChild(self.troopIconList[troopIndex],7)
				end
			end
		end
	end
end

function platWarMapScene:setShowWhenEndBattle()
    if self and self.bgLayer~=nil then
        if self.beforeHideIsShow==true then
            self.isShow=true
	        self.beforeHideIsShow=false
	        self.touchEnable=true
	        self.bgLayer:setPosition(ccp(0,0))
        end
    elseif base.allShowedCommonDialog==0 then
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setShow()
            elseif sceneController.curIndex==1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex==2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
end
function platWarMapScene:setHide()
    if self and self.bgLayer~=nil then
        self.isShow=false
        self.beforeHideIsShow=true
        self.touchEnable=false
        self.bgLayer:setPosition(ccp(0,10000))
    end
end

function platWarMapScene:initNotice()
	local chatBg,chatMenu=self:initChat(self.bgLayer,self.layerNum,true,1,nil,self.functionBarHeight,nil,0)
	chatBg:setTouchPriority(-(self.layerNum-1)*20-8)
	chatBg:setIsSallow(true)
	chatMenu:setTouchPriority(-(self.layerNum-1)*20-8)
	self.chatBg=chatBg
	self:setLastNotice(1)
end
function platWarMapScene:initChat(parent,layerNum,isShow,showType,newType,posY,bgWidth)
	local function chatHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        if newGuidMgr:isNewGuiding()==true then
            do return end
        end
        platWarVoApi:showNoticeDialog(self.layerNum+1,self)
    end
    
    local m_chatBtn=GetButtonItem("mainBtnChat.png","mainBtnChat_Down.png","mainBtnChat_Down.png",chatHandler,nil,nil,nil)
    -- local m_chatBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgSmall.png",CCRect(10,10,5,5),chatHandler)
    local m_chatBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBg.png",CCRect(10,10,5,5),chatHandler)
    if posY==nil then
        posY=0
    end
    local scaleX=1
    if bgWidth then
        scaleX=bgWidth/(m_chatBtn:getContentSize().width/2+m_chatBg:getContentSize().width+5)
    end
    m_chatBtn:setAnchorPoint(ccp(1,0))
    local chatSpriteMenu=CCMenu:createWithItem(m_chatBtn)
    chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth,posY))
    chatSpriteMenu:setTouchPriority(-(layerNum-1)*20-6)
    parent:addChild(chatSpriteMenu,11)
    m_chatBtn:setScaleX(scaleX)
    
    m_chatBg:setAnchorPoint(ccp(0,0))
    m_chatBg:setIsSallow(false)
    m_chatBg:setTouchPriority(-(layerNum-1)*20-6)
    m_chatBg:setPosition(ccp(0,posY+5))
    parent:addChild(m_chatBg,11)
    m_chatBg:setScaleX(scaleX)
    if bgWidth then
        local wSpace=(G_VisibleSizeWidth-bgWidth)/2
        chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth-wSpace,posY))
        m_chatBg:setPosition(ccp(wSpace,posY+5))
    end
    
    return m_chatBg,chatSpriteMenu
end
function platWarMapScene:setLastNotice(showType)
    -- if isShow==true or platWarVoApi:getHasNewData(newType)==true then
    if self.chatBg then
    	local m_chatBg=self.chatBg
        local noticeVo=platWarVoApi:getLastNotice(showType)
        if noticeVo then
            local sizeSp=36
            if noticeVo.platform and m_chatBg then
                local m_labelLastType=m_chatBg:getChildByTag(11)
                if m_labelLastType then
                    m_labelLastType:removeFromParentAndCleanup(true)
                    m_labelLastType=nil
                end
                m_labelLastType = platWarVoApi:getPlatIcon(noticeVo.platform)
                if m_labelLastType then
	                typeScale=sizeSp/m_labelLastType:getContentSize().width
	                m_labelLastType:setAnchorPoint(ccp(0.5,0.5))
	                m_labelLastType:setPosition(ccp(5+sizeSp/2,m_chatBg:getContentSize().height/2))
	                m_chatBg:addChild(m_labelLastType,2)
	                m_labelLastType:setScale(typeScale)
	                m_labelLastType:setTag(11)
	            end
            end
            
            local nameStr=noticeVo.senderName
            local m_labelLastName=m_chatBg:getChildByTag(12)
            if m_labelLastName then
                m_labelLastName=tolua.cast(m_labelLastName,"CCLabelTTF")
            end
            -- if nameStr~=nil and nameStr~="" and chatVo.type<=3 and chatVo.contentType~=3 then
            if nameStr~=nil and nameStr~="" then
                nameStr=nameStr..":"
                if m_labelLastName then
                    m_labelLastName:setString(nameStr)
                    if color then
                       m_labelLastName:setColor(color)
                    end
                else
                    m_labelLastName=GetTTFLabel(nameStr,30)
                    m_labelLastName:setAnchorPoint(ccp(0,0.5))
                    m_labelLastName:setPosition(ccp(5+sizeSp,m_chatBg:getContentSize().height/2))
                    m_chatBg:addChild(m_labelLastName,2)
                    if color then
                       m_labelLastName:setColor(color)
                    end
                    m_labelLastName:setTag(12)
                end
            end
            
            local message=noticeVo.content
            if message==nil then
                message=""
            end
            local msgFont=nil
            --处理ios表情在安卓不显示问题
            if G_isIOS()==false then
                if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                    local tmpTb={}
                    tmpTb["action"]="EmojiConv"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["str"]=tostring(message)
                    local cjson=G_Json.encode(tmpTb)
                    message=G_accessCPlusFunction(cjson)
                    msgFont=G_EmojiFontSrc
                end
            end

            local xPos=sizeSp+5
            -- if m_labelLastName and chatVo.type<=3 then
            --     if chatVo.contentType==3 then
            --         --m_labelLastName:setString(nameStr)
            --         m_labelLastName:setString("")
            --     else
                    xPos=xPos+m_labelLastName:getContentSize().width
            --     end
            -- end
            local m_labelLastMsg=m_chatBg:getChildByTag(13)
            if m_labelLastMsg then
                m_labelLastMsg=tolua.cast(m_labelLastMsg,"CCLabelTTF")
            end
            if m_labelLastMsg then
                m_labelLastMsg:setString(message)
                if msgFont then
                    m_labelLastMsg:setFontName(msgFont)
                end
            else
                m_labelLastMsg=GetTTFLabelWrap(message,30,CCSizeMake(m_chatBg:getContentSize().width-100,35),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,msgFont)
                m_labelLastMsg:setAnchorPoint(ccp(0,0.5))
                m_labelLastMsg:setPosition(ccp(xPos,m_chatBg:getContentSize().height/2))
                m_chatBg:addChild(m_labelLastMsg,2)
                m_labelLastMsg:setTag(13)
            end

            m_labelLastMsg:setDimensions(CCSize(m_chatBg:getContentSize().width-xPos-50,40))
            -- if noticeVo.contentType and noticeVo.contentType==2 then --战报
            --     m_labelLastMsg:setColor(G_ColorYellow)
            -- else
            --     m_labelLastMsg:setColor(color)
            -- end
            m_labelLastMsg:setPosition(ccp(xPos,m_chatBg:getContentSize().height/2))
        end
        -- if newType==11 or newType==12 or newType==13 or newType==15 then
        --     chatVoApi:setNoNewData(newType)
        -- end
    end
end
function platWarMapScene:showLineTroopDialog(lineID)
	local status=platWarVoApi:checkStatus()
	if(status<20 or status>=30)then
		do return end
	end
	local function onHide()
		if(self.lineTroopDialog)then
			self.lineTroopDialog:removeFromParentAndCleanup(true)
			self.lineTroopDialog=nil
		end
	end
	if(self.lineTroopDialog)then
		onHide()
	end
	local layerNum=self.layerNum + 1
	self.lineTroopDialog=CCLayer:create()
	self.bgLayer:addChild(self.lineTroopDialog,2)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.lineTroopDialog:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	dialogBg:setContentSize(CCSizeMake(570,570))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.lineTroopDialog:addChild(dialogBg,1)

	local landType=platWarCfg.mapAttr.lineLandtype[lineID]
	local icon=GetBgIcon("world_ground_"..landType..".png")
	icon:setScale(100/icon:getContentSize().width)
	icon:setPosition(ccp(100,470))
	dialogBg:addChild(icon)
	local lineName=GetTTFLabel(getlocal("plat_war_road_"..lineID),25)
	lineName:setPosition(ccp(350,500))
	dialogBg:addChild(lineName)
	local titleLb=GetTTFLabel(getlocal("serverwar_scheduleTable"),25)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(350,440))
	dialogBg:addChild(titleLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(570/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(285,410))
	dialogBg:addChild(lineSp)

	local titleLb1=GetTTFLabel(getlocal("red"),25)
	titleLb1:setColor(G_ColorRed)
	titleLb1:setPosition(ccp(162.5,380))
	dialogBg:addChild(titleLb1)
	local titleLb2=GetTTFLabel(getlocal("blue"),25)
	titleLb2:setColor(ccc3(46, 46, 254))
	titleLb2:setPosition(ccp(407.5,380))
	dialogBg:addChild(titleLb2)

	local function nilFunc( ... )
	end
	local listBg1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	listBg1:setTouchPriority(-(layerNum-1)*20-2)
	listBg1:setContentSize(CCSizeMake(240,280))
	listBg1:setPosition(ccp(162.5,220))
	dialogBg:addChild(listBg1)
	local listBg2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	listBg2:setTouchPriority(-(layerNum-1)*20-2)
	listBg2:setContentSize(CCSizeMake(240,280))
	listBg2:setPosition(ccp(407.5,220))
	dialogBg:addChild(listBg2)
	local troopDetailList=platWarVoApi:getTroopDetailList()
	local function onViewTank(tag,object)
		self:showLeftTroopDialog(lineID,tag,layerNum + 1)
	end
	local function eventHandler(handler,fn,idx,cel,side)
		if fn=="numberOfCellsInTableView" then
			if(troopDetailList and troopDetailList[lineID] and troopDetailList[lineID][side])then
				return math.max(#(troopDetailList[lineID][side]) + 2,3)
			else
				return 3
			end
		elseif fn=="tableCellSizeForIndex" then
			if(idx==0 or idx==2)then
				return CCSizeMake(240,50)
			else
				return CCSizeMake(240,30)
			end
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local lb
			if(idx==0)then
				lb=GetTTFLabel(getlocal("plat_war_troop1"),25)
				lb:setColor(G_ColorGreen)
				lb:setAnchorPoint(ccp(0,0.5))
				lb:setPosition(10,20)
				local viewItem=GetButtonItem("platWarView.png","platWarView_down.png","platWarView_down.png",onViewTank,side)
				local viewBtn=CCMenu:createWithItem(viewItem)
				viewBtn:setTouchPriority(-(layerNum-1)*20-2)
				viewBtn:setPosition(ccp(40 + lb:getContentSize().width,20))
				cell:addChild(viewBtn)
			elseif(idx==2)then
				lb=GetTTFLabel(getlocal("plat_war_troop2"),25)
				lb:setColor(G_ColorGreen)
				lb:setAnchorPoint(ccp(0,0.5))
				lb:setPosition(10,20)
			else
				local index
				if(idx>1)then
					index=idx - 1
				else
					index=idx
				end
				local data=troopDetailList[lineID][side][index]
				if(data)then
					if(index==1)then
						if(type(data)~="table")then
							data={data,{},0}
						end
						if(tostring(data[1]) and string.len(tostring(data[1]))==1)then
							if(data[1]==nil or tonumber(data[1])==0)then
								data[1]=1
							end
							lb=GetTTFLabel(getlocal("plat_war_donate_troops_"..(data[1])),25)
						else
							lb=GetTTFLabel(data[1],25)
						end
					else
						if(tostring(data) and string.len(tostring(data))==1)then
							if(tonumber(data)==0)then
								data=1
							end
							lb=GetTTFLabel(getlocal("plat_war_donate_troops_"..(data)),25)
						else
							lb=GetTTFLabel(data,25)
						end
					end
				else
					lb=GetTTFLabel("",25)
				end
				lb:setPosition(120,15)
			end
			cell:addChild(lb)
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		elseif fn=="ccScrollEnable" then
		end
	end
	local function callback1(handler,fn,idx,cel)
		return eventHandler(handler,fn,idx,cel,1)
	end
	local hd=LuaEventHandler:createHandler(callback1)
	local tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(240,280),nil)
	tv1:setTableViewTouchPriority(-(layerNum-1)*20-3)
	tv1:setPosition(ccp(0,0))
	tv1:setMaxDisToBottomOrTop(40)
	listBg1:addChild(tv1)
	local function callback2(handler,fn,idx,cel)
		return eventHandler(handler,fn,idx,cel,2)
	end
	local hd=LuaEventHandler:createHandler(callback2)
	local tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(240,280),nil)
	tv2:setTableViewTouchPriority(-(layerNum-1)*20-3)
	tv2:setPosition(ccp(0,0))
	tv2:setMaxDisToBottomOrTop(40)
	listBg2:addChild(tv2)
end

function platWarMapScene:showLeftTroopDialog(lineID,side,layerNum)
	local status=platWarVoApi:checkStatus()
	if(status<20 or status>=30)then
		do return end
	end
	local function onHide()
		if(self.leftTroopDialog)then
			self.leftTroopDialog:removeFromParentAndCleanup(true)
			self.leftTroopDialog=nil
		end
	end
	if(self.leftTroopDialog)then
		onHide()
	end
	self.leftTroopDialog=CCLayer:create()
	self.bgLayer:addChild(self.leftTroopDialog,2)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ( ... ) end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.leftTroopDialog:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),onHide)
	dialogBg:setContentSize(CCSizeMake(570,570))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.leftTroopDialog:addChild(dialogBg,1)

	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",onHide)
	closeBtnItem:setPosition(ccp(0,0))
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	local closeBtn = CCMenu:createWithItem(closeBtnItem)
	closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	closeBtn:setPosition(ccp(570 - closeBtnItem:getContentSize().width,570 - closeBtnItem:getContentSize().height))
	dialogBg:addChild(closeBtn,2)

	local titleLb=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),30)
	titleLb:setPosition(285,520)
	dialogBg:addChild(titleLb)

	local troopDetailList=platWarVoApi:getTroopDetailList()
	for i=1,6 do
		local posX,posY
		if(i%2==0)then
			posX=150
		else
			posX=420
		end
		posY=400 - math.floor((i - 1)/2)*140
		local tankIcon
		if(troopDetailList[lineID] and troopDetailList[lineID][side] and troopDetailList[lineID][side][1] and type(troopDetailList[lineID][side][1])=="table")then
			if(troopDetailList[lineID][side][1][2] and troopDetailList[lineID][side][1][2][i])then
				local tid=troopDetailList[lineID][side][1][2][i][1]
				if(tid)then
					tid=tonumber(string.sub(tid,2))
					tankIcon=CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
				end
			end
		end
		local hasTroop=true
		if(tankIcon==nil)then
			tankIcon=CCSprite:createWithSpriteFrameName("BgEmptyTank.png")
			hasTroop=false
		end
		tankIcon:setScale(100/tankIcon:getContentSize().width)
		tankIcon:setPosition(ccp(posX,posY))
		dialogBg:addChild(tankIcon)
		if(hasTroop)then
			local tid=troopDetailList[lineID][side][1][2][i][1]
			tid=tonumber(string.sub(tid,2))
			local lb=GetTTFLabel(getlocal(tankCfg[tid].name).."("..troopDetailList[lineID][side][1][2][i][2]..")",22)
			lb:setPosition(ccp(posX,posY - 70))
			dialogBg:addChild(lb)
		end
	end
end

function platWarMapScene:tick()
	if(base.serverTime>=self.refreshTime)then
		local function callback()
			self.refreshTime=platWarVoApi:getBattleExpireTime()
			local status=platWarVoApi:checkStatus()
			if(status<=0)then
				self.curRoundLb:setString(getlocal("dailyAnswer_tab1_question_title1"))
				self.totalFire:setVisible(false)
			elseif(status<20)then
				self.curRoundLb:setString(getlocal("world_war_matchStatus1"))
				self.totalFire:setVisible(false)
			elseif(status<30)then
				self.curRoundLb:setString(getlocal("plat_war_cur_round",{platWarVoApi:getCurRound()}))
				self.totalFire:setVisible(true)
			else
				self.curRoundLb:setString(getlocal("serverwarteam_all_end"))
				self.totalFire:setVisible(false)
			end
			local lineX={101,307,512,715,920}
			local disY=1200/platWarCfg.mapAttr.lineLength
			local posMap={}
			for k,v in pairs(platWarCfg.mapAttr.linePosClient) do
				posMap[v]=k
			end
			self.cityList=platWarVoApi:getCityList()
			self.lineList=platWarVoApi:getLineList()
			if(self.cityFlagList)then
				for k,road in pairs(self.cityFlagList) do
					for kk,flag in pairs(road) do
						flag:removeFromParentAndCleanup(true)print(k,v)
					end
				end
			end
			self.cityFlagList={}
			for road,tb in pairs(self.cityList) do
				self.cityFlagList[road]={}
				for point,cityVo in pairs(tb) do
					local hpProgress=tolua.cast(self.hpList[road][point],"CCSprite")
					if(hpProgress)then
						hpProgress:removeAllChildrenWithCleanup(true)
						local percentage=cityVo.hp/cityVo.maxHp
						local length=percentage*88
						local gridNum=math.floor(length/10)
						local gridName
						if(percentage>0.8)then
							gridName="platWar_bloodGreen.png"
						elseif(percentage>0.3)then
							gridName="platWar_bloodYellow.png"
						else
							gridName="platWar_bloodRed.png"
						end
						for i=1,gridNum do
							local gridSprite=CCSprite:createWithSpriteFrameName(gridName)
							gridSprite:setScaleX(15/gridSprite:getContentSize().width)
							gridSprite:setScaleY(8/gridSprite:getContentSize().height)
							gridSprite:setAnchorPoint(ccp(0.5,0))
							gridSprite:setPosition(ccp(hpProgress:getContentSize().width/2,10*(i - 1)))
							hpProgress:addChild(gridSprite)
						end
						if(10*gridNum<length)then
							local gridSprite=CCSprite:createWithSpriteFrameName(gridName)
							gridSprite:setScaleX(15/gridSprite:getContentSize().width)
							gridSprite:setScaleY((length - 10*gridNum)/gridSprite:getContentSize().height)
							gridSprite:setAnchorPoint(ccp(0.5,0))
							gridSprite:setPosition(ccp(hpProgress:getContentSize().width/2,10*gridNum))
							hpProgress:addChild(gridSprite)
						end
						if(cityVo.hp<=0)then
							local progressBg=tolua.cast(self.hpBgList[road][point],"CCSprite")
							if(progressBg)then
								progressBg:setVisible(false)
							end
						end
					end
					if(cityVo.side and cityVo.side>0)then
						local flag
						if(cityVo.side==1)then
							flag=CCSprite:createWithSpriteFrameName("platWarFlag1.png")
						else
							flag=CCSprite:createWithSpriteFrameName("platWarFlag2.png")
						end
						flag:setPosition(ccp(lineX[posMap[cityVo.lineID]] + 30,1600 - 217 - cityVo.pointID*disY + 50))
						self.background:addChild(flag,4)
						self.cityFlagList[road][point]=flag
					end
				end
			end
			for k,v in pairs(self.lineList) do
				local progress1=self.lineProgressList[k][1]
				progress1:setScaleX(v[1]*disY/progress1:getContentSize().width)
				local progress2=self.lineProgressList[k][2]
				if(v[2] - v[1]<=1 and platWarVoApi:getWinnerID()==nil)then
					local fire=tolua.cast(self.lineProgressList[k][3],"CCSprite")
					if(fire==nil)then
						fire=CCSprite:createWithSpriteFrameName("platWarFire1.png")
						fire:setPosition(ccp(lineX[posMap[k]],1600 - 217 - v[1]*disY))
						fire:setScale(2)
						self.background:addChild(fire,3)
						local fireArr=CCArray:create()
						for i=1,14 do
							local nameStr="platWarFire"..i..".png"
							local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
							fireArr:addObject(frame)
						end
						local animation=CCAnimation:createWithSpriteFrames(fireArr)
						animation:setDelayPerUnit(0.03)
						local animate=CCAnimate:create(animation)
						local repeatForever=CCRepeatForever:create(animate)
						fire:runAction(repeatForever)
						self.lineProgressList[k][3]=fire
					end
					fire:setPosition(ccp(lineX[posMap[k]],1600 - 217 - v[1]*disY))
				else
					local fire=tolua.cast(self.lineProgressList[k][3],"CCSprite")
					if(fire)then
						fire:removeFromParentAndCleanup(true)
						self.lineProgressList[k][3]=nil
					end
				end
			end
			local num1,num2,num=0,0,0
			for road,tb in pairs(self.cityList) do
				for point,cityVo in pairs(tb) do
					if(cityVo.side==1)then
						num1=num1 + 1
					elseif(cityVo.side==2)then
						num2=num2 + 1
					end
				end
			end
			num=num1 + num2
			if(num==0)then
				self.progress1:setPercentage(50)
				self.totalFire:setPosition(G_VisibleSizeWidth/2,self.titleHeight/2 - 40)
			else
				self.progress1:setPercentage(num1/num*100)
				self.totalFire:setPosition(G_VisibleSizeWidth/2 - 420/2 + 420*num1/num,self.titleHeight/2 - 40)
			end
		end
		platWarVoApi:refreshBattle(callback)
	end
	local lastNoticeTime=platWarVoApi:getLastNoticeTime(1)
	if base.serverTime-lastNoticeTime>=platWarCfg.noticeInterval then
		platWarVoApi:setLastNoticeTime(base.serverTime,1)
		local isSuccess=platWarVoApi:initNoticeList(0)
        if isSuccess==true then
	        self:setLastNotice(1)
	    end
	end
	if platWarVoApi:checkStatus()<30 then
		local fleetIndexTb=tankVoApi:getPlatWarFleetIndexTb()
	    local isSetAll=tankVoApi:platWarIsAllSetFleet()
	    if isSetAll==true and #fleetIndexTb>=3 then
	        self.troopsTipSp:setVisible(false)
	    else
	        self.troopsTipSp:setVisible(true)
	    end
	end
end

function platWarMapScene:close()
	if(self.lineTroopDialog)then
		self.lineTroopDialog:removeFromParentAndCleanup(true)
		self.lineTroopDialog=nil
	end
	if(self.leftTroopDialog)then
		self.leftTroopDialog:removeFromParentAndCleanup(true)
		self.leftTroopDialog=nil
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
	self.eventListener=nil
	base:removeFromNeedRefresh(self)
	self.layerNum=nil
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.firstOldPos=nil
	self.secondOldPos=nil
	self.touchArr=nil
	self.isShow=false
	self.beforeHideIsShow=false
	self.chatBg=nil
	self.cityList=nil
	self.hpList=nil
	self.hpBgList=nil
	self.troopIconList=nil
	self.cityFlagList=nil
	self.functionBar=nil
	self.lineTroopDialog=nil
	self.leftTroopDialog=nil
	self.troopsTipSp=nil
	self.refreshTime=0
	base.allShowedCommonDialog=math.max(base.allShowedCommonDialog-1,0)
	for k,v in pairs(base.commonDialogOpened_WeakTb) do
		if v==self then
			table.remove(base.commonDialogOpened_WeakTb,k)
			break
		end
	end
end