--世界争霸淘汰赛对阵表
worldWarScheduleScene={}

--param type: 1是NB组, 2是SB组
--param groupID: ABCD哪一组
function worldWarScheduleScene:new(type,groupID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.type=type
	nc.groupID=groupID
	nc.rootTv=nil
	nc.nameTb={}
	nc.rootCellWidth=1150
	nc.rootCellHeight=G_VisibleSizeHeight - 300
	nc.winnerColor=ccc3(0,199,131)
	nc.loserColor=ccc3(145,145,145)
	return nc
end

function worldWarScheduleScene:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTitle()
	self:initTableView()
	self:initBtn()
	return self.bgLayer
end

function worldWarScheduleScene:initTitle()
	local map={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"}
	local typeStr
	if(self.type==1)then
		typeStr=getlocal("world_war_sub_title12")
	else
		typeStr=getlocal("world_war_sub_title13")
	end
	local titleLb=GetTTFLabel(getlocal("world_war_scheduleTitle",{typeStr,map[self.groupID]}),33)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(titleLb)
end

function worldWarScheduleScene:initTableView()
	local function callback(...)
		return self:eventHandlerRoot(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.rootTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,self.rootCellHeight),nil)
	self.rootTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.rootTv:setPosition(30,20)
	self.rootTv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(self.rootTv)
end

function worldWarScheduleScene:eventHandlerRoot(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.rootCellWidth,self.rootCellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.rootCell=cell
		self:initSchedule()
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function worldWarScheduleScene:initSchedule()
	self:initRefreshTime()
	local totalBattleList=worldWarVoApi:getBattleList(self.type)
	self.battleList={}
	for i=1,4 do
		if(totalBattleList[i] and #totalBattleList[i]>0)then
			self.battleList[i]={}
			local space=(#totalBattleList[i])/worldWarCfg.tmatchgroup
			local startIndex=(self.groupID - 1)*space + 1
			local endIndex=self.groupID*space
			for j=startIndex,endIndex do
				table.insert(self.battleList[i],totalBattleList[i][j])
			end
		end
	end
	local nameSize=CCSizeMake(250,70)
	local nameSizeSpace=(self.rootCellHeight - 100)/8
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
			if(tag~=99)then
				local battleIndex=math.floor(tag/10)
				local posIndex=tag%10
				self:showPlayerInfo(battleIndex,posIndex,false)
			else
				self:showPlayerInfo(nil,nil,true)
			end
		end
	end
	self.nameTb={}
	for i=1,8 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		nameBg:setAnchorPoint(ccp(0,0.5))
		nameBg:setPosition(10,self.rootCellHeight - nameSizeSpace*(i-0.5))
		self.rootCell:addChild(nameBg,2)
		table.insert(self.nameTb,nameBg)
		self:addNameAndTagToBg(i,nameBg)
	end
	for i=1,8 do
		local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),showPlayerInfo)
		nameBg:setContentSize(nameSize)
		nameBg:setAnchorPoint(ccp(1,0.5))
		nameBg:setPosition(self.rootCellWidth - 10,self.rootCellHeight - nameSizeSpace*(i-0.5))
		self.rootCell:addChild(nameBg,2)
		table.insert(self.nameTb,nameBg)
		self:addNameAndTagToBg(i+8,nameBg)
	end
	local championBg=LuaCCSprite:createWithSpriteFrameName("heroHead1.png",showPlayerInfo)
	championBg:setAnchorPoint(ccp(0.5,0))
	championBg:setScale(0.8)
	championBg:setPosition(self.rootCellWidth/2,self.rootCellHeight/2 + 100)
	championBg:setTag(99)
	championBg:setTouchPriority(-(self.layerNum-1)*20-2)
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,4)
	if(roundStatus>=30)then
		if(self.battleList[4] and self.battleList[4][1] and self.battleList[4][1].winnerID)then
			local playerData
			if(self.battleList[4][1].winnerID==self.battleList[4][1].id1 and self.battleList[4][1].player1)then
				playerData=self.battleList[4][1].player1
			elseif(self.battleList[4][1].winnerID==self.battleList[4][1].id2 and self.battleList[4][1].player2)then
				playerData=self.battleList[4][1].player2
			end
			if(playerData)then
				--local personPhotoName="photo"..playerData.pic..".png"
				--local playerPic = GetBgIcon(personPhotoName)
                local personPhotoName=playerVoApi:getPersonPhotoName(playerData.pic)
                local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
				playerPic:setPosition(getCenterPoint(championBg))
				playerPic:setScale((championBg:getContentSize().width - 18)/playerPic:getContentSize().width)
				championBg:addChild(playerPic)
			end
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(1.5)
		unknownIcon:setPosition(getCenterPoint(championBg))
		championBg:addChild(unknownIcon)		
	end
	self.rootCell:addChild(championBg,2)
	self:initLines()
	self:initTimeDesc()
end

function worldWarScheduleScene:addNameAndTagToBg(bgIndex,nameBg)
	local nameSize=CCSizeMake(250,70)
	local roundList=self.battleList[1]
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,1)
	if(roundStatus>=10 and roundList)then
		local battleIndex=math.ceil(bgIndex/2)
		local playerIndex
		if(bgIndex%2==0)then
			playerIndex=2
		else
			playerIndex=1
		end
		if(roundList[battleIndex]["player"..playerIndex])then
			local serverLb=GetTTFLabelWrap(roundList[battleIndex]["player"..playerIndex].serverName,20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			local playerLb=GetTTFLabelWrap(roundList[battleIndex]["player"..playerIndex].name,20,CCSizeMake(nameSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			serverLb:setAnchorPoint(ccp(0.5,0))
			serverLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
			nameBg:addChild(serverLb)
			
			playerLb:setAnchorPoint(ccp(0.5,1))
			playerLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
			nameBg:addChild(playerLb)
	
			nameBg:setTag(battleIndex*10 + playerIndex)
			nameBg:setTouchPriority(-(self.layerNum-1)*20-2)
		end
	else
		local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
		unknownIcon:setScale(0.7)
		unknownIcon:setPosition(getCenterPoint(nameBg))
		nameBg:addChild(unknownIcon)
	end
end

function worldWarScheduleScene:initLines()
	local nameSize=self.nameTb[1]:getContentSize()
	local nameSizeSpace=(self.rootCellHeight - 100)/8
	local function onSendFlower(tag,object)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if self.rootTv and self.rootTv:getScrollEnable()==true and self.rootTv:getIsScrolled()==false then
			if(tag)then
				local roundIndex=math.floor(tag/100)
				local battleIndex=tag%100
				self:showSendFlowerDialog(roundIndex,battleIndex)
			end
		end
	end
	local function onWatch(tag,object)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if self.rootTv and self.rootTv:getScrollEnable()==true and self.rootTv:getIsScrolled()==false then
			if(tag)then
				local roundIndex=math.floor(tag/100)
				local battleIndex=tag%100
				self:showBattleDialog(roundIndex,battleIndex)
			end
		end
	end
	--round 1 line
	local horizonLineLength=60
	local verticalLineLength=nameSizeSpace/2 + 1
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,1)
	local lineStartX=self.nameTb[1]:getPositionX() + nameSize.width
	for i=1,8 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(lineStartX,self.nameTb[i]:getPositionY())
		self.rootCell:addChild(line1,1)

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
		self.rootCell:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].player1 and self.battleList[1][battleIndex].player2)then
				self:addBtnToBackground(1,100 + battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].player1 and self.battleList[1][battleIndex].player2)then
				self:addBtnToBackground(2,100 + battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then				
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[1] and self.battleList[1][battleIndex])then
					if(self.battleList[1][battleIndex].winnerID~=self.battleList[1][battleIndex]["id"..playerIndex] or self.battleList[1][battleIndex]["player"..playerIndex]==nil)then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	lineStartX=self.nameTb[16]:getPositionX() - nameSize.width
	for i=1,8 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPosition(lineStartX,self.nameTb[i+8]:getPositionY())
		self.rootCell:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX - horizonLineLength)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[i+8]:getPositionY() - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[i+8]:getPositionY() + 1)
		end
		self.rootCell:addChild(line2,1)

		local battleIndex=math.ceil((i+8)/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].player1 and self.battleList[1][battleIndex].player2)then
				self:addBtnToBackground(1,100 + battleIndex,lineStartX - horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[1][battleIndex] and self.battleList[1][battleIndex].player1 and self.battleList[1][battleIndex].player2)then
				self:addBtnToBackground(2,100 + battleIndex,lineStartX - horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[1] and self.battleList[1][battleIndex])then
					if(self.battleList[1][battleIndex].winnerID~=self.battleList[1][battleIndex]["id"..playerIndex] or self.battleList[1][battleIndex]["player"..playerIndex]==nil)then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 2 line
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,2)
	local lineStartX=self.nameTb[1]:getPositionX() + nameSize.width + horizonLineLength
	verticalLineLength=nameSizeSpace + 2
	for i=1,4 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(lineStartX,self.rootCellHeight - nameSizeSpace*(2*i - 1))
		self.rootCell:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX + horizonLineLength)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[i*2]:getPositionY() + nameSizeSpace/2 - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[i*2]:getPositionY() + nameSizeSpace/2 + 1)
		end
		self.rootCell:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].player1 and self.battleList[2][battleIndex].player2)then
				self:addBtnToBackground(1,200 + battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].player1 and self.battleList[2][battleIndex].player2)then
				self:addBtnToBackground(2,200 + battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[2] and self.battleList[2][battleIndex])then
					if(self.battleList[2][battleIndex].winnerID~=self.battleList[2][battleIndex]["id"..playerIndex] or self.battleList[2][battleIndex]["player"..playerIndex]==nil)then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	lineStartX=self.nameTb[16]:getPositionX() - nameSize.width - horizonLineLength
	for i=1,4 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPosition(lineStartX,self.nameTb[(i+4)*2]:getPositionY() + nameSizeSpace/2)
		self.rootCell:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX - horizonLineLength)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[(i+4)*2]:getPositionY() + nameSizeSpace/2 - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[(i+4)*2]:getPositionY() + nameSizeSpace/2 + 1)
		end
		self.rootCell:addChild(line2,1)

		local battleIndex=math.ceil((i+4)/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].player1 and self.battleList[2][battleIndex].player2)then
				self:addBtnToBackground(1,200 + battleIndex,lineStartX - horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[2][battleIndex] and self.battleList[2][battleIndex].player1 and self.battleList[2][battleIndex].player2)then
				self:addBtnToBackground(2,200 + battleIndex,lineStartX - horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[2] and self.battleList[2][battleIndex])then
					if(self.battleList[2][battleIndex].winnerID~=self.battleList[2][battleIndex]["id"..playerIndex] or self.battleList[2][battleIndex]["player"..playerIndex]==nil)then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 3 line
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,3)
	local lineStartX=self.nameTb[1]:getPositionX() + nameSize.width + horizonLineLength*2
	verticalLineLength=nameSizeSpace*2 + 2
	for i=1,2 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(0,0.5))
		line1:setPosition(lineStartX,self.nameTb[i*4]:getPositionY() + nameSizeSpace*3/2)
		self.rootCell:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX + horizonLineLength)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[i*4]:getPositionY() + nameSizeSpace*3/2 - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[i*4]:getPositionY() + nameSizeSpace*3/2 + 1)
		end
		self.rootCell:addChild(line2,1)

		local battleIndex=math.ceil(i/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].player1 and self.battleList[3][battleIndex].player2)then
				self:addBtnToBackground(1,300 + battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].player1 and self.battleList[3][battleIndex].player2)then
				self:addBtnToBackground(2,300 + battleIndex,lineStartX + horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[3] and self.battleList[3][battleIndex])then
					if(self.battleList[3][battleIndex].winnerID~=self.battleList[3][battleIndex]["id"..playerIndex] or self.battleList[3][battleIndex]["player"..playerIndex]==nil)then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	lineStartX=self.nameTb[16]:getPositionX() - nameSize.width - horizonLineLength*2
	for i=1,2 do
		local line1=self:getLine(horizonLineLength)
		line1:setAnchorPoint(ccp(1,0.5))
		line1:setPosition(lineStartX,self.nameTb[(i+2)*4]:getPositionY() + nameSizeSpace*3/2)
		self.rootCell:addChild(line1,1)

		local line2=self:getLine(verticalLineLength)
		line2:setAnchorPoint(ccp(0,0.5))
		line2:setPositionX(lineStartX - horizonLineLength)
		if(i%2==0)then
			line2:setRotation(-90)
			line2:setPositionY(self.nameTb[(i+2)*4]:getPositionY() + nameSizeSpace*3/2 - 1)
		else
			line2:setRotation(90)
			line2:setPositionY(self.nameTb[(i+2)*4]:getPositionY() + nameSizeSpace*3/2 + 1)
		end
		self.rootCell:addChild(line2,1)

		local battleIndex=math.ceil((i+2)/2)
		if(roundStatus==10)then
			if(i%2==1 and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].player1 and self.battleList[3][battleIndex].player2)then
				self:addBtnToBackground(1,300+math.ceil((i+2)/2),lineStartX - horizonLineLength,line2:getPositionY() - verticalLineLength,onSendFlower)
			end
		elseif(roundStatus>=20)then
			if(i%2==1 and self.battleList[3][battleIndex] and self.battleList[3][battleIndex].player1 and self.battleList[3][battleIndex].player2)then
				self:addBtnToBackground(2,300+math.ceil((i+2)/2),lineStartX - horizonLineLength,line2:getPositionY() - verticalLineLength,onWatch)
			end
			if(roundStatus>=30)then
				local playerIndex
				if(i%2==1)then
					playerIndex=1
				else
					playerIndex=2
				end
				if(self.battleList[3] and self.battleList[3][battleIndex])then
					if(self.battleList[3][battleIndex].winnerID~=self.battleList[3][battleIndex]["id"..playerIndex] or self.battleList[3][battleIndex]["player"..playerIndex]==nil)then
						line1:setColor(self.loserColor)
						line2:setColor(self.loserColor)
					end
				end
			end
		end
	end
	--round 4 line
	local roundStatus=worldWarVoApi:getRoundStatus(self.type,4)
	local lineStartX=self.nameTb[1]:getPositionX() + nameSize.width + horizonLineLength*3

	local lineLeft=self:getLine((self.nameTb[16]:getPositionX() - nameSize.width - horizonLineLength*3 - lineStartX)/2)
	lineLeft:setAnchorPoint(ccp(0,0.5))
	lineLeft:setPosition(lineStartX,self.rootCellHeight - nameSizeSpace*4)
	self.rootCell:addChild(lineLeft,1)

	local lineRight=self:getLine((self.nameTb[16]:getPositionX() - nameSize.width - horizonLineLength*3 - lineStartX)/2)
	lineRight:setAnchorPoint(ccp(1,0.5))
	lineRight:setPosition(self.nameTb[16]:getPositionX() - nameSize.width - horizonLineLength*3,self.rootCellHeight - nameSizeSpace*4)
	self.rootCell:addChild(lineRight,1)

	local lineChampion=self:getLine(60)
	lineChampion:setAnchorPoint(ccp(0,0.5))
	lineChampion:setPosition(self.rootCellWidth/2,self.rootCellHeight - nameSizeSpace*4)
	lineChampion:setRotation(-90)
	self.rootCell:addChild(lineChampion,1)

	if(roundStatus==0)then
		local vSp=LuaCCSprite:createWithSpriteFrameName("v.png",function ( ... )end)
		local sSp=LuaCCSprite:createWithSpriteFrameName("s.png",function ( ... )end)
		vSp:setScale(0.5)
		sSp:setScale(0.5)
		vSp:setPosition(self.rootCellWidth/2 - 30,self.rootCellHeight/2 + 5)
		sSp:setPosition(self.rootCellWidth/2 + 30,self.rootCellHeight/2 + 5)
		self.rootCell:addChild(vSp,2)
		self.rootCell:addChild(sSp,2)
	elseif(roundStatus==10)then
		if(self.battleList[4][1] and self.battleList[4][1].player1 and self.battleList[4][1].player2)then
			self:addBtnToBackground(1,401,self.rootCellWidth/2,lineChampion:getPositionY(),onSendFlower)
		end
	elseif(roundStatus>=20)then
		if(self.battleList[4][1] and self.battleList[4][1].player1 and self.battleList[4][1].player2)then
			self:addBtnToBackground(2,401,self.rootCellWidth/2,lineChampion:getPositionY(),onWatch)
		end
		if(roundStatus>=30)then
			if(self.battleList[4] and self.battleList[4][1])then
				if(self.battleList[4][1].winnerID~=self.battleList[4][1]["id"..1])then
					lineLeft:setColor(self.loserColor)
				else
					lineRight:setColor(self.loserColor)
				end
			end
		end
	end
