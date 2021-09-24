allianceWar2BidDialog=smallDialog:new()

function allianceWar2BidDialog:new(parent,cityID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=480
	self.dialogWidth=550

	self.parent=parent
	self.cityID=cityID
	return nc
end

function allianceWar2BidDialog:init(layerNum)
	self.layerNum=layerNum

	self.allianceFunds=allianceVoApi:getSelfAlliance().point

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
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local cityCfg=allianceWar2Cfg.city[self.cityID]
	local titleLb=GetTTFLabel(getlocal("allianceWar_bidTitle",{getlocal(cityCfg.name)}),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)

	local atLeastLb=GetTTFLabelWrap(getlocal("allianceWar2_signup_atLeast",{allianceWar2Cfg.minRegistrationFee}),25,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	atLeastLb:setPosition(ccp(self.dialogWidth/2,(self.dialogHeight-85+self.dialogHeight/2+30)/2+30-10))
	dialogBg:addChild(atLeastLb)
	atLeastLb:setColor(G_ColorYellowPro)

	self.moneyLb=GetTTFLabelWrap(getlocal("allianceWar_leftFundsNum",{allianceVoApi:getSelfAlliance().point}),25,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.moneyLb:setPosition(ccp(self.dialogWidth/2,(self.dialogHeight-85+self.dialogHeight/2+30)/2-30-10))
	dialogBg:addChild(self.moneyLb)

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
			self.moneyLb:setString(getlocal("allianceWar_leftFundsNum",{allianceVoApi:getSelfAlliance().point-tonumber(self.lastNumValue)}))
		end
	end
	self.lastNumValue="0"
	local centerPoint=ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height/2-30)--getCenterPoint(dialogBg)
	local numEditBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),nilFunc)
	numEditBoxBg:setContentSize(CCSize(120,60))
	local showLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),nilFunc)
	showLbBg:setContentSize(CCSize(120,60))
	showLbBg:setPosition(centerPoint)
	dialogBg:addChild(showLbBg)
	self.numShowLb=GetTTFLabel(self.lastNumValue,25)
	self.numShowLb:setPosition(getCenterPoint(showLbBg))
	showLbBg:addChild(self.numShowLb)
	local numEditBox
	numEditBox=CCEditBox:createForLua(CCSize(120,60),numEditBoxBg,nil,nil,callbackInput)
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
	numEditBoxBg2:setContentSize(CCSize(120,60))
	numEditBoxBg2:setTouchPriority(-(self.layerNum-1)*20-4)
	numEditBoxBg2:setOpacity(0)
	dialogBg:addChild(numEditBoxBg2)

	local nameStr=getlocal(cityCfg.name)
	local warTimeStr=allianceWar2VoApi:formatTimeStrByTb(allianceWar2VoApi.startWarTime[cityCfg.id])
	local timeLb=GetTTFLabelWrap(getlocal("allianceWar_signTimeDesc2",{nameStr,warTimeStr}),25,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setPosition(ccp(self.dialogWidth/2,(90+self.dialogHeight/2-30)/2-10))
	dialogBg:addChild(timeLb)

	local function onClickOK()
		PlayEffect(audioCfg.mouseClick)
		self:bid()
	end
	self.confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickOK,2,getlocal("allianceWar_bidTitle",{""}),25)
	local confirmBtn=CCMenu:createWithItem(self.confirmItem);
	confirmBtn:setPosition(ccp(self.dialogWidth/2,60))
	confirmBtn:setTouchPriority(-(layerNum-1)*20-2);
	dialogBg:addChild(confirmBtn)
		
	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function allianceWar2BidDialog:bid()
    -- if CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest")==1 then
    --     allianceWar2Cfg.minRegistrationFee=1
    -- end
	local bidFunds=tonumber(self.lastNumValue)
	if(bidFunds==nil or bidFunds<allianceWar2Cfg.minRegistrationFee)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_illegalFunds",{allianceWar2Cfg.minRegistrationFee}),30)
	else
		local function onBidCallback(result)
			if(result and self.parent)then
				self.parent:showCityInfo(self.cityID)
			end
			self:close()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_email_title9"),30)
		end
		allianceWar2VoApi:bid(bidFunds,self.cityID,onBidCallback)
	end
end

function allianceWar2BidDialog:createWithBuffId(buffId,layerNum,refCallback)
	local sd=allianceWar2BidDialog:new()
	sd:initWithBuffId(buffId,layerNum,refCallback)
	return sd

