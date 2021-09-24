--等待队列已满, 加速或者去升级vip的提示面板
vipQueueDialog=smallDialog:new()

--param type: 1为建筑 2为生产坦克 3为改装坦克 4为科技研究 5为道具生产 6为出战部队
function vipQueueDialog:new(type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.type=type
	nc.dialogWidth=550
	--每一部分的高度
	nc.partHeight=300
	return nc
end

--param speedCallback: 加速完成之后的回调
--param data: 一些队列需要传参数进来
function vipQueueDialog:init(layerNum,speedCallback,data)
	--如果队列已经达到最大值, 再提升vip也没法出新的队列了，那么下半部分就不显示
	if(self:checkShowTwoParts())then
		self.dialogHeight=self.partHeight*2 + 85 + 30 + 30
		self.showDown=true
	else
		self.dialogHeight=self.partHeight + 85 + 15
		self.showDown=false
	end

	self.isTouch=nil
	self.layerNum=layerNum
	self.speedCallback=speedCallback
	self.data=data
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
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
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))

	local titleLb=GetTTFLabel(getlocal("vipQueue_queueNotEnough"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local upType,downType=self:getUpDownType()
	self.upType=upType
	self.downType=downType
	self:initUpContent()
	if(self.showDown)then
		self:initDownContent()
	end
	return self.dialogLayer
end

function vipQueueDialog:initUpContent()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... )end)
	background:setContentSize(CCSizeMake(self.dialogWidth - 60,self.partHeight))
	background:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 85 - self.partHeight/2))
	self.bgLayer:addChild(background,1)

	local descTv
	if(self.upType==0)then
		if(self.type==6)then
			descTv=G_LabelTableView(CCSizeMake(320,self.partHeight/2),getlocal("vipQueue_desc12"),25,kCCTextAlignmentLeft)
		else
			local contenStr
	        if base.autoUpgrade==1 and buildingVoApi:getAutoUpgradeBuilding()==1 and buildingVoApi:getAutoUpgradeExpire()-base.serverTime>0 then
	            contenStr = getlocal("vipQueue_desc11")..getlocal("building_auto_upgrade_quick")
	        else
	            contenStr = getlocal("vipQueue_desc11")
	        end
			descTv=G_LabelTableView(CCSizeMake(320,self.partHeight/2),contenStr,25,kCCTextAlignmentLeft)
		end
	elseif(self.upType==1)then
		needVip,needGems=self:getNextQueueVipAndGem()
		local downDesc=getlocal("vipQueue_desc21",{playerVoApi:getVipLevel(),needGems,needVip})
		descTv=G_LabelTableView(CCSizeMake(320,self.partHeight/2),downDesc,25,kCCTextAlignmentLeft)
	elseif(self.upType==2)then
		descTv=G_LabelTableView(CCSizeMake(320,self.partHeight/2),getlocal("vipQueue_desc22",{playerVoApi:getVipLevel()}),25,kCCTextAlignmentLeft)
	end
	descTv:setAnchorPoint(ccp(0,0))
	descTv:setPosition(ccp(15,self.partHeight/2 - 10))
	descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	descTv:setMaxDisToBottomOrTop(60)
	background:addChild(descTv)

	if(self.type~=6)then
		local needLb=GetTTFLabel(getlocal("activity_equipSearch_need"),25)
		needLb:setColor(G_ColorYellowPro)
		needLb:setAnchorPoint(ccp(0,0.5))
		needLb:setPosition(ccp(15,self.partHeight/2 - 30))
		background:addChild(needLb)

		if(self.upType==1)then
			local vipLb=CCSprite:createWithSpriteFrameName("Vip"..needVip..".png")
			if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
				vipLb=GetTTFLabel(getlocal("VIPStr1",{needVip}),25)
			end
			vipLb:setAnchorPoint(ccp(0,0.5))
			vipLb:setPosition(ccp(15 + needLb:getContentSize().width + 10,self.partHeight/2 - 30))
			background:addChild(vipLb)
		else
			local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
			gemIcon:setAnchorPoint(ccp(0,0.5))
			gemIcon:setPosition(ccp(15 + needLb:getContentSize().width + 10,self.partHeight/2 - 30))
			background:addChild(gemIcon)
	
			local cost
			if(self.upType==0)then
				cost=self:getSpeedUpCost()
			elseif(self.upType==2)then
				cost=playerCfg.buildQueuePrice[playerVoApi:getOriginBuildingSlotNum() + 1]
			end
	
			local costLb=GetTTFLabel("x"..cost,25)
			costLb:setColor(G_ColorYellowPro)
			costLb:setAnchorPoint(ccp(0,0.5))
			costLb:setPosition(ccp(gemIcon:getPositionX() + gemIcon:getContentSize().width + 10,self.partHeight/2 - 30))
			background:addChild(costLb)
		end
	end

	local portraitSp=CCSprite:createWithSpriteFrameName("NewCharacter01.png")
	portraitSp:setScale(self.partHeight*4/5/portraitSp:getContentSize().height)
	portraitSp:setAnchorPoint(ccp(1,0))
	portraitSp:setPosition(ccp(background:getContentSize().width + 20,0))
	background:addChild(portraitSp)

	local function onSpeedUp()
		PlayEffect(audioCfg.mouseClick)
		self:clickUp()
	end
	local speedStr
	if(self.type==6)then
		speedStr=getlocal("activity_heartOfIron_goto")
	else
		if(self.upType==0)then
			speedStr=getlocal("accelerateBuild")
		elseif(self.upType==1)then
			speedStr=getlocal("recharge")
		elseif(self.upType==2)then
			speedStr=getlocal("buy")
		end
	end
	local speedItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onSpeedUp,2,speedStr,25)
	local speedBtn=CCMenu:createWithItem(speedItem);
	speedBtn:setPosition(ccp(15 + descTv:getContentSize().width/2,45))
	speedBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	background:addChild(speedBtn)
