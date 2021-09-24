acStormFortressRewardDialog=smallDialog:new()

function acStormFortressRewardDialog:new(layerNum)
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
function acStormFortressRewardDialog:init(callbackSure)
	self.dialogWidth=500
	self.dialogHeight=650
	self.isTouch=nil
	self.lotsAward =acStormFortressVoApi:getPoolReward( )------取配置奖励库

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

	--activity_stormFortress_NormRewardTitle
	local desLb = GetTTFLabelWrap(getlocal("activity_stormFortress_NormRewardTitle"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dialogBg:addChild(desLb)
	desLb:setColor(G_ColorYellowPro)
	desLb:setPosition(dialogBg:getContentSize().width*0.5, self.dialogHeight-60)

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

function acStormFortressRewardDialog:initTableView( ... )

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	middleBg:setContentSize(CCSizeMake(self.dialogWidth-30 ,self.dialogHeight*0.65))
	middleBg:setAnchorPoint(ccp(0,0))
	middleBg:setPosition(ccp(15,120))
	self.bgLayer:addChild(middleBg)

	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-30 ,self.dialogHeight*0.63),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(15,125))
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(120)
end

function acStormFortressRewardDialog:eventHandler(handler,fn,idx,cel)
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
				bgSp:setPosition(70+addW*(awidth-1), cellHeight-60-130*aHeight)
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

function acStormFortressRewardDialog:dispose()
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
function acStormFortressRewardDialog:close()

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