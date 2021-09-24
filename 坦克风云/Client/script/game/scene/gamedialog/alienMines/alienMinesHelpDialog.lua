alienMinesHelpDialog=smallDialog:new()

--param type: 面板类型, 1是自己占领, 2是友军占领, 3是敌军占领,4是空地
--param data: 数据, 坐标 ID等
function alienMinesHelpDialog:new(type,data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=560
	self.dialogHeight=720

	self.type=type
	self.data=data
	return nc
end

function alienMinesHelpDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
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
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleStr=getlocal("help")
	local titleLb=GetTTFLabel(titleStr,30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)
    
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	-- local posY=self.dialogHeight-110
	self:initTableView()


	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function alienMinesHelpDialog:initTableView()

    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-10,self.dialogHeight-130),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(5,30))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.tv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.tv)
end

function alienMinesHelpDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		self.cellHeight = 1450
		if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="thai" or G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage() =="ar" then
			self.cellHeight =2000
		elseif G_getCurChoseLanguage() =="ru" then
			self.cellHeight =2300
		end
		tmpSize=CCSizeMake(self.dialogWidth-40,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		-- local rect = CCRect(0, 0, 50, 50);
		-- local capInSet = CCRect(20, 20, 10, 10);
		-- local function cellClick(hd,fn,idx)
		-- end
		-- local hei=150-4
	   
		-- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		-- backSprie:setContentSize(CCSizeMake(self.dialogWidth-40, hei))
		-- backSprie:ignoreAnchorPointForPosition(false);
		-- backSprie:setAnchorPoint(ccp(0,0));
		-- backSprie:setIsSallow(false)
		-- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		-- backSprie:setPosition(ccp(15,2))
		-- cell:addChild(backSprie)

		-- 矿产
		local lbH = self.cellHeight-10
		local systemLb = GetTTFLabel(getlocal("alienMines_mineral"),28)
		systemLb:setAnchorPoint(ccp(0,1))
		systemLb:setPosition(30, lbH)
		systemLb:setColor(G_ColorGreen)
		cell:addChild(systemLb)

		lbH = lbH-systemLb:getContentSize().height-10
		local systemContentStr = getlocal("alienMines_mineral_des") .. "\n" .. "6." .. getlocal("alienMines_info4")
		local systemContentLb = GetTTFLabelWrap(systemContentStr,25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		systemContentLb:setAnchorPoint(ccp(0,1))
		systemContentLb:setPosition(30, lbH)
		cell:addChild(systemContentLb)

		-- 占领
		lbH = lbH-systemContentLb:getContentSize().height-20
		local battleLb = GetTTFLabel(getlocal("alienMines_Occupied"),28)
		battleLb:setAnchorPoint(ccp(0,1))
		battleLb:setPosition(30, lbH)
		battleLb:setColor(G_ColorGreen)
		cell:addChild(battleLb)

		lbH = lbH-battleLb:getContentSize().height-10
		local battleContentLb = GetTTFLabelWrap(getlocal("alienMines_Occupied_des",{alienMineCfg.dailyOccupyNum,alienMineCfg.protectTime/60}),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		battleContentLb:setAnchorPoint(ccp(0,1))
		battleContentLb:setPosition(30, lbH)
		cell:addChild(battleContentLb)

		-- 掠夺
		lbH = lbH-battleContentLb:getContentSize().height-20
		local battleLogLb = GetTTFLabel(getlocal("help4_t3_t3"),28)
		battleLogLb:setAnchorPoint(ccp(0,1))
		battleLogLb:setPosition(30, lbH)
		battleLogLb:setColor(G_ColorGreen)
		cell:addChild(battleLogLb)

		lbH = lbH-battleLogLb:getContentSize().height-10
		local battleLogContentLb = GetTTFLabelWrap(getlocal("alienMines_plunder_des",{alienMineCfg.robRate*100 .. "%%",alienMineCfg.dailyRobNum}),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		battleLogContentLb:setAnchorPoint(ccp(0,1))
		battleLogContentLb:setPosition(30, lbH)
		cell:addChild(battleLogContentLb)

		-- 异星积分
		lbH = lbH-battleLogContentLb:getContentSize().height-20
		local scoreLb = GetTTFLabel(getlocal("alienMines_alienScore"),28)
		scoreLb:setAnchorPoint(ccp(0,1))
		scoreLb:setPosition(30, lbH)
		scoreLb:setColor(G_ColorGreen)
		cell:addChild(scoreLb)

		lbH = lbH-scoreLb:getContentSize().height-10
		local scoreContentLb = GetTTFLabelWrap(getlocal("alienMines_alienScore_des"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		scoreContentLb:setAnchorPoint(ccp(0,1))
		scoreContentLb:setPosition(30, lbH)
		cell:addChild(scoreContentLb)



		-- 排行榜
		lbH = lbH-scoreContentLb:getContentSize().height-20
		local betLb = GetTTFLabel(getlocal("mainRank"),28)
		betLb:setAnchorPoint(ccp(0,1))
		betLb:setPosition(30, lbH)
		betLb:setColor(G_ColorGreen)
		cell:addChild(betLb)

		lbH = lbH-betLb:getContentSize().height-10
		local betContentLb = GetTTFLabelWrap(getlocal("alienMines_rank_des"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		betContentLb:setAnchorPoint(ccp(0,1))
		betContentLb:setPosition(30, lbH)
		cell:addChild(betContentLb)

		-- 奖励
		lbH = lbH-betContentLb:getContentSize().height-20
		local rewardLb = GetTTFLabel(getlocal("award"),28)
		rewardLb:setAnchorPoint(ccp(0,1))
		rewardLb:setPosition(30, lbH)
		rewardLb:setColor(G_ColorGreen)
		cell:addChild(rewardLb)

		lbH = lbH-rewardLb:getContentSize().height-10
		local rewardContentLb = GetTTFLabelWrap(getlocal("alienMines_reward_des"),25,CCSizeMake(self.dialogWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		rewardContentLb:setAnchorPoint(ccp(0,1))
		rewardContentLb:setPosition(30, lbH)
		cell:addChild(rewardContentLb)
		
	   return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end








