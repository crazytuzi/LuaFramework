--群雄争霸战场场景
serverWarLocalMapScene=
{
	bgLayer=nil,
	clayer=nil,
	background=nil,
	minScale=1,
	maxScale=2,
	isShow=false,
	chatBg=nil,
	mapIndex=nil,
	mapCfg=nil,
	cityList=nil,
	cityStatusList=nil,
	roadList=nil,				--roadType==2的道路列表，到时间才能显示
	troops=nil,					--自己的三支部队数据
	troopIcons=nil,				--三支部队的icon
	troopTip=nil,				--右边的三支部队的图标
	selectedTroopID=nil,		--当前选中了哪支部队
	troopAlerts=nil,			--部队上浮动的tip, 死亡消息
	taskTip=nil,				--突袭任务
	taskExpireTime=0,			--突袭任务过期时间
	taskCompleteTime=nil,		--突袭任务完成时间
	selfTroopsTags=nil
}

function serverWarLocalMapScene:show(layerNum)
	self.layerNum=layerNum
	self.mapCfg=serverWarLocalFightVoApi:getMapCfg()
	spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
	spriteController:addPlist("public/serverWarLocal/serverWarLocalCity.plist")
	spriteController:addTexture("public/serverWarLocal/serverWarLocal2.png")
	spriteController:addTexture("public/serverWarLocal/serverWarLocalCity.png")
	spriteController:addTexture("public/serverWarLocal/serverWarLocalMapBg.jpg")
	spriteController:addPlist("public/serverWarLocal/swlocal_waiting.plist")
	spriteController:addTexture("public/serverWarLocal/swlocal_waiting.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
	self.bgLayer=CCLayer:create()

	self.groupId=serverWarLocalVoApi:getGroupID()
	self.touchArr={}
	self:initBackground()
	self:initFunctionBar()
	self:initMap()
	self:initChat()
	self:refreshTroops()
	self:refreshTask()
	self:checkShowMask()
	self.isShow=true
	self.showTime=base.serverTime
	sceneGame:addChild(self.bgLayer,self.layerNum)
	base:addNeedRefresh(self)
	local function eventListener(event,data)
		self:dealEvent(event,data)
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("serverWarLocal.battle",eventListener)
end

function serverWarLocalMapScene:initBackground()
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(touchDialogBg)

	self:initTitle()
	self.mapSize=CCSizeMake(2048,2048)
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
	self.background:setContentSize(self.mapSize)
	self.background:setPosition(ccp(0,0))
	self.clayer:addChild(self.background)

	local mapTexture=spriteController:getTexture("public/serverWarLocal/serverWarLocalMapBg.jpg")
	local mapBatchNode=CCSpriteBatchNode:createWithTexture(mapTexture,4)
	for i=1,4 do
		local mapBg=CCSprite:createWithTexture(mapTexture)
		mapBg:setAnchorPoint(ccp(0,0))
		mapBg:setPosition(((i + 1)%2)*1024,math.floor((i - 1)/2)*1024)
		mapBatchNode:addChild(mapBg)
	end
	self.background:addChild(mapBatchNode)
end

function serverWarLocalMapScene:initTitle()
	local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),function ()end)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-8)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(ccp(0,G_VisibleSizeHeight))
	self.bgLayer:addChild(titleBg,3)

	self.titleHeight=titleBg:getContentSize().height

	local function close()
		PlayEffect(audioCfg.mouseClick)
		self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil)
	closeBtnItem:setPosition(0, 0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))

	local closeBtn = CCMenu:createWithItem(closeBtnItem)
	closeBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	closeBtn:setPosition(ccp(G_VisibleSizeWidth-closeBtnItem:getContentSize().width,G_VisibleSizeHeight-closeBtnItem:getContentSize().height))
	self.bgLayer:addChild(closeBtn,5)

	local endTimeDesc=GetTTFLabel(getlocal("local_war_endTime"),22)
	endTimeDesc:setPosition(ccp(70,G_VisibleSizeHeight - 30))
	self.bgLayer:addChild(endTimeDesc,4)
	local nextBattleTimeDesc=GetTTFLabel(getlocal("local_war_battleTime"),22)
	nextBattleTimeDesc:setPosition(ccp(70,G_VisibleSizeHeight - 60))
	self.bgLayer:addChild(nextBattleTimeDesc,4)
	self.countDownProgress=CCProgressTimer:create(CCSprite:createWithSpriteFrameName("AllXpBar.png"))
	self.countDownProgress:setScaleX(360/self.countDownProgress:getContentSize().width)
	self.countDownProgress:setScaleY(1.1)
	self.countDownProgress:setType(kCCProgressTimerTypeBar)
	self.countDownProgress:setMidpoint(ccp(0,0))
	self.countDownProgress:setBarChangeRate(ccp(1,0))
	self.countDownProgress:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 30))
	self.bgLayer:addChild(self.countDownProgress,4)
	self.countDownLb=GetTTFLabel("",22)
	self.countDownLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 30))
	self.bgLayer:addChild(self.countDownLb,4)

	self.battleCDProgress=CCProgressTimer:create(CCSprite:create("public/tankLoadingBar.png"))
	self.battleCDProgress:setScaleX(360/self.battleCDProgress:getContentSize().width)
	self.battleCDProgress:setType(kCCProgressTimerTypeBar)
	self.battleCDProgress:setMidpoint(ccp(0,0))
	self.battleCDProgress:setBarChangeRate(ccp(1,0))
	self.battleCDProgress:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 60))
	self.bgLayer:addChild(self.battleCDProgress,4)
	self.battleCDLb=GetTTFLabel("",22)
	self.battleCDLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 60))
	self.bgLayer:addChild(self.battleCDLb,4)

	local function showInfo()
		if(base.serverTime<serverWarLocalFightVoApi:getStartTime())then
			do return end
		end
		PlayEffect(audioCfg.mouseClick)

       	local tabStr={getlocal("local_war_hpTip")}
        local tabColor={G_ColorYellowPro}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr,tabColor)

		local hpTip=tolua.cast(self.bgLayer:getChildByTag(317),"CCSprite")
		if(hpTip)then
			hpTip:removeFromParentAndCleanup(true)
		end
	end
	local hpTip = LuaCCSprite:createWithSpriteFrameName("ProductTankDialog.png",showInfo)
	hpTip:setScale(0.7)
	hpTip:setTag(317)
	hpTip:setRotation(135)
	hpTip:setPosition(ccp(G_VisibleSizeWidth - 140,G_VisibleSizeHeight - 100))
	hpTip:setTouchPriority(-(self.layerNum-1)*20-9)
	local tipLb=GetTTFLabel("?",35)
	tipLb:setColor(G_ColorYellowPro)
	tipLb:setRotation(180)
	tipLb:setPosition(getCenterPoint(hpTip))
	hpTip:addChild(tipLb)
	self.bgLayer:addChild(hpTip,4)
end