end

function vipQueueDialog:initDownContent()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... )end)
	background:setContentSize(CCSizeMake(self.dialogWidth - 60,self.partHeight))
	background:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 115 - self.partHeight*3/2))
	self.bgLayer:addChild(background,1)

	local downDesc
	local needVip,needGems
	if(self.downType==2)then
		downDesc=getlocal("vipQueue_desc22",{playerVoApi:getVipLevel()})
	elseif(self.downType==3)then
		downDesc=getlocal("vipQueue_desc23",{playerCfg.tempslotsgold,math.floor(playerCfg.tempslotstime/86400)})
	else
		needVip,needGems=self:getNextQueueVipAndGem()
		downDesc=getlocal("vipQueue_desc21",{playerVoApi:getVipLevel(),needGems,needVip})
	end
	local descTv=G_LabelTableView(CCSizeMake(320,self.partHeight/2),downDesc,25,kCCTextAlignmentLeft)
	descTv:setAnchorPoint(ccp(0,0))
	descTv:setPosition(ccp(15,self.partHeight/2 - 10))
	descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	descTv:setMaxDisToBottomOrTop(60)
	background:addChild(descTv)

	local needLb=GetTTFLabel(getlocal("activity_equipSearch_need"),25)
	needLb:setColor(G_ColorYellowPro)
	needLb:setAnchorPoint(ccp(0,0.5))
	needLb:setPosition(ccp(15,self.partHeight/2 -30))
	background:addChild(needLb)

	if(self.downType==2)then
		local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
		gemIcon:setAnchorPoint(ccp(0,0.5))
		gemIcon:setPosition(ccp(15 + needLb:getContentSize().width + 10,self.partHeight/2 - 30))
		background:addChild(gemIcon)

		local costGems=playerCfg.buildQueuePrice[playerVoApi:getOriginBuildingSlotNum() + 1]
		local costLb=GetTTFLabel("x"..costGems,25)
		costLb:setColor(G_ColorYellowPro)
		costLb:setAnchorPoint(ccp(0,0.5))
		costLb:setPosition(ccp(gemIcon:getPositionX() + gemIcon:getContentSize().width + 10,self.partHeight/2 - 30))
		background:addChild(costLb)
	elseif(self.downType==3)then
		local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
		gemIcon:setAnchorPoint(ccp(0,0.5))
		gemIcon:setPosition(ccp(15 + needLb:getContentSize().width + 10,self.partHeight/2 - 30))
		background:addChild(gemIcon)

		local costGems=playerCfg.tempslotsgold
		local costLb=GetTTFLabel("x"..costGems,25)
		costLb:setColor(G_ColorYellowPro)
		costLb:setAnchorPoint(ccp(0,0.5))
		costLb:setPosition(ccp(gemIcon:getPositionX() + gemIcon:getContentSize().width + 10,self.partHeight/2 - 30))
		background:addChild(costLb)
	else
		local vipLb=CCSprite:createWithSpriteFrameName("Vip"..needVip..".png")
		if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
			vipLb=GetTTFLabel(getlocal("VIPStr1",{needVip}),25)
		end
		vipLb:setAnchorPoint(ccp(0,0.5))
		vipLb:setPosition(ccp(15 + needLb:getContentSize().width + 10,self.partHeight/2 - 30))
		background:addChild(vipLb)
	end

	local portraitSp=CCSprite:createWithSpriteFrameName("NewCharacter02.png")
	portraitSp:setScale(self.partHeight*4/5/portraitSp:getContentSize().height)
	portraitSp:setAnchorPoint(ccp(1,0))
	portraitSp:setPosition(ccp(background:getContentSize().width + 10,0))
	background:addChild(portraitSp)

	local function onClickDownBtn()
		PlayEffect(audioCfg.mouseClick)
		self:clickDown()
	end
	local btnStr
	if(self.downType==2 or self.downType==3)then
		btnStr=getlocal("buy")
	else
		btnStr=getlocal("recharge")
	end
	local downItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickDownBtn,2,btnStr,25)
	local downBtn=CCMenu:createWithItem(downItem);
	downBtn:setPosition(ccp(15 + descTv:getContentSize().width/2,45))
	downBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	background:addChild(downBtn)
