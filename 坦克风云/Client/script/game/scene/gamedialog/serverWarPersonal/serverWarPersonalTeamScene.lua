serverWarPersonalTeamScene=
{
	bgLayer=nil,
	clayer=nil,
	background=nil,
	minScale=1,
	maxScale=1.7,
	winnerColor=ccc3(0,199,131),
	loserColor=ccc3(145,145,145),
	isShow=false,
}

function serverWarPersonalTeamScene:show(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.touchArr={}
	self:initBackground()
	self:initTitle()
	self:initTick()
	self:initContent()
	self.isShow=true
	sceneGame:addChild(self.bgLayer,self.layerNum)
	base.allShowedCommonDialog=base.allShowedCommonDialog+1
	table.insert(base.commonDialogOpened_WeakTb,self)
end

function serverWarPersonalTeamScene:initBackground()
	local nameSize=CCSizeMake((G_VisibleSizeWidth/2-5*3)/2,45)
	self.titleHeight=170
	self.totalWidth=G_VisibleSizeWidth
	self.totalHeight=nameSize.height*4*4+20
	if(self.totalHeight<G_VisibleSizeHeight-self.titleHeight)then
		self.totalHeight=G_VisibleSizeHeight-self.titleHeight
	end

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
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-3,false)
	self.clayer:setPosition(ccp(0,G_VisibleSizeHeight-self.titleHeight-self.totalHeight))
	self.bgLayer:addChild(self.clayer)

	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),function ( ... )end)
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	titleBg:setPosition(ccp(0,G_VisibleSizeHeight))
	titleBg:setTouchPriority(-(self.layerNum-1)*20-8)
	self.bgLayer:addChild(titleBg,2)

	local titleBg2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... ) end)
	titleBg2:setTouchPriority(-(self.layerNum-1)*20-8)
	titleBg2:setAnchorPoint(ccp(0,1))
	titleBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.titleHeight-85))
	titleBg2:setPosition(ccp(0,G_VisibleSizeHeight-85))
	self.bgLayer:addChild(titleBg2,2)

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

function serverWarPersonalTeamScene:initTitle()
	local titleLb1=GetTTFLabel(getlocal("serverwar_groupMatch"),33)
	titleLb1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85/2))
	self.bgLayer:addChild(titleLb1,2)

	local titleLb2=GetTTFLabel(getlocal("serverwar_battleTime"),28)
	titleLb2:setColor(G_ColorYellowPro)
	titleLb2:setAnchorPoint(ccp(0.5,1))
	titleLb2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85-10))
	self.bgLayer:addChild(titleLb2,2)

	local battleTime=serverWarPersonalVoApi:getBattleTimeList()[1]
	if(battleTime)then
		battleTime=G_getDataTimeStr(battleTime,true)
	else
		battleTime=getlocal("alliance_info_content")
	end
	local titleLb3=GetTTFLabel(battleTime,25)
	titleLb3:setColor(G_ColorYellowPro)
	titleLb3:setAnchorPoint(ccp(0.5,1))
	titleLb3:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85-10-32))
	self.bgLayer:addChild(titleLb3,2)
end

function serverWarPersonalTeamScene:touchEvent(fn,x,y,touch)
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

function serverWarPersonalTeamScene:checkBound(pos)
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

function serverWarPersonalTeamScene:initContent()
	self.background=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20,20,10,10),function ( ... )end)
	self.background:setAnchorPoint(ccp(0,0))
	self.background:setTouchPriority(-(self.layerNum-1)*20)
	self.background:setContentSize(CCSizeMake(self.totalWidth,self.totalHeight))
	self.background:setPosition(ccp(0,0))
	self.clayer:addChild(self.background)
	self:initSchedule()
end

