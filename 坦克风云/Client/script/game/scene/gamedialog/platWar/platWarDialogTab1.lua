platWarDialogTab1={}
function platWarDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function platWarDialogTab1:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initBg()
	self:initProgress()
	local function eventListener(event,data)
		self:refreshProgress()
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("platWar.npcCount",eventListener)
	return self.bgLayer
end

function platWarDialogTab1:initBg()
	local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	local posY=G_VisibleSizeHeight - 200
	local posterBg=CCSprite:createWithSpriteFrameName("platWarPosterBg.jpg")
	posterBg:setScaleX((G_VisibleSizeWidth - 44)/posterBg:getContentSize().width)
	posterBg:setScaleY((G_VisibleSizeHeight - 235)/posterBg:getContentSize().height)
	posterBg:setAnchorPoint(ccp(0.5,1))
	posterBg:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(posterBg)
	local status=platWarVoApi:checkStatus()
	if(status<20)then
		local leftTime=GetTimeStr(platWarVoApi.startTime + platWarCfg.preparetime*3600 - base.serverTime)
		self.statusLb=GetTTFLabelWrap(getlocal("world_war_matchStatus1").."\n"..getlocal("costTime1",{leftTime}),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	elseif(status<30)then
		local leftTime=GetTimeStr(platWarVoApi.startTime + platWarCfg.preparetime*3600 + platWarCfg.battletime*3600 - base.serverTime)
		self.statusLb=GetTTFLabel(getlocal("serverwarteam_battleing").."\n"..getlocal("costTime1",{leftTime}),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	else
		local leftTime=GetTimeStr(math.max(0,platWarVoApi.endTime - base.serverTime))
		self.statusLb=GetTTFLabel(getlocal("serverwarteam_all_end").."\n"..getlocal("costTime1",{leftTime}),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	end
	self.statusLb:setColor(G_ColorYellowPro)
	self.statusLb:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(self.statusLb,2)
	self.platList=platWarVoApi:getPlatList()
	local platNameBg1=CCSprite:createWithSpriteFrameName("platWarNameBg1.png")
	platNameBg1:setScaleY(60/platNameBg1:getContentSize().height)
	platNameBg1:setAnchorPoint(ccp(0,0.5))
	platNameBg1:setPosition(ccp(20,posY - 65))
	self.bgLayer:addChild(platNameBg1)
	local platNameBg2=CCSprite:createWithSpriteFrameName("platWarNameBg2.png")
	platNameBg2:setScaleY(60/platNameBg2:getContentSize().height)
	platNameBg2:setAnchorPoint(ccp(1,0.5))
	platNameBg2:setPosition(ccp(G_VisibleSizeWidth - 20,posY - 65))
	platNameBg2:setFlipX(true)
	self.bgLayer:addChild(platNameBg2)

	local function onClickPoster1( ... )
		platWarVoApi:showPlayerListDialog(self.platList[1][1],self.layerNum + 1)
	end
	local posterItem1=GetButtonItem("platWar_team1.png","platWar_team1_down.png","platWar_team1_down.png",onClickPoster1)
	local posterBtn1=CCMenu:createWithItem(posterItem1)
	posterBtn1:setTouchPriority(-(self.layerNum-1)*20-2)
	posterBtn1:setPosition(ccp(70,posY - 45))
	self.bgLayer:addChild(posterBtn1,1)
	local function onClickPoster2( ... )
		platWarVoApi:showPlayerListDialog(self.platList[2][1],self.layerNum + 1)
	end
	local posterItem2=GetButtonItem("platWar_team2.png","platWar_team2_down.png","platWar_team2_down.png",onClickPoster2)
	local posterBtn2=CCMenu:createWithItem(posterItem2)
	posterBtn2:setTouchPriority(-(self.layerNum-1)*20-2)
	posterBtn2:setPosition(ccp(G_VisibleSizeWidth - 70,posY - 45))
	self.bgLayer:addChild(posterBtn2,1)

	local platName1=GetTTFLabelWrap(self.platList[1][2],25,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	platName1:setPosition(ccp(190,posY - 65))
	self.bgLayer:addChild(platName1,2)
	local platName2=GetTTFLabelWrap(self.platList[2][2],25,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	platName2:setPosition(ccp(G_VisibleSizeWidth - 190,posY - 65))
	self.bgLayer:addChild(platName2,2)

	posY = posY - 100
	local poster1
	if(platWarVoApi:getWinnerID()==platWarVoApi:getPlatList()[2][1])then
		poster1=GraySprite:create("public/platWar/poster1/pw_101.png")
		local posterClickBg=LuaCCSprite:createWithFileName("public/platWar/poster1/pw_101.png",onClickPoster1)
		posterClickBg:setTouchPriority(-(self.layerNum-1)*20-2)
		posterClickBg:setOpacity(0)
		posterClickBg:setAnchorPoint(ccp(0,1))
		posterClickBg:setPosition(ccp(50,posY + 30))
		self.bgLayer:addChild(posterClickBg)
	else
		poster1=LuaCCSprite:createWithFileName("public/platWar/poster1/pw_101.png",onClickPoster1)
		poster1:setTouchPriority(-(self.layerNum-1)*20-2)
	end
	local animation=CCAnimation:create()
	for i=2,12 do
		local index
		if(i<10)then
			index="0"..i
		else
			index=i
		end
		animation:addSpriteFrameWithFileName("public/platWar/poster1/pw_1"..index..".png")
	end
	animation:setDelayPerUnit(0.07)
	local animate=CCAnimate:create(animation)
	local repeatForever=CCRepeatForever:create(animate)
	poster1:runAction(repeatForever)
	poster1:setFlipX(true)
	poster1:setAnchorPoint(ccp(0,1))
	poster1:setPosition(ccp(50,posY + 30))
	self.bgLayer:addChild(poster1)
	local poster2
	if(platWarVoApi:getWinnerID()==platWarVoApi:getPlatList()[1][1])then
		poster2=GraySprite:create("public/platWar/poster2/pw_201.png")
		local posterClickBg=LuaCCSprite:createWithFileName("public/platWar/poster2/pw_201.png",onClickPoster2)
		posterClickBg:setTouchPriority(-(self.layerNum-1)*20-2)
		posterClickBg:setOpacity(0)
		posterClickBg:setAnchorPoint(ccp(1,1))
		posterClickBg:setPosition(ccp(G_VisibleSizeWidth - 50,posY + 30))
		self.bgLayer:addChild(posterClickBg)
	else
		poster2=LuaCCSprite:createWithFileName("public/platWar/poster2/pw_201.png",onClickPoster2)
		poster2:setTouchPriority(-(self.layerNum-1)*20-2)
	end
	local animation=CCAnimation:create()
	for i=2,12 do
		local index
		if(i<10)then
			index="0"..i
		else
			index=i
		end
		animation:addSpriteFrameWithFileName("public/platWar/poster2/pw_2"..index..".png")
	end
	animation:setDelayPerUnit(0.07)
	local animate=CCAnimate:create(animation)
	local repeatForever=CCRepeatForever:create(animate)
	poster2:runAction(repeatForever)
	poster2:setAnchorPoint(ccp(1,1))
	poster2:setPosition(ccp(G_VisibleSizeWidth - 50,posY + 30))
	self.bgLayer:addChild(poster2)

	if(platWarVoApi:getWinnerID())then
		local winSp=CCSprite:createWithSpriteFrameName("platWarWin.png")
		local loseSp=CCSprite:createWithSpriteFrameName("platWarLose.png")
		if(platWarVoApi:getWinnerID()==platWarVoApi:getPlatList()[1][1])then
			winSp:setPosition(ccp(190,posY - 50))
			loseSp:setPosition(ccp(G_VisibleSizeWidth - 190,posY - 50))
		else
			winSp:setPosition(ccp(G_VisibleSizeWidth - 190,posY - 50))
			loseSp:setPosition(ccp(190,posY - 50))
		end
		self.bgLayer:addChild(winSp)
		self.bgLayer:addChild(loseSp)
	end

	local vSp=CCSprite:createWithSpriteFrameName("v.png")
	vSp:setScale(0.8)
	vSp:setPosition(ccp(G_VisibleSizeWidth/2 - 40,posY - 130))
	self.bgLayer:addChild(vSp)
	local sSp=CCSprite:createWithSpriteFrameName("s.png")
	sSp:setScale(0.8)
	sSp:setPosition(ccp(G_VisibleSizeWidth/2 + 40,posY - 130))
	self.bgLayer:addChild(sSp)
	local function onViewReward()
		PlayEffect(audioCfg.mouseClick)
		-- platWarVoApi:showSelectRoadSmallDialog(self.layerNum+1)
		platWarVoApi:showRewardDialog(self.layerNum+1)
	end
	local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onViewReward,nil,getlocal("super_weapon_challenge_reward_preview"),strSize2)
	local rewardBtn=CCMenu:createWithItem(rewardItem)
	rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	rewardBtn:setPosition(ccp(120,60))
	self.bgLayer:addChild(rewardBtn)
	local function onEnterBattle()
		PlayEffect(audioCfg.mouseClick)
		local function callback()
			platWarVoApi:showMap(self.layerNum + 1)
		end
		platWarVoApi:getInfo(callback)
	end
	local enterItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onEnterBattle,nil,getlocal("serverwarteam_enter_battlefield"),25)
	local enterBtn=CCMenu:createWithItem(enterItem)
	enterBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	enterBtn:setPosition(ccp(G_VisibleSizeWidth/2,60))
	self.bgLayer:addChild(enterBtn)
	local function onHelp()
		PlayEffect(audioCfg.mouseClick)
		platWarVoApi:showHelpDialog(self.layerNum+1)
	end
	local helpItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onHelp,nil,getlocal("alien_tech_propTitle4"),25)
	local helpBtn=CCMenu:createWithItem(helpItem)
	helpBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	helpBtn:setPosition(ccp(G_VisibleSizeWidth - 120,60))
	self.bgLayer:addChild(helpBtn)
end

function platWarDialogTab1:initProgress()
	self.progressList={}
	self.numLbList={}
	local posY=G_VisibleSizeHeight - 205 - 30 - 360
	local distance
	if(G_isIphone5())then
		distance=(posY - 150)/3
	else
		distance=(posY - 110)/3
	end
	local totalProgressLength=G_VisibleSizeWidth - 204
	for i=1,3 do
		local lb=GetTTFLabel(getlocal("plat_war_progress"..i),25)
		lb:setColor(G_ColorGreen)
		lb:setPosition(ccp(G_VisibleSizeWidth/2,posY - distance*i + 60))
		self.bgLayer:addChild(lb)
		local progressBg=CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
		progressBg:setPosition(ccp(G_VisibleSizeWidth/2,posY - distance*i + 30))
		self.bgLayer:addChild(progressBg)
		local progress1,progress2
		progress1=CCSprite:createWithSpriteFrameName("platWarProgress1.png")
		progress1=CCProgressTimer:create(progress1)
		progress1:setType(kCCProgressTimerTypeBar)
		progress1:setMidpoint(ccp(0,0))
		progress1:setBarChangeRate(ccp(1,0))
		progress1:setPosition(ccp(G_VisibleSizeWidth/2,posY - distance*i + 30))
		progress2=CCSprite:createWithSpriteFrameName("platWarProgress2.png")
		progress2:setPosition(ccp(G_VisibleSizeWidth/2,posY - distance*i + 30))
		self.bgLayer:addChild(progress2)
		self.bgLayer:addChild(progress1)
		local fire=CCSprite:createWithSpriteFrameName("platWarLight1.png")
		self.bgLayer:addChild(fire,1)

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
		fire:runAction(repeatForever)

		local num1,num2,num=0,0,0
		if(i==1)then
			local cityList=platWarVoApi:getCityList()
			for road,tb in pairs(cityList) do
				for point,cityVo in pairs(tb) do
					if(cityVo.side==1)then
						num1=num1 + 1
					elseif(cityVo.side==2)then
						num2=num2 + 1
					end
				end
			end
		elseif(i==2)then
			local troopList=platWarVoApi:getTroopList()
			if(troopList[1])then
				for k,v in pairs(troopList[1]) do
					num1 = num1 + v
				end
			end
			if(troopList[2])then
				for k,v in pairs(troopList[2]) do
					num2 = num2 + v
				end
			end
		else
			local moraleList=platWarVoApi:getMoraleList()
			num1=moraleList[1]
			num2=moraleList[2]
		end
		num=num1 + num2
		if(num==0)then
			fire:setPosition(ccp(G_VisibleSizeWidth/2,posY - distance*i + 30))
			progress1:setPercentage(50)
		else
			fire:setPosition(ccp(G_VisibleSizeWidth/2 - totalProgressLength/2 + totalProgressLength*num1/num,posY - distance*i + 30))
			progress1:setPercentage(num1/num*100)
			if(num1==0 or num1==num)then
				fire:setVisible(false)
			end
		end
		local num1Lb=GetTTFLabel(num1,25)
		num1Lb:setPosition(G_VisibleSizeWidth/2 - totalProgressLength/2,posY - distance*i + 60)
		self.bgLayer:addChild(num1Lb)
		local num2Lb=GetTTFLabel(num2,25)
		num2Lb:setPosition(G_VisibleSizeWidth/2 + totalProgressLength/2,posY - distance*i + 60)
		self.bgLayer:addChild(num2Lb)
		self.progressList[i]={}
		self.progressList[i][1]=progress1
		self.progressList[i][2]=progress2
		self.progressList[i][3]=fire
		self.numLbList[i]={}
		self.numLbList[i][1]=num1Lb
		self.numLbList[i][2]=num2Lb
	end
end

function platWarDialogTab1:tick()
	if(base.serverTime>=platWarVoApi:getBattleExpireTime())then
		local function callback()
			if(platWarVoApi:getWinnerID())then
				self.bgLayer:removeAllChildrenWithCleanup(true)
				self:initBg()
				self:initProgress()
			else
				self:refreshProgress()
			end
		end
		platWarVoApi:refreshBattle(callback)
	end
	local status=platWarVoApi:checkStatus()
	if(status<20)then
		local leftTime=GetTimeStr(platWarVoApi.startTime + platWarCfg.preparetime*3600 - base.serverTime)
		self.statusLb:setString(getlocal("world_war_matchStatus1").."\n"..getlocal("costTime1",{leftTime}))
	elseif(status<30)then
		local leftTime=GetTimeStr(platWarVoApi.startTime + platWarCfg.preparetime*3600 + platWarCfg.battletime*3600 - base.serverTime)
		self.statusLb:setString(getlocal("serverwarteam_battleing").."\n"..getlocal("costTime1",{leftTime}))
	else
		local leftTime=GetTimeStr(math.max(0,platWarVoApi.endTime - base.serverTime))
		self.statusLb:setString(getlocal("serverwarteam_all_end").."\n"..getlocal("costTime1",{leftTime}))
	end
end

function platWarDialogTab1:refreshProgress()
	local totalProgressLength=G_VisibleSizeWidth - 204
	for i=1,3 do
		local progress1=self.progressList[i][1]
		local progress2=self.progressList[i][2]
		local fire=self.progressList[i][3]
		local num1Lb=self.numLbList[i][1]
		local num2Lb=self.numLbList[i][2]
		local num1,num2,num=0,0,0
		if(i==1)then
			local cityList=platWarVoApi:getCityList()
			for road,tb in pairs(cityList) do
				for point,cityVo in pairs(tb) do
					if(cityVo.side==1)then
						num1=num1 + 1
					elseif(cityVo.side==2)then
						num2=num2 + 1
					end
				end
			end
		elseif(i==2)then
			local troopList=platWarVoApi:getTroopList()
			if(troopList[1])then
				for k,v in pairs(troopList[1]) do
					num1 = num1 + v
				end
			end
			if(troopList[2])then
				for k,v in pairs(troopList[2]) do
					num2 = num2 + v
				end
			end
		else
			local moraleList=platWarVoApi:getMoraleList()
			num1=moraleList[1]
			num2=moraleList[2]
		end
		num=num1 + num2
		if(num==0)then
			fire:setPositionX(G_VisibleSizeWidth/2)
			progress1:setPercentage(50)
			fire:setVisible(true)
		else
			fire:setPositionX(G_VisibleSizeWidth/2 - totalProgressLength/2 + totalProgressLength*num1/num)
			progress1:setPercentage(num1/num*100)
			if(num1==0 or num1==num)then
				fire:setVisible(false)
			else
				fire:setVisible(true)
			end
		end
		num1Lb:setString(num1)
		num2Lb:setString(num2)
	end
end

function platWarDialogTab1:dispose()
	eventDispatcher:removeEventListener("platWar.npcCount",self.eventListener)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end