acDuanWuTabOne={}
function acDuanWuTabOne:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil

	nc.timeLb    = nil
	nc.isIphone5 = G_isIphone5()
	nc.bgWidth   = 0
	nc.upPosY    = G_VisibleSizeHeight-160
	nc.upHeight  = 222--G_VisibleSizeHeight * 0.15
	nc.ver			  = acDuanWuVoApi:getVersion( )
	nc.bottomTip 	  = nil
	nc.rechargeBtn 	  = nil
	nc.allRechargeStr = nil
	nc.goldPic		  = nil
	nc.middlePosY	  = nil
	nc.middleHeight	  = nil
	nc.cellHeight	  = 150
	nc.rechargeStallsTb, nc.canGetAwardStalls, nc.leftGoldNums, nc.stallTbNums = acDuanWuVoApi:getAllRechargeStalls()
	nc.rechargeAwardsTb = acDuanWuVoApi:getAllRechargeAwardsTb()
	nc.hadAwardsTb		= acDuanWuVoApi:getHadAwardTb()
	nc.url 				= G_downloadUrl("active/".."acDuanWuBg.jpg") or nil
	
	nc.verWidth			= 0
	return nc
end
function acDuanWuTabOne:dispose( )

	self.verWidth		   = nil
	self.stallTbNums	   = nil
	self.leftGoldNums	   = nil
	self.canGetAwardStalls = nil
	self.hadAwardsTb       = nil
	self.rechargeAwardsTb  = nil
	self.rechargeStallsTb  = nil
	self.cellHeight        = nil
	self.rechargeBtn 	= nil
	self.bottomTip 		= nil
	self.middlePosY 	= nil
	self.middleHeight	= nil
	self.goldPic		= nil
	self.allRechargeStr = nil
	self.timeLb    = nil
	self.isIphone5 = nil
	self.bgWidth   = nil
	self.upPosY    = nil
	self.upHeight  = nil
	self.ver 	   = nil
	self.tv 	   = nil
	self.bgWidth   = nil
	self.bgLayer   = nil
	self.parent    = nil
	self.isIphone5 = nil
end
function acDuanWuTabOne:init(layerNum)
	self.layerNum = layerNum
	self.bgLayer  = CCLayer:create()
	self.bgWidth  = self.bgLayer:getContentSize().width-40

	if self.ver ~= 1 then
		self.url = G_downloadUrl("active/".."acDuanWuBg_v2.jpg") or nil
	end

	self:initUp()
	self:initMiddle()
	self:initBottom()
	return self.bgLayer
end
function acDuanWuTabOne:initUrl( )
	local function onLoadIcon(fn,icon)
        icon:setAnchorPoint(ccp(0.5,1))
        icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
        self.bgLayer:addChild(icon)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acDuanWuTabOne:tick( )
	if self.timeLb then
    	self.timeLb:setString(acDuanWuVoApi:getTimer())
    end
