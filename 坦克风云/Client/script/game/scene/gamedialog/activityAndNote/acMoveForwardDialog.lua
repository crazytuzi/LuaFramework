acMoveForwardDialog=commonDialog:new()

function acMoveForwardDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	return nc
end

function acMoveForwardDialog:initTableView()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
	self.panelLineBg:setPosition(ccp(20,20))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-105))

	self.acVo=acMoveForwardVoApi:getAcVo()
	self:initUp()
	self:initMiddle()
	self:initDown()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
end

function acMoveForwardDialog:initUp()
	local function nilFunc( ... )
	end
	local girlBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBgNew.png",CCRect(70, 35, 10, 10),nilFunc)
	girlBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,170))
	girlBg:setAnchorPoint(ccp(0,1))
	girlBg:setPosition(ccp(30,G_VisibleSizeHeight - 90))
	self.bgLayer:addChild(girlBg)

	local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2 + 70,G_VisibleSizeHeight - 95))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabel(activityVoApi:getActivityTimeStr(self.acVo.st, self.acVo.et),25)
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2 + 70,G_VisibleSizeHeight - 126))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
    G_updateActiveTime(self.acVo,self.timeLb)

	local descLb=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth - 200,100),getlocal("activity_yongwangzhiqian_desc"),25,kCCTextAlignmentLeft)
	descLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	descLb:setPosition(170,G_VisibleSizeHeight - 255)
	descLb:setMaxDisToBottomOrTop(20)
	self.bgLayer:addChild(descLb)

	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale(150/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(33,G_VisibleSizeHeight - 250))
	self.bgLayer:addChild(girlImg,2)
end

function acMoveForwardDialog:initMiddle()
	local function nilFunc( ... )
	end
	local isLongSize=G_isIphone5()
	local middleBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	if(isLongSize)then
		middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,250))
	else
		middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,200))
	end
	middleBg:setAnchorPoint(ccp(0.5,1))
	middleBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 270))
	self.bgLayer:addChild(middleBg)

	local titleBorder=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20,20,10,20),nilFunc)
	titleBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,50))
	titleBorder:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 295))
	self.bgLayer:addChild(titleBorder)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(100,0,114,47),nilFunc)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 70,45))
	titleBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 295))
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("activity_yongwangzhiqian_during"),25)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 295))
	self.bgLayer:addChild(titleLb)

	local goldIcon=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
	goldIcon:setScale(1.2)
	self.bgLayer:addChild(goldIcon)
	local goldLb1=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_condition1"),25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	goldLb1:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(goldLb1)
	local goldLb2=GetTTFLabel("-"..(self.acVo.activeRes*100).."%",40)
	goldLb2:setColor(G_ColorYellowPro)
	goldLb2:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(goldLb2)

	local expIcon=CCSprite:createWithSpriteFrameName("player_exp.png")
	expIcon:setScale(120/expIcon:getContentSize().width)
	self.bgLayer:addChild(expIcon)
	local expLb1=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_condition2"),25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	expLb1:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(expLb1)
	local expLb2=GetTTFLabel("+"..(self.acVo.activeExp*100).."%",40)
	expLb2:setColor(G_ColorYellowPro)
	expLb2:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(expLb2)
	if(isLongSize)then
		goldIcon:setPosition(ccp(100,G_VisibleSizeHeight - 410))
		goldLb1:setPosition(ccp(165,G_VisibleSizeHeight - 370))
		goldLb2:setPosition(ccp(225,G_VisibleSizeHeight -  430))
		expIcon:setPosition(ccp(390,G_VisibleSizeHeight - 410))
		expLb1:setPosition(455,G_VisibleSizeHeight - 370)
		expLb2:setPosition(510,G_VisibleSizeHeight - 430)
	else
		goldIcon:setPosition(ccp(100,G_VisibleSizeHeight - 390))
		goldLb1:setPosition(ccp(165,G_VisibleSizeHeight - 350))
		goldLb2:setPosition(ccp(225,G_VisibleSizeHeight -  410))
		expIcon:setPosition(ccp(390,G_VisibleSizeHeight - 390))
		expLb1:setPosition(455,G_VisibleSizeHeight - 350)
		expLb2:setPosition(510,G_VisibleSizeHeight - 410)
	end
