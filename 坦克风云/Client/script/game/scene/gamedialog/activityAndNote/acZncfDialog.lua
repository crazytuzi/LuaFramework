acZncfDialog=commonDialog:new()

function acZncfDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum = layerNum
	nc.upPosY   = G_VisibleSizeHeight - 82
	nc.width    = G_VisibleSizeWidth
	nc.isIphone5  = G_isIphone5()
	nc.tvHadDataTv = {}
	nc.pageDescList = {}
	return nc
end
function acZncfDialog:dispose()
    acZncfVoApi:setCurRewardIdx(1)
    self.tipSp = nil
	self.pageDescList = nil
	self.tvHadDataTv = nil
	self.tv = nil
	spriteController:removePlist("public/rewardCenterImage.plist")
    spriteController:removeTexture("public/rewardCenterImage.png")
    spriteController:removePlist("public/acZnqd2017.plist")
	spriteController:removeTexture("public/acZnqd2017.png")
	spriteController:removePlist("public/acZncfImage.plist")
	spriteController:removeTexture("public/acZncfImage.png")
	spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
end
function acZncfDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end
function acZncfDialog:getBgOfTabPosY(tabIndex)
    local offset = 0
    if tabIndex == 0 then
    	if G_getIphoneType() == G_iphone5 then
    		offset = - 140
    	elseif G_getIphoneType() == G_iphoneX then
    		offset = - 200
    	else --默认是 G_iphone4
    		offset = - 40
    	end
    elseif tabIndex == 1 then
    	offset = 170
    elseif tabIndex == 2 then
    	offset = 230
    end
    return G_VisibleSizeHeight + offset
end
function acZncfDialog:doUserHandler()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/rewardCenterImage.plist")
    spriteController:addTexture("public/rewardCenterImage.png")
    spriteController:addPlist("public/acZnqd2017.plist")
	spriteController:addTexture("public/acZnqd2017.png")
	spriteController:addPlist("public/acZncfImage.plist")
	spriteController:addTexture("public/acZncfImage.png")
	spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self:initBg()
    self:initTopAward()
    acZncfVoApi:getDataByTab(8)
    self:initMiddle()
    self:initBelow()