end

function vipQueueDialog:checkShowTwoParts()
	if(self.type==1 and buildingSlotVoApi:getCanHaveSlotsMaxNum()>playerVoApi:getOriginBuildingSlotNum())then
		return true
	end
	local queueCfg
	if(self.type==1)then
		queueCfg=playerCfg.vip4BuildQueue
	elseif(self.type==6)then
		queueCfg=playerCfg.actionFleets
	else
		queueCfg=playerCfg.vipProuceQueue
	end
	queueCfg=Split(queueCfg,",")
	local vipLv=playerVoApi:getVipLevel()
	local curNum=tonumber(queueCfg[vipLv + 1])
	local maxVip=#queueCfg
	local nextVip
	for i=vipLv + 2,maxVip do
		local nextNum=tonumber(queueCfg[i])
		if(nextNum and nextNum>curNum)then
			nextVip=i - 1
			break
		end
	end
	if(nextVip and nextVip<=playerVoApi:getMaxLvByKey("maxVip"))then
		return true
	else
		if(self.type==1 and base.ifTmpSlotOpen==1)then
			if(playerVoApi:getTmpSlotTs()<base.serverTime and playerVoApi:getBuildingSlotNum()>=SizeOfTable(buildingSlotVoApi:getAllBuildingSlots()))then
				return true
			else
				return false
			end
		else
			return false
		end
	end
end

function vipQueueDialog:getSpeedUpCost()
	local costTime
	if(self.type==1)then
		local recentSlot=buildingSlotVoApi:getShortestSlot()
		if(recentSlot)then
			costTime=recentSlot.et - base.serverTime
		end
	elseif(self.type==2)then
		local recentSlot=tankSlotVoApi:getCurProduceSlot(self.data)
		if(recentSlot)then
			costTime=recentSlot.et - base.serverTime
		end
	elseif(self.type==3)then
		local recentSlot=tankUpgradeSlotVoApi:getCurProduceSlot(self.data)
		if(recentSlot)then
			costTime=recentSlot.et - base.serverTime
		end
	elseif(self.type==4)then
		local allSlot = technologySlotVoApi:getAllSlotSortBySt()
		local recentSlot=allSlot[1]
		if recentSlot and recentSlot.et~=nil then
			costTime=recentSlot.et - base.serverTime
		else
			costTime=0
		end
	elseif(self.type==5)then
		local recentSlot=workShopSlotVoApi:getProductSolt()
		if(recentSlot)then
			costTime=recentSlot.et - base.serverTime
		end
	end
	if(costTime==nil or costTime<0)then
		costTime=0
	end
	local costGems=TimeToGems(costTime)
	return costGems
end

--获取上下两格的内容
--return upType,downType: 0为加速, 1为VIP等级不足，队列达到上限, 2为当前VIP等级的新队列未购买（建筑队列提示）,3为购买临时建造队列
function vipQueueDialog:getUpDownType()
	if(self.type==1)then
		if(buildingSlotVoApi:getCanHaveSlotsMaxNum()>playerVoApi:getOriginBuildingSlotNum())then
			if(base.ifTmpSlotOpen==1 and playerVoApi:getTmpSlotTs()<base.serverTime)then
				return 2,3
			else
				return 0,2
			end
		elseif(base.ifTmpSlotOpen==1 and playerVoApi:getTmpSlotTs()<base.serverTime and playerVoApi:getBuildingSlotNum()>=SizeOfTable(buildingSlotVoApi:getAllBuildingSlots()))then
			if(playerVoApi:getOriginBuildingSlotNum()<buildingSlotVoApi:getVersionMaxSlots())then
				return 1,3
			else
				return 0,3
			end
		else
			return 0,1
		end
	else
		return 0,1
	end
