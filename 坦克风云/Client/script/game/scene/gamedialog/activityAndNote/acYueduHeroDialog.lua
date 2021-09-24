acYueduHeroDialog = commonDialog:new()

function acYueduHeroDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end	

function acYueduHeroDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))   
end	

function acYueduHeroDialog:initTableView()
	local function callback( ... )
	end

	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
	self:tabClick(0,false)
end

function acYueduHeroDialog:doUserHandler()

	self.reward1 = acYueduHeroVoApi:getRewardById(1)
	self.reward2 = acYueduHeroVoApi:getRewardById(2)

	-- 时间和item
	local h = G_VisibleSizeHeight-100
	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, h))
	self.bgLayer:addChild(acLabel)
	acLabel:setColor(G_ColorGreen)

	h = h-30
	local acVo = acYueduHeroVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, h))
	self.bgLayer:addChild(messageLabel)
	self.timeLb=messageLabel
	self:updateAcTime()

	local function touchInfo()
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_acYueduHero_tip2"), getlocal("activity_acYueduHero_tip1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
		sceneGame:addChild(dialog,self.layerNum+1)

	end
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-25, h))
	self.bgLayer:addChild(menuDesc,2)

	local height = (G_VisibleSizeHeight-210)/2
	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local backSize = CCSizeMake(600,height)
	local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
    backSprie1:setContentSize(backSize)
    backSprie1:setAnchorPoint(ccp(0.5,1))
    backSprie1:setPosition(ccp(self.bgLayer:getContentSize().width/2,h-40))
    self.bgLayer:addChild(backSprie1)

	local bgSp1=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp1:setPosition(ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height-5));
	bgSp1:setAnchorPoint(ccp(0.5,1))
	bgSp1:setScaleY(60/bgSp1:getContentSize().height)
	bgSp1:setScaleX(600/bgSp1:getContentSize().width)
	backSprie1:addChild(bgSp1)

	local str1=getlocal("activity_acYueduHero_subtitle1")
	local title1 = GetTTFLabel(str1,30)
	bgSp1:addChild(title1)
	title1:setScaleY(bgSp1:getContentSize().height/60)
	title1:setScaleX(bgSp1:getContentSize().width/600)
	title1:setPosition(bgSp1:getContentSize().width/2, bgSp1:getContentSize().height/2)


	local conditionStr1=getlocal("activity_acYueduHero_condition",{getlocal("activity_acYueduHero_condition1",{acYueduHeroVoApi:getCost(1)})})
	local conditionLb1 = GetTTFLabel(conditionStr1,25)
	conditionLb1:setAnchorPoint(ccp(0,0.5))
	backSprie1:addChild(conditionLb1)
	conditionLb1:setPosition(10, backSprie1:getContentSize().height-90)
	conditionLb1:setColor(G_ColorGreen)

	local lineSp1 = CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSp1:setAnchorPoint(ccp(0.5,0.5));
	lineSp1:setPosition(self.bgLayer:getContentSize().width/2,backSprie1:getContentSize().height-120)
	lineSp1:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp1:getContentSize().width)
	backSprie1:addChild(lineSp1)

	local lineSp3 = CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSp3:setAnchorPoint(ccp(0.5,0.5));
	lineSp3:setPosition(self.bgLayer:getContentSize().width/2,90)
	lineSp3:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp3:getContentSize().width)
	backSprie1:addChild(lineSp3)

	local alreadyStr1=getlocal("activity_acYueduHero_already1",{acYueduHeroVoApi:getRecord(1),acYueduHeroVoApi:getCost(1)})
	local alreadyLb1 = GetTTFLabelWrap(alreadyStr1,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	alreadyLb1:setAnchorPoint(ccp(0,0.5))
	backSprie1:addChild(alreadyLb1)
	alreadyLb1:setPosition(20,50)
	alreadyLb1:setColor(G_ColorGreen)
	self.alreadyLb1=alreadyLb1

	local numstr = acYueduHeroVoApi:getRecord(1) .. "/" .. acYueduHeroVoApi:getCost(1)
	local numLb1 = GetTTFLabel(numstr,25)
	alreadyLb1:addChild(numLb1)
	numLb1:setColor(G_ColorYellowPro)
	numLb1:setAnchorPoint(ccp(0,0.5))
	numLb1:setPosition(alreadyLb1:getContentSize().width, alreadyLb1:getContentSize().height/2)
	self.numLb1=numLb1

	local function touchItem(tag)
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		local flag=acYueduHeroVoApi:getFlagByTag(tag)
		if flag ==1 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_acYueduHero_noget"),30)
			return
		elseif flag==2 then
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_acYueduHero_alreadyGet"),30)
			return
		end
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret==true then
				acYueduHeroVoApi:setFlag(tag,1)
				-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
				
				local rewardM 
				if tag==1 then
					rewardM = self.reward1
				else
					rewardM = self.reward2
				end
				for k,v in pairs(rewardM) do
					if v.type=="h" then
					 	heroVoApi:addSoul(v.key,v.num)
				 	else
				 		 G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
					 
				end
				G_showRewardTip(rewardM,true)
				self:checkVisible()

			end

		end
		socketHelper:acYueduHeroLingjiang(tag,callback)

	end
	local lingquItem1=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchItem,1,getlocal("daily_scene_get"),25)
	lingquItem1:setAnchorPoint(ccp(0.5,0.5))
	lingquItem1:setScale(0.8)
	local lingquBtn1=CCMenu:createWithItem(lingquItem1);
	lingquBtn1:setTouchPriority(-(self.layerNum-1)*20-4);
	lingquBtn1:setPosition(ccp(530,50))
	backSprie1:addChild(lingquBtn1)
	self.lingquItem1=lingquItem1

	local aLingquLb1 = GetTTFLabel(getlocal("activity_hadReward"),25)
	backSprie1:addChild(aLingquLb1)
	aLingquLb1:setPosition(ccp(500,50))
	aLingquLb1:setColor(G_ColorGreen)
	self.aLingquLb1=aLingquLb1
	
	local num1 = SizeOfTable(self.reward1)
	for i=1,num1 do
		local item = self.reward1[i]
		local function callback()
			propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
		end
		local icon,scale=G_getItemIcon(item,100,false,self.layerNum,callback,nil)
		backSprie1:addChild(icon)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(100+(i-1)*190, backSprie1:getContentSize().height/2-15)

		local numLb = GetTTFLabel("x" .. item.num,24)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb)
		numLb:setPosition(icon:getContentSize().width-10, 5)
		numLb:setScale(1/scale)
	end


	-- 下面
    local backSprie2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
    backSprie2:setContentSize(backSize)
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
    self.bgLayer:addChild(backSprie2)

    local bgSp2=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp2:setPosition(ccp(backSprie2:getContentSize().width/2,backSprie2:getContentSize().height-5));
	bgSp2:setAnchorPoint(ccp(0.5,1))
	bgSp2:setScaleY(60/bgSp2:getContentSize().height)
	bgSp2:setScaleX(600/bgSp2:getContentSize().width)
	backSprie2:addChild(bgSp2)

	local str2=getlocal("activity_acYueduHero_subtitle2")
	local title2 = GetTTFLabel(str2,30)
	bgSp2:addChild(title2)
	title2:setScaleY(bgSp2:getContentSize().height/60)
	title2:setScaleX(bgSp2:getContentSize().width/600)
	title2:setPosition(bgSp2:getContentSize().width/2, bgSp2:getContentSize().height/2)

	local lbSize2 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end 
	local conditionStr2=getlocal("activity_acYueduHero_condition",{getlocal("activity_acYueduHero_condition2",{acYueduHeroVoApi:getCost(2)})})
	local conditionLb2 = GetTTFLabel(conditionStr2,lbSize2)
	conditionLb2:setAnchorPoint(ccp(0,0.5))
	backSprie2:addChild(conditionLb2)
	conditionLb2:setPosition(10, backSprie2:getContentSize().height-90)
	conditionLb2:setColor(G_ColorGreen)

	local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSp2:setAnchorPoint(ccp(0.5,0.5));
	lineSp2:setPosition(self.bgLayer:getContentSize().width/2,backSprie2:getContentSize().height-120)
	lineSp2:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp2:getContentSize().width)
	backSprie2:addChild(lineSp2)

	local lineSp4 = CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSp4:setAnchorPoint(ccp(0.5,0.5));
	lineSp4:setPosition(self.bgLayer:getContentSize().width/2,90)
	lineSp4:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp4:getContentSize().width)
	backSprie2:addChild(lineSp4)

	local alreadyStr2=getlocal("activity_acYueduHero_already2",{acYueduHeroVoApi:getRecord(2),acYueduHeroVoApi:getCost(2)})
	local alreadyLb2 = GetTTFLabel(alreadyStr2,25)
	alreadyLb2:setAnchorPoint(ccp(0,0.5))
	backSprie2:addChild(alreadyLb2)
	alreadyLb2:setPosition(20,50)
	alreadyLb2:setColor(G_ColorGreen)
	self.alreadyLb2=alreadyLb2

	local numstr2 = acYueduHeroVoApi:getRecord(2) .. "/" .. acYueduHeroVoApi:getCost(2)
	local numLb2 = GetTTFLabel(numstr2,25)
	alreadyLb2:addChild(numLb2)
	numLb2:setColor(G_ColorYellowPro)
	numLb2:setAnchorPoint(ccp(0,0.5))
	numLb2:setPosition(alreadyLb2:getContentSize().width, alreadyLb2:getContentSize().height/2)
	self.numLb2=numLb2

	local lingquItem2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchItem,2,getlocal("daily_scene_get"),25)
	lingquItem2:setAnchorPoint(ccp(0.5,0.5))
	lingquItem2:setScale(0.8)
	local lingquBtn2=CCMenu:createWithItem(lingquItem2);
	lingquBtn2:setTouchPriority(-(self.layerNum-1)*20-4);
	lingquBtn2:setPosition(ccp(530,50))
	backSprie2:addChild(lingquBtn2)
	self.lingquItem2=lingquItem2

	local aLingquLb2 = GetTTFLabel(getlocal("activity_hadReward"),25)
	backSprie2:addChild(aLingquLb2)
	aLingquLb2:setPosition(ccp(500,50))
	aLingquLb2:setColor(G_ColorGreen)
	self.aLingquLb2=aLingquLb2

	
	local num2 = SizeOfTable(self.reward2)
	for i=1,num2 do
		local item = self.reward2[i]
		local function callback()
			propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
		end
		local icon,scale=G_getItemIcon(item,100,false,self.layerNum,callback,nil)
		backSprie2:addChild(icon)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(100+(i-1)*200, backSprie2:getContentSize().height/2-15)

		local numLb = GetTTFLabel("x" .. item.num,24)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb)
		numLb:setPosition(icon:getContentSize().width-10, 5)
		numLb:setScale(1/scale)
	end

	-- if(G_isIphone5())then
		lineSp1:setPosition(self.bgLayer:getContentSize().width/2,backSprie1:getContentSize().height-120)
		lineSp2:setPosition(self.bgLayer:getContentSize().width/2,backSprie1:getContentSize().height-120)
	-- end

	local istoday = acYueduHeroVoApi:isToday()
	if istoday==false then
		self:refreshApi()
    	self:refreshDialog()
	else
		self:checkVisible()
	end

