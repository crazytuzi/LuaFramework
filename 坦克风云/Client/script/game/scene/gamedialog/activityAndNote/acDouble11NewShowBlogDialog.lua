--世界地图点击叛军弹出的叛军面板
acDouble11NewShowBlogDialog=smallDialog:new()

--param data: 数据vo,worldBaseVo
function acDouble11NewShowBlogDialog:new(data,sender,corpLimit)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.sender = sender
	nc.dialogWidth=490
	nc.dialogHeight=660
	nc.data=data
	nc.corpLimit =corpLimit
	return nc
end

function acDouble11NewShowBlogDialog:init(layerNum)
	local subP = 10
	spriteController:addPlist("public/acXinchunhongbao.plist")--acChunjiepansheng
	-- spriteController:addPlist("public/newPropsIcon.plist")--acChunjiepansheng
	-- spriteController:addTexture("public/newPropsIcon.png")
	local strSize2 = 25
	local strSize3 = 20
	local varWidht = 10
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 = 35
		strSize3 =25
		varWidht =25
	end
	local titleLBStr = getlocal("activity_double11New_RollRedBag")
	local upSenderLbStr = getlocal("activity_double11New_RedBagSenderLb",{self.sender})
	local vo = acDouble11NewVoApi:getAcVo()
	if vo.corpRedBagRecordTb then
		titleLBStr =getlocal("activity_double11New_tab3")
		upSenderLbStr =getlocal("activity_double11New_RedBagCorpSenderLb",{self.sender})
	end
	self.isTouch=nil
	self.layerNum=layerNum
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,1,1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self.bgLayer:setPosition(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5)
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
	closeBtnItem:setScale(0.98)
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-subP-1)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width-2,self.dialogHeight-closeBtnItem:getContentSize().height-2))
	dialogBg:addChild(self.closeBtn,9)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-subP)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	base:addNeedRefresh(self)
--activity_double11New_RollRedBag
	local titleLB = GetTTFLabelWrap(titleLBStr,strSize2,CCSizeMake(self.dialogWidth-40,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLB:setAnchorPoint(ccp(0.5,0.5))
	titleLB:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight-45))
	self.bgLayer:addChild(titleLB)

	local upWidthSize = self.dialogWidth*0.68
	local upHeightSize = 105
	local function noData( ) end
	local upSenderBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),noData)
	upSenderBg:setAnchorPoint(ccp(1,1))
	upSenderBg:setContentSize(CCSizeMake(upWidthSize ,upHeightSize))
	upSenderBg:setPosition(ccp(self.dialogWidth-20,self.dialogHeight-100))
	self.bgLayer:addChild(upSenderBg)

	
	local againPosY = upSenderBg:getPositionY()-upHeightSize

	local desTv2, desLabel2 = G_LabelTableView(CCSizeMake(upWidthSize-10, upHeightSize-10),upSenderLbStr,24,kCCTextAlignmentLeft)
	self.bgLayer:addChild(desTv2)
	desTv2:setPosition(ccp(self.dialogWidth-14-upWidthSize,againPosY+5))
	desTv2:setAnchorPoint(ccp(0,0))
	desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-subP-1)
	desTv2:setMaxDisToBottomOrTop(130)

	local redBagIcon = CCSprite:createWithSpriteFrameName("can_gift_red_packets.png")
	redBagIcon:setAnchorPoint(ccp(0,1))
	redBagIcon:setPosition(ccp(20,upSenderBg:getPositionY()-2))
	self.bgLayer:addChild(redBagIcon)

	local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",close,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.dialogWidth*0.5,50))
    sureMenu:setTouchPriority(-(layerNum-1)*20-subP-1)
    self.bgLayer:addChild(sureMenu)

    local curFlag = acDouble11NewVoApi:getCurFlag()
    local tipShow = nil
    if curFlag ==2 then
    	tipShow =getlocal("activity_grabRed_grabSuccess")
    elseif curFlag ==4 then
    	tipShow =getlocal("activity_grabRed_grabOver")
    end

    if tipShow then
    	local tipShowStr = GetTTFLabelWrap(tipShow,strSize3,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	tipShowStr:setAnchorPoint(ccp(0.5,0.5))
    	tipShowStr:setPosition(ccp(self.dialogWidth*0.5+10,sureMenu:getPositionY()+sureItem:getContentSize().height*0.8))
    	tipShowStr:setColor(G_ColorRed)
    	self.bgLayer:addChild(tipShowStr)
    end

	local downHeight = upSenderBg:getPositionY()- upSenderBg:getContentSize().height- sureItem:getPositionY()- sureItem:getContentSize().height-70
	local downWidth = self.dialogWidth-40

	local downReceiverBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),noData)
	downReceiverBg:setAnchorPoint(ccp(0,0))
	downReceiverBg:setContentSize(CCSizeMake(downWidth ,downHeight))
	downReceiverBg:setPosition(ccp(20,sureItem:getPositionY()+sureItem:getContentSize().height+60))
	self.bgLayer:addChild(downReceiverBg)

	local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX(downWidth/lineSP:getContentSize().width)
    lineSP:setScaleY(1.2)
    lineSP:setPosition(ccp(downReceiverBg:getContentSize().width*0.5,downHeight*0.84))
    downReceiverBg:addChild(lineSP)

    local recordTitle = GetTTFLabel(getlocal("activity_double11New_redBagRecordTitile"),strSize3)
    recordTitle:setAnchorPoint(ccp(0,0.5))
    recordTitle:setPosition(ccp(varWidht,lineSP:getPositionY()+(downHeight-lineSP:getPositionY())*0.5))
    downReceiverBg:addChild(recordTitle)

    local limitStr = self.corpLimit
    if limitStr ==nil then
    	limitStr =acDouble11NewVoApi:getNumLimit()
    end
    local recordInfo = GetTTFLabel(getlocal("scheduleChapter",{SizeOfTable(self.data),limitStr}),25)
    recordInfo:setAnchorPoint(ccp(1,0.5))
    recordInfo:setPosition(downWidth-10,recordTitle:getPositionY())
    downReceiverBg:addChild(recordInfo)

    self.cellHeight =downHeight*0.15
    self.cellWidth =downWidth-20
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=downHeight*0.84-15;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(downWidth-20,height),nil)-- -200
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-subP-1)
    self.tv:setPosition(ccp(10,10))
    downReceiverBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)--120

	return self.dialogLayer
