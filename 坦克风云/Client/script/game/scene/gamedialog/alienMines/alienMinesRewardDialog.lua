alienMinesRewardDialog=smallDialog:new()

--param type: 面板类型, 1是自己占领, 2是友军占领, 3是敌军占领,4是空地
--param data: 数据, 坐标 ID等
function alienMinesRewardDialog:new(type,data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=560
	self.dialogHeight=720

	self.oldSelectedTabIndex=0
	self.selectedTabIndex=0
	self.allTabs={}
	self.reward1={}
	self.reward2={}

	self.type=type
	self.data=data
	return nc
end

function alienMinesRewardDialog:init(layerNum)
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
	
	local titleStr=getlocal("serverwar_help_title5")
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

	-- 描述label
	local descLb=GetTTFLabelWrap(getlocal("alienMines_reward_des4"),25,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0))
	descLb:setColor(G_ColorRed)
	descLb:setPosition(ccp(30,20))
	self.bgLayer:addChild(descLb)
	self.descLb=descLb

	-- 初始化页签
	self:initTab()
	

	self:initTableView()


	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function alienMinesRewardDialog:initTab()
	local function touchItem(idx)
        self.oldSelectedTabIndex=self.selectedTabIndex
        self:tabClickColor(idx)
        return self:tabClick(idx)
    end
    -- 页签1
    local titleItem1=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    titleItem1:setScale(0.8)
    self.allTabs[1]=titleItem1
    titleItem1:setTag(1)
    titleItem1:registerScriptTapHandler(touchItem)
    titleItem1:setEnabled(false)
    local tabMenu1=CCMenu:createWithItem(titleItem1)
    tabMenu1:setPosition(ccp(20+titleItem1:getContentSize().width/2*0.8,self.dialogHeight-110))
    tabMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(tabMenu1,2)
    self.titleItem1=titleItem1

	local titleLb1 = GetTTFLabel(getlocal("alliance_war_personal"),20)
	titleItem1:addChild(titleLb1)
	titleLb1:setPosition(ccp(titleItem1:getContentSize().width/2,titleItem1:getContentSize().height/2))

	-- 页签2
	local titleItem2=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
	titleItem2:setScale(0.8)
	titleItem2:setTag(2)
	titleItem2:registerScriptTapHandler(touchItem)
	self.allTabs[2]=titleItem2
	local tabMenu2=CCMenu:createWithItem(titleItem2)
	tabMenu2:setPosition(ccp(20+titleItem2:getContentSize().width/2*3*0.8,self.dialogHeight-110))
	tabMenu2:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(tabMenu2,2)
	self.titleItem2=titleItem2

	local titleLb2 = GetTTFLabel(getlocal("alliance_list_scene_name"),20)
	titleItem2:addChild(titleLb2)
	titleLb2:setPosition(ccp(titleItem2:getContentSize().width/2,titleItem2:getContentSize().height/2))
end

function alienMinesRewardDialog:initTableView()

	self.reward1=alienMinesVoApi:getUserRankingReward()
	self.cellTb1={
	{title=getlocal("serverwar_rank_1"),icon="top1.png",pic=self.reward1[1].pic,des=getlocal("alienMines_reward_des2",{"1"}),reStr=self.reward1[1].name .. "*" .. FormatNumber(self.reward1[1].num)},
	{title=getlocal("serverwar_rank_2"),icon="top2.png",pic=self.reward1[2].pic,des=getlocal("alienMines_reward_des2",{"2"}),reStr=self.reward1[2].name .. "*" .. FormatNumber(self.reward1[2].num)},
	{title=getlocal("serverwar_rank_3"),icon="top3.png",pic=self.reward1[3].pic,des=getlocal("alienMines_reward_des2",{"3"}),reStr=self.reward1[3].name .. "*" .. FormatNumber(self.reward1[3].num)},
	{title=getlocal("rankOne",{"4~5"}),icon="top3.png",pic=self.reward1[4].pic,des=getlocal("alienMines_reward_des2",{"4~5"}),reStr=self.reward1[4].name .. "*" .. FormatNumber(self.reward1[4].num)},
	{title=getlocal("rankOne",{"6~10"}),icon="top3.png",pic=self.reward1[5].pic,des=getlocal("alienMines_reward_des2",{"6~10"}),reStr=self.reward1[5].name .. "*" .. FormatNumber(self.reward1[5].num)},

	}

    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-10,self.dialogHeight-155-self.descLb:getContentSize().height),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(5,20+self.descLb:getContentSize().height+10))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.tv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.tv)

	self.reward2=alienMinesVoApi:getAllianceRankingReward()
	self.cellTb2={
	{title=getlocal("serverwar_rank_1"),icon="top1.png",pic=self.reward2[1].pic,des=getlocal("alienMines_reward_des1",{"1"}),reStr=self.reward2[1].name .. "*" .. FormatNumber(self.reward2[1].num)},
	}
	
	local function callBack1(...)
		return self:eventHandler1(...)
	end
	local hd= LuaEventHandler:createHandler(callBack1)
 	self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-10,self.dialogHeight-155-self.descLb:getContentSize().height),nil)
	self.tv1:setAnchorPoint(ccp(0,0))
	self.tv1:setPosition(ccp(5,20+self.descLb:getContentSize().height+10))
	self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.tv1:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.tv1)

	self.tv1:setPosition(0,99993)
	self.tv1:setVisible(false)

	
	

	

