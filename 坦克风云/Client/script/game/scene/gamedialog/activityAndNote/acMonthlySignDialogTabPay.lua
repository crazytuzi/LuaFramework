--月度签到
acMonthlySignDialogTabPay={}

function acMonthlySignDialogTabPay:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.tv=nil
	nc.bgLayer=nil
	nc.layerNum=nil
	nc.showFestival = nil -- 显示的节日气氛标题背景框
	nc.titleBg = nil
	nc.titleIcon = nil
	return nc
end

function acMonthlySignDialogTabPay:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.acVo=acMonthlySignVoApi:getAcVo()
	self:initTableView()
	self:updateTitleBg()
	if self.tv then
		local payCfg = acMonthlySignVoApi:getPayCfg()
		if payCfg then
			local maxLen = #payCfg
			local today=acMonthlySignVoApi:getCurrentDay()
			if today then
				local hang=-150*(maxLen - today) + (G_VisibleSizeHeight-305) - 150 --(maxLen - todayCfgIndex + 1)--maxLen - todayCfgIndex + 1 -- tv 自动跑到当天所在行
				if hang > 0 then
					hang = 0
				end
				local recordPoint = ccp(0,hang)
				self.tv:recoverToRecordPoint(recordPoint)
			end
		end
	end
	local function forbidClick()
	end
	local capInSet1 = CCRect(20, 20, 10, 10);
	local topForbidHeight = self.bgLayer:getContentSize().height*0.2
	self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet1,forbidClick)
	self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
	self.topforbidSp:setAnchorPoint(ccp(0.5,1))
	self.topforbidSp:setContentSize(CCSize(self.bgLayer:getContentSize().width,270))
	self.topforbidSp:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height)
	self.bgLayer:addChild(self.topforbidSp)
	self.topforbidSp:setVisible(false)
	return self.bgLayer
end

function acMonthlySignDialogTabPay:initTableView()
	if G_isArab() or G_curPlatName()=="0" then
		self.titleBg=CCSprite:create("arImage/monthlysignPayTitleBg_ar.jpg")
	else
		self.titleBg = CCSprite:createWithSpriteFrameName("monthlysignPayTitleBg.jpg")
	end
	self.titleBg:setAnchorPoint(ccp(0.5,1))
	self.titleBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160)
	self.bgLayer:addChild(self.titleBg,1)
	local paySubTitle=GetTTFLabelWrap(getlocal("activity_monthlysign_desc_pay"),28,CCSizeMake(self.titleBg:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	paySubTitle:setAnchorPoint(ccp(0,0.5))
	paySubTitle:setPosition(ccp(10,self.titleBg:getContentSize().height/2))
	self.titleBg:addChild(paySubTitle,3)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 305),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,28))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)
end

function acMonthlySignDialogTabPay:update()
	if self and self.tv then
		self.acVo=acMonthlySignVoApi:getAcVo()
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
		self:updateTitleBg()
	end
end

function acMonthlySignDialogTabPay:updateTitleBg()
end

