acYwzqDialog=commonDialog:new()

function acYwzqDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.layerNum=layerNum
	nc.upPosY=G_VisibleSizeHeight - 80
	nc.upHeight=220
	nc.middlePosySubHeight=270
	nc.url=G_downloadUrl("active/".."acDuanWuBg_v2.jpg") or nil
	
	return nc
end

function acYwzqDialog:initTableView()
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")

	self.panelLineBg:setVisible(false)

	self.acVo=acYwzqVoApi:getAcVo()
	self:initUrl()
	self:initUp()
	self:initMiddle()
	self:initDown()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
end
function acYwzqDialog:initUrl( )
	local function onLoadIcon(fn,icon)
        icon:setAnchorPoint(ccp(0.5,1))
        icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
        self.bgLayer:addChild(icon)
        icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
        icon:setScaleY(self.upHeight/icon:getContentSize().height)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)

    spriteController:addPlist("public/acYwzq2018Image.plist")--acMjzx2Image
    spriteController:addTexture("public/acYwzq2018Image.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end
function acYwzqDialog:initUp()
	local function nilFunc( ... )
	end
	local girlBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	girlBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.upHeight))
	girlBg:setAnchorPoint(ccp(0.5,1))
	girlBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upPosY))
	girlBg:setOpacity(0)
	self.bgLayer:addChild(girlBg,1)

	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setOpacity(255*0.6)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upHeight)
    girlBg:addChild(timeBg)

	local timeStrSize = G_isAsia() and 24 or 21
	local acLabel     = GetTTFLabel(acYwzqVoApi:getTimer(),22,"Helvetica-bold")
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5, self.upHeight - 25))
    girlBg:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro2)
    self.timeLb=acLabel

	local descLb=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth - 200,100),getlocal("activity_ywzq_desc"),20,kCCTextAlignmentLeft)
	descLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	descLb:setPosition(G_VisibleSizeWidth * 0.28,self.upHeight * 0.1)
	descLb:setMaxDisToBottomOrTop(20)
	girlBg:addChild(descLb,1)

end

