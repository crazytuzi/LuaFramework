--2018春节充值活动春福临门, 基金页签
--author: Liang Qi
acCflmDialogTabInvest={}

function acCflmDialogTabInvest:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acCflmDialogTabInvest:init(acVo,layerNum)
	self.acVo=acVo
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initBackground()
	self:initTableView()
	return self.bgLayer
end

function acCflmDialogTabInvest:initBackground()
	local url=G_downloadUrl("active/acCflmBg.png")
	local function onLoadIcon(fn,sprite)
		if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer"))then
			sprite:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 370)
			self.bgLayer:addChild(sprite)
		end
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local webImage=LuaCCWebImage:createWithURL(url,onLoadIcon)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.status=acCflmVoApi:checkActiveStatus()
	local countdownStr1,countdownStr2
	if(self.status==1)then
		countdownStr1=GetTimeStr(math.max(0,acCflmVoApi:getActiveEndTs() - base.serverTime))
	else
		countdownStr1=getlocal("activity_heartOfIron_over")
	end
	countdownStr2=GetTimeStr(math.max(0,self.acVo.et - base.serverTime))
	countdownStr1=getlocal("activityCountdown")..": "..countdownStr1
	countdownStr2=getlocal("onlinePackage_next_title").." "..countdownStr2
	local scrollTv,timeLb1,timeLb2=G_LabelRollView(CCSizeMake(G_VisibleSizeWidth - 200,35),countdownStr1,25,kCCTextAlignmentCenter,G_ColorYellowPro,nil,countdownStr2,G_ColorYellowPro,2,2,2,nil)
	scrollTv:setPosition(100,G_VisibleSizeHeight - 180 - 17.5)
	self.bgLayer:addChild(scrollTv,1)
	self.timeLb1=timeLb1
	self.timeLb2=timeLb2
	local limitLb1=GetTTFLabelWrap(getlocal("activity_cflm_limit"),25,CCSizeMake(G_VisibleSizeWidth - 230,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	limitLb1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 215)
	self.bgLayer:addChild(limitLb1,1)
	local function touchTip()
		local tabStr={getlocal("activity_cflm_info21",{acCflmVoApi:getCfg().prolongTime + 1}),getlocal("activity_cflm_info22"),getlocal("activity_cflm_info23")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	local menu=G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 195),{},nil,nil,28,touchTip,true)
	menu:setTouchPriority(-(self.layerNum-1)*20-5)
	local function onClickChest(object,fn,tag)
		if(tag and tag>0)then
			if(tag>=200 and tag<300)then
				self:switchChest(tag - 200)
			else
				self:switchChest(tag)
			end
		end
	end
	self.selectedChest=acCflmVoApi:getCurBuyInvest() or 1
	for i=1,2 do
		local chestSp=LuaCCSprite:createWithSpriteFrameName("acChunjieBase1.png",onClickChest)
		chestSp:setTag(i)
		chestSp:setTouchPriority(-(self.layerNum-1)*20-5)
		chestSp:setPosition(G_VisibleSizeWidth/2 + math.pow(-1,i)*120,G_VisibleSizeHeight - 380)
		self.bgLayer:addChild(chestSp,1)
		self["chestBtn"..i]=chestSp
		if(i~=self.selectedChest)then
			chestSp:setOpacity(0)
		end
		local centerPos=getCenterPoint(chestSp)
		local baseSp=CCSprite:createWithSpriteFrameName("acChunjieBase.png")
		baseSp:setPosition(centerPos)
		chestSp:addChild(baseSp)
		local lightSp=CCSprite:createWithSpriteFrameName("acChunjieLight.png")
		lightSp:setTag(100)
		lightSp:setAnchorPoint(ccp(0.5,0))
		lightSp:setScale(1.5)
		lightSp:setPosition(centerPos)
		chestSp:addChild(lightSp)
		if(i~=self.selectedChest)then
			lightSp:setVisible(false)
		end
		local boxSp=LuaCCSprite:createWithSpriteFrameName("acChunjieBox"..i..".png",onClickChest)
		boxSp:setTag(i)
		boxSp:setScale(0.9)
		boxSp:setTouchPriority(-(self.layerNum-1)*20-5)
		boxSp:setAnchorPoint(ccp(0.5,0))
		boxSp:setPosition(chestSp:getContentSize().width/2,30)
		chestSp:addChild(boxSp)
		local priceLb
		if(i==1)then
			priceLb=GetTTFLabel(acCflmVoApi:getCfg().fundA,23)
		else
			priceLb=GetTTFLabel(acCflmVoApi:getCfg().fundB,23)
		end
		priceLb:setPosition(chestSp:getContentSize().width/2,-8)
		chestSp:addChild(priceLb,2)
		local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
		goldSp:setPosition(chestSp:getContentSize().width/2 - priceLb:getContentSize().width/2 - 20,-8)
		chestSp:addChild(goldSp,2)
		local priceBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(40,0,40,36),function ( ... )end)
		priceBg:setContentSize(CCSizeMake(priceLb:getContentSize().width + 60,priceLb:getContentSize().height + 4))
		priceBg:setPosition(chestSp:getContentSize().width/2 - 15,-8)
		chestSp:addChild(priceBg)
		local checkBox1=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
		checkBox1:setTag(101)
		checkBox1:setScale(0.8)
		checkBox1:setPosition(chestSp:getContentSize().width/2 + priceLb:getContentSize().width/2 + 30,-8)
		chestSp:addChild(checkBox1)
		if(i~=self.selectedChest)then
			checkBox1:setVisible(false)
		end
		local checkBox2=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
		checkBox2:setTag(102)
		checkBox2:setScale(0.8)
		checkBox2:setPosition(chestSp:getContentSize().width/2 + priceLb:getContentSize().width/2 + 30,-8)
		chestSp:addChild(checkBox2)
		if(i==self.selectedChest)then
			checkBox2:setVisible(false)
		end
		local checkBoxTouchSp=LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",onClickChest)
		checkBoxTouchSp:setTag(200 + i)
		checkBoxTouchSp:setTouchPriority(-(self.layerNum-1)*20-5)
		checkBoxTouchSp:setScale(checkBox1:getContentSize().width*0.8/checkBoxTouchSp:getContentSize().width)
		checkBoxTouchSp:setPosition(checkBox1:getPosition())
		checkBoxTouchSp:setOpacity(0)
		chestSp:addChild(checkBoxTouchSp)
	end
	local function onBuy()
		self:buyInvest()
	end
	self.buyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onBuy,nil,getlocal("buy"),28)
	self.buyItem:setScale(0.8)
	local buyMenu=CCMenu:createWithItem(self.buyItem)
	buyMenu:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 507)
	self.bgLayer:addChild(buyMenu,1)
	self.boughtLb=GetTTFLabel(getlocal("hasBuy"),25)
	self.boughtLb:setColor(G_ColorGray)
	self.boughtLb:setVisible(false)
	self.boughtLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 507)
	self.bgLayer:addChild(self.boughtLb,1)
	if(self.selectedChest==1)then
		self.limitLb=GetTTFLabel(getlocal("vip_tequanlibao_goumai",{acCflmVoApi:getCfg().vipLimit}),25)
	else
		local needNum=acCflmVoApi:getCfg().rechargeLimit
		local rechargeNum=tonumber(self.acVo.totalRecharge) or 0
		if(rechargeNum>needNum)then
			rechargeNum=needNum
		end
		self.limitLb=GetTTFLabel(getlocal("activity_cflm_limit2",{rechargeNum,needNum}),25)
	end
	self.limitLb:setColor(G_ColorYellowPro)
	self.limitLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 555)
	self.bgLayer:addChild(self.limitLb,1)
	local canBuy=acCflmVoApi:checkCanBuyInvest(self.selectedChest)
	if(canBuy==0)then
		self.limitLb:setColor(G_ColorRed)
	elseif(canBuy==2)then
		self.buyItem:setVisible(false)
		self.boughtLb:setVisible(true)
	end
