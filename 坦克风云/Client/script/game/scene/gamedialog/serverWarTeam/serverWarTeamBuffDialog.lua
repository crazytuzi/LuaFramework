--军团跨服战买buff的面板
serverWarTeamBuffDialog=smallDialog:new()
function serverWarTeamBuffDialog:new(buffID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550

	self.buffID=buffID
	return nc
end

function serverWarTeamBuffDialog:init(layerNum)
	self.isTouch=false
	self.isUseAmi=false
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgSize=CCSizeMake(550,600)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	
	local iconSp=CCSprite:createWithSpriteFrameName(serverWarTeamCfg.buffSkill[self.buffID].icon)
	iconSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-90,self.bgLayer:getContentSize().height/2+70))
	self.bgLayer:addChild(iconSp)
	
	local nameLb=GetTTFLabelWrap(getlocal("buffName",{getlocal(serverWarTeamCfg.buffSkill[self.buffID].name)}),26,CCSize(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	nameLb:setAnchorPoint(ccp(0,0))
	nameLb:setPosition(ccp(self.bgSize.width/2,self.bgLayer:getContentSize().height/2+85))
	dialogBg:addChild(nameLb)
	
	local buffLv=tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])
	
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

	local costLb=GetTTFLabel(serverWarTeamCfg.buffSkill[self.buffID].cost,26)
	costLb:setAnchorPoint(ccp(0,0.5))
	costLb:setPosition(ccp(goldIcon:getPositionX()+goldIcon:getContentSize().width+5,goldIcon:getPositionY()))
	costLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(costLb)
	local rateStr=""
	local point1=ccp(0,0)
	local point2 = ccp(0,0)
	if tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])==serverWarTeamCfg.buffSkill[self.buffID]["maxLv"] then
		rateStr=getlocal("technology_max_level",{""})
		point1=ccp(0.5,0.5)
		point2=ccp(self.bgLayer:getContentSize().width/2,goldIcon:getPositionY())
		goldIcon:setVisible(false)
		costLb:setVisible(false)
	else
		local per=tonumber(serverWarTeamCfg.buffSkill[self.buffID]["probability"][buffLv+1])
		rateStr=getlocal("tip_succeedRate",{per})
		point1=ccp(0,0.5)
        point2=ccp(220,goldIcon:getPositionY())
	end
	
	local rateLb=GetTTFLabel(rateStr,25)
	rateLb:setAnchorPoint(point1)
	rateLb:setPosition(point2)
	
	
	self.bgLayer:addChild(rateLb)
	
	local contentLb=GetTTFLabelWrap(getlocal(serverWarTeamCfg.buffSkill[self.buffID]["des"],{serverWarTeamCfg.buffSkill[self.buffID]["per"]*100}),25,CCSize(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
	
	local titleLb=GetTTFLabel(getlocal("activation"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true);
	
	local oldLv=tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])
	
	local function okback()
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("technology_max_level",{""}),30)
	end
	local okBtn=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall.png",okback,1,getlocal("confirm"),25)
	local menuOkBtn=CCMenu:createWithItem(okBtn)
	menuOkBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
	menuOkBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(menuOkBtn,1)


	local function activation()
		if tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])==serverWarTeamCfg.buffSkill[self.buffID]["maxLv"] then
			local str=getlocal("technology_max_level",{getlocal(serverWarTeamCfg.buffSkill[self.buffID].name)})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
			do return end
		end
		if serverWarTeamFightVoApi:getGems()<serverWarTeamCfg.buffSkill[self.buffID].cost then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_buyBuffError"),30)
			do return end
		end

		local function callback()
			local buffLv=tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])
			lvLb:setString(getlocal("buffLv",{buffLv}))				
			local rateStr=""
			if tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])==serverWarTeamCfg.buffSkill[self.buffID]["maxLv"] then
				rateStr=getlocal("technology_max_level",{""})
				okBtn:setVisible(true)
				rateLb:setAnchorPoint(ccp(0.5,0.5))
				rateLb:setPosition(ccp(self.bgSize.width/2,goldIcon:getPositionY()))
				goldIcon:setVisible(false)
				costLb:setVisible(false)
				self.activationBtn:setVisible(false)
			else
				local per=tonumber(serverWarTeamCfg.buffSkill[self.buffID]["probability"][buffLv+1])
				rateStr=getlocal("tip_succeedRate",{per})
			end
			rateLb:setString(rateStr)
			local str=getlocal("buffSuccess")
			if buffLv==oldLv then
				str=getlocal("buffField")
			else
				oldLv=buffLv
			end
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
		end
		serverWarTeamFightVoApi:buyBuff(self.buffID,callback)
	end
	self.activationBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",activation,1,getlocal("activation"),25)
	local menuActivationBtn=CCMenu:createWithItem(self.activationBtn)
	menuActivationBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
	menuActivationBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(menuActivationBtn,1)
	
	if tonumber(serverWarTeamFightVoApi:getBuffData()[self.buffID])==serverWarTeamCfg.buffSkill[self.buffID]["maxLv"] then
		okBtn:setVisible(true)
		self.activationBtn:setVisible(false)
	else
		okBtn:setVisible(false)
		self.activationBtn:setVisible(true)
	end
end