end

function acMoveForwardDialog:initDown()
	local function nilFunc( ... )
	end
	local isLongSize=G_isIphone5()
	local posY
	if(isLongSize)then
		posY=G_VisibleSizeHeight - 530
	else
		posY=G_VisibleSizeHeight - 480
	end

	local titleBorder=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20,20,10,20),nilFunc)
	titleBorder:setTag(316)
	titleBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,50))
	titleBorder:setPosition(ccp(G_VisibleSizeWidth/2,posY - 25))
	self.bgLayer:addChild(titleBorder)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(100,0,114,47),nilFunc)
	titleBg:setTag(317)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 70,45))
	titleBg:setPosition(ccp(G_VisibleSizeWidth/2,posY - 25))
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("activity_yongwangzhiqian_task"),25)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setTag(318)
	titleLb:setPosition(ccp(G_VisibleSizeWidth/2,posY - 25))
	self.bgLayer:addChild(titleLb)
	local bgHeight=(posY - 50 - 30 - 10)/2
	local taskBg1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	taskBg1:setTag(319)
	taskBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,bgHeight))
	taskBg1:setAnchorPoint(ccp(0.5,1))
	taskBg1:setPosition(ccp(G_VisibleSizeWidth/2,posY - 50))
	self.bgLayer:addChild(taskBg1)
	local taskBg2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
	taskBg2:setTag(320)
	taskBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,bgHeight))
	taskBg2:setAnchorPoint(ccp(0.5,0))
	taskBg2:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(taskBg2)

	local index
	local sid
	for k,v in pairs(self.acVo.totalCfg) do
		sid=v.id
		if(self.acVo.progressTotal[sid]==nil or self.acVo.progressTotal[sid].f~=1)then
			index=k
			break
		end
	end
	if(index==nil)then
		index=#self.acVo.totalCfg
	end
	sid=self.acVo.totalCfg[index].id
	local realSid=10000 + tonumber(string.sub(sid,2))
	local cfg=checkPointVoApi:getCfgBySid(realSid)
	local chapterID=cfg.chapter
	local checkpointID=tonumber(cfg.index) + 1
	local titleLb1=GetTTFLabel(getlocal("activity_yongwangzhiqian_taskTitle1",{chapterID,checkpointID}),25)
	titleLb1:setPosition(ccp(230,bgHeight - 50))
	taskBg1:addChild(titleLb1)
	local function showReward()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local awardTab=FormatItem(self.acVo.totalCfg[index].reward,true)
		self:showRewardDialog(1,awardTab)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showReward,11,nil,nil)
	infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(taskBg1:getContentSize().width - 100,bgHeight - 50))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	taskBg1:addChild(infoBtn)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(taskBg1:getContentSize().width/2,bgHeight - 90))
	taskBg1:addChild(lineSp)
	local num=0
	if(self.acVo.progressTotal[sid] and self.acVo.progressTotal[sid].n)then
		num=tonumber(self.acVo.progressTotal[sid].n)
	end
	local descLb1=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_taskDesc1",{chapterID,checkpointID,num,self.acVo.totalCfg[index].num}),25,CCSizeMake(G_VisibleSizeWidth - 280,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb1:setPosition(ccp(230,(bgHeight - 90)/2))
	taskBg1:addChild(descLb1)
	if(self.acVo.progressTotal[sid] and self.acVo.progressTotal[sid].f==1)then
		local iconCheck=CCSprite:createWithSpriteFrameName("IconCheck.png")
		iconCheck:setPosition(ccp(490,(bgHeight - 90)/2))
		taskBg1:addChild(iconCheck)
	elseif(self.acVo.progressTotal[sid] and self.acVo.progressTotal[sid].n and self.acVo.progressTotal[sid].n>=self.acVo.totalCfg[index].num)then
		local function onGetReward()
			local function callback()
				self.acVo=acMoveForwardVoApi:getAcVo()
				self:refresh()
			end
			acMoveForwardVoApi:getReward(1,sid,callback)
		end
		local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetReward,nil,getlocal("daily_scene_get"),25)
		local rewardBtn=CCMenu:createWithItem(rewardItem)
		rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardBtn:setPosition(ccp(490,(bgHeight - 90)/2))
		taskBg1:addChild(rewardBtn)
	else
		local function onGotoStory()
			activityAndNoteDialog:closeAllDialog()
			local chapterCfg=checkPointVoApi:getCfgBySid(chapterID)
			storyScene:setShow(ccp(chapterCfg.x,chapterCfg.y))
		end
		local gotoItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGotoStory,nil,getlocal("activity_heartOfIron_goto"),25)
		local gotoBtn=CCMenu:createWithItem(gotoItem)
		gotoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		gotoBtn:setPosition(ccp(490,(bgHeight - 90)/2))
		taskBg1:addChild(gotoBtn)
	end

	local index
	local tid
	for k,v in pairs(self.acVo.dailyCfg) do
		tid=v.id
		if(self.acVo.progressDaily.f==nil or self.acVo.progressDaily.f[tid]==nil)then
			index=k
			break
		end
	end
	if(index==nil)then
		index=#self.acVo.dailyCfg
	end
	tid=self.acVo.dailyCfg[index].id
	local titleLb2=GetTTFLabel(getlocal("activity_yongwangzhiqian_taskTitle2"),25)
	titleLb2:setPosition(ccp(230,bgHeight - 50))
	taskBg2:addChild(titleLb2)
	local function showReward()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local awardTab=FormatItem(self.acVo.dailyCfg[index].reward,true)
		self:showRewardDialog(2,awardTab)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showReward,11,nil,nil)
	infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(taskBg2:getContentSize().width - 100,bgHeight - 50))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	taskBg2:addChild(infoBtn)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(taskBg2:getContentSize().width/2,bgHeight - 90))
	taskBg2:addChild(lineSp)
	local num=0
    local maxNum=self.acVo.dailyCfg[index].num or 0
	if(self.acVo.progressDaily.n)then
		num=tonumber(self.acVo.progressDaily.n)
        if num>maxNum then
            num=maxNum
        end
	end
	local descLb2=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_taskDesc2",{num,maxNum}),25,CCSizeMake(G_VisibleSizeWidth - 250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb2:setPosition(ccp(230,(bgHeight - 90)/2))
	taskBg2:addChild(descLb2)
	if(self.acVo.progressDaily.f and self.acVo.progressDaily.f[tid]==1)then
		local iconCheck=CCSprite:createWithSpriteFrameName("IconCheck.png")
		iconCheck:setPosition(ccp(490,(bgHeight - 90)/2))
		taskBg2:addChild(iconCheck)
	elseif(num>=maxNum)then
		local function onGetReward()
			local function callback()
				self.acVo=acMoveForwardVoApi:getAcVo()
				self:refresh()
			end
			acMoveForwardVoApi:getReward(2,tid,callback)
		end
		local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetReward,nil,getlocal("daily_scene_get"),25)
		local rewardBtn=CCMenu:createWithItem(rewardItem)
		rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardBtn:setPosition(ccp(490,(bgHeight - 90)/2))
		taskBg2:addChild(rewardBtn)
	else
		local function onGotoStory()
			activityAndNoteDialog:closeAllDialog()
			storyScene:setShow()
		end
		local gotoItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGotoStory,nil,getlocal("activity_heartOfIron_goto"),25)
		local gotoBtn=CCMenu:createWithItem(gotoItem)
		gotoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		gotoBtn:setPosition(ccp(490,(bgHeight - 90)/2))
		taskBg2:addChild(gotoBtn)
	end
