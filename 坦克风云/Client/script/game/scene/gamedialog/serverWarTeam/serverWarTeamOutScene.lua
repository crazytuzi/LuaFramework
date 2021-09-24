serverWarTeamOutScene=
{
	bgLayer=nil,
	clayer=nil,
	roundBgTb=nil,
	round1Tb=nil,
	round2Tb=nil,
	round3Tb=nil,
	round4Tb=nil,
	winnerColor=ccc3(0,199,131),
	loserColor=ccc3(145,145,145),
	isShow=false,
}

function serverWarTeamOutScene:show(layerNum)
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

function serverWarTeamOutScene:initTitle()
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

function serverWarTeamOutScene:initBg()
	local nameSize=CCSizeMake(250,80)
	self.totalHeight=(nameSize.height+10)*12
	if(self.totalHeight<G_VisibleSizeHeight-self.titleHeight)then
		self.totalHeight=G_VisibleSizeHeight-self.titleHeight
	end
	local firstBgWidth=160
	self.totalWidth=(nameSize.width+250)*4

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

function serverWarTeamOutScene:touchEvent(fn,x,y,touch)
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

function serverWarTeamOutScene:checkBound(pos)
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

function serverWarTeamOutScene:initContent()
	self.background=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20,20,10,10),function ( ... )end)
	self.background:setAnchorPoint(ccp(0,0))
	self.background:setContentSize(CCSizeMake(self.totalWidth,self.totalHeight))
	self.background:setPosition(ccp(0,0))
	self.clayer:addChild(self.background)

	local posX=0
	local firstBgWidth=160
	local nameSize=CCSizeMake(250,80)
	self.roundBgTb={}
	for i=1,4 do
		local darkBg = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(42, 26, 10, 10),function ( ... ) end)
		darkBg:setContentSize(CCSizeMake(nameSize.width + 250,self.totalHeight))
		self.roundBgTb[i]=darkBg
		darkBg:setAnchorPoint(ccp(0,0))
		darkBg:setPosition(ccp(posX,0))
		self.background:addChild(darkBg,1)
		posX=posX+darkBg:getContentSize().width
	end

	posX=self.roundBgTb[1]:getPositionX()
	for i=1,4 do
		local textBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(20,20,10,10),function ( ... )end)
		local width=self.roundBgTb[i]:getContentSize().width
		textBg:setContentSize(CCSizeMake(width,40))
		textBg:setAnchorPoint(ccp(0,1))
		textBg:setPosition(ccp(posX,self.totalHeight))
		self.background:addChild(textBg,2)

		if(i<4)then
			local battleTime=G_getWeeTs(serverWarTeamVoApi:getBattleTimeList()[i][1])
			local dateStr=G_getDataTimeStr(battleTime,true,true)
			local dateLb=GetTTFLabel(dateStr,30)
			dateLb:setPosition(ccp(textBg:getContentSize().width/2,textBg:getContentSize().height/2))
			textBg:addChild(dateLb)
		end
		posX=posX+textBg:getContentSize().width
	end

	for i=1,4 do
		local posX=self.roundBgTb[i]:getPositionX()+self.roundBgTb[i]:getContentSize().width/2
		local titleStr
		if(i<4)then
			titleStr=getlocal("serverwar_roundIndex",{i})
		else
			titleStr=getlocal("serverwar_finalFight")
		end
		local roundTitle=GetTTFLabel(titleStr,25)
		roundTitle:setColor(G_ColorYellowPro)
		roundTitle:setPosition(ccp(posX,self.totalHeight-60))
		self.background:addChild(roundTitle,2)
	end
	self:initPlayers()
end

