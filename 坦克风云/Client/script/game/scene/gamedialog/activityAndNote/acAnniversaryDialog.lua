--周年庆活动
acAnniversaryDialog=commonDialog:new()

function acAnniversaryDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.acVo=acAnniversaryVoApi:getAcVo()
	nc.costRewardTb={}
	nc.curPage=1
	nc.gameRewardTb={}
	return nc
end

function acAnniversaryDialog:resetTab()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/acAnniversary.plist")
	spriteController:addTexture("public/acAnniversary.png")
	spriteController:addPlist("public/acChunjiepansheng.plist")
	spriteController:addTexture("public/acChunjiepansheng.png")
	spriteController:addPlist("public/acNewYearsEva.plist")
	spriteController:addTexture("public/acNewYearsEva.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
	blueBg:setScaleX(G_VisibleSizeWidth/blueBg:getContentSize().width)
	local num=math.floor((G_VisibleSizeHeight - 85)/blueBg:getContentSize().height)
	local scaleY=(G_VisibleSizeHeight - 85)/blueBg:getContentSize().height/num
	blueBg:setScaleY(scaleY)
	blueBg:setAnchorPoint(ccp(0,0))
	blueBg:setPosition(ccp(0,0))
	self.bgLayer:addChild(blueBg)
	for i=2,num do
		local tmpBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
		tmpBg:setAnchorPoint(ccp(0,0))
		tmpBg:setPosition(0,tmpBg:getContentSize().height*(i - 1))
		blueBg:addChild(tmpBg)
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acAnniversaryDialog:initTableView()
	self:initGameReward()
	self:initCostReward()
end

function acAnniversaryDialog:initGameReward()
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr = {"\n",getlocal("activity_anniversary_info2"),"\n",getlocal("activity_anniversary_info1"),"\n"}
		local tabColor = {nil,G_ColorYellow,nil,G_ColorYellow,nil}
		local sd=smallDialog:new()
		local layer=sd:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum + 1,tabStr,25,tabColor)
		sceneGame:addChild(layer,self.layerNum + 1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11)
	local infoBtn=CCMenu:createWithItem(infoItem)
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	infoBtn:setPosition(G_VisibleSizeWidth - 90,G_VisibleSizeHeight - 140)
	self.bgLayer:addChild(infoBtn)
	local haloSp=CCSprite:createWithSpriteFrameName("anniversaryHalo.png")
	haloSp:setAnchorPoint(ccp(0.5,1))
	haloSp:setScaleY(2)
	haloSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 215)
	self.bgLayer:addChild(haloSp)
	local ribbonSp1=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
	ribbonSp1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 230)
	self.bgLayer:addChild(ribbonSp1)
	local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
	lightSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 160)
	self.bgLayer:addChild(lightSp)
	local ribbonSp2=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_caidai.png",CCRect(85,26,2,2),showInfo)
	ribbonSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth - 80,65))
	ribbonSp2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 215)
	self.bgLayer:addChild(ribbonSp2)
	local timeLb1=GetTTFLabel(getlocal("activity_timeLabel"),25)
	timeLb1:setColor(G_ColorGreen)
	timeLb1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 270)
	self.bgLayer:addChild(timeLb1)
	local timeBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	timeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 310)
	self.bgLayer:addChild(timeBg)
	local timeLb2=GetTTFLabel(activityVoApi:getActivityTimeStr(self.acVo.st,self.acVo.et),25)
	timeLb2:setColor(G_ColorYellowPro)
	timeLb2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 310)
	self.bgLayer:addChild(timeLb2)
	if(G_getCurChoseLanguage()=="cn")then
		local lb1=GetTTFLabel(getlocal("activity_anniversary_birthday1"),25)
		lb1:setColor(G_ColorYellowPro)
		lb1:setAnchorPoint(ccp(1,0.5))
		lb1:setPosition(G_VisibleSizeWidth/2 - 50,G_VisibleSizeHeight - 208)
		self.bgLayer:addChild(lb1)
		local sp1=CCSprite:createWithSpriteFrameName("crackerLight.png")
		sp1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 208)
		self.bgLayer:addChild(sp1)
		local sp2=CCSprite:createWithSpriteFrameName("anniversaryYear.png")
		sp2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 208)
		self.bgLayer:addChild(sp2)
		local lb2=GetTTFLabel(getlocal("activity_anniversary_birthday2"),25)
		lb2:setColor(G_ColorYellowPro)
		lb2:setAnchorPoint(ccp(0,0.5))
		lb2:setPosition(G_VisibleSizeWidth/2 + 50,G_VisibleSizeHeight - 208)
		self.bgLayer:addChild(lb2)
	else
		local lb=GetTTFLabel(getlocal("activity_anniversary_birthday"),25)
		lb:setColor(G_ColorYellowPro)
		lb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 208)
		self.bgLayer:addChild(lb)
	end
	local screenSp=CCSprite:createWithSpriteFrameName("anniversaryBg.png")
	screenSp:setRotation(90)
	screenSp:setScale((G_VisibleSizeWidth - 80)/screenSp:getContentSize().height)
	screenSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 490)
	self.bgLayer:addChild(screenSp)
	self.targetSp=GetTTFLabelWrap(acAnniversaryVoApi:getTargetStr(self.curPage),25,CCSizeMake(G_VisibleSizeWidth - 280,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.targetSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 415)
	self.bgLayer:addChild(self.targetSp)
	local function onSendChat()
		if(self.lastChat==nil or base.serverTime>=self.lastChat + 5)then
			self.lastChat=base.serverTime
			local params={subType=1,contentType=2,message=acAnniversaryVoApi:getTargetStr(self.curPage),level=playerVoApi:getPlayerLevel(),rank=playerVoApi:getRank(),power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=G_getCurChoseLanguage(),st=base.serverTime,title=playerVoApi:getTitle(),brType=10}
			chatVoApi:sendChatMessage(1,playerVoApi:getUid(),playerVoApi:getPlayerName(),0,"",params)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_anniversary_sendChat"),30)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{self.lastChat + 5 - base.serverTime}),30)
		end
	end
	local sendChatItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onSendChat)
	sendChatItem:setScale(1.2)
	local sendChatBtn=CCMenu:createWithItem(sendChatItem)
	sendChatBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	sendChatBtn:setPosition(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 400)
	self.bgLayer:addChild(sendChatBtn)
	local function onLeft()
		self:pageChange(-1)
	end
	local leftBtn=LuaCCSprite:createWithSpriteFrameName("accessoryArrow2.png",onLeft)
	leftBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	leftBtn:setRotation(180)
	leftBtn:setPosition(90,G_VisibleSizeHeight - 490)
	self.bgLayer:addChild(leftBtn)
	local mvTo1=CCMoveTo:create(0.5,ccp(70,G_VisibleSizeHeight - 490))
	local mvTo2=CCMoveTo:create(0.5,ccp(90,G_VisibleSizeHeight - 490))
	local seq=CCSequence:createWithTwoActions(mvTo1,mvTo2)
	leftBtn:runAction(CCRepeatForever:create(seq))
	--小箭头太小，不容点到，加个遮罩
	local leftMask=LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",onLeft)
	leftMask:setOpacity(0)
	leftMask:setTouchPriority(-(self.layerNum-1)*20-4)
	leftMask:setScale(2)
	leftMask:setPosition(80,G_VisibleSizeHeight - 490)
	self.bgLayer:addChild(leftMask)
	local function onRight()
		self:pageChange(1)
	end
	local rightBtn=LuaCCSprite:createWithSpriteFrameName("accessoryArrow2.png",onRight)
	rightBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	rightBtn:setPosition(G_VisibleSizeWidth - 90,G_VisibleSizeHeight - 490)
	self.bgLayer:addChild(rightBtn)
	local mvTo1=CCMoveTo:create(0.5,ccp(G_VisibleSizeWidth - 70,G_VisibleSizeHeight - 490))
	local mvTo2=CCMoveTo:create(0.5,ccp(G_VisibleSizeWidth - 90,G_VisibleSizeHeight - 490))
	local seq=CCSequence:createWithTwoActions(mvTo1,mvTo2)
	rightBtn:runAction(CCRepeatForever:create(seq))
	--小箭头太小，不容点到，加个遮罩
	local rightMask=LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",onRight)
	rightMask:setOpacity(0)
	rightMask:setTouchPriority(-(self.layerNum-1)*20-4)
	rightMask:setScale(2)
	rightMask:setPosition(G_VisibleSizeWidth - 80,G_VisibleSizeHeight - 490)
	self.bgLayer:addChild(rightMask)
	local function onGetReward()
		local function callback()
			local rewardTb=FormatItem(self.acVo.rewardCfgGame[self.curPage])
			for k,v in pairs(rewardTb) do
				G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
			end
			G_showRewardTip(rewardTb,true)
			self:refreshGameReward()
		end
		acAnniversaryVoApi:getReward("reward",self.curPage,callback)
	end
	local rewardItem=GetButtonItem("anniversaryBtn.png","anniversaryBtnDown.png","anniversaryBtnDown.png",onGetReward,nil,getlocal("daily_scene_get"),25)
	self.rewardBtn=CCMenu:createWithItem(rewardItem)
	self.rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.rewardBtn:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 630)
	self.bgLayer:addChild(self.rewardBtn,1)
	self.rewardLb=GetTTFLabel(getlocal("activity_hadReward"),25)
	self.rewardLb:setColor(G_ColorGreen)
	self.rewardLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 585)
	self.bgLayer:addChild(self.rewardLb,1)

	self:refreshGameReward()
