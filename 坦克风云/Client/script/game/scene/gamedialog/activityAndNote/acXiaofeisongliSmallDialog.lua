acXiaofeisongliSmallDialog=smallDialog:new()

function acXiaofeisongliSmallDialog:new(layerNum,id)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.id = id 
	self.layerNum=layerNum
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acXiaofeisongliSmallDialog:init(addSelectSp,activityFlag)
	self.dialogWidth=500
	self.dialogHeight=550
	self.isTouch=nil
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local desLb = GetTTFLabelWrap(getlocal("activity_xiaofeisongli_small_des"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setPosition(dialogBg:getContentSize().width/2, self.dialogHeight-60)

	local selectReward
	if activityFlag==nil then
		selectReward = acXiaofeisongliVoApi:getR1()
	elseif activityFlag==1 then
		selectReward = acChongzhisongliVoApi:getR1()
	elseif activityFlag==2 then
		selectReward = acDanrixiaofeiVoApi:getR1()
	elseif activityFlag==3 then
		selectReward = acDanrichongzhiVoApi:getR1()
	end
	 
	local reward = selectReward[self.id]

	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	local addW = 110
	local addH = 130

	-- 是否大奖
	local isreward
	if activityFlag==nil then
		isreward = acXiaofeisongliVoApi:getIsreward()
	elseif activityFlag==1 then
		isreward = acChongzhisongliVoApi:getIsreward()
	elseif activityFlag==2 then
		isreward = acDanrixiaofeiVoApi:getIsreward()
	elseif activityFlag==3 then
		isreward = acDanrichongzhiVoApi:getIsreward()
	end
	local isDajiang = false 
	if isreward and isreward[self.id] and isreward[self.id][1] and isreward[self.id][1]==1 then
		isDajiang=true
	end

	local rule
	if activityFlag==nil then
		rule = acXiaofeisongliVoApi:getRule()
	elseif activityFlag==1 then
		rule = acChongzhisongliVoApi:getRule()
	elseif activityFlag==2 then
		rule = acDanrixiaofeiVoApi:getRule()
	elseif activityFlag==3 then
		rule = acDanrichongzhiVoApi:getRule()
	end
	local vipList={}
	if rule.r1 and rule.r1[self.id] then
		vipList=rule.r1[self.id]
	end

	for i=1,#reward do
		local item = FormatItem(reward[i])

		local awidth = i%4
		if awidth==0 then
			awidth=4
		end

		local function callback()
			-- PlayEffect(audioCfg.mouseClick)
			if item[1].type == "h" then
				local heroId,orderId 
				if activityFlag==nil then
					heroId,orderId = acXiaofeisongliVoApi:takeHeroOrder(item[1].key)
				elseif activityFlag==1 then
					heroId,orderId = acChongzhisongliVoApi:takeHeroOrder(item[1].key)
				elseif activityFlag==2 then
					heroId,orderId = acDanrixiaofeiVoApi:takeHeroOrder(item[1].key)
				elseif activityFlag==3 then
					heroId,orderId = acDanrichongzhiVoApi:takeHeroOrder(item[1].key)
				end
				local td = acHuoxianmingjiangHeroInfoDialog:new(heroId,orderId)
				local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
				sceneGame:addChild(dialog,self.layerNum+1)
			end

			if self.checkSp==nil then
				self.checkSp = CCSprite:createWithSpriteFrameName("IconCheck.png")
				dialogBg:addChild(self.checkSp,5)
			end
			if i<5 then
				self.checkSp:setPosition(85+addW*(awidth-1)+30, self.dialogHeight-150-30)
			else
				self.checkSp:setPosition(85+addW*(awidth-1)+30, self.dialogHeight-150-160-30)
			end
			self.item = item[1]
			-- acXiaofeisongliVoApi:setChooseFlagList(self.id,i)
			if activityFlag==nil then
				acXiaofeisongliVoApi:setChooseFlagList(self.id,i)
			elseif activityFlag==1 then
				acChongzhisongliVoApi:setChooseFlagList(self.id,i)
			elseif activityFlag==2 then
				acDanrixiaofeiVoApi:setChooseFlagList(self.id,i)
			elseif activityFlag==3 then
				acDanrichongzhiVoApi:setChooseFlagList(self.id,i)
			end
			
		end

		local isShowInfo=true
		local infoCallback=callback
		if item[1].type == "h" then
			isShowInfo=false
			-- infoCallback=callback
		end

		-- vip限制
		local limitVip = vipList[i] or 0
		local playerVip = playerVoApi:getVipLevel() or 0
		if playerVip<limitVip then
			infoCallback=nil
			isShowInfo=false
		end


		local bgSp,scale = G_getItemIcon(item[1],100,isShowInfo,self.layerNum,infoCallback)
		bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
		-- local bgSp = GetBgIcon("Icon_BG.png",callback,nil,100,80)
		
		if i<5 then
			bgSp:setPosition(85+addW*(awidth-1), self.dialogHeight-150)
		else
			bgSp:setPosition(85+addW*(awidth-1), self.dialogHeight-150-160)
		end
		dialogBg:addChild(bgSp)

		local numLabel=GetTTFLabel("x"..item[1].num,21)
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(bgSp:getContentSize().width-5, 5)
		numLabel:setScale(1/scale)
		bgSp:addChild(numLabel,1)

		-- 是否是大奖
		if isDajiang then
			G_addRectFlicker(bgSp,(1/scale)*1.33,(1/scale)*1.3)
		end

		-- vip图标
		if limitVip>0 then
			local vipIcon=CCSprite:createWithSpriteFrameName("Vip".. limitVip ..".png")
			bgSp:addChild(vipIcon)
			vipIcon:setScale(1/scale)
			vipIcon:setPosition(bgSp:getContentSize().width/2, -vipIcon:getContentSize().height/scale/2)
		end

		-- 朦板
		if playerVip<limitVip then
			local function nilFunc()
			end
			local smForbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
			bgSp:addChild(smForbidBg)
			-- local smWidth = bgSp:getContentSize().width/scale
			smForbidBg:setContentSize(CCSizeMake(100,100))
			smForbidBg:setPosition(bgSp:getContentSize().width/2, bgSp:getContentSize().height/2)
			smForbidBg:setScale(1/scale)
		end


	end
	

	 --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if self.item then
			addSelectSp(self.item)
		end
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local function nilFunc()
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)


	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function acXiaofeisongliSmallDialog:dispose()
	self.id = nil
	self.checkSp = nil
	self.item = nil
end