function serverWarTeamOutScene:initPlayers()
	self.battleList=serverWarTeamVoApi:getOutBattleList()
	local nameSize=CCSizeMake(250,80)
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
	local function nilFunc( ... )
	end
	self.round1Tb={}
	self.round2Tb={}
	self.round3Tb={}
	self.round4Tb={}
	local maxY=self.totalHeight - 80
	local spaceY=maxY/18
	--init round 1
	for i=1,8 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		nameBg:setAnchorPoint(ccp(0,0.5))
		nameBg:setPosition(ccp(self.roundBgTb[1]:getPositionX()+20,maxY - spaceY*(i*2-1)))
		self.background:addChild(nameBg,2)
		table.insert(self.round1Tb,nameBg)
		self:addNameAndTagToBg(1,i,0,nameBg)

		if(i%2==0)then
			local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),showPlayerInfo)
			timeBg:setContentSize(CCSizeMake(120,50))
			timeBg:setAnchorPoint(ccp(0,0.5))
			timeBg:setPosition(ccp(self.roundBgTb[1]:getPositionX()+365,(self.round1Tb[i]:getPositionY()+self.round1Tb[i-1]:getPositionY())/2))
			self.background:addChild(timeBg,2)

			local lb=GetTTFLabel(G_chatTime(serverWarTeamVoApi:getBattleTimeList()[1][i/2]),25)
			lb:setPosition(getCenterPoint(timeBg))
			timeBg:addChild(lb)
		end
	end
	--init round 2
	for i=1,4 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		nameBg:setAnchorPoint(ccp(0,0.5))
		local posY=(self.round1Tb[i*2]:getPositionY()+self.round1Tb[i*2-1]:getPositionY())/2
		nameBg:setPosition(ccp(self.roundBgTb[2]:getPositionX()+20,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round2Tb,nameBg)
		self:addNameAndTagToBg(2,i,0,nameBg)

		if(i%2==0)then
			local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),showPlayerInfo)
			timeBg:setContentSize(CCSizeMake(120,50))
			timeBg:setAnchorPoint(ccp(0,0.5))
			timeBg:setPosition(ccp(self.roundBgTb[2]:getPositionX()+365,(self.round2Tb[i]:getPositionY()+self.round2Tb[i-1]:getPositionY())/2))
			self.background:addChild(timeBg,2)

			local lb=GetTTFLabel(G_chatTime(serverWarTeamVoApi:getBattleTimeList()[2][i/2]),25)
			lb:setPosition(getCenterPoint(timeBg))
			timeBg:addChild(lb)
		end
	end
	--init round 3
	for i=1,2 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		nameBg:setAnchorPoint(ccp(0,0.5))
		local posY=(self.round2Tb[i*2]:getPositionY()+self.round2Tb[i*2-1]:getPositionY())/2
		nameBg:setPosition(ccp(self.roundBgTb[3]:getPositionX()+20,posY))
		self.background:addChild(nameBg,2)
		table.insert(self.round3Tb,nameBg)
		self:addNameAndTagToBg(3,i,0,nameBg)

		if(i%2==0)then
			local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),showPlayerInfo)
			timeBg:setContentSize(CCSizeMake(120,50))
			timeBg:setAnchorPoint(ccp(0,0.5))
			timeBg:setPosition(ccp(self.roundBgTb[3]:getPositionX()+365,(self.round3Tb[i]:getPositionY()+self.round3Tb[i-1]:getPositionY())/2))
			self.background:addChild(timeBg,2)

			local lb=GetTTFLabel(G_chatTime(serverWarTeamVoApi:getBattleTimeList()[3][i/2]),25)
			lb:setPosition(getCenterPoint(timeBg))
			timeBg:addChild(lb)
		end
	end
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
	rank2Bg:setScale(1.3)
	rank2Bg:setPosition(ccp(self.roundBgTb[4]:getPositionX()+self.roundBgTb[4]:getContentSize().width/2,(nameSize.height+10)*3))
	rank2Bg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.background:addChild(rank2Bg,2)

	local lb2nd=GetTTFLabel("【"..getlocal("serverwar_rank_2").."】",30)
	lb2nd:setColor(G_ColorYellowPro)
	lb2nd:setPosition(ccp(rank2Bg:getPositionX(),rank2Bg:getPositionY()+nameSize.height/2+30))
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
	championBg:setScale(1.3)
	championBg:setPosition(ccp(self.roundBgTb[4]:getPositionX()+self.roundBgTb[4]:getContentSize().width/2,(self.round3Tb[1]:getPositionY()+self.round3Tb[2]:getPositionY())/2 + 20))
	championBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.background:addChild(championBg,2)
	self.round4Tb[1]=championBg

	local lb1st=GetTTFLabel("【"..getlocal("serverwar_rank_1").."】",30)
	lb1st:setColor(G_ColorYellowPro)
	lb1st:setPosition(ccp(championBg:getPositionX(),championBg:getPositionY() + 80))
	self.background:addChild(lb1st,2)

	local roundStatus=serverWarTeamVoApi:getRoundStatus(3,1)
	if(self.battleList[3] and self.battleList[3][1] and self.battleList[3][1].winnerID)then
		local championServer=GetTTFLabelWrap("",20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		championServer:setAnchorPoint(ccp(0.5,0))
		championServer:setPosition(ccp(championBg:getContentSize().width/2,30))
		championBg:addChild(championServer)
		local championName=GetTTFLabelWrap("",20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		championName:setAnchorPoint(ccp(0.5,1))
		championName:setPosition(ccp(championBg:getContentSize().width/2,28))
		championBg:addChild(championName)

		local rank2Server=GetTTFLabelWrap("",20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		rank2Server:setAnchorPoint(ccp(0.5,0))
		rank2Server:setPosition(ccp(rank2Bg:getContentSize().width/2,rank2Bg:getContentSize().height/2))
		rank2Bg:addChild(rank2Server)
		local rank2Name=GetTTFLabelWrap("",20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		rank2Name:setAnchorPoint(ccp(0.5,1))
		rank2Name:setPosition(ccp(rank2Bg:getContentSize().width/2,rank2Bg:getContentSize().height/2))
		rank2Bg:addChild(rank2Name)

		if(self.battleList[3][1].winnerID==self.battleList[3][1].id1)then
			if(self.battleList[3][1].alliance1)then
				championServer:setString(self.battleList[3][1].alliance1.serverName)
				championName:setString(self.battleList[3][1].alliance1.name)
			end
			if(self.battleList[3][1].alliance2)then
				rank2Server:setString(self.battleList[3][1].alliance2.serverName)
				rank2Name:setString(self.battleList[3][1].alliance2.name)
			end
		else
			if(self.battleList[3][1].alliance2)then
				championServer:setString(self.battleList[3][1].alliance2.serverName)
				championName:setString(self.battleList[3][1].alliance2.name)
			end
			if(self.battleList[3][1].alliance1)then
				rank2Server:setString(self.battleList[3][1].alliance1.serverName)
				rank2Name:setString(self.battleList[3][1].alliance1.name)
			end
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

function serverWarTeamOutScene:addNameAndTagToBg(roundIndex,bgIndex,offset,nameBg)
	local nameSize=CCSizeMake(250,80)
	local roundList=self.battleList[roundIndex]
	local roundStatus=serverWarTeamVoApi:getRoundStatus(roundIndex,1)
	--在本轮开始投注之前, 无法获知本轮的选手信息
	if(roundStatus>0 and roundList)then
		local battleIndex=math.ceil(bgIndex/2)+offset
		local aIndex
		if(bgIndex%2==0)then
			aIndex=2
		else
			aIndex=1
		end
		local serverName
		local aName
		if(roundList[battleIndex] and roundList[battleIndex]["alliance"..aIndex])then
			serverName=roundList[battleIndex]["alliance"..aIndex].serverName
			aName=roundList[battleIndex]["alliance"..aIndex].name
		else
			serverName=""
			aName=""
		end
		local serverLb=GetTTFLabelWrap(serverName,20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		serverLb:setAnchorPoint(ccp(0.5,0))
		serverLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
		nameBg:addChild(serverLb)
		local allianceLb=GetTTFLabelWrap(aName,20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		allianceLb:setAnchorPoint(ccp(0.5,1))
		allianceLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
		nameBg:addChild(allianceLb)

		nameBg:setTag(roundIndex*1000 + battleIndex*10 + aIndex)
		nameBg:setTouchPriority(-(self.layerNum-1)*20-1)
	elseif(roundIndex>1 and serverWarTeamVoApi:getRoundStatus(roundIndex-1,1)==20)then
		if(self.battleList[roundIndex-1][bgIndex] and self.battleList[roundIndex-1][bgIndex].winnerID)then
			local aIndex
			if(self.battleList[roundIndex-1][bgIndex].winnerID==self.battleList[roundIndex-1][bgIndex].id1)then
				aIndex=1
			else
				aIndex=2
			end
			local serverName
			local aName
			if(self.battleList[roundIndex-1][bgIndex] and self.battleList[roundIndex-1][bgIndex]["alliance"..aIndex])then
				serverName=self.battleList[roundIndex-1][bgIndex]["alliance"..aIndex].serverName
				aName=self.battleList[roundIndex-1][bgIndex]["alliance"..aIndex].name
			else
				serverName=""
				aName=""
			end
			local serverLb=GetTTFLabelWrap(serverName,20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			serverLb:setAnchorPoint(ccp(0.5,0))
			serverLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
			nameBg:addChild(serverLb)
			local allianceLb=GetTTFLabelWrap(aName,20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			allianceLb:setAnchorPoint(ccp(0.5,1))
			allianceLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
			nameBg:addChild(allianceLb)
		else
			local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
			unknownIcon:setPosition(getCenterPoint(nameBg))
			nameBg:addChild(unknownIcon)
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setPosition(getCenterPoint(nameBg))
		nameBg:addChild(unknownIcon)
	end
end

function serverWarTeamOutScene:initLines()
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
	local roundStatus=serverWarTeamVoApi:getRoundStatus(1,1)
	for i=1,8 do
		local lineLength=55
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(self.round1Tb[i]:getPositionX() + nameSize.width - 3,self.round1Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round1Tb[1]:getPositionY()-self.round1Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.round1Tb[1]:getPositionX() + nameSize.width + 50)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round1Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round1Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[1] and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].alliance1 and self.battleList[1][battleIndex].alliance2)then
				self:addBtnToBackground(1,100+math.ceil(i/2),self.round1Tb[1]:getPositionX() + nameSize.width + 50,(self.round1Tb[i]:getPositionY()+self.round1Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20 and self.battleList[1] and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].winnerID)then
			if(i%2==1 and self.battleList[1] and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].alliance1 and self.battleList[1][battleIndex].alliance2)then
				self:addBtnToBackground(2,100+math.ceil(i/2),self.round1Tb[1]:getPositionX() + nameSize.width + 50,(self.round1Tb[i]:getPositionY()+self.round1Tb[i+1]:getPositionY())/2,onWatch)
			end
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
	--round 2 line
	local roundStatus=serverWarTeamVoApi:getRoundStatus(2)
	for i=1,4 do
		local lineLength
		lineLength=self.round2Tb[1]:getPositionX()-(self.round1Tb[1]:getPositionX() + nameSize.width + 50)+5
		local lineLeft=self:getLine(lineLength)
		lineLeft:setAnchorPoint(ccp(0,0.5))
		lineLeft:setPositionX(self.round1Tb[1]:getPositionX() + nameSize.width + 50)
		lineLeft:setPositionY(self.round2Tb[i]:getPositionY())
		self.background:addChild(lineLeft,1)

		local lineLength=55
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(self.round2Tb[i]:getPositionX() + nameSize.width - 3,self.round2Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round2Tb[1]:getPositionY()-self.round2Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.round2Tb[1]:getPositionX() + nameSize.width + 50)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round2Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round2Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[2] and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].alliance1 and self.battleList[2][battleIndex].alliance2)then
				self:addBtnToBackground(1,200+math.ceil(i/2),self.round2Tb[1]:getPositionX() + nameSize.width + 50,(self.round2Tb[i]:getPositionY()+self.round2Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20 and self.battleList[2] and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].winnerID)then
			if(i%2==1 and self.battleList[2] and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].alliance1 and self.battleList[2][battleIndex].alliance2)then
				self:addBtnToBackground(2,200+math.ceil(i/2),self.round2Tb[1]:getPositionX() + nameSize.width + 50,(self.round2Tb[i]:getPositionY()+self.round2Tb[i+1]:getPositionY())/2,onWatch)
			end
			local playerIndex
			if(i%2==1)then
				playerIndex=1
			else
				playerIndex=2
			end
			if(self.battleList[2] and self.battleList[2][battleIndex] and self.battleList[2][battleIndex])then
				if(self.battleList[2][battleIndex].winnerID~=self.battleList[2][battleIndex]["id"..playerIndex])then
					line1:setColor(self.loserColor)
					line2:setColor(self.loserColor)
				end
			end
		end
	end
	--round 3 line
	roundStatus=serverWarTeamVoApi:getRoundStatus(3)
	for i=1,2 do
		local lineLength
		lineLength=self.round3Tb[1]:getPositionX()-(self.round2Tb[1]:getPositionX() + nameSize.width + 50)+5
		local lineLeft=self:getLine(lineLength)
		lineLeft:setAnchorPoint(ccp(0,0.5))
		lineLeft:setPositionX(self.round2Tb[1]:getPositionX() + nameSize.width + 50)
		lineLeft:setPositionY(self.round3Tb[i]:getPositionY())
		self.background:addChild(lineLeft,1)

		local lineLength=55
		local line1=self:getLine(lineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(self.round3Tb[i]:getPositionX() + nameSize.width - 3,self.round3Tb[i]:getPositionY())
		self.background:addChild(line1,1)

		lineLength=(self.round3Tb[1]:getPositionY()-self.round3Tb[2]:getPositionY())/2+2
		local line2=self:getLine(lineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(self.round3Tb[1]:getPositionX() + nameSize.width + 50)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.round3Tb[i]:getPositionY()-1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.round3Tb[i]:getPositionY()+1)
		end
		self.background:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[3] and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].alliance1 and self.battleList[3][battleIndex].alliance2)then
				self:addBtnToBackground(1,300+math.ceil(i/2),self.round3Tb[1]:getPositionX() + nameSize.width + 50,(self.round3Tb[i]:getPositionY()+self.round3Tb[i+1]:getPositionY())/2,onSendFlower)
			end
		elseif(roundStatus>=20 and self.battleList[3] and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].winnerID)then
			if(i%2==1 and self.battleList[3] and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].alliance1 and self.battleList[3][battleIndex].alliance2)then
				self:addBtnToBackground(2,300+math.ceil(i/2),self.round3Tb[1]:getPositionX() + nameSize.width + 50,(self.round3Tb[i]:getPositionY()+self.round3Tb[i+1]:getPositionY())/2,onWatch)
			end
			local playerIndex
			if(i%2==1)then
				playerIndex=1
			else
				playerIndex=2
			end
			if(self.battleList[3] and self.battleList[3][battleIndex] and self.battleList[3][battleIndex])then
				if(self.battleList[3][battleIndex].winnerID~=self.battleList[3][battleIndex]["id"..playerIndex])then
					line1:setColor(self.loserColor)
					line2:setColor(self.loserColor)
				end
			end
		end
	end
	--round 4 line
	local lineLength=self.round4Tb[1]:getPositionX() - nameSize.width/2 -(self.round3Tb[1]:getPositionX() + nameSize.width + 50)+5
	local lineLeft=self:getLine(lineLength)
	lineLeft:setAnchorPoint(ccp(0,0.5))
	lineLeft:setPositionX(self.round3Tb[1]:getPositionX() + nameSize.width + 49)
	lineLeft:setPositionY((self.round3Tb[1]:getPositionY()+self.round3Tb[2]:getPositionY())/2)
	self.background:addChild(lineLeft,1)

	-- lineLength=(self.round7Tb[1]:getPositionX()-self.round6Tb[1]:getPositionX()-nameSize.width)/2+5
	-- lineLeft=self:getLine(lineLength)
	-- lineLeft:setAnchorPoint(ccp(0,0.5))
	-- lineLeft:setPositionX(self.roundBgTb[7]:getPositionX())
	-- lineLeft:setPositionY(self.round7Tb[2]:getPositionY())
	-- self.background:addChild(lineLeft,1)

	-- local middleY=(self.totalHeight-35)/2
	-- lineLength=110
	-- local line21=self:getLine(lineLength)
	-- line21:setAnchorPoint(ccp(0,0.5))
	-- line21:setPositionX(self.round7Tb[1]:getPositionX())
	-- line21:setPositionY(self.round7Tb[1]:getPositionY()-nameSize.height/2+5)
	-- line21:setRotation(90)
	-- self.background:addChild(line21,1)

	-- lineLength=middleY - self.round7Tb[2]:getPositionY() -nameSize.height + 5
	-- local line22=self:getLine(lineLength)
	-- line22:setAnchorPoint(ccp(0,0.5))
	-- line22:setPositionX(self.round7Tb[1]:getPositionX())
	-- line22:setPositionY(self.round7Tb[2]:getPositionY()+nameSize.height/2-5)
	-- line22:setRotation(-90)
	-- self.background:addChild(line22,1)

	-- roundStatus=serverWarTeamVoApi:getRoundStatus(4)
	-- if(roundStatus==10)then
	-- 	self:addBtnToBackground(1,401,self.round7Tb[1]:getPositionX(),(self.round7Tb[2]:getPositionY()+middleY)/2,onSendFlower)
	-- elseif(roundStatus>=20)then
	-- 	self:addBtnToBackground(2,401,self.round7Tb[1]:getPositionX(),(self.round7Tb[2]:getPositionY()+middleY)/2,onWatch)
	-- 	if(roundStatus>=30)then
	-- 		local battleIndex=1
	-- 		if(self.battleList[7] and self.battleList[7][battleIndex])then
	-- 			if(self.battleList[7][battleIndex].winnerID==self.battleList[7][battleIndex].id1)then
	-- 				line22:setColor(self.loserColor)
	-- 			else
	-- 				line21:setColor(self.loserColor)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function serverWarTeamOutScene:getLine(length)
	local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line:setColor(self.winnerColor)
	local lineSize=line:getContentSize()
	line:setScaleX(length/lineSize.width)
	line:setScaleY(5/lineSize.height)
	return line