end

function alienMinesRewardDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.reward1)
		-- return 3
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		self.cellHeight = 200
		tmpSize=CCSizeMake(self.dialogWidth-40,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local bs1 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
		bs1:setPosition(self.bgLayer:getContentSize().width/2, self.cellHeight-30)
		bs1:setScaleY(0.6)
		cell:addChild(bs1)

		local oneLb = GetTTFLabel(self.cellTb1[idx+1].title, 25)
		oneLb:setPosition(self.bgLayer:getContentSize().width/2, self.cellHeight-30)
		cell:addChild(oneLb)

		if idx<3 then
			local oneSp = CCSprite:createWithSpriteFrameName(self.cellTb1[idx+1].icon)
			oneSp:setAnchorPoint(ccp(0,1))
			oneSp:setPosition(20, self.cellHeight)
			cell:addChild(oneSp)
		end

		local sp = CCSprite:createWithSpriteFrameName(self.cellTb1[idx+1].pic)
		sp:setAnchorPoint(ccp(0,0.5))
		sp:setPosition(30,(self.cellHeight-30)/2-10)
		cell:addChild(sp)

		local descLb=GetTTFLabelWrap(self.cellTb1[idx+1].des,22,CCSizeMake(self.dialogWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0.5,0.5))
		descLb:setPosition(ccp(self.dialogWidth/2+50,(self.cellHeight-30)/2+5))
		cell:addChild(descLb)

		local resLb = GetTTFLabel(self.cellTb1[idx+1].reStr, 22)
		resLb:setAnchorPoint(ccp(0.5,1))
		resLb:setPosition(self.dialogWidth/2+50,(self.cellHeight-30)/2-22)
		cell:addChild(resLb)
		resLb:setColor(G_ColorYellowPro)
		

		
	   return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function alienMinesRewardDialog:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.reward2)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		self.cellHeight = 200
		tmpSize=CCSizeMake(self.dialogWidth-40,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local bs1 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
		bs1:setPosition(self.bgLayer:getContentSize().width/2, self.cellHeight-30)
		bs1:setScaleY(0.6)
		cell:addChild(bs1)

		local oneLb = GetTTFLabel(self.cellTb2[idx+1].title, 25)
		oneLb:setPosition(self.bgLayer:getContentSize().width/2, self.cellHeight-30)
		cell:addChild(oneLb)

		local oneSp = CCSprite:createWithSpriteFrameName(self.cellTb2[idx+1].icon)
		oneSp:setAnchorPoint(ccp(0,1))
		oneSp:setPosition(20, self.cellHeight)
		cell:addChild(oneSp)

		local sp = CCSprite:createWithSpriteFrameName(self.cellTb2[idx+1].pic)
		sp:setAnchorPoint(ccp(0,0.5))
		sp:setPosition(30,(self.cellHeight-30)/2-10)
		cell:addChild(sp)

		local descLb=GetTTFLabelWrap(self.cellTb2[idx+1].des,22,CCSizeMake(self.dialogWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0.5,0.5))
		descLb:setPosition(ccp(self.dialogWidth/2+50,(self.cellHeight-30)/2+5))
		cell:addChild(descLb)

		local resLb = GetTTFLabel(self.cellTb2[idx+1].reStr, 22)
		resLb:setAnchorPoint(ccp(0.5,1))
		resLb:setPosition(self.dialogWidth/2+50,(self.cellHeight-30)/2-22)
		cell:addChild(resLb)
		resLb:setColor(G_ColorYellowPro)
		




	   return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function alienMinesRewardDialog:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
         else
            v:setEnabled(true)
            local tabBtnItem = v
         end
    end
end
function alienMinesRewardDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
         else            
            v:setEnabled(true)
         end
    end
    if idx==1 then
    	self.tv:setPosition(ccp(5,20+self.descLb:getContentSize().height+10))
    	self.tv:setVisible(true)

    	self.tv1:setPosition(0,99993)
    	self.tv1:setVisible(false)
    else
    	self.tv:setPosition(ccp(0,99993))
    	self.tv:setVisible(false)

    	self.tv1:setPosition(ccp(5,20+self.descLb:getContentSize().height+10))
    	self.tv1:setVisible(true)
    end

end

function alienMinesRewardDialog:dispose()
	self.bgLayer=nil
	self.descLb=nil
	self.tv=nil
end








