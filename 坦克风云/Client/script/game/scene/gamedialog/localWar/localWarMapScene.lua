--区域战战场场景
localWarMapScene=
{
	bgLayer=nil,
	clayer=nil,
	background=nil,
	minScale=1,
	maxScale=2,
	isShow=false,
	chatBg=nil,
	arrow=nil,
}

function localWarMapScene:show(layerNum)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWarCityIcon.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWarFire.plist")
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.touchArr={}
	self:initBackground()
	self:initFunctionBar()
	self:initMap()
	self:initChat()
	self:initPlayer()
	self:checkShowMask()
	self.isShow=true
	self.showTime=base.serverTime
	sceneGame:addChild(self.bgLayer,self.layerNum)
	base:addNeedRefresh(self)
	local function eventListener(event,data)
		self:dealEvent(event,data)
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("localWar.battle",eventListener)
	base.allShowedCommonDialog=base.allShowedCommonDialog+1
	table.insert(base.commonDialogOpened_WeakTb,self)
end

function localWarMapScene:initBackground()
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(touchDialogBg)

	self:initTitle()
	local mapBg=CCSprite:create("public/localWar/localWarMapScene.jpg")
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

function localWarMapScene:initTitle()
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
	local leftTime=localWarFightVoApi.startTime + localWarCfg.maxBattleTime - base.serverTime
	local totalTime=localWarCfg.maxBattleTime
	self.countDownProgress:setPercentage(leftTime/totalTime*100)
	self.bgLayer:addChild(self.countDownProgress,4)
	self.countDownLb=GetTTFLabel(GetTimeStr(localWarFightVoApi.startTime + localWarCfg.maxBattleTime - base.serverTime),22)
	self.countDownLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 30))
	self.bgLayer:addChild(self.countDownLb,4)
	

	self.battleCDProgress=CCProgressTimer:create(CCSprite:create("public/tankLoadingBar.png"))
	self.battleCDProgress:setScaleX(360/self.battleCDProgress:getContentSize().width)
	self.battleCDProgress:setType(kCCProgressTimerTypeBar)
	self.battleCDProgress:setMidpoint(ccp(0,0))
	self.battleCDProgress:setBarChangeRate(ccp(1,0))
	self.battleCDProgress:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 60))
	self.battleCDProgress:setPercentage(math.max(localWarFightVoApi:getNextBattleTime() - base.serverTime,0)/20*100)
	self.bgLayer:addChild(self.battleCDProgress,4)
	if(base.serverTime<localWarFightVoApi.startTime)then
		self.battleCDLb=GetTTFLabel(localWarCfg.cdTime,22)
	else
		self.battleCDLb=GetTTFLabel(math.max(localWarFightVoApi:getNextBattleTime() - base.serverTime,0),22)
	end
	self.battleCDLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 60))
	self.bgLayer:addChild(self.battleCDLb,4)

	local function showInfo()
		if(base.serverTime<localWarFightVoApi.startTime)then
			do return end
		end
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("local_war_hpTip"),"\n"}
		local tabColor ={nil,G_ColorYellowPro,nil}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
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