end

function acCflmDialogTabInvest:switchChest(index)
	if(index==self.selectedChest)then
		do return end
	end
	self.selectedChest=index
	for i=1,2 do
		local chestSp=self["chestBtn"..i]
		if(chestSp and tolua.cast(chestSp,"LuaCCSprite"))then
			local lightSp=tolua.cast(chestSp:getChildByTag(100),"CCSprite")
			local checkBox1=tolua.cast(chestSp:getChildByTag(101),"CCSprite")
			local checkBox2=tolua.cast(chestSp:getChildByTag(102),"CCSprite")
			if(i==self.selectedChest)then
				if(lightSp)then
					lightSp:setVisible(true)
				end				
				if(checkBox1)then
					checkBox1:setVisible(true)
				end
				if(checkBox2)then
					checkBox2:setVisible(false)
				end
				chestSp:setOpacity(255)
			else
				if(lightSp)then
					lightSp:setVisible(false)
				end				
				if(checkBox1)then
					checkBox1:setVisible(false)
				end
				if(checkBox2)then
					checkBox2:setVisible(true)
				end
				chestSp:setOpacity(0)
			end
		end
	end
	local canBuy=acCflmVoApi:checkCanBuyInvest(self.selectedChest)
	if(canBuy==0)then
		self.limitLb:setColor(G_ColorRed)
		self.buyItem:setVisible(true)
		self.buyItem:setEnabled(true)
		self.boughtLb:setVisible(false)
	elseif(canBuy==2)then
		self.limitLb:setColor(G_ColorYellowPro)
		if(acCflmVoApi:getCurBuyInvest()==self.selectedChest)then
			self.buyItem:setVisible(false)
			self.boughtLb:setVisible(true)
		else
			self.buyItem:setVisible(true)
			self.buyItem:setEnabled(false)
			self.boughtLb:setVisible(false)
		end
	else
		self.limitLb:setColor(G_ColorYellowPro)
		self.buyItem:setVisible(true)
		self.buyItem:setEnabled(true)
		self.boughtLb:setVisible(false)
	end
	if(self.selectedChest==1)then
		self.limitLb:setString(getlocal("vip_tequanlibao_goumai",{acCflmVoApi:getCfg().vipLimit}))
	else
		local needNum=acCflmVoApi:getCfg().rechargeLimit
		local rechargeNum=tonumber(self.acVo.totalRecharge) or 0
		if(rechargeNum>needNum)then
			rechargeNum=needNum
		end
		self.limitLb:setString(getlocal("activity_cflm_limit2",{rechargeNum,needNum}))
	end
	if(self.tv and tolua.cast(self.tv,"CCTableView"))then
		self.tv:reloadData()
		self.tv:stopAllActions()
		self.tv:setScaleY(0.02)
		self.tv:setPositionY(85 + (G_VisibleSizeHeight - 660)/2)
		local scaleTo=CCScaleTo:create(0.2,1,1)
		local moveTo=CCMoveTo:create(0.2,ccp(25,85))
		local acArr=CCArray:create()
		acArr:addObject(scaleTo)
		acArr:addObject(moveTo)
		local spawn=CCSpawn:create(acArr)
		self.tv:runAction(spawn)
	end
