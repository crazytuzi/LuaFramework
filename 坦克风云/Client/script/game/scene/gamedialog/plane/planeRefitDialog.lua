planeRefitDialog = commonDialog:new()

function planeRefitDialog:new(layerNum, placeId, planeId)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.curSelectedPlaceId = placeId or 1
    self.curSelectedPlaneId = planeId or "p1"
    G_addResource8888(function()
    	spriteController:addPlist("public/planeRefit_skillIcons.plist")
    	spriteController:addTexture("public/planeRefit_skillIcons.png")
    	spriteController:addPlist("public/nbSkill.plist")
    	spriteController:addTexture("public/nbSkill.png")
    	spriteController:addPlist("public/rewardCenterImage.plist")
    	spriteController:addTexture("public/rewardCenterImage.png")
    	spriteController:addPlist("public/newButton180711.plist")
    	spriteController:addTexture("public/newButton180711.png")
    end)
    return nc
end

function planeRefitDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    if self.panelBottomLine then
        self.panelBottomLine:setVisible(false)
    end

    local placeRowHeight = 100
    if G_getIphoneType() == G_iphone4 then
    	placeRowHeight = 70
    end
    local function onClickInfo(tag, obj)
    	if G_checkClickEnable() == false then
			do return end
		else
			base.setWaitTime = G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local itemName = ""
		local pid = planeRefitVoApi:getRefitCostPropId()
	    if pid then
	    	local item = FormatItem({p = {[pid] = 0}})[1]
	    	if item and item.name then
	    		itemName = item.name
	    	end
	    end
		local tabStr = { 
			getlocal("planeRefit_infoDesc1", {itemName}),
			getlocal("planeRefit_infoDesc2", {itemName}),
			getlocal("planeRefit_infoDesc3"),
			getlocal("planeRefit_infoDesc4"),
		}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickInfo)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    infoBtn:setPosition(G_VisibleSizeWidth - infoItem:getContentSize().width / 2 - 20, G_VisibleSizeHeight - 82 - placeRowHeight / 2)
    self.bgLayer:addChild(infoBtn, 2)
    local placeLb = GetTTFLabel(getlocal("planeRefit_place"), 24)
    placeLb:setAnchorPoint(ccp(0, 0.5))
    placeLb:setPosition(20, G_VisibleSizeHeight - 82 - placeRowHeight / 2)
    placeLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(placeLb, 2)

    local placeData = planeRefitVoApi:getPlaceData()
    local placeTvSize = CCSizeMake(infoBtn:getPositionX() - infoItem:getContentSize().width / 2 - 10 - placeLb:getPositionX() - placeLb:getContentSize().width - 10, placeRowHeight)
    local placeTempTb = {}
    local placeTv = G_createTableView(placeTvSize, SizeOfTable(placeData), CCSizeMake(80, placeRowHeight), function(cell, cellSize, idx, cellNum)
    	local data = placeData[idx + 1]
    	if data == nil then
    		do return end
    	end
    	local iconPic = (data.placeId == self.curSelectedPlaceId) and data.icon or data.icon2
    	local placeIcon = LuaCCSprite:createWithSpriteFrameName(iconPic, function()
    		local isUnlockPlace, unlockValue = planeRefitVoApi:isUnlockByPlaceId(data.placeId)
    		if isUnlockPlace == false then
    			G_showTipsDialog(getlocal("planeRefit_placeUnlockTips", {unlockValue, getlocal(data.placeName)}))
    			do return end
    		end
    		if self.curSelectedPlaceId == data.placeId then
    			do return end
    		end
    		for k, v in pairs(placeTempTb) do
    			local iconSp, iconData = v[1], v[2]
    			if data.placeId == k then
    				iconSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconData.icon))
    				self.curSelectedPlaceId = data.placeId
    			else
    				iconSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconData.icon2))
    			end
    		end
    		self:refreshMiddleUI()
    	end)
    	placeIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    	placeIcon:setPosition(cellSize.width / 2, cellSize.height / 2)
    	cell:addChild(placeIcon)
    	placeTempTb[data.placeId] = { placeIcon, data }
    end, true)
    placeTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    placeTv:setPosition(placeLb:getPositionX() + placeLb:getContentSize().width + 10, G_VisibleSizeHeight - 82 - placeRowHeight)
    -- placeTv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(placeTv, 2)

    local topBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("pri_bg2.png", CCRect(0, 48, 640, 2), function()end)
    topBgSp:setContentSize(CCSizeMake(topBgSp:getContentSize().width, placeRowHeight + topBgSp:getContentSize().height))
    topBgSp:setAnchorPoint(ccp(0.5, 1))
    topBgSp:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 80 - topBgSp:getContentSize().height)
    topBgSp:setRotation(180)
    local bgSp
    G_addResource8888(function()
    	bgSp = CCSprite:create("public/pri_refitBg.png")
    end)
    bgSp:setAnchorPoint(ccp(0.5, 1))
    local bgSpPosY = topBgSp:getPositionY()
    if G_getIphoneType() == G_iphone4 then
    	bgSpPosY = topBgSp:getPositionY() + 55
    end
    bgSp:setPosition(G_VisibleSizeWidth / 2, bgSpPosY)
    self.bgLayer:addChild(bgSp)
    self.bgLayer:addChild(topBgSp)
    local bottomBgSpHeight = bgSpPosY - bgSp:getContentSize().height
    local bottomBgSpPosY = bgSpPosY - bgSp:getContentSize().height
    if G_getIphoneType() == G_iphone4 then
    	bottomBgSpHeight = bgSpPosY - bgSp:getContentSize().height + 55
    	bottomBgSpPosY = bgSpPosY - bgSp:getContentSize().height + 55
    end
    local bottomBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("pri_bg2.png", CCRect(0, 48, 640, 2), function()end)
    bottomBgSp:setContentSize(CCSizeMake(bottomBgSp:getContentSize().width, bottomBgSpHeight))
    bottomBgSp:setAnchorPoint(ccp(0.5, 1))
    bottomBgSp:setPosition(G_VisibleSizeWidth / 2, bottomBgSpPosY)
    self.bgLayer:addChild(bottomBgSp)
    self.bgSp = bgSp
    self:initMiddleUI()
    self:initBottomUI()

  	self.listenerFunc = function(eventKey, eventData)
  		if self and type(eventData) == "table" and (eventData.eventType == 1 or eventData.eventType == 2) then
  			local effectType
  			if eventData.params and eventData.params.effectType then
  				effectType = eventData.params.effectType
  			end
		  	self:refreshMiddleUI(effectType)
			self:refreshBottomItemNum()
			local surplusLb = tolua.cast(self.surplusLb, "CCLabelTTF")
			if surplusLb then
				local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
				surplusLb:setString(getlocal("equip_explore_num", {surplusCount}))
			end
		end
  	end
  	planeRefitVoApi:addEventListener(self.listenerFunc)

  	--添加战力值变化的监听
  	self.powerChangeListener = function(eventKey, eventData)
  		G_showNumberChange(eventData[1], eventData[2])
 	end
  	eventDispatcher:addEventListener("user.power.change", self.powerChangeListener)
