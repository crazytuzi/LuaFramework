acAccessoryUpgradeDialog=commonDialog:new()

function acAccessoryUpgradeDialog:new(parent,layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.parent=parent
	self.layerNum=layerNum
	self.dec1=nil
	self.dec2=nil
	self.tbLb=nil
	self.tbLbDec=nil
	self.downPic=nil
	self.isToday=nil
	self.version =acAccessoryUpgradeVoApi:getVersion()
	return nc
end

function acAccessoryUpgradeDialog:initTableView()
	self.isToday=acAccessoryUpgradeVoApi:isToday()
	if self.version ~=nil and (self.version ==2 or self.version ==3 )then
		self.dec1=getlocal("activity_accessoryEvolution_descB")
		self.dec2=getlocal("activity_accessoryEvolution_detail2B")
		self.tbLb=getlocal("sample_prop_name_884")
		self.tbLbDec=getlocal("sample_prop_des_884")
		self.downPic="item_developmentBox.png"
	else
		self.dec1=getlocal("activity_accessoryEvolution_desc")
		self.dec2=getlocal("activity_accessoryEvolution_detail2")
		self.tbLb=getlocal("sample_prop_name_96")
		self.tbLbDec=getlocal("sample_prop_des_96")
		self.downPic="resourse_normal_gold.png"
	end		
	self:initUp()
	self:initUpgrade()
	self:initMoneyBuy()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
end

function acAccessoryUpgradeDialog:initUp()
	local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabel(acAccessoryUpgradeVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-128))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
	self:updateAcTime()
	
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
	local girlDesc=GetTTFLabelWrap(self.dec1,23,CCSizeMake(girlDescBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
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

	local function showInfo()
		local tabStr={"\n",self.dec2,self.tbLb,"\n",getlocal("activity_accessoryEvolution_detail1"),getlocal("activity_accessoryEvolution_title1"),"\n"};
		local tabColor={nil,G_ColorWhite,G_ColorGreen,nil,G_ColorWhite,G_ColorGreen,nil}
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,(G_VisibleSizeHeight-85+girlImg:getPositionY()+girlImg:getContentSize().height)/2));
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(infoBtn)

	self.panelLineBg:setVisible(false)
end