end
function acDuanWuTabOne:initUp( )
	self:initUrl()

	local strSize2 = G_isAsia() and 25 or 20
	local upBG = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	upBG:setOpacity(0)
    upBG:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.upHeight))
    upBG:setAnchorPoint(ccp(0.5,1))
    upBG:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
    self.bgLayer:addChild(upBG,1)

    local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setOpacity(255*0.6)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upHeight)
    upBG:addChild(timeBg)

	local timeStrSize = G_isAsia() and 24 or 21
	local acLabel     = GetTTFLabel(acDuanWuVoApi:getTimer(),22,"Helvetica-bold")
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5, self.upHeight - 25))
    upBG:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro2)
    self.timeLb=acLabel

    local upDesc = GetTTFLabelWrap(getlocal("activity_duanwu_upDesc"),20,CCSizeMake(upBG:getContentSize().width-260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    upDesc:setAnchorPoint(ccp(0.5,0))
    upDesc:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upHeight * 0.32))
    upBG:addChild(upDesc,1)

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acDuanWuVoApi:showInfoTipTb(self.layerNum + 1)
    end
    local i1,i2 = "LotusLeafIcon1.png","LotusLeafIcon2.png"
    if self.ver ~= 1 then
    	i1,i2 = "i_sq_Icon1.png","i_sq_Icon2.png"
    end
    local menuItemDesc=GetButtonItem(i1,i2,i1,touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    -- menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-10, self.upHeight - 10))
    upBG:addChild(menuDesc,2)

    local hasAllRechargeTitle = GetTTFLabel(getlocal("activity_vipAction_tab2").."：",21,"Helvetica-bold")
    hasAllRechargeTitle:setAnchorPoint(ccp(0,1))
    hasAllRechargeTitle:setPosition(ccp(50,-12))
    hasAllRechargeTitle:setColor(G_ColorYellowPro)
    upBG:addChild(hasAllRechargeTitle)

    local allReNums = acDuanWuVoApi:getAllRechargeNums()
    self.allRechargeStr = GetTTFLabel(allReNums,24,"Helvetica-bold")
    self.allRechargeStr:setAnchorPoint(ccp(0,0))
    self.allRechargeStr:setPosition(ccp(hasAllRechargeTitle:getContentSize().width + 2,0))
    hasAllRechargeTitle:addChild(self.allRechargeStr)

    self.goldPic = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldPic:setAnchorPoint(ccp(0,0))
    self.goldPic:setPosition(ccp(self.allRechargeStr:getContentSize().width + 2,0))
    self.allRechargeStr:addChild(self.goldPic)


    local touchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 160,self.upHeight + 50))
    touchBg:setTouchPriority(-(self.layerNum-1)*20-10)
    touchBg:setAnchorPoint(ccp(0.5,0))
	touchBg:setIsSallow(true)
    touchBg:setPosition(G_VisibleSizeWidth * 0.5 , -50)
    touchBg:setOpacity(0)
    upBG:addChild(touchBg,10)

    if self.ver ~= 1 then
    	local tipPic = CCSprite:createWithSpriteFrameName("propTip1_4.png")
    	tipPic:setAnchorPoint(ccp(1,0))
    	tipPic:setPosition(G_VisibleSizeWidth - 15,15)
    	upBG:addChild(tipPic)
    end
end

function acDuanWuTabOne:initMiddle( )
	self.middlePosY = self.upPosY - self.upHeight - 45
	self.middleHeight = self.middlePosY - G_VisibleSizeHeight * 0.13
	if G_getIphoneType() == G_iphone4 then
		self.middleHeight = self.middleHeight - 30
	end

	local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    middleBg:setContentSize(CCSizeMake(self.bgWidth,self.middleHeight))
    middleBg:setAnchorPoint(ccp(0.5,1))
    middleBg:setPosition(G_VisibleSizeWidth * 0.5,self.middlePosY)
    self.bgLayer:addChild(middleBg)

    self.verWidth = self.ver == 1 and 0 or 30
    local verPosx = 0 - self.verWidth * 0.5

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgWidth + 8 + self.verWidth ,self.middleHeight - 4),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(-4 + verPosx,2)
	middleBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)

	if self.canGetAwardStalls < 4 then
		local recordPoint = self.tv:getRecordPoint()
		recordPoint.y=0
		self.tv:recoverToRecordPoint(recordPoint)
	end
	
	if self.ver == 1 then
		local deckScaleTb = { 1,0.8}
		local deckMovXTb  = { -20,-40}
		local deckMovYTb  = {0,-10}
		for i=1,2 do
			local llPic = CCSprite:createWithSpriteFrameName("LotusLeafTag.png")
			llPic:setScale(deckScaleTb[i])
			llPic:setPosition(ccp(self.bgWidth + deckMovXTb[i],self.middleHeight + deckMovYTb[i]))
			middleBg:addChild(llPic,2)
		end
	end
end

function acDuanWuTabOne:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
	    return self.stallTbNums
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgWidth + 8 + self.verWidth,self.cellHeight)--????????
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local useIdx = self.stallTbNums - idx
        self:initCurCell(useIdx,cell,self.rechargeStallsTb[useIdx],self.rechargeAwardsTb[useIdx])
     	return cell
    end
end