end

function planeRefitDialog:initPageLayer(pageLayerSize, pageLayerPos, onPageCallback)
	local pageLayer = CCLayer:create()
	pageLayer:setContentSize(pageLayerSize)
    pageLayer:setPosition(pageLayerPos)
    local touchArray = {}
    local beganPos
    local function touchHandler(fn, x, y, touch)
        if fn == "began" then
            if x >= pageLayer:getPositionX() and x <= pageLayer:getPositionX() + pageLayer:getContentSize().width and y >= pageLayer:getPositionY() and y <= pageLayer:getPositionY() + pageLayer:getContentSize().height then
                table.insert(touchArray, touch)
                if SizeOfTable(touchArray) > 1 then
                    touchArray = {}
                    return false
                else
                    beganPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                    return true
                end
            end
            return false
        elseif fn == "moved" then
        elseif fn == "ended" then
            if beganPos then
                local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                local moveDisTmp = ccpSub(curPos, beganPos)
                if moveDisTmp.x > 50 then
                	if type(onPageCallback) == "function" then
                		onPageCallback(-1)
                	end
                elseif moveDisTmp.x < - 50 then
                    if type(onPageCallback) == "function" then
                    	onPageCallback(1)
                    end
                end
            end
            beganPos = nil
            touchArray = {}
        else
            touchArray = {}
        end
    end
    pageLayer:setTouchEnabled(true)
    pageLayer:setBSwallowsTouches(true)
    pageLayer:registerScriptTouchHandler(touchHandler, false, - (self.layerNum - 1) * 20 - 1, true)
    self.bgLayer:addChild(pageLayer)

    local offset = 20
    local leftArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
    leftArrowSp:setPosition(leftArrowSp:getContentSize().width / 2 + offset, pageLayer:getContentSize().height / 2)
    pageLayer:addChild(leftArrowSp)
    local rightArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
    rightArrowSp:setFlipX(true)
    rightArrowSp:setPosition(pageLayer:getContentSize().width - rightArrowSp:getContentSize().width / 2 - offset, pageLayer:getContentSize().height / 2)
    pageLayer:addChild(rightArrowSp)
    local function runArrowAction(arrowSp, flag)
        local posX, posY = arrowSp:getPosition()
        local posX2 = posX + flag * offset
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

    local leftTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if type(onPageCallback) == "function" then onPageCallback(-1) end end)
    local rightTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if type(onPageCallback) == "function" then onPageCallback(1) end end)
    leftTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    rightTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    leftTouchArrow:setContentSize(CCSizeMake(leftArrowSp:getContentSize().width + 40, leftArrowSp:getContentSize().height + 50))
    rightTouchArrow:setContentSize(CCSizeMake(rightArrowSp:getContentSize().width + 40, rightArrowSp:getContentSize().height + 50))
    leftTouchArrow:setPosition(leftArrowSp:getPositionX(), leftArrowSp:getPositionY())
    rightTouchArrow:setPosition(rightArrowSp:getPositionX(), rightArrowSp:getPositionY())
    leftTouchArrow:setOpacity(0)
    rightTouchArrow:setOpacity(0)
    pageLayer:addChild(leftTouchArrow)
    pageLayer:addChild(rightTouchArrow)
end

