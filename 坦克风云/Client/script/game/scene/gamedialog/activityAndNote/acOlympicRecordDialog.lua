acOlympicRecordDialog = smallDialog:new()

function acOlympicRecordDialog:new(layerNum)
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
function acOlympicRecordDialog:init(callbackSure)
	local strSize2 = 22
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =25
	end

	self.dialogWidth=560
	self.dialogHeight=770
	self.isTouch=nil
	self.lotsAward =acOlympicVoApi:getAwardAllTbRecord( )
	self.rewardTb = acOlympicVoApi:getAwardAllTb( )
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


	local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight-30));
	bgSp:setScaleY(60/bgSp:getContentSize().height)
	bgSp:setScaleX(self.dialogWidth/bgSp:getContentSize().width)
	dialogBg:addChild(bgSp)

	local desLb = GetTTFLabelWrap(getlocal("activity_customLottery_RewardRecode"),33,CCSizeMake(self.dialogWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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

    --activity_xinchunhongbao_repordMax --activity_getRich_notice
    local lbHeight = 120
    local noticeStr = GetTTFLabelWrap(getlocal("activity_getRich_notice")..getlocal("activity_xinchunhongbao_repordMax",{10}),strSize2,CCSizeMake(dialogBg:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    noticeStr:setAnchorPoint(ccp(0,0.5))
    noticeStr:setColor(G_ColorRed)
    noticeStr:setPosition(ccp(15,lbHeight))
    dialogBg:addChild(noticeStr)

    -- local noticeLb = GetTTFLabel(getlocal("activity_xinchunhongbao_repordMax",{10}),strSize2)
    -- noticeLb:setAnchorPoint(ccp(0,0))
    -- noticeLb:setColor(G_ColorRed)
    -- noticeLb:setPosition(ccp(15+noticeStr:getContentSize().width,lbHeight))
    -- dialogBg:addChild(noticeLb)

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

function acOlympicRecordDialog:initTableView( ... )

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	middleBg:setContentSize(CCSizeMake(self.dialogWidth-30,self.dialogHeight*0.7))
	middleBg:setAnchorPoint(ccp(0,0))
	middleBg:setPosition(ccp(15,150))
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

function acOlympicRecordDialog:eventHandler(handler,fn,idx,cel)
   	local strSize2 = 21
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =23
	end
   if fn=="numberOfCellsInTableView" then
	   	if #self.lotsAward >0 then
			return #self.lotsAward
		end
       return 1
   elseif fn=="tableCellSizeForIndex" then
   		
       return  CCSizeMake(self.dialogWidth-40,130)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()

       local tbNums = SizeOfTable(self.lotsAward)
	   local curTb = self.lotsAward[tbNums-idx]
	   acOlympicVoApi:setCurCellAwardRecord(curTb)--------!!!!!!!!!!!!!!

       	local function touch( ) end 
		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),touch)
		self.wholeBgSp:setContentSize(CCSizeMake(self.dialogWidth-40 ,130))
		self.wholeBgSp:setAnchorPoint(ccp(0,0))
		self.wholeBgSp:setOpacity(200)
		self.wholeBgSp:setPosition(ccp(5,0))
		cell:addChild(self.wholeBgSp)
		local addW = 110
		local addH = 130
		local cellHeight = self.wholeBgSp:getContentSize().height
		local curShowTb = acOlympicVoApi:getCurCellAwardRecord( )--------!!!!!!!!!!!!!!
		local isTen = false
		for k,v in pairs(curShowTb) do
			local aHeight = math.floor((k-1)/4)
			local awidth = k%4
			if awidth==0 then
				awidth=4
			end
			local bgSp,scale =G_getItemIcon(v,80,true,self.layerNum,nil)
			bgSp:setTouchPriority(-(self.layerNum-1)*20-2)		
			bgSp:setPosition(70+addW*(awidth-1), cellHeight-80-130*aHeight)
			self.wholeBgSp:addChild(bgSp)

			local numLabel=GetTTFLabel("x"..v.num,21)
			numLabel:setAnchorPoint(ccp(1,0))
			numLabel:setPosition(bgSp:getContentSize().width-5, 5)
			numLabel:setScale(1/scale)
			bgSp:addChild(numLabel,1)

			if acOlympicVoApi:getIsTen( ) ==true then
				isTen =true
			end
		end

		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	    lineSp:setAnchorPoint(ccp(0.5,0.5))
	    lineSp:setScale(0.95)
	    lineSp:setPosition(ccp(self.dialogWidth*0.5,95))
	    self.wholeBgSp:addChild(lineSp)
	    local showStrHeight = 100


	    local showStrHeight = 100
	    local headCellStr1 =getlocal("activity_olympic_normalLb")
	    if isTen then
	    	headCellStr1 = getlocal("activity_olympic_TenLb")
	    end
	    local showStr1 = GetTTFLabel(headCellStr1,strSize2)
	    showStr1:setAnchorPoint(ccp(0,0))
	    showStr1:setPosition(ccp(15,showStrHeight))
	    self.wholeBgSp:addChild(showStr1)
	    if isTen then
	    	showStr1:setColor(ccc3(69,255,93))
	    end

	    local timeStr = acOlympicVoApi:getTimeRecord()--------!!!!!!!!!!!!!!
	    local timeShow = GetTTFLabel(timeStr,strSize2)
	    timeShow:setAnchorPoint(ccp(1,0))
	    timeShow:setPosition(ccp(self.dialogWidth-45,showStrHeight))
	    self.wholeBgSp:addChild(timeShow)

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

function acOlympicRecordDialog:dispose()
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
function acOlympicRecordDialog:close()

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