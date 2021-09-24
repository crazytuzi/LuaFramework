acThanksGivingSmallDialog=smallDialog:new()

function acThanksGivingSmallDialog:new(layerNum,id)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.id = id 
	self.layerNum=layerNum
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acThanksGivingSmallDialog:init(callbackSure,lotsAwardTb)
	self.dialogWidth=500
	self.dialogHeight=550
	self.isTouch=nil
	self.lotsAward=lotsAwardTb[self.id]
	local addW = 110
	local addH = 130
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

	local desLb = GetTTFLabelWrap(getlocal("activity_xiaofeisongli_small_des"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setPosition(dialogBg:getContentSize().width/2, self.dialogHeight-60)

	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	local function showHandler(hd,fn,idx)

		local checkBorder = nil
		local bgSp = nil
		for k,v in pairs(self.lotsAward) do
			bgSp = tolua.cast(dialogBg:getChildByTag(k),"CCSprite")
			checkBorder = tolua.cast(bgSp:getChildByTag(k),"CCSprite")
			if k ==idx then
				checkBorder:setVisible(true)
				acThanksGivingVoApi:setSureAward(self.id,idx)
			else
				checkBorder:setVisible(false)
			end
		end
	end
	for k,v in pairs(self.lotsAward) do
		local awidth = k%4
		if awidth==0 then
			awidth=4
		end
		local bgSp,scale = acThanksGivingVoApi:G_getItemIcon(v,100,true,self.layerNum,showHandler)
		bgSp:setTag(k)
		bgSp:setTouchPriority(-(self.layerNum-1)*20-2)		
		if k<5 then
			bgSp:setPosition(85+addW*(awidth-1), self.dialogHeight-150)
		else
			bgSp:setPosition(85+addW*(awidth-1), self.dialogHeight-150-160)
		end
		dialogBg:addChild(bgSp)

		local numLabel=GetTTFLabel("x"..v.num,21)
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(bgSp:getContentSize().width-5, 5)
		numLabel:setScale(1/scale)
		bgSp:addChild(numLabel,1)

		local function nilFunc()
		end
		local checkBorder = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),nilFunc)
		checkBorder:setContentSize(CCSizeMake(bgSp:getContentSize().width+2,bgSp:getContentSize().height+2))
		checkBorder:setAnchorPoint(ccp(1,0))
		checkBorder:setPosition(ccp(bgSp:getContentSize().width,0))
		bgSp:addChild(checkBorder,1)
		checkBorder:setTag(k)
		checkBorder:setVisible(false)

	end
	

	 --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
			
		callbackSure()
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local function nilFunc()
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)


	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function acThanksGivingSmallDialog:dispose()
	self.id = nil
	self.checkSp = nil
	self.item = nil
	self.lotsAward=nil
end