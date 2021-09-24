acThrivingDialog = commonDialog:new()

function acThrivingDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self

	self.dayBtnTb = {}
	self.dayBtnLockTb = {}
	self.daybtnLbTb = {}
	self.limitBtn = {}
	self.curTaskDays = 1
	self.curChooseTaskTb = nil
	self.taskTipItemTb = {}
	self.taskTipTb = {}
	self.taskLbTb = {}
	self.lockPicTb = {}
	self.dayTipPicTb = {}
	self.taskTipPicTb = {}
	self.tv = nil
	return nc
end	
function acThrivingDialog:dispose()
	self.bgLayer=nil
	self.dayBtnTb = nil
	self.dayBtnLockTb = nil
	self.daybtnLbTb = nil
	self.limitBtn = nil
	self.curTaskDays = nil
	self.taskTipItemTb = nil
	self.taskTipTb = nil
	self.taskLbTb = nil
	self.lockPicTb = nil
	self.dayTipPicTb = nil
	self.taskTipPicTb = nil
	self.tv = nil

	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
	spriteController:removePlist("public/activePicUseInNewGuid.plist")
	spriteController:removeTexture("public/activePicUseInNewGuid.png")
	spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    spriteController:removePlist("public/acThrivingImage.plist")
	spriteController:removeTexture("public/acThrivingImage.png")
	spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")
end

