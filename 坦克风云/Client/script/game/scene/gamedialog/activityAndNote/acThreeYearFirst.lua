acThreeYearFirst={}
function acThreeYearFirst:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.curPage=1
	nc.footCfg=nil
	nc.footNum=0
	nc.footSpTb={}
	nc.footNode=nil
	nc.rewardCount=0
	nc.propSize=80
	nc.cellHeight=120
	nc.rewardBtn=nil
	nc.rewardLb=nil
	nc.selectIcon=nil
	nc.selectSp=nil
	nc.footPicTb={"threeyear_know.png","helpAlliance.png","threeyear_march.png","rpCoin.png","mainBtnFriend.png"}
	return nc
end

function acThreeYearFirst:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	
	self:initTableView()

	return self.bgLayer
end

function acThreeYearFirst:initTableView()
	self.footCfg=acThreeYearVoApi:getFootCfg()
	if self.footCfg then
		self.footNum=SizeOfTable(self.footCfg)
	end
	if G_isIphone5()==true then
		self.cellHeight=150
		self.propSize=100
	end
	local count=math.floor((G_VisibleSizeHeight-160)/80)
	for i=1,count do
		local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
		bgSp:setAnchorPoint(ccp(0.5,1))
		bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
		bgSp:setScaleY(80/bgSp:getContentSize().height)
		bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
		self.bgLayer:addChild(bgSp)
		if G_isIphone5()==false and i==count then
			bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
		end
	end
	self:initTitleView()
	local isOpen=acThreeYearVoApi:isOpenHistory()
	if isOpen and isOpen==true and self.footCfg then
		self:initHistoricalStep()
	else
		self:initStrengthView()
	end
end

function acThreeYearFirst:initTitleView()
	local titlePosY=G_VisibleSizeHeight-160
	if G_isIphone5()==true then
		titlePosY=G_VisibleSizeHeight-180
	end
	local strSize3 = 25
	if G_getCurChoseLanguage() =="ar" or G_getCurChoseLanguage() =="ru" then
		strSize3 =20
	end
	local titleNode=CCNode:create()
	titleNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,1))
	titleNode:setAnchorPoint(ccp(0.5,0.5))
	titleNode:setPosition(ccp(G_VisibleSizeWidth/2,titlePosY))
	self.bgLayer:addChild(titleNode)

	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("activity_threeyear_history_rule3"),"\n",getlocal("activity_threeyear_history_rule2",{acThreeYearVoApi:getLimitLv()}),"\n",getlocal("activity_threeyear_history_rule1"),"\n"}
		local tabColor={nil,nil,nil,nil,nil,nil,nil}
		local sd=smallDialog:new()
		local layer=sd:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(layer,self.layerNum+1)
	end
	local infoItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11)
	infoItem:setScale(0.8)
	local infoBtn=CCMenu:createWithItem(infoItem)
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	infoBtn:setPosition(G_VisibleSizeWidth-60,-infoItem:getContentSize().height/2)
	titleNode:addChild(infoBtn)
	local haloSp=CCSprite:createWithSpriteFrameName("anniversaryHalo.png")
	haloSp:setAnchorPoint(ccp(0.5,1))
	haloSp:setScaleY(1.5)
	haloSp:setPosition(G_VisibleSizeWidth/2,-110)
	titleNode:addChild(haloSp)
	local ribbonSp1=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
	ribbonSp1:setPosition(G_VisibleSizeWidth/2,-140)
	titleNode:addChild(ribbonSp1)
	local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
	lightSp:setPosition(G_VisibleSizeWidth/2,-70)
	titleNode:addChild(lightSp)
	local titleBg=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,0))
    titleBg:setScaleX(1.1)
    titleBg:setPosition(ccp(G_VisibleSizeWidth/2,-155))
    titleNode:addChild(titleBg)
	local timeLb1=GetTTFLabel(getlocal("activity_timeLabel"),25)
	timeLb1:setColor(G_ColorGreen)
	timeLb1:setPosition(G_VisibleSizeWidth/2,-160)
	titleNode:addChild(timeLb1)
	local timeBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
	timeBg:setPosition(G_VisibleSizeWidth/2,-200)
	titleNode:addChild(timeBg)
	local timeStr=acThreeYearVoApi:getTimeStr()
	local timeLb2=GetTTFLabel(timeStr,25)
	timeLb2:setColor(G_ColorYellowPro)
	timeLb2:setPosition(G_VisibleSizeWidth/2,-200)
	titleNode:addChild(timeLb2)
	if(G_getCurChoseLanguage()=="cn")then
		local lb1=GetTTFLabel(getlocal("activity_anniversary_birthday1"),25)
		lb1:setColor(G_ColorYellowPro)
		lb1:setAnchorPoint(ccp(1,0.5))
		lb1:setPosition(G_VisibleSizeWidth/2-50,-115)
		titleNode:addChild(lb1)
		local sp1=CCSprite:createWithSpriteFrameName("crackerLight.png")
		sp1:setPosition(G_VisibleSizeWidth/2,-115)
		titleNode:addChild(sp1)
		local sp2=CCSprite:createWithSpriteFrameName("threenum.png")
		sp2:setPosition(G_VisibleSizeWidth/2,-115)
		titleNode:addChild(sp2)
		local lb2=GetTTFLabel(getlocal("activity_anniversary_birthday2"),25)
		lb2:setColor(G_ColorYellowPro)
		lb2:setAnchorPoint(ccp(0,0.5))
		lb2:setPosition(G_VisibleSizeWidth/2+50,-115)
		titleNode:addChild(lb2)
	else
		local lb=GetTTFLabel(getlocal("activity_anniversary_birthday"),strSize3)
		lb:setColor(G_ColorYellowPro)
		lb:setPosition(G_VisibleSizeWidth/2,-115)
		titleNode:addChild(lb)
	end
