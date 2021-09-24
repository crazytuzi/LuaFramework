--世界争霸决赛对阵表
worldWarFinalScene={}

--param type: 1是NB组, 2是SB组
--param groupID: ABCD哪一组
function worldWarFinalScene:new(type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.type=type
	nc.nameTb={}
	nc.winnerColor=ccc3(0,199,131)
	nc.loserColor=ccc3(145,145,145)
	return nc
end

function worldWarFinalScene:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTitle()
	self:initSchedule()
	self:initBtn()
	return self.bgLayer
end

function worldWarFinalScene:initTitle()
	local typeStr
	if(self.type==1)then
		typeStr=getlocal("world_war_sub_title12")
	else
		typeStr=getlocal("world_war_sub_title13")
	end
	local titleLb=GetTTFLabel(getlocal("world_war_typeFinal",{typeStr}),33)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(titleLb)

	local timeTb=worldWarVoApi:getBattleTimeList(self.type)
	local timeDesc1=GetTTFLabel(getlocal("world_war_semifinal"),25)
	timeDesc1:setColor(G_ColorYellowPro)
	timeDesc1:setPosition(G_VisibleSizeWidth/6,G_VisibleSizeHeight - 295)
	self.bgLayer:addChild(timeDesc1)
	local time1=GetTTFLabel(G_getDataTimeStr(timeTb[5]),25)
	time1:setPosition(G_VisibleSizeWidth/6,G_VisibleSizeHeight - 325)
	self.bgLayer:addChild(time1)
	local timeDesc2=GetTTFLabel(getlocal("serverwar_finalFight"),25)
	timeDesc2:setColor(G_ColorYellowPro)
	timeDesc2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 295)
	self.bgLayer:addChild(timeDesc2)
	local time2=GetTTFLabel(G_getDataTimeStr(timeTb[6]),25)
	time2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 325)
	self.bgLayer:addChild(time2)
    local timeDesc3Siz = 20
    local timeDesc3PosWidht	= 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
      timeDesc3Siz =25
      timeDesc3PosWidht=0
    end
	local timeDesc3=GetTTFLabel(getlocal("world_war_3rdFight"),timeDesc3Siz)
	timeDesc3:setColor(G_ColorYellowPro)
	timeDesc3:setPosition(G_VisibleSizeWidth*5/6-timeDesc3PosWidht,G_VisibleSizeHeight - 295)
	self.bgLayer:addChild(timeDesc3)
	local time3=GetTTFLabel(G_getDataTimeStr(timeTb[6]),25)
	time3:setPosition(G_VisibleSizeWidth*5/6,G_VisibleSizeHeight - 325)
	self.bgLayer:addChild(time3)

	self.scheduleHeight=G_VisibleSizeHeight - 340
	self.tmatchRounds=tonumber(string.format("%.0f",math.log(worldWarCfg.tmatchplayer)/math.log(2)))
	self.nameSize=CCSizeMake(230,70)
	self.nameSizeSpace=(self.scheduleHeight - 100)/6
end