end
function acZncfDialog:initBg( )
	local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 82))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 82)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper)

	local function onLoadBackground(fn,webImage)
		if self and clipper and tolua.cast(clipper, "CCNode") then
            webImage:setAnchorPoint(ccp(0.5, 1))
            webImage:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 105)--self:getBgOfTabPosY(self.selectedTabIndex) + 100)
            clipper:addChild(webImage)
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acZncfImage.jpg"),onLoadBackground)
	
	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    -- timeBg:setOpacity(150)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
    self.bgLayer:addChild(timeBg,10)

	local vo=acZncfVoApi:getAcVo()
	local timeStr=acZncfVoApi:getTimer()
	self.timeLb=GetTTFLabel(timeStr,25,"Helvetica-bold")
	self.timeLb:setColor(G_ColorYellowPro)
	self.timeLb:setAnchorPoint(ccp(0.5,1))
	self.timeLb:setPosition(ccp(timeBg:getContentSize().width * 0.5,timeBg:getContentSize().height - 12))
	timeBg:addChild(self.timeLb,2)

	local function showInfo()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acZncfVoApi:showInfoTipTb(self.layerNum + 1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(timeBg:getContentSize().width - 10,timeBg:getContentSize().height - 10))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	timeBg:addChild(infoBtn,3)

	local subHeight = self.isIphone5 and 15 or 5
	self.UpBgDownPosY = self.upPosY - timeBg:getContentSize().height - subHeight

	local topTitle = GetTTFLabel(getlocal("activity_zncf_topTitle"),23)
	topTitle:setAnchorPoint(ccp(0.5,1))
	topTitle:setColor(G_ColorYellowPro)
	topTitle:setPosition(G_VisibleSizeWidth * 0.5, self.UpBgDownPosY + 40)
	self.bgLayer:addChild(topTitle,2)

	local topTip = GetTTFLabelWrap(getlocal("activity_zncf_tip"),19,CCSizeMake(G_VisibleSizeWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	topTip:setAnchorPoint(ccp(0.5,1))
	topTip:setColor(G_ColorOrange2)
	topTip:setPosition(G_VisibleSizeWidth * 0.5, self.UpBgDownPosY + 5)
	self.bgLayer:addChild(topTip,2)
end

function acZncfDialog:initTopAward( )
	local dailyRewardList = acZncfVoApi:getDailyReward()
	local useWidth, useHeight = G_VisibleSizeWidth, 350
	self.upHeight = useHeight
	local btnPos = ccp(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - useHeight  + 15)
	local iconSize, iconSpaceX, iconSpaceY = 75, 40, 10
	local awardNum = SizeOfTable(dailyRewardList)
    local firstPosX = (useWidth - awardNum * iconSize - (awardNum - 1) * iconSpaceX) / 2
    
    for k, v in pairs(dailyRewardList) do
        local posX = firstPosX + (k - 1) % awardNum * (iconSize + iconSpaceX)
        local posY = G_VisibleSizeHeight - useHeight * 0.64
        
        local function showPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, nil, nil, v, nil, nil, nil, nil, true)
        end
        local rewardSp, scale = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
        rewardSp:setScale(iconSize / rewardSp:getContentSize().width)
        rewardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        rewardSp:setAnchorPoint(ccp(0, 1))
        rewardSp:setPosition(posX, posY)
        self.bgLayer:addChild(rewardSp,2)
        
        local numLb = GetTTFLabel("x"..FormatNumber(v.num), 22)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setScale(1 / scale)
        numLb:setPosition(ccp(rewardSp:getContentSize().width - 5, 2))
        rewardSp:addChild(numLb, 3)
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
        numBg:setPosition(ccp(rewardSp:getContentSize().width - 5, 5))
        numBg:setOpacity(150)
        rewardSp:addChild(numBg, 2)
    end

    local function getRewardHandler()
        local flag = acZncfVoApi:hasReward()
        if flag == true then
            do return end
        end
        local function callback()
            self:refresh()
            local rewardList = acZncfVoApi:getDailyReward()
            --加奖励
            for k, v in pairs(rewardList) do
                G_addPlayerAward(v.type, v.key, v.id, v.num)
            end
            --奖励展示
            G_showRewardTip(rewardList, true)
        end
        acZncfVoApi:getRewardRequest(callback)
    end
    self.getItem, self.getMenu = G_createBotton(self.bgLayer, btnPos, {getlocal("daily_scene_get"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", getRewardHandler, 0.6, -(self.layerNum - 1) * 20 - 4, 3)
    self:refresh()

    local function shareHandler( )
    	local curStr = self.pageDescList[acZncfVoApi:getCurRewardIdx()] and self.pageDescList[acZncfVoApi:getCurRewardIdx()]:getString() or ""
    	acZncfVoApi:readySendCurDataWithChat(self.layerNum + 1,curStr)
    end 
    local shareBtn=G_createBotton(self.bgLayer,ccp(useWidth-50,G_VisibleSizeHeight - useHeight - 70),nil,"newShareBtn.png","newShareBtn_Down.png","newShareBtn_Down.png",shareHandler,1, -(self.layerNum - 1) * 20 - 4,3)
end

function acZncfDialog:refresh( )

        if self.getItem then
            local btnStr = ""
            local flag = acZncfVoApi:hasReward()
            if flag == true then
                self.getItem:setEnabled(false)
                btnStr = getlocal("activity_hadReward")
            else
                self.getItem:setEnabled(true)
                btnStr = getlocal("daily_scene_get")
            end
            local strLb = tolua.cast(self.getItem:getChildByTag(101), "CCLabelTTF")
            if strLb then
                strLb:setString(btnStr)
            end
        end

end

function acZncfDialog:tick()
	local isEnd=acZncfVoApi:isEnd()
    if isEnd==true then
        self:close()
    end
    if self.timeLb then
    	self.timeLb:setString(acZncfVoApi:getTimer())
    end

    if acZncfVoApi:isToday() == false then
        acZncfVoApi:resetDailyReward()
        self:refresh()
    end
end

function acZncfDialog:initMiddle( )
	local width,height = G_VisibleSizeWidth - 80, 390
	self.middleHeight = height
    local listNum = acZncfVoApi:getrewardList( )
    local showPageIndex = 1
    local pageList = {}
    local pageBgList = {}

    local parent2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function() end)
    parent2:setContentSize(CCSizeMake(width,height))
    parent2:setOpacity(0)
    parent2:setAnchorPoint(ccp(0.5,1))
    parent2:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - self.upHeight - 20)
    self.bgLayer:addChild(parent2,5)
    local pWidth,pHeight = parent2:getContentSize().width,parent2:getContentSize().height

    for i=1,listNum do
    	pageList[i] = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function() end)
	    pageList[i]:setContentSize(CCSizeMake(width,height))
	    pageList[i]:setOpacity(0)
	    pageList[i]:setPosition(i == showPageIndex and pWidth * 0.5 or pWidth * 1.8, pHeight * 0.5)
	    parent2:addChild(pageList[i],5)

	    local showSp = CCSprite:createWithSpriteFrameName("acZncf_tipPic_"..i..".png")
	    showSp:setPosition(width * 0.5,height * 0.6)
	    pageList[i]:addChild(showSp)

	    pageBgList[i] = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function() end)
	    pageBgList[i]:setContentSize(CCSizeMake(20,20))
	    pageBgList[i]:setPosition(width * 0.5,110)
	    pageBgList[i]:setOpacity(150)
	    pageList[i]:addChild(pageBgList[i],1)

	    local pageDesc = GetTTFLabelWrap("",G_isAsia() and 22 or 18,CCSizeMake(width - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    pageDesc:setPosition(width * 0.5,110)
	    pageList[i]:addChild(pageDesc,1)
	    self.pageDescList[i] = pageDesc
	    self.tvHadDataTv[i] = false
	    acZncfVoApi:getCurDesc(i,pageDesc,pageBgList[i],self.tvHadDataTv)
    end

    local pageTurning = false
    local function onPage(flag)
    	-- print("here??????",flag)
        if pageTurning == true then
            do return end
        end
        pageTurning = true
        local pageBg = pageList[showPageIndex]
        showPageIndex = showPageIndex + flag
        if showPageIndex <= 0 then
            showPageIndex = listNum
        end
        if showPageIndex > listNum then
            showPageIndex = 1
        end
        local newPageBg = pageList[showPageIndex]
        
        local cPos = ccp(pageBg:getPosition())
        newPageBg:setPosition(cPos.x + flag * G_VisibleSizeWidth, cPos.y)
        pageBg:runAction(CCMoveTo:create(0.3, ccp(cPos.x - flag * G_VisibleSizeWidth, cPos.y)))
        local arry = CCArray:create()
        arry:addObject(CCMoveTo:create(0.3, cPos))
        arry:addObject(CCMoveTo:create(0.06, ccp(cPos.x - flag * 50, cPos.y)))
        arry:addObject(CCMoveTo:create(0.06, cPos))
        arry:addObject(CCCallFunc:create(function()
                pageTurning = false
                if self.tipSp then
                    self.tipSp:setVisible(false)
                end
                if self.tv then
                	acZncfVoApi:setCurRewardIdx(showPageIndex)
                	self.tv:reloadData()
                end
        end))
        newPageBg:runAction(CCSequence:create(arry))
    end

    local leftArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
    local rightArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
    rightArrowSp:setFlipX(true)
    leftArrowSp:setPosition(-5, 110)
    rightArrowSp:setPosition(width + 5, 110)
    parent2:addChild(leftArrowSp,1)
    parent2:addChild(rightArrowSp,1)
    local leftTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() onPage( - 1) end)
    local rightTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() onPage(1) end)
    leftTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    rightTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    leftTouchArrow:setContentSize(CCSizeMake(leftArrowSp:getContentSize().width + 40, leftArrowSp:getContentSize().height + 60))
    rightTouchArrow:setContentSize(CCSizeMake(rightArrowSp:getContentSize().width + 40, rightArrowSp:getContentSize().height + 60))
    leftTouchArrow:setPosition(leftArrowSp:getPositionX() - 20, leftArrowSp:getPositionY())
    rightTouchArrow:setPosition(rightArrowSp:getPositionX() + 20, rightArrowSp:getPositionY())
    leftTouchArrow:setOpacity(0)
    rightTouchArrow:setOpacity(0)
    parent2:addChild(leftTouchArrow,1)
    parent2:addChild(rightTouchArrow,1)
    
    local function runArrowAction(arrowSp, flag)
        local posX, posY = arrowSp:getPosition()
        local posX2 = posX + flag * 20
        local arry1 = CCArray:create()
        arry1:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
        arry1:addObject(CCFadeIn:create(0.5))
        local spawn1 = CCSpawn:create(arry1)
        
        local arry2 = CCArray:create()
        arry2:addObject(CCMoveTo:create(0.5, ccp(posX2, posY)))
        arry2:addObject(CCFadeOut:create(0.5))
        local spawn2 = CCSpawn:create(arry2)
        
        arrowSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(spawn2, spawn1)))
    end
    runArrowAction(leftArrowSp, - 1)
    runArrowAction(rightArrowSp, 1)

    local pageLayer = CCLayer:create()
    pageLayer:setContentSize(CCSizeMake(width, height))
    pageLayer:setPosition(0,height)
    local touchArray = {}
    local beganPos
    local function touchHandler(fn, x, y, touch)
        if fn == "began" then
            if x >= 0 and x <= width and y <= height and y > 0 then
                return false
            end
            beganPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            return true
        elseif fn == "moved" then
        elseif fn == "ended" then
            if beganPos then
                local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                local moveDisTmp = ccpSub(curPos, beganPos)
                if moveDisTmp.x > 50 then
                    onPage( - 1)
                elseif moveDisTmp.x < - 50 then
                    onPage(1)
                end
            end
            beganPos = nil
        end
    end
    pageLayer:setTouchEnabled(true)
    pageLayer:setBSwallowsTouches(true)
    pageLayer:registerScriptTouchHandler(touchHandler, false, - (self.layerNum - 1) * 20 - 3, true)
    parent2:addChild(pageLayer,1)