function acThrivingDialog:doUserHandler()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    spriteController:addPlist("public/acThrivingImage.plist")
    spriteController:addTexture("public/acThrivingImage.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local function callback()
		if(self and self.bgLayer and tolua.cast(self.bgLayer,"LuaCCScale9Sprite"))then
			self:initDialog()
		end
	end
	acThrivingVoApi:checkSetFull(callback)
end

function acThrivingDialog:initDialog()
	self.panelLineBg:setVisible(false)
	-- 时间和item
	local h = G_VisibleSizeHeight-100
	local timeFontSize = 20
	local strPosXSubWidht = G_getCurChoseLanguage() =="fr" and 120 or 0
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        timeFontSize = 24
        
    end
    local timeStr,timeStr2=acThrivingVoApi:getTimer()
    if timeStr then
		local acLabel = GetTTFLabel(getlocal("activityCountdown")..":"..timeStr,timeFontSize)
		acLabel:setAnchorPoint(ccp(0,1))
		acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)*0.42 - strPosXSubWidht, h))
		self.bgLayer:addChild(acLabel)
		acLabel:setColor(G_ColorYellowPro)
		self.acLabel = acLabel
		self.timePosy = h -15
		h = h-30

	else
		h = h - 15
		self.timePosy = h
	end

	
	local messageLabel=GetTTFLabel(getlocal("onlinePackage_next_title")..timeStr2,timeFontSize)
	messageLabel:setAnchorPoint(ccp(0,1))
	messageLabel:setColor(G_ColorYellowPro)
	messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)*0.42 , h))
	self.bgLayer:addChild(messageLabel)
	self.timeLb=messageLabel
	-- self:updateAcTime()

	local function touchInfo()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local tabStr={}
		for i=1,4 do
			table.insert(tabStr,getlocal("activity_zzrs_info"..i))
		end
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        if G_getCurChoseLanguage() =="ru" then
	        textSize = 20 
	    end
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end
	local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
	menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-30, h))
	self.bgLayer:addChild(menuDesc,2)

    local rewardCenterBtnBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    rewardCenterBtnBg:setOpacity(0)
    self.bgLayer:addChild(rewardCenterBtnBg,2)
    rewardCenterBtnBg:setPosition(ccp(120,G_VisibleSizeHeight-180))
    for i=1,2 do
      local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
      realLight:setScale(1.4)
      realLight:setPosition(getCenterPoint(rewardCenterBtnBg))
      rewardCenterBtnBg:addChild(realLight)  
      local roteSize = i ==1 and 360 or -360
      local rotate1=CCRotateBy:create(8, roteSize)
      local repeatForever = CCRepeatForever:create(rotate1)
      realLight:runAction(repeatForever)
    end

    self:setBar(rewardCenterBtnBg)

    local function willGetAward( )
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		local awardDia = acThrivingSmallDialog:new(self.layerNum+1)
		awardDia:init()
    end 
    local rewardCenterBtn=LuaCCSprite:createWithSpriteFrameName("unGiftBoxPic.png",willGetAward)
    rewardCenterBtn:setPosition(getCenterPoint(rewardCenterBtnBg))
    rewardCenterBtn:setIsSallow(true)
    -- rewardCenterBtn:setScale(1.4)
    rewardCenterBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardCenterBtnBg:addChild(rewardCenterBtn,1)

    local taskbarBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(60, 18, 1, 1),function ()end)
    taskbarBg:setPosition(ccp(rewardCenterBtn:getContentSize().width*0.5-5,10))
    rewardCenterBtn:addChild(taskbarBg,90)

    local taskFontSize = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        taskFontSize = 24
        
    end
    local taskBarLb = GetTTFLabel(getlocal("taskPro"),taskFontSize)
    taskbarBg:addChild(taskBarLb)
    taskbarBg:setContentSize(CCSizeMake(taskBarLb:getContentSize().width+16,taskBarLb:getContentSize().height+4))
    taskBarLb:setPosition(getCenterPoint(taskbarBg))

    local littStars = CCParticleSystemQuad:create("public/littStars.plist")
    littStars.positionType=kCCPositionTypeFree
    littStars:setPosition(getCenterPoint(rewardCenterBtn))
    rewardCenterBtn:addChild(littStars,99)

    local taskDays,curTaskDays = acThrivingVoApi:getTaskDays(),acThrivingVoApi:getCurDays()--取配置
    self.curTaskDays = curTaskDays
    local function taskDaysCall(tag)
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        print("tag------>>>>",tag)
        if tag > self.curTaskDays then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("unlockTip",{tag}),28)
        	do return end
        else
        	for k,v in pairs(self.daybtnLbTb) do
        		if k == tag then
        			v:setColor(G_ColorWhite)
        			self.limitBtn[k]:setVisible(false)
        			self.dayBtnLockTb[k]:setVisible(false)
        			self:refreshCurDayTaskTb(k)
        		else
        			v:setColor(G_ColorGreen)
        			self.limitBtn[k]:setVisible(true)
        			self.dayBtnLockTb[k]:setVisible(true)
        		end
        	end
        end
        
    end
    
    for i=1,taskDays do--rhombicBtn_up

    	local dayBtn = LuaCCSprite:createWithSpriteFrameName("rhombicBtn_down.png",function() end)
    	local usePosY = dayBtn:getContentSize().height
    	local addPosY = i%2 == 0 and -(usePosY*0.25) or usePosY*0.25
		dayBtn:setTouchPriority(-(self.layerNum-1)*20-3)
		dayBtn:setTag(i)
		dayBtn:setIsSallow(true)
		dayBtn:setPosition(ccp(G_VisibleSizeWidth*0.32+i*dayBtn:getContentSize().width*0.8,G_VisibleSizeHeight-240+addPosY))
		self.dayBtnTb[i] = dayBtn
		self.bgLayer:addChild(dayBtn,2)

		local limitItem=GetButtonItem("rhombicBtn_down.png","rhombicBtn_down.png","rhombicBtn_down.png",taskDaysCall,i)
        local limitBtn=CCMenu:createWithItem(limitItem);
        limitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
        self.limitBtn[i] = limitItem
        limitBtn:setPosition(getCenterPoint(dayBtn))
        dayBtn:addChild(limitBtn)

		local daybtnLb = GetTTFLabel(i,35)
		daybtnLb:setPosition(getCenterPoint(dayBtn))
		daybtnLb:setColor(G_ColorGreen)
		self.daybtnLbTb[i] = daybtnLb
		dayBtn:addChild(daybtnLb,1)
		

		local dayBtnLock = LuaCCSprite:createWithSpriteFrameName("rhombicBtn_up.png",taskDaysCall)
		dayBtnLock:setPosition(getCenterPoint(dayBtn))
		dayBtn:addChild(dayBtnLock)
		self.dayBtnLockTb[i] = dayBtnLock

		if i == self.curTaskDays then
			daybtnLb:setColor(G_ColorWhite)
			self.limitBtn[i]:setVisible(false)
			dayBtnLock:setVisible(false)
		elseif i > acThrivingVoApi:getCurDays() then
			self.daybtnLbTb[i]:setVisible(false)
		end

		local newsTip=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),function ()end)
        newsTip:setPosition(ccp(dayBtn:getContentSize().width-14,dayBtn:getContentSize().height+4))
        newsTip:setAnchorPoint(ccp(1,1))
        newsTip:setScale(0.6)
        dayBtn:addChild(newsTip,2)
        newsTip:setVisible(false)
        self.dayTipPicTb[i] = newsTip

		local lockPic = CCSprite:createWithSpriteFrameName("lockingIcon.png")
		lockPic:setPosition(getCenterPoint(dayBtnLock))
		self.lockPicTb[i]= lockPic
		dayBtnLock:addChild(lockPic)

		if i <= acThrivingVoApi:getCurDays() then
			self.lockPicTb[i]:setVisible(false)
		end
    end

    local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
    upM_Line:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,upM_Line:getContentSize().height))
    upM_Line:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,G_VisibleSizeHeight-320))
    upM_Line:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(upM_Line,2)

    self.upCurPosY = upM_Line:getPositionY()-5
    self.lastCurHeight = G_VisibleSizeHeight - self.upCurPosY
    self:refreshCurDayTaskTb(self.curTaskDays)