function worldWarFinalScene:initSchedule()
	self.scheduleLayer=CCLayer:create()
	self:initRefreshTime()
	self.bgLayer:addChild(self.scheduleLayer)
	local totalBattleList=worldWarVoApi:getBattleList(self.type)
	self.battleList={}
	for i=self.tmatchRounds - 1,self.tmatchRounds do
		if(totalBattleList[i])then
			table.insert(self.battleList,totalBattleList[i])
		end
	end
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
			self:showPlayerInfo(tag)
		end
	end
	self.nameTb={}
	for i=1,6 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),showPlayerInfo)
		nameBg:setContentSize(self.nameSize)
		nameBg:setAnchorPoint(ccp(0,0.5))
		nameBg:setPosition(30,self.scheduleHeight - self.nameSizeSpace*(i-0.5))
		nameBg:setTouchPriority(-(self.layerNum-1)*20-2)
		self.scheduleLayer:addChild(nameBg,2)
		table.insert(self.nameTb,nameBg)
		if(i<=4 and self.battleList[1] and #(self.battleList[1])>0)then
			local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds - 1)
			if(roundStatus>0)then
				local battleIndex=math.ceil(i/2)
				local playerIndex=i%2
				if(playerIndex==0)then
					playerIndex=2
				end
				nameBg:setTag(battleIndex*10+playerIndex)
				if(self.battleList[1][battleIndex]["player"..playerIndex])then
					local serverLb=GetTTFLabelWrap(self.battleList[1][battleIndex]["player"..playerIndex].serverName,20,CCSizeMake(self.nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
					serverLb:setAnchorPoint(ccp(0.5,0))
					serverLb:setPosition(ccp(self.nameSize.width/2,self.nameSize.height/2+1))
					nameBg:addChild(serverLb)
					local playerLb=GetTTFLabelWrap(self.battleList[1][battleIndex]["player"..playerIndex].name,20,CCSizeMake(self.nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					playerLb:setAnchorPoint(ccp(0.5,1))
					playerLb:setPosition(ccp(self.nameSize.width/2,self.nameSize.height/2-1))
					nameBg:addChild(playerLb)
				end
			else
				local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
				unknownIcon:setScale(0.7)
				unknownIcon:setPosition(getCenterPoint(nameBg))
				nameBg:addChild(unknownIcon)
			end
		elseif(self.battleList[2] and #(self.battleList[2])>0)then
			local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds)
			if(roundStatus>0)then
				local playerIndex=i%2
				if(playerIndex==0)then
					playerIndex=2
				end
				nameBg:setTag(80+playerIndex)
				if(self.battleList[2][2]["player"..playerIndex])then
					local serverLb=GetTTFLabelWrap(self.battleList[2][2]["player"..playerIndex].serverName,20,CCSizeMake(self.nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
					serverLb:setAnchorPoint(ccp(0.5,0))
					serverLb:setPosition(ccp(self.nameSize.width/2,self.nameSize.height/2+1))
					nameBg:addChild(serverLb)
					local playerLb=GetTTFLabelWrap(self.battleList[2][2]["player"..playerIndex].name,20,CCSizeMake(self.nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					playerLb:setAnchorPoint(ccp(0.5,1))
					playerLb:setPosition(ccp(self.nameSize.width/2,self.nameSize.height/2-1))
					nameBg:addChild(playerLb)
				end
			else
				local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
				unknownIcon:setScale(0.7)
				unknownIcon:setPosition(getCenterPoint(nameBg))
				nameBg:addChild(unknownIcon)
			end
		end
	end
	local championBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarTopBg1.png",CCRect(90,40,20,20),showPlayerInfo)
	championBg:setAnchorPoint(ccp(1,0.5))
	championBg:setPosition(G_VisibleSizeWidth - 30,self.scheduleHeight - self.nameSizeSpace*2 + 10)
	championBg:setTag(99)
	championBg:setTouchPriority(-(self.layerNum-1)*20-2)
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds)
	if(roundStatus>=30)then
		if(self.battleList[2] and self.battleList[2][1] and self.battleList[2][1].winnerID)then
			local playerIndex
			if(self.battleList[2][1].winnerID==self.battleList[2][1].id1)then
				playerIndex=1
			else
				playerIndex=2
			end
			if(self.battleList[2][1]["player"..playerIndex])then
				local serverLb=GetTTFLabelWrap(self.battleList[2][1]["player"..playerIndex].serverName,20,CCSizeMake(self.nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
				serverLb:setAnchorPoint(ccp(0.5,0))
				serverLb:setPosition(ccp(championBg:getContentSize().width/2,championBg:getContentSize().height/2-10))
				championBg:addChild(serverLb)
				local playerLb=GetTTFLabelWrap(self.battleList[2][1]["player"..playerIndex].name,20,CCSizeMake(self.nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				playerLb:setAnchorPoint(ccp(0.5,1))
				playerLb:setPosition(ccp(championBg:getContentSize().width/2,championBg:getContentSize().height/2-12))
				championBg:addChild(playerLb)
			end
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.8)
		unknownIcon:setPosition(championBg:getContentSize().width/2,championBg:getContentSize().height/2 - 10)
		championBg:addChild(unknownIcon)		
	end
	self.scheduleLayer:addChild(championBg,2)
	local rank2Bg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarTopBg2.png",CCRect(90,40,20,20),showPlayerInfo)
	rank2Bg:setAnchorPoint(ccp(1,0.5))
	rank2Bg:setPosition(G_VisibleSizeWidth - 30,self.scheduleHeight - self.nameSizeSpace*3.5)
	rank2Bg:setTag(98)
	rank2Bg:setTouchPriority(-(self.layerNum-1)*20-2)
	if(roundStatus>=30)then
		if(self.battleList[2] and self.battleList[2][1] and self.battleList[2][1].winnerID)then
			local playerIndex
			if(self.battleList[2][1].winnerID==self.battleList[2][1].id1)then
				playerIndex=2
			else
				playerIndex=1
			end
			if(self.battleList[2][1]["player"..playerIndex])then
				local serverLb=GetTTFLabelWrap(self.battleList[2][1]["player"..playerIndex].serverName,20,CCSizeMake(self.nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
				serverLb:setAnchorPoint(ccp(0.5,0))
				serverLb:setPosition(ccp(rank2Bg:getContentSize().width/2,rank2Bg:getContentSize().height/2+1))
				rank2Bg:addChild(serverLb)
				local playerLb=GetTTFLabelWrap(self.battleList[2][1]["player"..playerIndex].name,20,CCSizeMake(self.nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				playerLb:setAnchorPoint(ccp(0.5,1))
				playerLb:setPosition(ccp(rank2Bg:getContentSize().width/2,rank2Bg:getContentSize().height/2-1))
				rank2Bg:addChild(playerLb)
			end
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.8)
		unknownIcon:setPosition(getCenterPoint(rank2Bg))
		rank2Bg:addChild(unknownIcon)		
	end
	self.scheduleLayer:addChild(rank2Bg,2)
	local rank3Bg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarTopBg3.png",CCRect(90,40,20,20),showPlayerInfo)
	rank3Bg:setAnchorPoint(ccp(1,0.5))
	rank3Bg:setPosition(G_VisibleSizeWidth - 30,self.scheduleHeight - self.nameSizeSpace*5)
	rank3Bg:setTag(97)
	rank3Bg:setTouchPriority(-(self.layerNum-1)*20-2)
	if(roundStatus>=30)then
		if(self.battleList[2] and self.battleList[2][2] and self.battleList[2][2].winnerID)then
			local playerIndex
			if(self.battleList[2][2].winnerID==self.battleList[2][2].id1)then
				playerIndex=1
			else
				playerIndex=2
			end
			if(self.battleList[2][2]["player"..playerIndex])then
				local serverLb=GetTTFLabelWrap(self.battleList[2][2]["player"..playerIndex].serverName,20,CCSizeMake(self.nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
				serverLb:setAnchorPoint(ccp(0.5,0))
				serverLb:setPosition(ccp(rank3Bg:getContentSize().width/2,rank3Bg:getContentSize().height/2+1))
				rank3Bg:addChild(serverLb)
				local playerLb=GetTTFLabelWrap(self.battleList[2][2]["player"..playerIndex].name,20,CCSizeMake(self.nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				playerLb:setAnchorPoint(ccp(0.5,1))
				playerLb:setPosition(ccp(rank3Bg:getContentSize().width/2,rank3Bg:getContentSize().height/2-1))
				rank3Bg:addChild(playerLb)
			end
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.8)
		unknownIcon:setPosition(getCenterPoint(rank3Bg))
		rank3Bg:addChild(unknownIcon)		
	end
	self.scheduleLayer:addChild(rank3Bg,2)

	self:initLines()
end

function worldWarFinalScene:initLines()
	local function onSendFlower(tag,object)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		if(tag and tag>0)then
			self:showSendFlowerDialog(tag)
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
		if(tag and tag>0)then
			self:showBattleDialog(tag)
		end
	end
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds - 1)
	local horizonLineLength=50
	local verticalLineLength=(self.nameTb[1]:getPositionY() - self.nameTb[2]:getPositionY())/2 + 2
	local lineStartX=self.nameTb[1]:getPositionX() + self.nameSize.width
	for i=1,4 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(lineStartX,self.nameTb[i]:getPositionY())
		self.scheduleLayer:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX + horizonLineLength)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[i]:getPositionY() - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[i]:getPositionY() + 1)
		end
		self.scheduleLayer:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].player1 and self.battleList[1][battleIndex].player2)then
				self:addBtnToBackground(1,10+battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].player1 and self.battleList[1][battleIndex].player2)then
				self:addBtnToBackground(2,10+battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
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
	roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds)
	for i=1,2 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(lineStartX,self.nameTb[i+4]:getPositionY())
		self.scheduleLayer:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX + horizonLineLength)
		if(i==2)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[i+4]:getPositionY() - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[i+4]:getPositionY() + 1)
		end
		self.scheduleLayer:addChild(line2,1)
		if(i==1)then
			local line3=self:getLine(100)
			line3:setAnchorPoint(ccp(0,0.5))
			line3:setPosition(lineStartX + horizonLineLength,(self.nameTb[5]:getPositionY()+self.nameTb[6]:getPositionY())/2)
			self.scheduleLayer:addChild(line3,1)
		end
		if(roundStatus==10)then
			if(i==1 and self.battleList[2][2] and self.battleList[2][2].player1 and self.battleList[2][2].player2)then
				self:addBtnToBackground(1,22,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i==1 and self.battleList[2][2] and self.battleList[2][2].player1 and self.battleList[2][2].player2)then
				self:addBtnToBackground(2,22,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=2
				local playerIndex=i
				if(self.battleList[2] and self.battleList[2][battleIndex])then
					if(self.battleList[2][battleIndex].winnerID~=self.battleList[2][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	lineStartX=lineStartX + horizonLineLength
	horizonLineLength=50
	verticalLineLength=verticalLineLength*2
	for i=1,2 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(lineStartX,(self.nameTb[i*2-1]:getPositionY()+self.nameTb[i*2]:getPositionY())/2)
		self.scheduleLayer:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX + horizonLineLength)
		if(i==2)then
			line2:setRotation(-90)
			line2:setPositionY((self.nameTb[i*2-1]:getPositionY()+self.nameTb[i*2]:getPositionY())/2 - 1)
		else
			line2:setRotation(90)
			line2:setPositionY((self.nameTb[i*2-1]:getPositionY()+self.nameTb[i*2]:getPositionY())/2 + 1)
			local line3=self:getLine(50)
			line3:setAnchorPoint(ccp(0,0.5))
			line3:setPosition(lineStartX+horizonLineLength,(self.nameTb[2]:getPositionY() + self.nameTb[3]:getPositionY())/2)
			self.scheduleLayer:addChild(line3,1)
		end
		self.scheduleLayer:addChild(line2,1)
		if(roundStatus==10)then
			if(i==1 and self.battleList[2][1] and self.battleList[2][1].player1 and self.battleList[2][1].player2)then
				self:addBtnToBackground(1,21,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i==1 and self.battleList[2][1] and self.battleList[2][1].player1 and self.battleList[2][1].player2)then
				self:addBtnToBackground(2,21,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local battleIndex=1
				local playerIndex=i
				if(self.battleList[2] and self.battleList[2][battleIndex])then
					if(self.battleList[2][battleIndex].winnerID~=self.battleList[2][battleIndex]["id"..playerIndex])then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
end

function worldWarFinalScene:showPlayerInfo(tag)
	if(tag>90)then
		local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds)
		if(roundStatus>=30)then
			if(tag==99 and self.battleList[2][1].winnerID)then
				local playerIndex
				if(self.battleList[2][1].winnerID==self.battleList[2][1].id1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[2][1]["player"..playerIndex])then
					worldWarVoApi:showPlayerDetailDialog(self.battleList[2][1]["player"..playerIndex],self.layerNum+1)
				end
			elseif(tag==98 and self.battleList[2][1].winnerID)then
				local playerIndex
				if(self.battleList[2][1].winnerID==self.battleList[2][1].id1)then
					playerIndex=2
				else
					playerIndex=1
				end
				if(self.battleList[2][1]["player"..playerIndex])then
					worldWarVoApi:showPlayerDetailDialog(self.battleList[2][1]["player"..playerIndex],self.layerNum+1)
				end
			elseif(self.battleList[2][2].winnerID)then
				local playerIndex
				if(self.battleList[2][2].winnerID==self.battleList[2][2].id1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[2][2]["player"..playerIndex])then
					worldWarVoApi:showPlayerDetailDialog(self.battleList[2][2]["player"..playerIndex],self.layerNum+1)
				end
			end
		end
	elseif(tag>80)then
		local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds)
		if(roundStatus>0)then
			local playerIndex=tag - 80
			if(self.battleList[2][2]["player"..playerIndex])then
				worldWarVoApi:showPlayerDetailDialog(self.battleList[2][2]["player"..playerIndex],self.layerNum+1)
			end
		end
	else
		local roundStatus=worldWarVoApi:getRoundStatus(self.type,self.tmatchRounds - 1)
		if(roundStatus>0)then
			local battleIndex=math.floor(tag/10)
			local playerIndex=tag%10
			if(self.battleList[1][battleIndex] and self.battleList[1][battleIndex]["player"..playerIndex])then
				worldWarVoApi:showPlayerDetailDialog(self.battleList[1][battleIndex]["player"..playerIndex],self.layerNum+1)
			end
		end
	end
end

function worldWarFinalScene:getLine(length)
	local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line:setColor(self.winnerColor)
	local lineSize=line:getContentSize()
	line:setScaleX(length/lineSize.width)
	line:setScaleY(5/lineSize.height)
	return line
end

function worldWarFinalScene:addBtnToBackground(type,tag,posX,posY,callback)
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
	self.scheduleLayer:addChild(menu,2)
end

function worldWarFinalScene:showSendFlowerDialog(tag)
	local roundIndex=math.floor(tag/10)
	local battleIndex=tag%10
	local data=self.battleList[roundIndex][battleIndex]
	if(data and data.player1 and data.player2)then
		worldWarVoApi:showFlowerDialog(self.type,data,self.layerNum+1)
	end
end

function worldWarFinalScene:showBattleDialog(tag)
	local roundIndex=math.floor(tag/10)
	local battleIndex=tag%10
	local data=self.battleList[roundIndex][battleIndex]
	if(data and data.player1 and data.player2)then
		local realRoundIndex=self.tmatchRounds + roundIndex - 2
		worldWarVoApi:showBattleDialog(self.type,data,false,self.layerNum+1)
	end
end

function worldWarFinalScene:initBtn()
	local function onClickInfo()
		PlayEffect(audioCfg.mouseClick)
		local contentTb={getlocal("world_war_scheduleInfo10"),getlocal("world_war_scheduleInfo9"),getlocal("world_war_scheduleInfo8"),getlocal("world_war_scheduleInfo7"),getlocal("world_war_scheduleInfo6"),getlocal("world_war_scheduleInfo5"),getlocal("world_war_scheduleInfo4"),getlocal("world_war_scheduleInfo3"),getlocal("world_war_scheduleInfo2"),getlocal("world_war_scheduleInfo1")}
		smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("help"),contentTb,{},true,self.layerNum+1)
	end
	local descItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickInfo,2,getlocal("activity_baseLeveling_ruleTitle"),25)
	local descBtn=CCMenu:createWithItem(descItem)
	descBtn:setPosition(G_VisibleSizeWidth/4,60)
	descBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(descBtn)
	local function onClickInfo2()
		worldWarVoApi:showReportListDialog(2,self.layerNum)
	end
	local recordItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickInfo2,2,getlocal("world_war_myBattle"),25)
	local recordBtn=CCMenu:createWithItem(recordItem)
	recordBtn:setPosition(G_VisibleSizeWidth*3/4,60)
	recordBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(recordBtn)
end

function worldWarFinalScene:initRefreshTime()
	local curRound = nil
	local curStatus = nil
	for i=1,6 do
		local roundStatus=worldWarVoApi:getRoundStatus(self.type,i)
		if(roundStatus<30)then
			curRound=i
			curStatus=roundStatus
			break
		end
	end
	if(curRound)then
		local battleTime=worldWarVoApi:getBattleTimeList(self.type)[curRound]
		if(curStatus<=10)then
			self.refreshTime=battleTime - worldWarCfg.betTime
		elseif(curStatus==11)then
			self.refreshTime=battleTime
			--前端延迟4分钟请求后台
		elseif(curStatus==21 and base.serverTime<battleTime + 240)then
			self.refreshTime=battleTime + 240
		else
			self.refreshTime=battleTime + 3*worldWarCfg.battleTime
		end
	else
		self.refreshTime=worldWarVoApi:getEndtime()
	end
end

function worldWarFinalScene:tick()
	if(base.serverTime>self.refreshTime)then
		local function callback()
			if(self.scheduleLayer)then
				self.scheduleLayer:removeFromParentAndCleanup(true)
				self:initSchedule()
			end
		end
		worldWarVoApi:getScheduleInfo(self.type,callback)
	end
end