function serverWarPersonalTeamScene:initSchedule()
	local posY=G_VisibleSizeHeight-self.titleHeight-10

	local nameSize=CCSizeMake((G_VisibleSizeWidth/2-5*3)/2,45)
	local cellWidth,cellHeight=5+nameSize.width+5+nameSize.width+5,nameSize.height*4
	self.battleList=serverWarPersonalVoApi:getTeamBattleList()
	local function showPlayerInfo(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.isMoved==true)then
			return
		end
		local battleIndex=math.floor(tag/100)
		local posIndex=tag%100
		self:showPlayerInfo(battleIndex,posIndex)
	end
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(0)
	local battleIndex=1
	for i=1,4 do
		for j=1,2 do
			local basicX,basicY=(j-1)*cellWidth,self.totalHeight-i*cellHeight
			if G_getIphoneType() == G_iphoneX then
				basicY = basicY -100
			end
			local groupName=GetTTFLabel(getlocal("serverwar_groupName"..((i-1)*2+j)),25)
			groupName:setColor(G_ColorYellowPro)
			groupName:setAnchorPoint(ccp(0.5,0))
			groupName:setPosition(ccp(basicX+cellWidth/2,basicY+5))
			self.background:addChild(groupName,1)

			local leftNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
			leftNameBg:setContentSize(nameSize)
			leftNameBg:setAnchorPoint(ccp(1,0))
			leftNameBg:setPosition(ccp(basicX+cellWidth/2,basicY+35))
			leftNameBg:setTouchPriority(-(self.layerNum-1)*20-1)
			leftNameBg:setTag(battleIndex*100+1)
			self.background:addChild(leftNameBg,1)

			local rightNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
			rightNameBg:setContentSize(nameSize)
			rightNameBg:setAnchorPoint(ccp(0,0))
			rightNameBg:setPosition(ccp(basicX+cellWidth/2,basicY+35))
			rightNameBg:setTouchPriority(-(self.layerNum-1)*20-1)
			rightNameBg:setTag(battleIndex*100+2)
			self.background:addChild(rightNameBg,1)

			local topNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42,26,10,10),showPlayerInfo)
			topNameBg:setContentSize(nameSize)
			topNameBg:setAnchorPoint(ccp(0.5,0))
			topNameBg:setPosition(ccp(basicX+cellWidth/2,basicY+35+nameSize.height*2))
			topNameBg:setTouchPriority(-(self.layerNum-1)*20-1)
			topNameBg:setTag(battleIndex*100+3)
			self.background:addChild(topNameBg,1)
			if(roundStatus<30)then
				local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
				unknownIcon:setScale(0.7)
				unknownIcon:setPosition(getCenterPoint(topNameBg))
				topNameBg:addChild(unknownIcon)
			end

			local lineLength=(topNameBg:getPositionY()-leftNameBg:getPositionY()-nameSize.height)/2+5
			local lineLeft1=self:getLine(lineLength)
			lineLeft1:setAnchorPoint(ccp(0,0.5))
			lineLeft1:setPosition(ccp(leftNameBg:getPositionX()-nameSize.width/2,leftNameBg:getPositionY()+nameSize.height-5))
			lineLeft1:setRotation(-90)
			self.background:addChild(lineLeft1)

			local lineRight1=self:getLine(lineLength)
			lineRight1:setAnchorPoint(ccp(0,0.5))
			lineRight1:setPosition(ccp(rightNameBg:getPositionX()+nameSize.width/2,rightNameBg:getPositionY()+nameSize.height-5))
			lineRight1:setRotation(-90)
			self.background:addChild(lineRight1)

			local line2Length=(nameSize.width+8)/2
			local lineLeft2=self:getLine(line2Length)
			lineLeft2:setAnchorPoint(ccp(1,0.5))
			lineLeft2:setPosition(ccp(basicX+cellWidth/2+1,(leftNameBg:getPositionY()+nameSize.height+topNameBg:getPositionY())/2))
			self.background:addChild(lineLeft2)

			local lineRight2=self:getLine(line2Length)
			lineRight2:setAnchorPoint(ccp(0,0.5))
			lineRight2:setPosition(ccp(basicX+cellWidth/2-1,(leftNameBg:getPositionY()+nameSize.height+topNameBg:getPositionY())/2))
			self.background:addChild(lineRight2)

			local lineTop=self:getLine(lineLength)
			lineTop:setAnchorPoint(ccp(0,0.5))
			lineTop:setPosition(ccp(basicX+cellWidth/2,topNameBg:getPositionY()+5))
			lineTop:setRotation(90)
			self.background:addChild(lineTop)

			if(self.battleList and self.battleList[battleIndex] and self.battleList[battleIndex].player1 and self.battleList[battleIndex].player2)then
				local p1ServerLb=GetTTFLabelWrap(self.battleList[battleIndex].player1.serverName,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
				p1ServerLb:setAnchorPoint(ccp(0.5,0))
				p1ServerLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
				leftNameBg:addChild(p1ServerLb)

				local p1NameLb=GetTTFLabelWrap(self.battleList[battleIndex].player1.name,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				p1NameLb:setAnchorPoint(ccp(0.5,1))
				p1NameLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
				leftNameBg:addChild(p1NameLb)

				local p2ServerLb=GetTTFLabelWrap(self.battleList[battleIndex].player2.serverName,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
				p2ServerLb:setAnchorPoint(ccp(0.5,0))
				p2ServerLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
				rightNameBg:addChild(p2ServerLb)

				local p2NameLb=GetTTFLabelWrap(self.battleList[battleIndex].player2.name,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				p2NameLb:setAnchorPoint(ccp(0.5,1))
				p2NameLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
				rightNameBg:addChild(p2NameLb)
				--下注时间
				if(roundStatus==10)then
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
							battleIndex=tag
							self:showSendFlowerDialog(battleIndex)
						end
					end
					local betItem=GetButtonItem("flowerBtn.png","flowerBtn_down.png","flowerBtn_down.png",onSendFlower,battleIndex)
					betItem:setScale(0.6)
					local betButton=CCMenu:createWithItem(betItem)
					betButton:setTouchPriority(-(self.layerNum-1)*20-2)
					betButton:setPosition(ccp(basicX+cellWidth/2,(leftNameBg:getPositionY()+nameSize.height+topNameBg:getPositionY())/2))
					self.background:addChild(betButton,2)
				--开战之后
				elseif(roundStatus>=20)then
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
							battleIndex=tag
							self:showBattleDialog(battleIndex)
						end
					end
					local watchItem=GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn_down.png",onWatch,battleIndex)
					watchItem:setScale(0.6)
					local watchBtn=CCMenu:createWithItem(watchItem)
					watchBtn:setTouchPriority(-(self.layerNum-1)*20-2)
					watchBtn:setPosition(ccp(basicX+cellWidth/2,(leftNameBg:getPositionY()+nameSize.height+topNameBg:getPositionY())/2))
					self.background:addChild(watchBtn,2)
					--开战15分钟以后显示战斗结果
					if(roundStatus>=30)then
						local winnerIndex
						if(self.battleList[battleIndex].winnerID==self.battleList[battleIndex].id1)then
							winnerIndex=1
							lineRight1:setColor(self.loserColor)
							lineRight2:setColor(self.loserColor)
						elseif(self.battleList[battleIndex].winnerID==self.battleList[battleIndex].id2)then
							winnerIndex=2
							lineLeft1:setColor(self.loserColor)
							lineLeft2:setColor(self.loserColor)
						end
						local winnerServerLb=GetTTFLabelWrap(self.battleList[battleIndex].winner.serverName,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
						winnerServerLb:setAnchorPoint(ccp(0.5,0))
						winnerServerLb:setPosition(ccp(nameSize.width/2,nameSize.height/2+1))
						topNameBg:addChild(winnerServerLb)
						local winnerNameLb=GetTTFLabelWrap(self.battleList[battleIndex].winner.name,12,CCSizeMake(nameSize.width,17),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
						winnerNameLb:setAnchorPoint(ccp(0.5,1))
						winnerNameLb:setPosition(ccp(nameSize.width/2,nameSize.height/2-1))
						topNameBg:addChild(winnerNameLb)
					end
				end
			else
				local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
				unknownIcon:setScale(0.7)
				unknownIcon:setPosition(getCenterPoint(leftNameBg))
				leftNameBg:addChild(unknownIcon)
				local unknownIcon=CCSprite:createWithSpriteFrameName("questionMark.png")
				unknownIcon:setScale(0.7)
				unknownIcon:setPosition(getCenterPoint(rightNameBg))
				rightNameBg:addChild(unknownIcon)
			end
			battleIndex=battleIndex+1
		end
	end
end

function serverWarPersonalTeamScene:getLine(length)
	local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
	line:setColor(self.winnerColor)
	local lineSize=line:getContentSize()
	line:setScaleX(length/lineSize.width)
	line:setScaleY(5/lineSize.height)
	return line
end

function serverWarPersonalTeamScene:showPlayerInfo(battleIndex,posIndex)
	local data
	if(posIndex==3)then
		local roundStatus=serverWarPersonalVoApi:getRoundStatus(0)
		if(roundStatus>=30)then
			if(self.battleList[battleIndex] and self.battleList[battleIndex].winnerID)then
				if(self.battleList[battleIndex].winnerID==self.battleList[battleIndex].id1)then
					data=self.battleList[battleIndex].player1
				else
					data=self.battleList[battleIndex].player2
				end
			end
		end
	elseif(self.battleList[battleIndex])then
		data=self.battleList[battleIndex]["player"..posIndex]
	end
	if(data)then
		serverWarPersonalVoApi:showPlayerDetailDialog(data,self.layerNum+1)
	end
end

function serverWarPersonalTeamScene:showBattleDialog(battleIndex)
	local data=self.battleList[battleIndex]
	if(data and data.winnerID)then
		serverWarPersonalVoApi:showBattleDialog(data,0,self.layerNum+1)
	end
end

function serverWarPersonalTeamScene:showSendFlowerDialog(battleIndex)
	local data=self.battleList[battleIndex]
	if(data)then
		serverWarPersonalVoApi:showFlowerDialog(data,0,self.layerNum+1)
	end
end

function serverWarPersonalTeamScene:initTick()
	self.curStatus=serverWarPersonalVoApi:getRoundStatus(0)
	if(self.curStatus<30)then
		local battleTime=serverWarPersonalVoApi:getBattleTimeList()[1]
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

function serverWarPersonalTeamScene:tick()
	self.countDown=self.countDown-1
	if(self.countDown<=0)then
		base:removeFromNeedRefresh(self)
		local function refresh()
			self.background:removeFromParentAndCleanup(true)
			self.background=nil
			self:initTick()
			self:initContent()
		end
		if(self.curStatus<20)then
			serverWarPersonalVoApi:getWarInfo(refresh)
		else
			refresh()
		end
	end
end

function serverWarPersonalTeamScene:setVisible(visible)
	if(self and self.bgLayer)then
		self.bgLayer:setVisible(visible)
	end
end

function serverWarPersonalTeamScene:close()
	base:removeFromNeedRefresh(self)
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