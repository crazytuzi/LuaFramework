acQuanmintankeSmallDialog=smallDialog:new()

function acQuanmintankeSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellHight=120
	return nc
end

-- mustReward 购买必给
-- getReward 抽奖抽出来的
function acQuanmintankeSmallDialog:init(isTouch,isuseami,layerNum,titleTb,bgSrc,dialogSize,bgRect,mustReward,getReward,btnStr,confirmCallback)
	local strHeight2 = 25
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strHeight2 =40
    end
	self.layerNum=layerNum

	self.dialogWidth=500
	self.dialogHeight=550
	self.isTouch=istouch
    self.isUseAmi=isuseami
    if bgSrc==nil then
    	bgSrc="TankInforPanel.png"
    end
    if dialogSize==nil then
    	dialogSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
    end
    if bgRect then
    	bgRect=CCRect(130, 50, 1, 1)
    end
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,bgRect,nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=dialogSize
	self.bgLayer:setContentSize(self.bgSize)
	-- self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.bgLayer:addChild(spriteTitle,1)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.bgLayer:addChild(spriteTitle1,1)

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeInfor.png");
	spriteShapeInfor:setScaleY(80/spriteShapeInfor:getContentSize().height)
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-40)
    dialogBg:addChild(spriteShapeInfor)

	local function nilFunc()
	end

	for k,v in pairs(titleTb) do
		local titleLb=GetTTFLabelWrap(v,25,CCSizeMake(dialogSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,dialogSize.height-90-(k-1)*180))
		self.bgLayer:addChild(titleLb,1)
		

		local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20, 20, 10, 10),nilFunc)
		bgSp:setContentSize(CCSizeMake(dialogSize.width, titleLb:getContentSize().height+20))
		bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,dialogSize.height-90-(k-1)*180));
		self.bgLayer:addChild(bgSp)

		-- local bgSp=CCSprite:createWithSpriteFrameName("HelpHeaderBg.png")
		-- bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,dialogSize.height-90-(k-1)*180));
		-- bgSp:setScaleY((titleLb:getContentSize().height+20)/bgSp:getContentSize().height)
		-- bgSp:setScaleX((dialogSize.width)/bgSp:getContentSize().width)
		-- self.bgLayer:addChild(bgSp)

		-- mustReward,getReward
		local reward 
		if k==1 then
			reward=mustReward[1]
		else
			reward=getReward[1]
		end
		local icon,scale=G_getItemIcon(reward,100,true,self.layerNum)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		icon:setPosition(dialogSize.width/2,dialogSize.height-90-(2*k-1)*90)
		self.bgLayer:addChild(icon)

		local numLb = GetTTFLabel("x" .. reward.num,25)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(icon:getContentSize().width-5,5)
		numLb:setScale(1/scale)
		icon:addChild(numLb,1)
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
		if(confirmCallback)then
			confirmCallback()
		end
        self:close()
    end
    local str
    if(btnStr)then
    	str=btnStr
    else
    	str=getlocal("confirm")
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,str,25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,65))
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

	self:show()


	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function acQuanmintankeSmallDialog:dispose()
	self.id = nil
	self.checkSp = nil
	self.item = nil
end