end

function serverWarTeamOutScene:addBtnToBackground(type,tag,posX,posY,callback)
	local btnName
	local btnNameDown
	if(type==1)then
		btnName="flowerBtn.png"
		btnNameDown="flowerBtn_down.png"
	else
		btnName="worldBtnModify_Up.png"
		btnNameDown="worldBtnModify_Down.png"
	end
	local menuItem=GetButtonItem(btnName,btnNameDown,btnNameDown,callback,tag)
	menuItem:setScale(0.8)
	local menu=CCMenu:createWithItem(menuItem)
	menu:setTouchPriority(-(self.layerNum-1)*20-2)
	menu:setPosition(ccp(posX,posY))
	self.background:addChild(menu,2)
end

function serverWarTeamOutScene:showPlayerInfo(roundIndex,battleIndex,posIndex)
	if roundIndex and battleIndex and posIndex then
		if(self.battleList[roundIndex] and self.battleList[roundIndex][battleIndex] and self.battleList[roundIndex][battleIndex]["alliance"..posIndex])then
			serverWarTeamVoApi:showAllianceDetailDialog(self.battleList[roundIndex][battleIndex]["alliance"..posIndex],self.layerNum+1)
		end
	end
end

function serverWarTeamOutScene:showSpecialPlayerDetail(rank)
	local data
	if(rank==2 and self.battleList[3] and self.battleList[3][1] and self.battleList[3][1].winnerID)then
		if(self.battleList[3][1].winnerID==self.battleList[3][1].id1)then
			data=self.battleList[3][1].alliance2
		else
			data=self.battleList[3][1].alliance1
		end
	elseif(rank==1 and self.battleList[3] and self.battleList[3][1] and self.battleList[3][1].winnerID)then
		if(self.battleList[3][1].winnerID==self.battleList[3][1].id1)then
			data=self.battleList[3][1].alliance1
		else
			data=self.battleList[3][1].alliance2
		end
	end
	if(data)then
		serverWarTeamVoApi:showAllianceDetailDialog(data,self.layerNum+1)
	end
