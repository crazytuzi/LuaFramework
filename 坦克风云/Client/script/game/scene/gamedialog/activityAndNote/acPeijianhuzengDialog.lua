acPeijianhuzengDialog = commonDialog:new()

function acPeijianhuzengDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acPeijianhuzeng.plist")
	return nc
end	

function acPeijianhuzengDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))   
end	

function acPeijianhuzengDialog:initTableView()
	local function callback( ... )
	end

	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
	self:tabClick(0,false)
end

function acPeijianhuzengDialog:doUserHandler()
	local h = G_VisibleSizeHeight-100
	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, h))
	self.bgLayer:addChild(acLabel)
	acLabel:setColor(G_ColorGreen)

	h = h-30
	local acVo = acPeijianhuzengVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, h))
	self.bgLayer:addChild(messageLabel)
	self.timeLb=messageLabel
	self:updateAcTime()


	local reward = acPeijianhuzengVoApi:getReward()
	self.reward=reward

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
		local tabStr = {"\n",getlocal("activity_peijianhuzeng_tip6",{reward[2].name,reward[1].name}),getlocal("activity_peijianhuzeng_tip5",{reward[2].name}),getlocal("activity_peijianhuzeng_tip4",{reward[2].name,reward[1].name}),getlocal("activity_peijianhuzeng_tip3",{reward[1].name}),getlocal("activity_peijianhuzeng_tip2",{reward[2].name}), getlocal("activity_peijianhuzeng_tip1",{reward[2].name,reward[1].name}),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
		sceneGame:addChild(dialog,self.layerNum+1)

	end
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-15, h))
	self.bgLayer:addChild(menuDesc,2)

	h = h-40
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	
	girlImg:setAnchorPoint(ccp(0,1))
	girlImg:setPosition(ccp(20,h+10))
	self.bgLayer:addChild(girlImg,2)

	local size
	if(G_isIphone5())then
		size=CCSizeMake(460,250)
	else
		girlImg:setScale(0.8)
		size=CCSizeMake(460,200)
	end

	local function nilFunc()
	end 
	local desBackSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),nilFunc);
	desBackSprite:setContentSize(size)
	desBackSprite:setAnchorPoint(ccp(0,1))
	desBackSprite:setOpacity(180)
	desBackSprite:setPosition(ccp(160,h))
	self.bgLayer:addChild(desBackSprite,1)

	local tvSize
	if(G_isIphone5())then
		tvSize=CCSizeMake(desBackSprite:getContentSize().width*0.75, 150)
	else
		tvSize=CCSizeMake(desBackSprite:getContentSize().width*0.85, 120)
	end

	local upLb = getlocal("activity_peijianhuzeng_des_content")
	local desTv, desLabel = G_LabelTableView(tvSize,upLb,25,kCCTextAlignmentLeft)
	desBackSprite:addChild(desTv)
	desTv:setPosition(ccp(desBackSprite:getContentSize().width*0.12,60))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)

	if(G_isIphone5())then
		desTv:setPosition(ccp(desBackSprite:getContentSize().width*0.25,60))
	else
		desTv:setPosition(ccp(desBackSprite:getContentSize().width*0.12,60))
	end

	local str = "——" .. getlocal("activity_peijianhuzeng_des_title")
	local desTitleLb = GetTTFLabelWrap(str,25,CCSizeMake(200,40),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
	desBackSprite:addChild(desTitleLb)
	desTitleLb:setPosition(ccp(desBackSprite:getContentSize().width*0.65,30))

	h=h-desBackSprite:getContentSize().height-30
	local aleadyLb = GetTTFLabel(getlocal("activity_peijianhuzeng_aleadyCost"),25)
	aleadyLb:setAnchorPoint(ccp(0,0.5))
	aleadyLb:setPosition(40,h)
	aleadyLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(aleadyLb,2)

	local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	aleadyLb:addChild(goldSp)
	goldSp:setAnchorPoint(ccp(0,0.5))
	goldSp:setPosition(aleadyLb:getContentSize().width, aleadyLb:getContentSize().height/2)

	local goldNumLb = GetTTFLabel(acPeijianhuzengVoApi:getAleadyCost(),25)
	goldNumLb:setColor(G_ColorYellowPro)
	goldNumLb:setAnchorPoint(ccp(0,0.5))
	aleadyLb:addChild(goldNumLb)
	goldNumLb:setPosition(aleadyLb:getContentSize().width+goldSp:getContentSize().width, aleadyLb:getContentSize().height/2)

	-- h = h-120
	if(G_isIphone5())then
		aleadyLb:setPosition(40,h-15)
		h = h-180
	else
		aleadyLb:setPosition(40,h)
		h = h-120
	end
	local function touchBgSp()
	end

	local backSprite1 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchBgSp)
	backSprite1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width/2-50, h))
	backSprite1:setPosition(ccp(self.bgLayer:getContentSize().width/4,100))
	backSprite1:setAnchorPoint(ccp(0.5,0))
	self.bgLayer:addChild(backSprite1)

	local backSprite2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchBgSp)
	backSprite2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width/2-50, h))
	backSprite2:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,100))
	backSprite2:setAnchorPoint(ccp(0.5,0))
	self.bgLayer:addChild(backSprite2)

	if(G_isIphone5())then
		backSprite2:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,120))
		backSprite1:setPosition(ccp(self.bgLayer:getContentSize().width/4,120))
	else
		backSprite2:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,100))
		backSprite1:setPosition(ccp(self.bgLayer:getContentSize().width/4,100))
	end

	

	local function touchMenu(tag)
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if tag==3 then
			friendMailVoApi:showSelectFriendDialog(self.layerNum)
		else
			local function callback(fn,data)
				 local ret,sData = base:checkServerData(data)
				 if ret==true then
				 	if sData and sData.data and sData.data.sendaccessory then
						local data =  sData.data.sendaccessory
						acPeijianhuzengVoApi:setR(data.r)
						G_addPlayerAward(reward[tag].type,reward[tag].key,reward[tag].id,reward[tag].num,nil,true)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
						self:checkEnable()
					end
				 end
			end
			socketHelper:acPeijianhuzengLingjiang(tag,callback)
		end
	end

	local receiveItem1 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchMenu,2,getlocal("daily_scene_get"),25)
	receiveItem1:setScale(0.8)
	local receiveBtn1=CCMenu:createWithItem(receiveItem1);
	receiveBtn1:setTouchPriority(-(self.layerNum-1)*20-4);
	receiveBtn1:setPosition(ccp(backSprite1:getContentSize().width/2,47))
	backSprite1:addChild(receiveBtn1)
	self.item1 = receiveItem1

	local goldSp1 = CCSprite:createWithSpriteFrameName("IconGold.png")
	backSprite1:addChild(goldSp1)
	goldSp1:setAnchorPoint(ccp(1,0.5))
	goldSp1:setPosition(backSprite1:getContentSize().width/2-10, 47+receiveItem1:getContentSize().height/2+15)

	local goldNumLb1 = GetTTFLabel(acPeijianhuzengVoApi:getCost(2),25)
	goldNumLb1:setColor(G_ColorYellowPro)
	goldNumLb1:setAnchorPoint(ccp(0,0.5))
	goldSp1:addChild(goldNumLb1)
	goldNumLb1:setPosition(goldSp1:getContentSize().width, goldSp1:getContentSize().height/2)

	local alreadyLb1=GetTTFLabel(getlocal("activity_hadReward"),25)
	alreadyLb1:setColor(G_ColorGreen)
	alreadyLb1:setAnchorPoint(ccp(0.5,0.5))
	backSprite1:addChild(alreadyLb1)
	alreadyLb1:setPosition(backSprite1:getContentSize().width/2,47)
	alreadyLb1:setVisible(false)
	self.alreadyLb1=alreadyLb1

	local Guangsp1=CCSprite:createWithSpriteFrameName("AperturePhoto.png")
	backSprite1:addChild(Guangsp1)
	Guangsp1:setScale(1.3)
	Guangsp1:setPosition(backSprite1:getContentSize().width/2,backSprite1:getContentSize().height-Guangsp1:getContentSize().width/2)
	self.Guangsp1=Guangsp1

	local sbBox = CCSprite:createWithSpriteFrameName("acPjhz_xiang_kai.png")
	backSprite1:addChild(sbBox)
	sbBox:setScale(0.7)
	sbBox:setPosition(backSprite1:getContentSize().width/2,backSprite1:getContentSize().height-Guangsp1:getContentSize().width/2+10)

	local nameStr = reward[2].name
	local nameLb = GetTTFLabel(nameStr,30)
	sbBox:addChild(nameLb)
	nameLb:setAnchorPoint(ccp(0.5,1))
	nameLb:setPosition(sbBox:getContentSize().width/2, -10)
	nameLb:setColor(G_ColorYellowPro)

	local desTvSize
	if(G_isIphone5())then
		desTvSize=CCSizeMake(desBackSprite:getContentSize().width*0.52,80)
		nameLb:setPosition(sbBox:getContentSize().width/2, -50)
	else
		desTvSize=CCSizeMake(desBackSprite:getContentSize().width*0.52,80)
		nameLb:setPosition(sbBox:getContentSize().width/2, -10)
	end

	local desStr = getlocal(reward[2].desc)
	local desTv, desLabel = G_LabelTableView(desTvSize,desStr,22,kCCTextAlignmentLeft)
	backSprite1:addChild(desTv)
	desTv:setPosition(ccp(20,backSprite1:getContentSize().height/2-70))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(60)



	local receiveItem2 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchMenu,1,getlocal("daily_scene_get"),25)
	receiveItem2:setScale(0.8)
	local receiveBtn2=CCMenu:createWithItem(receiveItem2);
	receiveBtn2:setTouchPriority(-(self.layerNum-1)*20-4);
	receiveBtn2:setPosition(ccp(backSprite2:getContentSize().width/2,47))
	backSprite2:addChild(receiveBtn2)
	self.item2 = receiveItem2


	local goldSp2 = CCSprite:createWithSpriteFrameName("IconGold.png")
	backSprite2:addChild(goldSp2)
	goldSp2:setAnchorPoint(ccp(1,0.5))
	goldSp2:setPosition(backSprite2:getContentSize().width/2-10, 47+receiveItem2:getContentSize().height/2+15)

	local goldNumLb2 = GetTTFLabel(acPeijianhuzengVoApi:getCost(1),25)
	goldNumLb2:setColor(G_ColorYellowPro)
	goldNumLb2:setAnchorPoint(ccp(0,0.5))
	goldSp2:addChild(goldNumLb2)
	goldNumLb2:setPosition(goldSp2:getContentSize().width, goldSp2:getContentSize().height/2)

	local alreadyLb2=GetTTFLabel(getlocal("activity_hadReward"),25)
	alreadyLb2:setColor(G_ColorGreen)
	alreadyLb2:setAnchorPoint(ccp(0.5,0.5))
	backSprite2:addChild(alreadyLb2)
	alreadyLb2:setPosition(backSprite2:getContentSize().width/2,47)
	alreadyLb2:setVisible(false)
	self.alreadyLb2=alreadyLb2

	local Guangsp2=CCSprite:createWithSpriteFrameName("AperturePhoto.png")
	backSprite2:addChild(Guangsp2)
	Guangsp2:setScale(1.3)
	Guangsp2:setPosition(backSprite2:getContentSize().width/2,backSprite2:getContentSize().height-Guangsp2:getContentSize().width/2)
	self.Guangsp2=Guangsp2

	local sbYaoshi = CCSprite:createWithSpriteFrameName("acPjhz_yaoshi.png")
	backSprite2:addChild(sbYaoshi)
	sbYaoshi:setScale(0.7)
	sbYaoshi:setPosition(backSprite2:getContentSize().width/2,backSprite2:getContentSize().height-Guangsp1:getContentSize().width/2+10)

	local lbSize2=25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        lbSize2 =30
    end
	local nameStr = reward[1].name
	local nameLb = GetTTFLabel(nameStr,lbSize2)
	sbYaoshi:addChild(nameLb)
	nameLb:setAnchorPoint(ccp(0.5,1))
	nameLb:setPosition(sbYaoshi:getContentSize().width/2, -20)
	nameLb:setColor(G_ColorYellowPro)

	if(G_isIphone5())then
		nameLb:setPosition(sbYaoshi:getContentSize().width/2, -60)
	end

	local desStr = getlocal(reward[1].desc)
	local desTv, desLabel = G_LabelTableView(desTvSize,desStr,22,kCCTextAlignmentLeft)
	backSprite2:addChild(desTv)
	desTv:setPosition(ccp(20,backSprite2:getContentSize().height/2-70))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(60)


	local goSendItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchMenu,3,getlocal("activity_peijianhuzeng_gosend"),25)
	-- goSendItem:setAnchorPoint(ccp(0.5,0))
	goSendItem:setScale(0.9)
	local goSendBtn=CCMenu:createWithItem(goSendItem);
	goSendBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	goSendBtn:setPosition(ccp(G_VisibleSizeWidth/2,57))
	self.bgLayer:addChild(goSendBtn)
	self.item3 = goSendItem

	-- self.item 1 右，2 左 3，下

	self:checkEnable()

