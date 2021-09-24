platWarBuffDialog=commonDialog:new()

function platWarBuffDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function platWarBuffDialog:resetTab()
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function platWarBuffDialog:initTableView( ... )
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 130),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,30))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)
end

function platWarBuffDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(platWarCfg.techBuff)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(G_VisibleSizeWidth - 60,126)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local function onBuyBuff(tag,object)
			if(tag and tag>0)then
				self:showBuyBuffConfirm("s"..tag)
			end
		end
		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),onBuyBuff)
		cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,120))
		cellBg:setAnchorPoint(ccp(0.5,0))
		cellBg:setPosition(ccp((G_VisibleSizeWidth - 60)/2,3))
		cell:addChild(cellBg)
		local buffID="s"..(idx + 1)
		local icon=CCSprite:createWithSpriteFrameName(platWarCfg.techBuff[buffID]["icon"])
		icon:setPosition(ccp(60,60))
		cellBg:addChild(icon)
		local cfg=platWarCfg.techBuff[buffID]
		local nameLb=GetTTFLabel(getlocal("plat_war_techName_"..buffID),25)
		nameLb:setColor(G_ColorGreen)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(120,100))
		cellBg:addChild(nameLb)
		local lv,effect
		if(platWarVoApi:getBuffList()[buffID])then
			lv=platWarVoApi:getBuffList()[buffID]
			effect=cfg.effect[lv]
		else
			lv=0
			effect=0
			if(buffID=="s6")then
				effect=1
			end
		end
		local effectStr
		if(buffID=="s1" or buffID=="s2" or buffID=="s3" or buffID=="s4")then
			effectStr=G_keepNumber(effect*100,0).."%%"
		elseif(buffID=="s6") then
			effectStr=G_keepNumber((1 - effect)*100,0).."%%"
		else
			effectStr=effect
		end
		local lvLb=GetTTFLabel(lv.."/"..cfg.lvLimit,25)
		lvLb:setAnchorPoint(ccp(0,0.5))
		lvLb:setPosition(ccp(120 + nameLb:getContentSize().width + 10,100))
		cellBg:addChild(lvLb)

		local descLb=GetTTFLabelWrap(getlocal("plat_war_techDesc_"..buffID,{effectStr}),22,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(120,40)
		cellBg:addChild(descLb)

		local buyItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onBuyBuff,idx + 1,getlocal("upgradeBuild"),25)
		buyItem:setScale(0.9)
		local buyBtn=CCMenu:createWithItem(buyItem)
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		buyBtn:setPosition(490,60)
		cellBg:addChild(buyBtn)
		if(lv>=cfg.lvLimit)then
			buyItem:setEnabled(false)
		end
		local status=platWarVoApi:checkStatus()
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

function platWarBuffDialog:showBuyBuffConfirm(buffID)
	local fleetIndexTb=tankVoApi:getPlatWarFleetIndexTb()
	if(fleetIndexTb==nil or #fleetIndexTb<3)then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("plat_war_buyBuffError"),true,self.layerNum + 1)
		do return end
	end
	for k,v in pairs(fleetIndexTb) do
		if(v==nil or v<=0)then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("plat_war_buyBuffError"),true,self.layerNum + 1)
			do return end
		end
	end
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
	local cfg=platWarCfg.techBuff[buffID]
	local icon=CCSprite:createWithSpriteFrameName(platWarCfg.techBuff[buffID]["icon"])
	icon:setPosition(ccp(100,320))
	dialogBg:addChild(icon)
	local nameLb=GetTTFLabel(getlocal("plat_war_techName_"..buffID),25)
	nameLb:setColor(G_ColorGreen)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(ccp(160,370))
	dialogBg:addChild(nameLb)
	local lv,effect,nextEffect
	if(platWarVoApi:getBuffList()[buffID])then
		lv=platWarVoApi:getBuffList()[buffID]
		effect=cfg.effect[lv]
	else
		lv=0
		effect=0
		if(buffID=="s6")then
			effect=1
		end
	end
	nextEffect=cfg.effect[lv + 1] or effect
	local effectStr
	local nextEffectStr
	if(buffID=="s1" or buffID=="s2" or buffID=="s3" or buffID=="s4")then
		effectStr=G_keepNumber(effect*100,0).."%"
		nextEffectStr=G_keepNumber(nextEffect*100,0).."%"
	elseif(buffID=="s6") then
		effectStr=G_keepNumber((1 - effect)*100,0).."%"
		nextEffectStr=G_keepNumber((1 - nextEffect)*100,0).."%"
	else
		effectStr=effect
		nextEffectStr=nextEffect
	end
	local lvLb=GetTTFLabel(lv.."/"..cfg.lvLimit,25)
	lvLb:setAnchorPoint(ccp(0,0.5))
	lvLb:setPosition(ccp(160 + nameLb:getContentSize().width + 10,370))
	dialogBg:addChild(lvLb)
	local descLb=GetTTFLabelWrap(getlocal("plat_war_techDesc_"..buffID,{effectStr.."%"}),22,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
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
	local percentLb=GetTTFLabelWrap(getlocal("plat_war_techPercentDesc",{cfg.cost[lv + 1],cfg.successRate[lv + 1].."%%"}),25,CCSizeMake(530,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	percentLb:setPosition(285,posY - 40)
	dialogBg:addChild(percentLb)

	local function onConfirm()
		local costGems=cfg.cost[lv + 1]
		if(playerVoApi:getGems()<costGems)then
			local needGem=costGems - playerVoApi:getGems()
			GemsNotEnoughDialog(nil,nil,needGem,layerNum+1,costGems)
			do return end
		end
		local function buyBuffCallback()
			playerVoApi:setGems(playerVoApi:getGems() - costGems)
			local buffLv=platWarVoApi:getBuffList()[buffID]
			if(buffLv>lv)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_success"),30)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_fail"),30)
			end
			self.tv:reloadData()
			onHide()
		end
		platWarVoApi:buyBuff(buffID,buyBuffCallback)
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