end

function acDouble11NewShowBlogDialog:eventHandler( handler,fn,idx,cel)
	local strSize3 = 20
	local varWidht = 10
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize3 =24
		varWidht =15
	end
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.data)
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(self.cellWidth,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local allNum = SizeOfTable(self.data)
    local everyGetRedBagRecordLb = GetTTFLabel(getlocal("activity_double11New_everyBodyGetRedBagLb",{self.data[allNum-idx][1]}),strSize3)
    everyGetRedBagRecordLb:setAnchorPoint(ccp(0,0.5))
    everyGetRedBagRecordLb:setPosition(ccp(varWidht,self.cellHeight*0.5))
    cell:addChild(everyGetRedBagRecordLb)

    local redBagTypeStr = GetTTFLabel(getlocal("activity_double11_shopName_"..self.data[allNum-idx][3]),strSize3)
    redBagTypeStr:setColor(G_ColorGreen)
    redBagTypeStr:setAnchorPoint(ccp(0,0.5))
    redBagTypeStr:setPosition(ccp(varWidht+everyGetRedBagRecordLb:getContentSize().width,self.cellHeight*0.5))
    cell:addChild(redBagTypeStr)

    local gotNums = GetTTFLabel(getlocal("activity_double11New_redBagGotNums",{self.data[allNum-idx][2]}),strSize3)
    gotNums:setAnchorPoint(ccp(0,0.5))
    gotNums:setPosition(ccp(5+redBagTypeStr:getPositionX()+redBagTypeStr:getContentSize().width,self.cellHeight*0.5))
    cell:addChild(gotNums)
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end



function acDouble11NewShowBlogDialog:dispose()
	self.tv =nil 
	spriteController:removePlist("public/acXinchunhongbao.plist")
	-- spriteController:removePlist("public/newPropsIcon.plist")
	-- spriteController:removeTexture("public//newPropsIcon.png")
end