end

function acPeijianhuzengDialog:checkEnable()
	local flag1 = acPeijianhuzengVoApi:isReceive(1)
	local flag2 = acPeijianhuzengVoApi:isReceive(2)
	local alreadyCost = acPeijianhuzengVoApi:getAleadyCost()
	local cost1 = acPeijianhuzengVoApi:getCost(1)
	local cost2 = acPeijianhuzengVoApi:getCost(2)
	-- 左按钮item2
	if flag1 then
		self.item2:setEnabled(false)
		self.item2:setVisible(false)
		self.alreadyLb2:setVisible(true)
		self.Guangsp2:setVisible(false)
	else
		if alreadyCost>=cost1 then
			self.item2:setEnabled(true)
			self.Guangsp2:setVisible(true)
		else
			self.item2:setEnabled(false)
			self.Guangsp2:setVisible(false)
		end
		self.item2:setVisible(true)
		self.alreadyLb2:setVisible(false)
	end

	-- 右按钮item1
	if flag2 then
		self.item1:setEnabled(false)
		self.item1:setVisible(false)
		self.alreadyLb1:setVisible(true)
		self.Guangsp1:setVisible(false)
	else
		if alreadyCost>=cost2 then
			self.item1:setEnabled(true)
			self.Guangsp1:setVisible(true)
		else
			self.item1:setEnabled(false)
			self.Guangsp1:setVisible(false)
		end
		self.alreadyLb1:setVisible(false)
		self.item1:setVisible(true)
	end

	-- 下按钮item3
	-- if flag2 then
	-- 	self.item3:setEnabled(true)
	-- else
	-- 	self.item3:setEnabled(false)
	-- end
	local id = tonumber(RemoveFirstChar(self.reward[2].key))
	local num = bagVoApi:getItemNumId(id)
	if num~=0 then
		self.item3:setEnabled(true)
	else
		
		self.item3:setEnabled(false)
	end

end

function acPeijianhuzengDialog:updateAcTime()
    local acVo=acPeijianhuzengVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acPeijianhuzengDialog:tick()
    local vo=acPeijianhuzengVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    self:updateAcTime()
end

function acPeijianhuzengDialog:dispose()
	self.item1=nil
	self.item2=nil
	self.item3=nil
	self.alreadyLb1=nil
	self.alreadyLb2=nil
	self.reward=nil
	self.Guangsp2=nil
	self.Guangsp1=nil
	self.timeLb=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acPeijianhuzeng.plist")
end