end
function allianceWar2BidDialog:initWithBuffId(buffId,layerNum,refCallback)
	self.isTouch=false
	self.isUseAmi=false
	local function touchHandler()
	
	end
	
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
	self.dialogLayer=CCLayer:create()
	
	self.bgLayer=dialogBg
	self.bgSize=CCSizeMake(550,600)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	
	local bid="b"..buffId
	local iconSp=CCSprite:createWithSpriteFrameName(allianceWar2Cfg.buffSkill[bid].icon)
	iconSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-90,self.bgLayer:getContentSize().height/2+70))
	self.bgLayer:addChild(iconSp)
	
    local nameLb=GetTTFLabelWrap(getlocal("buffName",{getlocal(allianceWar2Cfg.buffSkill[bid].name)}),26,CCSize(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0))
    nameLb:setPosition(ccp(self.bgSize.width/2,self.bgLayer:getContentSize().height/2+85))
	dialogBg:addChild(nameLb)
	
	local buffLv=tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])
	local lvLb=GetTTFLabel(getlocal("buffLv",{buffLv}),26)
	lvLb:setAnchorPoint(ccp(0,0.5))
	lvLb:setPosition(ccp(self.bgSize.width/2,self.bgLayer:getContentSize().height/2+50))
	dialogBg:addChild(lvLb)
	
	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height/2+70)
	lineSp:setScaleY(3)
	lineSp:setScaleX(0.5)
	self.bgLayer:addChild(lineSp)
	
	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height/2+20)
	lineSp:setScaleY(3)
	lineSp:setScaleX(0.5)
	self.bgLayer:addChild(lineSp)
	
	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    goldIcon:setPosition(ccp(130,150));
	self.bgLayer:addChild(goldIcon)

	local costLb=GetTTFLabel(allianceWar2Cfg.buffSkill[bid].cost,26)
	costLb:setAnchorPoint(ccp(0,0.5))
	costLb:setPosition(ccp(goldIcon:getPositionX()+goldIcon:getContentSize().width+5,goldIcon:getPositionY()))
	costLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(costLb)
	local rateStr=""
	local point1=ccp(0,0)
	local point2 = ccp(0,0)
	if tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])==allianceWar2Cfg.buffSkill[bid]["maxLv"] then

		rateStr=getlocal("technology_max_level",{""})
		point1=ccp(0.5,0.5)
		point2=ccp(self.bgLayer:getContentSize().width/2,goldIcon:getPositionY())
		goldIcon:setVisible(false)
		costLb:setVisible(false)
	else
		local per=tonumber(allianceWar2Cfg.buffSkill[bid]["probability"][buffLv+1])
		rateStr=getlocal("tip_succeedRate",{per})
		point1=ccp(0,0.5)
        point2=ccp(220,goldIcon:getPositionY())
	end
	
	local rateLb=GetTTFLabel(rateStr,25)
	rateLb:setAnchorPoint(point1)
	rateLb:setPosition(point2)
	
	
	self.bgLayer:addChild(rateLb)
	
    local contentLb=GetTTFLabelWrap(getlocal(allianceWar2Cfg.buffSkill[bid]["des"]),25,CCSize(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
   contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2-60))
	self.bgLayer:addChild(contentLb)


	local function touchLuaSpr()

	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);
	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	
	local function close()
			PlayEffect(audioCfg.mouseClick)
			return self:close()
		end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("upgradeBuild"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true);
	
	local oldLv=tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])
	local function okback()
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("technology_max_level",{""}),30)
	end
	local okBtn=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall.png",okback,1,getlocal("confirm"),25)
	local menuOkBtn=CCMenu:createWithItem(okBtn)
	menuOkBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
	menuOkBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(menuOkBtn,1)


	local function activation()
		if tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])==allianceWar2Cfg.buffSkill[bid]["maxLv"] then
			local str=getlocal("technology_max_level",{getlocal(allianceWar2Cfg.buffSkill[bid].name)})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
			do
				return
			end
		end
		if playerVoApi:getGems()<allianceWar2Cfg.buffSkill[bid].cost then
			local function jumpGemDlg()
                vipVoApi:showRechargeDialog(layerNum+2)
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,layerNum+1)

			do
				return
			end
		end


		local function callback(fn,data)
			if base:checkServerData(data)==true then
				local buffLv=tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])
				lvLb:setString(getlocal("buffLv",{buffLv}))
				
				local rateStr=""
				if tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])==allianceWar2Cfg.buffSkill[bid]["maxLv"] then
					rateStr=getlocal("technology_max_level",{""})
					okBtn:setVisible(true)
					rateLb:setAnchorPoint(ccp(0.5,0.5))
					rateLb:setPosition(ccp(self.bgSize.width/2,goldIcon:getPositionY()))
					goldIcon:setVisible(false)
					costLb:setVisible(false)
					self.activationBtn:setVisible(false)
				else
					local per=tonumber(allianceWar2Cfg.buffSkill[bid]["probability"][buffLv+1])
					rateStr=getlocal("tip_succeedRate",{per})

				end
				rateLb:setString(rateStr)

				local str=getlocal("buffSuccess")
				if buffLv==oldLv then
					str=getlocal("buffField")

				else
					oldLv=buffLv
				end
				
				
				local gems=playerVoApi:getGems()-allianceWar2Cfg.buffSkill[bid].cost
					playerVoApi:setGems(gems)
				if refCallback then
					refCallback()
				end
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)

			end
		end
		local resultcityID=allianceWar2VoApi:getTargetCity()
		local type=allianceWar2Cfg.city[resultcityID].type
		socketHelper:alliancewarnewBuybuff(bid,callback,type)
	end
	self.activationBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",activation,1,getlocal("upgradeBuild"),25)
	local menuActivationBtn=CCMenu:createWithItem(self.activationBtn)
	menuActivationBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
	menuActivationBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(menuActivationBtn,1)
	
	if tonumber(allianceWar2VoApi:getBattlefieldUser()[bid])==allianceWar2Cfg.buffSkill[bid]["maxLv"] then
		okBtn:setVisible(true)
		self.activationBtn:setVisible(false)
	else
		okBtn:setVisible(false)
		self.activationBtn:setVisible(true)
	end


end



