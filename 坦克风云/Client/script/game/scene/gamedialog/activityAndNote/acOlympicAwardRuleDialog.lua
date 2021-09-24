acOlympicAwardRuleDialog = smallDialog:new()

function acOlympicAwardRuleDialog:new(layerNum)
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

	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acOlympicAwardRuleDialog:init(callbackSure)
	local strSize2 = 22
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =25
	end

	self.dialogWidth=560
	self.dialogHeight=770
	self.isTouch=nil
	self.lotsAward =acOlympicVoApi:getAwardAllTb( )

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

	local desLb = GetTTFLabelWrap(getlocal("super_weapon_challenge_reward_preview"),33,CCSizeMake(self.dialogWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setColor(G_ColorYellowPro)
	desLb:setPosition(dialogBg:getContentSize().width*0.5, self.dialogHeight-50)

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


	self:initTableView()
	 --确定
    local function sureHandler()
    	print("sureHandler--------")
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0.5))
	lineSp:setScale(0.95)
	lineSp:setPosition(ccp(self.dialogWidth*0.5,75+sureItem:getContentSize().height))
	dialogBg:addChild(lineSp)

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

function acOlympicAwardRuleDialog:initTableView( ... )

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	middleBg:setContentSize(CCSizeMake(self.dialogWidth-30,self.dialogHeight*0.7))
	middleBg:setAnchorPoint(ccp(0,0))
	middleBg:setPosition(ccp(15,150))
	middleBg:setOpacity(0)
	self.bgLayer:addChild(middleBg)

	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-30,self.dialogHeight*0.68),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(15,155))
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(120)
end

function acOlympicAwardRuleDialog:eventHandler(handler,fn,idx,cel)
   	local scoreShowTb = acOlympicVoApi:getScoreTb( )
	local strSize2 = 18
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =25
	end
   if fn=="numberOfCellsInTableView" then
	   	if #self.lotsAward >0 then
			return #self.lotsAward
		end
       return 1
   elseif fn=="tableCellSizeForIndex" then
	   	local cellHeightNum = math.ceil(#self.lotsAward[#self.lotsAward - idx]/2)
       return  CCSizeMake(self.dialogWidth-40,cellHeightNum*150)-- -130
   elseif fn=="tableCellAtIndex" then
       	local cell=CCTableViewCell:new()
	   	local cellHeightNum = math.ceil(#self.lotsAward[#self.lotsAward - idx]/2)
	   	local cellScoreNum = scoreShowTb[#scoreShowTb - idx]
       	local function touch( ) end 
		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),touch)
		self.wholeBgSp:setContentSize(CCSizeMake(self.dialogWidth-40 ,cellHeightNum*150))
		self.wholeBgSp:setAnchorPoint(ccp(0,0))
		self.wholeBgSp:setOpacity(0)
		self.wholeBgSp:setPosition(ccp(5,0))
		cell:addChild(self.wholeBgSp)

		--scoreNum
		local scoreLb = GetTTFLabel(getlocal("scoreNum",{cellScoreNum}),30)
		scoreLb:setAnchorPoint(ccp(0,1))
		scoreLb:setPosition(ccp(5,self.wholeBgSp:getContentSize().height-10))
		scoreLb:setColor(G_ColorYellowPro)
		self.wholeBgSp:addChild(scoreLb)

		local addW = self.wholeBgSp:getContentSize().width*0.45
		local addH = 150
		local cellHeight = self.wholeBgSp:getContentSize().height
		local curShowTb = self.lotsAward[#self.lotsAward - idx] --------!!!!!!!!!!!!!!
		local isBigBig = false
		local getAwardNums = 0
		
		local isTen = true
		for k,v in pairs(curShowTb) do
			local aHeight = math.floor((k-1)/2)
			local awidth = k%2
			if awidth==0 then
				awidth=2
			end
			local bgSp,scale =G_getItemIcon(v,100,true,self.layerNum,nil)
			bgSp:setTouchPriority(-(self.layerNum-1)*20-2)		
			bgSp:setPosition(70+addW*(awidth-1), cellHeight-100-110*aHeight)
			self.wholeBgSp:addChild(bgSp)

			local propName = GetTTFLabelWrap(v.name,strSize2+7,CCSizeMake(self.wholeBgSp:getContentSize().width*0.75,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			propName:setAnchorPoint(ccp(0,1))
			propName:setPosition(ccp(bgSp:getContentSize().width+10,bgSp:getContentSize().height-5))
			bgSp:addChild(propName)

			local numLabel=GetTTFLabel("x"..v.num,strSize2+3)
			numLabel:setAnchorPoint(ccp(0,0))
			numLabel:setPosition(bgSp:getContentSize().width+10, 5)
			numLabel:setScale(1/scale)
			bgSp:addChild(numLabel,1)

		end

       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acOlympicAwardRuleDialog:dispose()
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
function acOlympicAwardRuleDialog:close()

	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.lotsAward=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    base:removeFromNeedRefresh(self)
end