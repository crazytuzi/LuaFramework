serverWarPersonalKnockOutScene=
{
	bgLayer=nil,
	clayer=nil,
	roundBgTb=nil,
	round1Tb=nil,
	round2Tb=nil,
	round3Tb=nil,
	round4Tb=nil,
	round5Tb=nil,
	round6Tb=nil,
	round7Tb=nil,
	minScale=1,
	maxScale=1.7,
	winnerColor=ccc3(0,199,131),
	loserColor=ccc3(145,145,145),
	isShow=false,
}

function serverWarPersonalKnockOutScene:show(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.touchArr={}
	self:initTitle()
	self:initBg()
	self:initContent()
	self:initTick()
	self.isShow=true
	sceneGame:addChild(self.bgLayer,self.layerNum)
	base.allShowedCommonDialog=base.allShowedCommonDialog+1
	table.insert(base.commonDialogOpened_WeakTb,self)
end

function serverWarPersonalKnockOutScene:initTitle()
	self.titleHeight=85

	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),function ( ... )end)
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.titleHeight))
	titleBg:setPosition(ccp(0,G_VisibleSizeHeight))
	titleBg:setTouchPriority(-(self.layerNum-1)*20-8)
	self.bgLayer:addChild(titleBg,2)

	local titleLb=GetTTFLabel(getlocal("serverwar_knockoutMath"),33)
	titleLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-self.titleHeight/2))
	self.bgLayer:addChild(titleLb,2)

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
	self.bgLayer:addChild(closeBtn,3)
end

function serverWarPersonalKnockOutScene:initBg()
	local nameSize=CCSizeMake((G_VisibleSizeWidth/2-5*3)/2,45)
	self.totalHeight=(nameSize.height+5)*20
	if(self.totalHeight<G_VisibleSizeHeight-self.titleHeight)then
		self.totalHeight=G_VisibleSizeHeight-self.titleHeight
	end
	local firstBgWidth=160
	self.totalWidth=(nameSize.width+50)*7+firstBgWidth

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(touchDialogBg)
	local maskBg=CCSprite:create("story/CheckpointBg.jpg")
	maskBg:setScale(G_VisibleSizeHeight/maskBg:getContentSize().height)
	maskBg:setAnchorPoint(ccp(0.5,0))
	maskBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
	self.bgLayer:addChild(maskBg)

	self.clayer=CCLayer:create()
	self.clayer:setTouchEnabled(true)
	local function tmpHandler(...)
		return self:touchEvent(...)
	end
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
	self.clayer:setPosition(ccp(0,G_VisibleSizeHeight-self.titleHeight-self.totalHeight))
	self.bgLayer:addChild(self.clayer)
end

function serverWarPersonalKnockOutScene:touchEvent(fn,x,y,touch)
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

function serverWarPersonalKnockOutScene:checkBound(pos)
	local tmpPos
	if pos==nil then
		tmpPos= ccp(self.clayer:getPosition())
	else
		tmpPos=pos
	end
	if tmpPos.x>0 then
		tmpPos.x=0
	elseif tmpPos.x<G_VisibleSizeWidth-self.background:boundingBox().size.width then
		tmpPos.x=G_VisibleSizeWidth-self.background:boundingBox().size.width
	end
	if tmpPos.y>=0 then
		tmpPos.y=0
	elseif tmpPos.y<G_VisibleSizeHeight-self.titleHeight-self.background:boundingBox().size.height then
		tmpPos.y=G_VisibleSizeHeight-self.titleHeight-self.background:boundingBox().size.height
	end
	if pos==nil then
		self.clayer:setPosition(tmpPos)
	else
		return tmpPos
	end
end