end


function acThrivingDialog:refreshCurDayTaskTb(curTaskChooseDays)
	if self.curChooseTaskTb then
		for k,v in pairs(self.taskTipTb) do
			v:removeFromParentAndCleanup(true)
		end
		for k,v in pairs(self.taskTipItemTb) do
			v:removeFromParentAndCleanup(true)
		end
		for k,v in pairs(self.taskLbTb) do
			v:removeFromParentAndCleanup(true)
		end
		self.taskLbTb = {}
		self.taskTipTb = {}
		self.taskTipItemTb = {}
		self.curChooseTaskTb = {}
	end
	self.curChooseTaskTb = acThrivingVoApi:getCurDayTaskTb(curTaskChooseDays)
	local function willChangeTask(hd,fn,idx)
		local tag = idx
		-- print("tag=====.>>>>>",tag)
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acThrivingVoApi:setCurChooseDayTask(curTaskChooseDays,tag)
        	for k,v in pairs(self.taskTipItemTb) do
        		if k == tag then
        			v:setVisible(false)
        			self.taskLbTb[k]:setColor(G_ColorWhite)
					local canAward,canAwardTb,canAwardDayTb = acThrivingVoApi:canReward()
					self.canAwardTb=canAwardTb
					self.canAwardDayTb=canAwardDayTb
    				self.tv:reloadData()
        		else
        			v:setVisible(true)
        			self.taskLbTb[k]:setColor(G_ColorGreen)
        		end
        	end
	end
	
	if self.taskTipPicTb then
		for k,v in pairs(self.taskTipPicTb) do
			v:removeFromParentAndCleanup(true)
		end
	end

	local strSize2,addPosX = 20,20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2,addPosX = 24,0
	end

    for i=1,SizeOfTable(self.curChooseTaskTb) do--LuaCCScale9Sprite:createWithSpriteFrameName("emblemViewAll.png",CCRect(10,0,20,64),onSelectQuality)
		
		local taskTip = LuaCCScale9Sprite:createWithSpriteFrameName("label_smal.png",CCRect(10,0,20,64),function() end)
		taskTip:setContentSize(CCSizeMake(130,taskTip:getContentSize().height))
		taskTip:setPosition(ccp(85,self.upCurPosY-40-80*(i-1)))--label_smal
		self.bgLayer:addChild(taskTip,2)
		self.taskTipTb[i] = taskTip

		local taskTipItem=LuaCCScale9Sprite:createWithSpriteFrameName("emblemViewAll.png",CCRect(10,0,20,64),willChangeTask)
		taskTipItem:setTag(i)
		taskTipItem:setContentSize(CCSizeMake(130,taskTipItem:getContentSize().height))
        taskTipItem:setTouchPriority(-(self.layerNum-1)*20-4);
        self.taskTipItemTb[i] = taskTipItem
        taskTipItem:setPosition(ccp(85,self.upCurPosY-40-80*(i-1)))
        self.bgLayer:addChild(taskTipItem,2)
        
        local taskLb = GetTTFLabel(getlocal("task")..i,strSize2)
        taskLb:setPosition(ccp(65+addPosX,self.upCurPosY-40-80*(i-1)))
        self.bgLayer:addChild(taskLb,2)
        taskLb:setColor(G_ColorGreen)
        self.taskLbTb[i] = taskLb

        local newsTip=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),function ()end)
        newsTip:setPosition(ccp(85+taskTip:getContentSize().width*0.38,self.upCurPosY-40-80*(i-1)+taskTip:getContentSize().height*0.46))
        newsTip:setScale(0.6)
        self.bgLayer:addChild(newsTip,3)
        newsTip:setVisible(false)
        self.taskTipPicTb[i] = newsTip
        if i == 1 then
        	self.taskTipItemTb[i]:setVisible(false)
        	self.taskLbTb[i]:setColor(G_ColorWhite)
        end
    end

    acThrivingVoApi:setCurChooseDayTask(curTaskChooseDays,1)
    local canAward,canAwardTb,canAwardDayTb = acThrivingVoApi:canReward()
    self.canAwardTb=canAwardTb
    self.canAwardDayTb=canAwardDayTb
    if self.tv then
    	self.tv:reloadData()
    else
    	local tvPosX,tvPosY,tvWidth,tvHeight,tvBg = self:setTvBg()
    	self.tvWidth,self.tvHeight = tvWidth,tvHeight
    	--按照顺序执行的
    	if G_getIphoneType() == G_iphoneX then
			self.tvHeight = self.tvHeight - 120
		end
    	local function callback(...)
			return self:eventHandler(...)
		end
		local hd= LuaEventHandler:createHandler(callback)
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)	
		-- self:tabClick(0,false)
		self.tv:setPosition(ccp(tvPosX,tvPosY))
		self.bgLayer:addChild(self.tv,3)
		self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
		self.tv:setMaxDisToBottomOrTop(80)
    end
