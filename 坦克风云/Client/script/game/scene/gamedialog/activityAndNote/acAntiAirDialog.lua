--打飞机活动的dialog
acAntiAirDialog=commonDialog:new()

function acAntiAirDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acAntiAirDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 100))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/acNewYearsEva.plist")
	spriteController:addTexture("public/acNewYearsEva.png")
	spriteController:addPlist("public/acAntiAir.plist")
	spriteController:addTexture("public/acAntiAir.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444) 
	local function callback()
		self:initUp()
		self:initDown()
	end
	acAntiAirVoApi:checkInit(callback)
end

function acAntiAirDialog:initUp()
	local function nilFunc( ... )
	end
	local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),nilFunc)
	upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,190))
	upBg:setAnchorPoint(ccp(0.5,1))
	upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 90)
	self.bgLayer:addChild(upBg)
	local timeLb = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 95))
	self.bgLayer:addChild(timeLb)

	local timeLb=GetTTFLabel(acAntiAirVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 128))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
	self:updateAcTime()

	-- local descLb=GetTTFLabelWrap(getlocal("activity_battleplane_desc"),25,CCSizeMake(G_VisibleSizeWidth - 70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- descLb:setAnchorPoint(ccp(0.5,1))
	-- descLb:setPosition(G_VisibleSizeWidth/2,timeLb:getPositionY() - timeLb:getContentSize().height - 10)
	-- self.bgLayer:addChild(descLb)
	local strSize2 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2 =25
	end
	local descLb = getlocal("activity_battleplane_desc")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth - 70,100),descLb,strSize2,kCCTextAlignmentLeft)
	upBg:addChild(desTv)
	desTv:setPosition(ccp(10,10))
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(100)



	local function onInfo()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_battleplane_info"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onInfo)
	infoItem:setScale(0.8)
	local infoBtn=CCMenu:createWithItem(infoItem)
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 135))
	self.bgLayer:addChild(infoBtn)
end

function acAntiAirDialog:initDown()
	local posY=G_VisibleSizeHeight - 290
	local function nilFunc(...)
	end
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(30,30,30,30),nilFunc)
	downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,posY - 23))
	downBg:setAnchorPoint(ccp(0.5,0))
	downBg:setPosition(G_VisibleSizeWidth/2,23)
	self.bgLayer:addChild(downBg)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(213,0,2,47),nilFunc)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,47))
	titleBg:setPosition(G_VisibleSizeWidth/2,posY - 47/2)
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("activity_battleplane_listTitle"),28)
	titleLb:setPosition(G_VisibleSizeWidth/2,posY - 47/2)
	self.bgLayer:addChild(titleLb)
	posY=posY - 47
	local showList=acAntiAirVoApi:getShowList()
	local flickerList=acAntiAirVoApi:getFlickerTb()
	local rewardTv
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return #showList
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(90,90)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local rewardIcon=G_getItemIcon(showList[idx + 1],80,true,self.layerNum + 1,nil,rewardTv)
			rewardIcon:setTouchPriority(-(self.layerNum-1)*20-2)
			rewardIcon:setPosition(45,45)
			cell:addChild(rewardIcon)
			if(showList[idx + 1].num)then
				local numLb=GetTTFLabel("x"..FormatNumber(showList[idx + 1].num),25)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(rewardIcon:getContentSize().width - 10,10)
				rewardIcon:addChild(numLb)
			end
			if(flickerList[idx + 1] and tonumber(flickerList[idx + 1])==1)then
				local tmpSp=CCSprite:createWithSpriteFrameName("RotatingEffect1.png")
				G_addRectFlicker(rewardIcon,rewardIcon:getContentSize().width/tmpSp:getContentSize().width,rewardIcon:getContentSize().height/tmpSp:getContentSize().height)
			end
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	rewardTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,90),nil)
	rewardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	rewardTv:setPosition(ccp(30,posY - 95))
	rewardTv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(rewardTv)

	posY=posY - 100
	local skyTexture=spriteController:getTexture("public/acAntiAir.png")
	self.skyBatchNode=CCSpriteBatchNode:createWithTexture(skyTexture,250)
	self.bgLayer:addChild(self.skyBatchNode)
	local picNum=math.floor((G_VisibleSizeWidth - 40)/3)
	for i=1,picNum do
		local sky=CCSprite:createWithSpriteFrameName("antiAirSky.png")
		sky:setAnchorPoint(ccp(0,0))
		sky:setScaleY((posY - 24)/sky:getContentSize().height)
		sky:setPosition(20 + (i - 1)*3,24)
		self.skyBatchNode:addChild(sky)
	end
	local cloud=CCSprite:createWithSpriteFrameName("antiAirCloud.png")
	cloud:setScale(2)
	cloud:setPosition(G_VisibleSizeWidth/2,100)
	self.skyBatchNode:addChild(cloud)

	local cloud=CCSprite:createWithSpriteFrameName("antiAirCloud.png")
	cloud:setScale(1.5)
	cloud:setPosition(400,300)
	self.skyBatchNode:addChild(cloud)

	local canonSp=CCSprite:createWithSpriteFrameName("antiAirCanon.png")
	canonSp:setAnchorPoint(ccp(0,0))
	canonSp:setPosition(20,24)
	self.skyBatchNode:addChild(canonSp)

	local upBorder=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	upBorder:setAnchorPoint(ccp(0.5,1))
	upBorder:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(upBorder,2)
	local downBorder=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	downBorder:setFlipY(true)
	downBorder:setAnchorPoint(ccp(0.5,0))
	downBorder:setPosition(ccp(G_VisibleSizeWidth/2,23))
	self.bgLayer:addChild(downBorder,2)

	local leftLb=GetTTFLabel(getlocal("activity_battleplane_left",{acAntiAirVoApi:getLeftPlane()}),25)
	local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(50,0,20,36),nilFunc)
	lbBg:setContentSize(CCSizeMake(leftLb:getContentSize().width + 80,36))
	lbBg:setPosition(G_VisibleSizeWidth - 60 - leftLb:getContentSize().width/2,posY - 30 - leftLb:getContentSize().height/2)
	self.bgLayer:addChild(lbBg,2)

	local offset=0
	if(G_isIphone5())then
		offset=(1136 - 960)/2
	end
	self.posTb={ccp(101,295 + offset),ccp(187, 400 + offset),ccp(295, 317 + offset),ccp(358, 167 + offset),ccp(451, 393 + offset),ccp(490, 270 + offset)}
	self:refreshDown()