end

function acYueduHeroDialog:checkVisible()
	local flag1 = acYueduHeroVoApi:getFlagByTag(1)
	local flag2 = acYueduHeroVoApi:getFlagByTag(2)
	if flag1==1 then
		self.alreadyLb1:setVisible(true)
	else
		self.alreadyLb1:setVisible(false)
	end

	if flag1==3 then
		self.aLingquLb1:setVisible(true)
		self.lingquItem1:setVisible(false)
		self.lingquItem1:setEnabled(false)
	else
		self.aLingquLb1:setVisible(false)
		self.lingquItem1:setVisible(true)
		self.lingquItem1:setEnabled(true)
	end

	if flag2==1 then
		self.alreadyLb2:setVisible(true)
	else
		self.alreadyLb2:setVisible(false)
	end

	if flag2==3 then
		self.aLingquLb2:setVisible(true)
		self.lingquItem2:setVisible(false)
		self.lingquItem2:setEnabled(false)
	else
		self.aLingquLb2:setVisible(false)
		self.lingquItem2:setVisible(true)
		self.lingquItem2:setEnabled(true)
	end
end


function acYueduHeroDialog:refreshApi()
	acYueduHeroVoApi:setLastTime(base.serverTime)
	acYueduHeroVoApi:setRecord(1,0)
	acYueduHeroVoApi:setRecord(2,0)
	acYueduHeroVoApi:setFlag(1,0)
	acYueduHeroVoApi:setFlag(2,0)
end

function acYueduHeroDialog:refreshDialog()
	if self.numLb1 then
		local str = acYueduHeroVoApi:getRecord(1) .. "/" .. acYueduHeroVoApi:getCost(1)
		self.numLb1:setString(str)
	end
	if self.numLb2 then
		local str = acYueduHeroVoApi:getRecord(2) .. "/" .. acYueduHeroVoApi:getCost(2)
		self.numLb2:setString(str)
	end
	self:checkVisible()
end

function acYueduHeroDialog:updateAcTime()
    local acVo=acYueduHeroVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acYueduHeroDialog:tick()
    local vo=acYueduHeroVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    local istoday = acYueduHeroVoApi:isToday()
    if istoday then
    else
    	self:refreshApi()
    	self:refreshDialog()
    end
    self:updateAcTime()
end

function acYueduHeroDialog:dispose()
	self.alreadyLb1=nil
	self.alreadyLb2=nil
	self.aLingquLb2=nil
	self.aLingquLb1=nil
	self.lingquItem1=nil
	self.lingquItem2=nil
	self.numLb1=nil
	self.numLb2=nil
	self.timeLb=nil
end