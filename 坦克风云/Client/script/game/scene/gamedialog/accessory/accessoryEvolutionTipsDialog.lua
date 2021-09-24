--配件突破tips面板
accessoryEvolutionTipsDialog=smallDialog:new()

function accessoryEvolutionTipsDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=580
	nc.dialogHeight=450
	return nc
end

function accessoryEvolutionTipsDialog:init(layerNum,subTitle,content)
	local strSize2 = 20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
		strSize2 =25
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
	
	local titleLb=GetTTFLabel(getlocal("dialog_title_prompt"),35)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)


	local subTitleLb=GetTTFLabel(subTitle,30)
	subTitleLb:setAnchorPoint(ccp(0,1))
	subTitleLb:setPosition(ccp(30,self.dialogHeight-titleLb:getContentSize().height-60))
	dialogBg:addChild(subTitleLb,1)
	subTitleLb:setColor(G_ColorYellowPro)

	local contentLb=GetTTFLabelWrap(content,strSize2,CCSizeMake(500,1000),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	contentLb:setAnchorPoint(ccp(0,1))
	contentLb:setPosition(ccp(30,self.dialogHeight-titleLb:getContentSize().height-50-subTitleLb:getContentSize().height-20))
	dialogBg:addChild(contentLb,1)

	local maskBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function ()end)
	maskBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(self.dialogWidth-20,self.dialogHeight-190)
	maskBg:setContentSize(rect)
	-- maskBg:setOpacity(180)
	maskBg:setAnchorPoint(ccp(0.5,1))
	maskBg:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-90))
	dialogBg:addChild(maskBg)


	local dataKey="accessoryEvolutionTips@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	local function onClick( ... )
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		
		if self.isNoticeSp then
			if self.isNoticeSp:isVisible()==true then
				self.isNoticeSp:setVisible(false)
				CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,0)
		        CCUserDefault:sharedUserDefault():flush()
			else
				self.isNoticeSp:setVisible(true)
				CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,1)
		        CCUserDefault:sharedUserDefault():flush()
			end
		end
	end
	local isNoticeBg=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onClick)
    isNoticeBg:setTouchPriority(-(self.layerNum-1)*20-4)
    isNoticeBg:setPosition(ccp(170,60))
    dialogBg:addChild(isNoticeBg,2)
    self.isNoticeSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    self.isNoticeSp:setPosition(ccp(170,60))
    dialogBg:addChild(self.isNoticeSp,3)
    local localData=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
    if localData==1 then
    	self.isNoticeSp:setVisible(true)
	else
		self.isNoticeSp:setVisible(false)
	end
	local isNoticeLb=GetTTFLabelWrap(getlocal("accessory_evolution_not_notice"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	isNoticeLb:setAnchorPoint(ccp(0,0.5))
	isNoticeLb:setPosition(ccp(170+isNoticeBg:getContentSize().width/2+15,60))
	dialogBg:addChild(isNoticeLb,3)


	-- local function sureHandler()
 --        if G_checkClickEnable()==false then
 --            do
 --                return
 --            end
 --        else
 --            base.setWaitTime=G_getCurDeviceMillTime()
 --        end
 --        PlayEffect(audioCfg.mouseClick)
 --        self:close()
 --    end
 --    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
 --    local sureMenu=CCMenu:createWithItem(sureItem)
 --    sureMenu:setPosition(ccp(self.dialogWidth/2,60))
 --    sureMenu:setTouchPriority(-(layerNum-1)*20-5)
 --    self.bgLayer:addChild(sureMenu)


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

function accessoryEvolutionTipsDialog:dispose()
	self.isNoticeSp=nil
end