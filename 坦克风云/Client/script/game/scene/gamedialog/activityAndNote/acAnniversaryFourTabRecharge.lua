--2017四周年周年庆典活动, 累计充值奖励页签
--author: Liang Qi
acAnniversaryFourTabRecharge={}

function acAnniversaryFourTabRecharge:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acAnniversaryFourTabRecharge:init(acVo,layerNum)
	self.acVo=acVo
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initBackground()
	self:initRecharge()
	return self.bgLayer
end

function acAnniversaryFourTabRecharge:initBackground()
	self.rechargeNum=acAnniversaryFourVoApi:getRechargeNum()
	self.rechargeCfg=acAnniversaryFourVoApi:getRechargeCfg()
	local maxRechargeNum=self.rechargeCfg[#self.rechargeCfg][1]
	if(self.rechargeNum>maxRechargeNum)then
		self.rechargeNum=maxRechargeNum
	end
	local function onLoadImage(fn,image)
		if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer"))then
			image:setScaleX((G_VisibleSizeWidth - 20)/image:getContentSize().width)
			image:setScaleY(1.5)
			image:setOpacity(130)
			image:setAnchorPoint(ccp(0.5,1))
			image:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 165)
			self.bgLayer:addChild(image)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/znqd2017/anniversary2017Bg2.png"),onLoadImage)
	local progressBg=CCSprite:createWithSpriteFrameName("acZnqd2017Bg3.png")
	progressBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 200)
	self.bgLayer:addChild(progressBg,1)
	local progress=CCSprite:createWithSpriteFrameName("acZnqd2017Pro.png")
	progress:setAnchorPoint(ccp(0,0.5))
	progress:setPosition(G_VisibleSizeWidth/2 - progressBg:getContentSize().width/2 + 3,G_VisibleSizeHeight - 200)
	local maxScale=(progressBg:getContentSize().width - 6)/progress:getContentSize().width
	progress:setScaleX(maxScale*self.rechargeNum/maxRechargeNum)
	self.bgLayer:addChild(progress,1)
	local progressLb=GetTTFLabel(self.rechargeNum.."/"..maxRechargeNum,25)
	progressLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 200)
	self.bgLayer:addChild(progressLb,1)
	local descLb=GetTTFLabelWrap(getlocal("activity_znqd2017_desc2"),23,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0.5,1))
	descLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 240)
	self.bgLayer:addChild(descLb,2)
	local descBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
	descBg:setScaleX((descLb:getContentSize().width + 6)/descBg:getContentSize().width)
	descBg:setScaleY(descLb:getContentSize().height/descBg:getContentSize().height)
	descBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 240 - descLb:getContentSize().height/2)
	self.bgLayer:addChild(descBg,1)
	for i=1,2 do
		local posY,addPosX
		if(i==1)then
			posY=descLb:getPositionY() + 3
			addPosX=40
		else
			posY=descLb:getPositionY() - descLb:getContentSize().height - 3
			addPosX=-50
		end
		local yellowLine = CCSprite:createWithSpriteFrameName("yellowLightPoint.png")
		yellowLine:setScaleX((descLb:getContentSize().width + 6)/yellowLine:getContentSize().width)
		yellowLine:setScaleY(1.2)
		yellowLine:setPosition(ccp(G_VisibleSizeWidth/2,posY))
		self.bgLayer:addChild(yellowLine,1)
		local yellowStar = CCSprite:createWithSpriteFrameName("yellowLightPointBg.png")
		yellowStar:setPosition(G_VisibleSizeWidth/2 + addPosX,yellowLine:getPositionY())
		yellowStar:setScaleY(0.9)
		self.bgLayer:addChild(yellowStar,1)
	end
	local function onLoadImage(fn,image)
		if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer"))then
			image:setOpacity(180)
			image:setAnchorPoint(ccp(0.5,1))
			image:setScaleY((G_VisibleSizeHeight - 425)/image:getContentSize().height)
			image:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 285)
			self.bgLayer:addChild(image)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/znqd2017/anniversary2017Bg1.png"),onLoadImage)
	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Sp3.png",CCRect(36,0,2,23),function ( ... )end)
	lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,25))
	lineSp:setPosition(G_VisibleSizeWidth/2,100)
	self.bgLayer:addChild(lineSp,1)
	local nextRechargeNum
	for i=1,#self.rechargeCfg do
		if(self.rechargeNum<self.rechargeCfg[i][1])then
			nextRechargeNum=self.rechargeCfg[i][1]
			break
		end
	end
	local nextStr
	if(nextRechargeNum==nil)then
		local canRewardFlag=false
		for k,v in pairs(self.rechargeCfg) do
			if(acAnniversaryFourVoApi:checkCanGetRechargeReward(k)==1)then
				canRewardFlag=true
				break
			end
		end
		if(canRewardFlag==true)then
			nextStr=getlocal("activity_znqd2017_allReward")
		else
			nextStr=getlocal("activity_znqd2017_allGot")
		end
	else
		nextStr=getlocal("activity_ljcz_tip",{nextRechargeNum - self.rechargeNum})
	end
	local rechargeLb=GetTTFLabelWrap(nextStr,23,CCSizeMake(G_VisibleSizeWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	rechargeLb:setPosition(G_VisibleSizeWidth/2,110)
	self.bgLayer:addChild(rechargeLb,1)
	local function onGotoRecharge()
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(3)
	end
	local rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onGotoRecharge,nil,getlocal("new_recharge_recharge_now"),26,100)
	rechargeItem:setScale(0.8)
	local rechargeBtn=CCMenu:createWithItem(rechargeItem)
	rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	rechargeBtn:setPosition(G_VisibleSizeWidth/2,50)
	self.bgLayer:addChild(rechargeBtn,1)
end

function acAnniversaryFourTabRecharge:initRecharge()
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 450),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,140)
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(80)
end