function serverWarPersonalKnockOutScene:initContent()
	self.background=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20,20,10,10),function ( ... )end)
	self.background:setAnchorPoint(ccp(0,0))
	self.background:setContentSize(CCSizeMake(self.totalWidth,self.totalHeight))
	self.background:setPosition(ccp(0,0))
	self.clayer:addChild(self.background)

	local posX=0
	local firstBgWidth=160
	local nameSize=CCSizeMake((G_VisibleSizeWidth/2-5*3)/2,45)
	self.roundBgTb={}
	local nextRoundID
	for i=1,7 do
		local roundStatus=serverWarPersonalVoApi:getRoundStatus(i)
		if(roundStatus<30 and roundStatus>0)then
			nextRoundID=i
			break
		end
	end
	for i=1,8 do
		local darkBg = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(42, 26, 10, 10),function ( ... ) end)
		if(i==1)then
			darkBg:setContentSize(CCSizeMake(firstBgWidth,self.totalHeight))
		else
			darkBg:setContentSize(CCSizeMake(nameSize.width+50,self.totalHeight))
			self.roundBgTb[i-1]=darkBg
		end
		darkBg:setAnchorPoint(ccp(0,0))
		darkBg:setPosition(ccp(posX,0))
		self.background:addChild(darkBg,1)
		if(nextRoundID and i==nextRoundID+1)then
			local lightBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20,20,10,10),function ( ... )end)
			lightBg:setContentSize(darkBg:getContentSize())
			lightBg:setAnchorPoint(ccp(0,0))
			lightBg:setPosition(ccp(0,0))
			darkBg:addChild(lightBg)
			self.clayer:setPositionX(-posX - lightBg:getContentSize().width/2 + G_VisibleSizeWidth/2)
			self:checkBound()
		end
		posX=posX+darkBg:getContentSize().width
	end

	posX=self.roundBgTb[1]:getPositionX()
	for i=1,4 do
		local textBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(20,20,10,10),function ( ... )end)
		local width
		if(i==4)then
			width=self.roundBgTb[i*2-1]:getContentSize().width
		else
			width=self.roundBgTb[i*2-1]:getContentSize().width*2
		end
		textBg:setContentSize(CCSizeMake(width,35))
		textBg:setAnchorPoint(ccp(0,1))
		textBg:setPosition(ccp(posX,self.totalHeight))
		self.background:addChild(textBg,2)

		local battleTime=serverWarPersonalVoApi:getBattleTimeList()[i*2]
		local dateStr=G_getDataTimeStr(battleTime,true,true)
		local dateLb=GetTTFLabel(dateStr,25)
		dateLb:setPosition(ccp(textBg:getContentSize().width/2,textBg:getContentSize().height/2))
		textBg:addChild(dateLb)
		posX=posX+textBg:getContentSize().width
	end

	local winGroupLb=GetTTFLabelWrap(getlocal("serverwar_groupWin"),22,CCSizeMake(firstBgWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	winGroupLb:setColor(G_ColorYellowPro)
	winGroupLb:setPosition(ccp(firstBgWidth/2,(self.totalHeight-35)*3/4))
	self.background:addChild(winGroupLb,1)

	local lineSeperate=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSeperate:setScaleX((self.totalWidth+200)/lineSeperate:getContentSize().width)
	lineSeperate:setScaleY(1.2)
	lineSeperate:setPosition(ccp(self.totalWidth/2,(self.totalHeight-35)/2))
	self.background:addChild(lineSeperate,1)

	local failGroupLb=GetTTFLabelWrap(getlocal("serverwar_groupFail"),22,CCSizeMake(firstBgWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	failGroupLb:setColor(G_ColorYellowPro)
	failGroupLb:setPosition(ccp(firstBgWidth/2,(self.totalHeight-35)/4))
	self.background:addChild(failGroupLb,1)

	for i=1,7 do
		local posX=self.roundBgTb[i]:getPositionX()+self.roundBgTb[i]:getContentSize().width/2
		local titleStr
		if(i<7)then
			titleStr=getlocal("serverwar_roundIndex",{i})
		else
			titleStr=getlocal("serverwar_finalFight")
		end
		local roundTitle=GetTTFLabel(titleStr,21)
		roundTitle:setColor(G_ColorYellowPro)
		roundTitle:setPosition(ccp(posX,self.totalHeight-55))
		self.background:addChild(roundTitle,2)

		local battleTime=serverWarPersonalVoApi:getBattleTimeList()[i+1]
		if(battleTime)then
			battleTime=G_chatTime(battleTime)
		else
			battleTime=getlocal("alliance_info_content")
		end
		local timeLb=GetTTFLabel(battleTime,20)
		timeLb:setColor(G_ColorYellowPro)
		timeLb:setPosition(ccp(posX,self.totalHeight-85))
		self.background:addChild(timeLb,2)
	end
	self:initPlayers()
end

function serverWarPersonalKnockOutScene:initPlayers()
	self.battleList=serverWarPersonalVoApi:getKOBattleList()
	local nameSize=CCSizeMake((G_VisibleSizeWidth/2-5*3)/2,45)
	local function showPlayerInfo(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		if(tag and tag~=0)then
			local roundIndex=math.floor(tag/1000)
			local leftNum=tag%1000
			local battleIndex=math.floor(leftNum/10)
			local posIndex=leftNum%10
			self:showPlayerInfo(roundIndex,battleIndex,posIndex)
		end
	end
	local middleY=(self.totalHeight-35)/2
	self.round1Tb={}
	self.round2Tb={}
	self.round3Tb={}
	self.round4Tb={}
	self.round5Tb={}
	self.round6Tb={}
	self.round7Tb={}
	--init round 1
	for i=1,16 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		nameBg:setPosition(ccp(self.roundBgTb[1]:getPositionX()+self.roundBgTb[1]:getContentSize().width/2,middleY+(8.5-i)*(nameSize.height+5)))
		self.background:addChild(nameBg,2)
		table.insert(self.round1Tb,nameBg)

		self:addNameAndTagToBg(1,i,0,nameBg)
	end
	--init round 2
	for i=1,8 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		local posY
		if(i<8)then
			posY=(self.round1Tb[i+8]:getPositionY()+self.round1Tb[i+9]:getPositionY())/2
		else
			posY=self.round1Tb[16]:getPositionY()-(self.round1Tb[15]:getPositionY()-self.round1Tb[16]:getPositionY())/2
		end
		nameBg:setPosition(ccp(self.roundBgTb[2]:getPositionX()+self.roundBgTb[2]:getContentSize().width/2,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round2Tb,nameBg)

		self:addNameAndTagToBg(2,i,0,nameBg)
	end
	--init round 3
	for i=1,4 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		local posY=(self.round1Tb[i*2]:getPositionY()+self.round1Tb[i*2-1]:getPositionY())/2
		nameBg:setPosition(ccp(self.roundBgTb[3]:getPositionX()+self.roundBgTb[3]:getContentSize().width/2,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round3Tb,nameBg)
		
		self:addNameAndTagToBg(3,i,0,nameBg)
	end
	for i=1,4 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		local posY=(self.round2Tb[i*2]:getPositionY()+self.round2Tb[i*2-1]:getPositionY())/2
		nameBg:setPosition(ccp(self.roundBgTb[3]:getPositionX()+self.roundBgTb[3]:getContentSize().width/2,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round3Tb,nameBg)
		
		self:addNameAndTagToBg(3,i,2,nameBg)
	end
	--init round 4
	for i=1,4 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		local posY
		if(i<4)then
			posY=(self.round3Tb[i+4]:getPositionY()+self.round3Tb[i+5]:getPositionY())/2
		else
			posY=self.round3Tb[8]:getPositionY()/2
		end
		nameBg:setPosition(ccp(self.roundBgTb[4]:getPositionX()+self.roundBgTb[4]:getContentSize().width/2,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round4Tb,nameBg)
		
		self:addNameAndTagToBg(4,i,0,nameBg)
	end
	--init round 5
	for i=1,2 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		local posY=(self.round3Tb[i*2]:getPositionY()+self.round3Tb[i*2-1]:getPositionY())/2
		nameBg:setPosition(ccp(self.roundBgTb[5]:getPositionX()+self.roundBgTb[5]:getContentSize().width/2,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round5Tb,nameBg)
		
		self:addNameAndTagToBg(5,i,0,nameBg)
	end
	for i=1,2 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		local posY=(self.round4Tb[i*2]:getPositionY()+self.round4Tb[i*2-1]:getPositionY())/2
		nameBg:setPosition(ccp(self.roundBgTb[5]:getPositionX()+self.roundBgTb[5]:getContentSize().width/2,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round5Tb,nameBg)
		
		self:addNameAndTagToBg(5,i,1,nameBg)
	end
	--init round 6
	local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
	nameBg:setContentSize(nameSize)
	local posY=(self.round5Tb[3]:getPositionY()+self.round5Tb[4]:getPositionY())/2
	nameBg:setPosition(ccp(self.roundBgTb[6]:getPositionX()+self.roundBgTb[6]:getContentSize().width/2,posY))
	self.background:addChild(nameBg,2)
	table.insert(self.round6Tb,nameBg)
	self:addNameAndTagToBg(6,1,0,nameBg)

	nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
	nameBg:setContentSize(nameSize)
	nameBg:setPosition(ccp(self.roundBgTb[6]:getPositionX()+self.roundBgTb[6]:getContentSize().width/2,posY+nameSize.height+10))
	self.background:addChild(nameBg,2)
	table.insert(self.round6Tb,nameBg)
	self:addNameAndTagToBg(6,2,0,nameBg)

	--季军
	local function show3RdPlayerDetail()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		self:showSpecialPlayerDetail(3)
	end
	nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarTopBg3.png",CCRect(82,26,20,20),show3RdPlayerDetail)
	nameBg:setScale(0.7)
	nameBg:setPosition(ccp(self.roundBgTb[6]:getPositionX()+self.roundBgTb[6]:getContentSize().width/2,(posY+nameSize.height+10+middleY)/2))
	nameBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.background:addChild(nameBg,2)
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(6)
	if(roundStatus>=30 and self.battleList[6] and self.battleList[6][1] and self.battleList[6][1].winnerID)then
		local playerIndex
		if(self.battleList[6][1].winnerID==self.battleList[6][1].id1)then
			playerIndex=2
		elseif(self.battleList[6][1].winnerID==self.battleList[6][1].id2)then
			playerIndex=1
		end
		if(playerIndex)then
			local serverLb=GetTTFLabelWrap(self.battleList[6][1]["player"..playerIndex].serverName,17,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			serverLb:setAnchorPoint(ccp(0.5,0))
			serverLb:setPosition(ccp(nameBg:getContentSize().width/2,nameBg:getContentSize().height/2+1))
			nameBg:addChild(serverLb)
			local playerLb=GetTTFLabelWrap(self.battleList[6][1]["player"..playerIndex].name,17,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			playerLb:setAnchorPoint(ccp(0.5,1))
			playerLb:setPosition(ccp(nameBg:getContentSize().width/2,nameBg:getContentSize().height/2-1))
			nameBg:addChild(playerLb)
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.875)
		unknownIcon:setPosition(getCenterPoint(nameBg))
		nameBg:addChild(unknownIcon)
	end

	local lb3rd=GetTTFLabel("【"..getlocal("serverwar_rank_3").."】",20)
	lb3rd:setColor(G_ColorYellowPro)
	lb3rd:setPosition(ccp(nameBg:getPositionX(),nameBg:getPositionY()+nameSize.height/2+20))
	self.background:addChild(lb3rd,2)

	--init round 7
	local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
	nameBg:setContentSize(nameSize)
	local posY=(self.round5Tb[1]:getPositionY()+self.round5Tb[2]:getPositionY())/2
	nameBg:setPosition(ccp(self.roundBgTb[7]:getPositionX()+self.roundBgTb[7]:getContentSize().width/2,posY))
	self.background:addChild(nameBg,2)
	table.insert(self.round7Tb,nameBg)
	self:addNameAndTagToBg(7,1,0,nameBg)

	local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
	nameBg:setContentSize(nameSize)
	local posY=(self.round6Tb[1]:getPositionY()+self.round6Tb[2]:getPositionY())/2
	nameBg:setPosition(ccp(self.roundBgTb[7]:getPositionX()+self.roundBgTb[7]:getContentSize().width/2,posY))
	self.background:addChild(nameBg,2)
	table.insert(self.round7Tb,nameBg)
	self:addNameAndTagToBg(7,2,0,nameBg)

	--亚军
	local function show2ndPlayerDetail()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		self:showSpecialPlayerDetail(2)
	end
	rank2Bg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarTopBg2.png",CCRect(82,26,20,20),show2ndPlayerDetail)
	rank2Bg:setScale(0.8)
	rank2Bg:setPosition(ccp(nameBg:getPositionX(),nameBg:getPositionY()/2))
	rank2Bg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.background:addChild(rank2Bg,2)

	local lb2nd=GetTTFLabel("【"..getlocal("serverwar_rank_2").."】",20)
	lb2nd:setColor(G_ColorYellowPro)
	lb2nd:setPosition(ccp(rank2Bg:getPositionX(),rank2Bg:getPositionY()+nameSize.height/2+20))
	self.background:addChild(lb2nd,2)

	--冠军
	local function show1stPlayerDetail()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		self:showSpecialPlayerDetail(1)
	end
	local championBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarTopBg1.png",CCRect(90,40,20,20),show1stPlayerDetail)
	championBg:setScale(0.8)
	championBg:setPosition(ccp(self.roundBgTb[7]:getPositionX()+self.roundBgTb[7]:getContentSize().width/2,middleY + 10))
	championBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.background:addChild(championBg,2)

	local lb1st=GetTTFLabel("【"..getlocal("serverwar_rank_1").."】",20)
	lb1st:setColor(G_ColorYellowPro)
	lb1st:setPosition(ccp(championBg:getPositionX(),championBg:getPositionY() + 50))
	self.background:addChild(lb1st,2)

	local roundStatus=serverWarPersonalVoApi:getRoundStatus(7)
	if(roundStatus>=30 and self.battleList[7] and self.battleList[7][1] and self.battleList[7][1].winnerID)then
		local championServer=GetTTFLabelWrap("asdasda",15,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		championServer:setAnchorPoint(ccp(0.5,0))
		championServer:setPosition(ccp(championBg:getContentSize().width/2,30))
		championBg:addChild(championServer)
		local championName=GetTTFLabelWrap("asdas",15,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		championName:setAnchorPoint(ccp(0.5,1))
		championName:setPosition(ccp(championBg:getContentSize().width/2,28))
		championBg:addChild(championName)

		local rank2Server=GetTTFLabelWrap("asdasda",15,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		rank2Server:setAnchorPoint(ccp(0.5,0))
		rank2Server:setPosition(ccp(rank2Bg:getContentSize().width/2,rank2Bg:getContentSize().height/2))
		rank2Bg:addChild(rank2Server)
		local rank2Name=GetTTFLabelWrap("asdas",15,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		rank2Name:setAnchorPoint(ccp(0.5,1))
		rank2Name:setPosition(ccp(rank2Bg:getContentSize().width/2,rank2Bg:getContentSize().height/2))
		rank2Bg:addChild(rank2Name)

		if(self.battleList[7][1].winnerID==self.battleList[7][1].id1)then
			championServer:setString(self.battleList[7][1].player1.serverName)
			championName:setString(self.battleList[7][1].player1.name)
			rank2Server:setString(self.battleList[7][1].player2.serverName)
			rank2Name:setString(self.battleList[7][1].player2.name)
		else
			championServer:setString(self.battleList[7][1].player2.serverName)
			championName:setString(self.battleList[7][1].player2.name)
			rank2Server:setString(self.battleList[7][1].player1.serverName)
			rank2Name:setString(self.battleList[7][1].player1.name)
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.875)
		unknownIcon:setPosition(ccp(championBg:getContentSize().width/2,30))
		championBg:addChild(unknownIcon)
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.7)
		unknownIcon:setPosition(getCenterPoint(rank2Bg))
		rank2Bg:addChild(unknownIcon)
	end

	self:initLines()
end

function serverWarPersonalKnockOutScene:addNameAndTagToBg(roundIndex,bgIndex,offset,nameBg)
	local nameSize=CCSizeMake((G_VisibleSizeWidth/2-5*3)/2,45)
	local roundList=self.battleList[roundIndex]
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(roundIndex)
	--在本轮开始投注之前, 无法获知本轮的选手信息
	if(roundStatus>0 and roundList)then
		local battleIndex=math.ceil(bgIndex/2)+offset
		local playerIndex
		if(bgIndex%2==0)then
			playerIndex=2
		else
			playerIndex=1
		end
		local serverLb=GetTTFLabelWrap(roundList[battleIndex]["player"..playerIndex].serverName,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		serverLb:setAnchorPoint(ccp(0.5,0))
		serverLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
		nameBg:addChild(serverLb)
		local playerLb=GetTTFLabelWrap(roundList[battleIndex]["player"..playerIndex].name,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		playerLb:setAnchorPoint(ccp(0.5,1))
		playerLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
		nameBg:addChild(playerLb)

		nameBg:setTag(roundIndex*1000+battleIndex*10+playerIndex)
		nameBg:setTouchPriority(-(self.layerNum-1)*20-1)
	else
		if(roundIndex>1)then
			local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
			unknownIcon:setScale(0.7)
			unknownIcon:setPosition(getCenterPoint(nameBg))
			nameBg:addChild(unknownIcon)
		else
			local map={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"}
			local unknownLb
            local lbSize =20
            if G_getCurChoseLanguage() =="ru" then
                lbSize =12
            end
			if(bgIndex<9)then
				unknownLb=GetTTFLabel(getlocal("serverwar_groupWinName",{map[bgIndex]}),lbSize)
			else
				unknownLb=GetTTFLabel(getlocal("serverwar_groupLoseName",{map[bgIndex-8]}),lbSize)
			end
			unknownLb:setPosition(getCenterPoint(nameBg))
			nameBg:addChild(unknownLb)
		end
	end
end

function serverWarPersonalKnockOutScene:initLines()
	local nameSize=self.round1Tb[1]:getContentSize()
	local function onSendFlower(tag,object)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		if(tag)then
			local roundIndex=math.floor(tag/100)
			local battleIndex=tag%100
			self:showSendFlowerDialog(roundIndex,battleIndex)
		end
	end
	local function onWatch(tag,object)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		if(tag)then
			local roundIndex=math.floor(tag/100)
			local battleIndex=tag%100
			self:showBattleDialog(roundIndex,battleIndex)
		end
	end
	--round 1 line
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(1)
	for i=1,8 do
		local lineLength=(self.round3Tb[1]:getPositionX()-self.round1Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.round2Tb[1]:getPositionX())
		line1:setPositionY(self.round1Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round1Tb[1]:getPositionY()-self.round1Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.round2Tb[1]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round1Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round1Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,100+math.ceil(i/2),self.round2Tb[1]:getPositionX(),(self.round1Tb[i]:getPositionY()+self.round1Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,100+math.ceil(i/2),self.round2Tb[1]:getPositionX(),(self.round1Tb[i]:getPositionY()+self.round1Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[1] and self.battleList[1][battleIndex] and self.battleList[1][battleIndex])then
					if(self.battleList[1][battleIndex].winnerID~=self.battleList[1][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	for i=9,16 do
		local lineLength=(self.round2Tb[1]:getPositionX()-self.round1Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.roundBgTb[2]:getPositionX())
		line1:setPositionY(self.round1Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round1Tb[9]:getPositionY()-self.round1Tb[10]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.roundBgTb[2]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round1Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round1Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,100+math.ceil(i/2),self.roundBgTb[2]:getPositionX(),(self.round1Tb[i]:getPositionY()+self.round1Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,100+math.ceil(i/2),self.roundBgTb[2]:getPositionX(),(self.round1Tb[i]:getPositionY()+self.round1Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[1] and self.battleList[1][battleIndex])then
					if(self.battleList[1][battleIndex].winnerID~=self.battleList[1][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 2 line
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(2)
	for i=1,8 do
		local lineLength
		if(i%2==1)then
			lineLength=(self.round2Tb[1]:getPositionX()-self.round1Tb[1]:getPositionX()-nameSize.width)/2+5
			local lineLeft=self:getLine(lineLength)
			lineLeft:setAnchorPoint(ccp(0,0.5))
			lineLeft:setPositionX(self.roundBgTb[2]:getPositionX())
			lineLeft:setPositionY(self.round2Tb[i]:getPositionY())
			self.background:addChild(lineLeft,1)
		end

		lineLength=(self.round3Tb[1]:getPositionX()-self.round2Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.roundBgTb[3]:getPositionX())
		line1:setPositionY(self.round2Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round2Tb[1]:getPositionY()-self.round2Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.roundBgTb[3]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round2Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round2Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,200+math.ceil(i/2),self.roundBgTb[3]:getPositionX(),(self.round2Tb[i]:getPositionY()+self.round2Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,200+math.ceil(i/2),self.roundBgTb[3]:getPositionX(),(self.round2Tb[i]:getPositionY()+self.round2Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[2] and self.battleList[2][battleIndex])then
					if(self.battleList[2][battleIndex].winnerID~=self.battleList[2][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 3 line
	roundStatus=serverWarPersonalVoApi:getRoundStatus(3)
	for i=1,4 do
		local lineLength=(self.round3Tb[1]:getPositionX()-self.round1Tb[1]:getPositionX()-nameSize.width)/2+5
		local lineLeft=self:getLine(lineLength)
		lineLeft:setAnchorPoint(ccp(0,0.5))
		lineLeft:setPositionX(self.round2Tb[1]:getPositionX())
		lineLeft:setPositionY(self.round3Tb[i]:getPositionY())
		self.background:addChild(lineLeft,1)

		lineLength=(self.round5Tb[1]:getPositionX()-self.round3Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.round4Tb[1]:getPositionX())
		line1:setPositionY(self.round3Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round3Tb[1]:getPositionY()-self.round3Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.round4Tb[1]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round3Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round3Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,300+math.ceil(i/2),self.round4Tb[1]:getPositionX(),(self.round3Tb[i]:getPositionY()+self.round3Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,300+math.ceil(i/2),self.round4Tb[1]:getPositionX(),(self.round3Tb[i]:getPositionY()+self.round3Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[3] and self.battleList[3][battleIndex])then
					if(self.battleList[3][battleIndex].winnerID~=self.battleList[3][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	for i=5,8 do
		local lineLength=(self.round3Tb[1]:getPositionX()-self.round2Tb[1]:getPositionX()-nameSize.width)/2+5
		local lineLeft=self:getLine(lineLength)
		lineLeft:setAnchorPoint(ccp(0,0.5))
		lineLeft:setPositionX(self.roundBgTb[3]:getPositionX())
		lineLeft:setPositionY(self.round3Tb[i]:getPositionY())
		self.background:addChild(lineLeft,1)

		lineLength=(self.round4Tb[1]:getPositionX()-self.round3Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.roundBgTb[4]:getPositionX())
		line1:setPositionY(self.round3Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		if(i%2==0)then
			lineLength=(self.round3Tb[i-1]:getPositionY()-self.round3Tb[i]:getPositionY())/2+2
		else
			lineLength=(self.round3Tb[i]:getPositionY()-self.round3Tb[i+1]:getPositionY())/2+2
		end
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.roundBgTb[4]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round3Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round3Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,300+math.ceil(i/2),self.roundBgTb[4]:getPositionX(),(self.round3Tb[i]:getPositionY()+self.round3Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,300+math.ceil(i/2),self.roundBgTb[4]:getPositionX(),(self.round3Tb[i]:getPositionY()+self.round3Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[3] and self.battleList[3][battleIndex])then
					if(self.battleList[3][battleIndex].winnerID~=self.battleList[3][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 4 line
	roundStatus=serverWarPersonalVoApi:getRoundStatus(4)
	for i=1,4 do
		local lineLength
		if(i%2==1)then
			lineLength=(self.round4Tb[1]:getPositionX()-self.round3Tb[1]:getPositionX()-nameSize.width)/2+5
			local lineLeft=self:getLine(lineLength)
			lineLeft:setAnchorPoint(ccp(0,0.5))
			lineLeft:setPositionX(self.roundBgTb[4]:getPositionX())
			lineLeft:setPositionY(self.round4Tb[i]:getPositionY())
			self.background:addChild(lineLeft,1)
		end

		lineLength=(self.round5Tb[1]:getPositionX()-self.round4Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.roundBgTb[5]:getPositionX())
		line1:setPositionY(self.round4Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		if(i%2==0)then
			lineLength=(self.round4Tb[i-1]:getPositionY()-self.round4Tb[i]:getPositionY())/2+2
		else
			lineLength=(self.round4Tb[i]:getPositionY()-self.round4Tb[i+1]:getPositionY())/2+2
		end
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.roundBgTb[5]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round4Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round4Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,400+math.ceil(i/2),self.roundBgTb[5]:getPositionX(),(self.round4Tb[i]:getPositionY()+self.round4Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,400+math.ceil(i/2),self.roundBgTb[5]:getPositionX(),(self.round4Tb[i]:getPositionY()+self.round4Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[4] and self.battleList[4][battleIndex])then
					if(self.battleList[4][battleIndex].winnerID~=self.battleList[4][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 5 line
	roundStatus=serverWarPersonalVoApi:getRoundStatus(5)
	for i=1,2 do
		local lineLength=(self.round5Tb[1]:getPositionX()-self.round3Tb[1]:getPositionX()-nameSize.width)/2+5
		local lineLeft=self:getLine(lineLength)
		lineLeft:setAnchorPoint(ccp(0,0.5))
		lineLeft:setPositionX(self.round4Tb[1]:getPositionX())
		lineLeft:setPositionY(self.round5Tb[i]:getPositionY())
		self.background:addChild(lineLeft,1)

		lineLength=(self.round7Tb[1]:getPositionX()-self.round5Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.round6Tb[1]:getPositionX())
		line1:setPositionY(self.round5Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round5Tb[1]:getPositionY()-self.round5Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.round6Tb[1]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round5Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round5Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,500+math.ceil(i/2),self.round6Tb[1]:getPositionX(),(self.round5Tb[i]:getPositionY()+self.round5Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,500+math.ceil(i/2),self.round6Tb[1]:getPositionX(),(self.round5Tb[i]:getPositionY()+self.round5Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[5] and self.battleList[5][battleIndex])then
					if(self.battleList[5][battleIndex].winnerID~=self.battleList[5][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	for i=3,4 do
		local lineLength=(self.round5Tb[1]:getPositionX()-self.round4Tb[1]:getPositionX()-nameSize.width)/2+5
		local lineLeft=self:getLine(lineLength)
		lineLeft:setAnchorPoint(ccp(0,0.5))
		lineLeft:setPositionX(self.roundBgTb[5]:getPositionX())
		lineLeft:setPositionY(self.round5Tb[i]:getPositionY())
		self.background:addChild(lineLeft,1)

		lineLength=(self.round6Tb[1]:getPositionX()-self.round5Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.roundBgTb[6]:getPositionX())
		line1:setPositionY(self.round5Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round5Tb[3]:getPositionY()-self.round5Tb[4]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.roundBgTb[6]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round5Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round5Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,500+math.ceil(i/2),self.roundBgTb[6]:getPositionX(),(self.round5Tb[i]:getPositionY()+self.round5Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,500+math.ceil(i/2),self.roundBgTb[6]:getPositionX(),(self.round5Tb[i]:getPositionY()+self.round5Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[5] and self.battleList[5][battleIndex])then
					if(self.battleList[5][battleIndex].winnerID~=self.battleList[5][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 6 line
	roundStatus=serverWarPersonalVoApi:getRoundStatus(6)
	for i=1,2 do
		local lineLength
		if(i==1)then
			lineLength=(self.round6Tb[1]:getPositionX()-self.round5Tb[1]:getPositionX()-nameSize.width)/2+5
			local lineLeft=self:getLine(lineLength)
			lineLeft:setAnchorPoint(ccp(0,0.5))
			lineLeft:setPositionX(self.roundBgTb[6]:getPositionX())
			lineLeft:setPositionY(self.round6Tb[i]:getPositionY())
			self.background:addChild(lineLeft,1)
		end

		lineLength=(self.round7Tb[1]:getPositionX()-self.round6Tb[1]:getPositionX()-nameSize.width)/2+5
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPositionX(self.roundBgTb[7]:getPositionX())
		line1:setPositionY(self.round6Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round6Tb[1]:getPositionY()-self.round6Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.roundBgTb[7]:getPositionX())
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round6Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round6Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		if(roundStatus==10)then
			if(i%2==1)then
				self:addBtnToBackground(1,600+math.ceil(i/2),self.roundBgTb[7]:getPositionX(),(self.round6Tb[i]:getPositionY()+self.round4Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1)then
				self:addBtnToBackground(2,600+math.ceil(i/2),self.roundBgTb[7]:getPositionX(),(self.round6Tb[i]:getPositionY()+self.round4Tb[i+1]:getPositionY())/2,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=math.ceil(i/2)
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[6] and self.battleList[6][battleIndex])then
					if(self.battleList[6][battleIndex].winnerID~=self.battleList[6][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 7 line
	local lineLength=(self.round7Tb[1]:getPositionX()-self.round5Tb[1]:getPositionX()-nameSize.width)/2+5
	local lineLeft=self:getLine(lineLength)
	lineLeft:setAnchorPoint(ccp(0,0.5))
	lineLeft:setPositionX(self.round6Tb[1]:getPositionX())
	lineLeft:setPositionY(self.round7Tb[1]:getPositionY())
	self.background:addChild(lineLeft,1)

	lineLength=(self.round7Tb[1]:getPositionX()-self.round6Tb[1]:getPositionX()-nameSize.width)/2+5
	lineLeft=self:getLine(lineLength)
	lineLeft:setAnchorPoint(ccp(0,0.5))
	lineLeft:setPositionX(self.roundBgTb[7]:getPositionX())
	lineLeft:setPositionY(self.round7Tb[2]:getPositionY())
	self.background:addChild(lineLeft,1)

	local middleY=(self.totalHeight-35)/2
	lineLength=110
	local line21=self:getLine(lineLength)
	line21:setAnchorPoint(ccp(0,0.5))
	line21:setPositionX(self.round7Tb[1]:getPositionX())
	line21:setPositionY(self.round7Tb[1]:getPositionY()-nameSize.height/2+5)
	line21:setRotation(90)
	self.background:addChild(line21,1)

	lineLength=middleY - self.round7Tb[2]:getPositionY() -nameSize.height + 5
	local line22=self:getLine(lineLength)
	line22:setAnchorPoint(ccp(0,0.5))
	line22:setPositionX(self.round7Tb[1]:getPositionX())
	line22:setPositionY(self.round7Tb[2]:getPositionY()+nameSize.height/2-5)
	line22:setRotation(-90)
	self.background:addChild(line22,1)

	roundStatus=serverWarPersonalVoApi:getRoundStatus(7)
	if(roundStatus==10)then
		self:addBtnToBackground(1,701,self.round7Tb[1]:getPositionX(),(self.round7Tb[2]:getPositionY()+middleY)/2,onSendFlower)
	elseif(roundStatus>=20)then
		self:addBtnToBackground(2,701,self.round7Tb[1]:getPositionX(),(self.round7Tb[2]:getPositionY()+middleY)/2,onWatch)
		if(roundStatus>=30)then
			local battleIndex=1
			if(self.battleList[7] and self.battleList[7][battleIndex])then
				if(self.battleList[7][battleIndex].winnerID==self.battleList[7][battleIndex].id1)then
					line22:setColor(self.loserColor)
				else
					line21:setColor(self.loserColor)
				end
			end
		end
	end
end

function serverWarPersonalKnockOutScene:getLine(length)
	local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line:setColor(self.winnerColor)
	local lineSize=line:getContentSize()
	line:setScaleX(length/lineSize.width)
	line:setScaleY(5/lineSize.height)
	return line
end

function serverWarPersonalKnockOutScene:addBtnToBackground(type,tag,posX,posY,callback)
	local btnName
	local btnNameDown
	if(type==1)then
		btnName="flowerBtn.png"
		btnNameDown="flowerBtn_down.png"
	else
		btnName="cameraBtn.png"
		btnNameDown="cameraBtn_down.png"
	end
	local menuItem=GetButtonItem(btnName,btnNameDown,btnNameDown,callback,tag)
	menuItem:setScale(0.6)
	local menu=CCMenu:createWithItem(menuItem)
	menu:setTouchPriority(-(self.layerNum-1)*20-2)
	menu:setPosition(ccp(posX,posY))
	self.background:addChild(menu,2)
end

function serverWarPersonalKnockOutScene:showPlayerInfo(roundIndex,battleIndex,posIndex)
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(roundIndex)
	if(roundStatus>0)then
		if(self.battleList[roundIndex] and self.battleList[roundIndex][battleIndex] and self.battleList[roundIndex][battleIndex]["player"..posIndex])then
			serverWarPersonalVoApi:showPlayerDetailDialog(self.battleList[roundIndex][battleIndex]["player"..posIndex],self.layerNum+1)
		end
	end
end

function serverWarPersonalKnockOutScene:showSpecialPlayerDetail(rank)
	local roundIndex
	if(rank==3)then
		roundIndex=6
	elseif(rank<3)then
		roundIndex=7
	end
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(roundIndex)
	if(roundStatus>=30)then
		local data
		if(rank==3 and self.battleList[6] and self.battleList[6][1])then
			if(self.battleList[6][1].winnerID==self.battleList[6][1].id1)then
				data=self.battleList[6][1].player2
			else
				data=self.battleList[6][1].player1
			end
		elseif(rank==2 and self.battleList[7] and self.battleList[7][1])then
			if(self.battleList[7][1].winnerID==self.battleList[7][1].id1)then
				data=self.battleList[7][1].player2
			else
				data=self.battleList[7][1].player1
			end
		elseif(rank==1 and self.battleList[7] and self.battleList[7][1])then
			if(self.battleList[7][1].winnerID==self.battleList[7][1].id1)then
				data=self.battleList[7][1].player1
			else
				data=self.battleList[7][1].player2
			end
		end
		if(data)then
			serverWarPersonalVoApi:showPlayerDetailDialog(data,self.layerNum+1)
		end
	end
end

function serverWarPersonalKnockOutScene:showBattleDialog(roundIndex,battleIndex)
	local data=self.battleList[roundIndex][battleIndex]
	if(data and data.winnerID)then
		serverWarPersonalVoApi:showBattleDialog(data,roundIndex,self.layerNum+1)
	end
end

function serverWarPersonalKnockOutScene:showSendFlowerDialog(roundIndex,battleIndex)
	print("∑∑roundIndex",roundIndex)
	print("∑∑battleIndex",battleIndex)
	local data=self.battleList[roundIndex][battleIndex]
	if(data)then
		serverWarPersonalVoApi:showFlowerDialog(data,roundIndex,self.layerNum+1)
	end
end

function serverWarPersonalKnockOutScene:initTick()
	self.curRound = nil
	self.curStatus = nil
	for i=1,7 do
		local roundStatus=serverWarPersonalVoApi:getRoundStatus(i)
		if(roundStatus<30)then
			self.curRound=i
			self.curStatus=roundStatus
			break
		end
	end
	if(self.curRound)then
		local battleTime=serverWarPersonalVoApi:getBattleTimeList()[self.curRound+1]
		local endTime
		if(self.curStatus<=10)then
			endTime=battleTime - serverWarPersonalCfg.betTime
		elseif(self.curStatus==11)then
			endTime=battleTime
		else
			endTime=battleTime + 3*serverWarPersonalCfg.battleTime
		end
		self.countDown=endTime-base.serverTime
		base:addNeedRefresh(self)
	end
end

function serverWarPersonalKnockOutScene:tick()
	self.countDown=self.countDown-1
	if(self.countDown<=0)then
		base:removeFromNeedRefresh(self)
		local function refresh()
			self.background:removeFromParentAndCleanup(true)
			self.background=nil
			self:initTick()
			self:initContent()
			self:checkBound()
		end
		if(self.curStatus<20)then
			serverWarPersonalVoApi:getWarInfo(refresh)
		else
			refresh()
		end
	end
end

function serverWarPersonalKnockOutScene:setVisible(visible)
	if(self and self.bgLayer)then
		self.bgLayer:setVisible(visible)
	end
end

function serverWarPersonalKnockOutScene:close()
	base:removeFromNeedRefresh(self)
	self.roundBgTb=nil
	self.round1Tb=nil
	self.round2Tb=nil
	self.round3Tb=nil
	self.round4Tb=nil
	self.round5Tb=nil
	self.round6Tb=nil
	self.round7Tb=nil
	self.clayer=nil
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.firstOldPos=nil
	self.secondOldPos=nil
	self.touchArr=nil
	self.isShow=false
	base.allShowedCommonDialog=math.max(base.allShowedCommonDialog-1,0)
	for k,v in pairs(base.commonDialogOpened_WeakTb) do
		if v==self then
			table.remove(base.commonDialogOpened_WeakTb,k)
			break
		end
	end
end