function acYwzqDialog:initMiddle()
	local posy1 = self.upPosY - self.upHeight

	local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,posy1 - titleBg:getContentSize().height * 0.5))
    self.bgLayer:addChild(titleBg)

    local titleLb=GetTTFLabel(getlocal("activity_yongwangzhiqian_during"),25,"Helvetica-bold")
	titleLb:setColor(G_ColorYellowPro2)
	titleLb:setPosition(getCenterPoint(titleBg))
	titleBg:addChild(titleLb)

	local posy2 = posy1 - titleBg:getContentSize().height - 2

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	middleBg:setAnchorPoint(ccp(0.5,1))
	middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,200))
	middleBg:setPosition(G_VisibleSizeWidth * 0.5,posy2)
	self.bgLayer:addChild(middleBg,1)

	self.downPosy = posy2 - middleBg:getContentSize().height - 5

	local middleWidth,middlePosy = middleBg:getContentSize().width,middleBg:getContentSize().height * 0.5
	local spIconTb = {"resourse_normal_gold.png","player_exp.png","battleNoDie.png"}
	local spLbTb = {"activity_yongwangzhiqian_condition1","activity_yongwangzhiqian_condition2","activity_ywzq_condition3"}
	local spLb2Tb = {"-"..(self.acVo.activeRes*100).."%","+"..(self.acVo.activeExp*100).."%",self.acVo.activeDie..getlocal("warDamageStr")}

	for i=1,3 do
		local spIcon=CCSprite:createWithSpriteFrameName(spIconTb[i])
		spIcon:setPosition(middleWidth * ((i-1)*0.31+0.19),middlePosy)
		middleBg:addChild(spIcon)


		local spStr = GetTTFLabelWrap(getlocal(spLbTb[i]),G_isAsia() and 23 or 18,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
		spStr:setAnchorPoint(ccp(0.5,0))
		spStr:setPosition(spIcon:getContentSize().width * 0.5,spIcon:getContentSize().height + 5)
		spIcon:addChild(spStr)

		local spStr2 = GetTTFLabel(spLb2Tb[i],G_isAsia() and 22 or 20,"Helvetica-bold")
		spStr2:setAnchorPoint(ccp(0.5,1))
		spStr2:setColor(G_ColorYellowPro)
		spStr2:setPosition(spIcon:getContentSize().width * 0.5, -7)
		spIcon:addChild(spStr2)
	end

end

function acYwzqDialog:initDown()
	local function nilFunc( ... )
	end
	local isLongSize=G_isIphone5()
	local posY
	if(isLongSize)then
		posY=G_VisibleSizeHeight - 530
	else
		posY=G_VisibleSizeHeight - 480
	end

	local titleBorder=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBorder:setTag(316)
	titleBorder:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.downPosy - 25))
	self.bgLayer:addChild(titleBorder)

	local titleLb=GetTTFLabel(getlocal("activity_yongwangzhiqian_task"),25,"Helvetica-bold")
	titleLb:setColor(G_ColorYellowPro2)
	titleLb:setTag(318)
	titleLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.downPosy - 25))
	self.bgLayer:addChild(titleLb)
	local bgHeight=(self.downPosy - 50 - 30 - 10) * 0.5
	local taskBg1=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	taskBg1:setTag(319)
	taskBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,bgHeight))
	taskBg1:setAnchorPoint(ccp(0.5,1))
	taskBg1:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.downPosy - 50))
	self.bgLayer:addChild(taskBg1)
	local taskBg2=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	taskBg2:setTag(320)
	taskBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,bgHeight))
	taskBg2:setAnchorPoint(ccp(0.5,0))
	taskBg2:setPosition(ccp(G_VisibleSizeWidth * 0.5,30))
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
	local titleLb1=GetTTFLabel(getlocal("activity_yongwangzhiqian_taskTitle1"),24,"Helvetica-bold")
	titleLb1:setColor(G_ColorYellowPro2)
	titleLb1:setAnchorPoint(ccp(0,1))
	titleLb1:setPosition(ccp(30,bgHeight - 10))
	taskBg1:addChild(titleLb1,1)

	local titleLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
	titleLbBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 56,titleLb1:getContentSize().height + 15))
	titleLbBg:setAnchorPoint(ccp(0,1))
	titleLbBg:setPosition(0,bgHeight - 2)
	taskBg1:addChild(titleLbBg)

	local function showReward()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local awardTab=FormatItem(self.acVo.totalCfg[index].reward,true)
		self:showRewardDialog(1,awardTab)
	end
	local infoItem = GetButtonItem("greenTipIcon.png","greenTipIcon.png","greenTipIcon.png",showReward,11,nil,nil)
	infoItem:setScale(0.5)
	infoItem:setAnchorPoint(ccp(0.5,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(taskBg1:getContentSize().width - 30,bgHeight - 8))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	taskBg1:addChild(infoBtn)

	local num=0
	if(self.acVo.progressTotal[sid] and self.acVo.progressTotal[sid].n)then
		num=tonumber(self.acVo.progressTotal[sid].n)
	end
	local adaSize = 25
	if G_isAsia() == false then
		adaSize = 20
	end
	local descLb1=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_taskDesc1",{chapterID,checkpointID,num,self.acVo.totalCfg[index].num}),adaSize,CCSizeMake(G_VisibleSizeWidth - 300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	descLb1:setAnchorPoint(ccp(0,0.5))
	descLb1:setPosition(ccp(80,(bgHeight - 50) * 0.5))
	taskBg1:addChild(descLb1)
	if(self.acVo.progressTotal[sid] and self.acVo.progressTotal[sid].f==1)then
		local iconCheck=CCSprite:createWithSpriteFrameName("IconCheck.png")
		iconCheck:setPosition(ccp(490,(bgHeight - 50) * 0.5))
		taskBg1:addChild(iconCheck)
	elseif(self.acVo.progressTotal[sid] and self.acVo.progressTotal[sid].n and self.acVo.progressTotal[sid].n>=self.acVo.totalCfg[index].num)then
		local function onGetReward()
			local function callback()
				self.acVo=acYwzqVoApi:getAcVo()
				self:refresh()
			end
			acYwzqVoApi:getReward(1,sid,callback)
		end
		local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGetReward,nil,getlocal("daily_scene_get"),34)
		rewardItem:setScale(0.7)
		local rewardBtn=CCMenu:createWithItem(rewardItem)
		rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardBtn:setPosition(ccp(490,(bgHeight - 50) * 0.5))
		taskBg1:addChild(rewardBtn)
	else
		local function onGotoStory()
			activityAndNoteDialog:closeAllDialog()
			local chapterCfg=checkPointVoApi:getCfgBySid(chapterID)
			storyScene:setShow(ccp(chapterCfg.x,chapterCfg.y))
		end
		local gotoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGotoStory,nil,getlocal("activity_heartOfIron_goto"),34)
		gotoItem:setScale(0.7)
		local gotoBtn=CCMenu:createWithItem(gotoItem)
		gotoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		gotoBtn:setPosition(ccp(490,(bgHeight - 50) * 0.5))
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
	local titleLb2=GetTTFLabel(getlocal("activity_yongwangzhiqian_taskTitle2"),24,"Helvetica-bold")
	titleLb2:setAnchorPoint(ccp(0,1))
	titleLb2:setPosition(ccp(30,bgHeight - 10))
	titleLb2:setColor(G_ColorYellowPro2)
	taskBg2:addChild(titleLb2,1)

	local titleLbBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
	titleLbBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth - 56,titleLb2:getContentSize().height + 15))
	titleLbBg2:setAnchorPoint(ccp(0,1))
	titleLbBg2:setPosition(0,bgHeight - 2)
	taskBg2:addChild(titleLbBg2)

	local function showReward()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local awardTab=FormatItem(self.acVo.dailyCfg[index].reward,true)
		self:showRewardDialog(2,awardTab)
	end
	local infoItem = GetButtonItem("greenTipIcon.png","greenTipIcon.png","greenTipIcon.png",showReward,11,nil,nil)
	infoItem:setScale(0.5)
	infoItem:setAnchorPoint(ccp(0.5,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(taskBg2:getContentSize().width - 30,bgHeight - 8))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	taskBg2:addChild(infoBtn)

	local num=0
    local maxNum=self.acVo.dailyCfg[index].num or 0
	if(self.acVo.progressDaily.n)then
		num=tonumber(self.acVo.progressDaily.n)
        if num>maxNum then
            num=maxNum
        end
	end
	local descLb2=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_taskDesc2",{num,maxNum}),adaSize,CCSizeMake(G_VisibleSizeWidth - 300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	descLb2:setPosition(ccp(80,(bgHeight - 50)/2))
	descLb2:setAnchorPoint(ccp(0,0.5))
	taskBg2:addChild(descLb2)
	if(self.acVo.progressDaily.f and self.acVo.progressDaily.f[tid]==1)then
		local iconCheck=CCSprite:createWithSpriteFrameName("IconCheck.png")
		iconCheck:setPosition(ccp(490,(bgHeight - 50)/2))
		taskBg2:addChild(iconCheck)
	elseif(num>=maxNum)then
		local function onGetReward()
			local function callback()
				self.acVo=acYwzqVoApi:getAcVo()
				self:refresh()
			end
			acYwzqVoApi:getReward(2,tid,callback)
		end
		local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGetReward,nil,getlocal("daily_scene_get"),34)
		rewardItem:setScale(0.7)
		local rewardBtn=CCMenu:createWithItem(rewardItem)
		rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardBtn:setPosition(ccp(490,(bgHeight - 50)/2))
		taskBg2:addChild(rewardBtn)
	else
		local function onGotoStory()
			activityAndNoteDialog:closeAllDialog()
			storyScene:setShow()
		end
		local gotoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGotoStory,nil,getlocal("activity_heartOfIron_goto"),34)
		gotoItem:setScale(0.7)
		local gotoBtn=CCMenu:createWithItem(gotoItem)
		gotoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		gotoBtn:setPosition(ccp(490,(bgHeight - 50)/2))
		taskBg2:addChild(gotoBtn)
	end