end

function acZncfDialog:initBelow()
	local width,height = G_VisibleSizeWidth - 40, G_VisibleSizeHeight - self.upHeight - self.middleHeight - 25
	local tvWidth,tvHeight = width - 20 , height - 22
	self.tvWidth, self.tvHeight = tvWidth,tvHeight
	self.cellHeight = 136
	local belowBg = CCSprite:createWithSpriteFrameName("acZncf_blackBg.png")
	belowBg:setScaleX(width / belowBg:getContentSize().width)
	belowBg:setScaleY(height / belowBg:getContentSize().height)
	belowBg:setAnchorPoint(ccp(0.5, 0))
	belowBg:setPosition(G_VisibleSizeWidth * 0.5, 10)
	self.bgLayer:addChild(belowBg,3)

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function() end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setOpacity(0)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(G_VisibleSizeWidth * 0.5, 18)
    self.bgLayer:addChild(tvBg,4)

    local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
    tipSp:setPosition(tvBg:getContentSize().width + 5,tvBg:getContentSize().height + 5)
    tvBg:addChild(tipSp)
    tipSp:setVisible(false)
    self.tipSp = tipSp

    local function eventHandler( ... )
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(eventHandler)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
	self.tv:setPosition(0,0)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.tv:setMaxDisToBottomOrTop(150)
	tvBg:addChild(self.tv,2)