end

function worldWarScheduleScene:initTimeDesc()
	local timeTb=worldWarVoApi:getBattleTimeList(self.type)
	for i=1,4 do
		local timeDescLb
		if(i==1)then
			timeDescLb=GetTTFLabel(getlocal("world_war_groupChampion"),25)
		else
			timeDescLb=GetTTFLabel(getlocal("world_war_knockOutDesc",{math.pow(2,i),math.pow(2,i-1)}),25)
		end
		timeDescLb:setColor(G_ColorYellowPro)
		timeDescLb:setPosition(self.rootCellWidth/2,125 + (i-1)*57)
		self.rootCell:addChild(timeDescLb,2)
		local timeLb=GetTTFLabel(G_getDataTimeStr(timeTb[5-i],true),25)
		timeLb:setPosition(self.rootCellWidth/2,100 + (i-1)*57)
		self.rootCell:addChild(timeLb,2)
	end
end

function worldWarScheduleScene:initBtn()
	local function onClickInfo()
		PlayEffect(audioCfg.mouseClick)
		local contentTb={getlocal("world_war_scheduleInfo10"),getlocal("world_war_scheduleInfo9"),getlocal("world_war_scheduleInfo8"),getlocal("world_war_scheduleInfo7"),getlocal("world_war_scheduleInfo6"),getlocal("world_war_scheduleInfo5"),getlocal("world_war_scheduleInfo4"),getlocal("world_war_scheduleInfo3"),getlocal("world_war_scheduleInfo2"),getlocal("world_war_scheduleInfo1")}
		smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("help"),contentTb,{},true,self.layerNum+1)
	end
	local descItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickInfo,2,getlocal("world_war_scheduleInfoBtn"),25)
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