function localWarMapScene:initFunctionBar()
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

	local functionBarCenter=CCSprite:createWithSpriteFrameName("localWar_functionBarCenter.png")
	functionBarCenter:setAnchorPoint(ccp(0.5,0))
	functionBarCenter:setPosition(ccp(G_VisibleSizeWidth/2,0))
	functionBarBg:addChild(functionBarCenter)

	local function onSetTroops()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if(localWarFightVoApi:checkBaseBlock())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4202"),30)
			do return end
		end
		localWarVoApi:showTroopsDialog(self.layerNum+1)
	end
	local setTroopsItem=GetButtonItem("mainBtnTeam.png","mainBtnTeam_Down.png","mainBtnTeam_Down.png",onSetTroops,nil,nil,nil)
	local setTroopsBtn=CCMenu:createWithItem(setTroopsItem)
	setTroopsBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	setTroopsBtn:setPosition(ccp(G_VisibleSizeWidth/8,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(setTroopsBtn)
	if(self.player==nil)then
		local troopAlert=CCSprite:createWithSpriteFrameName("IconTip.png")
		troopAlert:setAnchorPoint(CCPointMake(1,0.5))
		troopAlert:setPosition(ccp(G_VisibleSizeWidth/8 + 50,self.functionBarHeight/2 + 30))
		troopAlert:setTag(101)
		functionBarBg:addChild(troopAlert)
	end
	local setTroopsLb=GetTTFLabel(getlocal("fleetInfoTitle2"),25)
	setTroopsLb:setColor(G_ColorGreen)
	setTroopsLb:setPosition(ccp(G_VisibleSizeWidth/8,20))
	functionBarBg:addChild(setTroopsLb)

	local function onAlliance()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

        localWarVoApi:showAllianceDialog(self.layerNum+1)
	end
	local allianceItem=GetButtonItem("mainBtnFireware.png","mainBtnFireware_Down.png","mainBtnFireware_Down.png",onAlliance,nil,nil,nil)
	local allianceBtn=CCMenu:createWithItem(allianceItem)
	allianceBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	allianceBtn:setPosition(ccp(G_VisibleSizeWidth*2/7,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(allianceBtn)
	local allianceLb=GetTTFLabel(getlocal("alliance_list_scene_name"),25)
	allianceLb:setColor(G_ColorGreen)
	allianceLb:setPosition(ccp(G_VisibleSizeWidth*2/7,20))
	functionBarBg:addChild(allianceLb)

	local function onMiniMap()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:showMiniMap()
	end
	local miniMapItem=GetButtonItem("miniMapBtn.png","miniMapBtn_down.png","miniMapBtn_down.png",onMiniMap,nil,nil,nil)
	local miniMapBtn=CCMenu:createWithItem(miniMapItem)
	miniMapBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	miniMapBtn:setPosition(ccp(G_VisibleSizeWidth/2,functionBarCenter:getContentSize().height/2))
	functionBarBg:addChild(miniMapBtn)

	local function onReport()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

        localWarVoApi:showReportDialog(self.layerNum+1)
	end
	local reportItem=GetButtonItem("mainBtnMail.png","mainBtnMail_Down.png","mainBtnMail_Down.png",onReport,nil,nil,nil)
	local reportBtn=CCMenu:createWithItem(reportItem)
	reportBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	reportBtn:setPosition(ccp(G_VisibleSizeWidth*5/7,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(reportBtn)
	local reportLb=GetTTFLabel(getlocal("allianceWar_battleReport"),25)
	reportLb:setColor(G_ColorGreen)
	reportLb:setPosition(ccp(G_VisibleSizeWidth*5/7,20))
	functionBarBg:addChild(reportLb)
	self.tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp:setAnchorPoint(CCPointMake(1,0.5))
	self.tipSp:setPosition(ccp(reportItem:getContentSize().width,reportItem:getContentSize().height-15))
	self.tipSp:setVisible(false)
	reportItem:addChild(self.tipSp)

	local function onDetail()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		-- localWarVoApi:showHelpDialog(self.layerNum+1)
		localWarVoApi:showDetailDialog(self.layerNum+1)
	end
	local detailItem=GetButtonItem("mainBtnHelp.png","mainBtnHelp_Down.png","mainBtnHelp_Down.png",onDetail,nil,nil,nil)
	local detailBtn=CCMenu:createWithItem(detailItem)
	detailBtn:setTouchPriority(-(self.layerNum-1)*20-8)
	detailBtn:setPosition(ccp(G_VisibleSizeWidth*7/8,self.functionBarHeight/2 + 10))
	functionBarBg:addChild(detailBtn)
	local detailLb=GetTTFLabel(getlocal("playerInfo"),25)
	detailLb:setColor(G_ColorGreen)
	detailLb:setPosition(ccp(G_VisibleSizeWidth*7/8,20))
	functionBarBg:addChild(detailLb)
end

function localWarMapScene:touchEvent(fn,x,y,touch)
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

function localWarMapScene:checkBound(pos)
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
	if tmpPos.y>=0 then
		tmpPos.y=0
	elseif tmpPos.y<G_VisibleSizeHeight - self.titleHeight - self.background:boundingBox().size.height then
		tmpPos.y=G_VisibleSizeHeight - self.titleHeight - self.background:boundingBox().size.height
	end
	if(base.serverTime>localWarFightVoApi.startTime and self.player and self.playerIcon)then
		local iconX,iconY=self.playerIcon:getPosition()
		local size=self.playerIcon:getContentSize()
		if(iconX+tmpPos.x<-size.width/2 or iconX+tmpPos.x>G_VisibleSizeWidth+size.width/2 or iconY+tmpPos.y<self.functionBarHeight-size.height or iconY+tmpPos.y>G_VisibleSizeHeight-self.titleHeight)then
			if(self and self.arrow==nil)then
				self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
				self.arrowLength=self.arrow:getContentSize().height/2
				self.bgLayer:addChild(self.arrow,1)
			end
			if(self.arrow and tolua.cast(self.arrow,"CCSprite"))then
				local centerX=G_VisibleSizeWidth/2
				local centerY=(G_VisibleSizeHeight - self.titleHeight)/2 + self.functionBarHeight - size.height
				iconX=iconX+tmpPos.x
				iconY=iconY+tmpPos.y
				local arrowX,arrowY
				local angle
				if(iconX==centerX)then
					arrowX=G_VisibleSizeWidth/2
					if(iconY>centerY)then
						angle=-90
						arrowY=G_VisibleSizeHeight-self.titleHeight-self.arrowSize.height/2
					else
						angle=90
						arrowY=self.functionBarHeight+60+self.arrowLength
					end
				else
					angle=-math.deg(math.atan((iconY - centerY)/(iconX - centerX)))
					if(iconX<centerX)then
						angle=180 + angle
						arrowX=self.arrowLength
						arrowY=centerY + math.tan(math.rad(angle))*(G_VisibleSizeWidth/2 - self.arrowLength)
						if(arrowY>G_VisibleSizeHeight - self.titleHeight - self.arrowLength)then
							arrowY=G_VisibleSizeHeight - self.titleHeight - self.arrowLength
							arrowX=centerX - 1/math.abs(math.tan(math.rad(angle)))*(G_VisibleSizeHeight - self.titleHeight - self.arrowLength - centerY)
						elseif(arrowY<self.functionBarHeight+60+self.arrowLength)then
							arrowY=self.functionBarHeight+60+self.arrowLength
							arrowX=centerX - 1/math.abs(math.tan(math.rad(angle)))*(G_VisibleSizeHeight - self.titleHeight - self.arrowLength - centerY)
						end
						if(arrowX<self.arrowLength)then
							arrowX=self.arrowLength
						end
					else
						arrowX=G_VisibleSizeWidth - self.arrowLength
						arrowY=centerY - math.tan(math.rad(angle))*(G_VisibleSizeWidth/2 - self.arrowLength)
						if(arrowY>G_VisibleSizeHeight - self.titleHeight - self.arrowLength)then
							arrowY=G_VisibleSizeHeight - self.titleHeight - self.arrowLength
							arrowX=centerX + 1/math.abs(math.tan(math.rad(angle)))*(G_VisibleSizeHeight - self.titleHeight - self.arrowLength - centerY)
						elseif(arrowY<self.functionBarHeight+60+self.arrowLength)then
							arrowY=self.functionBarHeight+60+self.arrowLength
							arrowX=centerX + 1/math.abs(math.tan(math.rad(angle)))*(G_VisibleSizeHeight - self.titleHeight - self.arrowLength - centerY)
						end
						if(arrowX>G_VisibleSizeWidth - self.arrowLength)then
							arrowX=G_VisibleSizeWidth - self.arrowLength
						end
					end
				end
				angle=angle - 90
				self.arrow:setVisible(true)
				self.arrow:setRotation(angle)
				self.arrow:setPosition(ccp(arrowX,arrowY))
			end
		else
			if(self.arrow and tolua.cast(self.arrow,"CCSprite"))then
				self.arrow:setVisible(false)
			end
		end
	end
	if pos==nil then
		self.clayer:setPosition(tmpPos)
	else
		return tmpPos
	end
end

function localWarMapScene:initMap()
	--摆城市
	local cityBatchNode
	cityBatchNode=CCSpriteBatchNode:create("public/localWar/localWarCityIcon.png",21)
	self.background:addChild(cityBatchNode,2)
	local function onClickCity(object,name,tag)
		if(self.isMoved)then
			do return end
		end
		if(base.serverTime<localWarFightVoApi.startTime)then
			do return end
		end
		local cityID = "a"..tag
		localWarFightVoApi:showCityDialog(cityID,self.layerNum + 1)
	end
	self.cityList=localWarFightVoApi:getCityList()
	self.iconList={}
	self.hpList={}
	self.nameList={}

	for k,v in pairs(self.cityList) do
		local cityIcon=LuaCCSprite:createWithSpriteFrameName(v.cfg.icon,onClickCity)
		if(v.cfg.pos[1]>self.mapSize.width/2)then
			cityIcon:setFlipX(true)
		end
		cityIcon:setTouchPriority(-(self.layerNum-1)*20-2)
		cityIcon:setTag(tonumber(string.sub(v.id,2)))
		cityIcon:setPosition(ccp(v.cfg.pos[1],v.cfg.pos[2]))
		cityBatchNode:addChild(cityIcon,2)

		local cityNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),onClickCity)
		cityNameBg:setPosition(v.cfg.pos[1],v.cfg.pos[2] - 70)
		local cityNameLb
		local isHome=false
		local homeBaseID
		for baseID,homeID in pairs(localWarMapCfg.homeID) do
			if(homeID==k)then
				isHome=true
				homeBaseID=baseID
				break
			end
		end
		if(isHome and self.cityList[homeBaseID]:isDestroyed())then
			cityNameLb=GetTTFLabelWrap(getlocal("local_war_destroyed"),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		else
			cityNameLb=GetTTFLabelWrap(getlocal("local_war_cityName_"..v.id),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		end
		cityNameBg:setContentSize(CCSizeMake(cityNameLb:getContentSize().width + 10,cityNameLb:getContentSize().height + 10))
		cityNameLb:setPosition(getCenterPoint(cityNameBg))
		cityNameBg:addChild(cityNameLb)
		self.background:addChild(cityNameBg,3)
		self.nameList[k]=cityNameLb
		local buffIconName
		if(v.cfg.type==1)then
			buffIconName="localWar_buff_base.png"
		elseif(v.cfg.type==3)then
			buffIconName="localWar_buff_captital.png"
		else
			buffIconName="localWar_buff"
			for buffID,buffValue in pairs(v.cfg.buff) do
				buffIconName=buffIconName.."_"..buffID
			end
			buffIconName=buffIconName..".png"
		end
		if(v.cfg.type==1 or v.cfg.type==3)then
			local progressBg=CCSprite:createWithSpriteFrameName("TimeBg.png")
			progressBg:setScaleX(155/progressBg:getContentSize().width)
			progressBg:setScaleY(21/progressBg:getContentSize().height)
			progressBg:setPosition(ccp(v.cfg.pos[1],v.cfg.pos[2] - 42))
			self.background:addChild(progressBg,3)
			local hpProgress=CCProgressTimer:create(CCSprite:createWithSpriteFrameName("AllXpBar.png"))
			hpProgress:setType(kCCProgressTimerTypeBar)
			hpProgress:setMidpoint(ccp(0,0))
			hpProgress:setBarChangeRate(ccp(1,0))
			hpProgress:setScaleX(150/hpProgress:getContentSize().width)
			hpProgress:setScaleY(17/hpProgress:getContentSize().height)
			hpProgress:setPosition(ccp(v.cfg.pos[1],v.cfg.pos[2] - 42))
			hpProgress:setPercentage(v:getHp()/v:getMaxHp()*100)
			self.background:addChild(hpProgress,4)
			self.hpList[k]=hpProgress
		end
		local cityBuffIcon=CCSprite:createWithSpriteFrameName(buffIconName)
		if(cityBuffIcon)then
			cityBuffIcon:setScale(0.6)
			if(v.cfg.type==2)then
				cityBuffIcon:setPosition(v.cfg.pos[1] - cityNameBg:getContentSize().width/2 - 20,v.cfg.pos[2] - 70)
			else
				cityBuffIcon:setPosition(v.cfg.pos[1] - cityNameBg:getContentSize().width/2 - 20,v.cfg.pos[2] - 60)
			end
			self.background:addChild(cityBuffIcon,5)
			local border
			if(localWarFightVoApi:getDefenderAlliance() and v.allianceID==localWarFightVoApi:getDefenderAlliance().id)then
				border=CCSprite:createWithSpriteFrameName("localWar_border99.png")
			elseif(v.allianceID==0)then
				border=CCSprite:createWithSpriteFrameName("localWar_border0.png")
			else
				for key,allianceVo in pairs(localWarFightVoApi:getAllianceList()) do
					if(allianceVo.id==v.allianceID)then
						border=CCSprite:createWithSpriteFrameName("localWar_border"..allianceVo.side..".png")
						break
					end
				end
			end
			if(border)then
				border:setTag(316)
				border:setScale(cityBuffIcon:getContentSize().width/border:getContentSize().width)
				border:setAnchorPoint(ccp(0,0))
				border:setPosition(ccp(0,0))
				cityBuffIcon:addChild(border)
			end
		end
		self.iconList[k]=cityBuffIcon
	end
	--画道路
	-- self.roadBatchNode=CCSpriteBatchNode:create("serverWar/serverWar2.pvr.ccz",150)
	-- self.background:addChild(self.roadBatchNode,1)
	-- local connectTb={}
	-- local testSprite=CCSprite:createWithSpriteFrameName("highway1.png")
	-- local roadLength=testSprite:getContentSize().height
	-- for cityID,cityVo in pairs(self.cityList) do
	-- 	local posCity=cityVo.cfg.pos
	-- 	for k,nearID in pairs(cityVo.cfg.adjoin) do
	-- 		local connectKey1=cityID.."-"..nearID
	-- 		local connectKey2=nearID.."-"..cityID
	-- 		if(connectTb[connectKey1]==nil and connectTb[connectKey2]==nil)then
	-- 			connectTb[connectKey1]=1
	-- 			local posTarget=localWarMapCfg.cityCfg[nearID].pos
	-- 			local distance=self:distance(posCity,posTarget)
	-- 			local roadNum=math.ceil(distance/roadLength,0)
	-- 			local angle=math.deg(math.asin((posTarget[2] - posCity[2])/distance))
	-- 			if(posTarget[1]<posCity[1])then
	-- 				angle=180 - angle
	-- 			end
	-- 			for i=1,roadNum do
	-- 				local roadSprite=CCSprite:createWithSpriteFrameName("highway1.png")
	-- 				roadSprite:setRotation(90 - angle)
	-- 				local posX=posCity[1] + (i - 1)*roadLength*math.cos(math.rad(angle))
	-- 				local posY=posCity[2] + (i - 1)*roadLength*math.sin(math.rad(angle))
	-- 				roadSprite:setPosition(ccp(posX,posY))
	-- 				self.roadBatchNode:addChild(roadSprite)
	-- 			end
	-- 		end
	-- 	end
	-- end
	self:showOrder(localWarFightVoApi.order)
end

function localWarMapScene:initPlayer()
	self.player=localWarFightVoApi:getPlayer()
	if(self.player==nil)then
		do return end
	end
	local troopAlert=tolua.cast(self.functionBar:getChildByTag(101),"CCSprite")
	if(troopAlert)then
		troopAlert:removeFromParentAndCleanup(true)
	end
	-- local playerPic=CCSprite:createWithSpriteFrameName("photo"..playerVoApi:getPic()..".png")
 --    local playerPic=playerVoApi:getPersonPhotoSp(playerVoApi:getPic())
	-- playerPic:setScale(0.8)
	local playerPic=playerVoApi:getPersonPhotoSp()
	playerPic:setScale(0.8*playerPic:getScale())
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
	self.background:addChild(self.playerIcon,7)
	self:userMove()
	self:checkBound()
end

function localWarMapScene:userMove()
	if(self.player==nil)then
		do return end
	end
	local targetCity=self.cityList[self.player.cityID]
	local startCity=self.cityList[self.player.lastCityID]
	if(self.player.arriveTime<=base.serverTime or targetCity==nil or startCity==nil)then
		self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
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
		self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
		do return end
	end
	local totalNeedTime=startCity.cfg.distance[key]
	local leftTime=self.player.arriveTime - base.serverTime
	local startPosX=(targetCity.cfg.pos[1] - startCity.cfg.pos[1])*(totalNeedTime - leftTime)/totalNeedTime + startCity.cfg.pos[1]
	local startPosY=(targetCity.cfg.pos[2] - startCity.cfg.pos[2])*(totalNeedTime - leftTime)/totalNeedTime + startCity.cfg.pos[2]
	self.playerIcon:setPosition(ccp(startPosX,startPosY))
	local actionArr=CCArray:create()
	local ccmoveTo=CCMoveTo:create(leftTime,ccp(targetCity.cfg.pos[1],targetCity.cfg.pos[2]))
	actionArr:addObject(ccmoveTo)
	local function moveEnd()
		self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
	end
	local fc= CCCallFunc:create(moveEnd)
	actionArr:addObject(fc)
	local seq=CCSequence:create(actionArr)
	self.playerIcon:runAction(seq)
end

function localWarMapScene:distance(pos1,pos2)
	return math.sqrt((pos1[1]-pos2[1])*(pos1[1]-pos2[1])+(pos1[2]-pos2[2])*(pos1[2]-pos2[2]))
end

function localWarMapScene:dealEvent(event,data)
	local type=data.type
	if(type=="player")then
		for k,playerVo in pairs(data.data) do
			if(playerVo.uid==playerVoApi:getUid())then
				if(self.player==nil)then
					self.player=localWarFightVoApi:getPlayer()
					self:initPlayer()
				end
				if(playerVo.canMoveTime>base.serverTime)then
					self.playerIcon:stopAllActions()
					local targetCity=self.cityList[playerVo.cityID]
					self.playerIcon:setPosition(targetCity.cfg.pos[1],targetCity.cfg.pos[2])
					if(playerVo.lastEnemyID and playerVo.battleTime~=self.dieTipTime and playerVo.battleTime>self.showTime)then
					--因为有可能同一次死亡消息在refresh和push中重复发了请求, 所以记一个时间, 如果死亡时间相同的话就不再提示
						local enemy
						if(playerVo.lastEnemyID==-1)then
							enemy={name=getlocal("local_war_npc_name")}
						else
							enemy=localWarFightVoApi:getPlayer(playerVo.lastEnemyID)
						end
						if(enemy)then
							smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_youAreKilled",{enemy.name}),nil,self.layerNum+2)
							self.dieTipTime=playerVo.battleTime
						end
					end
				elseif(playerVo.lastEnemyID and playerVo.battleTime~=self.dieTipTime and playerVo.battleTime>self.showTime)then
					local enemy
					if(playerVo.lastEnemyID==-1)then
						enemy={name=getlocal("local_war_npc_name"),allianceName=getlocal("local_war_cityName_"..playerVo.battleCity)}
					else
						enemy=localWarFightVoApi:getPlayer(playerVo.lastEnemyID)
					end
					if(enemy)then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_tipWin",{enemy.allianceName,enemy.name}),30)
						self.dieTipTime=playerVo.battleTime
					end
				end
				break
			end
		end
	elseif(type=="city")then
		for k,cityVo in pairs(data.data) do
			if(self.iconList[cityVo.id])then
				local cityBuffIcon=self.iconList[cityVo.id]
				local border=tolua.cast(cityBuffIcon:getChildByTag(316),"CCSprite")
				if(border)then
					border:removeFromParentAndCleanup(true)
				end
				if(localWarFightVoApi:getDefenderAlliance() and cityVo.allianceID==localWarFightVoApi:getDefenderAlliance().id)then
					border=CCSprite:createWithSpriteFrameName("localWar_border99.png")
				elseif(cityVo.allianceID==0)then
					border=CCSprite:createWithSpriteFrameName("localWar_border0.png")
				else
					for key,allianceVo in pairs(localWarFightVoApi:getAllianceList()) do
						if(allianceVo.id==cityVo.allianceID)then
							border=CCSprite:createWithSpriteFrameName("localWar_border"..allianceVo.side..".png")
							break
						end
					end
				end
				if(border)then
					border:setTag(316)
					border:setScale(cityBuffIcon:getContentSize().width/border:getContentSize().width)
					border:setAnchorPoint(ccp(0,0))
					border:setPosition(ccp(0,0))
					cityBuffIcon:addChild(border)
				end
				if(self.hpList[cityVo.id])then
					self.hpList[cityVo.id]:setPercentage(cityVo:getHp()/cityVo:getMaxHp()*100)
				end
				if(self.nameList[cityVo.id])then
					local isHome=false
					local homeBaseID
					for baseID,homeID in pairs(localWarMapCfg.homeID) do
						if(homeID==k)then
							isHome=true
							homeBaseID=baseID
							break
						end
					end
					if(isHome and self.cityList[homeBaseID]:isDestroyed())then
						self.nameList[cityVo.id]:setString(getlocal("local_war_destroyed"))
					end
				end
			end
		end
		if(self.miniMap)then
			self:hideMiniMap()
			self:showMiniMap()
		end
	elseif(type=="order")then
		self:showOrder(data.data)
	elseif(type=="over")then
		if(self.playerIcon)then
			self.playerIcon:stopAllActions()
		end
		if(self.miniMap)then
			self:hideMiniMap()
		end
		if(self.fireList)then
			for k,v in pairs(self.fireList) do
				v:stopAllActions()
				v:removeFromParentAndCleanup(true)
			end
		end
		base:removeFromNeedRefresh(self)
	end
end

function localWarMapScene:checkShowReviveBar(visible)
	if(self.player==nil)then
		do return end
	end
	if(visible)then
		if(self.reviveBar)then
			local timeLb=tolua.cast(self.reviveBar:getChildByTag(316),"CCLabelTTF")
			if(timeLb)then
				timeLb:setString(GetTimeStr(self.player.canMoveTime - base.serverTime))
			end
		end
		if(self.showReviveBar==true)then
			do return end
		end
		if(self.reviveBar==nil)then
			local function nilFunc( ... )
			end
			self.reviveBar=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
			self.reviveBar:setContentSize(CCSizeMake(G_VisibleSizeWidth,100))
			self.reviveBar:setAnchorPoint(ccp(0,1))
			self.bgLayer:addChild(self.reviveBar,2)
			local lb1=GetTTFLabel(getlocal("local_war_reviving"),25)
			lb1:setAnchorPoint(ccp(0,0.5))
			lb1:setPosition(ccp(5,75))
			self.reviveBar:addChild(lb1)
			local lb2=GetTTFLabel(GetTimeStr(self.player.canMoveTime - base.serverTime),25)
			lb2:setColor(G_ColorYellowPro)
			lb2:setTag(316)
			lb2:setAnchorPoint(ccp(0,0.5))
			lb2:setPosition(ccp(5,25))
			self.reviveBar:addChild(lb2)
			local function onRevive()
				self:revive()
			end
			local reviveItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onRevive,2,getlocal("accelerateGroup"),25)
			local reviveBtn=CCMenu:createWithItem(reviveItem)
			reviveBtn:setTouchPriority(-(self.layerNum-1)*20-6)
			reviveBtn:setPosition(ccp(G_VisibleSizeWidth - 100,50))
			self.reviveBar:addChild(reviveBtn)
		else
			self.reviveBar:stopAllActions()
		end
		self.reviveBar:setPosition(ccp(0,self.functionBarHeight))
		self.reviveBar:setVisible(true)
		local ccmoveTo=CCMoveTo:create(1,ccp(0,self.functionBarHeight + 180))
		self.reviveBar:runAction(ccmoveTo)
		self.showReviveBar=true
	elseif(visible~=true and self.showReviveBar==true)then
		if(self.reviveBar)then
			local actionArr=CCArray:create()
			local ccmoveTo=CCMoveTo:create(1,ccp(0,self.functionBarHeight))
			actionArr:addObject(ccmoveTo)
			local function moveEnd()
				self.reviveBar:setVisible(false)
			end
			local fc= CCCallFunc:create(moveEnd)
			actionArr:addObject(fc)
			local seq=CCSequence:create(actionArr)
			self.reviveBar:runAction(seq)
		end
		self.showReviveBar=false
	end
end

function localWarMapScene:checkShowMask()
	if(base.serverTime<localWarFightVoApi.startTime)then
		if(self.beginMask==nil)then
			self.beginMask=CCLayer:create()
			self.bgLayer:addChild(self.beginMask,4)
			local function nilFunc( ... )
			end
			local blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
			blackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
			blackBg:setAnchorPoint(ccp(0,0))
			self.beginMask:addChild(blackBg)
			local startLb1=GetTTFLabelWrap(getlocal("serverwar_battleCountDown"),28,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			startLb1:setColor(G_ColorYellowPro)
			startLb1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 + 20))
			self.beginMask:addChild(startLb1,1)
			local startLb2=GetTTFLabel(GetTimeStr(localWarFightVoApi.startTime - base.serverTime),32)
			startLb2:setTag(316)
			startLb2:setColor(G_ColorYellowPro)
			startLb2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 25))
			self.beginMask:addChild(startLb2,1)
		else
			local startLb2=tolua.cast(self.beginMask:getChildByTag(316),"CCLabelTTF")
			if(startLb2)then
				local countDown=localWarFightVoApi.startTime - base.serverTime
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
			self.beginMask:removeFromParentAndCleanup(true)
			self.beginMask=nil
		end
	end
end

function localWarMapScene:revive()
	-- local function onConfirm()
	-- 	local costGems=(self.player.canMoveTime - base.serverTime) + localWarCfg.reviveCost
	-- 	if(playerVoApi:getGems()<costGems)then
	-- 		local needGem=costGems - playerVoApi:getGems()
	-- 		GemsNotEnoughDialog(nil,nil,needGem,self.layerNum+1,costGems)
	-- 		do return end
	-- 	end
	-- 	localWarFightVoApi:revive()
	-- end
	-- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_reviveAndMove"),nil,self.layerNum+1)

	if self.player and self.player.canMoveTime then
	    local reviveTime=self.player.canMoveTime
	    local function reviveCallback()
	    end
	    localWarVoApi:showRepairDialog(reviveTime,self.layerNum+1,reviveCallback)
	end
end

function localWarMapScene:showOrder(order)
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
			tip:removeFromParentAndCleanup(true)
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
		self.background:addChild(tip,3)
	end
end

function localWarMapScene:showMiniMap()
	if(base.serverTime<localWarFightVoApi.startTime)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4002"),30)
		do return end
	end
	local function onHide()
		self:hideMiniMap()
	end
	if(self.miniMap)then
		self:hideMiniMap()
	end
	local layerNum=self.layerNum + 1
	self.miniMap=CCLayer:create()
	self.bgLayer:addChild(self.miniMap,2)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.miniMap:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	dialogBg:setContentSize(CCSizeMake(570,570))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.miniMap:addChild(dialogBg,1)
	local lb=GetTTFLabel(getlocal("miniMapSetting"),28)
	lb:setPosition(ccp(275,515))
	dialogBg:addChild(lb)
	local miniMap = CCSprite:createWithSpriteFrameName("localWar_miniMap.jpg")
	miniMap:setPosition(ccp(285,325))
	dialogBg:addChild(miniMap)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(570/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(285,490))
	dialogBg:addChild(lineSp,1)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(570/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(285,160))
	dialogBg:addChild(lineSp,1)
	local posScaleX=532/self.mapSize.width
	local posScaleY=333/self.mapSize.height
	local posTb={{175.5, 268},{218.5, 304.5},{325.5, 298.5},{365.5, 265},{132.5, 231.5},{229.5, 231.5},{316.5, 231.5},{423.5, 231.5},{143.5, 142.5},{218.5, 142.5},{325.5, 141.5},{412.5, 141.5},{170, 97.5},{219.5, 56.5 },{325.5, 53.5 },{377, 97.5},{267.5, 176.5},{132.5, 304.5},{405.5, 298.5},{120.5, 53.5 },{428.5, 44.5 }}
	for cityID,cityVo in pairs(self.cityList) do
		local cityPoint=CCSprite:createWithSpriteFrameName("localWar_miniMap_point.png")
		local colorTb
		if(localWarFightVoApi:getDefenderAlliance() and cityVo.allianceID==localWarFightVoApi:getDefenderAlliance().id)then
			colorTb={240, 194, 33}
		elseif(localWarFightVoApi:getAllianceList()[1] and cityVo.allianceID==localWarFightVoApi:getAllianceList()[1].id)then
			colorTb={0, 255, 255}
		elseif(localWarFightVoApi:getAllianceList()[2] and cityVo.allianceID==localWarFightVoApi:getAllianceList()[2].id)then
			colorTb={56,246,154}
		elseif(localWarFightVoApi:getAllianceList()[3] and cityVo.allianceID==localWarFightVoApi:getAllianceList()[3].id)then
			colorTb={218, 30, 214}
		elseif(localWarFightVoApi:getAllianceList()[4] and cityVo.allianceID==localWarFightVoApi:getAllianceList()[4].id)then
			colorTb={255, 50, 50}
		else
			colorTb={255,255,255}
		end
		cityPoint:setColor(ccc3(colorTb[1],colorTb[2],colorTb[3]))
		if(localWarFightVoApi:checkCityInWar(cityID))then
			--明暗交替
			local fadeOut=CCTintTo:create(1,50,50,50)
			local fadeIn=CCTintTo:create(1,colorTb[1],colorTb[2],colorTb[3])
			local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
			cityPoint:runAction(CCRepeatForever:create(seq))
		end
		local index=tonumber(string.sub(cityID,2))
		cityPoint:setPosition(ccp(posTb[index][1],posTb[index][2]))
		miniMap:addChild(cityPoint)
	end
	for i=1,6 do
		local cityPoint=CCSprite:createWithSpriteFrameName("localWar_miniMap_point.png")
		local nameLb
		if(i<6)then
			nameLb=GetTTFLabel(getlocal("local_war_miniMapName",{i}),22)
		else
			nameLb=GetTTFLabel(getlocal("local_war_cityStatus2"),22)
		end
		if(i<4)then
			cityPoint:setPosition(ccp(30 + (i-1)*177,135))
			nameLb:setPosition(ccp(50 + (i-1)*177,135))
		else
			cityPoint:setPosition(ccp(30 + (i-4)*177,85))
			nameLb:setPosition(ccp(50 + (i-4)*177,85))
		end
		if(i==1)then
			cityPoint:setColor(ccc3(0,255,255))
		elseif(i==2)then
			cityPoint:setColor(ccc3(56,246,154))
		elseif(i==3)then
			cityPoint:setColor(ccc3(218, 30, 214))
		elseif(i==4)then
			cityPoint:setColor(ccc3(255, 50, 50))
		elseif(i==5)then
			cityPoint:setColor(ccc3(240, 194, 33))
		end
		dialogBg:addChild(cityPoint)
		nameLb:setAnchorPoint(ccp(0,0.5))
		dialogBg:addChild(nameLb)
	end
	local descLb=GetTTFLabelWrap(getlocal("local_war_miniMapDesc"),22,CCSizeMake(520,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setColor(G_ColorYellowPro)
	descLb:setPosition(ccp(275,45))
	dialogBg:addChild(descLb)
end

function localWarMapScene:hideMiniMap()
	if(self.miniMap)then
		self.miniMap:removeFromParentAndCleanup(true)
		self.miniMap=nil
	end
end

--四个主基地向中心城市开火的动画
function localWarMapScene:baseFire()
	if(self.fireList)then
		for k,v in pairs(self.fireList) do
			v:stopAllActions()
			v:removeFromParentAndCleanup(true)
		end
	end
	self.fireList={}
	local function hitEnd()
		for k,v in pairs(self.fireList) do
			v:stopAllActions()
			v:removeFromParentAndCleanup(true)
		end
		self.fireList=nil
	end
	local function playHit()
		local containerHit=CCSprite:createWithSpriteFrameName("localWar_hit_12.png")
		containerHit:setPosition(ccp(self.cityList[localWarMapCfg.capitalID].cfg.pos[1],self.cityList[localWarMapCfg.capitalID].cfg.pos[2]))
		self.fireList[1]=containerHit
		self.background:addChild(containerHit,3)
		local hitArr=CCArray:create()
		for i=1,12 do
			local hitNameStr="localWar_hit_"..i..".png"
			local hitFrame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(hitNameStr)
			hitArr:addObject(hitFrame)
		end
		local animation=CCAnimation:createWithSpriteFrames(hitArr)
		animation:setDelayPerUnit(0.06)
		local animate=CCAnimate:create(animation)
		local callFunc=CCCallFunc:create(hitEnd)
		local acArr=CCArray:create()
		acArr:addObject(animate)
		acArr:addObject(callFunc)
		local seq=CCSequence:create(acArr)
		containerHit:runAction(seq)
	end
	local function animationEnd()
		for k,v in pairs(self.fireList) do
			v:stopAllActions()
			v:removeFromParentAndCleanup(true)
		end
		self.fireList={}
		playHit()
	end
	for k,baseID in pairs(localWarMapCfg.baseCityID) do
		if(self.cityList[baseID].allianceID~=0 and (localWarFightVoApi:getDefenderAlliance()==nil or self.cityList[baseID].allianceID~=localWarFightVoApi:getDefenderAlliance().id))then
			local container=CCSprite:createWithSpriteFrameName("localWar_hit_12.png")
			if(baseID=="a1")then
				container:setRotation(47)
				container:setPosition(ccp(self.cityList[baseID].cfg.pos[1] + 130,self.cityList[baseID].cfg.pos[2]))
			elseif(baseID=="a4")then
				container:setRotation(-120)
				container:setPosition(ccp(self.cityList[baseID].cfg.pos[1] - 130,self.cityList[baseID].cfg.pos[2] + 5))
			elseif(baseID=="a13")then
				container:setRotation(-5)
				container:setPosition(ccp(self.cityList[baseID].cfg.pos[1] + 85,self.cityList[baseID].cfg.pos[2] + 120))
			elseif(baseID=="a16")then
				container:setRotation(-60)
				container:setPosition(ccp(self.cityList[baseID].cfg.pos[1] - 80,self.cityList[baseID].cfg.pos[2] + 140))
			else
				container:setPosition(ccp(self.cityList[baseID].cfg.pos[1],self.cityList[baseID].cfg.pos[2]))
			end
			self.background:addChild(container,3)
			self.fireList[baseID]=container
			local fireArr=CCArray:create()
			for i=1,12 do
				local nameStr="localWar_fire_"..i..".png"
				local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				fireArr:addObject(frame)
			end
			local animation=CCAnimation:createWithSpriteFrames(fireArr)
			animation:setDelayPerUnit(0.06)
			local animate=CCAnimate:create(animation)
			local callFunc=CCCallFunc:create(animationEnd)
			local acArr=CCArray:create()
			acArr:addObject(animate)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			container:runAction(seq)
		end
	end
end

function localWarMapScene:initChat()
	local chatBg,chatMenu=G_initChat(self.bgLayer,self.layerNum,true,3,14,self.functionBarHeight)
	chatBg:setTouchPriority(-(self.layerNum-1)*20-8)
	chatBg:setIsSallow(true)
	chatMenu:setTouchPriority(-(self.layerNum-1)*20-8)
	self.chatBg=chatBg
end

function localWarMapScene:tick()
	self:checkShowMask()
	if(base.serverTime<localWarFightVoApi.startTime)then
		do return end
	end
	if self.chatBg then
		G_setLastChat(self.chatBg,false,3,14)
	end
	local leftTime=localWarFightVoApi.startTime + localWarCfg.maxBattleTime - base.serverTime
	local totalTime=localWarCfg.maxBattleTime
	self.countDownLb:setString(GetTimeStr(localWarFightVoApi.startTime + localWarCfg.maxBattleTime - base.serverTime))
	self.countDownProgress:setPercentage(leftTime/totalTime*100)
	self.battleCDLb:setString(math.max(localWarFightVoApi:getNextBattleTime() - base.serverTime,0))
	self.battleCDProgress:setPercentage(math.max(localWarFightVoApi:getNextBattleTime() - base.serverTime,0)/20*100)
	if(self.player and self.player.canMoveTime>base.serverTime)then
		self:checkShowReviveBar(true)
	else
		self:checkShowReviveBar(false)
	end
	if(base.serverTime%20==0)then
		self:baseFire()
	end

	if self.tipSp then
		if localWarVoApi:getIsNewReport(1)==0 or localWarVoApi:getIsNewReport(2)==0 then
			self.tipSp:setVisible(true)
		else
			self.tipSp:setVisible(false)
		end
	end
end

function localWarMapScene:close()
	if(self.miniMap)then
		self:hideMiniMap()
	end
	self.bgLayer:stopAllActions()
	eventDispatcher:removeEventListener("localWar.battle",self.eventListener)
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
	self.cityList=nil
	self.iconList=nil
	self.hpList=nil
	self.nameList=nil
	self.reviveBar=nil
	self.showReviveBar=false
	self.beginMask=nil
	self.functionBar=nil
	self.arrow=nil
	self.showTime=nil
	self.orderTipList=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWarFire.plist")
	if G_isCompressResVersion()==true then
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWarFire.png")
	else
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWarFire.pvr.ccz")
	end
	base.allShowedCommonDialog=math.max(base.allShowedCommonDialog-1,0)
	for k,v in pairs(base.commonDialogOpened_WeakTb) do
		if v==self then
			table.remove(base.commonDialogOpened_WeakTb,k)
			break
		end
	end
end