end

function acAntiAirDialog:refreshDown()
	local posY=G_VisibleSizeHeight - 290 - 147
	if(self.planeList)then
		for k,v in pairs(self.planeList) do
			v:removeFromParentAndCleanup(true)
		end
	end
	if(self.boxList)then
		for k,v in pairs(self.boxList) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.curRewardList=acAntiAirVoApi:getCurReward()
	self.beforeRewardList=acAntiAirVoApi:getBeforeReward()
	self.planeList={}
	self.boxList={}
	local allRewarded=true
	for k,v in pairs(self.curRewardList) do
		local planeSp=CCSprite:createWithSpriteFrameName("antiAirPlane"..v..".png")
		if(planeSp)then
			planeSp:setPosition(self.posTb[k])
			self.skyBatchNode:addChild(planeSp)
			self.planeList[k]=planeSp
		end
		if(self.beforeRewardList[k])then
			local rewardIcon=G_getItemIcon(self.beforeRewardList[k],80,true,self.layerNum)
			rewardIcon:setTouchPriority(-(self.layerNum-1)*20-2)
			rewardIcon:setPosition(self.posTb[k])
			self.bgLayer:addChild(rewardIcon,1)
			self.boxList[k]=rewardIcon
			local tmpSp=CCSprite:createWithSpriteFrameName("RotatingEffect1.png")
			G_addRectFlicker(rewardIcon,rewardIcon:getContentSize().width/tmpSp:getContentSize().width,rewardIcon:getContentSize().height/tmpSp:getContentSize().height)
			if(self.beforeRewardList[k].num)then
				local numLb=GetTTFLabel("x"..FormatNumber(self.beforeRewardList[k].num),25)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(rewardIcon:getContentSize().width - 10,10)
				rewardIcon:addChild(numLb)
			end
		else
			allRewarded=false
		end
	end

	local function onReset()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:reset()
	end
	if(self.resetBtn==nil)then
		local resetItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onReset,nil,getlocal("confirm"),25)
		self.resetBtn=CCMenu:createWithItem(resetItem)
		self.resetBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.resetBtn:setPosition(G_VisibleSizeWidth - 135,80)
		self.bgLayer:addChild(self.resetBtn,2)
	end
	if(self.mask==nil)then
		self.mask=LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",function ( ... )end)
		self.mask:setTouchPriority(-(self.layerNum-1)*20-3)
		self.mask:setOpacity(200)
		self.mask:setScaleX((G_VisibleSizeWidth - 40)/self.mask:getContentSize().width)
		self.mask:setScaleY((posY - 24)/self.mask:getContentSize().height)
		self.mask:setAnchorPoint(ccp(0,0))
		self.mask:setPosition(20,24)
		self.bgLayer:addChild(self.mask,2)
	end
	if(self.leftLb==nil)then
		self.leftLb=GetTTFLabel(getlocal("activity_battleplane_left",{acAntiAirVoApi:getLeftPlane()}),25)
		self.leftLb:setColor(G_ColorYellowPro)
		self.leftLb:setAnchorPoint(ccp(1,1))
		self.leftLb:setPosition(G_VisibleSizeWidth - 60,posY - 30)
		self.bgLayer:addChild(self.leftLb,3)
	else
		self.leftLb:setString(getlocal("activity_battleplane_left",{acAntiAirVoApi:getLeftPlane()}))
	end
	if(self.resetSp==nil)then
		local resetLb=GetTTFLabel(getlocal("activity_battleplane_reset"),25)
		self.resetSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),onReset)
		self.resetSp:setTouchPriority(-(self.layerNum-1)*20-4)
		self.resetSp:setOpacity(0)
		self.resetSp:setContentSize(CCSizeMake(resetLb:getContentSize().width + 20,resetLb:getContentSize().height + 10))
		self.resetSp:setAnchorPoint(ccp(0,1))
		self.resetSp:setPosition(45,posY - 30)
		self.bgLayer:addChild(self.resetSp,3)
		resetLb:setColor(G_ColorGreen)
		resetLb:setPosition(getCenterPoint(self.resetSp))
		self.resetSp:addChild(resetLb)
		local underline=CCSprite:createWithSpriteFrameName("white_line.png")
		underline:setColor(G_ColorGreen)
		underline:setScaleX(resetLb:getContentSize().width/underline:getContentSize().width)
		underline:setPosition(resetLb:getPositionX(),resetLb:getPositionY() - resetLb:getContentSize().height/2)
		self.resetSp:addChild(underline)
	end
	if(self.lastRewardIcon)then
		self.lastRewardIcon:removeFromParentAndCleanup(true)
		self.lastRewardIcon=nil
	end
	if(self.lastRewardLb)then
		self.lastRewardLb:removeFromParentAndCleanup(true)
		self.lastRewardLb=nil
	end
	if(self.lastReward)then
		self.lastRewardIcon=G_getItemIcon(self.lastReward,100)
		self.lastRewardIcon:setPosition(G_VisibleSizeWidth/2,24 + (posY - 24)/2 + 30)
		self.bgLayer:addChild(self.lastRewardIcon,3)
		self.lastRewardLb=GetTTFLabel(getlocal("item_number",{self.lastReward.name,self.lastReward.num}),25)
		self.lastRewardLb:setPosition(G_VisibleSizeWidth/2,self.lastRewardIcon:getPositionY() - 70)
		self.bgLayer:addChild(self.lastRewardLb,2)
	else
		if(self.lastRewardIcon)then
			self.lastRewardIcon:removeFromParentAndCleanup(true)
			self.lastRewardIcon=nil
		end
		if(self.lastRewardLb)then
			self.lastRewardLb:removeFromParentAndCleanup(true)
			self.lastRewardLb=nil
		end
	end
	if(self.drawBtn1==nil)then
		local function onDraw()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:draw(1)
		end
		self.drawItem1=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onDraw,nil,getlocal("activity_battleplane_hit1"),25,101)
		self.drawBtn1=CCMenu:createWithItem(self.drawItem1)
		self.drawBtn1:setTouchPriority(-(self.layerNum-1)*20-4)
		self.drawBtn1:setPosition(G_VisibleSizeWidth/2 - 120,24 + (posY - 24)/2 - 110)
		self.bgLayer:addChild(self.drawBtn1,3)
	end
	if(self.drawBtn2==nil)then
		local function onDraw()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:draw(2)
		end
		self.drawItem2=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onDraw,nil,getlocal("activity_battleplane_hitAll"),25)
		self.drawBtn2=CCMenu:createWithItem(self.drawItem2)
		self.drawBtn2:setTouchPriority(-(self.layerNum-1)*20-4)
		self.drawBtn2:setPosition(G_VisibleSizeWidth/2 + 120,24 + (posY - 24)/2 - 110)
		self.bgLayer:addChild(self.drawBtn2,3)
	end
	if(self.priceSp1==nil)then
		self.priceSp1=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
		self.priceSp1:setOpacity(0)
		self.priceSp1:setPosition(self.drawBtn1:getPositionX(),self.drawBtn1:getPositionY() - 60)
		self.bgLayer:addChild(self.priceSp1,3)
		local lb=GetTTFLabel("",25)
		lb:setTag(101)
		lb:setPosition(20,20)
		self.priceSp1:addChild(lb)
		local icon=CCSprite:createWithSpriteFrameName("IconGold.png")
		icon:setTag(102)
		icon:setPosition(20 - lb:getPositionX() - 20,lb:getPositionY())
		self.priceSp1:addChild(icon)
	end
	if(self.priceSp2==nil)then
		self.priceSp2=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
		self.priceSp2:setOpacity(0)
		self.priceSp2:setPosition(self.drawBtn2:getPositionX(),self.drawBtn2:getPositionY() - 60)
		self.bgLayer:addChild(self.priceSp2,3)
		local lb=GetTTFLabel(acAntiAirVoApi:getCost(2),25)
		lb:setPosition(20,20)
		self.priceSp2:addChild(lb)
		local icon=CCSprite:createWithSpriteFrameName("IconGold.png")
		icon:setPosition(20 - lb:getPositionX() - 20,lb:getPositionY())
		self.priceSp2:addChild(icon)
	end
	local priceLb1=tolua.cast(self.priceSp1:getChildByTag(101),"CCLabelTTF")
	local iconGold1=tolua.cast(self.priceSp1:getChildByTag(102),"CCSprite")
	if(acAntiAirVoApi:canReward())then
		priceLb1:setString(getlocal("daily_lotto_tip_2"))
		priceLb1:setColor(G_ColorGreen)
		iconGold1:setVisible(false)
		self.drawItem2:setEnabled(false)
	else
		priceLb1:setString(acAntiAirVoApi:getCost(1))
		priceLb1:setColor(G_ColorWhite)
		iconGold1:setVisible(true)
		iconGold1:setPositionX(20 - priceLb1:getPositionX() - 20)
		self.drawItem2:setEnabled(true)
	end
	if(allRewarded)then
		self.resetBtn:setVisible(true)
		self.mask:setVisible(false)
		self.mask:setPositionX(999333)
		self.resetSp:setVisible(false)
		self.drawBtn1:setVisible(false)
		self.drawBtn2:setVisible(false)
		self.priceSp1:setVisible(false)
		self.priceSp2:setVisible(false)
	else
		self.resetBtn:setVisible(false)
		self.mask:setVisible(true)
		self.mask:setPositionX(20)
		if(SizeOfTable(acAntiAirVoApi:getBeforeReward())>0)then
			self.resetSp:setVisible(true)
		else
			self.resetSp:setVisible(false)
		end
		self.drawBtn1:setVisible(true)
		self.drawBtn2:setVisible(true)
		self.priceSp1:setVisible(true)
		self.priceSp2:setVisible(true)
		local btnLb=tolua.cast(self.drawItem1:getChildByTag(101),"CCLabelTTF")
		if(acAntiAirVoApi:getLeftPlane()<=0)then
			btnLb:setString(getlocal("confirm"))
		else
			btnLb:setString(getlocal("activity_battleplane_hit1"))
		end
	end
