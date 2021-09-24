serverWarPersonalBattleDialog=smallDialog:new()

function serverWarPersonalBattleDialog:new(data,roundIndex)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=500
	self.dialogHeight=850

	self.data=data
	self.roundIndex=roundIndex
	return nc
end

function serverWarPersonalBattleDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self.dialogLayer=CCLayer:create()
	self:initContent()
	self:show()
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function serverWarPersonalBattleDialog:initContent()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
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
	
	local titleLb=GetTTFLabel(getlocal("arena_fightRecord"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local posY=self.dialogHeight-85

	local roundTitleLb
	if(self.roundIndex==0)then
		roundTitleLb = GetTTFLabel(getlocal("serverwar_groupMatch"),28)
	else
		roundTitleLb = GetTTFLabel(getlocal("serverwar_roundIndex",{self.roundIndex}),28)
	end
	roundTitleLb:setColor(G_ColorYellowPro)
	roundTitleLb:setPosition(ccp(self.dialogWidth/2,posY-20))
	dialogBg:addChild(roundTitleLb)
	posY=posY-35

	if(self.roundIndex>0)then
		local groupLb
		if(self.roundIndex<7)then
			if(tonumber(self.data.groupID)==1)then
				groupLb = GetTTFLabel(getlocal("serverwar_groupWin"),25)
			else
				groupLb = GetTTFLabel(getlocal("serverwar_groupFail"),25)
			end
		else
			groupLb = GetTTFLabel(getlocal("serverwar_finalFight"),25)
		end
		groupLb:setColor(G_ColorYellowPro)
		groupLb:setPosition(ccp(self.dialogWidth/2,posY-15))
		dialogBg:addChild(groupLb)
	end
	posY=posY-30
    local vsPic1=CCSprite:createWithSpriteFrameName("v.png")
    vsPic1:setScale(0.7)
    vsPic1:setPosition(ccp(self.dialogWidth/2-30,posY-70))
    dialogBg:addChild(vsPic1)
    local vsPic2=CCSprite:createWithSpriteFrameName("s.png")
    vsPic2:setScale(0.7)
    vsPic2:setPosition(ccp(self.dialogWidth/2+30,posY-70))
    dialogBg:addChild(vsPic2)
	local roundStatus=serverWarPersonalVoApi:getRoundStatus(self.roundIndex)
	for i=1,2 do
		local headBorder = CCSprite:createWithSpriteFrameName("headerBgSilver.png")
		local posX
		if(i==1)then
			posX=5+(self.dialogWidth-10)/4-10
		else
			posX=5+(self.dialogWidth-10)*3/4+10
		end
		headBorder:setPosition(ccp(posX,posY-70))
		dialogBg:addChild(headBorder)

		local playerData=self.data["player"..i]
		--local headPic="photo"..playerData.pic..".png"
		--local playerPic = CCSprite:createWithSpriteFrameName(headPic)
        local playerPic = playerVoApi:getPersonPhotoSp(playerData.pic)
		playerPic:setScale(100/playerPic:getContentSize().width)
		playerPic:setPosition(ccp(posX,posY-70))
		dialogBg:addChild(playerPic,1)
		if(roundStatus==30)then
			local medal
			if(self.data.winnerID==self.data["id"..i])then
				medal=CCSprite:createWithSpriteFrameName("winnerMedal.png")
			else
				medal=CCSprite:createWithSpriteFrameName("loserMedal.png")
			end
			medal:setScale(0.8)
			medal:setPosition(ccp(posX,posY-140))
			dialogBg:addChild(medal,2)
		end

		local serverLb=GetTTFLabel(playerData.serverName,25)
		serverLb:setColor(G_ColorYellowPro)
		serverLb:setPosition(ccp(posX,posY-190))
		dialogBg:addChild(serverLb)

		local nameLb=GetTTFLabel(playerData.name,25)
		nameLb:setColor(G_ColorYellowPro)
		nameLb:setPosition(ccp(posX,posY-220))
		dialogBg:addChild(nameLb)
	end

	posY=posY-240
	local capInSet = CCRect(20, 20, 10, 10)
	if(roundStatus>=20 and roundStatus<30)then
		base:addNeedRefresh(self)
	end
	for i=1,3 do
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",capInSet,nilFunc)
		titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,40))
		titleBg:setScaleX(self.dialogWidth/titleBg:getContentSize().width)
		titleBg:setPosition(ccp(self.dialogWidth/2,posY-20))
		dialogBg:addChild(titleBg)
		local landformStr
		if(self.data.landformTb and self.data.landformTb[i])then
			landformStr=" ("..getlocal("world_ground_name_"..self.data.landformTb[i])..")"
		else
			landformStr=""
		end
		local indexTitle=GetTTFLabel(getlocal("serverwar_battle_num",{i})..landformStr,25)
		indexTitle:setColor(G_ColorYellowPro)
		indexTitle:setPosition(ccp(self.dialogWidth/2,posY-20))
		dialogBg:addChild(indexTitle,1)

		if(roundStatus==20+i)then
			local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
			cellBg:setContentSize(CCSizeMake(self.dialogWidth-10,95))
			cellBg:setPosition(ccp(self.dialogWidth/2,posY-40-50))
			dialogBg:addChild(cellBg)
			self.countDown=serverWarPersonalVoApi:getBattleTimeList()[self.roundIndex+1]+i*serverWarPersonalCfg.battleTime-base.serverTime
			self.countDownLb=GetTTFLabel(GetTimeStr(self.countDown),25)
			self.countDownLb:setColor(G_ColorYellowPro)
			self.countDownLb:setPosition(self.dialogWidth/2,posY-40-50+15)
			dialogBg:addChild(self.countDownLb,1)
			local descLb=GetTTFLabel(getlocal("serverwar_battle_ing"),25)
			descLb:setPosition(self.dialogWidth/2,posY-40-50-15)
			dialogBg:addChild(descLb)
		elseif(roundStatus>20+i)then
			local winnerBg=LuaCCScale9Sprite:createWithSpriteFrameName("winnerBg.png",CCRect(10,10,10,10),nilFunc)
			winnerBg:setContentSize(CCSizeMake((self.dialogWidth-10)/2,95))
			local winnerMedal=CCSprite:createWithSpriteFrameName("winnerMedal.png")
			winnerMedal:setScale(0.6)
			local winnerLb=GetTTFLabel(getlocal("fight_content_result_win"),25)

			local loserBg=LuaCCScale9Sprite:createWithSpriteFrameName("loserBg.png",CCRect(10,10,10,10),nilFunc)
			loserBg:setContentSize(CCSizeMake((self.dialogWidth-10)/2,95))
			local loserMedal=CCSprite:createWithSpriteFrameName("loserMedal.png")
			loserMedal:setScale(0.6)
			local loserLb=GetTTFLabel(getlocal("fight_content_result_defeat"),25)

			local bg1,bg2,medal1,medal2,lb1,lb2
			if(self.data.resultTb[i]==self.data.id1)then
				bg1,medal1,lb1=winnerBg,winnerMedal,winnerLb
				bg2,medal2,lb2=loserBg,loserMedal,loserLb
			else
				bg1,medal1,lb1=loserBg,loserMedal,loserLb
				bg2,medal2,lb2=winnerBg,winnerMedal,winnerLb
			end
			bg1:setAnchorPoint(ccp(1,0.5))
			bg1:setPosition(5+(self.dialogWidth-10)/2,posY-40-50)
			self.bgLayer:addChild(bg1)
			medal1:setPosition(5+(self.dialogWidth-10)/4,posY-40-50-15)
			self.bgLayer:addChild(medal1)
			lb1:setPosition(5+(self.dialogWidth-10)/4,posY-40-50+20)
			self.bgLayer:addChild(lb1)

			bg2:setAnchorPoint(ccp(1,0.5))
			bg2:setPosition(5+(self.dialogWidth-10)/2,posY-40-50)
			bg2:setRotation(180)
			self.bgLayer:addChild(bg2)
			medal2:setPosition(5+(self.dialogWidth-10)*3/4,posY-40-50-15)
			self.bgLayer:addChild(medal2)
			lb2:setPosition(5+(self.dialogWidth-10)*3/4,posY-40-50+20)
			self.bgLayer:addChild(lb2)

			local function onWatch()
				self:watch(i)
			end
			local menuItem=GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn_down.png",onWatch)
			menuItem:setScale(0.8)
			local menu=CCMenu:createWithItem(menuItem)
			menu:setTouchPriority(-(self.layerNum-1)*20-2)
			menu:setPosition(ccp(5+(self.dialogWidth-10)/2,posY-40-50))
			self.bgLayer:addChild(menu)
		elseif(roundStatus<20+i)then
			local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
			cellBg:setContentSize(CCSizeMake(self.dialogWidth-10,95))
			cellBg:setPosition(ccp(self.dialogWidth/2,posY-40-50))
			dialogBg:addChild(cellBg)
			local descLb=GetTTFLabel(getlocal("waiting"),25)
			descLb:setPosition(self.dialogWidth/2,posY-40-50)
			dialogBg:addChild(descLb)
		end


		posY=posY-140
	end
	self.dialogLayer:addChild(self.bgLayer,1)
end

function serverWarPersonalBattleDialog:watch(i)
	if G_checkClickEnable()==false then
		do return end
	else
		base.setWaitTime=G_getCurDeviceMillTime()
	end
	PlayEffect(audioCfg.mouseClick)
	serverWarPersonalVoApi:getBattleReport(self.data.roundID,self.data.groupID,self.data.battleID,i)
end

function serverWarPersonalBattleDialog:tick()
	self.countDown=self.countDown-1
	if(self.countDownLb)then
		self.countDownLb:setString(GetTimeStr(self.countDown))
	end
	if(self.countDown<=0)then
		base:removeFromNeedRefresh(self)
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
		self:initContent()
	end
end