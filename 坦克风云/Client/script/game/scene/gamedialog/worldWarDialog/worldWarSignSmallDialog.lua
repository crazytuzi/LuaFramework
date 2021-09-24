--世界争霸报名面板
worldWarSignSmallDialog=smallDialog:new()

function worldWarSignSmallDialog:new(type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.type=type
	self.dialogWidth=550
	self.dialogHeight=740
	return nc
end

function worldWarSignSmallDialog:init(layerNum)
	local strSize2 = 25
	if G_getCurChoseLanguage() =="ru" then
		strSize2 =20
	end
	self.isTouch=nil
	self.layerNum=layerNum
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
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
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("world_war_signTitle",{getlocal("world_war_group_"..self.type)}),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local function onClickChest()
		worldWarVoApi:showRewardInfoDialog(self.layerNum+1,self.type - 1)
	end
	local boxName
	if(self.type==1)then
		boxName="SpecialBox.png"
	else
		boxName="silverBox.png"
	end
	local chestSp=LuaCCSprite:createWithSpriteFrameName(boxName,onClickChest)
	chestSp:setTouchPriority(-(self.layerNum-1)*20-2)
	chestSp:setScale(2)
	chestSp:setPosition(self.dialogWidth/2,self.dialogHeight - 200)
	dialogBg:addChild(chestSp,1)

	local goldSp1=CCSprite:createWithSpriteFrameName("iconGold5.png")
	goldSp1:setPosition(180,self.dialogHeight - 260)
	dialogBg:addChild(goldSp1,2)
	local goldSp21=CCSprite:createWithSpriteFrameName("iconGold3.png")
	goldSp21:setPosition(self.dialogWidth/2 - 30,self.dialogHeight - 260)
	dialogBg:addChild(goldSp21,2)
	local goldSp22=CCSprite:createWithSpriteFrameName("iconGold3.png")
	goldSp22:setPosition(self.dialogWidth/2 + 30,self.dialogHeight - 260)
	dialogBg:addChild(goldSp22,2)
	local goldSp3=CCSprite:createWithSpriteFrameName("iconGold6.png")
	goldSp3:setPosition(self.dialogWidth - 180,self.dialogHeight - 260)
	dialogBg:addChild(goldSp3,2)
	local goldSp4=CCSprite:createWithSpriteFrameName("iconGold5.png")
	goldSp4:setPosition(self.dialogWidth - 180,self.dialogHeight - 230)
	dialogBg:addChild(goldSp4)
	local goldSp5=CCSprite:createWithSpriteFrameName("iconGold6.png")
	goldSp5:setPosition(180,self.dialogHeight - 230)
	dialogBg:addChild(goldSp5)

	local rewardTip=GetTTFLabelWrap(getlocal("world_war_clickToViewReward"),strSize2,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	rewardTip:setColor(G_ColorGreen)
	rewardTip:setPosition(self.dialogWidth/2,self.dialogHeight - 315)
	dialogBg:addChild(rewardTip)

	local bgSize=CCSizeMake(self.dialogWidth - 60,300)
	local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function()end)
	descBg:setContentSize(bgSize)
	descBg:setPosition(self.dialogWidth/2,self.dialogHeight - 485)
	self.bgLayer:addChild(descBg)

	local titleBg=CCSprite:createWithSpriteFrameName("HelpHeaderBg.png")
	titleBg:setScaleX(bgSize.width/titleBg:getContentSize().width)
	titleBg:setScaleY(35/titleBg:getContentSize().height)
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(0,bgSize.height)
	descBg:addChild(titleBg)

	local titleLb=GetTTFLabel(getlocal("shuoming"),25)
	titleLb:setPosition(bgSize.width/2,bgSize.height - 15)
	descBg:addChild(titleLb)

	local descLbTb={}
	for i=1,3 do
		local str
		if(i==1)then
			str=getlocal("world_war_signDesc"..i,{playerVoApi:getRankName(worldWarCfg.signRank),getlocal("world_war_group_"..self.type)})
		elseif(i==3)then
			str=getlocal("world_war_signDesc"..i..self.type)
		else
			str=getlocal("world_war_signDesc"..i)
		end
		local lb=GetTTFLabelWrap(str,25,CCSizeMake(bgSize.width - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		table.insert(descLbTb,lb)
	end
	local function tvCallBack(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return 3
		elseif fn=="tableCellSizeForIndex" then
			local tmpSize=CCSizeMake(bgSize.width,descLbTb[idx+1]:getContentSize().height + 20)
			return  tmpSize
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local logo=CCSprite:createWithSpriteFrameName("ww_logo_"..self.type..".png")
			logo:setScale(0.6)
			logo:setPosition(50,(descLbTb[idx+1]:getContentSize().height + 20)/2)
			cell:addChild(logo)
			local lb=descLbTb[idx+1]
			lb:setPosition(100 + (bgSize.width - 100)/2,logo:getPositionY())
			cell:addChild(lb)
			local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
			lineSP:setAnchorPoint(ccp(0.5,0.5))
			lineSP:setScaleX(self.dialogWidth/lineSP:getContentSize().width)
			lineSP:setScaleY(1.2)
			lineSP:setPosition(ccp(self.dialogWidth/2,0))
			cell:addChild(lineSP,2)
			return cell
		elseif fn=="ccTouchBegan" then
			isMoved=false
			return true
		elseif fn=="ccTouchMoved" then
			isMoved=true
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(tvCallBack)
	local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgSize.width,bgSize.height - 35),nil)
	tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	tableView:setPosition(0,0)
	descBg:addChild(tableView)
	tableView:setMaxDisToBottomOrTop(50)

	local function onSign()
		local function onSignSuccess()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_onSign",{getlocal("world_war_group_"..self.type)}),30)
			self:close()
		end
		worldWarVoApi:signUp(self.type,onSignSuccess)
	end
	local signItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onSign,2,getlocal("allianceWar_sign"),25)
	local signBgn=CCMenu:createWithItem(signItem)
	signBgn:setPosition(self.dialogWidth/2,50)
	signBgn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(signBgn)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

--因为要释放图片，所以重写close方法
function worldWarSignSmallDialog:close()
	if self.isUseAmi~=nil and self.bgLayer~=nil then
		local function realClose()
			return self:realClose()
		end
		local fc= CCCallFunc:create(realClose)
		local scaleTo1=CCScaleTo:create(0.1, 1.1);
		local scaleTo2=CCScaleTo:create(0.07, 0.8);
		local acArr=CCArray:create()
		acArr:addObject(scaleTo1)
		acArr:addObject(scaleTo2)
		acArr:addObject(fc)
		local seq=CCSequence:create(acArr)
		self.bgLayer:runAction(seq)
	else
		self:realClose()
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/iconGoldImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/iconGoldImage.pvr.ccz")
end