function acAccessoryUpgradeDialog:initUpgrade()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/4))
	background:setAnchorPoint(ccp(0.5,1))
	background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+45))

	local bgSize=background:getContentSize()

	local chestIcon=GetBgIcon("mainBtnAccessory.png",nil,nil,80,100)
	chestIcon:setPosition(70,bgSize.height/2)
	background:addChild(chestIcon)

	local iconSize=CCSizeMake(100,100)

	local chestName=GetTTFLabel(getlocal("activity_accessoryEvolution_title1"),28)
	chestName:setAnchorPoint(ccp(0,0.5))
	chestName:setPosition(ccp(chestIcon:getPositionX()-iconSize.width/2,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)

	local chestDesc=GetTTFLabelWrap(getlocal("activity_accessoryEvolution_desc1"),23,CCSizeMake(440, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestDesc:setPosition(ccp(140,bgSize.height/2+55))
	chestDesc:setAnchorPoint(ccp(0,1))
	background:addChild(chestDesc)

	local function onGotoAccessory()
		if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
		else
			self.parent:close()
			self:close()
			local function onShowAccessory()
				accessoryVoApi:showAccessoryDialog(sceneGame,3)
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
	local upgSize = 21
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		upgSize = 25
	end
	local upgradeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGotoAccessory,2,getlocal("activity_accessoryEvolution_gotoUpgrade"),upgSize)
	upgradeItem:setAnchorPoint(ccp(1,0))
	local upgradeBtn=CCMenu:createWithItem(upgradeItem)
	upgradeBtn:setAnchorPoint(ccp(1,0))
	upgradeBtn:setPosition(ccp(bgSize.width-10,5))
    upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	background:addChild(upgradeBtn)
	self.bgLayer:addChild(background,2)
end

function acAccessoryUpgradeDialog:initMoneyBuy()
	local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =23
    end
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/4))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,30))

	local bgSize=background:getContentSize()

	local chestIcon=CCSprite:createWithSpriteFrameName(self.downPic)
	chestIcon:setPosition(70,bgSize.height/2)
	if self.version==1 or self.version ==nil then
		local numLb=GetTTFLabel("x"..FormatNumber(30000000),20)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(ccp(95,5))
		chestIcon:addChild(numLb)
	end
	background:addChild(chestIcon)

	local iconSize=CCSizeMake(100,100)

	local chestName=GetTTFLabel(self.tbLb,28)
	chestName:setAnchorPoint(ccp(0,0.5))
	chestName:setPosition(ccp(chestIcon:getPositionX()-iconSize.width/2,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	chestName:setColor(G_ColorGreen)
	background:addChild(chestName)
	self.buyTimeLb=GetTTFLabel("("..acAccessoryUpgradeVoApi:getTodayByTime().."/"..activityCfg.accessoryEvolution[self.version].serverreward.maxBuyTime..")",28)
	self.buyTimeLb:setAnchorPoint(ccp(0,0.5))
	self.buyTimeLb:setPosition(ccp(chestIcon:getPositionX()-iconSize.width/2+chestName:getContentSize().width+5,bgSize.height/2+(chestIcon:getPositionY()+iconSize.height/2)/2))
	background:addChild(self.buyTimeLb)

	local chestDesc=GetTTFLabelWrap(self.tbLbDec.."\n"..getlocal("activity_accessoryEvolution_buyLimit",{activityCfg.accessoryEvolution[self.version].serverreward.maxBuyTime}),strSize2,CCSizeMake(270, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	chestDesc:setAnchorPoint(ccp(0,1))
	chestDesc:setPosition(ccp(140,bgSize.height/2+55))
	background:addChild(chestDesc)

	local originPriceLb=GetTTFLabel(activityCfg.accessoryEvolution[self.version].serverreward.originPrice,25)
	originPriceLb:setAnchorPoint(ccp(0,0))
	originPriceLb:setPosition(ccp(450,118))
	background:addChild(originPriceLb)
	local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold:setAnchorPoint(ccp(0,0))
	iconGold:setPosition(ccp(originPriceLb:getPositionX()+originPriceLb:getContentSize().width,118))
	background:addChild(iconGold)
	local line = CCSprite:createWithSpriteFrameName("redline.jpg")
	line:setAnchorPoint(ccp(0,0))
	line:setScaleX((originPriceLb:getContentSize().width+iconGold:getContentSize().width+10)/line:getContentSize().width)
	line:setPosition(ccp(445,127))
	background:addChild(line,2)

	local nowPriceLb=GetTTFLabel(activityCfg.accessoryEvolution[self.version].serverreward.price,28)
	nowPriceLb:setAnchorPoint(ccp(0,0))
	nowPriceLb:setColor(G_ColorYellowPro)
	nowPriceLb:setPosition(ccp(450,85))
	background:addChild(nowPriceLb)
	local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold:setAnchorPoint(ccp(0,0))
	iconGold:setPosition(ccp(nowPriceLb:getPositionX()+nowPriceLb:getContentSize().width,85))
	background:addChild(iconGold)


	local function onBuyMoney()
		if(playerVoApi:getGems()<activityCfg.accessoryEvolution[self.version].serverreward.price)then
			local function buyGems()
                vipVoApi:showRechargeDialog(self.layerNum+1)
			end
			local num=tonumber(activityCfg.accessoryEvolution[self.version].serverreward.price)-playerVoApi:getGems()
			local smallD=smallDialog:new()
			smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{activityCfg.accessoryEvolution[self.version].serverreward.price,playerVoApi:getGems(),num}),nil,self.layerNum+1)
			do return end
		end
		if(acAccessoryUpgradeVoApi:getTodayByTime()>=activityCfg.accessoryEvolution[self.version].serverreward.maxBuyTime)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_discount_maxNum"),30)
			do return end
		end
		local function onConfirm()
			local function callback()
				self.buyTimeLb:setString("("..acAccessoryUpgradeVoApi:getTodayByTime().."/"..activityCfg.accessoryEvolution[self.version].serverreward.maxBuyTime..")")
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{self.tbLb}),30)
			end
			acAccessoryUpgradeVoApi:buyMoney(callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("island_sureBuy",{activityCfg.accessoryEvolution[self.version].serverreward.price,self.tbLb}),nil,self.layerNum+1)
	end
	local upgradeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onBuyMoney,2,getlocal("buy"),25)
	upgradeItem:setAnchorPoint(ccp(1,0))
	local upgradeBtn=CCMenu:createWithItem(upgradeItem)
	upgradeBtn:setAnchorPoint(ccp(1,0))
	upgradeBtn:setPosition(ccp(bgSize.width-10,10))
    upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	background:addChild(upgradeBtn)
	self.bgLayer:addChild(background,2)
end

function acAccessoryUpgradeDialog:tick()
	local today=acAccessoryUpgradeVoApi:isToday()
	if self.isToday~=today then
		self.isToday=today
		self.buyTimeLb:setString("("..acAccessoryUpgradeVoApi:getTodayByTime().."/"..activityCfg.accessoryEvolution[self.version].serverreward.maxBuyTime..")")
	end
	self:updateAcTime()
end

function acAccessoryUpgradeDialog:updateAcTime()
    local acVo=acAccessoryUpgradeVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end