end

function acCflmDialogTabInvest:buyInvest()
	local canBuy=acCflmVoApi:checkCanBuyInvest(self.selectedChest)
	if(canBuy~=1)then
		if(canBuy==0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("get_prop_error1"),28)
		elseif(canBuy==2)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("activity_cjms_only1"),28)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage2034"),28)
		end
		do return end
	end
	local costGem
	if(self.selectedChest==1)then
		costGem=acCflmVoApi:getCfg().fundA
	else
		costGem=acCflmVoApi:getCfg().fundB
	end
	if(playerVoApi:getGems()<costGem)then
		GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
		do return end
	end
	local function onConfirmTwice()
		local function callback()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("alliance_successfulOperation"),28)
			if(self.limitLb and tolua.cast(self.limitLb,"CCLabelTTF"))then
				self.limitLb:setColor(G_ColorYellowPro)
				self.buyItem:setVisible(false)
				self.boughtLb:setVisible(true)
			end
			if(self.tv and tolua.cast(self.tv,"CCTableView"))then
				self.tv:reloadData()
			end
		end
		acCflmVoApi:buyInvest(self.selectedChest,callback)
	end
	local function onConfirm()
		smallDialog:showSureAndCancle("rewardPanelBg1.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(30, 30, 1, 1),onConfirmTwice,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{costGem}),nil,self.layerNum + 1)
	end
	smallDialog:showSureAndCancle("rewardPanelBg1.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(30, 30, 1, 1),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_cflm_confirm",{costGem}),nil,self.layerNum + 1)
end