end

function acThrivingDialog:initTableView( )
	
end
function acThrivingDialog:eventHandler(handler,fn,idx,cel)
	local strSize2,addPosX2 = 16,10
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2,addPosX2 = 24,0
	end
	if fn=="numberOfCellsInTableView" then
		return 4
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self.tvHeight/4)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		  local curTaskTb,chooseDay,chooseTask,taskNeedNumTb = acThrivingVoApi:getCurChooseDayTask()
		  local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),function() end)
		  cellBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight/SizeOfTable(curTaskTb)))
		  cellBg:setAnchorPoint(ccp(0,0))
		  cellBg:setPosition(ccp(0,0))
		  cell:addChild(cellBg)

		  local showCellAward = FormatItem(curTaskTb[idx+1],nil,true)
		  local scaleNum = G_isIphone5() and 95 or 75
		  local addWidth = G_isIphone5() and 110 or 85
		  local posY22 = G_isIphone5() and 75 or 50
		  for k,v in pairs(showCellAward) do
		  		local function callback( )
		            G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
		        end 
		        local icon,scale=G_getItemIcon(v,scaleNum,false,self.layerNum,callback,nil)
		        cellBg:addChild(icon)
		        icon:setTouchPriority(-(self.layerNum-1)*20-3)
		        icon:setPosition(ccp(60+addWidth*(k-1),posY22))

		        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
		        numBg:setAnchorPoint(ccp(1,0))
		        icon:addChild(numBg,1)
		        numBg:setOpacity(180)
		        numBg:setPosition(icon:getContentSize().width-5, 4)

		        local numLabel=GetTTFLabel("x"..v.num,21)
		        numLabel:setAnchorPoint(ccp(1,0))
		        numLabel:setPosition(icon:getContentSize().width-5, 5)
		        numLabel:setScale(1/scale)
		        icon:addChild(numLabel,1)
		        numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+2,numLabel:getContentSize().height+2))

		        -- print("self.curTaskDays=====>>>>",self.curTaskDays)

		        local colorName = acThrivingVoApi:getIconColor(chooseDay,chooseTask,idx+1,k)
		        -- print("colorName=====>>>>",colorName)
		        if colorName and colorName~="" then
		        	--flickerIdx: 黄色 y 3  蓝色 b 1  紫色 p 2 绿色 g 4
		        	local flickerIdxTb = {y=3,b=1,p=2,g=4}
		        	-- print("flickerIdxTb[colorName]=====>>>>",flickerIdxTb[colorName],colorName)
		        	local flickerPic = G_addRectFlicker2(icon,1.15,1.15,flickerIdxTb[colorName],colorName)
		        	flickerPic:setPosition(ccp(flickerPic:getPositionX(),flickerPic:getPositionY()-2))
		        end
		  end

		  -- acThrivingVoApi:getTaskClassTb(chooseDay,chooseTask)
		  local typeName = acThrivingVoApi:getTaskClassTb(chooseDay,chooseTask)
		  local useTypeName2 = typeName =="gba" and "gb" or typeName
		  local taskedNum = acThrivingVoApi:getHadTaskNumTb( )[useTypeName2] or 0
		  taskedNum = taskedNum > taskNeedNumTb[idx+1] and taskNeedNumTb[idx+1] or taskedNum
		  local useTypeName = typeName =="hy" and "hya" or typeName
		  if(acThrivingVoApi:checkTypeFull(typeName))then
		  	taskedNum=taskNeedNumTb[idx+1]
		  end
		  local cellTaskLb = GetTTFLabel(getlocal("activity_chunjiepansheng_"..useTypeName.."_title",{taskedNum,taskNeedNumTb[idx+1]}),strSize2)
		  cellTaskLb:setAnchorPoint(ccp(0,1))
		  cellTaskLb:setPosition(ccp(10,cellBg:getContentSize().height-8))
		  cellBg:addChild(cellTaskLb,2)

		  local cellTaskBg = LuaCCScale9Sprite:createWithSpriteFrameName("titlesBG.png",CCRect(35, 16, 1, 1),function() end)
		  cellTaskBg:setContentSize(CCSizeMake(cellTaskLb:getContentSize().width+35,cellTaskLb:getContentSize().height+8))
		  cellTaskBg:setAnchorPoint(ccp(0,1))
		  cellTaskBg:setPosition(ccp(8,cellBg:getContentSize().height-5))
		  cellBg:addChild(cellTaskBg,1)
		  if taskedNum and taskedNum >= taskNeedNumTb[idx+1] then -- (可领取)领取/未领取
		  	  local geted = acThrivingVoApi:isRec(useTypeName2,taskNeedNumTb[idx+1])
		  	  -- print("geted=====>>>>",geted,typeName,taskNeedNumTb[idx+1])
		  	  if geted then
		  	  	  local hadReward = GetTTFLabel(getlocal("activity_hadReward"),strSize2)
			  	  hadReward:setAnchorPoint(ccp(1,0.5))
			  	  hadReward:setPosition(ccp(cellBg:getContentSize().width-30,cellBg:getContentSize().height*0.5))
			  	  cellBg:addChild(hadReward)
			  	  hadReward:setColor(G_ColorGray)
		  	  else
		  	  	  	local function taskAwardCall()
				        -- acThrivingVoApi:socketByCall(typeName,chooseDay,taskNeedNumTb[idx+1],showCellAward)
				        local function getCellAwardCall(fn,data)
					        local ret,sData = base:checkServerData(data)
					        if ret==true then
					        	if sData and sData.data and sData.data.zzrs then
					        		acThrivingVoApi:updateData(sData.data.zzrs)
					        		if sData.data.zzrs.rd then
						        		acThrivingVoApi:setHasBeenRecAwardTb(sData.data.zzrs.rd)
										local canAward,canAwardTb,canAwardDayTb = acThrivingVoApi:canReward()
										self.canAwardTb=canAwardTb
										self.canAwardDayTb=canAwardDayTb
						        		self.tv:reloadData()
						        	end
					        	end
					            for k,v in pairs(showCellAward) do
									G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
								end
								G_showRewardTip(showCellAward,true)

					        end
					    end
					    typeName = typeName =="gba" and "gb" or typeName
					    socketHelper:acThrivingRequest("active.zzrs.reward",{action=typeName,day=chooseDay,num=taskNeedNumTb[idx+1]},getCellAwardCall)
				    end--
				    local taskItem = GetButtonItem("taskReward.png","taskReward_down.png","taskReward_down.png",taskAwardCall,nil,nil,nil,11)
				    -- taskItem:setScale(0.5)
				    local taskBtn=CCMenu:createWithItem(taskItem)
				    taskBtn:setPosition(ccp(cellBg:getContentSize().width-65,cellBg:getContentSize().height*0.5))
				    taskBtn:setTouchPriority(-(self.layerNum-1)*20-4)
				    cellBg:addChild(taskBtn,2)
		  	  end
		  else
		  	  local youCantLb = GetTTFLabel(getlocal("noReached"),strSize2)
		  	  youCantLb:setAnchorPoint(ccp(1,0.5))
		  	  youCantLb:setPosition(ccp(cellBg:getContentSize().width-30+addPosX2,cellBg:getContentSize().height*0.5))
		  	  cellBg:addChild(youCantLb)
		  end

			local curTaskPicTb = {}

			if self.dayTipPicTb then
				if SizeOfTable(self.canAwardDayTb) == 0 then
					for k,v in pairs(self.dayTipPicTb) do
						v:setVisible(false)
					end
				else
					for i=1,SizeOfTable(self.canAwardDayTb) do
						if self.canAwardDayTb[i] and self.dayTipPicTb[i] then
							self.dayTipPicTb[i]:setVisible(true)
						else
							self.dayTipPicTb[i]:setVisible(false)
						end
					end
				end
			end
			curTaskPicTb = self.canAwardTb[chooseDay]
			if self.taskTipPicTb then
				if SizeOfTable(curTaskPicTb) == 0 then
					for k,v in pairs(self.taskTipPicTb) do
						v:setVisible(false)
					end
				else
					for i=1,SizeOfTable(curTaskPicTb) do
						if curTaskPicTb[i] and self.taskTipPicTb[i]then
							self.taskTipPicTb[i]:setVisible(true)
						else
							self.taskTipPicTb[i]:setVisible(false)
						end
					end
				end
			end
			
		return cell
	end