function worldWarScheduleScene:showSendFlowerDialog(roundIndex,battleIndex)
	local data=self.battleList[roundIndex][battleIndex]
	if(data and data.player1 and data.player2)then
		worldWarVoApi:showFlowerDialog(self.type,data,self.layerNum+1)
	end
end

function worldWarScheduleScene:showBattleDialog(roundIndex,battleIndex)
	local data=self.battleList[roundIndex][battleIndex]
	if(data and data.player1 and data.player2)then
		worldWarVoApi:showBattleDialog(self.type,data,false,self.layerNum+1)
	end
end

function worldWarScheduleScene:getLine(length)
	local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line:setColor(self.winnerColor)
	local lineSize=line:getContentSize()
	line:setScaleX(length/lineSize.width)
	line:setScaleY(5/lineSize.height)
	return line
end

function worldWarScheduleScene:addBtnToBackground(type,tag,posX,posY,callback)
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
	self.rootCell:addChild(menu,2)
end

function worldWarScheduleScene:showPlayerInfo(battleID,playerIndex,champion)
	if(champion~=true)then
		local battleData=self.battleList[1][battleID]
		if(battleData["player"..playerIndex])then
			local playerData=battleData["player"..playerIndex]
			worldWarVoApi:showPlayerDetailDialog(playerData,self.layerNum+1)
		end
	else
		local roundStatus=worldWarVoApi:getRoundStatus(self.type,4)
		if(roundStatus>=30 and self.battleList and self.battleList[4] and self.battleList[4][1])then
			local battleData=self.battleList[4][1]
			if(battleData.winnerID)then
				local playerData=worldWarVoApi:getPlayer(battleData.winnerID)
				if(playerData)then
					worldWarVoApi:showPlayerDetailDialog(playerData,self.layerNum+1)
				end
			end
		end
	end
end

function worldWarScheduleScene:initRefreshTime()
	local zeroTime=G_getWeeTs(worldWarVoApi:getBattleTimeList(self.type)[1]) - 86400
	local lastPMatchTime=zeroTime + worldWarCfg["pmatchendtime"..self.type][1]*3600 + worldWarCfg["pmatchendtime"..self.type][2]*60
	if(base.serverTime<lastPMatchTime)then
		self.refreshTime=lastPMatchTime
	else
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
end

function worldWarScheduleScene:tick()
	if(base.serverTime>self.refreshTime)then
		local function callback()
			if(self.rootTv)then
				local recordPoint = self.rootTv:getRecordPoint()
				self.rootTv:reloadData()
				self.rootTv:recoverToRecordPoint(recordPoint)
			end
		end
		worldWarVoApi:getScheduleInfo(self.type,callback)
	end
end