function acCflmDialogTabInvest:initTableView()
	local forbidUpBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),function ( ... )end)
	forbidUpBg:setTouchPriority(-(self.layerNum-1)*20-4)
	forbidUpBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,400))
	forbidUpBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 370)
	forbidUpBg:setOpacity(0)
	self.bgLayer:addChild(forbidUpBg)
	local forbidDownBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),function ( ... )end)
	forbidDownBg:setTouchPriority(-(self.layerNum-1)*20-4)
	forbidDownBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,75))
	forbidDownBg:setAnchorPoint(ccp(0.5,0))
	forbidDownBg:setPosition(G_VisibleSizeWidth/2,0)
	forbidDownBg:setOpacity(0)
	self.bgLayer:addChild(forbidDownBg)
	self.curDay=acCflmVoApi:getCurrentDay()
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("borderOrange.png",CCRect(4,4,3,3),function ( ... )end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 663))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(20,80)
	self.bgLayer:addChild(tvBg)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 673),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(25,85))
	self.tv:setMaxDisToBottomOrTop(30)
	self.bgLayer:addChild(self.tv,1)
	local descBg=CCSprite:createWithSpriteFrameName("lineWhite.png")
	descBg:setScaleX((G_VisibleSizeWidth - 30)/descBg:getContentSize().width)
	descBg:setScaleY(60/descBg:getContentSize().height)
	descBg:setColor(ccc3(32,28,18))
	descBg:setAnchorPoint(ccp(0,0))
	descBg:setPosition(15,15)
	self.bgLayer:addChild(descBg)
	local descLb,height=G_getRichTextLabel(getlocal("activity_cflm_desc",{acCflmVoApi:getCfg().needValue*100}),{G_ColorWhite,G_ColorYellowPro,G_ColorWhite},23,G_VisibleSizeWidth - 30,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	descLb:setAnchorPoint(ccp(0,1))
	if(height<40)then
		descLb:setPosition(ccp(15,57))
	else
		descLb:setPosition(ccp(15,75))
	end
	self.bgLayer:addChild(descLb)
end

function acCflmDialogTabInvest:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if(self.selectedChest==1)then
			if(acCflmVoApi:getCfg().fundAreward)then
				return #(acCflmVoApi:getCfg().fundAreward)
			else
				return 0
			end
		else
			if(acCflmVoApi:getCfg().fundBreward)then
				return #(acCflmVoApi:getCfg().fundBreward)
			else
				return 0
			end
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth - 50,150)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local day=idx + 1
		local cellWidth,cellHeight=G_VisibleSizeWidth - 50,150
		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Bg2.png",CCRect(40,15,10,10),function ( ... )end)
		cellBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
		cellBg:setPosition(cellWidth/2,cellHeight/2)
		cell:addChild(cellBg)
		local titleLb=GetTTFLabel(getlocal("activity_continueRecharge_dayDes",{day}),25)
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(40,cellHeight - 20)
		cell:addChild(titleLb,1)		
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Title1.png",CCRect(0,0,20,33),function ( ... )end)
		titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width + 105,33))
		titleBg:setAnchorPoint(ccp(0,0.5))
		titleBg:setPosition(0,cellHeight - 20)
		cell:addChild(titleBg)
		local status=acCflmVoApi:checkInvestStatusByDay(day)
		local curBuyInvest=acCflmVoApi:getCurBuyInvest()
		local rewardCfg
		if(self.selectedChest==1)then
			rewardCfg=acCflmVoApi:getCfg().fundAreward[day]
		else
			rewardCfg=acCflmVoApi:getCfg().fundBreward[day]
		end
		local rewardTb=FormatItem(rewardCfg[2],true,true)
		for k,v in pairs(rewardTb) do
			local function showNewReward()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
				return false
			end
			local isGem=(v.type=="u" and v.key=="gems")
			local icon
			if(isGem)then
				icon=CCSprite:createWithSpriteFrameName("iconGoldNew3.png")
				icon:setScale(0.8)
			else
				icon=G_getItemIcon(v,80,true,self.layerNum,showNewReward)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
			end
			if(k==1)then
				icon:setAnchorPoint(ccp(0.5,0.5))
				icon:setPosition(60 + (k - 1)*100,65)
				local plusIcon=CCSprite:createWithSpriteFrameName("plusOrange.png")
				plusIcon:setPosition(20 + (k - 1)*100 + 80 + 25,20 + 40)
				cell:addChild(plusIcon)
			else
				icon:setAnchorPoint(ccp(0,0))
				icon:setPosition(50 + (k - 1)*100,20)
			end
			cell:addChild(icon)
			--金币不加成
			--没有购买基金，或者手动领取基金的时候显示加成图标
			if((curBuyInvest~=self.selectedChest or status~=3 and status~=4) and isGem==false)then
				local plusIcon=CCSprite:createWithSpriteFrameName("saleRedBg.png")
				plusIcon:setPosition(icon:getContentSize().width - 20,icon:getContentSize().height - 20)
				icon:addChild(plusIcon)
				local lb=GetTTFLabel(((acCflmVoApi:getCfg().needValue)*100).."%",23)
				lb:setPosition(getCenterPoint(plusIcon))
				plusIcon:addChild(lb)
			end
			local numLb
			if(isGem)then
				numLb=GetBMLabel(v.num,G_GoldFontSrc)
				numLb:setScale(0.5)
				numLb:setAnchorPoint(ccp(0.5,1))
				numLb:setPosition(icon:getContentSize().width/2,5)
			else
				numLb=GetTTFLabel("×"..v.num,25)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(icon:getContentSize().width - 5,5)
			end
			icon:addChild(numLb)
		end
				
		if(curBuyInvest~=self.selectedChest)then
			local lb=GetTTFLabel(getlocal("not_buy"),25)
			lb:setPosition(cellWidth - 100,cellHeight/2)
			cell:addChild(lb)
		else
			if(status==0)then
				local lb=GetTTFLabelWrap(getlocal("receivereward_nostart"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				lb:setPosition(cellWidth - 100,cellHeight/2)
				cell:addChild(lb)
			elseif(status==1)then
				local function onGetReward(tag,object)
					if(tag and tag>100)then
						self:getInvestReward(tag - 100)
					end
				end
				local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGetReward,100 + day,getlocal("daily_scene_get"),28)
				rewardItem:setScale(0.8)
				local rewardMenu=CCMenu:createWithItem(rewardItem)
				rewardMenu:setPosition(cellWidth - 100,cellHeight/2)
				cell:addChild(rewardMenu)
			elseif(status==2)then
				local lb=GetTTFLabel(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				lb:setColor(G_ColorGray)
				lb:setPosition(cellWidth - 100,cellHeight/2)
				cell:addChild(lb)
			elseif(status==3)then
				local lb=GetTTFLabel(getlocal("activity_cflm_invest_later"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				lb:setColor(G_ColorGray)
				lb:setPosition(cellWidth - 100,cellHeight/2)
				cell:addChild(lb)
			elseif(status==4)then
				local lb=GetTTFLabel(getlocal("already_sent"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				lb:setColor(G_ColorGray)
				lb:setPosition(cellWidth - 100,cellHeight/2)
				cell:addChild(lb)
			end
		end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function acCflmDialogTabInvest:tick()
	local oldStatus=self.status
	self.status=acCflmVoApi:checkActiveStatus()
	if(self.timeLb1 and tolua.cast(self.timeLb1,"CCLabelTTF"))then
		local countdownStr1,countdownStr2
		if(self.status==1)then
			countdownStr1=GetTimeStr(math.max(0,acCflmVoApi:getActiveEndTs() - base.serverTime))
		else
			countdownStr1=getlocal("activity_heartOfIron_over")
		end
		countdownStr2=GetTimeStr(math.max(0,self.acVo.et - base.serverTime))
		self.timeLb1:setString(getlocal("activityCountdown")..": "..countdownStr1)
		self.timeLb2:setString(getlocal("onlinePackage_next_title").." "..countdownStr2)
	end
	local oldDay=self.curDay
	self.curDay=acCflmVoApi:getCurrentDay()
	if(oldStatus~=self.status or oldDay~=self.curDay)then
		if(self.status==2)then
			if(self.buyItem and tolua.cast(self.buyItem,"CCMenuItemSprite"))then
				self.buyItem:setEnabled(false)
			end
		end
		if(self.tv and tolua.cast(self.tv,"CCTableView"))then
			self.tv:reloadData()
		end
	end
end

function acCflmDialogTabInvest:getInvestReward(day)
	local function callback()
		if(self.tv and tolua.cast(self.tv,"CCTableView"))then
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		end
	end
	acCflmVoApi:getInvestReward(day,callback)
end

function acCflmDialogTabInvest:dispose()
	if(self.tv and self.tv.stopAllActions)then
		self.tv:stopAllActions()
	end
	self.tv=nil
	self.selectedChest=nil
	self.curDay=nil
	self.status=nil
	self.bgLayer=nil
end