function acMonthlySignDialogTabPay:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local payCfg = acMonthlySignVoApi:getPayCfg()
		if payCfg then
			return #payCfg
		else
			return 0
		end
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth-40,150)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		-- 此时是某月，某天
		local currentMonth,currentDay=acMonthlySignVoApi:getCurrentDate()
		--此条活动配置
		local day = idx + 1
		local cfg=acMonthlySignVoApi:getPayCfgByIndex(day)
		if(cfg==nil)then
			return cell
		end
		local dayIconImage = "dayIconBlue.png"
		local flag=cfg.f or 0
		if flag>0 then
			dayIconImage = "dayIconGreen.png"
		end
		local bgImage = "7daysLight.png"
		local sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function ( ... )end)
		sprieBg:setContentSize(CCSizeMake(600,140))
		sprieBg:setPosition(ccp((G_VisibleSizeWidth - 40)/2,75))
		cell:addChild(sprieBg)
		local centerY=5 + sprieBg:getContentSize().height/2
		local dayIcon = CCSprite:createWithSpriteFrameName(dayIconImage)
		dayIcon:setPosition(10 + dayIcon:getContentSize().width/2,5 + sprieBg:getContentSize().height - dayIcon:getContentSize().height/2)
		cell:addChild(dayIcon)
		local onDayIconY = dayIcon:getContentSize().height-50
		local dayIconW = dayIcon:getContentSize().width	
		local firstDayTs=G_getWeeTs(self.acVo.st)
		local dayTs=firstDayTs + 86400*idx
		local dateStr=G_getDateStr(dayTs,false,true)
		local dateLb = GetTTFLabelWrap(dateStr,24,CCSizeMake(dayIconW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--GetTTFLabel(getlocal("activity_equipSearch_data",{month,day}),20)
		dateLb:setPosition(dayIconW/2,onDayIconY)
		dayIcon:addChild(dateLb)
		local iconStartX = 20+dayIcon:getContentSize().width
		local cfgReward = cfg.r
		if cfgReward then
			local reward = FormatItem(cfgReward)
			local iconSize = 80
			for k,v in pairs(reward) do
				local icon,scale = G_getItemIcon(v,iconSize,true,self.layerNum,nil,self.tv)
				icon:setIsSallow(false)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				icon:setPosition(iconStartX+iconSize/2+(k-1)*(iconSize+5),centerY)
				cell:addChild(icon)
				local numLb = GetTTFLabel("x"..v.num,30)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(icon:getPositionX()+iconSize/2,icon:getPositionY()-iconSize/2)
				cell:addChild(numLb)
				numLb:setColor(G_ColorYellow)
			end
		end
		local stateX = self.bgLayer:getContentSize().width-150
		--显示状态
		local payState = acMonthlySignVoApi:getPayRewardState(day)
		if payState == acMonthlySignVoApi.payStateEnd then -- 已结束
			local endLb=GetTTFLabelWrap(getlocal("activity_heartOfIron_over"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			endLb:setPosition(stateX,centerY)
			cell:addChild(endLb)
		elseif payState == acMonthlySignVoApi.payStateHadReward then--已领取显示对号
			local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
			rightIcon:setAnchorPoint(ccp(0.5,0.5))
			rightIcon:setPosition(stateX,centerY)
			cell:addChild(rightIcon)
		elseif payState == acMonthlySignVoApi.payStateHadRecharge then--已充值，未领取显示领取按钮
			local function rewardHandler(tag,object)
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					self:getPayReward(tag)
				end
			end
			local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,day,getlocal("daily_scene_get"),25)
			local rewardBtn=CCMenu:createWithItem(rewardItem)
			rewardBtn:setPosition(stateX,centerY)
			rewardBtn:setTouchPriority(-(self.layerNum-1)*20-1)
			cell:addChild(rewardBtn)
		else
			local function rechargeHandler(tag,object)
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					activityAndNoteDialog:closeAllDialog()
					vipVoApi:showRechargeDialog(3)
				end
			end
			local rechargeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",rechargeHandler,idx+1,getlocal("recharge"),25)
			local rechargeBtn=CCMenu:createWithItem(rechargeItem)
			rechargeBtn:setPosition(stateX,centerY)
			rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-1)
			cell:addChild(rechargeBtn)
			if payState == acMonthlySignVoApi.payStateNotRecharge then--未充值显示充值按钮
				rechargeItem:setEnabled(true)
			elseif payState == acMonthlySignVoApi.payStateNotOpen then -- 时间未到，未开启
				rechargeItem:setEnabled(false)
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

function acMonthlySignDialogTabPay:getPayReward(day)
	print("acMonthlySignDialogTabPay:getPayReward: ",day)
	local payState = acMonthlySignVoApi:getPayRewardState(day)
	if payState == acMonthlySignVoApi.payStateHadRecharge then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				local rewardTb
				if sData.data and sData.data.reward then
					rewardTb=FormatItem(sData.data.reward)
				else
					local cfg=acMonthlySignVoApi:getPayCfgByIndex(day)
					if cfg and cfg.r then
						rewardTb = FormatItem(cfg.r)
					end
				end
				if rewardTb then
					for k,v in pairs(rewardTb) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
					end
					G_showRewardTip(rewardTb,true)
				end
				acMonthlySignVoApi:afterGetReward()
			end
		end
		print("领取充值签到奖励：",cfgIndex)
		socketHelper:monthlysignGetReward(1,day,onRequestEnd)
	end
end

function acMonthlySignDialogTabPay:dispose()
	if G_isArab() then 
		CCTextureCache:sharedTextureCache():removeTextureForKey("arImage/monthlysignPayTitleBg_ar.jpg")
	end
	self.tv=nil
end
