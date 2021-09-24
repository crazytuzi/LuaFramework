localWarBidSmallDialog=smallDialog:new()

function localWarBidSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=600
	self.dialogHeight=700

	-- self.parent=parent
	-- self.cityID=1
	return nc
end

function localWarBidSmallDialog:init(layerNum)
	self.layerNum=layerNum
	local function nilFunc()
	end

	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	local titleLb=GetTTFLabel(getlocal("local_war_bid"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)


	local capInSet = CCRect(42, 26, 10, 10)
	local function cellClick(hd,fn,idx)
	end
	local serverTxtSp=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",capInSet,cellClick)
	serverTxtSp:setContentSize(CCSizeMake(self.dialogWidth-20,120))
	serverTxtSp:ignoreAnchorPointForPosition(false)
	serverTxtSp:setAnchorPoint(ccp(0.5,0.5))
	serverTxtSp:setIsSallow(false)
	serverTxtSp:setTouchPriority(-(self.layerNum-1)*20-2)
	serverTxtSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-150))
	dialogBg:addChild(serverTxtSp,1)


	self.allianceFunds=allianceVoApi:getSelfAlliance().point
	local applyAllianceNum=localWarVoApi:getApplyAllianceNum() --报名军团数量
	local lbPosX=self.dialogWidth/2
	local status,tStr,strColor,signupTime=localWarVoApi:checkStatus()
	local time=0
	if status<=10 then
		time=signupTime-base.serverTime
		if time<0 then
			time=0
		end
	else
		time=0
	end
	local timeStr=""
	if time>0 then
		timeStr=G_getTimeStr(time)
	else
		timeStr=getlocal("serverwarteam_all_end")
	end
	-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	local lbTab={
		{getlocal("local_war_bid_can_battle",{localWarCfg.signupBattleNum}),25,ccp(0.5,0.5),ccp(serverTxtSp:getContentSize().width/2,serverTxtSp:getContentSize().height/3*2+5),serverTxtSp,1,G_ColorYellowPro,CCSize(serverTxtSp:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{getlocal("local_war_bid_alliance_num",{applyAllianceNum}),25,ccp(0.5,0.5),ccp(serverTxtSp:getContentSize().width/2,serverTxtSp:getContentSize().height/3-5),serverTxtSp,1,G_ColorWhite,CCSize(serverTxtSp:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{getlocal("local_war_bid_count_down"),25,ccp(0.5,0.5),ccp(lbPosX,self.dialogHeight/2+100),self.bgLayer,1,G_ColorWhite,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{timeStr,25,ccp(0.5,0.5),ccp(lbPosX,self.dialogHeight/2+60),self.bgLayer,1,G_ColorGreen},
		{getlocal("local_war_bid_min_point",{localWarCfg.minRegistrationFee}),25,ccp(0.5,0.5),ccp(lbPosX,self.dialogHeight/2-60),self.bgLayer,1,G_ColorYellowPro,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{getlocal("local_war_bid_left_funds"),25,ccp(0.5,0.5),ccp(lbPosX,self.dialogHeight/2-120),self.bgLayer,1,G_ColorWhite,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{allianceVoApi:getSelfAlliance().point,25,ccp(0.5,0.5),ccp(lbPosX,self.dialogHeight/2-160),self.bgLayer,1,G_ColorGreen},
		{getlocal("local_war_bid_show_result"),25,ccp(0,0.5),ccp(30,130),self.bgLayer,1,G_ColorRed,CCSize(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	}
	for k,v in pairs(lbTab) do
		local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
		local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
		if k==4 then
			self.timeLb=lb
		elseif k==7 then
			self.moneyLb=lb
		end
	end

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0.5))
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setScaleY(1.2)
	lineSp:setPosition(ccp(lbPosX,165))
	self.bgLayer:addChild(lineSp,2) 



	-- self.moneyLb=GetTTFLabelWrap(getlocal("allianceWar_leftFundsNum",{allianceVoApi:getSelfAlliance().point}),25,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- self.moneyLb:setPosition(ccp(self.dialogWidth/2,(self.dialogHeight-85+self.dialogHeight/2+30)/2))
	-- dialogBg:addChild(self.moneyLb)

	local inputWidth=180
	local function callbackInput(fn,eB,str,type)
		if type==1 then  --检测文本内容变化
			if str=="" then
				self.lastNumValue="0"
				self.numShowLb:setString(self.lastNumValue)
				do return end
			end
			local strNum=tonumber(str)
			if strNum==nil then
				eB:setText(self.lastNumValue)
			else
				if strNum>=0 and strNum<=self.allianceFunds then
					self.lastNumValue=str
				else
					if(strNum<0)then
						eB:setText("0")
						self.lastNumValue="0"
					elseif strNum>self.allianceFunds then
						eB:setText(self.allianceFunds)
						self.lastNumValue=tostring(self.allianceFunds)
					end
				end
			end
			self.numShowLb:setString(self.lastNumValue)
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			self.numShowLb:setString(self.lastNumValue)
			self.moneyLb:setString(allianceVoApi:getSelfAlliance().point-tonumber(self.lastNumValue))
		end
	end
	self.lastNumValue="0"
	local centerPoint=getCenterPoint(dialogBg)
	local numEditBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),nilFunc)
	numEditBoxBg:setContentSize(CCSize(inputWidth,60))
	local showLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),nilFunc)
	showLbBg:setContentSize(CCSize(inputWidth,60))
	showLbBg:setPosition(centerPoint)
	dialogBg:addChild(showLbBg)
	self.numShowLb=GetTTFLabel(self.lastNumValue,25)
	self.numShowLb:setPosition(getCenterPoint(showLbBg))
	showLbBg:addChild(self.numShowLb)
	local numEditBox
	numEditBox=CCEditBox:createForLua(CCSize(inputWidth,60),numEditBoxBg,nil,nil,callbackInput)
	if G_isIOS()==true then
		numEditBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
	else
		numEditBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
	end
	numEditBox:setPosition(centerPoint)
	numEditBox:setText(0)
	numEditBox:setVisible(false)
	dialogBg:addChild(numEditBox)
	local function showEditBox()
		numEditBox:setText(self.lastNumValue)
		numEditBox:setVisible(true)
	end
	local numEditBoxBg2=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),showEditBox)
	numEditBoxBg2:setPosition(centerPoint)
	numEditBoxBg2:setContentSize(CCSize(inputWidth,60))
	numEditBoxBg2:setTouchPriority(-(self.layerNum-1)*20-4)
	numEditBoxBg2:setOpacity(0)
	dialogBg:addChild(numEditBoxBg2)

	-- local nameStr=getlocal(cityCfg.name)
	-- local warTimeStr=allianceWarVoApi:formatTimeStrByTb(localWarCfg.startWarTime)
	-- local timeLb=GetTTFLabelWrap(getlocal("allianceWar_signTimeDesc2",{nameStr,warTimeStr}),25,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- timeLb:setPosition(ccp(self.dialogWidth/2,(90+self.dialogHeight/2-30)/2))
	-- dialogBg:addChild(timeLb)


	local function onClickResult()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local checkStatus=localWarVoApi:checkStatus()
		if checkStatus>10 then
			local applyRank=localWarVoApi:getApplyRank()
			if applyRank and SizeOfTable(applyRank)>0 then
				localWarVoApi:showApplyRankDialog(self.layerNum+1)
			else
				local function applyrankCallback()
					localWarVoApi:showApplyRankDialog(self.layerNum+1)
				end
				localWarVoApi:applyrank(applyrankCallback)
			end
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_bid_show_result"),30)
		end
	end
	self.resultItem=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",onClickResult,1,getlocal("local_war_bid_result"),25)
	local resultBtn=CCMenu:createWithItem(self.resultItem);
	resultBtn:setPosition(ccp(155,60))
	resultBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	dialogBg:addChild(resultBtn)

	local selfApplyData=localWarVoApi:getSelfApplyData()
	local function onClickBid()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:bid()
	end
	if selfApplyData and SizeOfTable(selfApplyData)>0 then
		self.bidItem=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",onClickBid,2,getlocal("local_war_bid_already"),25)
	else
		self.bidItem=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",onClickBid,2,getlocal("local_war_bid"),25)
	end
	local bidBtn=CCMenu:createWithItem(self.bidItem);
	bidBtn:setPosition(ccp(self.dialogWidth-155,60))
	bidBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	dialogBg:addChild(bidBtn)
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if selfAlliance and tonumber(selfAlliance.role)==2 then
		if selfApplyData and SizeOfTable(selfApplyData)>0 then
			self.bidItem:setEnabled(false)
		else
			self.bidItem:setEnabled(true)
		end
	else
		self.bidItem:setEnabled(false)
	end

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)
		
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

	base:addNeedRefresh(self)
end

function localWarBidSmallDialog:bid()
	local bidFunds=tonumber(self.lastNumValue)
	local bidMinLimit=localWarCfg.minRegistrationFee
	if(bidFunds==nil or bidFunds<bidMinLimit)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_illegalFunds",{bidMinLimit}),30)
	else
		local function onBidCallback()
			self:close()
		end
		localWarVoApi:bid(bidFunds,onBidCallback)
	end
end

function localWarBidSmallDialog:tick()
	if self and self.timeLb then
		local status,tStr,strColor,signupTime=localWarVoApi:checkStatus()
		if status<=10 then
			local time=signupTime-base.serverTime
			if time<0 then
				time=0
			end
			local timeStr=""
			if time>0 then
				timeStr=G_getTimeStr(time)
			else
				timeStr=getlocal("serverwarteam_all_end")
			end
			self.timeLb:setString(timeStr)
		end
	end
end



