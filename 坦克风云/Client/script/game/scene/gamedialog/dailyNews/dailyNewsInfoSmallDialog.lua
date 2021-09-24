dailyNewsInfoSmallDialog=smallDialog:new()

function dailyNewsInfoSmallDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum=layerNum
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
	return nc
end

function dailyNewsInfoSmallDialog:showPersonalInfo(layerNum,titleStr,infoTb,infoType)
	local sd=dailyNewsInfoSmallDialog:new(layerNum)
	sd:initPersonalInfo(titleStr,infoTb,infoType)
	return sd
end

function dailyNewsInfoSmallDialog:showAllianceInfo(layerNum,titleStr,infoTb)
	local sd=dailyNewsInfoSmallDialog:new(layerNum)
	sd:initAllianceInfo(titleStr,infoTb)
	return sd
end

function dailyNewsInfoSmallDialog:initPersonalInfo(titleStr,dataTb,infoType)
	if not infoType then
		infoType=1
	end

	-- titleStr=getlocal("playerRole")
	infoTb={}
	
	if infoType==3 or infoType==4 then -- 天梯榜
		infoTb.name=dataTb[1] or "" -- 名字
		infoTb.level=dataTb[2] or "" -- 服务器名字
		infoTb.power=dataTb[3] or 0 -- 战力
		-- serverWarLocal_server
		infoTb.aName=dataTb[4] or 1 -- 赛季
		infoTb.pic=dataTb[5] -- 图片

		infoTb.level=getlocal("serverWarLocal_server",{infoTb.level})
		infoTb.aName=getlocal("serverWarLadderSeasonTitle",{infoTb.aName})

	else
		infoTb.pic=dataTb[1] or 1 -- 图片
		infoTb.name=dataTb[2] or "" -- 名字
		infoTb.level=dataTb[3] or 1 -- 等级
		infoTb.power=dataTb[4] or 0 -- 战力
		infoTb.aName=dataTb[5] or "" -- 军团
		infoTb.uid=dataTb[6] or 1

		local aName=infoTb.aName
		if aName=="" or aName==nil then
			aName=getlocal("alliance_info_content")
		end
		infoTb.aName=getlocal("local_war_history_alliance",{aName})
		infoTb.level=getlocal("world_war_level",{infoTb.level})
	end


	-- infoTb.glory="1000" -- 繁荣度
	-- infoTb.gloryMax="10000" -- 当前繁荣度最大值

	local dialogWidth=600
	local dialogHeight=510

	if infoType>2 then
		dialogHeight=dialogHeight-110
	end


	local gloryH=110

	-- if base.isGlory ~=1 then
		dialogHeight=dialogHeight-gloryH
	-- end

	-- layer
	self.dialogLayer=CCLayer:create()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)


	local function nilFunc()
	end
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)

	-- 真正的背景
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	local size=CCSizeMake(dialogWidth,dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2)

	self:show()

	-- 关闭按钮
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
	local closeBtn = CCMenu:createWithItem(closeBtnItem)
	closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	closeBtn:setPosition(ccp(dialogWidth-closeBtnItem:getContentSize().width,dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(closeBtn)

	-- 标题
	local titleLb=GetTTFLabel(titleStr,32)
	titleLb:setPosition(ccp(dialogWidth/2,dialogHeight - 45))
	dialogBg:addChild(titleLb,1)

	local startH=dialogHeight-90

	local grayBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),nilFunc)
	if infoType>2 then
		grayBg:setContentSize(CCSizeMake(dialogWidth-20,dialogHeight-85-15+10))
	else
		grayBg:setContentSize(CCSizeMake(dialogWidth-20,dialogHeight-85-120+10))
	end
	
	grayBg:setAnchorPoint(ccp(0.5,1))
	grayBg:setPosition(ccp(dialogWidth/2,dialogHeight-85))
	self.bgLayer:addChild(grayBg)

	local startW=40
	-- local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
	local headBs=CCNode:create()
	headBs:setContentSize(CCSizeMake(dialogWidth,180))
	headBs:setAnchorPoint(ccp(0.5,1))
	headBs:setPosition(ccp(dialogWidth/2,dialogHeight-90))
	self.bgLayer:addChild(headBs,1)
	-- headBs:setOpacity(0)

	local iconH=headBs:getContentSize().height/2+20
	if infoType==3 then
		local icon = dailyNewsVoApi:getNewsAllianceIcon()
		-- CCSprite:createWithSpriteFrameName("helpAlliance.png")
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(startW,iconH)
		headBs:addChild(icon)
		icon:setScale(120/icon:getContentSize().width)
	else
		local personPhotoName=playerVoApi:getPersonPhotoName(infoTb.pic)
		local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
		playerPic:setAnchorPoint(ccp(0,0.5))
		playerPic:setPosition(ccp(startW,iconH))
		headBs:addChild(playerPic,1)
		playerPic:setScale(120/playerPic:getContentSize().width)
	end

	

	local playerName = GetTTFLabel(infoTb.name,28)
	playerName:setAnchorPoint(ccp(0,0.5))
	playerName:setPosition(startW+140,iconH+35)
	playerName:setColor(G_ColorYellowPro)
	headBs:addChild(playerName)

	local levelLb=GetTTFLabel(infoTb.level,22)
	levelLb:setAnchorPoint(ccp(0,0.5))
	levelLb:setPosition(startW+140,iconH-15)
	-- levelLb:setColor(G_ColorYellow)
	headBs:addChild(levelLb)

	local fightLb=GetTTFLabel(getlocal("world_war_power",{G_countDigit(tonumber(infoTb.power or 0))}),22)
	fightLb:setAnchorPoint(ccp(0,0.5))
	fightLb:setPosition(startW+140,iconH-45)
	-- fightLb:setColor(G_ColorYellow)
	headBs:addChild(fightLb)

	-- local aName=infoTb.aName
	-- if aName=="" or aName==nil then
	-- 	aName=getlocal("alliance_info_content")
	-- end

	local aNameLb=GetTTFLabel(infoTb.aName,28)
	aNameLb:setAnchorPoint(ccp(0,0.5))
	aNameLb:setPosition(startW,20)
	headBs:addChild(aNameLb)

	if infoType<3 then
		local btnScale=0.6
		local lbSize=22*1/btnScale
		-- 邮件
		local function touchEmail()
			if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		    end
		    PlayEffect(audioCfg.mouseClick)
		    local pUid=playerVoApi:getUid()
		    if tonumber(infoTb.uid)==tonumber(pUid) then
		    	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("player_message_info_tip1"),true,self.layerNum+1)
		    	return
		    end
		    self:close()
		    activityAndNoteDialog:closeAllDialog()
			emailVoApi:showWriteEmailDialog(self.layerNum,getlocal("email_write"),infoTb.name,nil,nil,nil,nil,infoTb.uid)
		end
		local emailItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touchEmail,nil,getlocal("email_email"),lbSize)
		emailItem:setScale(btnScale)
		local emailBtn = CCMenu:createWithItem(emailItem)
		emailBtn:setPosition(ccp(headBs:getContentSize().width-100,30))
		emailBtn:setTouchPriority(-(self.layerNum-1)*20-3);
		headBs:addChild(emailBtn)

		-- 私聊
		local function touchS()
			if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		    end
		    -- PlayEffect(audioCfg.mouseClick)
		    local pUid=playerVoApi:getUid()
		    if tonumber(infoTb.uid)==tonumber(pUid) then
		    	PlayEffect(audioCfg.mouseClick)
		    	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("message_scene_whiper_prompt"),true,self.layerNum+1)
		    	return
		    end
		    self:close()
		    activityAndNoteDialog:closeAllDialog()
		    chatVoApi:showChatDialog(self.layerNum,nil,infoTb.uid,infoTb.name,true)
		end
		local sItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touchS,nil,getlocal("chat_private"),lbSize)
		sItem:setScale(btnScale)
		local sBtn = CCMenu:createWithItem(sItem)
		sBtn:setPosition(ccp(headBs:getContentSize().width-100,100))
		sBtn:setTouchPriority(-(self.layerNum-1)*20-3);
		headBs:addChild(sBtn)

		local function touchMenu(tag)
			if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		    end
		    PlayEffect(audioCfg.mouseClick)
		    local pid="p"..tag
		    local haveNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
			if 1>haveNum then
				local nameStr=getlocal(propCfg[pid].name)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des4",{nameStr}),30)
				return
			end
			local function refreshCallback()
				self:close()
			end

	        bagVoApi:showSearchSmallDialog(self.layerNum+1,pid,refreshCallback,infoTb.name)
		end

		local function menuFunc1()
			touchMenu(3305)
		end
		local function menuFunc2()
			touchMenu(3304)
		end
	    local menuItem1=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",menuFunc1,101,getlocal("dailyNews_scout_troop"),25)
	    local menuItem2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",menuFunc2,2,getlocal("dailyNews_scout_base"),25)

	    local menuBtn1 = CCMenu:createWithItem(menuItem1)
		menuBtn1:setPosition(ccp(self.bgLayer:getContentSize().width/2-150,60))
		menuBtn1:setTouchPriority(-(self.layerNum-1)*20-3);
		self.bgLayer:addChild(menuBtn1)

		local menuBtn2 = CCMenu:createWithItem(menuItem2)
		menuBtn2:setPosition(ccp(self.bgLayer:getContentSize().width/2+150,60))
		menuBtn2:setTouchPriority(-(self.layerNum-1)*20-3);
		self.bgLayer:addChild(menuBtn2)
	end
