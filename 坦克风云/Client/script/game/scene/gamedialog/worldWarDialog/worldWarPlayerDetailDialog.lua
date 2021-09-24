worldWarPlayerDetailDialog=smallDialog:new()

function worldWarPlayerDetailDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=500
	self.dialogHeight=460

	self.data=data
	return nc
end

function worldWarPlayerDetailDialog:init(layerNum)
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
	
	local titleLb=GetTTFLabel(getlocal("playerInfo"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	if self.data.pic then
		--local personPhotoName="photo"..self.data.pic..".png"
		--local playerPic = GetBgIcon(personPhotoName)
        local personPhotoName=playerVoApi:getPersonPhotoName(self.data.pic)
        local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
		playerPic:setAnchorPoint(ccp(0,1))
		playerPic:setPosition(ccp(20,self.dialogHeight-100))
		dialogBg:addChild(playerPic,1)
	end

	local nameLb=GetTTFLabel(self.data.name,30)
	nameLb:setAnchorPoint(ccp(0,1))
	nameLb:setPosition(ccp(110,self.dialogHeight-95))
	nameLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(nameLb)

	local rank=tonumber(self.data.rank)
	if rank==nil or rank==0 then
		rank=1
	end
	local rankLb=GetTTFLabelWrap("Lv. "..self.data.level.." "..playerVoApi:getRankName(rank),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	rankLb:setAnchorPoint(ccp(0,0))
	rankLb:setPosition(ccp(110,self.dialogHeight-185))
	self.bgLayer:addChild(rankLb)

	local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-200))
	self.bgLayer:addChild(lineSp)

	local serverLb=GetTTFLabel(getlocal("server",{""}).."    "..self.data.serverName,25)
	serverLb:setAnchorPoint(ccp(0,0))
	serverLb:setPosition(ccp(20,self.dialogHeight-240))
	self.bgLayer:addChild(serverLb)

	lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-260))
	self.bgLayer:addChild(lineSp)

	local powerLb=GetTTFLabel(getlocal("player_message_info_power").."    "..self.data.power,25)
	powerLb:setAnchorPoint(ccp(0,0))
	powerLb:setPosition(ccp(20,self.dialogHeight-300))
	self.bgLayer:addChild(powerLb)

	lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleY(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-320))
	self.bgLayer:addChild(lineSp)

	local allianceName
	if self.data.allianceName and self.data.allianceName~="" then
		allianceName=getlocal("player_message_info_alliance").."    "..self.data.allianceName
	else
		allianceName=getlocal("player_message_info_alliance").."    "..getlocal("alliance_info_content")
	end
	local allianceLb=GetTTFLabel(allianceName,25)
	allianceLb:setAnchorPoint(ccp(0,0))
	allianceLb:setPosition(ccp(20,self.dialogHeight-360))
	self.bgLayer:addChild(allianceLb)

	local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",close,2,getlocal("confirm"),25)
	confirmItem:setScale(0.9)
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-410))
	confirmBtn:setTouchPriority(-(layerNum-1)*20-2)
	self.bgLayer:addChild(confirmBtn)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end