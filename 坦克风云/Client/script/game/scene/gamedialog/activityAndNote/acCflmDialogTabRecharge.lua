--2018春节充值活动春福临门, 充值奖励页签
--author: Liang Qi
acCflmDialogTabRecharge={}

function acCflmDialogTabRecharge:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acCflmDialogTabRecharge:init(acVo,layerNum)
	self.acVo=acVo
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initBackground()
	self:initReward()
	return self.bgLayer
end

function acCflmDialogTabRecharge:initBackground()
	local backgoundSp=CCSprite:createWithSpriteFrameName("lineWhite.png")
	backgoundSp:setScaleX((G_VisibleSizeWidth - 30)/backgoundSp:getContentSize().width)
	backgoundSp:setScaleY((G_VisibleSizeHeight - 175)/backgoundSp:getContentSize().height)
	backgoundSp:setColor(ccc3(32,28,18))
	backgoundSp:setAnchorPoint(ccp(0,0))
	backgoundSp:setPosition(15,15)
	self.bgLayer:addChild(backgoundSp)
	local bgSp=CCSprite:createWithSpriteFrameName("goldAndTankBg_2.jpg")
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(bgSp)
	local finalReward=acCflmVoApi:getCfg().exhibitReward
	if(finalReward)then
		local reward=FormatItem(finalReward)
		if(reward)then
			reward=reward[1]
			local function showNewReward()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
				return false
			end
			local icon=G_getItemIcon(reward,100,true,self.layerNum,showNewReward)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(80,G_VisibleSizeHeight - 270)
			self.bgLayer:addChild(icon,1)
			local numLb=GetTTFLabel("×"..reward.num,25)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width - 5,5)
			icon:addChild(numLb)
			G_addRectFlicker2(icon,1.2,1.2,2,"r")
		end
	end
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
	self.bgLayer:addChild(scrollTv)
	self.timeLb1=timeLb1
	self.timeLb2=timeLb2

	local posterLb=GetTTFLabelWrap(getlocal("activity_cflm_poster"),23,CCSizeMake(390,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	posterLb:setAnchorPoint(ccp(0.5,1))
	posterLb:setPosition(G_VisibleSizeWidth/2 + 30,G_VisibleSizeHeight - 225)
	self.bgLayer:addChild(posterLb,1)
	local posterBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(40,0,40,36),function ( ... )end)
	posterBg:setContentSize(CCSizeMake(440,posterLb:getContentSize().height + 20))
	posterBg:setAnchorPoint(ccp(0.5,1))
	posterBg:setPosition(G_VisibleSizeWidth/2 + 30,G_VisibleSizeHeight - 220)
	self.bgLayer:addChild(posterBg)
	local line1=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
	line1:setScaleX((posterBg:getContentSize().width + 100)/line1:getContentSize().width)
	line1:setPosition(G_VisibleSizeWidth/2 + 30,posterBg:getPositionY())
	self.bgLayer:addChild(line1)
	local line2=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
	line2:setScaleX((posterBg:getContentSize().width + 100)/line2:getContentSize().width)
	line2:setPosition(G_VisibleSizeWidth/2 + 30,posterBg:getPositionY() - posterBg:getContentSize().height)
	self.bgLayer:addChild(line2)

	local function touchTip()
		local tabStr={getlocal("activity_cflm_info11"),getlocal("activity_cflm_info12",{acCflmVoApi:getCfg().rechargDay}),getlocal("activity_cflm_info13")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 195),{},nil,nil,28,touchTip,true)
	local function onRecharge()
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(3)
	end
	self.rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onRecharge,nil,getlocal("recharge"),28,100)
	self.rechargeItem:setScale(0.8)
	if(self.status~=1)then
		self.rechargeItem:setEnabled(false)
	end
	local rechargeBtn=CCMenu:createWithItem(self.rechargeItem)
	rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	local adaH = 0
	if G_getCurChoseLanguage() == "de" then
		adaH = 25
	end
	rechargeBtn:setPosition(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 335+adaH)
	self.bgLayer:addChild(rechargeBtn)
	self.rechargeLb=GetTTFLabel(getlocal("activity_TitaniumOfharvest_today_cost",{acCflmVoApi:getRechargeNumByDay(acCflmVoApi:getCurrentDay())}),23)
	if(self.status~=1)then
		self.rechargeLb:setVisible(false)
	end
	self.rechargeLb:setAnchorPoint(ccp(0,0.5))
	local adaH = 0
	if G_getCurChoseLanguage() == "de" then
		adaH = 11
	end
	self.rechargeLb:setPosition(30,G_VisibleSizeHeight - 345 - adaH)
	self.bgLayer:addChild(self.rechargeLb)