function acAnniversaryFourTabRecharge:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return  #self.rechargeCfg
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,150)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellSize=CCSizeMake(G_VisibleSizeWidth - 60,150)
		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Bg2.png",CCRect(40,15,10,10),function ( ... )end)
		cellBg:setContentSize(cellSize)
		cellBg:setPosition(cellSize.width/2,cellSize.height/2)
		cell:addChild(cellBg)
		local rewardIndex=#self.rechargeCfg - idx
		local rechargeCfg=self.rechargeCfg[rewardIndex]
		local titleLb=GetTTFLabel(getlocal("daily_award_tip_3",{rechargeCfg[1]}),25,true)
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(40,cellSize.height - 20)
		cell:addChild(titleLb,1)
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("acZnqd2017Title1.png",CCRect(0,0,20,33),function ( ... )end)
		titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width + 105,33))
		titleBg:setAnchorPoint(ccp(0,0.5))
		titleBg:setPosition(0,cellSize.height - 20)
		cell:addChild(titleBg)
		local rewardTb=FormatItem(rechargeCfg[2],true,true)
		local rewardNum=#rewardTb
		local colorTb=rechargeCfg[3]
		for i=1,rewardNum do
			local reward=rewardTb[i]
			local function showNewReward()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
				return false
			end
			local icon=G_getItemIcon(reward,80,true,self.layerNum,showNewReward)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(40 + 90*(i - 1),65)
			cell:addChild(icon)
			local numLb=GetTTFLabel("×"..reward.num,22)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width - 5,5)
			icon:addChild(numLb)
			if(colorTb and (colorTb[i] or colorTb[tostring(i)]))then
				local colorStr=colorTb[i] or colorTb[tostring(i)]
				local flickerIdxTb={y=3,b=1,p=2,g=4}
				local color=flickerIdxTb[colorStr]
				G_addRectFlicker2(icon,1.15,1.15,color,colorStr)
			end
		end
		local function onGetReward(tag,object)
			if(tag)then
				PlayEffect(audioCfg.mouseClick)
				self:getReward(tag)
			end
		end
		local status=acAnniversaryFourVoApi:checkCanGetRechargeReward(rewardIndex)
		if(status==0)then
			local lb=GetTTFLabel(getlocal("noReached"),25)
			lb:setAnchorPoint(ccp(1,0.5))
			lb:setPosition(cellSize.width - 30,cellSize.height/2)
			cell:addChild(lb)
		elseif(status==1)then
			local rewardItem=GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward_down.png",onGetReward,rewardIndex,nil,0)
			local rewardMenu=CCMenu:createWithItem(rewardItem)
			rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
			rewardMenu:setPosition(cellSize.width - 50,cellSize.height/2)
			cell:addChild(rewardMenu)
		else
			local lb=GetTTFLabel(getlocal("activity_hadReward"),25)
			lb:setColor(G_ColorGray)
			lb:setAnchorPoint(ccp(1,0.5))
			lb:setPosition(cellSize.width - 30,cellSize.height/2)
			cell:addChild(lb)
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

function acAnniversaryFourTabRecharge:getReward(rewardIndex)
	local function callback()
		if(self.tv and tolua.cast(self.tv,"CCTableView"))then
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		end
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
	end
	acAnniversaryFourVoApi:getReward(3,rewardIndex,callback)
end

function acAnniversaryFourTabRecharge:dispose()
	self.tv=nil
end