end
function acThrivingDialog:tick()
    local vo=acThrivingVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if self.timeLb then
    	local timeStr,timeStr2=acThrivingVoApi:getTimer()
    	if self.acLabel and timeStr then
	    	self.acLabel:setString(getlocal("activityCountdown")..":"..timeStr)
	    	self.timeLb:setString(getlocal("onlinePackage_next_title")..timeStr2)
	    else
	    	if self.acLabel then
	    		self.acLabel:setVisible(false)
	    	end
	    	self.timeLb:setString(getlocal("onlinePackage_next_title")..timeStr2)
	    	self.timeLb:setPositionY(self.timePosy)
	    end
    	
    end
end

function acThrivingDialog:setTvBg( )
	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 170,self.upCurPosY - 10))
    tvBg:setPosition(ccp(155,10))
    self.bgLayer:addChild(tvBg,2)
    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(2,tvBg:getContentSize().height/2))
    tvBg:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(tvBg:getContentSize().width-2,tvBg:getContentSize().height/2))
    tvBg:addChild(pointSp2)


    local function goTiantang()
		if G_checkClickEnable()==false then
		    do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		local curTaskTb,chooseDay,chooseTask,taskNeedNumTb = acThrivingVoApi:getCurChooseDayTask()
		local typeName = acThrivingVoApi:getTaskClassTb(chooseDay,chooseTask)
		typeName = typeName =="gba" and "gb" or typeName--heroM
		typeName =typeName =="bc" and "cn" or typeName
		typeName =(typeName =="ua" or typeName=="ta") and "armor" or typeName
		typeName =(typeName =="uh" or typeName=="th") and "heroM" or typeName
		-- print("goto=====>>>>typeName=====>>>>>",typeName)

		G_goToDialog2(typeName,4,true)
	end
	local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),31)
	goItem:setScale(0.8)
	local goBtn=CCMenu:createWithItem(goItem);
	goBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	local adaH = 50
	if G_getIphoneType() == G_iphoneX then
		adaH = 80
	end
	goBtn:setPosition(ccp(tvBg:getContentSize().width*0.5,adaH))
	tvBg:addChild(goBtn)
	local isInLastDay = acThrivingVoApi:isInLastDay()
	if isInLastDay then
		goItem:setEnabled(false)
	end
    return tvBg:getPositionX()+4,tvBg:getPositionY()+84,tvBg:getContentSize().width-8,tvBg:getContentSize().height-88,tvBg
end

function acThrivingDialog:setBar(rewardCenterBtnBg)
	local posX,posY = rewardCenterBtnBg:getPositionX(),rewardCenterBtnBg:getPositionY() - rewardCenterBtnBg:getContentSize().height*0.5 - 10
	local percent = acThrivingVoApi:getCurCompletedTaskNums( ) 
	local percentLb = GetTTFLabel(percent.."/100",23)
	percentLb:setPosition(ccp(posX,posY))
	local timerSprite,pgSprite = AddProgramTimer(self.bgLayer,ccp(posX,posY),21,22,"","res_progressbg.png","resyellow_progress.png",23,0.6,0.8)
	timerSprite:setPercentage(percent)
	self.bgLayer:addChild(percentLb,99)
end