--在区域战向军团成员发送命令的面板
localWarCityOrderSmallDialog=smallDialog:new()

--param cityID: 城市ID, a1到a11
function localWarCityOrderSmallDialog:new(cityID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.cityID=cityID
	nc.data=localWarFightVoApi:getCity(cityID)
	nc.dialogWidth=550
	nc.explodeArr={}
	nc.dialogHeight=700
	return nc
end

function localWarCityOrderSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self.curOrder=1
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	local function eventListener(event,data)
		self:dealEvent(event,data)
	end
	self.eventListener=eventListener
	eventDispatcher:addEventListener("localWar.battle",eventListener)
	return self.dialogLayer
end

function localWarCityOrderSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
end

function localWarCityOrderSmallDialog:initContent()
	local title=GetTTFLabel(getlocal("local_war_command"),28)
	title:setColor(G_ColorYellowPro)
	title:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 50))
	self.bgLayer:addChild(title)

	local posY=self.dialogHeight - 80
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(lineSp)

	posY=posY - 80
	local cityIcon=CCSprite:createWithSpriteFrameName(self.data.cfg.icon)
	if(self.data.cfg.pos[1]>localWarMapScene.mapSize.width/2)then
		cityIcon:setFlipX(true)
	end
	cityIcon:setScale(120/cityIcon:getContentSize().height)
	cityIcon:setPosition(ccp(120,posY))
	self.bgLayer:addChild(cityIcon)

	local cityName=GetTTFLabel(getlocal("local_war_cityName_"..self.data.id),28)
	cityName:setPosition(ccp(350,posY + 20))
	self.bgLayer:addChild(cityName)

	local cityStatus
	if(self.data.allianceID==0)then
		cityStatus=GetTTFLabel(getlocal("state")..": "..getlocal("local_war_cityStatus2"),25)
	else
		local attackers=localWarFightVoApi:getAttackersInCity(self.data.id)
		if(#attackers>0)then
			cityStatus=GetTTFLabel(getlocal("state")..": "..getlocal("local_war_cityStatus1"),25)
			cityStatus:setColor(G_ColorRed)
		else
			cityStatus=GetTTFLabel(getlocal("state")..": "..getlocal("local_war_cityStatus3"),25)
		end
	end
	cityStatus:setPosition(ccp(350,posY - 20))
	self.bgLayer:addChild(cityStatus)

	posY=posY - 80
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,posY))
	self.bgLayer:addChild(lineSp)

	posY=posY - 20
	local function onCheck(object,name,tag)
		local orderIndex=math.floor(tag/100)
		if(orderIndex~=self.curOrder)then
			local curCheckBox1=tolua.cast(self.bgLayer:getChildByTag(self.curOrder*100 + 1),"CCSprite")
			curCheckBox1:setPositionX(999333)
			curCheckBox1:setVisible(false)
			local curCheckBox2=tolua.cast(self.bgLayer:getChildByTag(self.curOrder*100 + 2),"CCSprite")
			curCheckBox2:setPositionX(40)
			curCheckBox2:setVisible(true)
			local newCheckBox1=tolua.cast(self.bgLayer:getChildByTag(orderIndex*100 + 1),"CCSprite")
			newCheckBox1:setPositionX(40)
			newCheckBox1:setVisible(true)
			local newCheckBox2=tolua.cast(self.bgLayer:getChildByTag(orderIndex*100 + 2),"CCSprite")
			newCheckBox2:setPositionX(999333)
			newCheckBox2:setVisible(false)
			self.curOrder=orderIndex
		end
	end
	local function nilFunc()
	end
	for i=1,4 do
		local lb=GetTTFLabelWrap(getlocal("local_war_order"..i),22,CCSizeMake(self.dialogWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		lb:setAnchorPoint(ccp(0,1))
		lb:setPosition(ccp(80,posY))
		self.bgLayer:addChild(lb)

		local checkBox1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
		checkBox1:setTag(i*100 + 1)
		checkBox1:setTouchPriority(-(self.layerNum-1)*20-2)
		self.bgLayer:addChild(checkBox1)
		local checkBox2=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onCheck)
		checkBox2:setTag(i*100 + 2)
		checkBox2:setTouchPriority(-(self.layerNum-1)*20-2)
		self.bgLayer:addChild(checkBox2)
		local lbHeight=lb:getContentSize().height
		if(i==1)then
			checkBox1:setPosition(ccp(40,posY - lbHeight/2))
			checkBox2:setPosition(ccp(999333,posY - lbHeight/2))
			checkBox2:setVisible(false)
		else
			checkBox1:setPosition(ccp(999333,posY - lbHeight/2))
			checkBox1:setVisible(false)
			checkBox2:setPosition(ccp(40,posY - lbHeight/2))
		end
		local height=math.max(checkBox1:getContentSize().height,lbHeight)
		posY = posY - height - 10
	end
	local function onCancel()
		self:close()
	end
	local cancelItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onCancel,1,getlocal("cancel"),25)
	local cancelBtn=CCMenu:createWithItem(cancelItem)
	cancelBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	cancelBtn:setPosition(ccp(150,60))
	self.bgLayer:addChild(cancelBtn)
	local function onConfirm()
		if(localWarFightVoApi:checkBaseBlock())then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4202"),30)
			do return end
		end
		local function callback()
			self:close()
		end
		localWarFightVoApi:sendOrder(self.data.id,self.curOrder,callback)
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,1,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(ccp(self.dialogWidth - 150,60))
	self.bgLayer:addChild(okBtn)
end

function localWarCityOrderSmallDialog:dealEvent(event,data)
	if(data.type=="over")then
		self:close()
	end
end

function localWarCityOrderSmallDialog:dispose()
	eventDispatcher:removeEventListener("localWar.battle",self.eventListener)
end