end

function acAnniversaryDialog:pageChange(pos)
	if(self.moving)then
		do return end
	end
	self.moving=true
	self.curPage=self.curPage + pos
	if(self.curPage>5)then
		self.curPage=1
	elseif(self.curPage<1)then
		self.curPage=5
	end
	local mvTo=CCMoveTo:create(0.3,ccp(G_VisibleSizeWidth/2 + 80*pos,G_VisibleSizeHeight - 415))
	local fadeOut=CCFadeOut:create(0.3)
	local arr1=CCArray:create()
	arr1:addObject(mvTo)
	arr1:addObject(fadeOut)
	local spawn1=CCSpawn:create(arr1)
	--奖品跟着一起动
	for k,v in pairs(self.gameRewardTb) do
		local mvTo=CCMoveTo:create(0.3,ccp(v:getPositionX() + 80*pos,v:getPositionY()))
		local arr=CCArray:create()
		arr:addObject(mvTo)
		arr:addObject(fadeOut)
		local spawn=CCSpawn:create(arr)
		v:runAction(spawn)
	end
	local function onDisappear()
		self.targetSp:setString(acAnniversaryVoApi:getTargetStr(self.curPage))
		self.targetSp:setPositionX(G_VisibleSizeWidth/2 - 80*pos)
		self:refreshGameReward()
		--奖品跟着一起动
		for k,v in pairs(self.gameRewardTb) do
			v:setOpacity(0)
			local targetX=v:getPositionX()
			v:setPositionX(targetX - 80*pos)
			local mvTo=CCMoveTo:create(0.3,ccp(targetX,v:getPositionY()))
			local fadeIn=CCFadeIn:create(0.3)
			local arr=CCArray:create()
			arr:addObject(mvTo)
			arr:addObject(fadeIn)
			local spawn=CCSpawn:create(arr)
			v:runAction(spawn)
		end
	end
	local callFunc1=CCCallFuncN:create(onDisappear)
	local mvTo=CCMoveTo:create(0.3,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 415))
	local fadeIn=CCFadeIn:create(0.3)
	local arr2=CCArray:create()
	arr2:addObject(mvTo)
	arr2:addObject(fadeIn)
	local spawn2=CCSpawn:create(arr2)
	local function onAppear()
		self.moving=false
	end
	local callFunc2=CCCallFuncN:create(onAppear)
	local acArr=CCArray:create()
	acArr:addObject(spawn1)
	acArr:addObject(callFunc1)
	acArr:addObject(spawn2)
	acArr:addObject(callFunc2)
	local seq=CCSequence:create(acArr)
	self.targetSp:runAction(seq)