end

--获取出现下一个队列所需要的vip等级和金币
--return vip等级和还需要的金币
function vipQueueDialog:getNextQueueVipAndGem()
	local queueCfg
	if(self.type==1)then
		queueCfg=playerCfg.vip4BuildQueue
	elseif(self.type==6)then
		queueCfg=playerCfg.actionFleets
	else
		queueCfg=playerCfg.vipProuceQueue
	end
	queueCfg=Split(queueCfg,",")
	local vipLv=playerVoApi:getVipLevel()
	local curNum=tonumber(queueCfg[vipLv + 1])
	local maxVip=#queueCfg
	local nextVip
	for i=vipLv + 2,maxVip do
		local nextNum=tonumber(queueCfg[i])
		if(nextNum>curNum)then
			nextVip=i - 1
			break
		end
	end
	if(nextVip)then
		local gemCfg=Split(G_getPlatVipCfg(),",")
		local needGems=tonumber(gemCfg[nextVip])
		local rechargedGems=playerVoApi:getVipExp()
		return nextVip,needGems - rechargedGems
	else
		return 0,0
	end
end

function vipQueueDialog:clickUp()
	if(self.upType==0)then
		self:speedUp()
	elseif(self.upType==1)then
		vipVoApi:showRechargeDialog(self.layerNum)
		self:close()
	elseif(self.upType==2)then
		self:buyBuildingSlot()
	end
end

function vipQueueDialog:clickDown()
	if(self.downType==2)then
		self:buyBuildingSlot()
	elseif(self.downType==3)then
		self:buyTmpBuildSlot()
 	else
		vipVoApi:showRechargeDialog(self.layerNum)
		self:close()
	end
end

--点击加速按钮
function vipQueueDialog:speedUp()
	--如果是出战部队的话, 按钮是跳转, 否则才是加速
	if(self.type==6)then
        require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
		local td=tankDefenseDialog:new(self.layerNum,true)
		local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,self.layerNum)
		td:tabClick(1)
		sceneGame:addChild(dialog,self.layerNum)
		self:close()
	else
		self.cost=self:getSpeedUpCost()
		if self.cost>0 then
			local needGems=getlocal("speedUp",{self.cost})
			if self.cost>playerVoApi:getGems() then --金币不足
				GemsNotEnoughDialog(nil,nil,self.cost - playerVoApi:getGems(),self.layerNum + 1,self.cost)
			else
				local function onConfirm()
					self:doSpeedUp()
				end
				local smallD=smallDialog:new()
				smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),needGems,nil,self.layerNum + 1)
			end
		else
			self:close()
		end
	end
end

