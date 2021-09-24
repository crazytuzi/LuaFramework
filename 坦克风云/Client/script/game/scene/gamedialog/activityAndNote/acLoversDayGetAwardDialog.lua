acLoversDayGetAwardDialog=smallDialog:new()

function acLoversDayGetAwardDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
	self.lotsAward=nil
	self.particleS ={}
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acLoversDayGetAwardDialog:init(callbackSure)

	local strSize2 = 24
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =30
	end
	-- local curBei = acLuckyPokerVoApi:getIsTen()
	self.dialogWidth=560
	self.dialogHeight=350
	local downHeight=260
	self.isTouch=nil
	local isHasNbAward = false
	local unSortTb = {}
	self.lotsAward =acLoversDayVoApi:getCurReward()------取配置奖励库
	print("self.lotsAward num------->",#self.lotsAward)
	local key="p3348"
    local type="p"
    local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
    local oldnum,pointIndex,num=acLoversDayVoApi:getCurAwardPoint()
    local item={type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=oldnum}
    table.insert(self.lotsAward,item)
    -- local numLb=GetTTFLabel(getlocal("propInfoNum",{num}),25)
    -- local icon,scale=G_getItemIcon(item,100,true,self.layerNum+1)
    -- icon:setAnchorPoint(ccp(0,0.5))
    -- icon:setTouchPriority(-(self.layerNum-1)*20-5)
    -- icon:setPosition(ccp(20,backSprie:getContentSize().height/2+numLb:getContentSize().height/2+5))
    -- backSprie:addChild(icon)
    -- numLb:setAnchorPoint(ccp(0,1))
    -- numLb:setPosition(0,-10)
    -- numLb:setScale(1/scale)
    -- icon:addChild(numLb)
    -- self.numLb=numLb

    local isTen = false
	local addW = 110
	local addH = 130
	local function nilFunc() end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	-- self.bgLayer:setPosition(ccp(self.bgLayer:getPositionX(),self.bgLayer:getPositionY()-200))
	local strSize3 = 15
	if G_getCurChoseLanguage() =="cn" then
		strSize3 = 20
	end
	--activity_refitPlanT99_bigRewardRateAdd
	if (oldnum == 100 and pointIndex-1 == 0) or oldnum > 100 then
		local discountIcon=CCSprite:createWithSpriteFrameName("monthlysignFreeVip.png")
        discountIcon:setAnchorPoint(ccp(1,1))
        discountIcon:setScale(2)
        -- discountIcon:setRotation(-125)
        discountIcon:setFlipX(true)
        discountIcon:setPosition(ccp(self.dialogWidth+5,self.dialogHeight+5))
        self.bgLayer:addChild(discountIcon)
        local discountLb=GetTTFLabel("10"..getlocal("activity_refitPlanT99_bigRewardRateAdd"),strSize3)
        -- discountLb:setColor(G_ColorYellowPro)
        discountLb:setAnchorPoint(ccp(0.5,0.5))
        discountLb:setRotation(43)
        discountLb:setPosition(discountIcon:getContentSize().width/2+14,discountIcon:getContentSize().height/2+13)
        discountIcon:addChild(discountLb) 

        local moveTo1 = CCMoveBy:create(0.5,ccp(-10,-10))
        local scale1 = CCScaleTo:create(0.5,1.5)
        local acArr=CCArray:create()
        acArr:addObject(moveTo1)
        acArr:addObject(scale1)
        local spawn = CCSpawn:create(acArr)
        -- local seq=CCSequence:createWithTwoActions(moveTo1,scale1)

        discountIcon:runAction(spawn)
        isTen = true
	end


	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight))
	self.bgLayer:addChild(spriteTitle,1)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight))
	self.bgLayer:addChild(spriteTitle1,1)

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeInfor:setScale(1.2)
	spriteShapeInfor:setOpacity(200)
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeInfor:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight))
    self.bgLayer:addChild(spriteShapeInfor)

    local sortNumScaleTb = {0.5,0.38,0.25,0.2}
    local biganScale = sortNumScaleTb[#self.lotsAward]
    
    isSameP = 0
    for k,v in pairs(self.lotsAward) do
    	if v.key == "p3348" then
    		isSameP = isSameP + 1
    		if isSameP == 2 then
	    		isSameP = k
	    	end
    	end
    	
    end
    print("isSameP------>",isSameP)
    for k,v in pairs(self.lotsAward) do
    	if isSameP > 1 and v.key =="p3348" and k ~= isSameP then
    		do break end
    	end
    	local icon,iconScale = G_getItemIcon(v,90,true,self.layerNum,nil,nil)
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        icon:setAnchorPoint(ccp(0.5,0))
        local posW = self.dialogWidth*biganScale*k+(k-1)
        if #self.lotsAward ==2 and k ==2 then
        	posW = self.dialogWidth*(1-biganScale)
        end
        icon:setPosition(ccp(posW,120))
        self.bgLayer:addChild(icon)
        -- local useNun = isTen ==true and v.num/10 or v.num
        local useNun = v.num
        local num = GetTTFLabel("x"..useNun,25/iconScale)
        num:setAnchorPoint(ccp(1,0))
        num:setPosition(icon:getContentSize().width-5,5)
        icon:addChild(num)
    end

    bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp:setAnchorPoint(ccp(0.5,0.5))
	bgSp:setPosition(ccp(self.dialogWidth*0.5,downHeight-5));
	bgSp:setScaleY(50/bgSp:getContentSize().height)
	bgSp:setOpacity(200)
	bgSp:setScaleX((self.dialogWidth+50)/bgSp:getContentSize().width)
	self.bgLayer:addChild(bgSp)

	local luckyStr = GetTTFLabel(getlocal("activity_loversDay_mateNumDes2",{pointIndex-1}),strSize2)
    luckyStr:setAnchorPoint(ccp(0.5,0.5))
    luckyStr:setColor(G_ColorYellowPro)
    luckyStr:setPosition(ccp(self.dialogWidth*0.5,downHeight-5))
    self.bgLayer:addChild(luckyStr)

    -- local pointBg = LuaCCScale9Sprite:createWithSpriteFrameName("yellowSmallBorder.png",CCRect(10, 10, 1, 1),function ()end)
    -- pointBg:setAnchorPoint(ccp(0.5,1))
    -- pointBg:setPosition(self.dialogWidth*0.5,downHeight-25)
    -- self.bgLayer:addChild(pointBg)
    
    
    -- local matePointStr = GetTTFLabel(getlocal("activity_loversDay_mateNumDes2",{pointIndex-1}),22)
    -- matePointStr:setAnchorPoint(ccp(0,0.5))
    -- matePointStr:setColor(G_ColorYellowPro)
    -- pointBg:addChild(matePointStr)
    

    -- local matePic = CCSprite:createWithSpriteFrameName("txjIcon.png")
    -- matePic:setAnchorPoint(ccp(0,0.5))
    -- matePic:setScale(0.4)
    -- pointBg:addChild(matePic)
    -- local useHeight = G_isIphone5() ==true and 35 or 30
    -- pointBg:setContentSize(CCSizeMake(matePointStr:getContentSize().width+matePic:getContentSize().width*0.4+10,useHeight))
    -- matePointStr:setPosition(ccp(5,pointBg:getContentSize().height*0.5))
    -- matePic:setPosition(ccp(matePointStr:getContentSize().width+5,pointBg:getContentSize().height*0.5))


	local function close()
		print("close()---------")
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
			else
				checkBorder:setVisible(false)
			end
		end
	end

	 --确定
    local function sureHandler()
    	-- print("sureHandler--------")
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if callbackSure ~=nil then
			-- print("callbackSure------~~~~~")
			callbackSure()
		end
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,55))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local function nilFunc() end
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

function acLoversDayGetAwardDialog:dispose()
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
	self.lotsAward =nil
end

function acLoversDayGetAwardDialog:close()
	-- self:removeParticles()
	-- acLuckyPokerVoApi:setAllAwardTb()
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.lotsAward=nil
	self.particleS =nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    base:removeFromNeedRefresh(self)
end