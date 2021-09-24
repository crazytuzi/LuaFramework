acAccessoryFightDialog=commonDialog:new()

function acAccessoryFightDialog:new(parent,layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.parent=parent
	self.layerNum=layerNum
	return nc
end

function acAccessoryFightDialog:initTableView()
	self:initUp()
	self:initMiddle()
	self:initDown()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
end

function acAccessoryFightDialog:initUp()
	local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabel(acAccessoryFightVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-128))
	self.bgLayer:addChild(timeLb)
	
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+60))
	self.bgLayer:addChild(girlImg,2)
	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(410,(G_VisibleSizeHeight/2-85)*0.6-60))
	girlDescBg:setAnchorPoint(ccp(0,0))
	girlDescBg:setPosition(200,G_VisibleSizeHeight/2+90)
	self.bgLayer:addChild(girlDescBg,1)
	local girlDesc=GetTTFLabelWrap(getlocal("activity_accessoryFight_desc"),25,CCSizeMake(girlDescBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	girlDesc:setPosition(girlDescBg:getContentSize().width/2+50,girlDescBg:getContentSize().height/2)
	girlDescBg:addChild(girlDesc)

	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20, 20, 10, 10),function()end)
	titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,20))
	titleBg:setScaleX((G_VisibleSizeWidth-40)/titleBg:getContentSize().width)
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+60))
	self.bgLayer:addChild(titleBg,1)
	local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setAnchorPoint(ccp(0.5,0.5))
	lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
	lineSP:setScaleY(1.2)
	lineSP:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+60))
	self.bgLayer:addChild(lineSP,2)

	local function onGotoFight()
		if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
		else
			self.parent:close()
			self:close()
			local function onShowAccessory()
				accessoryVoApi:showSupplyDialog(3)
			end
			local callFunc=CCCallFunc:create(onShowAccessory)
			local delay=CCDelayTime:create(0.4)
			local acArr=CCArray:create()
			acArr:addObject(delay)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			sceneGame:runAction(seq)
		end
	end
	local fightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGotoFight,2,getlocal("accessory_title_2"),25)
	fightItem:setAnchorPoint(ccp(0.5,0))
	local fightBtn=CCMenu:createWithItem(fightItem)
	fightBtn:setAnchorPoint(ccp(0.5,0))
	fightBtn:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.panelLineBg:setVisible(false)
	self.bgLayer:addChild(fightBtn)
end

function acAccessoryFightDialog:initMiddle()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/4-40))
	background:setAnchorPoint(ccp(0.5,1))
	background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+45))

	local bgSize=background:getContentSize()

	local chestIcon=GetBgIcon("mainBtnAccessory.png",nil,nil,80,100)
	chestIcon:setScaleX(120/chestIcon:getContentSize().width)
	chestIcon:setScaleY(120/chestIcon:getContentSize().height)
	chestIcon:setPosition(90,bgSize.height/2)
	background:addChild(chestIcon)

	local iconSize=CCSizeMake(120,120)

	local chestName=GetTTFLabel(getlocal("activity_accessoryFight_title1"),28)
	chestName:setAnchorPoint(ccp(0,0.5))
	chestName:setPosition(ccp(chestIcon:getPositionX()-iconSize.width/2,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)

	local chestDesc=GetTTFLabelWrap(getlocal("activity_accessoryFight_desc1"),23,CCSizeMake(410, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestDesc:setAnchorPoint(ccp(0,1))
	chestDesc:setPosition(ccp(170,bgSize.height/2+50))
	background:addChild(chestDesc)
	local chestDesc2=GetTTFLabel((activityCfg.accessoryFight.serverreward.reducePrice*100).."%",35)
	chestDesc2:setAnchorPoint(ccp(0,1))
	chestDesc2:setPosition(ccp(200,chestDesc:getPositionY()-chestDesc:getContentSize().height-5))
	chestDesc2:setColor(G_ColorYellowPro)
	background:addChild(chestDesc2)

	self.bgLayer:addChild(background)
end

function acAccessoryFightDialog:initDown()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/4-40))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,110))

	local bgSize=background:getContentSize()

	local chestIcon=CCSprite:createWithSpriteFrameName("tech_fight_exp_up.png")
	chestIcon:setScaleX(120/chestIcon:getContentSize().width)
	chestIcon:setScaleY(120/chestIcon:getContentSize().height)
	chestIcon:setPosition(90,bgSize.height/2)
	background:addChild(chestIcon)

	local iconSize=CCSizeMake(120,120)

	local chestName=GetTTFLabel(getlocal("activity_accessoryFight_title2"),28)
	chestName:setAnchorPoint(ccp(0,0.5))
	chestName:setPosition(ccp(chestIcon:getPositionX()-iconSize.width/2,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)

	local chestDesc=GetTTFLabelWrap(getlocal("activity_accessoryFight_desc2"),23,CCSizeMake(410, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestDesc:setAnchorPoint(ccp(0,1))
	chestDesc:setPosition(ccp(170,bgSize.height/2+50))
	background:addChild(chestDesc)
	local chestDesc2=GetTTFLabel((activityCfg.accessoryFight.serverreward.powerAdd*100).."%",35)
	chestDesc2:setAnchorPoint(ccp(0,1))
	chestDesc2:setPosition(ccp(200,chestDesc:getPositionY()-chestDesc:getContentSize().height-5))
	chestDesc2:setColor(G_ColorYellowPro)
	background:addChild(chestDesc2)

	self.bgLayer:addChild(background)
end