end

function acMoveForwardDialog:tick()
	if(base.serverTime%86400==0)then
		self:refresh()
	end
	if self.timeLb and self.acVo then
        G_updateActiveTime(self.acVo,self.timeLb)
    end
end

function acMoveForwardDialog:showRewardDialog(type,itemTab)
	local function onHide()
		if(self.rewardDialog)then
			self.rewardDialog:removeFromParentAndCleanup(true)
			self.rewardDialog=nil
		end
	end
	local layerNum=self.layerNum + 1
	self.rewardDialog=CCLayer:create()
	self.bgLayer:addChild(self.rewardDialog,3)
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.rewardDialog:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	local size=CCSizeMake(550,150 + (SizeOfTable(itemTab) + 1)*84)
	dialogBg:setContentSize(size)
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.rewardDialog:addChild(dialogBg,1)
	local sizeLb=0
	sizeLb=sizeLb + (SizeOfTable(itemTab)+1)*84
	local width = 30
	local height=size.height - 65
	for k,v in pairs(itemTab) do
		if v and v.pic and v.name and v.num then
			height=height - 84
			local icon = CCSprite:createWithSpriteFrameName(v.pic)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(ccp(width,height))
			dialogBg:addChild(icon,1)
			if icon:getContentSize().width>80 then
				local iconW = icon:getContentSize().width
				local iconH = icon:getContentSize().height
				icon:setScaleX(80/iconW)
				icon:setScaleY(80/iconH)
			end
			local nameLable = GetTTFLabel(v.name.." x "..FormatNumber(v.num),22)
			nameLable:setAnchorPoint(ccp(0,0.5))
			nameLable:setPosition(ccp(width+100,height))
			dialogBg:addChild(nameLable,1)
		end
	end
	local titleLb=GetTTFLabel(getlocal("activity_yongwangzhiqian_rewardTitle"),25)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(ccp(30,size.height - 80))
	dialogBg:addChild(titleLb)
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(size.width/2,100))
	dialogBg:addChild(lineSp)
	local lb=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_rewardDesc"..type),25,CCSizeMake(size.width - 30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	lb:setColor(G_ColorRed)
	lb:setPosition(size.width/2,60)
	dialogBg:addChild(lb)