--确认加速, 与后台通信
function vipQueueDialog:doSpeedUp()
	local cost=self:getSpeedUpCost()
	if(cost~=self.cost)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),30)
		self:close()
		do return end
	end
	if(self.type==1)then
		local recentSlot=buildingSlotVoApi:getShortestSlot()
		if(recentSlot==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),30)
			self:close()
			do return end
		end
		local function serverSuperUpgrade(fn,data)
			if base:checkServerData(data)==true then  
				if buildingVoApi:superUpgradeBuild(recentSlot.bid) then --加速成功
					base:tick()
				end
				if(self.speedCallback)then
					self:speedCallback()
				end
			end
		end
		if buildingVoApi:checkSuperUpgradeBuildBeforeServer(recentSlot.bid)==true then
			socketHelper:superUpgradeBuild(recentSlot.bid,buildingVoApi:getBuildiingVoByBId(recentSlot.bid).type,serverSuperUpgrade)
			self:close()
		end
	elseif(self.type==2)then
		local recentSlot=tankSlotVoApi:getCurProduceSlot(self.data)
		if(recentSlot==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),30)
			self:close()
			do return end
		end
		local tid=tonumber(recentSlot.itemId)
		local nums=tonumber(recentSlot.itemNum)
		local slotid=tonumber(recentSlot.slotId)
		local tankname=getlocal(tankCfg[tankSlotVoApi:getSlotBySlotid(self.data,slotid).itemId].name)
		local function serverSuperUpgrade(fn,data)
			if base:checkServerData(data)==true then
				smallDialog:showTipsDialog("SuccessPanelSmall.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{tankname}),28)
				G_cancelPush("t"..self.data.."_"..recentSlot.slotId,G_TankProduceTag)
				eventDispatcher:dispatchEvent("tankslot.speedup")
				if(self.speedCallback)then
					self:speedCallback()
				end
				self:close()
			end
		end
		socketHelper:speedupTanks(self.data,slotid,tid,nums,serverSuperUpgrade)
	elseif(self.type==3)then
		local recentSlot=tankUpgradeSlotVoApi:getCurProduceSlot(self.data)
		if(recentSlot==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),30)
			self:close()
			do return end
		end
		local tid=tonumber(recentSlot.itemId)
		local nums=tonumber(recentSlot.itemNum)
		local slotid=tonumber(recentSlot.slotId)
		local tankname=getlocal(tankCfg[tankUpgradeSlotVoApi:getSlotBySlotid(self.data,slotid).itemId].name)
		local function serverSuperUpgrade(fn,data)
			if base:checkServerData(data)==true then
				if base:checkServerData(data)==true then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{tankname}),28)
					G_cancelPush("t"..self.data.."_"..recentSlot.slotId,G_TankProduceTag)
					tankVoApi:cancleUpgrade(self.data,recentSlot.slotId)
				end
				eventDispatcher:dispatchEvent("tankslot.speedup")
				if(self.speedCallback)then
					self:speedCallback()
				end
				self:close()
			end
		end
		socketHelper:speedupUpgradeTanks(self.data,slotid,tid,nums,serverSuperUpgrade)
	elseif(self.type==4)then
		local allSlot = technologySlotVoApi:getAllSlotSortBySt()
		local recentSlot=allSlot[1]
		if(recentSlot==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),30)
			self:close()
			do return end
		end
		local function superServerHandler(fn,data)
			if base:checkServerData(data)==true then
				technologyVoApi:superUpgrade(recentSlot.tid)
				eventDispatcher:dispatchEvent("techslot.speedup")
				if(self.speedCallback)then
					self:speedCallback()
				end
				self:close()
			end
		end
		local result,reason=technologyVoApi:checkSuperUpgradeBeforeSendServer(recentSlot.tid)
		if result==false then
			if reason==1 then --升级已完成
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("indexisSpeed"),nil,self.layerNum+1)
				if(self.speedCallback)then
					self:speedCallback()
				end
			end
			self:close()
		else
			socketHelper:superUpgradeTech(recentSlot.tid,superServerHandler) --通知服务器
		end
	elseif(self.type==5)then
		local recentSlot=workShopSlotVoApi:getProductSolt()
		if(recentSlot==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),30)
			self:close()
			do return end
		end
		local pid=tonumber(recentSlot.itemId)
		local propName=propCfg["p"..pid].name
		local nums=tonumber(recentSlot.itemNum)
		local slotId=recentSlot.slotId
		local function serverSuperUpgrade(fn,data)
			if base:checkServerData(data)==true then  
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(propName)}),28)
				G_cancelPush("p".."_"..slotId,G_ItemProduceTag)
				eventDispatcher:dispatchEvent("workshopslot.speedup")
				if(self.speedCallback)then
					self:speedCallback()
				end
				self:close()
			end
		end
		socketHelper:speedUpProps(slotId,pid,nums,serverSuperUpgrade)
	else
	end
end

function vipQueueDialog:buyBuildingSlot()
	local costGems=tonumber(playerCfg.buildQueuePrice[playerVoApi:getOriginBuildingSlotNum() + 1])
	if playerVoApi:getGems()<costGems then
		GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),self.layerNum + 1,costGems)
		do return end
	end
	local function callback()
		local function serverBuyBuildingSolt(fn,data)
			if base:checkServerData(data)==true then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("promptBuyBuildingQueue",{playerVoApi:getBuildingSlotNum()}),nil,self.layerNum + 1)
				self:close()
			end
		end
		socketHelper:buyBuildingSlot(serverBuyBuildingSolt)
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("buyQueueContent",{costGems}),nil,self.layerNum + 1)
end

function vipQueueDialog:buyTmpBuildSlot()
	local costGems=tonumber(playerCfg.tempslotsgold)
	if playerVoApi:getGems()<costGems then
		GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),self.layerNum + 1,costGems)
		do return end
	end
	local function callback()
		local function serverBuyBuildingSolt(fn,data)
			if base:checkServerData(data)==true then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("promptBuyTmpBuildingQueue",{playerVoApi:getBuildingSlotNum()}),nil,self.layerNum + 1)
				self:close()
			end
		end
		socketHelper:buyTmpBuildSlot(serverBuyBuildingSolt)
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("vipQueue_desc23",{playerCfg.tempslotsgold,math.floor(playerCfg.tempslotstime/86400)}),nil,self.layerNum + 1)
end