acPjjnhSmallDialog=smallDialog:new()

function acPjjnhSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acPjjnhSmallDialog:init(isTouch,isuseami,layerNum,flag)
	local function touchDialog()
        
    end
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
	local capInSet1 = CCRect(10, 10, 1, 1)

	self.layerNum=layerNum
	self.isTouch=istouch
    self.isUseAmi=isuseami

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(500,220)
	self.bgLayer:setContentSize(self.bgSize)
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local spPic
	local desStr
	if flag==1 then
		spPic="BlueBoxRandom.png"
		desStr=getlocal("activity_pjjnh_small_des1")
	else
		spPic="friendBtn.png"
		if acPjjnhVoApi:getVersion() == 2 then
			desStr = getlocal("activity_pjjnh_small_des3")
		else
			desStr = getlocal("activity_pjjnh_small_des2")
		end
	end

	local spBg=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	spBg:setPosition(80,dialogBg:getContentSize().height/2)
	dialogBg:addChild(spBg)

	local sp = CCSprite:createWithSpriteFrameName(spPic)
	spBg:addChild(sp)
	sp:setScale(88/sp:getContentSize().width)
	sp:setPosition(spBg:getContentSize().width/2,spBg:getContentSize().height/2)

	local desName=GetTTFLabelWrap(desStr,25,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desName:setPosition(140,dialogBg:getContentSize().height/2)
    desName:setAnchorPoint(ccp(0,0.5));
    dialogBg:addChild(desName,2)
    desName:setColor(G_ColorYellowPro)


	local function nilFunc()
		PlayEffect(audioCfg.mouseClick)
        self:close()
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
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