end

function acAnniversaryDialog:initCostReward()
	acAnniversaryVoApi:updateCostData()
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,45))
	titleBg:setPosition(G_VisibleSizeWidth/2,240)
	self.bgLayer:addChild(titleBg)
	self.costLb=GetTTFLabel(getlocal("activity_anniversary_todayCost",{self.acVo.costGem}),28)
	local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.costLb:setPosition(G_VisibleSizeWidth/2 - gemIcon:getContentSize().width/2,240)
	self.bgLayer:addChild(self.costLb)
	gemIcon:setPosition(G_VisibleSizeWidth/2 + self.costLb:getContentSize().width/2,240)
	self.bgLayer:addChild(gemIcon)
	local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
	orangeLine:setPosition(ccp(G_VisibleSizeWidth/2,240 + 45/2))
	self.bgLayer:addChild(orangeLine)
	local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
	orangeLine:setPosition(ccp(G_VisibleSizeWidth/2,240 - 45/2))
	self.bgLayer:addChild(orangeLine)
	self:refreshCostReward()
end

function acAnniversaryDialog:refreshGameReward()
	if(self.gameRewardTb)then
		for k,v in pairs(self.gameRewardTb) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.gameRewardTb={}
	local rewardCfg=self.acVo.rewardCfgGame[self.curPage]
	local rewardTb=FormatItem(rewardCfg)
	local length=#rewardTb
	local unitWidth=(G_VisibleSizeWidth - 160)/(length + 1)
	for i=1,length do
		local posX=80 + unitWidth*i
		local rewardSp=G_getItemIcon(rewardTb[i],80,true,self.layerNum + 1)
		rewardSp:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardSp:setPosition(posX,G_VisibleSizeHeight - 520)
		self.bgLayer:addChild(rewardSp)
		table.insert(self.gameRewardTb,rewardSp)
		local numLb=GetTTFLabel("x"..FormatNumber(rewardTb[i].num),25)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(rewardSp:getContentSize().width - 5,5)
		rewardSp:addChild(numLb)
	end
	local getFlag=false
	for k,v in pairs(self.acVo.gameReward) do
		if(v==self.curPage)then
			getFlag=true
			break
		end
	end
	if(getFlag)then
		self.rewardBtn:setVisible(false)
		self.rewardLb:setVisible(true)
	else
		self.rewardBtn:setVisible(true)
		self.rewardLb:setVisible(false)
	end
