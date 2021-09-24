serverWarAllianceDetailDialog=smallDialog:new()

function serverWarAllianceDetailDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=500
	self.dialogHeight=600

	self.data=data
	return nc
end

function serverWarAllianceDetailDialog:init(layerNum)
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

	local serverName=""
	local name=""
	local leaderName=""
	local level=0
	local memNum=0
	local power=0
	if self.data then
		serverName=self.data.serverName or ""
		name=self.data.name or ""
		leaderName=self.data.commander or ""
		level=self.data.level or 0
		memNum=self.data.num or 0
		power=self.data.fight or 0
	end

    local lbSize=25
    local lbPosX=20
    local lbPosX1=self.bgSize.width/2-lbPosX
    local lbWidth=self.bgSize.width/2-40
    local lbWidth1=self.bgSize.width/2
    local hSpace=60
    local poxYSpace=10
    local lbTab={
        {getlocal("serverwar_server_name"),28,ccp(0,0.5),ccp(lbPosX,self.dialogHeight-hSpace*2-poxYSpace),self.bgLayer,1,G_ColorGreen,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {serverName,28,ccp(0,0.5),ccp(lbPosX1,self.dialogHeight-hSpace*2-poxYSpace),self.bgLayer,1,G_ColorGreen,CCSize(lbWidth1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

        {getlocal("alliance_scene_button_info_name"),lbSize,ccp(0,0.5),ccp(lbPosX,self.dialogHeight-hSpace*3-poxYSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {name,lbSize,ccp(0,0.5),ccp(lbPosX1,self.dialogHeight-hSpace*3-poxYSpace),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

        {getlocal("alliance_role2"),lbSize,ccp(0,0.5),ccp(lbPosX,self.dialogHeight-hSpace*4-poxYSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {leaderName,lbSize,ccp(0,0.5),ccp(lbPosX1,self.dialogHeight-hSpace*4-poxYSpace),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

        {getlocal("alliance_scene_level"),lbSize,ccp(0,0.5),ccp(lbPosX,self.dialogHeight-hSpace*5-poxYSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {"Lv. "..level,lbSize,ccp(0,0.5),ccp(lbPosX1,self.dialogHeight-hSpace*5-poxYSpace),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

        {getlocal("alliance_list_scene_number"),lbSize,ccp(0,0.5),ccp(lbPosX,self.dialogHeight-hSpace*6-poxYSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {memNum,lbSize,ccp(0,0.5),ccp(lbPosX1,self.dialogHeight-hSpace*6-poxYSpace),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

        {getlocal("city_info_power"),lbSize,ccp(0,0.5),ccp(lbPosX,self.dialogHeight-hSpace*7-poxYSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {power,lbSize,ccp(0,0.5),ccp(lbPosX1,self.dialogHeight-hSpace*7-poxYSpace),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTab) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

	for i=1,5 do
		local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-150-hSpace*i-poxYSpace))
		self.bgLayer:addChild(lineSp)
	end

	local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",close,2,getlocal("confirm"),25)
	confirmItem:setScale(0.9)
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setPosition(ccp(self.dialogWidth/2,60))
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