function planeRefitDialog:initMiddleUI()
	if self.bgSp == nil then
		do return end
	end
	local bgSpSize = self.bgSp:getContentSize()
	local pVo = planeVoApi:getPlaneVoById(self.curSelectedPlaneId)
	local planeSp = CCSprite:createWithSpriteFrameName(pVo:getPic())
	planeSp:setPosition(bgSpSize.width / 2, bgSpSize.height / 2)
	planeSp:setScale(0.75)
	self.bgSp:addChild(planeSp)

	local showPageIndex = pVo.idx
	local planeList = planeVoApi:getPlaneList()
	local planeListSize = SizeOfTable(planeList)
	local pageTurning = false

	local pageLayerSize = CCSizeMake(G_VisibleSizeWidth, 300)
	local pageLayerPos = ccp((G_VisibleSizeWidth - pageLayerSize.width) / 2, self.bgSp:getPositionY() - bgSpSize.height / 2 - pageLayerSize.height / 2)
	self:initPageLayer(pageLayerSize, pageLayerPos, function(direction)
		if pageTurning == true then
            do return end
        end
        pageTurning = true
        showPageIndex = showPageIndex + direction
        if showPageIndex <= 0 then
            showPageIndex = planeListSize
        end
        if showPageIndex > planeListSize then
            showPageIndex = 1
        end
        local cPos = ccp(planeSp:getPosition())
        local nextPlaneVo = planeList[showPageIndex]
        local nextPlaneSp = CCSprite:createWithSpriteFrameName(nextPlaneVo:getPic())
        nextPlaneSp:setPosition(cPos.x + direction * pageLayerSize.width, cPos.y)
        nextPlaneSp:setScale(0.75)
        self.bgSp:addChild(nextPlaneSp)
        planeSp:runAction(CCMoveTo:create(0.3, ccp(cPos.x - direction * pageLayerSize.width, cPos.y)))
        local arry = CCArray:create()
        arry:addObject(CCMoveTo:create(0.3, cPos))
        arry:addObject(CCMoveTo:create(0.06, ccp(cPos.x - direction * 50, cPos.y)))
        arry:addObject(CCMoveTo:create(0.06, cPos))
        arry:addObject(CCCallFunc:create(function()
        	planeSp:removeFromParentAndCleanup(true)
        	planeSp = nil
        	planeSp = nextPlaneSp
        	self.curSelectedPlaneId = nextPlaneVo.pid
        	self:refreshMiddleUI()
        	pageTurning = false
        end))
        nextPlaneSp:runAction(CCSequence:create(arry))
	end)

	local function onClickPandect(tag, obj)
		if G_checkClickEnable() == false then
			do return end
		else
			base.setWaitTime = G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		planeRefitVoApi:showAttributePandectSmallDialog(self.layerNum + 1, {self.curSelectedPlaceId, self.curSelectedPlaneId})
	end
	local pandectBtn = GetButtonItem("csi_searchBtn.png", "csi_searchBtn_down.png", "csi_searchBtn.png", onClickPandect)
	pandectBtn:setAnchorPoint(ccp(1, 1))
	local pandectMenu = CCMenu:createWithItem(pandectBtn)
	pandectMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	pandectMenu:setPosition(bgSpSize.width - 20, bgSpSize.height - ((G_getIphoneType() == G_iphone4) and 55 or 25))
	self.bgSp:addChild(pandectMenu)

	local isHaveRefitTempExp = planeRefitVoApi:isHaveRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
	local barBgTopPosY = 120
	if G_getIphoneType() == G_iphone4 then
		barBgTopPosY = 130
	end
	local expProgressBarBg = CCSprite:createWithSpriteFrameName("pri_progressBarBg.png")
	expProgressBarBg:setPosition(bgSpSize.width / 2, bgSpSize.height - barBgTopPosY)
	expProgressBarBg:setTag(3)
	self.bgSp:addChild(expProgressBarBg)
	local expProgressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("pri_progressBar.png"))
	expProgressBar:setType(kCCProgressTimerTypeBar)
	expProgressBar:setMidpoint(ccp(0, 1))
	expProgressBar:setBarChangeRate(ccp(1, 0))
	expProgressBar:setPosition(expProgressBarBg:getContentSize().width / 2, expProgressBarBg:getContentSize().height / 2)
	expProgressBar:setTag(1)
	expProgressBarBg:addChild(expProgressBar, 1)
	local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
	local maxRefitExp = planeRefitVoApi:getRefitMaxExp(level)
	local usedRefitExp = planeRefitVoApi:getRefitExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
	local surplusRefitExp = maxRefitExp - usedRefitExp
	expProgressBar:setPercentage(surplusRefitExp / maxRefitExp * 100)
	local tempRefitExpLb = GetTTFLabel("", 20, true)
	tempRefitExpLb:setPosition(expProgressBar:getPositionX(), - 13)
	tempRefitExpLb:setTag(2)
	expProgressBarBg:addChild(tempRefitExpLb, 1)
	tempRefitExpLb:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(2.5, 55), CCFadeTo:create(2.5, 255))))
	if isHaveRefitTempExp then
		local tempRefitExp = planeRefitVoApi:getRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
		if tempRefitExp then
			tempRefitExpLb:setString((tempRefitExp > 0) and ("-" .. tempRefitExp) or ("+" .. ((tempRefitExp == 0) and 1 or -1) * tempRefitExp))
			tempRefitExpLb:setColor((tempRefitExp > 0) and G_ColorRed or G_ColorGreen)
		end
		--start ^_^ 进度值的变动效果
		if tempRefitExp and tempRefitExp ~= 0 then
			local tempExpPercentage
			if tempRefitExp < 0 then
				tempExpPercentage = (surplusRefitExp - tempRefitExp) / maxRefitExp
				if tempExpPercentage > 1 then
					tempExpPercentage = 1
				end
			else
				local expPer = (surplusRefitExp - tempRefitExp) / maxRefitExp * 100
				if expPer < 0 then
					expPer = 0
				end
				expProgressBar:setPercentage(expPer)
				tempExpPercentage = surplusRefitExp / maxRefitExp
			end
			local tempExpProgressSp
			G_addResource8888(function()
				tempExpProgressSp = CCSprite:create("public/pri_texture_progressBar.png")
			end)
			tempExpProgressSp:setAnchorPoint(ccp(0, 0.5))
			tempExpProgressSp:setPosition(0, expProgressBar:getPositionY())
			tempExpProgressSp:setTag(3)
			expProgressBarBg:addChild(tempExpProgressSp)
			tempExpProgressSp:setColor(tempRefitExp > 0 and ccc3(201, 53, 44) or ccc3(27, 212, 91))
			tempExpProgressSp:setTextureRect(CCRect(0, 0, tempExpProgressSp:getContentSize().width * tempExpPercentage, tempExpProgressSp:getContentSize().height))
			tempExpProgressSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.3, 0), CCFadeTo:create(0.3, 200))))
		end
		--end ^_^ 进度值的变动效果
	end
	local surplusRefitExpLb = GetTTFLabel(getlocal("expeditionRaidLeftNum", {surplusRefitExp .. "/" .. maxRefitExp}), 22)
	surplusRefitExpLb:setAnchorPoint(ccp(0.5, 0))
	surplusRefitExpLb:setPosition(bgSpSize.width / 2, expProgressBarBg:getPositionY() + expProgressBarBg:getContentSize().height / 2 + 5)
	surplusRefitExpLb:setTag(2)
	self.bgSp:addChild(surplusRefitExpLb)
	local placeName = planeRefitVoApi:getPlaceName(self.curSelectedPlaceId) .. "-" .. getlocal("planeRefit_energyText") .. getlocal("fightLevel", {level})
	local placeNameLb = GetTTFLabelWrap(placeName, 22, CCSizeMake(350, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
	placeNameLb:setAnchorPoint(ccp(0.5, 0))
	placeNameLb:setPosition(bgSpSize.width / 2, surplusRefitExpLb:getPositionY() + surplusRefitExpLb:getContentSize().height + 5)
	local color = planeRefitVoApi:getLevelColor(level)
	if color then
		placeNameLb:setColor(color)
	end
	placeNameLb:setTag(1)
	self.bgSp:addChild(placeNameLb)

	local yPosSpace = 130
	if G_getIphoneType() == G_iphone4 then
		yPosSpace = 120
	end
	for i = 1, 4 do
		local refitTypeIconBg = CCSprite:createWithSpriteFrameName("pri_refitTypeIconBg.png")
		local xPos, yPos = (i % 2 == 0) and 1 or -1, (i > 2) and -1 or 1
		refitTypeIconBg:setPosition(bgSpSize.width / 2 + xPos * 150 + xPos * refitTypeIconBg:getContentSize().width / 2, bgSpSize.height / 2 + yPos * yPosSpace + yPos * refitTypeIconBg:getContentSize().height / 2)
		refitTypeIconBg:setTag(100 + i)
		self.bgSp:addChild(refitTypeIconBg)
		local refitTypeIcon = LuaCCSprite:createWithSpriteFrameName("pri_refitTypeIcon" .. i .. ".png", function()
			print("cjl ------->>> 查看改装类型技能能信息")
			planeRefitVoApi:showAttributeDetailsSmallDialog(self.layerNum + 1, {self.curSelectedPlaceId, self.curSelectedPlaneId, i})
		end)
		refitTypeIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		refitTypeIcon:setPosition(refitTypeIconBg:getContentSize().width / 2, refitTypeIconBg:getContentSize().height / 2)
		refitTypeIcon:setTag(1)
		refitTypeIconBg:addChild(refitTypeIcon)
		local refitTypeData = planeRefitVoApi:getRefitTypeData(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
		local refitExp = planeRefitVoApi:getRefitExp(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
		local circleBottomPos = ccp(refitTypeIconBg:getContentSize().width / 2, 0)
        local circleRadius = refitTypeIconBg:getContentSize().width / 2 -- 61.5 --根据图片的弧度而定
		for j = 1, 3 do
			local progressBarBg = CCSprite:createWithSpriteFrameName("pri_circle_progressBarBg.png")
			progressBarBg:setAnchorPoint(ccp(0.5, 0))
			local circleRadiusAngle = -90 --依据数学坐标系，该资源的默认半径角度为-90，若修改图片资源时切忌要修正此数值
			if j == 1 then
				progressBarBg:setRotation(- 360 / 3)
				circleRadiusAngle = circleRadiusAngle + 360 / 3
			elseif j == 2 then
			elseif j == 3 then
				progressBarBg:setRotation(360 / 3)
				circleRadiusAngle = circleRadiusAngle - 360 / 3
			end
			progressBarBg:setPosition(G_getPointOfCircle(circleBottomPos, circleRadius, circleRadiusAngle))
			progressBarBg:setTag(100 + j)
			refitTypeIconBg:addChild(progressBarBg)
			local progressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("pri_circle_progressBar.png"))
			--圆形进度条
	        -- progressBar:setType(kCCProgressTimerTypeRadial)
	        -- progressBar:setMidpoint(ccp(0.5, 0.999))
	        --方形进度条
	        progressBar:setType(kCCProgressTimerTypeBar)
	        progressBar:setMidpoint(ccp(1, 0))
	        progressBar:setBarChangeRate(ccp(1, 0))
	        progressBar:setAnchorPoint(ccp(0.5, 0))
	        progressBar:setPosition(progressBarBg:getContentSize().width / 2, 0)
	        progressBar:setTag(1)
	        progressBarBg:addChild(progressBar, 1)
	        local percentage = planeRefitVoApi:getRefitPercentageByIndex(refitTypeData, refitExp, j)
	        progressBar:setPercentage(percentage)
	        --start ^_^ 进度值的变动效果，目前由于数值变动很小，所以几乎看不出啥效果来，后续再酌情考虑要不要该效果了
	        if isHaveRefitTempExp then
	        	local tempExp = planeRefitVoApi:getRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
				if tempExp and tempExp ~= 0 then
					local newPercentage = planeRefitVoApi:getRefitPercentageByIndex(refitTypeData, refitExp + tempExp, j)
					local tempPercentage
					if tempExp > 0 then
						if percentage < 100 then
							tempPercentage = newPercentage / 100
						end
					else
						progressBar:setPercentage(newPercentage)
						tempPercentage = percentage / 100
					end
					if tempPercentage and tempPercentage ~= 0 then
						local tempProgressSp
						G_addResource8888(function()
							tempProgressSp = CCSprite:create("public/pri_texture_circle_progressBar.png")
						end)
						tempProgressSp:setAnchorPoint(ccp(1, 0))
						tempProgressSp:setPosition(progressBarBg:getContentSize().width, 0)
						tempProgressSp:setTag(2)
						progressBarBg:addChild(tempProgressSp)
						tempProgressSp:setColor(tempExp >= 0 and ccc3(27, 212, 91) or ccc3(201, 53, 44))
						tempProgressSp:setTextureRect(CCRect(tempProgressSp:getContentSize().width * (1 - tempPercentage), 0, tempProgressSp:getContentSize().width * tempPercentage, tempProgressSp:getContentSize().height))
						tempProgressSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.3, 50), CCFadeTo:create(0.3, 200))))
					end
				end
	        end
	        --end ^_^ 进度值的变动效果，目前由于数值变动很小，所以几乎看不出啥效果来，后续再酌情考虑要不要该效果了
		end
		local unlockSp
		unlockSp = LuaCCSprite:createWithSpriteFrameName("pri_unlockIcon.png", function()
			local lockSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_lockIcon.png")
			local unlockSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_unlockIcon.png")
			if unlockSp:isFrameDisplayed(unlockSpriteFrame) then
				local lockCount = self:getCurLockCount()
				if lockCount >= 3 then
					G_showTipsDialog(getlocal("planeRefit_lockErrorTips"))
					do return end
				end
				print("cjl -------->>> 上锁")
				unlockSp:setDisplayFrame(lockSpriteFrame)
				self:lockStateLogic(1, i)
			elseif unlockSp:isFrameDisplayed(lockSpriteFrame) then
				print("cjl -------->>> 开锁")
				unlockSp:setDisplayFrame(unlockSpriteFrame)
				self:lockStateLogic(2, i)
			end
		end)
		unlockSp:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		unlockSp:setAnchorPoint(ccp((i % 2 == 0) and 0 or 1, 0.5))
		unlockSp:setPosition((i % 2 == 0) and refitTypeIconBg:getContentSize().width or 0, refitTypeIconBg:getContentSize().height / 2)
		unlockSp:setTag(2)
		refitTypeIconBg:addChild(unlockSp)
		local refitTempExpLb = GetTTFLabel("", 24, true)
		refitTempExpLb:setAnchorPoint(ccp(0.5, 0))
		refitTempExpLb:setPosition(refitTypeIconBg:getContentSize().width / 2, 10)
		refitTempExpLb:setTag(3)
		refitTypeIconBg:addChild(refitTempExpLb)
		refitTempExpLb:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(2.5, 55), CCFadeTo:create(2.5, 255))))
		if isHaveRefitTempExp then
			local tempExp = planeRefitVoApi:getRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
			if tempExp then
				refitTempExpLb:setString((tempExp < 0) and tostring(tempExp) or ("+" .. tempExp))
				refitTempExpLb:setColor((tempExp < 0) and G_ColorRed or G_ColorGreen)
			end
		end
		local refitExpLb = GetTTFLabel(refitExp .. "/" .. refitTypeData.powerMax, 22, true)
		refitExpLb:setAnchorPoint(ccp(0.5, 1))
		refitExpLb:setPosition(refitTypeIconBg:getContentSize().width / 2, - 5)
		refitExpLb:setTag(4)
		refitTypeIconBg:addChild(refitExpLb)
		if i == 1 then
			if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 87 then
				otherGuideMgr:setGuideStepField(88, refitTypeIconBg, true)
    			otherGuideMgr:toNextStep()
			end
		end
	end