function acDuanWuTabOne:initCurCell(curIdx,parent,curGemsStalls,curAwardsTb)
	local useScale = 0.22
	local useScaleV2 = 0
	if curGemsStalls then
		local tabBgStr = self.ver == 1 and "LotusLeafTab.png" or "avtTextTab.png"
		local stallsBg = CCSprite:createWithSpriteFrameName(tabBgStr)--avtTextTab
		stallsBg:setAnchorPoint(ccp(0,0.5))
		if self.ver == 1 then
			stallsBg:setContentSize(CCSizeMake(self.bgWidth * useScale,self.cellHeight * 0.4))
		else
			useScaleV2 = self.bgWidth * (useScale + 0.04) / stallsBg:getContentSize().width
			stallsBg:setScaleX(useScaleV2)
		end
		stallsBg:setPosition(0,self.cellHeight * 0.5)

		local addPosy,addPosx = 0,0
		local goldStrPosx = -5
		if self.ver ~= 1 then
			goldStrPosx = 0
			addPosx,addPosy = 0,10
			stallsBg:setFlipX(true)
			stallsBg:setPosition(-12,self.cellHeight * 0.5)
		end
		parent:addChild(stallsBg,10)

		local curStallsGoldPic = CCSprite:createWithSpriteFrameName("IconGold.png")
	    curStallsGoldPic:setAnchorPoint(ccp(1,0.5))
	    curStallsGoldPic:setPosition(ccp(stallsBg:getContentSize().width - 15 + addPosx,stallsBg:getContentSize().height * 0.4 + addPosy))
	    stallsBg:addChild(curStallsGoldPic)

	    local curStallsGold = GetTTFLabel(curGemsStalls,24,"Helvetica-bold")
	    curStallsGold:setAnchorPoint(ccp(1,0.5))
	    curStallsGold:setPosition(goldStrPosx,curStallsGoldPic:getContentSize().height * 0.5 )
	    curStallsGoldPic:addChild(curStallsGold)

	    if self.ver ~= 1 then
	    	curStallsGoldPic:setScaleX(1/useScaleV2)
	    	curStallsGold:setScaleX(1/useScaleV2)
	    end
	end

	if curAwardsTb then
		local rewardTb=FormatItem(curAwardsTb,true,true)
		local rewardNum=#rewardTb
		local iconpy=60
		for i=1,rewardNum do
			local reward=rewardTb[i]
			local function showNewReward()
				if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
				end
				return false
			end
			local icon,scale=G_getItemIcon(reward,80,true,self.layerNum,showNewReward)
			icon:setTouchPriority(-(self.layerNum-1)*20-3)
			-- icon:setIsSallow(false)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(self.bgWidth * useScale + 10 + 90*(i - 1),self.cellHeight * 0.5)
			parent:addChild(icon)
			local numLb=GetTTFLabel("×"..FormatNumber(reward.num),22)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width - 5,5)
			icon:addChild(numLb)
			numLb:setScale(0.9/scale)
		end
	end

	local isHad = false
	if self.hadAwardsTb and SizeOfTable(self.hadAwardsTb) > 0 then
		for k,v in pairs(self.hadAwardsTb) do
			if v == curIdx then
				isHad = true
				do break end
			end
		end
	end

	if curIdx > self.canGetAwardStalls or isHad then
		local strSize = 24
		if G_isAsia() == false then
			strSize = 15
		end
		local useStr = curIdx > self.canGetAwardStalls and getlocal("local_war_incomplete") or getlocal("activity_hadReward")
		local showLb = GetTTFLabelWrap(useStr,strSize,CCSizeMake(self.bgWidth * 0.25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		showLb:setPosition(self.bgWidth * 0.9,self.cellHeight * 0.5)
		parent:addChild(showLb)

		if isHad then
			showLb:setColor(G_ColorGray)

			local cellAlpha = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
	        cellAlpha:setContentSize(CCSizeMake(self.bgWidth-8,self.cellHeight-3))
	        cellAlpha:setPosition(self.bgWidth * 0.5,self.cellHeight * 0.5)
	        cellAlpha:setOpacity(200)
	        parent:addChild(cellAlpha,3)
		end
	else
		local function onGetReward(tag,object)
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        local function rechargeAwardCall( )
	        	self:refresh()
	        end 
			acDuanWuVoApi:getRechargeAeward(tag,rechargeAwardCall)
		end
		local item1,item2 = "zongZiIcon.png","zongZiIcon.png"
		if self.ver ~= 1 then
			item1,item2 = "yh_taskReward.png","yh_taskReward_down.png"
		end
		local rewardItem=GetButtonItem(item1,item2,item1,onGetReward,curIdx,nil,0)
		rewardItem:setScale(1.1)
		local rewardMenu=CCMenu:createWithItem(rewardItem)
		rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		rewardMenu:setPosition(self.bgWidth * 0.9,self.cellHeight * 0.5)
		parent:addChild(rewardMenu)

		G_addFlicker(rewardItem,2,2)
	end

	local line =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
    line:setContentSize(CCSizeMake(self.bgWidth - 20 - self.verWidth,line:getContentSize().height))
    line:setPosition(ccp(self.bgWidth * 0.5 + self.verWidth * 0.5,0))
    parent:addChild(line,99)
end

function acDuanWuTabOne:initBottom( )
	local function goRecharge()
		vipVoApi:showRechargeDialog(self.layerNum+1)
		activityAndNoteDialog:closeAllDialog()
	end
	local btnScale,priority=1,-(self.layerNum-1)*20-4
	local rechargeBtn,rechargeMenu = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth * 0.5,65),{getlocal("new_recharge_recharge_now")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goRecharge,btnScale,priority)
	if self.ver == 1 then
		local bottomSide = CCSprite:createWithSpriteFrameName("dragonBoat.png")
		bottomSide:setAnchorPoint(ccp(0.5,0))
		bottomSide:setPosition(ccp(G_VisibleSizeWidth * 0.5,5))
		self.bgLayer:addChild(bottomSide,20)
	end

	if self.leftGoldNums then
		local strSize3 = G_isAsia() and 21 or 20
        local colorTab={G_ColorYellowPro,nowColor,G_ColorYellowPro}
        local againStr=getlocal("activity_duanwu_BottomTip",{self.leftGoldNums})
        local bottomTip = G_getRichTextLabel(againStr,colorTab,strSize3,G_VisibleSizeWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,0,true)
        bottomTip:setPosition(rechargeBtn:getContentSize().width * 0.5,rechargeBtn:getContentSize().height + 30)
        self.bottomTip = bottomTip
        bottomTip:setAnchorPoint(ccp(0.5,1))
        rechargeBtn:addChild(bottomTip)
        self.rechargeBtn = rechargeBtn
	end
end
function acDuanWuTabOne:refresh( )
	self.rechargeStallsTb,self.canGetAwardStalls, self.leftGoldNums, self.stallTbNums = acDuanWuVoApi:getAllRechargeStalls()
	self.rechargeAwardsTb = acDuanWuVoApi:getAllRechargeAwardsTb()
	self.hadAwardsTb	  = acDuanWuVoApi:getHadAwardTb()

	local allReNums = acDuanWuVoApi:getAllRechargeNums()
	if self.allRechargeStr and self.goldPic then
		self.allRechargeStr:setString(allReNums)
		self.goldPic:setPositionX(self.allRechargeStr:getContentSize().width + 2)
	end

	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		if self.canGetAwardStalls < 4 then
			recordPoint.y=0
		end
		self.tv:recoverToRecordPoint(recordPoint)
	end

	-- if self.bottomTip and self.rechargeBtn then
	-- 	self.bottomTip:removeFromParentAndCleanup(true)
	-- 	self.bottomTip = nil
	-- 	if self.leftGoldNums then
	-- 		local strSize3 = G_isAsia() and 21 or 20
	--         local colorTab={G_ColorYellowPro,nowColor,G_ColorYellowPro}
	--         local againStr=getlocal("activity_duanwu_BottomTip",{self.leftGoldNums})
	--         local bottomTip = G_getRichTextLabel(againStr,colorTab,strSize3,G_VisibleSizeWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,0,true)
	--         bottomTip:setPosition(self.rechargeBtn:getContentSize().width * 0.5,self.rechargeBtn:getContentSize().height + 30)
	--         self.bottomTip = bottomTip
	--         bottomTip:setAnchorPoint(ccp(0.5,1))
	--         self.rechargeBtn:addChild(bottomTip)
	-- 	end
	-- end
end