end

function acCflmDialogTabRecharge:initReward()
	local rewardCfg
	if(acCflmVoApi:getCfg().rechargereward)then
		rewardCfg=acCflmVoApi:getCfg().rechargereward
	else
		rewardCfg={}
	end
	local totalTabNum=(acCflmVoApi:getActiveEndTs() - G_getWeeTs(self.acVo.st))/86400 + 1
	local rewardFlag=nil
	local rewardTb={}
	for i=1,totalTabNum do
		if(i==totalTabNum)then
			if(acCflmVoApi:checkCanRechargeFinalReward())then
				rewardFlag=0
				table.insert(rewardTb,0)
			end
		else
			if(acCflmVoApi:checkCanRechargeRewardByDay(i))then
				rewardFlag=i
				table.insert(rewardTb,i)
			end
		end
	end
	if(rewardFlag~=nil)then
		self.curSelectTab=rewardFlag
	else
		if(self.status==1)then
			local curDay=acCflmVoApi:getCurrentDay()
			if(curDay<totalTabNum)then
				self.curSelectTab=curDay
			else
				self.curSelectTab=0
			end
		else
			self.curSelectTab=0
		end
	end	
	self.tabArr={}
	local function callbackTab(...)
		return self:eventHandlerTab(...)
	end
	local hd=LuaEventHandler:createHandler(callbackTab)
	local height=0
	self.tabTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(100,G_VisibleSizeHeight - 420),nil)
	self.tabTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tabTv:setPosition(ccp(15,25))
	self.tabTv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(self.tabTv)
	local curTabPos=G_VisibleSizeHeight - 420 - 75*self.curSelectTab
	if(curTabPos<25 + 64)then
		self.tabTv:recoverToRecordPoint(ccp(0,self.tabTv:getRecordPoint().y - (curTabPos - 25 - 64)))
	end

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("borderOrange.png",CCRect(4,4,3,3),function ( ... )end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 140,G_VisibleSizeHeight - 410))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(115,20)
	self.bgLayer:addChild(tvBg)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	local height=0
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 150,G_VisibleSizeHeight - 420),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(120,25))
	self.tv:setMaxDisToBottomOrTop(30)
	self.bgLayer:addChild(self.tv)
end