end

--@stateType: 1-上锁,2-开锁
function planeRefitDialog:lockStateLogic(stateType, index)
	if stateType == 1 then
		if self.lockStateTb == nil then
			self.lockStateTb = {}
		end
		if self.lockStateTb[self.curSelectedPlaceId] == nil then
			self.lockStateTb[self.curSelectedPlaceId] = {}
		end
		if self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId] == nil then
			self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId] = {}
		end
		self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId][index] = true
		self:refreshBottomItemNum()
		G_showTipsDialog(getlocal("planeRefit_refitLockSuccessTips", {planeRefitVoApi:getRefitTypeName(self.curSelectedPlaceId, self.curSelectedPlaneId, index)}))
	elseif stateType == 2 then
		if self.lockStateTb and self.lockStateTb[self.curSelectedPlaceId] and self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId] then
			self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId][index] = nil
		end
		self:refreshBottomItemNum()
		G_showTipsDialog(getlocal("planeRefit_refitLockCancelTips", {planeRefitVoApi:getRefitTypeName(self.curSelectedPlaceId, self.curSelectedPlaneId, index)}))
	end
end

function planeRefitDialog:initBottomUI()
	local function onClickHandler(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
        	local isHaveRefitTempExp, tempExpChangeTb = planeRefitVoApi:isHaveRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
        	if isHaveRefitTempExp == false then
        		G_showTipsDialog(getlocal("planeRefit_refitSaveErrorTips"))
        		do return end
        	end
        	print("cjl ---------->>> 保存")
        	self.tempExpChangeTb = tempExpChangeTb
        	local prevRefitExpTb = planeRefitVoApi:getRefitExpTb(self.curSelectedPlaceId, self.curSelectedPlaneId)
        	local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
        	planeRefitVoApi:requestSaveRefit(function()
        		local eventType = 1
        		local newLevel = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
        		if newLevel > level then
        			eventType = 2
        			G_showTipsDialog(getlocal("planeRefit_energyUpgradeTips", {getlocal("fightLevel", {newLevel})}))
        		end
        		local skillIdTb
        		local rtData = planeRefitVoApi:getRefitTypeData(self.curSelectedPlaceId, self.curSelectedPlaneId)
        		if rtData then
        			skillIdTb = {}
        			for k, v in pairs(rtData) do
        				table.insert(skillIdTb, v.skill1)
        				for kk, vv in pairs(v.skill2) do
        					table.insert(skillIdTb, vv)
        				end
        			end
        		end
        		planeRefitVoApi:dispatchEvent(eventType, skillIdTb, {effectType = 2})
        		planeRefitVoApi:checkSkillState(self.curSelectedPlaceId, self.curSelectedPlaneId, prevRefitExpTb)
        	end, self.curSelectedPlaceId, self.curSelectedPlaneId)
        elseif tag == 11 then
        	print("cjl ---------->>> 自动改装")
        	planeRefitVoApi:showAutoRefitDialog(self.layerNum + 1, self)
        elseif tag == 12 then
        	local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
        	if surplusCount <= 0 then
        		G_showTipsDialog(getlocal("planeRefit_refitCountDissatisfy"))
        		do return end
        	end
        	local lockIndexTb = {}
        	local needNum = planeRefitVoApi:getRefitCostPropNum(self:getCurLockCount(lockIndexTb))
			if self.refitCostItem and self.refitCostItem.num < needNum then
				-- G_showTipsDialog(getlocal("planeRefit_refitItemDissatisfy"))
				local function onBuyHander(buyNum)
		    		print("cjl --------->>> 购买消耗道具", buyNum)
		    		local function socketCallback(fn, data)
						local ret, sData = base:checkServerData(data)
				        if ret == true then
				        	G_showTipsDialog(getlocal("buyPropPrompt", {self.refitCostItem.name}))
				        	self:refreshBottomItemNum()
				        end
					end
		    		socketHelper:buyProc(self.refitCostItem.id, socketCallback, buyNum)
		    	end
		    	shopVoApi:showBatchBuyPropSmallDialog(self.refitCostItem.key, self.layerNum + 1, onBuyHander)
				do return end
			end
        	print("cjl ---------->>> 改装")
        	planeRefitVoApi:requestRefit(function()
        		self:refreshMiddleUI(1)
        		if self.refitCostItem then
        			bagVoApi:useItemNumId(self.refitCostItem.id, needNum)
        			self.refitCostItem.num = self.refitCostItem.num - needNum
        		end
        		self:refreshBottomItemNum()
        		local surplusLb = tolua.cast(self.surplusLb, "CCLabelTTF")
        		if surplusLb then
        			local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
    				surplusLb:setString(getlocal("equip_explore_num", {surplusCount}))
    			end
        	end, self.curSelectedPlaceId, self.curSelectedPlaneId, lockIndexTb)
        end
	end
	local btnScale, btnFontSize = 0.7, 24
    if G_getCurChoseLanguage() == "de" then
        btnFontSize = 22
    end
	local saveBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("collect_border_save"), btnFontSize / btnScale)
	local autoRefitBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("planeRefit_autoRefit"), btnFontSize / btnScale)
	local refitBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("planeRefit_refitText"), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(saveBtn)
    menuArr:addObject(autoRefitBtn)
    menuArr:addObject(refitBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.bgLayer:addChild(btnMenu, 2)
    saveBtn:setScale(btnScale)
    autoRefitBtn:setScale(btnScale)
    refitBtn:setScale(btnScale)
    local btnBottomSpace = 50
    autoRefitBtn:setPosition(G_VisibleSizeWidth / 2 - autoRefitBtn:getContentSize().width * btnScale / 2 - 135, btnBottomSpace + autoRefitBtn:getContentSize().height * btnScale / 2)
    saveBtn:setPosition(G_VisibleSizeWidth / 2, btnBottomSpace + saveBtn:getContentSize().height * btnScale / 2)
    refitBtn:setPosition(G_VisibleSizeWidth / 2 + refitBtn:getContentSize().width * btnScale / 2 + 135, btnBottomSpace + refitBtn:getContentSize().height * btnScale / 2)

    local pid = planeRefitVoApi:getRefitCostPropId()
    if pid then
    	local item = FormatItem({p = {[pid] = 0}})[1]
    	item.num = bagVoApi:getItemNumId(item.id)
    	local iconSize = 35
    	local itemIcon, iconScale = G_getItemIcon(item, 100, false, self.layerNum, function()
	        G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
	    end)
	    itemIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	    itemIcon:setScale(iconSize / itemIcon:getContentSize().height)
	    iconScale = itemIcon:getScale()
	    itemIcon:setPosition(refitBtn:getPositionX() - iconSize / 2 - 10, refitBtn:getPositionY() + refitBtn:getContentSize().height * btnScale / 2 + iconSize / 2 + 5)
	    self.bgLayer:addChild(itemIcon)
	    local numLb = GetTTFLabel(item.num, 22)
	    numLb:setAnchorPoint(ccp(0, 0.5))
	    numLb:setPosition(itemIcon:getPositionX() + iconSize / 2 + 3, itemIcon:getPositionY())
	    self.bgLayer:addChild(numLb)
	    local needNum = planeRefitVoApi:getRefitCostPropNum(self:getCurLockCount())
	    if item.num < needNum then
	    	numLb:setColor(G_ColorRed)
	    else
	    	numLb:setColor(G_ColorGreen)
	    end
	    local needNumLb = GetTTFLabel("/" .. needNum, 22)
	    needNumLb:setAnchorPoint(ccp(0, 0.5))
	    needNumLb:setPosition(numLb:getPositionX() + numLb:getContentSize().width, numLb:getPositionY())
	    self.bgLayer:addChild(needNumLb)
	    self.numLb = numLb
	    self.needNumLb = needNumLb
	    self.refitCostItem = item
    end
    local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
    local surplusLbWidth = (G_VisibleSizeWidth - refitBtn:getPositionX()) * 2
    local surplusLbFontSize = 22
    if (G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "fr") and G_isIOS() == false then
        surplusLbFontSize = 20
    elseif G_getCurChoseLanguage() == "ar" then
        surplusLbFontSize = 18
    end
    local surplusLb = GetTTFLabelWrap(getlocal("equip_explore_num", {surplusCount}), surplusLbFontSize, CCSizeMake(surplusLbWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    surplusLb:setAnchorPoint(ccp(0.5, 1))
    surplusLb:setPosition(refitBtn:getPositionX(), refitBtn:getPositionY() - refitBtn:getContentSize().height * btnScale / 2)
    self.bgLayer:addChild(surplusLb)
    self.surplusLb = surplusLb
end

--@effectType : 效果类型(1-点击改装按钮时的效果,2-点击保存按钮时的效果)
function planeRefitDialog:refreshMiddleUI(effectType)
	if self.bgSp == nil then
		do return end
	end
	local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
	local placeNameLb = tolua.cast(self.bgSp:getChildByTag(1), "CCLabelTTF")
	if placeNameLb then
		placeNameLb:setString(planeRefitVoApi:getPlaceName(self.curSelectedPlaceId) .. "-" .. getlocal("planeRefit_energyText") .. getlocal("fightLevel", {level}))
		local color = planeRefitVoApi:getLevelColor(level)
		if color then
			placeNameLb:setColor(color)
		end
	end
	local isHaveRefitTempExp = planeRefitVoApi:isHaveRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
	local maxRefitExp = planeRefitVoApi:getRefitMaxExp(level)
	local usedRefitExp = planeRefitVoApi:getRefitExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
	local surplusRefitExp = maxRefitExp - usedRefitExp
	local surplusRefitExpLb = tolua.cast(self.bgSp:getChildByTag(2), "CCLabelTTF")
	if surplusRefitExpLb then
		if effectType == 2 then
			surplusRefitExpLb:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.3), CCScaleTo:create(0.3, 1)))
		else
			surplusRefitExpLb:stopAllActions()
			surplusRefitExpLb:setScale(1)
		end
		surplusRefitExpLb:setString(getlocal("expeditionRaidLeftNum", {surplusRefitExp .. "/" .. maxRefitExp}))
	end
	local expProgressBarBg = tolua.cast(self.bgSp:getChildByTag(3), "CCSprite")
	if expProgressBarBg then
		local tempRefitExpLb = tolua.cast(expProgressBarBg:getChildByTag(2), "CCLabelTTF")
		if tempRefitExpLb then
			tempRefitExpLb:setString("")
		end
		local tempExpProgressSp = tolua.cast(expProgressBarBg:getChildByTag(3), "CCSprite")
		if tempExpProgressSp then
			tempExpProgressSp:removeFromParentAndCleanup(true)
			tempExpProgressSp = nil
		end
		local expProgressBar = tolua.cast(expProgressBarBg:getChildByTag(1), "CCProgressTimer")
		if expProgressBar then
			expProgressBar:setPercentage(surplusRefitExp / maxRefitExp * 100)
			if isHaveRefitTempExp then
				local tempRefitExp = planeRefitVoApi:getRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId)
				if tempRefitExp and tempRefitExpLb then
					if effectType == 1 then
						local lbSeqArr = CCArray:create()
						lbSeqArr:addObject(CCScaleTo:create(0.1, 2))
						lbSeqArr:addObject(CCScaleTo:create(0.3, 1))
						tempRefitExpLb:runAction(CCSequence:create(lbSeqArr))
					else
						tempRefitExpLb:stopAllActions()
						tempRefitExpLb:setScale(1)
						tempRefitExpLb:setVisible(true)
					end
					tempRefitExpLb:setString((tempRefitExp > 0) and ("-" .. tempRefitExp) or ("+" .. ((tempRefitExp == 0) and 1 or -1) * tempRefitExp))
					tempRefitExpLb:setColor((tempRefitExp > 0) and G_ColorRed or G_ColorGreen)
				end
				--start ^_^ 进度值的变动效果
				if tempRefitExp and tempRefitExp ~= 0 then
					local tempExpPercentage
					if tempRefitExp < 0 then
						tempExpPercentage = (surplusRefitExp - tempRefitExp) / maxRefitExp
						if tempExpPercentage > 1 then
							tempExpPercentage = 1
						end
					else
						local expPer = (surplusRefitExp - tempRefitExp) / maxRefitExp * 100
						if expPer < 0 then
							expPer = 0
						end
						expProgressBar:setPercentage(expPer)
						tempExpPercentage = surplusRefitExp / maxRefitExp
					end
					G_addResource8888(function()
						tempExpProgressSp = CCSprite:create("public/pri_texture_progressBar.png")
					end)
					tempExpProgressSp:setAnchorPoint(ccp(0, 0.5))
					tempExpProgressSp:setPosition(0, expProgressBar:getPositionY())
					tempExpProgressSp:setTag(3)
					expProgressBarBg:addChild(tempExpProgressSp)
					tempExpProgressSp:setColor(tempRefitExp > 0 and ccc3(201, 53, 44) or ccc3(27, 212, 91))
					tempExpProgressSp:setTextureRect(CCRect(0, 0, tempExpProgressSp:getContentSize().width * tempExpPercentage, tempExpProgressSp:getContentSize().height))
					tempExpProgressSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.3, 50), CCFadeTo:create(0.3, 200))))
				end
				--end ^_^ 进度值的变动效果
			end
		end
	end
	for i = 1, 4 do
		local refitTypeIconBg = tolua.cast(self.bgSp:getChildByTag(100 + i), "CCSprite")
		if refitTypeIconBg then
			local refitTypeData = planeRefitVoApi:getRefitTypeData(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
			local refitExp = planeRefitVoApi:getRefitExp(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
			for j = 1, 3 do
				local progressBarBg = tolua.cast(refitTypeIconBg:getChildByTag(100 + j), "CCSprite")
				if progressBarBg then
					local tempProgressSp = tolua.cast(progressBarBg:getChildByTag(2), "CCSprite")
					if tempProgressSp then
						tempProgressSp:removeFromParentAndCleanup(true)
						tempProgressSp = nil
					end
					local progressBar = tolua.cast(progressBarBg:getChildByTag(1), "CCProgressTimer")
					if progressBar then
						local percentage = planeRefitVoApi:getRefitPercentageByIndex(refitTypeData, refitExp, j)
						progressBar:setPercentage(percentage)
						--start ^_^ 进度值的变动效果，目前由于数值变动很小，所以几乎看不出啥效果来，后续再酌情考虑要不要该效果了
				        if isHaveRefitTempExp then
				        	local tempExp = planeRefitVoApi:getRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
							if tempExp and tempExp ~= 0 then
								local newPercentage = planeRefitVoApi:getRefitPercentageByIndex(refitTypeData, refitExp + tempExp, j)
								local tempPercentage
								if tempExp > 0 then
									if percentage < 100 then
										tempPercentage = newPercentage / 100
									end
								else
									progressBar:setPercentage(newPercentage)
									tempPercentage = percentage / 100
								end
								if tempPercentage and tempPercentage ~= 0 then
									G_addResource8888(function()
										tempProgressSp = CCSprite:create("public/pri_texture_circle_progressBar.png")
									end)
									tempProgressSp:setAnchorPoint(ccp(1, 0))
									tempProgressSp:setPosition(progressBarBg:getContentSize().width, 0)
									tempProgressSp:setTag(2)
									progressBarBg:addChild(tempProgressSp)
									tempProgressSp:setColor(tempExp >= 0 and ccc3(27, 212, 91) or ccc3(201, 53, 44))
									tempProgressSp:setTextureRect(CCRect(tempProgressSp:getContentSize().width * (1 - tempPercentage), 0, tempProgressSp:getContentSize().width * tempPercentage, tempProgressSp:getContentSize().height))
									tempProgressSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.3, 50), CCFadeTo:create(0.3, 200))))
								end
							end
				        end
				        --end ^_^ 进度值的变动效果，目前由于数值变动很小，所以几乎看不出啥效果来，后续再酌情考虑要不要该效果了
					end
				end
			end
			local unlockSp = tolua.cast(refitTypeIconBg:getChildByTag(2), "CCSprite")
			if unlockSp then
				local lockSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_lockIcon.png")
				local unlockSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_unlockIcon.png")
				if self.lockStateTb and self.lockStateTb[self.curSelectedPlaceId] and self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId] 
					and self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId][i] == true then
					unlockSp:setDisplayFrame(lockSpriteFrame)
				else
					unlockSp:setDisplayFrame(unlockSpriteFrame)
				end
			end
			local refitTempExpLb = tolua.cast(refitTypeIconBg:getChildByTag(3), "CCLabelTTF")
			if refitTempExpLb then
				refitTempExpLb:setString("")
				if isHaveRefitTempExp then
					local tempExp = planeRefitVoApi:getRefitTempExp(self.curSelectedPlaceId, self.curSelectedPlaneId, i)
					if tempExp then
						if effectType == 1 then
							local lbSeqArr = CCArray:create()
							lbSeqArr:addObject(CCScaleTo:create(0.1, 2))
							lbSeqArr:addObject(CCScaleTo:create(0.3, 1))
							refitTempExpLb:runAction(CCSequence:create(lbSeqArr))
						else
							refitTempExpLb:stopAllActions()
							refitTempExpLb:setScale(1)
							refitTempExpLb:setVisible(true)
						end
						refitTempExpLb:setString((tempExp < 0) and tostring(tempExp) or ("+" .. tempExp))
						refitTempExpLb:setColor((tempExp < 0) and G_ColorRed or G_ColorGreen)
					end
				end
			end
			local refitExpLb = tolua.cast(refitTypeIconBg:getChildByTag(4), "CCLabelTTF")
			if refitExpLb then
				if effectType == 2 and (self.tempExpChangeTb and self.tempExpChangeTb[i]) then
					refitExpLb:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 2), CCScaleTo:create(0.3, 1)))
				else
					refitExpLb:stopAllActions()
					refitExpLb:setScale(1)
				end
				refitExpLb:setString(refitExp .. "/" .. refitTypeData.powerMax)
			end
		end
	end
	self:refreshBottomItemNum()