end
function acZncfDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num = acZncfVoApi:getCurRewardIdxTvRewardAndNum( )
		return num
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(self.tvWidth,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.cell = cell

		local reardTbNum, reardTb = acZncfVoApi:getCurCellRewardData(idx + 1)
		local isHadReward = acZncfVoApi:getTaskRewardState(idx + 1)
		local subTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
        subTitleBg:setContentSize(CCSizeMake(self.tvWidth - 60,34))
        subTitleBg:setAnchorPoint(ccp(0,1))
        subTitleBg:setPosition(4,self.cellHeight - 2)
        cell:addChild(subTitleBg)

        for k,v in pairs(reardTb) do
  			local iconSize = 90
        	local function showPropInfo()
	            G_showNewPropInfo(self.layerNum + 1, true, nil, nil, v, nil, nil, nil, nil, true)
	        end
	        local rewardSp, scale = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
	        rewardSp:setScale(iconSize / rewardSp:getContentSize().width)
	        rewardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
	        rewardSp:setAnchorPoint(ccp(0, 0))
	        rewardSp:setPosition((k-1) * 105 + 10,4)
	        cell:addChild(rewardSp,2)
	        
	        local numLb = GetTTFLabel("x"..FormatNumber(v.num), 22)
	        numLb:setAnchorPoint(ccp(1, 0))
	        numLb:setScale(1 / scale)
	        numLb:setPosition(ccp(rewardSp:getContentSize().width - 5, 2))
	        rewardSp:addChild(numLb, 3)
	        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
	        numBg:setAnchorPoint(ccp(1, 0))
	        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
	        numBg:setPosition(ccp(rewardSp:getContentSize().width - 5, 5))
	        numBg:setOpacity(150)
	        rewardSp:addChild(numBg, 2)
        end

        if self.tvHadDataTv[acZncfVoApi:getCurRewardIdx()] then
        	local subDesc,isCanReward = acZncfVoApi:getCurCellDesc(idx + 1)
        	local subDescLb = GetTTFLabel(subDesc,G_isAsia() and 20 or 17)
        	subDescLb:setColor(G_ColorYellowPro3)
        	subDescLb:setAnchorPoint(ccp(0,0.5))
        	subDescLb:setPosition(15,subTitleBg:getContentSize().height * 0.5)
        	subTitleBg:addChild(subDescLb)

        	if isHadReward then
        		local hadLb = GetTTFLabel(getlocal("activity_hadReward"),G_isAsia() and 23 or 17)
        		hadLb:setPosition(self.tvWidth - 85,self.cellHeight * 0.35)
        		hadLb:setColor(G_ColorGray)
        		cell:addChild(hadLb,3)
        	else
	        	local function getRewardHandle( )
	        		if isHadReward then
	        			do return end
	        		end
	        		local function callback()
	        		 	--加奖励
			            for k, v in pairs(reardTb) do
			                G_addPlayerAward(v.type, v.key, v.id, v.num)
			            end
			            --奖励展示
			            G_showRewardTip(reardTb, true)
                        if self.tipSp then
                            self.tipSp:setVisible(false)
                        end
	        		 	if self.tv then
	        		 		local recordPoint = self.tv:getRecordPoint()
	        		 		self.tv:reloadData()
	        		 		self.tv:recoverToRecordPoint(recordPoint)
	        		 	end
	        		end
	        		acZncfVoApi:rewardSocket(callback,idx + 1)
	        	end
	        	local btnItem,btnMenu = G_createBotton(cell, ccp(self.tvWidth - 85,self.cellHeight * 0.35), {getlocal("daily_scene_get"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", getRewardHandle, 0.7, -(self.layerNum - 1) * 20 - 2, 3)

	        	if not isCanReward or isHadReward then
	        		btnItem:setEnabled(false)
                else
                    local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
                    tipSp:setPosition(btnItem:getContentSize().width,btnItem:getContentSize().height)
                    btnItem:addChild(tipSp)
                    if self.tipSp then
                        self.tipSp:setVisible(true)
                    end
	        	end
	        end
        end
		return cell
	end
end