end

function dailyNewsInfoSmallDialog:initAllianceInfo(titleStr,dataTb)
	-- titleStr=getlocal("alliance_info_title")
	infoTb={}
	infoTb.name=dataTb[1] or "" -- 军团名字
	infoTb.level=dataTb[2] or 1 -- 等级
	infoTb.leaderName=dataTb[3] or "" -- 团长
	infoTb.fight=dataTb[4] or 0 -- 战力
	infoTb.amaxnum=dataTb[5] or 0 -- 最大人数
	infoTb.memberNum=dataTb[6] or 0 -- 当前人数
	infoTb.type=dataTb[7] or 1 -- 加入军团方式
	infoTb.level_limit=tonumber(dataTb[8] or 0) -- 等级限制（加入条件）
	infoTb.fight_limit=tonumber(dataTb[9] or 0) -- 战力限制（加入条件）
	infoTb.notice=dataTb[10] or "" -- 军团宣言

	local dialogWidth=600
	local dialogHeight=520 - 25

	if infoTb.notice=="" then
		infoTb.notice=getlocal("alliance_info_content")
	end
	local noticeValueLable=GetTTFLabelWrap(infoTb.notice,25,CCSize(dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local noticeLb = GetTTFLabelWrap(getlocal("daily_news_alliance_declaration"),25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

	local height1=noticeValueLable:getContentSize().height
	local height2=noticeLb:getContentSize().height
	local addH=height1
	if height2>height1 then
		addH=height2
	end
	dialogHeight=dialogHeight+addH


	-- layer
	self.dialogLayer=CCLayer:create()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local function nilFunc()
	end
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)

	-- 真正的背景
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	local size=CCSizeMake(dialogWidth,dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2)

	self:show()

	-- 关闭按钮
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
	local closeBtn = CCMenu:createWithItem(closeBtnItem)
	closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	closeBtn:setPosition(ccp(dialogWidth-closeBtnItem:getContentSize().width,dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(closeBtn)

	-- 标题
	local titleLb=GetTTFLabel(titleStr,32)
	titleLb:setPosition(ccp(dialogWidth/2,dialogHeight - 45))
	dialogBg:addChild(titleLb,1)

	local startH=dialogHeight-90

	local grayBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),nilFunc)
	grayBg:setContentSize(CCSizeMake(dialogWidth-20,dialogHeight-85-120))
	grayBg:setAnchorPoint(ccp(0.5,1))
	grayBg:setPosition(ccp(dialogWidth/2,dialogHeight-85))
	self.bgLayer:addChild(grayBg)

	local startW=40
	-- local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
	local headBs=CCNode:create()
	headBs:setContentSize(CCSizeMake(dialogWidth,150))
	headBs:setAnchorPoint(ccp(0.5,1))
	headBs:setPosition(ccp(dialogWidth/2,dialogHeight-90))
	self.bgLayer:addChild(headBs,1)
	-- headBs:setOpacity(0)

	local icon = dailyNewsVoApi:getNewsAllianceIcon()
	-- CCSprite:createWithSpriteFrameName("helpAlliance.png")
	icon:setAnchorPoint(ccp(0,0.5))
	icon:setPosition(startW,headBs:getContentSize().height/2)
	headBs:addChild(icon)
	icon:setScale(120/icon:getContentSize().width)

	local myAllianceName = GetTTFLabel(infoTb.name,28)
	myAllianceName:setAnchorPoint(ccp(0,0.5))
	myAllianceName:setPosition(startW+143,headBs:getContentSize().height-27)
	myAllianceName:setColor(G_ColorYellowPro)
	headBs:addChild(myAllianceName)

	local myAllianceLv = GetTTFLabel("(" .. getlocal("fightLevel",{infoTb.level}) .. ")",25)
	myAllianceLv:setAnchorPoint(ccp(0,0.5))
	myAllianceLv:setPosition(myAllianceName:getContentSize().width+5,myAllianceName:getContentSize().height/2)
	-- myAllianceLv:setColor(G_ColorGreen)
	myAllianceName:addChild(myAllianceLv)

	local myAllianceLeader = GetTTFLabelWrap(getlocal("alliance_info_leader",{infoTb.leaderName}),22,CCSizeMake(dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	myAllianceLeader:setAnchorPoint(ccp(0,0.5))
	myAllianceLeader:setPosition(startW+143,headBs:getContentSize().height/2)
	headBs:addChild(myAllianceLeader)

	local iconScale=0.8
	local myAllianceAttackSp = CCSprite:createWithSpriteFrameName("allianceAttackIcon.png")
	myAllianceAttackSp:setAnchorPoint(ccp(0,0.5))
	myAllianceAttackSp:setPosition(startW+140,30)
	headBs:addChild(myAllianceAttackSp)
	myAllianceAttackSp:setScale(iconScale)

	local myAllianceAttack = GetTTFLabel(FormatNumber(infoTb.fight),22)
	myAllianceAttack:setAnchorPoint(ccp(0,0.5))
	myAllianceAttack:setPosition(myAllianceAttackSp:getContentSize().width*iconScale+15,myAllianceAttackSp:getContentSize().height/2)
	myAllianceAttackSp:addChild(myAllianceAttack)
	myAllianceAttack:setScale(1/iconScale)

	local myAllianceNumSp = CCSprite:createWithSpriteFrameName("allianceMemberIcon.png")
	myAllianceNumSp:setAnchorPoint(ccp(0,0.5))
	myAllianceNumSp:setPosition(340,30)
	headBs:addChild(myAllianceNumSp)
	myAllianceNumSp:setScale(iconScale)

	local myAllianceNum = GetTTFLabel(getlocal("scheduleChapter",{infoTb.memberNum,infoTb.amaxnum}),22)
	myAllianceNum:setAnchorPoint(ccp(0,0.5))
	myAllianceNum:setPosition(myAllianceNumSp:getContentSize().width*iconScale+15,myAllianceNumSp:getContentSize().height/2)
	myAllianceNumSp:addChild(myAllianceNum)
	myAllianceNum:setScale(1/iconScale)

	local lineH1=dialogHeight-90-headBs:getContentSize().height-5
	local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp1:setScaleX((dialogWidth-40)/lineSp1:getContentSize().width)
	self.bgLayer:addChild(lineSp1,1)
	lineSp1:setPosition(dialogWidth/2,lineH1)

	local joinSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
	joinSp:setAnchorPoint(ccp(0.5,1))
	joinSp:setPosition(ccp(dialogWidth/2,lineH1))
	joinSp:setContentSize(CCSizeMake(dialogWidth,120))
	self.bgLayer:addChild(joinSp,1)
	joinSp:setOpacity(0)

	local joinTypeTitle = GetTTFLabelWrap(getlocal("alliance_join_type"),25,CCSizeMake(140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	joinTypeTitle:setAnchorPoint(ccp(0,0.5))
	joinTypeTitle:setPosition(startW,joinSp:getContentSize().height/4*3-10)
	joinSp:addChild(joinTypeTitle)

	local joinTypeLb = GetTTFLabelWrap(getlocal("alliance_apply"..infoTb.type),25,CCSizeMake(dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	joinTypeLb:setAnchorPoint(ccp(0,0.5))
	joinTypeLb:setPosition(180,joinSp:getContentSize().height/4*3-10)
	joinSp:addChild(joinTypeLb)
	joinTypeLb:setColor(G_ColorYellow)

	local conditionTitle = GetTTFLabelWrap(getlocal("alliance_join_condition"),25,CCSizeMake(140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionTitle:setAnchorPoint(ccp(0,0.5))
	conditionTitle:setPosition(startW,joinSp:getContentSize().height/4+10)
	joinSp:addChild(conditionTitle)

	local conditionStr=""
	if infoTb.level_limit and infoTb.level_limit>0 then
		conditionStr=conditionStr..getlocal("fightLevel",{infoTb.level_limit})
	end
	if infoTb.fight_limit and infoTb.fight_limit>0 then
	if conditionStr=="" then
		conditionStr=conditionStr..getlocal("alliance_join_condition_value",{FormatNumber(infoTb.fight_limit)})
	else
		conditionStr=conditionStr..getlocal("alliance_join_condition_and")..getlocal("alliance_join_condition_value",{FormatNumber(infoTb.fight_limit)})
	end
	end
	if conditionStr=="" then
		conditionStr=getlocal("alliance_info_content")
	end
	local conditionLb = GetTTFLabelWrap(conditionStr,25,CCSizeMake(dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionLb:setAnchorPoint(ccp(0,0.5))
	conditionLb:setPosition(180,joinSp:getContentSize().height/4+10)
	joinSp:addChild(conditionLb)
	conditionLb:setColor(G_ColorYellow)

	local lineH2=lineH1-joinSp:getContentSize().height
	-- local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- lineSp2:setScaleX((dialogWidth-40)/lineSp2:getContentSize().width)
	-- self.bgLayer:addChild(lineSp2,1)
	-- lineSp2:setPosition(dialogWidth/2,lineH2)

	-- local noticeH=lineH2-5
	local noticeH=lineH2+15
	-- local noticeLb = GetTTFLabelWrap(getlocal("alliance_info_declaration"),25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	noticeLb:setAnchorPoint(ccp(0,1))
	noticeLb:setPosition(startW,noticeH)
	self.bgLayer:addChild(noticeLb)

	-- local noticeBgH=noticeH-noticeLb:getContentSize().height-15
	-- local noticeBg =LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png",CCRect(20, 20, 10, 10),nilFunc)
	-- noticeBg:setContentSize(CCSizeMake(dialogWidth-40,150))
	-- noticeBg:setAnchorPoint(ccp(0.5,1))
	-- noticeBg:setPosition(ccp(dialogWidth/2,noticeBgH))
	-- noticeBg:setTouchPriority(-(self.layerNum-1)*20-2)
	-- self.bgLayer:addChild(noticeBg,1)

	-- local noticeValueLable=GetTTFLabelWrap(infoTb.notice,25,CCSize(dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	noticeValueLable:setAnchorPoint(ccp(0,1))
	noticeValueLable:setPosition(ccp(180,noticeH))
	noticeValueLable:setColor(G_ColorYellow)
	self.bgLayer:addChild(noticeValueLable,1)

	local function searchFunc()
		-- if G_checkClickEnable()==false then
	 --        do
	 --            return
	 --        end
  --   	end
  --   	PlayEffect(audioCfg.mouseClick)
    	self:close()
    	activityAndNoteDialog:closeAllDialog()
    	eventDispatcher:dispatchEvent("dailyNewsSmallDialog.close",{})
    	dailyNewsVoApi:goAllianceDialog(self.layerNum-1,infoTb.name)
	end
	local searchItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",searchFunc,nil,getlocal("alliance_list_scene_search"),25)
	local searchBtn=CCMenu:createWithItem(searchItem)
	searchBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	searchBtn:setAnchorPoint(ccp(0.5,0.5))
	searchBtn:setPosition(ccp(dialogWidth/2,60))
	dialogBg:addChild(searchBtn)
end

function dailyNewsInfoSmallDialog:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")
end