end

function acAntiAirDialog:reset()
	if(SizeOfTable(acAntiAirVoApi:getBeforeReward())<=0)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),28)
		do return end
	end
	local function callback()
		self.lastReward=nil
		self:refreshDown()
	end
	acAntiAirVoApi:reset(callback)
end

function acAntiAirDialog:draw(index)
	if(index==1 and acAntiAirVoApi:getLeftPlane()<=0)then
		local function onConfirm()
			self:reset()
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_battleplane_resetConfirm"),nil,self.layerNum + 1)
		do return end
	end
	local function realDraw()
		self.lastReward=nil
		self.oldBeforeReward={}
		local function playMv1(rewardTb)
			local reward
			local rewardIndex
			for k,v in pairs(rewardTb) do
				reward=v
				rewardIndex=k
			end
			self.lastReward=reward
			self:playMv(1,rewardIndex)
		end
		local function playMv2(rewardTb)
			self:playMv(2)
		end
		if(acAntiAirVoApi:canReward())then
			acAntiAirVoApi:draw(1,playMv1)
		else
			local cost=acAntiAirVoApi:getCost(index)
			if(playerVoApi:getGems()<cost)then
				GemsNotEnoughDialog(nil,nil,cost - playerVoApi:getGems(),self.layerNum+1,cost)
				do return end
			end
			if(index==1)then
				acAntiAirVoApi:draw(2,playMv1)
			else
				self.oldBeforeReward={}
				for k,v in pairs(acAntiAirVoApi:getBeforeReward()) do
					self.oldBeforeReward[k]=v
				end
				acAntiAirVoApi:draw(3,playMv2)
			end
		end
	end
	if acAntiAirVoApi:canReward() then--免费抽
		realDraw()
	else
		local cost=acAntiAirVoApi:getCost(index)	
		local keyName = "battleplane"
	   	local function secondTipFunc(sbFlag)
	        local sValue=base.serverTime .. "_" .. sbFlag
	        G_changePopFlag(keyName,sValue)
	    end
	  	if G_isPopBoard(keyName) then
	        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,realDraw,secondTipFunc)
	    else
	        realDraw()
	    end
	end
