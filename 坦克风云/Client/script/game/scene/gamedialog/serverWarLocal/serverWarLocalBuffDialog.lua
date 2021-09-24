serverWarLocalBuffDialog=commonDialog:new()

function serverWarLocalBuffDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	return nc
end

function serverWarLocalBuffDialog:resetTab()
	self.panelLineBg:setVisible(false)
	G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
	-- self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	-- self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	-- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function serverWarLocalBuffDialog:initTableView( ... )
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(616,G_VisibleSizeHeight - 130),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(12,30))
	self.tv:setMaxDisToBottomOrTop(30)
	self.bgLayer:addChild(self.tv)
	local descLb=GetTTFLabelWrap(getlocal("serverWarLocal_buffDesc"),24,CCSizeMake(G_VisibleSizeWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(G_VisibleSizeWidth/2,200)
	self.bgLayer:addChild(descLb)
	self.gemLb=GetTTFLabel(getlocal("serverwarteam_funds")..": "..serverWarLocalFightVoApi:getCarryGems(),25)
	self.gemLb:setColor(G_ColorYellowPro)
	self.gemLb:setAnchorPoint(ccp(0,0.5))
	self.gemLb:setPosition(ccp(40,40))
	self.bgLayer:addChild(self.gemLb)
end

function serverWarLocalBuffDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(serverWarLocalCfg.buffSkill)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(616,126)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth,cellHeight=616,120
		local function onBuyBuff(tag,object)
			if(tag and tag>0)then
				self:showBuyBuffConfirm("b"..tag)
			end
		end
		local cellBg=G_getThreePointBg(CCSizeMake(cellWidth,cellHeight),onBuyBuff,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)

		local buffID="b"..(idx + 1)
		local icon=CCSprite:createWithSpriteFrameName(serverWarLocalCfg.buffSkill[buffID]["icon"])
		icon:setPosition(ccp(60,60))
		cellBg:addChild(icon)
		local cfg=serverWarLocalCfg.buffSkill[buffID]
		local nameLb=GetTTFLabel(getlocal("serverWarLocal_techName_"..buffID),25)
		nameLb:setColor(G_ColorGreen)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(120,100))
		cellBg:addChild(nameLb)
		local lv,effect
		if(serverWarLocalFightVoApi:getBuffList()[buffID])then
			lv=serverWarLocalFightVoApi:getBuffList()[buffID]
			effect=cfg.per*lv
		else
			lv=0
			effect=0
		end
		local effectStr
		if(buffID=="b1" or buffID=="b3" or buffID=="b4")then
			effectStr=G_keepNumber(effect*100,0).."%%"
		else
			effectStr=effect
		end
		local lvLb=GetTTFLabel(lv.."/"..cfg.maxLv,25)
		lvLb:setAnchorPoint(ccp(0,0.5))
		lvLb:setPosition(ccp(120 + nameLb:getContentSize().width + 10,100))
		cellBg:addChild(lvLb)

		local descLb=GetTTFLabelWrap(getlocal("serverWarLocal_techDesc_"..buffID,{effectStr}),22,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(120,40)
		cellBg:addChild(descLb)

		local btnScale=0.8
		local buyItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onBuyBuff,idx + 1,getlocal("upgradeBuild"),25/btnScale)
		buyItem:setScale(0.9*btnScale)
		local buyBtn=CCMenu:createWithItem(buyItem)
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		buyBtn:setPosition(490,60)
		cellBg:addChild(buyBtn)
		if(lv>=cfg.maxLv)then
			buyItem:setEnabled(false)
		end
		local status=serverWarLocalVoApi:checkStatus()
		if(status>=30)then
			buyItem:setEnabled(false)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
	end
end

function serverWarLocalBuffDialog:showBuyBuffConfirm(buffID)
	local function onHide()
		if(self.confirmLayer)then
			self.confirmLayer:removeFromParentAndCleanup(true)
			self.confirmLayer=nil
		end
	end
	onHide()
	local layerNum=self.layerNum + 1
	self.confirmLayer=CCLayer:create()
	self.bgLayer:addChild(self.confirmLayer,2)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.confirmLayer:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	dialogBg:setContentSize(CCSizeMake(570,470))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.confirmLayer:addChild(dialogBg,1)
	local lb=GetTTFLabel(getlocal("upgradeBuild"),28)
	lb:setPosition(ccp(275,415))
	dialogBg:addChild(lb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(570/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(285,390))
	dialogBg:addChild(lineSp,1)
	local cfg=serverWarLocalCfg.buffSkill[buffID]
	local icon=CCSprite:createWithSpriteFrameName(serverWarLocalCfg.buffSkill[buffID]["icon"])
	icon:setPosition(ccp(100,320))
	dialogBg:addChild(icon)
	local nameLb=GetTTFLabel(getlocal("serverWarLocal_techName_"..buffID),25)
	nameLb:setColor(G_ColorGreen)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(ccp(160,370))
	dialogBg:addChild(nameLb)
	local lv,effect,nextEffect
	if(serverWarLocalFightVoApi:getBuffList()[buffID])then
		lv=serverWarLocalFightVoApi:getBuffList()[buffID]
		effect=lv*cfg.per
	else
		lv=0
		effect=0
	end
	nextEffect=(lv + 1)*cfg.per
	local effectStr
	local nextEffectStr
	if(buffID=="b1" or buffID=="b3" or buffID=="b4")then
		effectStr=G_keepNumber(effect*100,0).."%"
		nextEffectStr=G_keepNumber(nextEffect*100,0).."%"
	else
		effectStr=effect
		nextEffectStr=nextEffect
	end
	local lvLb=GetTTFLabel(lv.."/"..cfg.maxLv,25)
	lvLb:setAnchorPoint(ccp(0,0.5))
	lvLb:setPosition(ccp(160 + nameLb:getContentSize().width + 10,370))
	dialogBg:addChild(lvLb)
	local descLb=GetTTFLabelWrap(getlocal("serverWarLocal_techDesc_"..buffID,{effectStr}),22,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(160,300)
	dialogBg:addChild(descLb)
	
	local posY = math.min(370,300 - descLb:getContentSize().height/2)
	local lv1=GetTTFLabel(getlocal("fightLevel",{lv}),25)
	lv1:setColor(G_ColorYellowPro)
	lv1:setAnchorPoint(ccp(1,1))
	lv1:setPosition(285 - 30,posY - 10)
	dialogBg:addChild(lv1)
	local arrow=GetTTFLabel("→",28)
	arrow:setColor(G_ColorGreen)
	arrow:setAnchorPoint(ccp(0.5,1))
	arrow:setPosition(ccp(285,posY - 10))
	dialogBg:addChild(arrow)
	local lv2=GetTTFLabel(getlocal("fightLevel",{lv + 1}),25)
	lv2:setColor(G_ColorYellowPro)
	lv2:setAnchorPoint(ccp(0,1))
	lv2:setPosition(285 + 30,posY - 10)
	dialogBg:addChild(lv2)
	local effect1=GetTTFLabel(effectStr,25)
	effect1:setAnchorPoint(ccp(1,1))
	effect1:setPosition(285 - 30,posY - 40)
	dialogBg:addChild(effect1)
	local arrow=GetTTFLabel("→",28)
	arrow:setColor(G_ColorGreen)
	arrow:setAnchorPoint(ccp(0.5,1))
	arrow:setPosition(ccp(285,posY - 40))
	dialogBg:addChild(arrow)
	local effect2=GetTTFLabel(nextEffectStr,25)
	effect2:setAnchorPoint(ccp(0,1))
	effect2:setPosition(285 + 30,posY - 40)
	dialogBg:addChild(effect2)

	posY=posY - 70
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(570/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(285,posY))
	dialogBg:addChild(lineSp,1)
	local percentLb=GetTTFLabelWrap(getlocal("serverWarLocal_techPercentDesc",{cfg.cost,cfg.probability[lv + 1].."%%"}),25,CCSizeMake(530,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	percentLb:setPosition(285,posY - 40)
	dialogBg:addChild(percentLb)

	local function onConfirm()
		local costGems=cfg.cost
		if(serverWarLocalFightVoApi:getCarryGems()<costGems)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_not_enough_gem"),30)
			do return end
		end
		local function buyBuffCallback()
			local buffLv=serverWarLocalFightVoApi:getBuffList()[buffID]
			if(buffLv>lv)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_success"),30)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_fail"),30)
			end
			self.tv:reloadData()
			self.gemLb:setString(getlocal("serverwarteam_funds")..": "..serverWarLocalFightVoApi:getCarryGems())
			onHide()
			if(buffLv<cfg.maxLv)then
				self:showBuyBuffConfirm(buffID)
			end
		end
		serverWarLocalFightVoApi:buyBuff(buffID,buyBuffCallback)
	end
	local buyItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("confirm"),25)
	local buyBtn=CCMenu:createWithItem(buyItem)
	buyBtn:setTouchPriority(-(layerNum-1)*20-2)
	buyBtn:setPosition(150,60)
	dialogBg:addChild(buyBtn)

	local cancelItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onHide,nil,getlocal("cancel"),25)
	local cancelBtn=CCMenu:createWithItem(cancelItem)
	cancelBtn:setTouchPriority(-(layerNum-1)*20-2)
	cancelBtn:setPosition(420,60)
	dialogBg:addChild(cancelBtn)
end