end

function acThreeYearFirst:initStrengthView()
	local iconBg=CCSprite:createWithSpriteFrameName("tank_redshade.png")
	iconBg:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)/2))
	iconBg:setScale(6)
	self.bgLayer:addChild(iconBg)
	local historyIcon=CCSprite:createWithSpriteFrameName("threeyear_icon.png")
	historyIcon:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)/2))
	self.bgLayer:addChild(historyIcon)

    local promptLb=GetTTFLabelWrap(getlocal("your_level_lack",{acThreeYearVoApi:getLimitLv()}),25,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	promptLb:setColor(G_ColorRed)
	promptLb:setPosition(ccp(G_VisibleSizeWidth/2,180))
	self.bgLayer:addChild(promptLb)

	local function goHandler()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		activityAndNoteDialog:closeAllDialog()
        local td=playerVoApi:showPlayerDialog(1,self.layerNum+1)
        td:tabClick(2)
	end
	local goItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",goHandler,11,getlocal("i_will_strength"),25)
	goItem:setAnchorPoint(ccp(0.5,0.5))
	local goBtn=CCMenu:createWithItem(goItem)
	goBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	goBtn:setPosition(ccp(G_VisibleSizeWidth/2,80))
	self.bgLayer:addChild(goBtn)

	G_addRectFlicker(goItem,2.4,1.1,getCenterPoint(goItem))
end

function acThreeYearFirst:initHistoricalStep()
	local strSize2 = 20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
		strSize2 =25
	end
	local historyNode=CCNode:create()
	historyNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,1))
	historyNode:setAnchorPoint(ccp(0.5,0))
	historyNode:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(historyNode)

	local iconPosY=320
	local height=180
	if G_isIphone5()==true then
		height=220
		iconPosY=400
	end
	if self.footCfg then
		local function onLeft()
			self:pageChange(-1)
		end
		local leftBtn=LuaCCSprite:createWithSpriteFrameName("ArrowYellow.png",onLeft)
		leftBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		leftBtn:setRotation(180)
		leftBtn:setPosition(90,iconPosY)
		historyNode:addChild(leftBtn)
		local leftMvTo1=CCMoveTo:create(0.5,ccp(70,iconPosY))
		local leftMvTo2=CCMoveTo:create(0.5,ccp(90,iconPosY))
		local leftSeq=CCSequence:createWithTwoActions(leftMvTo1,leftMvTo2)
		leftBtn:runAction(CCRepeatForever:create(leftSeq))
		--小箭头太小，不容点到，加个遮罩
		local leftMask=LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",onLeft)
		leftMask:setOpacity(0)
		leftMask:setTouchPriority(-(self.layerNum-1)*20-4)
		leftMask:setScale(2)
		leftMask:setPosition(80,iconPosY)
		historyNode:addChild(leftMask)
		local function onRight()
			self:pageChange(1)
		end
		local rightBtn=LuaCCSprite:createWithSpriteFrameName("ArrowYellow.png",onRight)
		rightBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		rightBtn:setPosition(G_VisibleSizeWidth-90,iconPosY)
		historyNode:addChild(rightBtn)
		local rightMoTo1=CCMoveTo:create(0.5,ccp(G_VisibleSizeWidth-70,iconPosY))
		local rightMoTo2=CCMoveTo:create(0.5,ccp(G_VisibleSizeWidth-90,iconPosY))
		local rightSeq=CCSequence:createWithTwoActions(rightMoTo1,rightMoTo2)
		rightBtn:runAction(CCRepeatForever:create(rightSeq))
		--小箭头太小，不容点到，加个遮罩
		local rightMask=LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",onRight)
		rightMask:setOpacity(0)
		rightMask:setTouchPriority(-(self.layerNum-1)*20-4)
		rightMask:setScale(2)
		rightMask:setPosition(G_VisibleSizeWidth-80,iconPosY)
		historyNode:addChild(rightMask)

		local iconBg=CCSprite:createWithSpriteFrameName("tank_redshade.png")
		iconBg:setPosition(G_VisibleSizeWidth/2,iconPosY)
		iconBg:setScale(6)
		historyNode:addChild(iconBg)
		local historyIcon=CCSprite:createWithSpriteFrameName("threeyear_icon.png")
		historyIcon:setPosition(G_VisibleSizeWidth/2,iconPosY)
		historyNode:addChild(historyIcon)
		local radius=historyIcon:getContentSize().height/2-50
		local perAngle=360/self.footNum
		for k,v in pairs(self.footCfg) do
			local angle=(k-1)*perAngle
			local footNode=CCNode:create()
			footNode:setAnchorPoint(ccp(0.5,0.5))
			footNode:setPosition(getCenterPoint(historyIcon))
			historyIcon:addChild(footNode,2)
			footNode:setRotation(angle)

			local function clickHandler()
				local foot=self.footSpTb[k]
				if foot and foot.index then
					if foot.index==2 then
						self:pageChange(-1)
					elseif foot.index==5 then
						self:pageChange(1)
					end
				end
			end
			local footSp=LuaCCSprite:createWithSpriteFrameName("history_unselect.png",clickHandler)
			footSp:setAnchorPoint(ccp(0.5,0))
			footSp:setPosition(ccp(footNode:getContentSize().width/2,radius))
            footSp:setTouchPriority(-(self.layerNum-1)*20-3)
			footSp:setTag(101)
			footNode:addChild(footSp)
			local shadeSp=CCSprite:createWithSpriteFrameName("history_shade.png")
			-- shadeSp:setAnchorPoint(ccp(0.5,0))
			shadeSp:setPosition(getCenterPoint(shadeSp))
			shadeSp:setTag(102)
			footSp:addChild(shadeSp)
			local icon=CCSprite:createWithSpriteFrameName(self.footPicTb[k])
			icon:setAnchorPoint(ccp(0.5,0.5))
			icon:setTag(103)
			icon:setPosition(footSp:getContentSize().width/2,75)
			if k==4 then
				icon:setScale(0.6)
			else
				icon:setScale(0.8)
			end
			footSp:addChild(icon)
			if k==1 then
				footSp:setScale(1)
			else
				footSp:setScale(0.8)
			end
			if k==3 or k==4 then
				footSp:setScale(0)
			end
			local foot={sp=footNode,index=k}
			self.footSpTb[k]=foot
		end
		local footNode=CCNode:create()
		footNode:setAnchorPoint(ccp(0.5,0.5))
		footNode:setPosition(getCenterPoint(historyIcon))
		historyIcon:addChild(footNode,10)
		local selectSp=CCSprite:createWithSpriteFrameName("history_select.png")
		selectSp:setAnchorPoint(ccp(0.5,0))
		selectSp:setPosition(ccp(footNode:getContentSize().width/2,radius))
		footNode:addChild(selectSp)
		self.selectSp=selectSp
		self:refreshHistoryView()
	end
	local function onSendChat()
		if(self.lastChat==nil or base.serverTime>=self.lastChat+5)then
			self.lastChat=base.serverTime
			local params={subType=1,contentType=2,message=acThreeYearVoApi:getHistoryDesc(self.curPage),level=playerVoApi:getPlayerLevel(),rank=playerVoApi:getRank(),power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=G_getCurChoseLanguage(),st=base.serverTime,title=playerVoApi:getTitle(),brType=10}
			chatVoApi:sendChatMessage(1,playerVoApi:getUid(),playerVoApi:getPlayerName(),0,"",params)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_anniversary_sendChat"),30)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{self.lastChat + 5 - base.serverTime}),30)
		end
	end
	local sendChatItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onSendChat)
	sendChatItem:setScale(1.2)
	local sendChatBtn=CCMenu:createWithItem(sendChatItem)
	sendChatBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	sendChatBtn:setPosition(G_VisibleSizeWidth-60,height+sendChatItem:getContentSize().width*sendChatItem:getScale()/2)
	historyNode:addChild(sendChatBtn)
 	local function nilFunc()
    end
	local fadeBg=LuaCCScale9Sprite:createWithSpriteFrameName("brown_fade1.png",CCRect(0,0,162,66),nilFunc)
    fadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,height))
    fadeBg:setAnchorPoint(ccp(0.5,1))
    fadeBg:setRotation(180)
    fadeBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
    historyNode:addChild(fadeBg)

	local readLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
	readLine:setScaleX((G_VisibleSizeWidth-50)/readLine:getContentSize().width)
	readLine:setScaleY(2/readLine:getContentSize().height)
	readLine:setPosition(G_VisibleSizeWidth/2,height)
	historyNode:addChild(readLine)
    
	local historyStr=acThreeYearVoApi:getHistoryDesc(self.curPage)
	local historyLb=GetTTFLabelWrap(historyStr,strSize2,CCSize(G_VisibleSizeWidth-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	historyLb:setAnchorPoint(ccp(0,0.5))
    historyLb:setPosition(ccp(40,height/2+self.cellHeight/2))
    historyNode:addChild(historyLb)
    self.historyLb=historyLb

    self.rewardList=FormatItem(self.footCfg[1].reward)
    self.rewardCount=SizeOfTable(self.rewardList)

    local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,20,20),nilFunc)
    rewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-200,self.cellHeight))
    rewardBg:setAnchorPoint(ccp(0,0))
    rewardBg:setPosition(ccp(30,5))
    historyNode:addChild(rewardBg)
    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-220,self.cellHeight),nil)
    self.tv:setPosition(ccp(10,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    rewardBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

	local function onGetReward()
		local function callback()
			for k,v in pairs(self.rewardList) do
				G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
			end
			G_showRewardTip(self.rewardList,true)
			self:refreshHistoryView()
		end
		acThreeYearVoApi:threeYearRequest("reward",self.curPage,nil,callback)
	end
	local rewardItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,11,nil,25,12)
	self.rewardBtn=CCMenu:createWithItem(rewardItem)
	self.rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.rewardBtn:setPosition(G_VisibleSizeWidth-100,self.cellHeight/2+10)
	historyNode:addChild(self.rewardBtn,1)

	self.rewardLb=GetTTFLabel(getlocal("activity_hadReward"),25)
	self.rewardLb:setColor(G_ColorWhite)
	self.rewardLb:setPosition(G_VisibleSizeWidth-100,self.cellHeight/2+10)
	historyNode:addChild(self.rewardLb,1)
	self:refreshHistoryView()
end

function acThreeYearFirst:pageChange(num)
	if(self.moving)then
		do return end
	end
	self.moving=true
	if self.selectSp then
		self.selectSp:setVisible(false)
	end
	self.curPage=self.curPage-num
	if(self.curPage>self.footNum)then
		self.curPage=1
	elseif(self.curPage<1)then
		self.curPage=self.footNum
	end
	local perAngle=360/self.footNum
	local time=0.5
	for k,v in pairs(self.footSpTb) do
		local footNode=v.sp
		local index=v.index
		if footNode and index then
			local rotateBy=CCRotateBy:create(time,num*perAngle)
			footNode:runAction(rotateBy)
			local footSp=tolua.cast(footNode:getChildByTag(101),"CCSprite")
			if footSp then
				local shadeSp=tolua.cast(footSp:getChildByTag(102),"CCSprite")	
				local iconSp=tolua.cast(footSp:getChildByTag(103),"CCSprite")
				local scale=0.8
				local fadeIn
				local fadeOut
				local delay
				local callFunc
				-- local fadeTime=time-0.4
				if (num==1 and index==5) or (num==-1 and index==2) then
					scale=1
					local function moveEnd()
						self.moving=false
						self.selectSp:setVisible(true)
						self:refreshHistoryView()
					end
					callFunc=CCCallFuncN:create(moveEnd)
				elseif (num==1 and index==2) or (num==-1 and index==5) then
					scale=0
					fadeIn=CCFadeTo:create(time,0)
					local fadeIn2=CCFadeTo:create(time,0)
					local fadeIn3=CCFadeTo:create(time,0)
					shadeSp:runAction(fadeIn2)
					iconSp:runAction(fadeIn3)
				elseif (num==1 and index==4) or (num==-1 and index==3)then
					fadeOut=CCFadeTo:create(time,255)
					local fadeOut2=CCFadeTo:create(time,255)
					local fadeOut3=CCFadeTo:create(time,255)
					shadeSp:runAction(fadeOut2)
					iconSp:runAction(fadeOut3)
				    -- delay=CCDelayTime:create(time-fadeTime)
			    elseif (num==1 and index==3) or (num==-1 and index==4) then
				   scale=0
				end
				local scaleTo=CCScaleTo:create(time,scale)
				local spawnArr=CCArray:create()
 			    local spawn
 			    if fadeIn~=nil and fadeOut==nil then
 			    	spawnArr:addObject(scaleTo)
 			    	spawnArr:addObject(fadeIn)
 			    	spawn=CCSpawn:create(spawnArr)
 			    elseif fadeIn==nil and fadeOut~=nil then
			    	spawnArr:addObject(scaleTo)
 			    	spawnArr:addObject(fadeOut)
 			    	spawn=CCSpawn:create(spawnArr)
 			    end
				local arr=CCArray:create()
				if delay then
					arr:addObject(delay)
				end
				if spawn then
					arr:addObject(spawn)
				else
					arr:addObject(scaleTo)
				end

				if callFunc then
					arr:addObject(callFunc)
				end
				local seq=CCSequence:create(arr)
				footSp:runAction(seq)
			end
		end
	end
	for k,v in pairs(self.footSpTb) do
		local index=v.index+num
		if index>self.footNum then
			index=1
		elseif index<1 then
			index=self.footNum
		end
		v.index=index
	end
end

function acThreeYearFirst:refreshHistoryView()
	local historyStr=acThreeYearVoApi:getHistoryDesc(self.curPage)
	if self.historyLb then
		self.historyLb:setString(historyStr)
	end
	if self.footCfg and self.footCfg[self.curPage] and self.tv then
		self.rewardList=FormatItem(self.footCfg[self.curPage].reward)
		self.rewardCount=SizeOfTable(self.rewardList)
		self.tv:reloadData()
		local flag=acThreeYearVoApi:getHistoryRewardFlag(self.curPage)
		if flag==2 then
			self.rewardBtn:setVisible(false)
			self.rewardLb:setVisible(true)
		else
			self.rewardLb:setVisible(false)
			self.rewardBtn:setVisible(true)
		end

		if self.selectSp then
			if self.selectIcon then
				self.selectIcon:removeFromParentAndCleanup(true)
				self.selectIcon=nil
			end
			local icon=CCSprite:createWithSpriteFrameName(self.footPicTb[self.curPage])
			icon:setAnchorPoint(ccp(0.5,0.5))
			icon:setPosition(self.selectSp:getContentSize().width/2,75)
			self.selectSp:addChild(icon)
			self.selectIcon=icon
			if self.curPage==4 then
				icon:setScale(0.6)
			else
				icon:setScale(0.8)
			end
		end
	end
end

function acThreeYearFirst:eventHandler(handler,fn,idx,cel)
     if fn=="numberOfCellsInTableView" then     
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.rewardCount*self.propSize+(self.rewardCount-1)*10+20,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local iconSize=self.propSize
        for k,v in pairs(self.rewardList) do
            local icon,iconScale=G_getItemIcon(v,iconSize,true,self.layerNum,nil,self.tv)
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10+(k-1)*(iconSize+10),self.cellHeight/2+10)
            cell:addChild(icon)

            local num=GetTTFLabel("x"..FormatNumber(v.num),20/iconScale)
            num:setAnchorPoint(ccp(0.5,1))
            num:setPosition(icon:getContentSize().width/2,-5)
            icon:addChild(num)
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

function acThreeYearFirst:tick()

end

function acThreeYearFirst:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.parent=nil
	self.layerNum=nil
	self.curPage=1
	self.footCfg=nil
	self.footNum=0
	self.footSpTb={}
	self.footNode=nil
	self.rewardCount=0
	self.propSize=100
	self.cellHeight=150
	self.rewardBtn=nil
	self.rewardLb=nil
	self.footPicTb=nil
	self.selectIcon=nil
	self.selectSp=nil
	self=nil
end