end

function acAntiAirDialog:playMv(type,index)
	if(self.lastRewardIcon)then
		self.lastRewardIcon:setVisible(false)
	end
	if(self.lastRewardLb)then
		self.lastRewardLb:setVisible(false)
	end
	self.mask:setVisible(false)
	self.resetSp:setVisible(false)
	self.drawBtn1:setVisible(false)
	self.drawBtn2:setVisible(false)
	self.priceSp1:setVisible(false)
	self.priceSp2:setVisible(false)

	self:removeMv()
	local function removeActionLayer()
		self:removeMv()
		self:refreshDown()
	end
	self.actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),removeActionLayer)
	self.actionLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.actionLayer:setPosition(getCenterPoint(self.bgLayer))
	self.actionLayer:setOpacity(0)
	self.actionLayer:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(self.actionLayer,2)

	local function onPlayEnd()
		self:refreshDown()
	end
	local minX,maxX,minY,maxY=20,G_VisibleSizeWidth - 20,44,G_VisibleSizeHeight - 310 - 147 - 20
	if(type==1)then
		if(index==nil)then
			onPlayEnd()
			do return end
		end
		local startPos,pos1,pos2,pos3
		local finalPos=self.posTb[index]
		local startIndex=math.random(1,4)
		if(startIndex==1)then
			startPos=ccp(minX,minY)
			pos1=ccp(math.random(finalPos.x,maxX),math.random(minY,finalPos.y))
			pos2=ccp(math.random(minX,finalPos.x),math.random(finalPos.y,maxY))
			pos3=ccp(math.random(finalPos.x,maxX),math.random(finalPos.y,maxY))
		elseif(startIndex==2)then
			startPos=ccp(minX,maxY)
			pos1=ccp(math.random(minX,finalPos.x),math.random(minY,finalPos.y))
			pos2=ccp(math.random(finalPos.x,maxX),math.random(finalPos.y,maxY))
			pos3=ccp(math.random(finalPos.x,maxX),math.random(minY,finalPos.y))
		elseif(startIndex==3)then
			startPos=ccp(maxX,minY)
			pos1=ccp(math.random(finalPos.x,maxX),math.random(finalPos.y,maxY))
			pos2=ccp(math.random(minX,finalPos.x),math.random(minY,finalPos.y))
			pos3=ccp(math.random(finalPos.x,maxX),math.random(minY,finalPos.y))
		else
			startPos=ccp(maxX,maxY)
			pos1=ccp(math.random(minX,finalPos.x),math.random(finalPos.y,maxY))
			pos2=ccp(math.random(finalPos.x,maxX),math.random(minY,finalPos.y))
			pos3=ccp(math.random(finalPos.x,maxX),math.random(finalPos.y,maxY))
		end
		local aimSp=CCSprite:createWithSpriteFrameName("Aim_1.png")
		aimSp:setScale(1.8)
		aimSp:setPosition(startPos)
		self.actionLayer:addChild(aimSp,3)
		local moveTo1=CCMoveTo:create(0.5,pos1)
		local moveTo2=CCMoveTo:create(0.5,pos2)
		local moveTo3=CCMoveTo:create(0.5,pos3)
		local arr1=CCArray:create()
		arr1:addObject(moveTo1)
		arr1:addObject(moveTo2)
		arr1:addObject(moveTo3)
		local seq1=CCSequence:create(arr1)
		local rotate1=CCRotateBy:create(1.5,1080)
		local arr2=CCArray:create()
		arr2:addObject(seq1)
		arr2:addObject(rotate1)
		local spawn1=CCSpawn:create(arr2)
		local moveTo4=CCMoveTo:create(0.5,finalPos)
		local rotate2=CCRotateBy:create(0.5,180)
		local arr3=CCArray:create()
		arr3:addObject(moveTo4)
		arr3:addObject(rotate2)
		local spawn2=CCSpawn:create(arr3)
		local function explode()
			local mzFrameName="hit4_1.png"
			local mzSp=CCSprite:createWithSpriteFrameName(mzFrameName)
			mzSp:setPosition(finalPos)
			mzSp:setScale(2)
			self.actionLayer:addChild(mzSp,2)
			local  mzArr=CCArray:create()
			for kk=1,14 do
				local nameStr="hit4_"..kk..".png"
				local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				mzArr:addObject(frame)
			end
			local animation=CCAnimation:createWithSpriteFrames(mzArr)
			animation:setDelayPerUnit(0.06)
			local animate=CCAnimate:create(animation)
			local function mzEnd()
				mzSp:stopAllActions()
				mzSp:removeFromParentAndCleanup(true)
				aimSp:stopAllActions()
				aimSp:removeFromParentAndCleanup(true)
				local reward=acAntiAirVoApi:getBeforeReward()[index]
				local rewardIcon=G_getItemIcon(reward,100)
				rewardIcon:setPosition(finalPos)
				self.actionLayer:addChild(rewardIcon,2)
				local rotate=CCRotateBy:create(0.5,1080)
				local scaleTo=CCScaleTo:create(0.5,80/rewardIcon:getContentSize().width)
				local arr=CCArray:create()
				arr:addObject(rotate)
				arr:addObject(scaleTo)
				local function rewardEnd()
					rewardIcon:removeFromParentAndCleanup(true)
					onPlayEnd()
				end
				local callFunc=CCCallFuncN:create(rewardEnd)
				arr:addObject(callFunc)
				local seq=CCSequence:create(arr)
				rewardIcon:runAction(seq)
			end
			local mzfunc=CCCallFuncN:create(mzEnd)
			local acArr=CCArray:create()
			acArr:addObject(animate)
			acArr:addObject(mzfunc)
			local  seq=CCSequence:create(acArr)
			mzSp:runAction(seq)
		end
		local acArr=CCArray:create()
		acArr:addObject(spawn1)
		acArr:addObject(spawn2)
		local delay=CCDelayTime:create(0.3)
		acArr:addObject(delay)
		local explodeFunc=CCCallFuncN:create(explode)
		acArr:addObject(explodeFunc)
		local seq=CCSequence:create(acArr)
		aimSp:runAction(seq)
	else
		local leftTb={}
		for k,v in pairs(acAntiAirVoApi:getCurReward()) do
			if(self.oldBeforeReward[k]==nil)then
				table.insert(leftTb,k)
			end
		end
		local posIndex=3
		local midX=(minX + maxX)/2
		local midY=(minY + maxY)/2
		local rewardIconTb={}
		for k,v in pairs(leftTb) do
			local posTb={}
			local lastX,lastY
			for i=1,posIndex do
				if(lastX==nil)then
					lastX=math.random(minX,maxX)
					lastY=math.random(minY,maxY)
				else
					local random=math.random()
					if(random<0.4)then
						if(lastX<=midX)then
							lastX=math.random(midX,maxX)
						else
							lastX=math.random(minX,midX)
						end
						if(lastY<=midY)then
							lastY=math.random(minY,midY)
						else
							lastY=math.random(midY,maxY)
						end
					elseif(random<0.7)then
						if(lastX<=midX)then
							lastX=math.random(minX,midX)
						else
							lastX=math.random(midX,maxX)
						end
						if(lastY<=midY)then
							lastY=math.random(midY,maxY)
						else
							lastY=math.random(minY,midY)
						end
					else
						if(lastX<=midX)then
							lastX=math.random(minX,midX)
						else
							lastX=math.random(midX,maxX)
						end
						if(lastY<=midY)then
							lastY=math.random(midY,maxY)
						else
							lastY=math.random(minY,midY)
						end
					end
				end
				local pos=ccp(lastX,lastY)
				table.insert(posTb,pos)
			end
			table.insert(posTb,self.posTb[v])
			posIndex=posIndex + 1
			local aimSp=CCSprite:createWithSpriteFrameName("Aim_1.png")
			aimSp:setScale(3)
			aimSp:setPosition(posTb[1])
			self.actionLayer:addChild(aimSp,3)
			local rotate=CCRotateBy:create(1,360*2)
			local scaleTo=CCScaleTo:create(1,1.8)
			local delay=CCDelayTime:create(0.3)
			local function explode()
				local mzFrameName="hit4_1.png"
				local mzSp=CCSprite:createWithSpriteFrameName(mzFrameName)
				mzSp:setPosition(self.posTb[v])
				mzSp:setScale(2)
				self.actionLayer:addChild(mzSp,2)
				local  mzArr=CCArray:create()
				for kk=1,14 do
					local nameStr="hit4_"..kk..".png"
					local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
					mzArr:addObject(frame)
				end
				local animation=CCAnimation:createWithSpriteFrames(mzArr)
				animation:setDelayPerUnit(0.06)
				local animate=CCAnimate:create(animation)
				local function mzEnd()
					mzSp:stopAllActions()
					mzSp:removeFromParentAndCleanup(true)
					aimSp:stopAllActions()
					aimSp:removeFromParentAndCleanup(true)
					local reward=acAntiAirVoApi:getBeforeReward()[v]
					local rewardIcon=G_getItemIcon(reward,100)
					rewardIcon:setPosition(self.posTb[v])
					self.actionLayer:addChild(rewardIcon,2)
					table.insert(rewardIconTb,rewardIcon)
					local rotate=CCRotateBy:create(0.5,1080)
					local scaleTo=CCScaleTo:create(0.5,80/rewardIcon:getContentSize().width)
					local arr=CCArray:create()
					arr:addObject(rotate)
					arr:addObject(scaleTo)
					local function rewardEnd()
						if(k==#leftTb)then
							for k,v in pairs(rewardIconTb) do
								v:removeFromParentAndCleanup(true)
							end
							onPlayEnd()
						end
					end
					local callFunc=CCCallFuncN:create(rewardEnd)
					arr:addObject(callFunc)
					local seq=CCSequence:create(arr)
					rewardIcon:runAction(seq)
				end
				local mzfunc=CCCallFuncN:create(mzEnd)
				local acArr=CCArray:create()
				acArr:addObject(animate)
				acArr:addObject(mzfunc)
				local  seq=CCSequence:create(acArr)
				mzSp:runAction(seq)
			end
			local explodeFunc=CCCallFuncN:create(explode)
			local acArr=CCArray:create()
			local length=#posTb
			for i=2,length do
				local moveTo=CCMoveTo:create(0.5,posTb[i])
				acArr:addObject(moveTo)
			end
			acArr:addObject(rotate)
			acArr:addObject(scaleTo)
			acArr:addObject(delay)
			acArr:addObject(explodeFunc)
			local seq=CCSequence:create(acArr)
			aimSp:runAction(seq)
		end
	end
end

function acAntiAirDialog:removeMv()
	if self.actionLayer then
		self.actionLayer:stopAllActions()
		self.actionLayer:removeFromParentAndCleanup(true)
		self.actionLayer=nil
	end
end

function acAntiAirDialog:tick()
	if(self.lastTick==nil)then
		self.lastTick=base.serverTime
	end
	local zeroTime=G_getWeeTs(base.serverTime)
	if(self.lastTick<zeroTime)then
		self:refreshDown()
	end
	self.lastTick=base.serverTime
	if(activityVoApi:checkActivityEffective("battleplane")==false)then
		self:close()
		do return end
	end
	self:updateAcTime()
end

function acAntiAirDialog:updateAcTime()
    local acVo=acAntiAirVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acAntiAirDialog:dispose()
	spriteController:removePlist("public/acNewYearsEva.plist")
	spriteController:removeTexture("public/acNewYearsEva.png")
	spriteController:removePlist("public/acAntiAir.plist")
	spriteController:removeTexture("public/acAntiAir.png")
	self.planeList=nil
	self.boxList=nil
	self.lastTick=nil
	self:removeMv()
end