end

function acMoveForwardDialog:refresh()
	self.acVo=acMoveForwardVoApi:getAcVo()
	local titleBorder=tolua.cast(self.bgLayer:getChildByTag(316),"CCScale9Sprite")
	if(titleBorder)then
		titleBorder:removeFromParentAndCleanup(true)
	end
	local titleBg=tolua.cast(self.bgLayer:getChildByTag(317),"CCScale9Sprite")
	if(titleBg)then
		titleBg:removeFromParentAndCleanup(true)
	end
	local titleLb1=tolua.cast(self.bgLayer:getChildByTag(318),"CCLabelTTF")
	if(titleLb1)then
		titleLb1:removeFromParentAndCleanup(true)
	end
	local taskBg1=tolua.cast(self.bgLayer:getChildByTag(319),"CCScale9Sprite")
	if(taskBg1)then
		taskBg1:removeFromParentAndCleanup(true)
	end
	local taskBg2=tolua.cast(self.bgLayer:getChildByTag(320),"CCScale9Sprite")
	if(taskBg2)then
		taskBg2:removeFromParentAndCleanup(true)
	end
	self:initDown()
end

function acMoveForwardDialog:dispose()
    self.timeLb=nil
	if(self.rewardDialog)then
		self.rewardDialog:removeFromParentAndCleanup(true)
		self.rewardDialog=nil
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar.pvr.ccz")
end