end

function planeRefitDialog:refreshBottomItemNum()
	local needNumLb = tolua.cast(self.needNumLb, "CCLabelTTF")
	if needNumLb then
		local needNum = planeRefitVoApi:getRefitCostPropNum(self:getCurLockCount())
		needNumLb:setString("/" .. needNum)
		local numLb = tolua.cast(self.numLb, "CCLabelTTF")
		if numLb and self.refitCostItem then
			local num = bagVoApi:getItemNumId(self.refitCostItem.id)
			self.refitCostItem.num = num
			numLb:setString(num)
			if num < needNum then
				numLb:setColor(G_ColorRed)
			else
				numLb:setColor(G_ColorGreen)
			end
			needNumLb:setPositionX(numLb:getPositionX() + numLb:getContentSize().width)
		end
	end
end

function planeRefitDialog:getCurLockCount(lockIndexTb)
	local lockCount = 0
	if self.lockStateTb and self.lockStateTb[self.curSelectedPlaceId] and self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId] then
		for k, v in pairs(self.lockStateTb[self.curSelectedPlaceId][self.curSelectedPlaneId]) do
			if v == true then
				lockCount = lockCount + 1
				if type(lockIndexTb) == "table" then
					table.insert(lockIndexTb, k)
				end
			end
		end
	end
	return lockCount
end

function planeRefitDialog:tick()
end

function planeRefitDialog:dispose()
	planeRefitVoApi:removeEventListener(self.listenerFunc)
	if self.powerChangeListener then
  		eventDispatcher:removeEventListener("user.power.change", self.powerChangeListener)
  		self.powerChangeListener = nil
  	end
	self = nil
	spriteController:removePlist("public/rewardCenterImage.plist")
	spriteController:removeTexture("public/rewardCenterImage.png")
	spriteController:removePlist("public/newButton180711.plist")
	spriteController:removeTexture("public/newButton180711.png")
	spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
	spriteController:removePlist("public/planeRefit_skillIcons.plist")
    spriteController:removeTexture("public/planeRefit_skillIcons.png")
end