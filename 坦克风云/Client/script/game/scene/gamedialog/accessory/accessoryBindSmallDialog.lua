--配件绑定的小面板
accessoryBindSmallDialog=smallDialog:new()

function accessoryBindSmallDialog:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=600
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		nc.dialogHeight=700
	else
		nc.dialogHeight=800
	end
	nc.tankID=tankID
	nc.partID=partID
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	return nc
end

function accessoryBindSmallDialog:init(layerNum)
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
	local closeBtn = CCMenu:createWithItem(closeBtnItem)
	closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("bindText"),32)
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 45))
	dialogBg:addChild(titleLb,1)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	self:initContent()

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function accessoryBindSmallDialog:initContent()
	local upBg=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	upBg:setScale((self.dialogWidth - 12)/upBg:getContentSize().width)
	upBg:setPosition(self.dialogWidth/2,self.dialogHeight - 210)
	self.bgLayer:addChild(upBg)
	local iconBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
	iconBg:setPosition(120,self.dialogHeight - 210)
	self.bgLayer:addChild(iconBg)
	local icon=accessoryVoApi:getAccessoryIcon(self.data.type,70,100)
	icon:setPosition(120,self.dialogHeight - 210)
	self.bgLayer:addChild(icon)
	local nameLb=GetTTFLabelWrap(getlocal(self.data:getConfigData("name")),25,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	nameLb:setAnchorPoint(ccp(0.5,1))
	local posX,posY=icon:getPosition()
	nameLb:setPosition(posX,posY - icon:getContentSize().height/2 - 10)
	self.bgLayer:addChild(nameLb)
	posX=215
	posY=self.dialogHeight - 140
	local titleLb=GetTTFLabel(getlocal("accessory_attChange"),28)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(posX,posY)
	self.bgLayer:addChild(titleLb)
	local bindAtt=self.data:getBindAtt()
	local attTb=self.data:getAttWithSuccinct()
	local attEffectTb=accessoryCfg.attEffect
	local attStrTb={}
	posY=posY - 35
	for k,v in pairs(bindAtt) do
		local effectStr
		if(attEffectTb[k]==1)then
			effectStr=string.format("%.2f",attTb[k]).."%%"
		else
			effectStr=attTb[k]
		end
		local attStr=getlocal("accessory_attAdd_"..k,{effectStr})
		local attLb=GetTTFLabel(attStr,25)
		attLb:setAnchorPoint(ccp(0,0.5))
		attLb:setPosition(posX,posY)
		self.bgLayer:addChild(attLb)

		if(attEffectTb[k]==1)then
			effectStr=string.format("%.2f",v).."%"
		else
			effectStr=v
		end
		local attUp=GetTTFLabel("↑ +"..effectStr,25)
		attUp:setColor(G_ColorGreen)
		attUp:setAnchorPoint(ccp(0,0.5))
		attUp:setPosition(posX + attLb:getContentSize().width + 20,posY)
		self.bgLayer:addChild(attUp)
		posY=posY - 30
	end
	posY=self.dialogHeight - 345
	local descLb=GetTTFLabelWrap(getlocal("accessory_bind_att"),25,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	descLb:setColor(G_ColorYellowPro)
	descLb:setAnchorPoint(ccp(0.5,1))
	descLb:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(descLb)
	posY=posY - descLb:getContentSize().height
	local warningLb=GetTTFLabelWrap(getlocal("backstage9042"),25,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	warningLb:setColor(G_ColorRed)
	warningLb:setAnchorPoint(ccp(0.5,1))
	warningLb:setPosition(self.dialogWidth/2,posY)
	self.bgLayer:addChild(warningLb)
	posY=posY - warningLb:getContentSize().height - 10
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(lineSp)
	posY=posY - 10
	local goldSp=CCSprite:createWithSpriteFrameName("resourse_normal_gem.png")
	goldSp:setPosition(self.dialogWidth/2,posY - 50)
	self.bgLayer:addChild(goldSp)
	local goldLb=GetTTFLabel(FormatNumber(playerVoApi:getGems()).." / "..accessoryCfg.bandGems,25)
	if(playerVoApi:getGems()>=accessoryCfg.bandGems)then
		goldLb:setColor(G_ColorGreen)
	else
		goldLb:setColor(G_ColorRed)
	end
	goldLb:setPosition(self.dialogWidth/2,posY - 115)
	self.bgLayer:addChild(goldLb)
	local function onBind()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:bind()
	end
	local bindItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onBind,nil,getlocal("bindText"),25)
	local bindBtn=CCMenu:createWithItem(bindItem)
	bindBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	bindBtn:setPosition(self.dialogWidth/2,60)
	self.bgLayer:addChild(bindBtn)
end

function accessoryBindSmallDialog:bind()
	local canBind=accessoryVoApi:checkCanBind(self.tankID,self.partID)
	if(canBind==3)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9041"),30)
		do return end
	end
	if(playerVoApi:getGems()>=accessoryCfg.bandGems)then
		local function callback()
			playerVoApi:setGems(playerVoApi:getGems() - accessoryCfg.bandGems)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
			self:close()
		end
		local function onConfirm()
			accessoryVoApi:bind(self.tankID,self.partID,callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("backstage9042")..getlocal("continue_confirm"),nil,self.layerNum+1)
	else
		GemsNotEnoughDialog(nil,nil,accessoryCfg.bandGems - playerVoApi:getGems(),self.layerNum + 1,accessoryCfg.bandGems)
	end
end