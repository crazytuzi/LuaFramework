vipRechargeDialogNewTabMonthly={}

function vipRechargeDialogNewTabMonthly:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function vipRechargeDialogNewTabMonthly:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

	local icon=CCSprite:create("public/monthlyCard.png")
	icon:setScale(120/icon:getContentSize().width)
	icon:setPosition(ccp(120,G_VisibleSizeHeight - 250))
	self.bgLayer:addChild(icon)

	local tmpStoreCfg=G_getPlatStoreCfg()
	local mType=tmpStoreCfg["moneyType"][GetMoneyName()]
	local cardCfg = vipVoApi:getMonthlyCardCfg()
	local mPrice=cardCfg["money"][GetMoneyName()]
	local priceStr =getlocal("buyGemsPrice",{mType,mPrice})
	if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
		priceStr =getlocal("buyGemsPrice",{mPrice,mType})
	end
	local priceLb=GetTTFLabelWrap(priceStr,25,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	priceLb:setPosition(ccp(G_VisibleSizeWidth/2,130))
	self.bgLayer:addChild(priceLb)

	local function onGetReward()
		if G_checkClickEnable()==false then
			do return end
		end
		PlayEffect(audioCfg.mouseClick)
		local function callBack()
			self.rewardItem:setEnabled(false)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("active_lottery_reward_tank",{getlocal("gem"),"x"..cardCfg.goldContinue}),28)
		end
		vipVoApi:getMonthlyCardReward(callBack)
	end
	self.rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetReward,nil,getlocal("daily_scene_get"),25)
	if(vipVoApi:checkCanGetMonthlyCardReward()==false)then
		self.rewardItem:setEnabled(false)
	end
	local rewardBtn=CCMenu:createWithItem(self.rewardItem)
	rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	rewardBtn:setPosition(ccp(G_VisibleSizeWidth-200,G_VisibleSizeHeight-250))
	self.bgLayer:addChild(rewardBtn)

	local middleBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function ( ... )end)
	middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight-600))
	middleBg:setAnchorPoint(ccp(0.5,1))
	middleBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-320))
	middleBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.bgLayer:addChild(middleBg)

	local function callBack(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return 1
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(G_VisibleSizeWidth - 80,600)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local cardCfg=vipVoApi:getMonthlyCardCfg()
			local descLb=GetTTFLabelWrap(getlocal("vip_monthlyCard_desc",{cardCfg.goldFirst,cardCfg.goldContinue,(cardCfg.effectiveDays)}),25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			descLb:setAnchorPoint(ccp(0,1))
			descLb:setPosition(ccp(0,600))
			cell:addChild(descLb)
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 80,G_VisibleSizeHeight-620),nil)
	tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	tv:setPosition(ccp(10,10))
	tv:setMaxDisToBottomOrTop(110)
	middleBg:addChild(tv)

	local leftDaysStr
	local leftDays=vipVoApi:getMonthlyCardLeftDays()
	local lbColor
	if(leftDays>0)then
		leftDaysStr=getlocal("vip_monthlyCard_leftDays",{vipVoApi:getMonthlyCardLeftDays()})
		lbColor=G_ColorWhite
	else
		leftDaysStr=getlocal("not_activated")
		lbColor=G_ColorRed
	end
	self.leftDaysLb=GetTTFLabelWrap(leftDaysStr,25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	self.leftDaysLb:setColor(lbColor)
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function ( ... )end)
	downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.leftDaysLb:getContentSize().height+60))
	self.leftDaysLb:setAnchorPoint(ccp(0,0))
	self.leftDaysLb:setPosition(ccp(10,30))
	downBg:addChild(self.leftDaysLb)
	downBg:setPosition(ccp(G_VisibleSizeWidth/2,210))
	self.bgLayer:addChild(downBg)

	local function rechargeHandler()
		if G_checkClickEnable()==false then
			do return end
		end
		PlayEffect(audioCfg.mouseClick)
		vipVoApi:buyMonthlyCard(self.layerNum)
	end
	local rechargeItem=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge.png",rechargeHandler,nil,getlocal("activation"),28)
	-- --北美IOS暂时不开军需卡功能，因为IOS跟Android混服，而Android是开着的，所以无法使用后台开关，在这里直接关掉
	-- if(G_curPlatName()=="14")then
	-- 	rechargeItem:setEnabled(false)
	-- end
	local rechargeBtnMenu = CCMenu:createWithItem(rechargeItem)
	rechargeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	rechargeBtnMenu:setPosition(ccp(G_VisibleSizeWidth/2,70))
	self.bgLayer:addChild(rechargeBtnMenu)

	local function onPayment(event,data)
		self:onPaymentCallback(event,data)
	end
	self.paymentListener=onPayment
	eventDispatcher:addEventListener("user.pay",onPayment)

	return self.bgLayer
end

function vipRechargeDialogNewTabMonthly:onPaymentCallback(event,data)
	local cardCfg=vipVoApi:getMonthlyCardCfg()
	if(cardCfg==nil)then
		do return end
	end
	if(data.num==cardCfg.goldFirst)then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("vip_monthlyCard_buySuccess",{vipVoApi:getMonthlyCardLeftDays(),cardCfg.goldContinue,cardCfg.goldFirst}),nil,20)
	end
end

function vipRechargeDialogNewTabMonthly:tick()
	if(self.bgLayer:isVisible())then
		if(vipVoApi:checkCanGetMonthlyCardReward()==false)then
			self.rewardItem:setEnabled(false)
		else
			self.rewardItem:setEnabled(true)
		end
		local leftDaysStr
		local leftDays=vipVoApi:getMonthlyCardLeftDays()
		local lbColor
		if(leftDays>0)then
			leftDaysStr=getlocal("vip_monthlyCard_leftDays",{vipVoApi:getMonthlyCardLeftDays()})
			lbColor=G_ColorWhite
		else
			leftDaysStr=getlocal("not_activated")
			lbColor=G_ColorRed
		end
		self.leftDaysLb:setString(leftDaysStr)
		self.leftDaysLb:setColor(lbColor)
	end
end

function vipRechargeDialogNewTabMonthly:dispose()
	eventDispatcher:removeEventListener("user.pay",self.paymentListener)
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/monthlyCard.png")
end