end

function acAnniversaryDialog:refreshCostReward()
	if(self.costRewardTb)then
		for k,v in pairs(self.costRewardTb) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.costRewardTb={}
	local length=#self.acVo.costCfg
	local unitWidth=(G_VisibleSizeWidth + 80)/(length + 1)
	local posY=(240 - 45/2 - 20)/2 + 20 + 30
	for i=1,length do
		local posX=-40 + unitWidth*i
		local boxSp
		local flag=false
		for k,v in pairs(self.acVo.costReward) do
			if(v==i)then
				flag=true
				break
			end
		end
		local lb
		local function onClickReward(object,fn,tag)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if(tag and tonumber(tag))then
				self:showReward(tonumber(tag))
			end
		end
		if(flag)then
			boxSp=LuaCCSprite:createWithSpriteFrameName("friendBtnDOwn.png",onClickReward)
			lb=GetTTFLabel(getlocal("activity_hadReward"),25)
			lb:setColor(G_ColorGreen)
		else
			boxSp=LuaCCSprite:createWithSpriteFrameName("friendBtn.png",onClickReward)
			if(self.acVo.costGem>=self.acVo.costCfg[i])then
				local lightSp=CCSprite:createWithSpriteFrameName("equipShine.png")
				lightSp:setPosition(posX,posY)
				self.bgLayer:addChild(lightSp)
				local rotateBy = CCRotateBy:create(4,360)
				local reverseBy = rotateBy:reverse()
				lightSp:runAction(CCRepeatForever:create(reverseBy))
				table.insert(self.costRewardTb,lightSp)
				lb=GetTTFLabel(getlocal("daily_scene_get"),25)
				lb:setColor(G_ColorYellowPro)
			else
				lb=GetTTFLabel(getlocal("daily_award_tip_3",{self.acVo.costCfg[i]}),25)
				lb:setColor(G_ColorRed)
			end
		end
		boxSp:setTag(i)
		boxSp:setTouchPriority(-(self.layerNum-1)*20-4)
		boxSp:setPosition(posX,posY)
		self.bgLayer:addChild(boxSp,1)
		table.insert(self.costRewardTb,boxSp)
		lb:setPosition(posX,70)
		self.bgLayer:addChild(lb,2)
		table.insert(self.costRewardTb,lb)
	end
end

function acAnniversaryDialog:tick()
	if(self.tickTime and self.tickTime<G_getWeeTs(base.serverTime))then
		acAnniversaryVoApi:updateCostData()
		if(self.costLb)then
			self.costLb:setString(getlocal("activity_anniversary_todayCost",{self.acVo.costGem}))
		end
		self:refreshCostReward()
	end
	self.tickTime=base.serverTime
end

function acAnniversaryDialog:showReward(index)
	if(self.acVo.rewardCfgCost[index])then
		require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
		local sd = acChunjiepanshengSmallDialog:new()
		local rewardTb=FormatItem(self.acVo.rewardCfgCost[index],nil,true)
		local titleStr=getlocal("activity_anniversary_costDesc",{self.acVo.costCfg[index]})
		local btnStr
		local flag=false
		for k,v in pairs(self.acVo.costReward) do
			if(v==index)then
				flag=true
				break
			end
		end
		if(flag)then
			btnStr=getlocal("activity_hadReward")
		elseif(self.acVo.costGem>=self.acVo.costCfg[index])then
			btnStr=getlocal("daily_scene_get")
		else
			btnStr=getlocal("confirm")
		end
		local function onConfirm()
			if(flag)then
				do return end
			end
			if(self.acVo.costGem>=self.acVo.costCfg[index])then
				local function callback()
					for k,v in pairs(rewardTb) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
					G_showRewardTip(rewardTb)
					self:refreshCostReward()
				end
				acAnniversaryVoApi:getReward("creward",index,callback)
			end
		end
		sd:init(true,true,self.layerNum + 1,titleStr,"TankInforPanel.png",CCSizeMake(500,600),CCRect(130, 50, 1, 1),rewardTb,nil,btnStr,onConfirm)
	end
end

function acAnniversaryDialog:dispose()
	self.costRewardTb=nil
	spriteController:removePlist("public/acAnniversary.plist")
	spriteController:removeTexture("public/acAnniversary.png")
	spriteController:removePlist("public/acChunjiepansheng.plist")
	spriteController:removeTexture("public/acChunjiepansheng.png")
end