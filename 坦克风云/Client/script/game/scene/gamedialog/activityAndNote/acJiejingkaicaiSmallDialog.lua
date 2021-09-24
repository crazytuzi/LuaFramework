acJiejingkaicaiSmallDialog=smallDialog:new()

function acJiejingkaicaiSmallDialog:new(layerNum,selectFriendTb)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum
	self.cellHeight=72
	self.selectFriendTb=selectFriendTb
	self.selectVo = nil
	self.duiSpTb={}
	return nc
end

function acJiejingkaicaiSmallDialog:init(callback)
	self.dialogWidth=G_VisibleSizeWidth-60
	self.dialogHeight=500
	self.isTouch=nil
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

	local titleLb=GetTTFLabelWrap(getlocal("activity_jiejingkaicai_isOk"),30,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,1))
	titleLb:setColor(G_ColorRed)
	titleLb:setPosition(ccp(self.dialogWidth/2,self.bgLayer:getContentSize().height-40))
	self.bgLayer:addChild(titleLb)

	local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-40-titleLb:getContentSize().height-20))
	self.bgLayer:addChild(lineSp)

	local recentLb=GetTTFLabelWrap(getlocal("activity_jiejingkaicai_recentReward"),25,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    recentLb:setAnchorPoint(ccp(0,0.5))
	recentLb:setColor(G_ColorYellow)
	recentLb:setPosition(ccp(10,self.bgLayer:getContentSize().height-40-titleLb:getContentSize().height-20-40))
	self.bgLayer:addChild(recentLb)

	local item =  acJiejingkaicaiVoApi:getDajiang()

	local rewardLb=GetTTFLabelWrap(item.name,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardLb:setAnchorPoint(ccp(0,0.5))
	rewardLb:setPosition(ccp(170,self.bgLayer:getContentSize().height-40-titleLb:getContentSize().height-20-40))
	self.bgLayer:addChild(rewardLb)

	local iconSp = GetBgIcon(item.pic,nilFunc,nil,80,100)
	self.bgLayer:addChild(iconSp)
	iconSp:setPosition(self.bgLayer:getContentSize().width/2, 240)

	local numLb=GetTTFLabel("X" .. tostring(item.num),17)
	numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
	numLb:setAnchorPoint(ccp(1,0));
	iconSp:addChild(numLb)

	local function touchItem(tag)
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if tag==2 then
			self:close()
			return
		else
			callback()
			self:close()
			return
		end
	end


	local oneItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchItem,1,getlocal("activity_jiejingkaicai_sureLingqu"),25)
	oneItem:setAnchorPoint(ccp(0.5,0))
	local oneBtn=CCMenu:createWithItem(oneItem);
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	oneBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2-120,40))
	self.bgLayer:addChild(oneBtn)

	local tenItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchItem,2,getlocal("activity_jiejingkaicai_continueGame"),25)
	tenItem:setAnchorPoint(ccp(0.5,0))
	local tenBtn=CCMenu:createWithItem(tenItem);
	tenBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	tenBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+120,40))
	self.bgLayer:addChild(tenBtn)





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



function acJiejingkaicaiSmallDialog:dispose()

end