function serverWarLocalMapScene:initFunctionBar()
	self.functionBarHeight=112
	local function nilFunc()
	end
	local functionBarBg=LuaCCScale9Sprite:createWithSpriteFrameName("localWar_functionBarBorder.png",CCRect(20,20,10,10),nilFunc)
	functionBarBg:setTouchPriority(-(self.layerNum-1)*20-7)
	functionBarBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.functionBarHeight))
	functionBarBg:setAnchorPoint(ccp(0.5,0))
	functionBarBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
	self.bgLayer:addChild(functionBarBg,5)
	self.functionBar=functionBarBg

	--当前是不是最后一场战斗
	local function isLastBattle()
		local noticeTime = serverWarLocalCfg.getSignUp
		local signuptime = serverWarLocalCfg.signuptime
		local battleTime = serverWarLocalCfg.battleTime
		local startWarTime = serverWarLocalCfg.startWarTime
		local groupId=serverWarLocalVoApi:getGroupID() or "b"
		startWarTime=startWarTime[groupId]
		local st=serverWarLocalVoApi:getStartTime()
		local lastWarSt = st + noticeTime + signuptime*3600*24 + startWarTime[1]*3600 + startWarTime[2]*60 + (battleTime - 1)*86400
		if(base.serverTime>=lastWarSt)then
			return true
		else
			return false
		end
	end

	local function onSetTroops()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if(isLastBattle() and serverWarLocalFightVoApi:checkIsEnd())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_matchStatus2"),30)
			do return end
		end
		local function callback()
			serverWarLocalVoApi:showTroopsDialog(self.layerNum+1)
		end
		serverWarLocalFightVoApi:refreshTroops(callback)		
	end
	local setTroopsItem=GetButtonItem("mainBtnTeam.png","mainBtnTeam_Down.png","mainBtnTeam_Down.png",onSetTroops,nil,nil,nil)
	local setTroopsBtn=CCMenu:createWithItem(setTroopsItem)
	setTroopsBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	setTroopsBtn:setPosition(ccp(G_VisibleSizeWidth/10,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(setTroopsBtn)
	if(serverWarLocalVoApi:getIsAllSetFleet()==false)then
		local troopAlert=CCSprite:createWithSpriteFrameName("IconTip.png")
		troopAlert:setAnchorPoint(CCPointMake(1,0.5))
		troopAlert:setPosition(ccp(G_VisibleSizeWidth/10 + 50,self.functionBarHeight/2 + 30))
		troopAlert:setTag(101)
		functionBarBg:addChild(troopAlert)
	end
	local setTroopsLb=GetTTFLabel(getlocal("fleetInfoTitle2"),25)
	setTroopsLb:setColor(G_ColorGreen)
	setTroopsLb:setPosition(ccp(G_VisibleSizeWidth/10,20))
	functionBarBg:addChild(setTroopsLb)

	local function onReport()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		serverWarLocalVoApi:showReportDialog(self.layerNum+1)
	end
	local reportItem=GetButtonItem("mainBtnMail.png","mainBtnMail_Down.png","mainBtnMail_Down.png",onReport,nil,nil,nil)
	local reportBtn=CCMenu:createWithItem(reportItem)
	reportBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	reportBtn:setPosition(ccp(G_VisibleSizeWidth*3/10,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(reportBtn)
	local reportLb=GetTTFLabel(getlocal("allianceWar_battleReport"),25)
	reportLb:setColor(G_ColorGreen)
	reportLb:setPosition(ccp(G_VisibleSizeWidth*3/10,20))
	functionBarBg:addChild(reportLb)
	self.tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp:setAnchorPoint(CCPointMake(1,0.5))
	self.tipSp:setPosition(ccp(reportItem:getContentSize().width,reportItem:getContentSize().height-15))
	self.tipSp:setVisible(false)
	reportItem:addChild(self.tipSp)

	local function onInformation()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if(base.serverTime<serverWarLocalFightVoApi:getStartTime())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarLocal_battleNotStart"),30)
			do return end
		end
		if(isLastBattle() and serverWarLocalFightVoApi:checkIsEnd())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_matchStatus2"),30)
			do return end
		end
		serverWarLocalVoApi:showInforDialog(self.layerNum+1)
	end
	local informationItem=GetButtonItem("serverWarLocalInfo.png","serverWarLocalInfo_down.png","serverWarLocalInfo_down.png",onInformation,nil,nil,nil)
	local informationBtn=CCMenu:createWithItem(informationItem)
	informationBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	informationBtn:setPosition(ccp(G_VisibleSizeWidth*7/10,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(informationBtn)
	local informationLb=GetTTFLabel(getlocal("serverWarLocal_information"),25)
	informationLb:setColor(G_ColorGreen)
	informationLb:setPosition(ccp(G_VisibleSizeWidth*7/10,20))
	functionBarBg:addChild(informationLb)

	local function onBuff()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if(base.serverTime<serverWarLocalFightVoApi:getStartTime())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarLocal_battleNotStart"),30)
			do return end
		end
		if(isLastBattle() and serverWarLocalFightVoApi:checkIsEnd())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_matchStatus2"),30)
			do return end
		end
		serverWarLocalVoApi:showBuffDialog(self.layerNum+1)
	end
	local buffItem=GetButtonItem("serverWarLocalBuff.png","serverWarLocalBuff_down.png","serverWarLocalBuff_down.png",onBuff,nil,nil,nil)
	local buffBtn=CCMenu:createWithItem(buffItem)
	buffBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	buffBtn:setPosition(ccp(G_VisibleSizeWidth/2,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(buffBtn)
	local buffLb=GetTTFLabel(getlocal("alliance_skill"),25)
	buffLb:setColor(G_ColorGreen)
	buffLb:setPosition(ccp(G_VisibleSizeWidth/2,20))
	functionBarBg:addChild(buffLb)

	local function onHelp()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		serverWarLocalVoApi:showHelpDialog(self.layerNum+1)
	end
	local helpItem=GetButtonItem("mainBtnHelp.png","mainBtnHelp_Down.png","mainBtnHelp_Down.png",onHelp,nil,nil,nil)
	local helpBtn=CCMenu:createWithItem(helpItem)
	helpBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	helpBtn:setPosition(ccp(G_VisibleSizeWidth*9/10,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(helpBtn)
	local helpLb=GetTTFLabel(getlocal("help"),25)
	helpLb:setColor(G_ColorGreen)
	helpLb:setPosition(ccp(G_VisibleSizeWidth*9/10,20))
	functionBarBg:addChild(helpLb)

	self.listLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(0,0,10,10),function( ... )end)
	self.listLayer:setOpacity(180)
	self.listLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
	self.listLayer:setAnchorPoint(ccp(0,1))
	self.listLayer:setPosition(ccp(0,G_VisibleSizeHeight - self.titleHeight))
	self.bgLayer:addChild(self.listLayer,1)
	local allianceList={}
	for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
		table.insert(allianceList,v)
	end
	local function sortFunc(a,b)
		return a.side<b.side
	end
	table.sort(allianceList,sortFunc)
	for k,v in pairs(allianceList) do
		local icon=CCSprite:createWithSpriteFrameName("serverWarLocal_t"..v.side..".png")
		icon:setPosition(G_VisibleSizeWidth/4*(k - 1) + 30,25)
		self.listLayer:addChild(icon)
		local lb=GetTTFLabel(serverWarLocalFightVoApi:getPointTb()[v.id] or 0,25)
		lb:setTag(100 + k)
		lb:setAnchorPoint(ccp(0,0.5))
		lb:setPosition(G_VisibleSizeWidth/4*(k - 1) + 60,25)
		self.listLayer:addChild(lb)
		local arrTb=Split(v.id,"-")
		if tonumber(arrTb[2])==tonumber(playerVoApi:getPlayerAid()) then
			local lightSp=CCSprite:createWithSpriteFrameName("swlocal_myselfPointBg.png")
			lightSp:setPosition(getCenterPoint(icon))
			icon:addChild(lightSp)
			local acArr=CCArray:create()
			local fadeIn=CCFadeIn:create(0.5)
			local fadeOut=CCFadeOut:create(0.5)
			local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
			local blinkAc=CCRepeatForever:create(seq)
			lightSp:runAction(blinkAc)
		end
	end

	if(base.serverTime<=serverWarLocalFightVoApi:getStartTime() - 300)then
		local function onCarryGems()
			if G_checkClickEnable()==false then
				do
					return
				end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			serverWarLocalVoApi:showBattleFundsDialog(self.layerNum+1)
		end
		self.gemBtn=LuaCCSprite:createWithSpriteFrameName("serverWarLocalFeat.png",onCarryGems)
		self.gemBtn:setTouchPriority(-(self.layerNum-1)*20-8)
		self.gemBtn:setPosition(ccp(100,300))
		self.bgLayer:addChild(self.gemBtn,5)
		local lb=GetTTFLabel(getlocal("serverwarteam_funds"),25)
		lb:setPosition(self.gemBtn:getContentSize().width/2,-15)
		self.gemBtn:addChild(lb)
	end
end

function serverWarLocalMapScene:checkTroopAlert()
	if(serverWarLocalVoApi:getIsAllSetFleet() and self.isShow and self.functionBar)then
		local troopAlert=tolua.cast(self.functionBar:getChildByTag(101),"CCSprite")
		if(troopAlert)then
			troopAlert:removeFromParentAndCleanup(true)
		end
	end
end

function serverWarLocalMapScene:refreshScore()
	if(self.listLayer==nil)then
		do return end
	end
	local allianceList={}
	for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
		table.insert(allianceList,v)
	end
	local function sortFunc(a,b)
		return a.side<b.side
	end
	table.sort(allianceList,sortFunc)
	for k,v in pairs(allianceList) do
		local lb=tolua.cast(self.listLayer:getChildByTag(100 + k),"CCLabelTTF")
		if(lb)then
			lb:setString(serverWarLocalFightVoApi:getPointTb()[v.id] or 0)
		end
	end
end

function serverWarLocalMapScene:touchEvent(fn,x,y,touch)
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
		-- if self.isMoving==true then
		-- 	self.isMoving=false
		-- 	local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
		-- 	tmpToPos=self:checkBound(tmpToPos)

		-- 	local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
		-- 	local cceaseOut=CCEaseOut:create(ccmoveTo,3)
		-- 	self.clayer:runAction(cceaseOut)
		-- end
	else
		self.touchArr=nil
		self.touchArr={}
	end
end

function serverWarLocalMapScene:checkBound(pos)
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

function serverWarLocalMapScene:initMap()
	--摆城市
	local cityTexture=spriteController:getTexture("public/serverWarLocal/serverWarLocalCity.png")
	local cityBatchNode=CCSpriteBatchNode:createWithTexture(cityTexture,45)
	self.background:addChild(cityBatchNode,3)
	local function onClickCity(object,name,tag)
		if(self.isMoved)then
			do return end
		end
		if(base.serverTime<serverWarLocalFightVoApi:getStartTime())then
			do return end
		end
		local cityID = "a"..tag
		serverWarLocalFightVoApi:showCityDialog(cityID,self.selectedTroopID,self.layerNum + 1)
	end
	self.cityList=serverWarLocalFightVoApi:getCityList()
	self.cityStatusList={}
	local keyIndex={}
	for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
		keyIndex[v.id]=v.side
	end
	local cityTroopList={}
	local selfAllianceID=base.curZoneID.."-"..playerVoApi:getPlayerAid()
	for k,troopVo in pairs(serverWarLocalFightVoApi:getTroops()) do
		if(troopVo.arriveTime<=base.serverTime and troopVo.canMoveTime<=base.serverTime)then
			if(cityTroopList[troopVo.cityID]==nil)then
				cityTroopList[troopVo.cityID]={}
			end
			if(cityTroopList[troopVo.cityID][troopVo.allianceID])then
				cityTroopList[troopVo.cityID][troopVo.allianceID]=cityTroopList[troopVo.cityID][troopVo.allianceID] + 1
			else
				cityTroopList[troopVo.cityID][troopVo.allianceID]=1
			end
		end
	end
	for k,v in pairs(self.cityList) do
		local cityIcon=LuaCCSprite:createWithSpriteFrameName(v.cfg.icon,onClickCity)
		cityIcon:setScale(0.7)
		cityIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		cityIcon:setTag(tonumber(string.sub(v.id,2)))
		cityIcon:setPosition(ccp(v.cfg.pos[1],v.cfg.pos[2]))
		cityBatchNode:addChild(cityIcon,2)
		if(v.cfg.type==2 and v.allianceID==selfAllianceID)then
			self.clayer:setPosition(G_VisibleSizeWidth/2 - v.cfg.pos[1],G_VisibleSizeHeight/2 - v.cfg.pos[2])
			self:checkBound()
		end

		local statusBg=CCSprite:createWithSpriteFrameName("BlackBg.png")
		statusBg:setPosition(v.cfg.pos[1],v.cfg.pos[2] - 70)
		self.background:addChild(statusBg,4)
		self.cityStatusList[k]=statusBg
		local cityNameBg
		if(v.allianceID~=0 and v.allianceID and keyIndex[v.allianceID])then
			cityNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg"..keyIndex[v.allianceID]..".png",CCRect(10,10,10,10),onClickCity)
		else
			cityNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),onClickCity)
		end
		cityNameBg:setTag(101)
		cityNameBg:setPosition(5,5)
		statusBg:addChild(cityNameBg)
		local cityNameLb=GetTTFLabelWrap(getlocal(v.cfg.name),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		cityNameBg:setContentSize(CCSizeMake(cityNameLb:getContentSize().width + 10,cityNameLb:getContentSize().height + 10))
		cityNameLb:setPosition(getCenterPoint(cityNameBg))
		cityNameBg:addChild(cityNameLb)
		local statusIconName
		if(cityTroopList[k])then
			for allianceID,num in pairs(cityTroopList[k]) do
				if(allianceID~=v.allianceID and num>0)then
					statusIconName="serverWarStatus2.png"
					break
				end
			end
			if(statusIconName==nil)then
				statusIconName="serverWarStatus1.png"
			end
		else
			statusIconName="serverWarStatus1.png"
		end
		local cityStatusIcon=CCSprite:createWithSpriteFrameName(statusIconName)
		cityStatusIcon:setTag(102)
		cityStatusIcon:setPosition(-70,5)
		statusBg:addChild(cityStatusIcon,2)
		local numLb
		if(cityTroopList[k] and cityTroopList[k][selfAllianceID])then
			numLb=GetTTFLabel(cityTroopList[k][selfAllianceID],22)
		else
			numLb=GetTTFLabel("0",22)
		end
		numLb:setPosition(cityStatusIcon:getContentSize().width/2,cityStatusIcon:getContentSize().height/2)
		numLb:setTag(103)
		cityStatusIcon:addChild(numLb)
		--鹰巢未被攻占的时候会显示防守部队的剩余血量
		if(v.id==self.mapCfg.bossCity and v.hp>0 and v.allianceID==0)then
			self.bossHp=CCSprite:createWithSpriteFrameName("TimeBg.png")
			self.bossHp:setScaleX(155/self.bossHp:getContentSize().width)
			self.bossHp:setScaleY(21/self.bossHp:getContentSize().height)
			self.bossHp:setPosition(ccp(v.cfg.pos[1],v.cfg.pos[2] + 50))
			self.background:addChild(self.bossHp,3)
			local hpProgress=CCProgressTimer:create(CCSprite:createWithSpriteFrameName("AllXpBar.png"))
			hpProgress:setTag(101)
			hpProgress:setType(kCCProgressTimerTypeBar)
			hpProgress:setMidpoint(ccp(0,0))
			hpProgress:setBarChangeRate(ccp(1,0))
			hpProgress:setScaleX((self.bossHp:getContentSize().width - 10)/hpProgress:getContentSize().width)
			hpProgress:setScaleY((self.bossHp:getContentSize().height - 4)/hpProgress:getContentSize().height)
			hpProgress:setAnchorPoint(ccp(0,0))
			hpProgress:setPosition(ccp(5,2))
			hpProgress:setPercentage(v.hp)
			self.bossHp:addChild(hpProgress)
		end
	end
	--画道路
	self.roadList={}
	local roadBatchNode=CCSpriteBatchNode:create("serverWar/serverWar2.png",360)
	self.background:addChild(roadBatchNode,1)
	local connectTb={}
	local testSprite=CCSprite:createWithSpriteFrameName("highway1.png")
	local roadLength=testSprite:getContentSize().width
	for cityID,cityVo in pairs(self.cityList) do
		local posCity=cityVo.cfg.pos
		for k,nearID in pairs(cityVo.cfg.adjoin) do
			local flag1,flag2=false,false
			for index,stationID in pairs(self.mapCfg.railWayStation) do
				if(stationID==cityID)then
					flag1=true
				end
				if(stationID==nearID)then
					flag2=true
				end
			end
			--火车站之间的路是不显示出来的
			if(flag1==false or flag2==false)then
				local connectKey1=cityID.."-"..nearID
				local connectKey2=nearID.."-"..cityID
				if(connectTb[connectKey1]==nil and connectTb[connectKey2]==nil)then
					connectTb[connectKey1]=1
					local posTarget=self.mapCfg.cityCfg[nearID].pos
					local distance=self:distance(posCity,posTarget)
					local roadNum=math.ceil(distance/roadLength,0)
					local angle=math.deg(math.asin((posTarget[2] - posCity[2])/distance))
					if(posTarget[1]<posCity[1])then
						angle=180 - angle
					end
					for i=1,roadNum do
						local roadSprite=CCSprite:createWithSpriteFrameName("highway1.png")
						roadSprite:setRotation(90 - angle)
						local posX=posCity[1] + (i - 1)*roadLength*math.cos(math.rad(angle))
						local posY=posCity[2] + (i - 1)*roadLength*math.sin(math.rad(angle)) - 10
						roadSprite:setPosition(ccp(posX,posY))
						roadBatchNode:addChild(roadSprite)
						if(cityVo.cfg.roadType[k]==2)then
							table.insert(self.roadList,roadSprite)
							if(base.serverTime<serverWarLocalFightVoApi:getStartTime() + serverWarLocalCfg.countryRoadTime)then
								roadSprite:setVisible(false)
							end
						end
					end
				end
			end
		end
	end
	self:showOrder(serverWarLocalFightVoApi.order)
end

function serverWarLocalMapScene:refreshTroops()
	self.troops=serverWarLocalFightVoApi:getSelfTroops()
	if(SizeOfTable(self.troops)<=0)then
		do return end
	end
	if(self.troopIcons==nil)then
		self.troopIcons={}
	end
	if self.selfTroopsTags==nil then
		self.selfTroopsTags={}
	end
	if self.troopTip==nil then
		self.troopTip=CCSprite:createWithSpriteFrameName("BlackBg.png")
		self.troopTip:setOpacity(0)
		self.troopTip:setAnchorPoint(ccp(0,0))
		self.troopTip:setPosition(G_VisibleSizeWidth - 100,self.functionBarHeight)
		self.bgLayer:addChild(self.troopTip,5)
	end

	local totalHeight=SizeOfTable(self.troops)*120 - 10
	local index=0

	local function onSelectTroop(object,fn,tag)
		local index=tag
		if(index and self.troops[index])then
			if(self.troops[index].canMoveTime>base.serverTime)then
				self:revive(index)
			else
				local tipIcon=tolua.cast(self.troopTip:getChildByTag(self.selectedTroopID),"CCSprite")
				local border=tolua.cast(self.troopTip:getChildByTag(888),"LuaCCScale9Sprite")
				if tipIcon and border then
					border:setPosition(tipIcon:getPositionX()+50,tipIcon:getPositionY()+50)
				end
				self.selectedTroopID=index
				for troopID,troopIcon in pairs(self.troopIcons) do
					local arrow=tolua.cast(troopIcon:getChildByTag(100),"CCSprite")
					if(troopID==self.selectedTroopID and arrow)then
						arrow:setVisible(true)
					elseif(arrow)then
						arrow:setVisible(false)
					end
				end
			end
		end
		if(index and self.troopIcons[index])then
			self.clayer:setPosition(G_VisibleSizeWidth/2 - self.troopIcons[index]:getPositionX(),G_VisibleSizeHeight/2 - self.troopIcons[index]:getPositionY())
			self:checkBound()
		end
	end

	for troopID,troopVo in pairs(self.troops) do
		if(self.selectedTroopID==nil or self.troops[self.selectedTroopID]==nil)then
			self.selectedTroopID=troopID
		end
		if self.selfTroopsTags[troopID]==nil then
			self.selfTroopsTags[troopID]={}
		end
		local trainIcon,arrowIcon
		if(self.troopIcons[troopID])then
			self.troopIcons[troopID]=tolua.cast(self.troopIcons[troopID],"CCSprite")
			trainIcon=tolua.cast(self.troopIcons[troopID]:getChildByTag(101),"CCSprite")
			arrowIcon=tolua.cast(self.troopIcons[troopID]:getChildByTag(100),"CCSprite")
		else
			self.troopIcons[troopID]=CCSprite:createWithSpriteFrameName("ProductTankDialog.png")
			self.troopIcons[troopID]:setAnchorPoint(ccp(0.5,0))
			self.background:addChild(self.troopIcons[troopID],7)
			trainIcon=CCSprite:createWithSpriteFrameName("serverWarLocalTrain.png")
			trainIcon:setTag(101)
			trainIcon:setScale(56/trainIcon:getContentSize().width)
			trainIcon:setPosition(ccp(self.troopIcons[troopID]:getContentSize().width/2-0.5,self.troopIcons[troopID]:getContentSize().height/2+6))
			self.troopIcons[troopID]:addChild(trainIcon,1)
			arrowIcon=CCSprite:createWithSpriteFrameName("GuideArow.png")
			arrowIcon:setTag(100)
			arrowIcon:setScale(0.5)
			arrowIcon:setAnchorPoint(ccp(0.5,0))
			arrowIcon:setPosition(ccp(self.troopIcons[troopID]:getContentSize().width/2-0.5,self.troopIcons[troopID]:getContentSize().height))
			self.troopIcons[troopID]:addChild(arrowIcon,1)
		end
		trainIcon:setVisible(false)
		if(self.selectedTroopID==troopID)then
			arrowIcon:setVisible(true)
		else
			arrowIcon:setVisible(false)
		end
		local pos
		if(self.troops[troopID].arriveTime<=base.serverTime)then
			pos=self.cityList[self.troops[troopID].cityID].cfg.pos
		else
			pos=self.cityList[self.troops[troopID].lastCityID].cfg.pos
		end
		self.troopIcons[troopID]:setPosition(pos[1],pos[2])
		-- local oldIcon=self.troopIcons[troopID]:getChildByTag(102)
		-- if(oldIcon)then
		-- 	oldIcon=tolua.cast(oldIcon,"CCSprite")
		-- 	print("∑∑removeOldIcon")
		-- 	oldIcon:removeFromParentAndCleanup(true)
		-- end
		local troopIconTag=0
		local troopIcon,tmpIcon
		local atBase=false
		for k,baseID in pairs(self.mapCfg.baseCityID) do
			if(baseID==troopVo.cityID)then
				atBase=true
				break
			end
		end
		if(atBase)then
			local heroData=heroVoApi:getServerWarLocalHeroList(troopID)
			local hid=0
			if(heroData)then
				for k,v in pairs(heroData) do
					if(v and v~=0)then
						hid=v
						break
					end
				end
			end
			if(hid and hid~=0)then
				troopIconTag=110+RemoveFirstChar(hid)
				-- troopIcon=heroVoApi:getHeroIcon(hid,nil,false)
			else
				troopIconTag=10000+playerVoApi:getPic()
				-- troopIcon=playerVoApi:getPersonPhotoSp(playerVoApi:getPic())
			end
		else
			if(troopVo.heroID)then
				troopIconTag=110+RemoveFirstChar(troopVo.heroID)
				-- troopIcon=heroVoApi:getHeroIcon(troopVo.heroID,nil,false)
			else
				troopIconTag=10000+playerVoApi:getPic()
				-- troopIcon=playerVoApi:getPersonPhotoSp(playerVoApi:getPic())
			end
		end
		-- troopIcon:setTag(102)

		local tipIcon=tolua.cast(self.troopTip:getChildByTag(troopID),"LuaCCScale9Sprite")
		if tipIcon==nil then
			tipIcon=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocalTroopBg.png",CCRect(0,0,10,10),onSelectTroop)
			tipIcon:setTag(troopID)
			tipIcon:setContentSize(CCSizeMake(100,100))
			tipIcon:setTouchPriority(-(self.layerNum-1)*20-6)
			tipIcon:setAnchorPoint(ccp(0,0))
			tipIcon:setPosition(ccp(0,totalHeight - index*120 + 10))
			self.troopTip:addChild(tipIcon,1)
		end

		local iconTag=self.selfTroopsTags[troopID].iconTag
		-- print("iconTag,troopIconTag---????",iconTag,troopIconTag)
		if iconTag then
			troopIcon=tolua.cast(self.troopIcons[troopID]:getChildByTag(iconTag),"CCSprite")		
			tmpIcon=tolua.cast(tipIcon:getChildByTag(iconTag),"CCSprite")
			if troopIconTag and tonumber(iconTag)~=tonumber(troopIconTag) then
				if troopIcon then
					troopIcon:removeFromParentAndCleanup(true)
					troopIcon=nil
					-- print("∑∑removeOldIcon")
				end
				if tmpIcon then
					tmpIcon:removeFromParentAndCleanup(true)
					tmpIcon=nil
					-- print("∑∑removeOldtmpIcon")
				end
			end
		end
		if (iconTag==nil) or (troopIconTag and tonumber(iconTag)~=tonumber(troopIconTag)) then
			self.selfTroopsTags[troopID].iconTag=troopIconTag
			if tonumber(troopIconTag)>=10000 then
				troopIcon=playerVoApi:getPersonPhotoSp(playerVoApi:getPic())
				tmpIcon=playerVoApi:getPersonPhotoSp(playerVoApi:getPic())
				local border=CCSprite:createWithSpriteFrameName("heroHead1.png")
				border:setScale(tmpIcon:getContentSize().width/border:getContentSize().width)
				border:setPosition(getCenterPoint(tmpIcon))
				tmpIcon:addChild(border)
			else
				local hid="h"..(troopIconTag-110)
				troopIcon=heroVoApi:getHeroIcon(hid,nil,false)
				tmpIcon=heroVoApi:getHeroIcon(hid,nil,false)
			end
			troopIcon:setTag(troopIconTag)
			troopIcon:setScale(56/troopIcon:getContentSize().width)
			troopIcon:setPosition(ccp(self.troopIcons[troopID]:getContentSize().width/2-0.5,self.troopIcons[troopID]:getContentSize().height/2+6))
			self.troopIcons[troopID]:addChild(troopIcon)

			tmpIcon:setTag(troopIconTag)
			tmpIcon:setScale(100/tmpIcon:getContentSize().width)
			tmpIcon:setPosition(50,50)
			tipIcon:addChild(tmpIcon)
		end

		if(troopID==self.selectedTroopID)then
			local border=tolua.cast(self.troopTip:getChildByTag(888),"LuaCCScale9Sprite")
			if border==nil then
				border=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(20,20,10,10),function () end)
				border:setTag(888)
				border:setContentSize(CCSizeMake(110,110))
				self.troopTip:addChild(border,3)
			end
			border:setPosition(tipIcon:getPositionX()+50,tipIcon:getPositionY()+50)
		end
		local hpBgTag,hpProgressTag,maskTag,deadLbTag=1001,1002,997,(100+troopID)
		local hpBg=tolua.cast(tipIcon:getChildByTag(hpBgTag),"LuaCCScale9Sprite")
		if hpBg==nil then
			hpBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(0,0,10,10),function () end)
			hpBg:setTag(hpBgTag)
			hpBg:setContentSize(CCSizeMake(90,24))
			hpBg:setPosition(ccp(50,15))
			tipIcon:addChild(hpBg,2)
		end
		local mask=tolua.cast(tmpIcon:getChildByTag(maskTag),"CCSprite")
		local deadLb=tolua.cast(self.troopTip:getChildByTag(deadLbTag),"CCLabelTTF")
		local hpProgress=tolua.cast(tipIcon:getChildByTag(hpProgressTag),"CCSprite")
		if(troopVo.canMoveTime>base.serverTime)then
			if mask==nil then
				mask=CCSprite:createWithSpriteFrameName("BlackBg.png")
				mask:setScale(tmpIcon:getContentSize().width/mask:getContentSize().width)
				mask:setOpacity(150)
				mask:setTag(maskTag)
				mask:setAnchorPoint(ccp(0,0))
				tmpIcon:addChild(mask)
			end
			if deadLb==nil then
				deadLb=GetTTFLabel(GetTimeStr(troopVo.canMoveTime - base.serverTime),22)
				deadLb:setTag(deadLbTag)
				deadLb:setColor(G_ColorRed)
				deadLb:setPosition(ccp(50,totalHeight - index*120 + 10 + 50))
				self.troopTip:addChild(deadLb,2)
			else
				deadLb:setString(GetTimeStr(troopVo.canMoveTime - base.serverTime))
			end
			hpBg:setVisible(false)
			if hpProgress then
				hpProgress:setVisible(false)
			end
		else
			hpBg:setVisible(true)
			if mask then
				mask:removeFromParentAndCleanup(true)
				mask=nil
			end
			if deadLb then
				deadLb:removeFromParentAndCleanup(true)
				deadLb=nil
			end
			--画血条，一格一格的
			if hpProgress then
				hpProgress:setVisible(true)
			else
				hpProgress=CCSprite:createWithSpriteFrameName("BlackBg.png")
				hpProgress:setOpacity(0)
				hpProgress:setAnchorPoint(ccp(0,0.5))
				hpProgress:setPosition(ccp(5,15))
				hpProgress:setTag(hpProgressTag)
				tipIcon:addChild(hpProgress,3)
			end
			hpProgress:removeAllChildrenWithCleanup(true)

			local length=troopVo.hpPercent*88/100
			local gridNum=math.floor(length/10)
			local gridName
			if(troopVo.hpPercent>80)then
				gridName="platWar_bloodGreen.png"
			elseif(troopVo.hpPercent>30)then
				gridName="platWar_bloodYellow.png"
			else
				gridName="platWar_bloodRed.png"
			end
			for i=1,gridNum do
				local gridSprite=CCSprite:createWithSpriteFrameName(gridName)
				gridSprite:setScaleX(15/gridSprite:getContentSize().width)
				gridSprite:setScaleY(8/gridSprite:getContentSize().height)
				gridSprite:setAnchorPoint(ccp(0.5,0))
				gridSprite:setRotation(90)
				gridSprite:setTag(10+i)
				gridSprite:setPosition(ccp(10*(i - 1),hpProgress:getContentSize().height/2))
				hpProgress:addChild(gridSprite)
			end
			if(10*gridNum<length)then
				local gridSprite=CCSprite:createWithSpriteFrameName(gridName)
				gridSprite:setScaleX(15/gridSprite:getContentSize().width)
				gridSprite:setScaleY((length - 10*gridNum)/gridSprite:getContentSize().height)
				gridSprite:setAnchorPoint(ccp(0.5,0))
				gridSprite:setRotation(90)
				gridSprite:setTag(101)
				gridSprite:setPosition(ccp(10*gridNum,hpProgress:getContentSize().height/2))
				hpProgress:addChild(gridSprite)
			end
		end
		self:troopMove(troopID)

		index = index + 1
	end
end

function serverWarLocalMapScene:troopMove(troopID)
	if(self.troops[troopID]==nil)then
		do return end
	end
	local targetCity=self.cityList[self.troops[troopID].cityID]
	local startCity=self.cityList[self.troops[troopID].lastCityID]
	if(self.troops[troopID].arriveTime<=base.serverTime or targetCity==nil or startCity==nil)then
		self.troopIcons[troopID]:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
		do return end
	end
	local distance=self:distance(startCity.cfg.pos,targetCity.cfg.pos)
	local key
	for k,v in pairs(startCity.cfg.adjoin) do
		if(v==targetCity.id)then
			key=k
			break
		end
	end
	if(key==nil)then
		self.troopIcons[troopID]:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
		do return end
	end
	local flag1,flag2=false,false
	for k,cityID in pairs(self.mapCfg.railWayStation) do
		if(cityID==targetCity.id)then
			flag1=true
		end
		if(cityID==startCity.id)then
			flag2=true
		end
	end
	if(flag1 and flag2)then
		local trainIcon=tolua.cast(self.troopIcons[troopID]:getChildByTag(101),"CCSprite")
		trainIcon:setVisible(true)
	end
	self.troopIcons[troopID]:stopAllActions()
	local totalNeedTime=startCity.cfg.distance[key]
	local leftTime=self.troops[troopID].arriveTime - base.serverTime
	if(leftTime>totalNeedTime)then
		leftTime=totalNeedTime
	end
	local startPosX=(targetCity.cfg.pos[1] - startCity.cfg.pos[1])*(totalNeedTime - leftTime)/totalNeedTime + startCity.cfg.pos[1]
	local startPosY=(targetCity.cfg.pos[2] - startCity.cfg.pos[2])*(totalNeedTime - leftTime)/totalNeedTime + startCity.cfg.pos[2]
	self.troopIcons[troopID]:setPosition(ccp(startPosX,startPosY))
	local actionArr=CCArray:create()
	local ccmoveTo=CCMoveTo:create(leftTime,ccp(targetCity.cfg.pos[1],targetCity.cfg.pos[2]))
	actionArr:addObject(ccmoveTo)
	local function moveEnd()
		local trainIcon=tolua.cast(self.troopIcons[troopID]:getChildByTag(101),"CCSprite")
		trainIcon:setVisible(false)
		self.troopIcons[troopID]:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
	end
	local fc= CCCallFunc:create(moveEnd)
	actionArr:addObject(fc)
	local seq=CCSequence:create(actionArr)
	self.troopIcons[troopID]:runAction(seq)
end

function serverWarLocalMapScene:distance(pos1,pos2)
	return math.sqrt((pos1[1]-pos2[1])*(pos1[1]-pos2[1])+(pos1[2]-pos2[2])*(pos1[2]-pos2[2]))
end

function serverWarLocalMapScene:dealEvent(event,data)
	local type=data.type
	if(type=="troop")then
		local selfTroops={}
		local flag=false
		for k,troopVo in pairs(data.data) do
			if(troopVo.uid==playerVoApi:getUid() and troopVo.serverID==tonumber(base.curZoneID))then
				selfTroops[troopVo.troopID]=troopVo
				flag=true
			end
		end
		if(flag)then
			self:refreshTroops()
			for troopID,troopVo in pairs(selfTroops) do
				if(self.troopAlerts==nil)then
					self.troopAlerts={}
				end
				if(self.troopAlerts[troopID]==nil)then
					self.troopAlerts[troopID]={time=0}
				end
				if(troopVo.canMoveTime>base.serverTime)then
					if(self.troopIcons[troopID])then
						self.troopIcons[troopID]:stopAllActions()
						local targetCity=self.cityList[troopVo.cityID]
						self.troopIcons[troopID]:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
					end
					if(troopVo.lastEnemyID and troopVo.battleTime~=self.troopAlerts[troopID].time and troopVo.battleTime>self.showTime)then
						if(self.troopAlerts[troopID].tip)then
							self.troopAlerts[troopID].tip=nil
						end
						--因为有可能同一次死亡消息在refresh和push中重复发了请求, 所以记一个时间, 如果死亡时间相同的话就不再提示
						local enemy
						if(troopVo.lastEnemyID=="0-0-1")then
							enemy={name=getlocal("local_war_npc_name")}
						else
							enemy=serverWarLocalFightVoApi:getTroop(troopVo.lastEnemyID)
						end
						if(enemy)then
							--部队icon旁边弹出tip，显示被XX击败
							self.troopAlerts[troopID].time=troopVo.battleTime
							local alertTip=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocalTip.png",CCRect(20, 20, 40, 45),function ( ... )end)
							local lb1=GetTTFLabel(getlocal("serverWarLocal_dieTip").." "..getlocal("serverWarLocal_dieTip1"),25)
							local lb2=GetTTFLabelWrap(getlocal("serverwarteam_youAreKilled",{enemy.name}),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
							local tipHeight=math.max(lb1:getContentSize().height + lb2:getContentSize().height + 20,90)
							alertTip:setContentSize(CCSizeMake(440,tipHeight))
							lb1:setColor(G_ColorRed)
							lb1:setAnchorPoint(ccp(0,1))
							lb1:setPosition(20,tipHeight - 10)
							alertTip:addChild(lb1)
							lb2:setAnchorPoint(ccp(0,1))
							lb2:setPosition(20,tipHeight - 40)
							alertTip:addChild(lb2)
							alertTip:setAnchorPoint(ccp(0,0.5))
							local tipIcon=tolua.cast(self.troopTip:getChildByTag(troopID),"CCSprite")
							alertTip:setPosition(0,tipIcon:getPositionY() + 50)
							-- alertTip:setScaleX(0.2)
							self.troopTip:addChild(alertTip)
							self.troopAlerts[troopID].tip=alertTip
							local moveShow=CCMoveTo:create(0.7,ccp(-alertTip:getContentSize().width,alertTip:getPositionY()))
							-- local scaleShow=CCScaleTo:create(1,1,1)
							-- local showArr=CCArray:create()
							-- showArr:addObject(moveShow)
							-- showArr:addObject(scaleShow)
							-- local showAction=CCSpawn:create(showArr)
							local delay=CCDelayTime:create(2)
							local moveHide=CCMoveTo:create(0.7,ccp(0,alertTip:getPositionY()))
							-- local scaleHide=CCScaleTo:create(1,0.2,1)
							-- local hideArr=CCArray:create()
							-- hideArr:addObject(moveHide)
							-- hideArr:addObject(scaleHide)
							-- local hideAction=CCSpawn:create(hideArr)
							local function onActionEnd()
								if(self and self.troopAlerts and troopVo and troopVo.troopID and self.troopAlerts[troopVo.troopID] and self.troopAlerts[troopVo.troopID].tip)then
									self.troopAlerts[troopVo.troopID].tip=tolua.cast(self.troopAlerts[troopVo.troopID].tip,"CCScale9Sprite")
									if(self.troopAlerts[troopVo.troopID].tip)then
										self.troopAlerts[troopVo.troopID].tip:removeFromParentAndCleanup(true)
										self.troopAlerts[troopVo.troopID].tip=nil
									end
								end
							end
							local endFunc=CCCallFunc:create(onActionEnd)
							local acArr=CCArray:create()
							acArr:addObject(moveShow)
							acArr:addObject(delay)
							acArr:addObject(moveHide)
							acArr:addObject(endFunc)
							local seq=CCSequence:create(acArr)
							alertTip:runAction(seq)
						end
					end
				elseif(troopVo.lastEnemyID and troopVo.battleTime~=self.troopAlerts[troopID].time and troopVo.battleTime>self.showTime)then
					if(self.troopAlerts[troopID].tip)then
						self.troopAlerts[troopID].tip=nil
					end
					local enemy
					if(troopVo.lastEnemyID=="0-0-1")then
						enemy={name=getlocal("local_war_npc_name"),allianceName=getlocal(self.cityList[troopVo.cityID].cfg.name)}
					else
						enemy=serverWarLocalFightVoApi:getTroop(troopVo.lastEnemyID)
					end
					if(enemy)then
						--部队icon旁边弹出tip，显示击败了XX
						self.troopAlerts[troopID].time=troopVo.battleTime
						local alertTip=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocalTip.png",CCRect(20, 20, 40, 45),function ( ... )end)
						local str1=getlocal("serverWarLocal_winTip1").."! "
						if(troopVo.killNum>1)then
							str1=str1..getlocal("serverWarLocal_winTip2",{troopVo.killNum}).."! "
							if(troopVo.killNum>=9)then
								str1=str1..getlocal("serverWarLocal_winTip7").."!"
							elseif(troopVo.killNum>=6)then
								str1=str1..getlocal("serverWarLocal_winTip6").."!"
							elseif(troopVo.killNum>=5)then
								str1=str1..getlocal("serverWarLocal_winTip5").."!"
							elseif(troopVo.killNum>=4)then
								str1=str1..getlocal("serverWarLocal_winTip4").."!"
							elseif(troopVo.killNum>=3)then
								str1=str1..getlocal("serverWarLocal_winTip3").."!"
							end
						end
						local lb1=GetTTFLabelWrap(str1,25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						local lb2=GetTTFLabelWrap(getlocal("local_war_tipWin",{enemy.allianceName,enemy.name}),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						local tipHeight=math.max(lb1:getContentSize().height + lb2:getContentSize().height + 20,90)
						alertTip:setContentSize(CCSizeMake(440,tipHeight))
						lb1:setColor(G_ColorYellowPro)
						lb1:setAnchorPoint(ccp(0,1))
						lb1:setPosition(20,tipHeight - 10)
						alertTip:addChild(lb1)
						lb2:setAnchorPoint(ccp(0,1))
						lb2:setPosition(20,tipHeight - 10 - lb1:getContentSize().height)
						alertTip:addChild(lb2)
						alertTip:setAnchorPoint(ccp(0,0.5))
						local tipIcon=tolua.cast(self.troopTip:getChildByTag(troopID),"CCSprite")
						alertTip:setPosition(0,tipIcon:getPositionY() + 50)
						-- alertTip:setScaleX(0.2)
						self.troopTip:addChild(alertTip)
						self.troopAlerts[troopID].tip=alertTip
						local moveShow=CCMoveTo:create(0.7,ccp(-alertTip:getContentSize().width,alertTip:getPositionY()))
						-- local scaleShow=CCScaleTo:create(1,1,1)
						-- local showArr=CCArray:create()
						-- showArr:addObject(moveShow)
						-- showArr:addObject(scaleShow)
						-- local showAction=CCSpawn:create(showArr)
						local delay=CCDelayTime:create(2)
						local moveHide=CCMoveTo:create(0.7,ccp(0,alertTip:getPositionY()))
						-- local scaleHide=CCScaleTo:create(1,0.2,1)
						-- local hideArr=CCArray:create()
						-- hideArr:addObject(moveHide)
						-- hideArr:addObject(scaleHide)
						-- local hideAction=CCSpawn:create(hideArr)
						local function onActionEnd()
							if(self and self.troopAlerts and troopVo and troopVo.troopID and self.troopAlerts[troopVo.troopID] and self.troopAlerts[troopVo.troopID].tip)then
								self.troopAlerts[troopVo.troopID].tip=tolua.cast(self.troopAlerts[troopVo.troopID].tip,"CCScale9Sprite")
								if(self.troopAlerts[troopVo.troopID].tip)then
									self.troopAlerts[troopVo.troopID].tip:removeFromParentAndCleanup(true)
									self.troopAlerts[troopVo.troopID].tip=nil
								end
							end
						end
						local endFunc=CCCallFunc:create(onActionEnd)
						local acArr=CCArray:create()
						acArr:addObject(moveShow)
						acArr:addObject(delay)
						acArr:addObject(moveHide)
						acArr:addObject(endFunc)
						local seq=CCSequence:create(acArr)
						alertTip:runAction(seq)
					end
				end
				break
			end
		end
		self:refreshCity()
	elseif(type=="city")then
		self:refreshCity()
	elseif(type=="order")then
		self:showOrder(data.data)
	elseif(type=="point")then
		self:refreshScore()
	elseif(type=="task")then
		self:refreshTask(data.data)
	elseif(type=="road")then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverWarLocal_roadShow"),30)
		for k,v in pairs(self.roadList) do
			v:setVisible(true)
		end
	elseif(type=="boss")then
		if data.data then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverWarLocal_killBoss",{data.data[2],data.data[1]}),30)
		end
	elseif(type=="over")then
		if(self.troopIcons)then
			for k,v in pairs(self.troopIcons) do
				v:stopAllActions()
			end
		end
		base:removeFromNeedRefresh(self)
	end
end

function serverWarLocalMapScene:refreshCity(list)
	local keyIndex={}
	for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
		keyIndex[v.id]=v.side
	end
	local cityTroopList={}
	local selfAllianceID=base.curZoneID.."-"..playerVoApi:getPlayerAid()
	for k,troopVo in pairs(serverWarLocalFightVoApi:getTroops()) do
		if(troopVo.arriveTime<=base.serverTime and troopVo.canMoveTime<=base.serverTime)then
			if(cityTroopList[troopVo.cityID]==nil)then
				cityTroopList[troopVo.cityID]={}
			end
			if(cityTroopList[troopVo.cityID][troopVo.allianceID])then
				cityTroopList[troopVo.cityID][troopVo.allianceID]=cityTroopList[troopVo.cityID][troopVo.allianceID] + 1
			else
				cityTroopList[troopVo.cityID][troopVo.allianceID]=1
			end
		end
	end
	local function nilFunc( ... )
	end
	if(list==nil)then
		list=self.cityList
	end
	for k,v in pairs(list) do
		local statusBg=self.cityStatusList[k]
		statusBg:removeChildByTag(101,true)
		if(v.allianceID~=0)then
			cityNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg"..keyIndex[v.allianceID]..".png",CCRect(10,10,10,10),nilFunc)
		else
			cityNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),nilFunc)
		end
		cityNameBg:setTag(101)
		cityNameBg:setPosition(5,5)
		statusBg:addChild(cityNameBg)
		local cityNameLb=GetTTFLabelWrap(getlocal(v.cfg.name),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		cityNameBg:setContentSize(CCSizeMake(cityNameLb:getContentSize().width + 10,cityNameLb:getContentSize().height + 10))
		cityNameLb:setPosition(getCenterPoint(cityNameBg))
		cityNameBg:addChild(cityNameLb)
		local statusIconName
		if(cityTroopList[k])then
			for allianceID,num in pairs(cityTroopList[k]) do
				if(allianceID~=v.allianceID and num>0)then
					statusIconName="serverWarStatus2.png"
					break
				end
			end
			if(statusIconName==nil)then
				statusIconName="serverWarStatus1.png"
			end
		else
			statusIconName="serverWarStatus1.png"
		end
		-- statusBg:removeChildByTag(102,true)
		local iconFrame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(statusIconName)
		local cityStatusIcon=tolua.cast(statusBg:getChildByTag(102),"CCSprite")
		if cityStatusIcon and iconFrame then
			cityStatusIcon:setDisplayFrame(iconFrame)
			local numLb=tolua.cast(cityStatusIcon:getChildByTag(103),"CCLabelTTF")
			if numLb then
				if(cityTroopList[k] and cityTroopList[k][selfAllianceID])then
					numLb:setString(cityTroopList[k][selfAllianceID])
				else
					numLb:setString("0")
				end
			end
			-- numLb:setPosition(cityStatusIcon:getContentSize().width/2,cityStatusIcon:getContentSize().height/2)
			-- cityStatusIcon:addChild(numLb)
		end

		-- local cityStatusIcon=CCSprite:createWithSpriteFrameName(statusIconName)
		-- cityStatusIcon:setTag(102)
		-- cityStatusIcon:setPosition(-70,5)
		-- statusBg:addChild(cityStatusIcon)

		--鹰巢未被攻占的时候会显示防守部队的剩余血量
		if(v.id==self.mapCfg.bossCity)then
		 	if(v.hp>0 and v.allianceID==0 and self.bossHp)then
				self.bossHp=tolua.cast(self.bossHp,"CCSprite")
				local hpProgress=tolua.cast(self.bossHp:getChildByTag(101),"CCProgressTimer")
				hpProgress:setPercentage(v.hp)
			elseif(self.bossHp)then
				self.bossHp=tolua.cast(self.bossHp,"CCSprite")
				if self.bossHp then
					self.bossHp:removeFromParentAndCleanup(true)
					self.bossHp=nil
				end
			end
		end
	end
end

function serverWarLocalMapScene:refreshTask()
	local taskData,taskExpireTime=serverWarLocalFightVoApi:getSelfTask()
	if(taskData==nil or type(taskData)~="table")then
		do return end
	end
	local targetCity=self.cityList[taskData[1]]
	if(targetCity==nil)then
		do return end
	end
	local completeTime=taskData[2]
	--如果时间相等, 说明是重复调用, 不做操作
	if(taskExpireTime==self.taskExpireTime and self.taskCompleteTime==completeTime)then
		do return end
	end
	self.taskExpireTime=taskExpireTime
	self.taskCompleteTime=completeTime
	if(self.taskTip==nil)then
		local function onClickTask()
			local taskData,taskExpireTime=serverWarLocalFightVoApi:getSelfTask()
			if(taskData==nil or type(taskData)~="table" or taskExpireTime<base.serverTime)then
				do return end
			end
			local targetCity=self.cityList[taskData[1]]
			self.clayer:setPosition(G_VisibleSizeWidth/2 - targetCity.cfg.pos[1],G_VisibleSizeHeight/2 - targetCity.cfg.pos[2])
			self:checkBound()
		end
		self.taskTip=LuaCCSprite:createWithSpriteFrameName("serverWarLocal_task.png",onClickTask)
		self.taskTip:setTouchPriority(-(self.layerNum-1)*20-6)
		self.taskTip:setAnchorPoint(ccp(1,1))
		self.taskTip:setPosition(ccp(G_VisibleSizeWidth - 10,G_VisibleSizeHeight - self.titleHeight - 50))
		self.bgLayer:addChild(self.taskTip,5)
		local leftTime=GetTimeStr(taskExpireTime - base.serverTime)
		local lb=GetTTFLabel(leftTime,25)
		lb:setTag(100)
		lb:setColor(G_ColorRed)
		lb:setPosition(ccp(self.taskTip:getContentSize().width/2,-15))
		self.taskTip:addChild(lb)
		local descLb=GetTTFLabelWrap(getlocal("serverWarLocal_taskDesc",{getlocal(targetCity.cfg.name)}),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		local tipMv=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(10,10,80,80),function( ... )end)
		tipMv:setTag(101)
		tipMv:setContentSize(CCSizeMake(420,descLb:getContentSize().height + 10))
		tipMv:setAnchorPoint(ccp(0,1))
		tipMv:setPosition(2*self.taskTip:getContentSize().width + 10,-35)
		self.taskTip:addChild(tipMv)
		descLb:setTag(200)
		descLb:setPosition(getCenterPoint(tipMv))
		tipMv:addChild(descLb)
		local icon=CCSprite:createWithSpriteFrameName("serverWarLocal_task.png")
		icon:setAnchorPoint(ccp(1,0.5))
		icon:setPosition(5,tipMv:getContentSize().height/2)
		tipMv:addChild(icon)
		local circleBg=CCSprite:createWithSpriteFrameName("BlackBg.png")
		circleBg:setTag(316)
		circleBg:setOpacity(0)
		circleBg:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2] - 20)
		self.background:addChild(circleBg,2)
		local circle1=CCSprite:createWithSpriteFrameName("serverWarLocalCircle.png")
		circle1:setPosition(5,5)
		circleBg:addChild(circle1)
		local fadeOut=CCFadeOut:create(0.5)
		local fadeIn=CCFadeIn:create(0.5)
		local acArr=CCArray:create()
		acArr:addObject(fadeOut)
		acArr:addObject(fadeIn)
		local seq=CCSequence:create(acArr)
		circle1:runAction(CCRepeatForever:create(seq))
		local circle2=CCSprite:createWithSpriteFrameName("serverWarLocalCircle.png")
		circle2:setPosition(5,5)
		circleBg:addChild(circle2,1)
		local scaleSmall=CCScaleTo:create(0.5,0.6)
		local scaleBig=CCScaleTo:create(0.5,1)
		local acArr=CCArray:create()
		acArr:addObject(scaleSmall)
		acArr:addObject(scaleBig)
		local seq=CCSequence:create(acArr)
		circle2:runAction(CCRepeatForever:create(seq))		
	else
		local lb=tolua.cast(self.taskTip:getChildByTag(100),"CCLabelTTF")
		lb:setString(GetTimeStr(taskExpireTime - base.serverTime))
		local tipMv=tolua.cast(self.taskTip:getChildByTag(101),"CCScale9Sprite")
		tipMv:stopAllActions()
		local descLb=tolua.cast(tipMv:getChildByTag(200),"CCLabelTTF")
		descLb:setString(getlocal("serverWarLocal_taskDesc",{getlocal(targetCity.cfg.name)}))
		tipMv:setContentSize(CCSizeMake(descLb:getContentSize().width + 20,descLb:getContentSize().height + 10))
		tipMv:setPosition(2*self.taskTip:getContentSize().width + 10,-35)
		descLb:setPosition(getCenterPoint(tipMv))
		local circleBg=tolua.cast(self.background:getChildByTag(316),"CCSprite")
		circleBg:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2] - 20)
	end
	if(taskExpireTime<=base.serverTime or (completeTime and completeTime<=base.serverTime - 5))then
		self.taskTip:setVisible(false)
		self.taskTip:setPositionX(999333)
		local circleBg=tolua.cast(self.background:getChildByTag(316),"CCSprite")
		circleBg:setVisible(false)
	elseif(completeTime and completeTime>=base.serverTime - 5)then
		self.taskTip:setOpacity(0)
		self.taskTip:setPositionX(G_VisibleSizeWidth - 10)
		local lb=tolua.cast(self.taskTip:getChildByTag(100),"CCLabelTTF")
		lb:setOpacity(0)
		local circleBg=tolua.cast(self.background:getChildByTag(316),"CCSprite")
		circleBg:setVisible(false)
		local tipMv=tolua.cast(self.taskTip:getChildByTag(101),"CCScale9Sprite")
		local descLb=tolua.cast(tipMv:getChildByTag(200),"CCLabelTTF")
		descLb:setString(getlocal("serverWarLocal_taskComplete"))
		local moveShow=CCMoveTo:create(0.5,CCPointMake(self.taskTip:getContentSize().width - 420,-35))
		local delay=CCDelayTime:create(5)
		local moveHide=CCMoveTo:create(0.5,ccp(2*self.taskTip:getContentSize().width + 10,-35))
		local function callback()
			self.taskTip:setVisible(false)
		end
		local callfunc=CCCallFunc:create(callback)
		local acArr=CCArray:create()
		acArr:addObject(moveShow)
		acArr:addObject(delay)
		acArr:addObject(moveHide)
		acArr:addObject(callfunc)
		local seq=CCSequence:create(acArr)
		tipMv:runAction(seq)
	else
		self.taskTip:setOpacity(255)
		self.taskTip:setPositionX(G_VisibleSizeWidth - 10)
		local lb=tolua.cast(self.taskTip:getChildByTag(100),"CCLabelTTF")
		lb:setOpacity(255)
		self.taskTip:setVisible(true)
		local tipMv=tolua.cast(self.taskTip:getChildByTag(101),"CCScale9Sprite")
		local moveShow=CCMoveTo:create(0.5,CCPointMake(self.taskTip:getContentSize().width - 420,-35))
		local delay=CCDelayTime:create(5)
		local moveHide=CCMoveTo:create(0.5,ccp(2*self.taskTip:getContentSize().width + 10,-35))
		local acArr=CCArray:create()
		acArr:addObject(moveShow)
		acArr:addObject(delay)
		acArr:addObject(moveHide)
		local seq=CCSequence:create(acArr)
		tipMv:runAction(seq)
		local circleBg=tolua.cast(self.background:getChildByTag(316),"CCSprite")
		circleBg:setVisible(true)
	end
end

function serverWarLocalMapScene:checkTickRevive()
	if(self.troopTip==nil)then
		do return end
	end
	for troopID,troopVo in pairs(self.troops) do
		local leftTime=troopVo.canMoveTime - base.serverTime
		local deadLb=self.troopTip:getChildByTag(100 + troopID)
		if(deadLb)then
			deadLb=tolua.cast(deadLb,"CCLabelTTF")
		end
		if(leftTime>0 and deadLb)then
			deadLb:setString(GetTimeStr(troopVo.canMoveTime - base.serverTime))
		elseif(leftTime<=0 and deadLb)then
			deadLb:removeFromParentAndCleanup(true)
		end
	end
end

function serverWarLocalMapScene:checkShowMask()
	if self.groupId and self.groupId=="a" and serverWarLocalFightVoApi:isBGroupBattleing()==true then --如果是a组的话在b组战斗中则关闭地图面板
		self:close()
		do return end
	end
	if(base.serverTime<serverWarLocalFightVoApi:getStartTime() or serverWarLocalFightVoApi:checkIsEnd())then
		if(self.beginMask==nil)then
			self.beginMask=CCLayer:create()
			self.bgLayer:addChild(self.beginMask,4)
			local function nilFunc( ... )
			end
			local blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
			blackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
			blackBg:setAnchorPoint(ccp(0,0))
			blackBg:setTouchPriority(-(self.layerNum-1)*20-6)
			blackBg:setIsSallow(true)
			self.beginMask:addChild(blackBg)
			local startLb1
			if(serverWarLocalFightVoApi:checkIsEnd())then
				startLb1=GetTTFLabelWrap(getlocal("serverWarLocal_status_6"),28,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			else
				startLb1=GetTTFLabelWrap(getlocal("serverwar_battleCountDown"),28,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			end
			startLb1:setColor(G_ColorYellowPro)
			startLb1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 20))
			self.beginMask:addChild(startLb1,1)
			local startLb2=GetTTFLabel(GetTimeStr(serverWarLocalFightVoApi:getStartTime() - base.serverTime),32)
			if(serverWarLocalFightVoApi:checkIsEnd())then
				startLb2:setVisible(false)
			end
			startLb2:setTag(316)
			startLb2:setColor(G_ColorYellowPro)
			startLb2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 25))
			self.beginMask:addChild(startLb2,1)
		else
			local startLb2=tolua.cast(self.beginMask:getChildByTag(316),"CCLabelTTF")
			if(startLb2)then
				local countDown=serverWarLocalFightVoApi:getStartTime() - base.serverTime
				startLb2:setString(GetTimeStr(countDown))
				if(countDown<=10)then
					local scaleTo1=CCScaleTo:create(0.4, 1.2)
					local scaleTo2=CCScaleTo:create(0.4, 1)
					local acArr=CCArray:create()
					acArr:addObject(scaleTo1)
					acArr:addObject(scaleTo2)
					local seq=CCSequence:create(acArr)
					startLb2:runAction(seq)
				end
			end
		end
	else
		if(self.beginMask)then
			self.beginMask=tolua.cast(self.beginMask,"CCLayer")
			if self.beginMask then
				self.beginMask:removeFromParentAndCleanup(true)
				self.beginMask=nil
			end
		end
		if(self.gemBtn)then
			self.gemBtn=tolua.cast(self.gemBtn,"CCSprite")
			if self.gemBtn then
				self.gemBtn:removeFromParentAndCleanup(true)
				self.gemBtn=nil
			end
		end
	end
end

function serverWarLocalMapScene:revive(troopID)
	if self.troops and self.troops[troopID] and self.troops[troopID].canMoveTime then
		local reviveTime=self.troops[troopID].canMoveTime
		local function reviveCallback()
		end
		serverWarLocalFightVoApi:showRepairDialog(troopID,reviveTime,self.layerNum+1,reviveCallback)
	end
end

function serverWarLocalMapScene:showOrder(order)
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

function serverWarLocalMapScene:initChat()
	local chatBg,chatMenu=G_initChat(self.bgLayer,self.layerNum,true,3,16,self.functionBarHeight)
	chatBg:setTouchPriority(-(self.layerNum-1)*20-8)
	chatBg:setIsSallow(true)
	chatMenu:setTouchPriority(-(self.layerNum-1)*20-8)
	self.chatBg=chatBg
end

function serverWarLocalMapScene:tick()
	if self.bgLayer==nil then
		do return end
	end
	if self.chatBg then
		G_setLastChat(self.chatBg,false,3,16)
	end
	self:checkShowMask()
	if(base.serverTime>=serverWarLocalFightVoApi:getStartTime() - 300 and self.gemBtn)then
		self.gemBtn=tolua.cast(self.gemBtn,"CCSprite")
		if(self.gemBtn)then
			self.gemBtn:removeFromParentAndCleanup(true)
			self.gemBtn=nil
		end
	end
	if(base.serverTime<serverWarLocalFightVoApi:getStartTime() or serverWarLocalFightVoApi:checkIsEnd())then
		do return end
	end
	local leftTime=serverWarLocalFightVoApi:getStartTime() + serverWarLocalCfg.maxBattleTime - base.serverTime
	local totalTime=serverWarLocalCfg.maxBattleTime
	if self.countDownLb and self.countDownProgress then
		self.countDownLb:setString(GetTimeStr(serverWarLocalFightVoApi:getStartTime() + serverWarLocalCfg.maxBattleTime - base.serverTime))
		self.countDownProgress:setPercentage(leftTime/totalTime*100)
	end
	-- print("nextbattletime,serverTime,leftTime-----????",serverWarLocalFightVoApi:getNextBattleTime(),base.serverTime,math.max(serverWarLocalFightVoApi:getNextBattleTime() - base.serverTime,0))
	local roundLeftTime=math.max(serverWarLocalFightVoApi:getNextBattleTime() - base.serverTime,0)
	if self.battleCDLb and self.battleCDProgress then
		self.battleCDLb:setString(roundLeftTime)
		self.battleCDProgress:setPercentage(roundLeftTime/20*100)
	end
	if(self.player and self.player.canMoveTime>base.serverTime)then
		self:checkTickRevive(true)
	else
		self:checkTickRevive(false)
	end
	if(self.taskTip)then
		local lb=tolua.cast(self.taskTip:getChildByTag(100),"CCLabelTTF")
		lb:setString(GetTimeStr(self.taskExpireTime - base.serverTime))
		if(self.taskExpireTime<=base.serverTime and self.taskCompleteTime==nil)then
			self.taskTip:setVisible(false)
			local circleBg=tolua.cast(self.background:getChildByTag(316),"CCSprite")
			circleBg:setVisible(false)
		end
	end
	-- 判断是否战斗结算
	if roundLeftTime<=5 and roundLeftTime>0 then
		self:showWaitingSettlementView() --显示结算等待动画
	else
		self:hideWaitingSettlementView() --隐藏结算等待动画
	end
end

--显示等待结算的页面
function serverWarLocalMapScene:showWaitingSettlementView()
	if self.waitingLayer and tolua.cast(self.waitingLayer,"LuaCCScale9Sprite") then
		self.waitingLayer:setPosition(getCenterPoint(self.bgLayer))
		self.waitingLayer:setVisible(true)
		do return end
	end
    local waitingLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    waitingLayer:setTouchPriority(-(self.layerNum-1)*20-12)
    waitingLayer:setContentSize(rect)
    waitingLayer:setOpacity(255*0.8)
    waitingLayer:setPosition(getCenterPoint(self.bgLayer))
    waitingLayer:setIsSallow(true)
    self.bgLayer:addChild(waitingLayer,10)
    self.waitingLayer=waitingLayer

	local bgWidth,bgHeight=660,428
	local tankBodyPos=ccp(469.5,151.5)
	local paotouPos1,paotouPos2=ccp(406.5,299),ccp(442.5,267)
	local linePos=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-500)
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("swlocal_yellowline.png",CCRect(1,1,1,1),function () end)
    lineSp:setContentSize(CCSizeMake(640,3))
    lineSp:setPosition(linePos)
    self.waitingLayer:addChild(lineSp,15)
    local lineSp=CCSprite:createWithSpriteFrameName("swlocal_sqlitlight.png")
    lineSp:setPosition(linePos)
    self.waitingLayer:addChild(lineSp,16)
    -- 添加切割层
    local clipperSize=CCSizeMake(bgWidth,G_VisibleSizeHeight-lineSp:getPositionY())
    local clipper=CCClippingNode:create()
    clipper:setContentSize(clipperSize)
    clipper:setAnchorPoint(ccp(0.5,0))
    clipper:setPosition(lineSp:getPosition())
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil)
    waitingLayer:addChild(clipper)

	local waitingBg=CCNode:create()
	waitingBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
	waitingBg:setAnchorPoint(ccp(0.5,0.5))
	waitingBg:setPosition(clipperSize.width/2,clipperSize.height/2-(clipperSize.height-bgHeight))
    clipper:addChild(waitingBg)
	local bgPos=ccp(waitingBg:getPosition())

	local waitingUpBg=CCSprite:createWithSpriteFrameName("swlocal_waitingup.png")
	waitingUpBg:setPosition(330,101.5)
	waitingBg:addChild(waitingUpBg,8)
	local function getWaitingBg(sprite)
		if self and self.waitingLayer and tolua.cast(self.waitingLayer,"LuaCCScale9Sprite")  and sprite then
			sprite:setAnchorPoint(ccp(0.5,0.5))
			sprite:setPosition(330,219.5)
			waitingBg:addChild(sprite,1)
		end
	end
	serverWarLocalVoApi:getSettlementWaitingSprite(getWaitingBg)
	local tankBodySp=CCSprite:createWithSpriteFrameName("swlocal_tankbody.png")
	tankBodySp:setPosition(tankBodyPos)
	waitingBg:addChild(tankBodySp,3)
	local bodyLightSp=CCSprite:createWithSpriteFrameName("swlocal_tankbodylight.png")
	bodyLightSp:setPosition(tankBodyPos)
	bodyLightSp:setOpacity(0)
	waitingBg:addChild(bodyLightSp,4)
	local tankPaotouSp=CCSprite:createWithSpriteFrameName("swlocal_paotou.png")
	tankPaotouSp:setPosition(paotouPos1)
	waitingBg:addChild(tankPaotouSp,2)
	local firekouSp=CCSprite:createWithSpriteFrameName("swlocal_firekou.png")
	firekouSp:setPosition(13,tankPaotouSp:getContentSize().height-15)
	firekouSp:setOpacity(0)
	tankPaotouSp:addChild(firekouSp)

	local paotouAcArr=CCArray:create()
	local moveTo1=CCMoveTo:create(0.2,paotouPos2)
	local function fire()
	    local fire=CCParticleSystemQuad:create("scene/loadingEffect/fire.plist")
	    if fire then
	        fire:setAutoRemoveOnFinish(true)
	        fire:setPositionType(kCCPositionTypeFree)
	        local firePosX,firePosY=tankPaotouSp:getPosition()
	        firePosX,firePosY=firePosX-100,firePosY+40
	        fire:setPosition(firePosX,firePosY)
	        -- fire:setScale(scale or 1)
	        fire:setRotation(-50 or 0)
	        waitingBg:addChild(fire,2)
	    end
     	-- PlayEffect(audioCfg.tank_2)

     	--坦克身体高亮动作
     	local bodyAcArr=CCArray:create()
     	local function light()
     		bodyLightSp:setOpacity(255)
     	end
     	local function removeLight()
     		bodyLightSp:setOpacity(0)
     	end
     	local lightFunc=CCCallFunc:create(light)
     	local removeLightFunc=CCCallFunc:create(removeLight)
     	local fadeOut=CCFadeOut:create(0.2)
     	bodyAcArr:addObject(lightFunc)
     	bodyAcArr:addObject(CCDelayTime:create(0.2))
     	bodyAcArr:addObject(fadeOut)
     	bodyAcArr:addObject(removeLightFunc)
     	local lightAc=CCSequence:create(bodyAcArr)
     	bodyLightSp:runAction(lightAc)

     	--开炮炮口效果
     	local function showFirekou()
     		firekouSp:setOpacity(255)
     	end
     	local firekouFunc=CCCallFunc:create(showFirekou)
     	local fadeIn=CCFadeOut:create(1.5)
     	firekouSp:runAction(CCSequence:createWithTwoActions(firekouFunc,fadeIn))

     	--开炮震动效果
	    local shakeAcArr=CCArray:create()
	    for i=1,5 do
	      local rndx=15-(deviceHelper:getRandom()/100)*30
	      local rndy=15-(deviceHelper:getRandom()/100)*30
	      rndx,rndy=math.abs(rndx),-(math.abs(rndy))
	      local moveTo1=CCMoveTo:create(0.02,ccp(rndx+bgPos.x,rndy+bgPos.y))
	      local moveTo2=CCMoveTo:create(0.02,ccp(-rndx+bgPos.x,-rndy+bgPos.y))
	      shakeAcArr:addObject(moveTo1)
	      shakeAcArr:addObject(moveTo2)
	    end
	    local function resetPos()
	       waitingBg:setPosition(bgPos)
	    end
	    local funcall=CCCallFunc:create(resetPos)
	    shakeAcArr:addObject(funcall)
	    local shakeSeq=CCSequence:create(shakeAcArr)
	    waitingBg:runAction(shakeSeq)
	end
	local fireFunc=CCCallFunc:create(fire)
	local moveTo2=CCMoveTo:create(0.2,paotouPos1)
	paotouAcArr:addObject(moveTo1)
	paotouAcArr:addObject(fireFunc)
	paotouAcArr:addObject(moveTo2)
	paotouAcArr:addObject(CCDelayTime:create(2))
	local seq=CCSequence:create(paotouAcArr)
	local paotouAc=CCRepeatForever:create(seq)
	tankPaotouSp:runAction(paotouAc)

	local promptLb=GetTTFLabelWrap(getlocal("serverwarlocal_settlement_pro"),30,CCSizeMake(600,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	promptLb:setPosition(linePos.x,linePos.y-100)
	waitingLayer:addChild(promptLb,10)
end

function serverWarLocalMapScene:hideWaitingSettlementView()
	if self and self.waitingLayer and tolua.cast(self.waitingLayer,"LuaCCScale9Sprite") then
		self.waitingLayer:setPosition(ccp(-9999,-9999))
		self.waitingLayer:setVisible(false)
	end
end

function serverWarLocalMapScene:close()
	eventDispatcher:removeEventListener("serverWarLocal.battle",self.eventListener)
	self.eventListener=nil
	base:removeFromNeedRefresh(self)
	self.layerNum=nil
	self.fireList=nil
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.firstOldPos=nil
	self.secondOldPos=nil
	self.touchArr=nil
	self.isShow=false
	self.chatBg=nil
	self.roadList=nil
	self.cityList=nil
	self.cityStatusList=nil
	self.beginMask=nil
	self.functionBar=nil
	self.arrow=nil
	self.showTime=nil
	self.mapIndex=nil
	self.mapCfg=nil
	self.troops=nil
	self.troopIcons=nil
	self.troopTip=nil
	self.selectedTroopID=nil
	self.troopAlerts=nil
	self.taskTip=nil
	self.orderTipList=nil
	self.taskExpireTime=0
	self.taskCompleteTime=0
	self.gemBtn=nil
	self.waitingLayer=nil
	self.selfTroopsTags=nil
	self.groupId=nil
	self.countDownProgress=nil
	self.countDownLb=nil
	self.battleCDLb=nil
	self.battleCDProgress=nil
	spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
	spriteController:removePlist("public/serverWarLocal/serverWarLocalCity.plist")
	spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
	spriteController:removeTexture("public/serverWarLocal/serverWarLocalCity.png")
	spriteController:removeTexture("public/serverWarLocal/serverWarLocalMapBg.jpg")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
	if(platWarVoApi==nil or platWarVoApi:checkStatus()==0)then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
	end
	spriteController:removePlist("public/serverWarLocal/swlocal_waiting.plist")
	spriteController:removeTexture("public/serverWarLocal/swlocal_waiting.png")
end