end

function acYwzqDialog:tick()
	if(base.serverTime%86400==0)then
		self:refresh()
	end
	if self.timeLb then
    	self.timeLb:setString(acYwzqVoApi:getTimer())
    end
end

function acYwzqDialog:showRewardDialog(type,itemTab)
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
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30,30,1,1),onHide)
	local size=CCSizeMake(550,150 + (SizeOfTable(itemTab) + 1)*84)
	dialogBg:setContentSize(size)
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.rewardDialog:addChild(dialogBg,1)

	local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
	dialogBg2:setContentSize(CCSizeMake(510,(SizeOfTable(itemTab)+1)*84 + 10))
	dialogBg2:setPosition(20,110)
	dialogBg2:setAnchorPoint(ccp(0,0))
	dialogBg:addChild(dialogBg2)

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
	local titleLb=GetTTFLabel(getlocal("activity_yongwangzhiqian_rewardTitle"),25,"Helvetica-bold")
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(ccp(30,size.height - 60))
	titleLb:setColor(G_ColorYellowPro2)
	dialogBg:addChild(titleLb)
	local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function ()end)
	lineSp:setScaleX( (size.width -10) / lineSp:getContentSize().width)
	lineSp:setPosition(ccp(size.width/2,100))
	dialogBg:addChild(lineSp)
	local lb=GetTTFLabelWrap(getlocal("activity_yongwangzhiqian_rewardDesc"..type),25,CCSizeMake(size.width - 30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	lb:setColor(G_ColorRed3)
	lb:setPosition(size.width/2,60)
	dialogBg:addChild(lb)
end

function acYwzqDialog:refresh()
	self.acVo=acYwzqVoApi:getAcVo()
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

function acYwzqDialog:dispose()
    self.timeLb=nil
	if(self.rewardDialog)then
		self.rewardDialog:removeFromParentAndCleanup(true)
		self.rewardDialog=nil
	end
	spriteController:removePlist("public/acYwzq2018Image.plist")
    spriteController:removeTexture("public/acYwzq2018Image.png")
end