function acCflmDialogTabRecharge:getTabButton(index)
	local function nilFunc( ... )
	end
	local selectN=LuaCCScale9Sprite:createWithSpriteFrameName("acOrangeArrowBtn.png",CCRect(10,0,30,64),nilFunc)
	selectN:setContentSize(CCSizeMake(120,64))
	local selectS=LuaCCScale9Sprite:createWithSpriteFrameName("acOrangeArrowBtn_down.png",CCRect(10,0,30,64),nilFunc)
	selectS:setContentSize(CCSizeMake(120,64))
	local selectD=LuaCCScale9Sprite:createWithSpriteFrameName("acOrangeArrowBtn_down.png",CCRect(10,0,30,64),nilFunc)
	selectD:setContentSize(CCSizeMake(120,64))
	local menuItem3 = CCMenuItemSprite:create(selectN,selectS,selectD)
	menuItem3:setTag(100 + index)
	local str
	if(index==0)then
		str=getlocal("activity_refitPlanT99_bigReward")
	else
		str=getlocal("activity_continueRecharge_dayDes",{index})
	end
	local strSize = 25
	if G_getCurChoseLanguage() == "de" and index == 0 then
		strSize = 16
	end
	local titleLb=GetTTFLabelWrap(str,strSize,CCSizeMake(menuItem3:getContentSize().width - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setPosition(ccp(menuItem3:getContentSize().width/2 - 10,menuItem3:getContentSize().height/2))
	menuItem3:addChild(titleLb,6)
	titleLb:setFontName("Helvetica-bold")
	local function onSwitchTab(tag,object)
		if(tag)then
			local tabIndex=tag - 100
			self:switchTab(tabIndex)
		end
	end
	menuItem3:registerScriptTapHandler(onSwitchTab)
	local flagPoint=CCSprite:createWithSpriteFrameName("NumBg.png")
	flagPoint:setVisible(false)
	flagPoint:setTag(100)
	flagPoint:setScale(0.6)
	flagPoint:setPosition(10,menuItem3:getContentSize().height - 10)
	menuItem3:addChild(flagPoint)
    return menuItem3
end

function acCflmDialogTabRecharge:switchTab(index)
	if(self.tabArr and self.tabArr["t"..index])then
		self.tabArr["t"..self.curSelectTab]:setEnabled(true)
		self.curSelectTab=index
		self.tabArr["t"..self.curSelectTab]:setEnabled(false)
		if(self.tv and tolua.cast(self.tv,"CCTableView"))then
			self.tv:reloadData()
		end
	end
end

function acCflmDialogTabRecharge:eventHandlerTab(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if(self.acVo and self.acVo.st)then
			return (acCflmVoApi:getActiveEndTs() - G_getWeeTs(self.acVo.st))/86400 + 1
		else
			return 0
		end
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(120,75)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local tabItem=self:getTabButton(idx)
		if(idx==self.curSelectTab)then
			tabItem:setEnabled(false)
		end
		if(self.tabArr)then
			self.tabArr["t"..idx]=tabItem
		end
		local tabBtn=CCMenu:createWithItem(tabItem)
		tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		tabBtn:setPosition(60,37.5)
		cell:addChild(tabBtn)
		local rewardFlag=false
		if(idx==0)then
			if(acCflmVoApi:checkCanRechargeFinalReward())then
				rewardFlag=true
			end
		elseif(acCflmVoApi:checkCanRechargeRewardByDay(idx))then
			rewardFlag=true
		end
		if(rewardFlag)then
			local flagPoint=tolua.cast(tabItem:getChildByTag(100),"CCSprite")
			flagPoint:setVisible(true)
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

function acCflmDialogTabRecharge:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if(self.curSelectTab==0)then
			if(acCflmVoApi:getCfg().finalreward)then
				return #(acCflmVoApi:getCfg().finalreward)
			else
				return 0
			end
		else
			local rewardCfg
			if(acCflmVoApi:getCfg().rechargereward)then
				rewardCfg=acCflmVoApi:getCfg().rechargereward
			else
				rewardCfg={}
			end
			if(rewardCfg)then
				return #(rewardCfg)
			else
				return 0
			end
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth - 150,160)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellWidth,cellHeight=G_VisibleSizeWidth - 150,160
		local rewardCfg,rechargeNum
		if(self.curSelectTab==0)then
			rewardCfg=acCflmVoApi:getCfg().finalreward[idx + 1]
			rechargeNum=acCflmVoApi:getFinalRechargeNum()
		else
			rewardCfg=acCflmVoApi:getCfg().rechargereward[idx + 1]
			rechargeNum=acCflmVoApi:getRechargeNumByDay(self.curSelectTab)
		end
		local needNum=rewardCfg[1]
		if(rechargeNum>needNum)then
			rechargeNum=needNum
		end
		local titleLb
		if(self.curSelectTab==0)then
			if(rechargeNum==needNum)then
				titleLb=GetTTFLabelWrap(getlocal("activity_cflm_finalStr",{acCflmVoApi:getCfg().rechargDay,acCflmVoApi:getCfg().rechargDay,rechargeNum,needNum}),25,CCSizeMake(cellWidth - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			else
				titleLb=GetTTFLabelWrap(getlocal("activity_cflm_finalStr",{acCflmVoApi:getContinuoursRechargeDay(needNum),acCflmVoApi:getCfg().rechargDay,rechargeNum,needNum}),25,CCSizeMake(cellWidth - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			end
		else
			titleLb=GetTTFLabel(getlocal("activity_chunjiepansheng_gba_title",{rechargeNum,needNum}),25)
		end
		titleLb:setAnchorPoint(ccp(0,1))
		titleLb:setPosition(20,cellHeight - 2)
		cell:addChild(titleLb,1)
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_yellowTitleBg.png",CCRect(30,0,50,32),function ( ... )end)
		titleBg:setContentSize(CCSizeMake(cellWidth - 10,math.max(32,titleLb:getContentSize().height + 4)))
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(0,cellHeight)
		cell:addChild(titleBg)

		local rewardTb=FormatItem(rewardCfg[2],true,true)
		for k,v in pairs(rewardTb) do
			local function showNewReward()
				G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
				return false
			end
			local icon=G_getItemIcon(v,80,true,self.layerNum,showNewReward)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setAnchorPoint(ccp(0,0))
			icon:setPosition(20 + (k - 1)*100,20)
			cell:addChild(icon)
			local numLb=GetTTFLabel("×"..v.num,25)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width - 5,5)
			icon:addChild(numLb)
		end

		local status 			--0是未达成，1是可领取，2是已领取, 3是已过期
		if(self.curSelectTab==0)then
			if(rechargeNum<needNum)then
				status=0
			elseif(acCflmVoApi:checkFinalRewardGet(needNum)==true)then
				status=2
			else
				status=1
			end
		else
			if(acCflmVoApi:checkRechargeRewardGet(self.curSelectTab,needNum)==true)then
				status=2
			elseif(rechargeNum>=needNum)then
				status=1
			else
				local curDay=acCflmVoApi:getCurrentDay()
				if(self.curSelectTab<curDay)then
					status=3
				else
					status=0
				end
			end
		end
		if(status==0)then
			local lb=GetTTFLabel(getlocal("noReached"),25)
			lb:setPosition(cellWidth - 80,(cellHeight - 32)/2)
			cell:addChild(lb)
		elseif(status==1)then
			local function onGetReward(tag,object)
				if(tag and tag>100)then
					self:getRechargeReward(needNum)
				end
			end
			local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGetReward,101 + idx,getlocal("daily_scene_get"),28)
			rewardItem:setScale(0.8)
			local rewardMenu=CCMenu:createWithItem(rewardItem)
			rewardMenu:setPosition(cellWidth - 80,(cellHeight - 32)/2)
			cell:addChild(rewardMenu)
		elseif(status==2)then
			local lb=GetTTFLabel(getlocal("activity_hadReward"),25)
			lb:setColor(G_ColorGray)
			lb:setPosition(cellWidth - 80,(cellHeight - 32)/2)
			cell:addChild(lb)
		else
			local lb=GetTTFLabel(getlocal("expireDesc"),25)
			lb:setColor(G_ColorGray)
			lb:setPosition(cellWidth - 80,(cellHeight - 32)/2)
			cell:addChild(lb)
		end
		local lineSp=CCSprite:createWithSpriteFrameName("lineOrangeBlack.png") 
		lineSp:setScaleX((cellWidth - 20)/lineSp:getContentSize().width)
		lineSp:setPosition(cellWidth/2,5)
		cell:addChild(lineSp)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function acCflmDialogTabRecharge:tick()
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
			if(self.rechargeItem and tolua.cast(self.rechargeItem,"CCMenuItemSprite"))then
				self.rechargeItem:setEnabled(false)
			end
		end
		if(self.tv and tolua.cast(self.tv,"CCTableView"))then
			self.tv:reloadData()
		end
		if(self.rechargeLb and tolua.cast(self.rechargeLb,"CCLabelTTF"))then
			self.rechargeLb:setString(getlocal("activity_TitaniumOfharvest_today_cost",{acCflmVoApi:getRechargeNumByDay(acCflmVoApi:getCurrentDay())}))
			if(self.status==2)then
				self.rechargeLb:setVisible(false)
			end
		end
	end
end

function acCflmDialogTabRecharge:getRechargeReward(rechargeNum)
	local act
	if(self.curSelectTab==0)then
		act="final"
	end
	local function callback()
		if(self.tv and tolua.cast(self.tv,"CCTableView"))then
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		end
		if(self.tabArr)then
			for k,v in pairs(self.tabArr) do
				v=tolua.cast(v,"CCMenuItemSprite")
				if(v==nil)then
					break
				end
				local status
				local day=tonumber(RemoveFirstChar(k))
				if(day==0)then
					status=acCflmVoApi:checkCanRechargeFinalReward()
				else
					status=acCflmVoApi:checkCanRechargeRewardByDay(day)
				end
				local flagPoint=tolua.cast(v:getChildByTag(100),"CCSprite")
				flagPoint:setVisible(status)
			end
		end
	end
	acCflmVoApi:getRechargeReward(act,self.curSelectTab,rechargeNum,callback)
end

function acCflmDialogTabRecharge:dispose()
	self.tabArr=nil
	self.curSelectTab=nil
	self.tabTv=nil
	self.tv=nil
end