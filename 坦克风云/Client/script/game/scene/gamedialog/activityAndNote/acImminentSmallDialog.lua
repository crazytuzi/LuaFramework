acImminentSmallDialog=smallDialog:new()

function acImminentSmallDialog:new(layerNum,id)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.id = id 
	self.layerNum=layerNum
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
	self.bigAward={}
	self.lotsAwardTb={}
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acImminentSmallDialog:init(callbackSure,lotsAwardTb,bigAwardTb)
	self.dialogWidth=500
	self.dialogHeight=550
	self.isTouch=nil
	self.lotsAward=lotsAwardTb[self.id]
	self.bigAward =bigAwardTb[self.id]
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

	local desLb = GetTTFLabelWrap(getlocal("activity_yichujifa_grubOutStr1",{self.id*20}),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setPosition(dialogBg:getContentSize().width*0.5, self.dialogHeight-40)

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
----大奖
	if self.bigAward then
		local awidth = 1
		local bgSp,scale =G_getItemIcon(self.bigAward,100,true,self.layerNum,nil)
		bgSp:setTouchPriority(-(self.layerNum-1)*20-2)		
		bgSp:setPosition(85+addW*(awidth-1), self.dialogHeight-110)
		dialogBg:addChild(bgSp)

		local numLabel=GetTTFLabel("x"..self.bigAward.num,21)
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(bgSp:getContentSize().width-5, 5)
		numLabel:setScale(1/scale)
		bgSp:addChild(numLabel,1)
	end
----
	local desLb = GetTTFLabelWrap(getlocal("activity_yichujifa_grubOutStr2"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setPosition(dialogBg:getContentSize().width*0.5, self.dialogHeight-180)

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

function acImminentSmallDialog:initTableView( ... )
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth ,self.dialogHeight*0.5-40),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(0,23))
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(120)
	self.tv:setPosition(ccp(5,110))
end

function acImminentSmallDialog:eventHandler(handler,fn,idx,cel)
	local needHeight = 50
	if SizeOfTable(self.lotsAward)>8 then
		needHeight =200
	end
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
   		
       return  CCSizeMake(self.dialogWidth ,self.dialogHeight*0.5+needHeight)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       local needHeight2 = 95
		if SizeOfTable(self.lotsAward)>8 then
			needHeight2 =240
		end
       	local function touch( )
       	end 
		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
		self.wholeBgSp:setContentSize(CCSizeMake(self.dialogWidth ,self.dialogHeight*0.5-40))
		self.wholeBgSp:setAnchorPoint(ccp(0,0))
		self.wholeBgSp:setOpacity(0)
		self.wholeBgSp:setPosition(ccp(0,needHeight2))
		cell:addChild(self.wholeBgSp)
		local addW = 110
		local addH = 130
		local cellHeight = self.wholeBgSp:getContentSize().height
			for k,v in pairs(self.lotsAward) do
				local aHeight = math.floor((k-1)/4)
				local awidth = k%4
				if awidth==0 then
					awidth=4
				end
				local bgSp,scale =G_getItemIcon(v,100,true,self.layerNum,nil)
				bgSp:setTouchPriority(-(self.layerNum-1)*20-2)		
				-- if k<5 then
					bgSp:setPosition(80+addW*(awidth-1), cellHeight-60-130*aHeight)
				-- else
				-- 	bgSp:setPosition(85+addW*(awidth-1), cellHeight-60-130)
				-- end
				self.wholeBgSp:addChild(bgSp)

				local numLabel=GetTTFLabel("x"..v.num,21)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(bgSp:getContentSize().width-5, 5)
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

function acImminentSmallDialog:dispose()
	self.id = nil
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
	self.bigAward=nil
	self.lotsAwardTb=nil
end
function acImminentSmallDialog:close()

	self.id = nil
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	-- self.dialogLayer=nil
	self.bigAward=nil
	self.lotsAwardTb=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    -- if self and self.bgLayer then
    --     self.bgLayer:removeFromParentAndCleanup(true)
    --     self.bgLayer=nil
    -- end
    base:removeFromNeedRefresh(self)
end