end

function serverWarTeamOutScene:showBattleDialog(roundIndex,battleIndex)
	local data=self.battleList[roundIndex][battleIndex]
	-- print("data.winnerID",data.winnerID)
	if(data and data.alliance1 and data.alliance2 and data.winnerID)then
		serverWarTeamVoApi:showRecordDialog(self.layerNum,data.roundID,data.battleID)
	else
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_battle_end_open"),30)
	end
end

function serverWarTeamOutScene:showSendFlowerDialog(roundIndex,battleIndex)
	local data=self.battleList[roundIndex][battleIndex]
	if(data and data.alliance1 and data.alliance2)then
		serverWarTeamVoApi:showFlowerDialog(data,roundIndex,self.layerNum+1)
	end
end

function serverWarTeamOutScene:initTick()
	self.curRound = nil
	self.curStatus = nil
	for i=1,3 do
		local roundStatus=serverWarTeamVoApi:getRoundStatus(1)
		if(roundStatus<30)then
			self.curRound=i
			self.curStatus=roundStatus
			break
		end
	end
	local timeList=serverWarTeamVoApi:getBattleTimeList()
	if(self.curRound)then
		local firstBattleTime=timeList[self.curRound][1] + serverWarTeamCfg.warTime
		local lastBattleTime=timeList[self.curRound][#(timeList[self.curRound])] + serverWarTeamCfg.warTime
		if(self.curStatus<=10)then
			self.countDownEnd=G_getWeeTs(firstBattleTime) + serverWarTeamCfg.flowerLimit[self.curRound][1][1]*3600 + serverWarTeamCfg.flowerLimit[self.curRound][1][2]*60
		else
			self.countDownEnd=lastBattleTime
		end
		base:addNeedRefresh(self)
	end
end

function serverWarTeamOutScene:tick()
	if(base.serverTime>=self.countDownEnd)then
		base:removeFromNeedRefresh(self)
		local function refresh()
			self.background:removeFromParentAndCleanup(true)
			self.background=nil
			self:initTick()
			self:initContent()
			self:checkBound()
		end
		if(self.curStatus<30)then
			serverWarTeamVoApi:getWarInfo(refresh)
		else
			refresh()
		end
	end
end

function serverWarTeamOutScene:setVisible(visible)
	if(self and self.bgLayer)then
		self.bgLayer:setVisible(visible)
	end
end

function serverWarTeamOutScene:close()
	base:removeFromNeedRefresh(self)
	self.roundBgTb=nil
	self.round1Tb=nil
	self.round2Tb=nil
	self.round3Tb=nil
	self.round4Tb=nil
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