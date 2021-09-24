planeChargeDialog = commonDialog:new()

function planeChargeDialog:new(layerNum)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/planeRefitImages.plist")
        spriteController:addTexture("public/planeRefitImages.png")
        spriteController:addPlist("public/planeRefitEffect.plist")
        spriteController:addTexture("public/planeRefitEffect.png")
    end)
    return nc
end

function planeChargeDialog:initTableView()
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
			getlocal("planeRefit_chargeInfoDesc1"),
			getlocal("planeRefit_chargeInfoDesc2"),
			getlocal("planeRefit_chargeInfoDesc3"),
			getlocal("planeRefit_chargeInfoDesc4", {planeRefitVoApi:getCfg().getPower[1], planeRefitVoApi:getCfg().getPower[2]}),
			getlocal("planeRefit_chargeInfoDesc5"),
			getlocal("planeRefit_chargeInfoDesc6"),
			getlocal("planeRefit_chargeInfoDesc7", {itemName}),
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

    self.curSelectedPlaceId = 1
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
    		self:refreshPlaneUI()
    		self:initBottomTipsLb()
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
    	bgSp = CCSprite:create("public/pri_bg1.jpg")
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
    	if self and type(eventData) == "table" and eventData.eventType == 2 then
		  	self:refreshPlaneUI()
		  	self:initBottomTipsLb()
		end
  	end
  	planeRefitVoApi:addEventListener(self.listenerFunc)

  	if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 85 then
		otherGuideMgr:setGuideStepField(86, self.circleSp, true)
        otherGuideMgr:toNextStep()
    end
end

function planeChargeDialog:initMiddleUI()
	if self.bgSp == nil then
		do return end
	end
	local yPosSpace = 150
	local placeNameLbTopSpace = 30
	if G_getIphoneType() == G_iphone4 then
		yPosSpace = 120
		placeNameLbTopSpace = 70
	end
	local bgSpSize = self.bgSp:getContentSize()
	local placeData = planeRefitVoApi:getPlaceData()
	local planeList = planeVoApi:getPlaneList()
	local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
	local color = planeRefitVoApi:getLevelColor(level)
	local placeName = planeRefitVoApi:getPlaceName(self.curSelectedPlaceId) .. "-" .. getlocal("planeRefit_energyText") .. getlocal("fightLevel", {level})
	local placeNameLb = GetTTFLabelWrap(placeName, 22, CCSizeMake(245, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	placeNameLb:setAnchorPoint(ccp(0.5, 1))
	placeNameLb:setPosition(bgSpSize.width / 2, bgSpSize.height - placeNameLbTopSpace)
	if color then
		placeNameLb:setColor(color)
	end
	self.bgSp:addChild(placeNameLb, 2)
	self.placeNameLb = placeNameLb
	local isMaxLevel = planeRefitVoApi:isMaxLevel(level)
	local maxLevelLb = GetTTFLabel(getlocal("decorateMax"), 22)
	maxLevelLb:setAnchorPoint(ccp(0.5, 1))
	maxLevelLb:setPosition(placeNameLb:getPositionX(), placeNameLb:getPositionY() - placeNameLb:getContentSize().height)
	maxLevelLb:setVisible(isMaxLevel)
	self.bgSp:addChild(maxLevelLb, 2)
	self.maxLevelLb = maxLevelLb

	self.planeBgTb = {}
	self.chargeProgressBarTb = {}
	for i = 1, 4 do
		local planeBg = LuaCCSprite:createWithSpriteFrameName("pri_planeBg.png", function()
			planeRefitVoApi:showRefitDialog(self.layerNum + 1, self.curSelectedPlaceId, planeList[i].pid)
		end)
		planeBg:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		local xPos, yPos = (i % 2 == 0) and 1 or -1, (i > 2) and -1 or 1
		planeBg:setPosition(bgSpSize.width / 2 + xPos * 120 + xPos * planeBg:getContentSize().width / 2, bgSpSize.height / 2 + yPos * yPosSpace + yPos * planeBg:getContentSize().height / 2)
		self.bgSp:addChild(planeBg)
		local planeSp = CCSprite:createWithSpriteFrameName(planeList[i]:getPic())
		planeSp:setPosition(planeBg:getContentSize().width / 2, planeBg:getContentSize().height / 2)
		planeSp:setScale((planeBg:getContentSize().width - 50) / planeSp:getContentSize().width)
		planeBg:addChild(planeSp)
		local checkSp = CCSprite:createWithSpriteFrameName("pri_checkIcon.png")
		checkSp:setAnchorPoint(ccp(1, 0))
		checkSp:setPosition(planeBg:getContentSize().width - 10, 10)
		planeBg:addChild(checkSp)
		local expLbStr, curPercentage
		if isMaxLevel then
			expLbStr = ""
			curPercentage = 100
		else
			local curExp = planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, planeList[i].pid)
			local maxExp = planeRefitVoApi:getEnergyMaxExp(level)
			expLbStr = curExp .. "/" .. maxExp
			curPercentage = curExp / maxExp * 100
		end
		local expLb = GetTTFLabel(expLbStr, 22)
		expLb:setAnchorPoint(ccp(0.5, 1))
		expLb:setPosition(planeBg:getContentSize().width / 2, 0)
		expLb:setTag(12)
		planeBg:addChild(expLb)
		local placeIcon = CCSprite:createWithSpriteFrameName(placeData[self.curSelectedPlaceId].icon)
		placeIcon:setAnchorPoint(ccp(0, 1))
		placeIcon:setPosition(10, planeBg:getContentSize().height - 10)
		placeIcon:setScale(0.6)
		placeIcon:setTag(13)
		planeBg:addChild(placeIcon)
		self.planeBgTb[i] = planeBg

		local progressBarSp = CCSprite:createWithSpriteFrameName("pri_chargeProgressBar.png")
		if i == 2 then
			progressBarSp:setFlipX(true)
		elseif i == 3 then
			progressBarSp:setFlipY(true)
		elseif i == 4 then
			progressBarSp:setFlipX(true)
			progressBarSp:setFlipY(true)
		end
		if color then
			progressBarSp:setColor(color)
		end
		local chargeProgressBar = CCProgressTimer:create(progressBarSp)
		---[[圆形进度条
		chargeProgressBar:setType(kCCProgressTimerTypeRadial)
	    local percentageOffsetFunc
	    if i == 1 then
	    	chargeProgressBar:setMidpoint(ccp(0.9999, 0.0001)) -- 1, 0
	    	percentageOffsetFunc = function(percentage) return percentage / 100 * (100 / 4) + 75 end
	    elseif i == 2 then
	    	chargeProgressBar:setMidpoint(ccp(0.0001, 0.0001)) -- 0, 0
	    	percentageOffsetFunc = function(percentage) return percentage / 100 * (100 / 4) + 0 end
	    elseif i == 3 then
	    	chargeProgressBar:setMidpoint(ccp(0.9999, 0.9999)) -- 1, 1
	    	percentageOffsetFunc = function(percentage) return percentage / 100 * (100 / 4) + 50 end
		elseif i == 4 then
			chargeProgressBar:setMidpoint(ccp(0.0001, 0.9999)) -- 0, 1
	    	percentageOffsetFunc = function(percentage) return percentage / 100 * (100 / 4) + 25 end
	    end
		chargeProgressBar:setPercentage(percentageOffsetFunc(curPercentage))
		--]]

		--[[方形进度条
		chargeProgressBar:setType(kCCProgressTimerTypeBar)
	    chargeProgressBar:setBarChangeRate(ccp(1, 0))
	    if i == 1 then
	    	chargeProgressBar:setMidpoint(ccp(0, 1))
		elseif i == 2 then
			chargeProgressBar:setMidpoint(ccp(0, 1))
		elseif i == 3 then
			chargeProgressBar:setMidpoint(ccp(1, 0))
		elseif i == 4 then
			chargeProgressBar:setMidpoint(ccp(1, 0))
		end
		chargeProgressBar:setPercentage(curPercentage)
		--]]
		if i == 1 then
	    	chargeProgressBar:setAnchorPoint(ccp(1, 0))
			chargeProgressBar:setPosition(bgSpSize.width / 2 - 35, bgSpSize.height / 2 + 35)
		elseif i == 2 then
			chargeProgressBar:setAnchorPoint(ccp(0, 0))
			chargeProgressBar:setPosition(bgSpSize.width / 2 + 35, bgSpSize.height / 2 + 35)
		elseif i == 3 then
			chargeProgressBar:setAnchorPoint(ccp(1, 1))
			chargeProgressBar:setPosition(bgSpSize.width / 2 - 35, bgSpSize.height / 2 - 35)
		elseif i == 4 then
			chargeProgressBar:setAnchorPoint(ccp(0, 1))
			chargeProgressBar:setPosition(bgSpSize.width / 2 + 35, bgSpSize.height / 2 - 35)
		end
		self.bgSp:addChild(chargeProgressBar)
		self.chargeProgressBarTb[i] = {chargeProgressBar, percentageOffsetFunc}
	end
	-- local circleSp = CCSprite:createWithSpriteFrameName("pri_texture5.png")
	local circleSp = LuaCCSprite:createWithSpriteFrameName("pri_texture5.png", function(...) self:onClickCharge(...) end)
	circleSp:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	circleSp:setPosition(bgSpSize.width / 2, bgSpSize.height / 2)
	self.bgSp:addChild(circleSp, 1)
	self.circleSp = circleSp

	-- local chargeBtnSp = LuaCCSprite:createWithSpriteFrameName("pri_texture3.png", function(...) self:onClickCharge(...) end)
	-- chargeBtnSp:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	local chargeBtnSp = CCSprite:createWithSpriteFrameName("pri_texture3.png")
	chargeBtnSp:setPosition(bgSpSize.width / 2, bgSpSize.height / 2)
	self.bgSp:addChild(chargeBtnSp, 1)
	chargeBtnSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(0.5, 0.6), CCScaleTo:create(0.5, 1.2))))
	self.chargeBtnSp = chargeBtnSp

	local armNode = CCNode:create()
	armNode:setPosition(chargeBtnSp:getPosition())
	self.bgSp:addChild(armNode, 1)
	for i = 1, 3 do
		local armSp = CCSprite:createWithSpriteFrameName("pri_texture1.png")
		armSp:setAnchorPoint(ccp(0.5, 0))
		if i == 1 then
			armSp:setPosition(0, 20)
		elseif i == 2 then
			armSp:setRotation(120)
			armSp:setPosition(15, -15)
		elseif i == 3 then
			armSp:setRotation(240)
			armSp:setPosition(-15, -15)
		end
		armSp:setTag(i)
		armNode:addChild(armSp)
	end
	self.armNode = armNode
end

function planeChargeDialog:initBottomUI()
	self.bottomUI = CCNode:create()
	self.bgLayer:addChild(self.bottomUI, 2)
	local tempCheckBoxItem2, tempCheckBoxItem3
	local function onClickCheckBox(tag, obj)
		if obj and tolua.cast(obj, "CCMenuItemToggle") then
			local isSelected = (obj:getSelectedIndex() == 1)
    		if tag == 11 then
    			self.isSelectedShortcutCharge = isSelected
    			self:refreshBottomCostUI()
    		elseif tag == 12 then
    			if isSelected then
    				tempCheckBoxItem3:setSelectedIndex(0)
    				self.selectedChargeType = 1
    				local chargeBtnSp = tolua.cast(self.chargeBtnSp, "CCSprite")
    				if chargeBtnSp then
    					chargeBtnSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_texture3.png"))
    				end
    			else
    				obj:setSelectedIndex(1)
    			end
    		elseif tag == 13 then
    			if isSelected then
    				tempCheckBoxItem2:setSelectedIndex(0)
    				self.selectedChargeType = 2
    				local chargeBtnSp = tolua.cast(self.chargeBtnSp, "CCSprite")
    				if chargeBtnSp then
    					chargeBtnSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_texture2.png"))
    				end
    			else
    				obj:setSelectedIndex(1)
    			end
    		end
    	end
	end
	local checkBoxPosY, checkBoxScale = 100, 1
	if G_getIphoneType() == G_iphone4 then
		checkBoxPosY = 65
		checkBoxScale = 0.7
	end
    local checkBox1, checkBoxItem1 = G_createCheckBox("LegionCheckBtnUn.png", "LegionCheckBtn.png", onClickCheckBox)
    checkBox1:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    checkBoxItem1:setScale(checkBoxScale)
    checkBox1:setPosition(30 + checkBoxItem1:getContentSize().width * checkBoxScale / 2, checkBoxPosY)
    checkBoxItem1:setTag(11)
    self.bottomUI:addChild(checkBox1)
    local label1 = GetTTFLabel(getlocal("activity_newyearseve_prompt1_1", {planeRefitVoApi:getChargeShortcutCount()}), 22)
    label1:setAnchorPoint(ccp(0, 0.5))
    label1:setPosition(checkBox1:getPositionX() + checkBoxItem1:getContentSize().width * checkBoxScale / 2 + 5, checkBox1:getPositionY())
    self.bottomUI:addChild(label1)
    local checkBox2, checkBoxItem2 = G_createCheckBox("LegionCheckBtnUn.png", "LegionCheckBtn.png", onClickCheckBox)
    checkBoxItem2:setScale(checkBoxScale)
    checkBox2:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    checkBox2:setPosition(G_VisibleSizeWidth / 2 - 80, checkBox1:getPositionY())
    checkBoxItem2:setTag(12)
    self.bottomUI:addChild(checkBox2)
    local labelFontSize = 22
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "fr" then
    	labelFontSize = 18
    	if G_isIOS() == false then
    		labelFontSize = 16
    	end
    end
    local label2 = GetTTFLabelWrap(getlocal("planeRefit_generalCharge"), labelFontSize, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    label2:setAnchorPoint(ccp(0, 0.5))
    label2:setPosition(checkBox2:getPositionX() + checkBoxItem2:getContentSize().width * checkBoxScale / 2 + 5, checkBox2:getPositionY())
    self.bottomUI:addChild(label2)
    local checkBox3, checkBoxItem3 = G_createCheckBox("LegionCheckBtnUn.png", "LegionCheckBtn.png", onClickCheckBox)
    checkBoxItem3:setScale(checkBoxScale)
    local label3 = GetTTFLabelWrap(getlocal("planeRefit_advancedCharge"), labelFontSize, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    label3:setAnchorPoint(ccp(1, 0.5))
    label3:setPosition(G_VisibleSizeWidth - 30, checkBox1:getPositionY())
    self.bottomUI:addChild(label3)
    checkBox3:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    checkBox3:setPosition(label3:getPositionX() - label3:getContentSize().width - 5 - checkBoxItem3:getContentSize().width * checkBoxScale / 2, checkBox1:getPositionY())
    checkBoxItem3:setTag(13)
    self.bottomUI:addChild(checkBox3)
    checkBoxItem2:setSelectedIndex(1)
    self.selectedChargeType = 1 --已选择的聚能类型(1:资源聚能，2:金币聚能)
    tempCheckBoxItem2, tempCheckBoxItem3 = checkBoxItem2, checkBoxItem3
    local resIndex, ownResNum = planeRefitVoApi:getChargeCostResIndex()
    if resIndex then
    	local resIcon = CCSprite:createWithSpriteFrameName(G_getResourceIconByIndex(resIndex))
    	resIcon:setAnchorPoint(ccp(0, 0.5))
    	resIcon:setPosition(label2:getPositionX(), checkBox2:getPositionY() - checkBoxItem2:getContentSize().height * checkBoxScale / 2 - resIcon:getContentSize().height / 2)
    	self.bottomUI:addChild(resIcon)
    	local resCostNum = planeRefitVoApi:getChargeCostRes()
    	if resCostNum then
    		local resCostLb = GetTTFLabel(FormatNumber(resCostNum), 22)
    		resCostLb:setAnchorPoint(ccp(0, 0.5))
    		resCostLb:setPosition(resIcon:getPositionX() + resIcon:getContentSize().width, resIcon:getPositionY())
    		if ownResNum < resCostNum then
    			resCostLb:setColor(G_ColorRed)
    		end
    		self.bottomUI:addChild(resCostLb)
    		self.resCostLb = resCostLb
    		self.resIcon = resIcon
    	end
    end
    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(0, 0.5))
    goldIcon:setPosition(label3:getPositionX() - label3:getContentSize().width, checkBox3:getPositionY() - checkBoxItem3:getContentSize().height * checkBoxScale / 2 - goldIcon:getContentSize().height / 2)
    self.bottomUI:addChild(goldIcon)
    local goldCostNum = planeRefitVoApi:getChargeCostGold()
    local goldCostLb = GetTTFLabel(FormatNumber(goldCostNum), 22)
    goldCostLb:setAnchorPoint(ccp(0, 0.5))
    goldCostLb:setPosition(goldIcon:getPositionX() + goldIcon:getContentSize().width, goldIcon:getPositionY())
    if playerVoApi:getGems() < goldCostNum then
    	goldCostLb:setColor(G_ColorRed)
    end
    self.bottomUI:addChild(goldCostLb)
    self.goldCostLb = goldCostLb

    self:initBottomTipsLb()
end

function planeChargeDialog:initBottomTipsLb()
	local bottomTipsLb = tolua.cast(self.bgLayer:getChildByTag(-1001), "CCLabelTTF")
	if bottomTipsLb then
		bottomTipsLb:removeFromParentAndCleanup(true)
		bottomTipsLb = nil
	end
	local tipsLbStr = nil
    local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
    if planeRefitVoApi:isMaxLevel(level) then --满级可继续聚能
    	-- tipsLbStr = getlocal("planeRefit_chargeMaxLvTips")
    else
    	local planeList = planeVoApi:getPlaneList()
    	local needRefit = planeRefitVoApi:getNextNeedRefit(level)
    	local maxExp = planeRefitVoApi:getEnergyMaxExp(level)
    	local flag = true
    	for i = 1, 4 do
    		local curExp = planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, planeList[i].pid)
    		if curExp < maxExp then
    			flag = nil
    			break
    		end
    	end
    	if flag then
	    	for i = 1, 4 do
	    		if planeRefitVoApi:getRefitExp(self.curSelectedPlaceId, i) < needRefit then
	    			tipsLbStr = getlocal("planeRefit_chargeNextLvTips", {needRefit})
	    			break
	    		end
	    	end
	    end
    end
    if self.bottomUI then
    	self.bottomUI:setVisible(tipsLbStr == nil)
    end
    if tipsLbStr then
    	local bottomTipsLbPosY = 75
    	if G_getIphoneType() == G_iphone4 then
			bottomTipsLbPosY = 40
		end
    	bottomTipsLb = GetTTFLabelWrap(tipsLbStr, 22, CCSizeMake(G_VisibleSizeWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		bottomTipsLb:setPosition(G_VisibleSizeWidth / 2, bottomTipsLbPosY)
		bottomTipsLb:setTag(-1001)
		self.bgLayer:addChild(bottomTipsLb, 2)
    end
end

function planeChargeDialog:onClickCharge()
	if self.isRunningEffect then
		return
	end

	local isMaxLevel
    local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
    if planeRefitVoApi:isMaxLevel(level) then --满级可继续聚能
    	isMaxLevel = true
    	-- G_showTipsDialog(getlocal("planeRefit_chargeMaxLvTips"))
    	-- return
    else
    	local planeList = planeVoApi:getPlaneList()
    	local needRefit = planeRefitVoApi:getNextNeedRefit(level)
    	local maxExp = planeRefitVoApi:getEnergyMaxExp(level)
    	local flag = true
    	for i = 1, 4 do
    		local curExp = planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, planeList[i].pid)
    		if curExp < maxExp then
    			flag = nil
    			break
    		end
    	end
    	if flag then
	    	for i = 1, 4 do
	    		if planeRefitVoApi:getRefitExp(self.curSelectedPlaceId, i) < needRefit then
	    			G_showTipsDialog(getlocal("planeRefit_chargeNextLvTips", {needRefit}))
	    			if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 86 then
						otherGuideMgr:endNewGuid()
					end
	    			return
	    		end
	    	end
	    end
    end
    local costNum
    local function sureChargeLogic()
    	if costNum then
			local planeList = planeVoApi:getPlaneList()
			local prevExpData = {}
			for k, v in pairs(planeList) do
				table.insert(prevExpData, planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, v.pid))
			end
			planeRefitVoApi:requestCharge(function(expRateTb)
				if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 86 then
					otherGuideMgr:hidingGuild()
				end
				if self.selectedChargeType == 1 then
					local costRTb = {}
					local resIndex, ownResNum = planeRefitVoApi:getChargeCostResIndex()
					costRTb[resIndex] = costNum
					playerVoApi:useResource(costRTb[1], costRTb[2], costRTb[3], costRTb[4], costRTb[5])
				elseif self.selectedChargeType == 2 then
					playerVoApi:setGems(playerVoApi:getGems() - costNum)
				end
				print("cjl ======>>> 播放聚能动画特效!!!!!!!")
				self:playChargeEffect(level, prevExpData, expRateTb, function()
					if isMaxLevel then
						local rewardTb = planeRefitVoApi:getMaxLevelChargeItem(self.selectedChargeType, self.isSelectedShortcutCharge)
				    	for k, v in pairs(rewardTb) do
				    		G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
				    	end
				        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
				        rewardShowSmallDialog:showNewReward(self.layerNum + 1, true, true, rewardTb, nil, getlocal("planeRefit_getItemTitle"))
					else
						self:refreshPlaneUI(true)
						self:initBottomTipsLb()
					end
					self:refreshBottomCostUI()
				end, isMaxLevel)
			end, self.curSelectedPlaceId, self.selectedChargeType, self.isSelectedShortcutCharge and planeRefitVoApi:getChargeShortcutCount() or 1)
		end
    end
	if self.selectedChargeType == 1 then
		local resIndex, ownResNum = planeRefitVoApi:getChargeCostResIndex()
		if resIndex and ownResNum then
			costNum = planeRefitVoApi:getChargeCostRes(self.isSelectedShortcutCharge)
			if ownResNum < costNum then
				G_showTipsDialog(getlocal("backstage25111"))
				if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 86 then
					otherGuideMgr:endNewGuid()
				end
				do return end
			end
			local resName
			if resIndex == 1 then resName = getlocal("metal")
			elseif resIndex == 2 then resName = getlocal("oil")
			elseif resIndex == 3 then resName = getlocal("silicon")
			elseif resIndex == 4 then resName = getlocal("uranium")
			elseif resIndex == 5 then resName = getlocal("money") end
			print("cjl --------->>> 资源聚能，需消耗" .. resName .. ":" .. costNum)
			sureChargeLogic()
		end
	elseif self.selectedChargeType == 2 then
		costNum = planeRefitVoApi:getChargeCostGold(self.isSelectedShortcutCharge)
		local ownGems = playerVoApi:getGems()
        if ownGems < costNum then
            GemsNotEnoughDialog(nil, nil, costNum - ownGems, self.layerNum + 1, costNum)
            do return end
        end
        print("cjl --------->>> 金币聚能，需消耗金币:" .. costNum)
        --金币消耗的二次确认
        if G_isPopBoard("planeRefit_goldChargeTips") then
           G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("second_tip_des", {costNum}), true, sureChargeLogic, function(sbFlag) G_changePopFlag("planeRefit_goldChargeTips", base.serverTime .. "_" .. sbFlag) end)
        else
            sureChargeLogic()
        end
	end
end

function planeChargeDialog:refreshPlaneUI(isShowEffect)
	if self.planeBgTb then
		local placeData = planeRefitVoApi:getPlaceData()
		local planeList = planeVoApi:getPlaneList()
		local level = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
		local isMaxLevel = planeRefitVoApi:isMaxLevel(level)
		local color, colorKey = planeRefitVoApi:getLevelColor(level)
		local placeNameLb = tolua.cast(self.placeNameLb, "CCLabelTTF")
		if placeNameLb then
			placeNameLb:setString(planeRefitVoApi:getPlaceName(self.curSelectedPlaceId) .. "-" .. getlocal("planeRefit_energyText") .. getlocal("fightLevel", {level}))
			if color then
				placeNameLb:setColor(color)
			end
			local maxLevelLb = tolua.cast(self.maxLevelLb, "CCLabelTTF")
			if maxLevelLb then
				maxLevelLb:setPositionY(placeNameLb:getPositionY() - placeNameLb:getContentSize().height)
				maxLevelLb:setVisible(isMaxLevel)
			end
		end
		for k, v in pairs(self.planeBgTb) do
			local curPercentage
			local expLb = tolua.cast(v:getChildByTag(12), "CCLabelTTF")
			if expLb then
				local expLbStr
				if isMaxLevel then
					expLbStr = ""
					curPercentage = 100
				else
					local curExp = planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, planeList[k].pid)
					local maxExp = planeRefitVoApi:getEnergyMaxExp(level)
					expLbStr = curExp .. "/" .. maxExp
					curPercentage = curExp / maxExp * 100
				end
				if isShowEffect then
					expLb:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 2), CCScaleTo:create(0.3, 1)))
				else
					expLb:stopAllActions()
					expLb:setScale(1)
				end
				expLb:setString(expLbStr)
			end
			local placeIcon = tolua.cast(v:getChildByTag(13), "CCSprite")
			if placeIcon then
				placeIcon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(placeData[self.curSelectedPlaceId].icon))
			end
			if curPercentage and self.chargeProgressBarTb and self.chargeProgressBarTb[k] then
				local chargeProgressBar = tolua.cast(self.chargeProgressBarTb[k][1], "CCProgressTimer")
				if chargeProgressBar then
					--由于CCProgressTimer中的Sprite针对setColor方法渲染不及时，所以每次都重设进度以达到重新渲染色值
					chargeProgressBar:setPercentage(0)
					if color then
						chargeProgressBar:getSprite():setColor(color)
					end
					if type(self.chargeProgressBarTb[k][2]) == "function" then
						chargeProgressBar:setPercentage(self.chargeProgressBarTb[k][2](curPercentage))
					else
						chargeProgressBar:setPercentage(curPercentage)
					end
				end
			end
			if k == 1 then
				if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 86 then
					otherGuideMgr:setGuideStepField(87, v)
    				otherGuideMgr:toNextStep()
				end
			end
		end
	end
end

function planeChargeDialog:refreshBottomCostUI()
	local resCostLb = tolua.cast(self.resCostLb, "CCLabelTTF")
	if resCostLb then
		local costNum = planeRefitVoApi:getChargeCostRes(self.isSelectedShortcutCharge)
		resCostLb:setString(FormatNumber(costNum))
		local resIndex, ownResNum = planeRefitVoApi:getChargeCostResIndex()
		if ownResNum < costNum then
			resCostLb:setColor(G_ColorRed)
		else
			resCostLb:setColor(G_ColorWhite)
		end
	end
	local goldCostLb = tolua.cast(self.goldCostLb, "CCLabelTTF")
	if goldCostLb then
		local costNum = planeRefitVoApi:getChargeCostGold(self.isSelectedShortcutCharge)
		goldCostLb:setString(FormatNumber(costNum))
		if playerVoApi:getGems() < costNum then
			goldCostLb:setColor(G_ColorRed)
		else
			goldCostLb:setColor(G_ColorWhite)
		end
	end
end

function planeChargeDialog:setTouchEnabled(enabled, callbackFunc, touchPriority)
	local sp = self.bgLayer:getChildByTag(-99999)
	if enabled then
		if sp then
			sp:removeFromParentAndCleanup(true)
			sp = nil
		end
	else
		if sp == nil then
			sp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if callbackFunc then callbackFunc() end end)
		    if touchPriority then
		    	sp:setTouchPriority(touchPriority)
		    else
		    	sp:setTouchPriority( - (self.layerNum - 1) * 20 - 10)
		    end
		    sp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
		    sp:setOpacity(0)
		    sp:setTag(-99999)
		    self.bgLayer:addChild(sp, 99999)
		end
	    sp:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
	    return sp
	end
end

function planeChargeDialog:playChargeEffect(prevLv, prevExpData, expRateTb, effectCallback, isMaxLevel)
	self.isRunningEffect = true
	self:setTouchEnabled(false, function()
		print("cjl ------------>>> 强制结束动画效果！！！")
	end)

	local function createAnim(frameTb)
		local frameNameTb, frameCount = Split(frameTb[1], "#"), frameTb[2]
		local prefix, suffix = frameNameTb[1], frameNameTb[2]
	    local firstFrameSp = CCSprite:createWithSpriteFrameName(prefix .. "1" .. suffix)
	    G_setBlendFunc(firstFrameSp, GL_ONE, GL_ONE)
	    local frameArray = CCArray:create()
	    for i = 1, frameCount do
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. i .. suffix)
	        frameArray:addObject(frame)
	    end
	    local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.07)
	    local animate = CCAnimate:create(animation)
	    return firstFrameSp, animate
	end

	local color, colorKey = planeRefitVoApi:getLevelColor(prevLv)
	local uiPointSpTb = {}
	for i = 1, 4 do
		local uiPointSp = CCSprite:createWithSpriteFrameName("pre_uiPoint_" .. colorKey .. ".png")
		if i == 1 then
			uiPointSp:setPosition(self.bgSp:getContentSize().width / 2 - 157, self.bgSp:getContentSize().height / 2)
		elseif i == 2 then
			uiPointSp:setRotation(90)
			uiPointSp:setPosition(self.bgSp:getContentSize().width / 2, self.bgSp:getContentSize().height / 2 + 157)
		elseif i == 3 then
			uiPointSp:setPosition(self.bgSp:getContentSize().width / 2 + 157, self.bgSp:getContentSize().height / 2)
		elseif i == 4 then
			uiPointSp:setRotation(90)
			uiPointSp:setPosition(self.bgSp:getContentSize().width / 2, self.bgSp:getContentSize().height / 2 - 157)
		end
		self.bgSp:addChild(uiPointSp)
		uiPointSpTb[i] = uiPointSp
	end

	local preCircle1, preCircle2, preCircle3, preLightFrame, preFlickerFrame, circleSpPic, preArmLightFrame
	if self.selectedChargeType == 1 then
		preCircle1 = CCSprite:createWithSpriteFrameName("preL_circle_1.png")
		preCircle2 = CCSprite:createWithSpriteFrameName("preL_circle_2.png")
		preCircle3 = CCSprite:createWithSpriteFrameName("preL_circle_3.png")
		preLightFrame = {"preL_light_#.png", 2}
		preFlickerFrame = {"preL_flicker_#.png", 10}
		circleSpPic = "pri_texture6.png"
		preArmLightFrame = {"preL_armLight_#.png", 18}
	elseif self.selectedChargeType == 2 then
		preCircle1 = CCSprite:createWithSpriteFrameName("preH_circle_1.png")
		preCircle2 = CCSprite:createWithSpriteFrameName("preH_circle_2.png")
		preCircle3 = CCSprite:createWithSpriteFrameName("preH_circle_3.png")
		preLightFrame = {"preH_light_#.png", 2}
		preFlickerFrame = {"preH_flicker_#.png", 10}
		circleSpPic = "pri_texture4.png"
		preArmLightFrame = {"preH_armLight_#.png", 18}
	end
	local preFlowFrame = {"pre_flow_" .. colorKey .. "_#.png", 10}
	local function playPreFlow()
		local bottomPos, radius = ccp(self.circleSp:getPositionX(), self.circleSp:getPositionY() - self.circleSp:getContentSize().height / 2 + 9), self.circleSp:getContentSize().height / 2 - 9
		for i = 1, 4 do
			local preFlowSp, preFlowAnim = createAnim(preFlowFrame)
			preFlowSp:setAnchorPoint(ccp(0.5, 0.33))
			if i == 1 then
				preFlowSp:setRotation(-45)
				preFlowSp:setPosition(G_getPointOfCircle(bottomPos, radius, 135))
			elseif i == 2 then
				preFlowSp:setRotation(45)
				preFlowSp:setPosition(G_getPointOfCircle(bottomPos, radius, 45))
			elseif i == 3 then
				preFlowSp:setRotation(135)
				preFlowSp:setPosition(G_getPointOfCircle(bottomPos, radius, -45))
			elseif i == 4 then
				preFlowSp:setRotation(-135)
				preFlowSp:setPosition(G_getPointOfCircle(bottomPos, radius, -135))
			end
			self.bgSp:addChild(preFlowSp)
			preFlowSp:setScaleX(1)
			preFlowSp:setScaleY(0)
			local preFlowSpSeqArr = CCArray:create()
			preFlowSpSeqArr:addObject(CCScaleTo:create(0.2, 1, 1))
			preFlowSpSeqArr:addObject(preFlowAnim)
			preFlowSpSeqArr:addObject(CCScaleTo:create(0.4, 0, 1))
			preFlowSpSeqArr:addObject(CCCallFunc:create(function()
				preFlowSp:removeFromParentAndCleanup(true)
				preFlowSp = nil
			end))
			preFlowSp:runAction(CCSequence:create(preFlowSpSeqArr))
		end
	end

	local oldPosTb = {}
	for i = 1, 3 do
		local armSp = tolua.cast(self.armNode:getChildByTag(i), "CCSprite")
		oldPosTb[i] = ccp(armSp:getPosition())
		armSp:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.4, ccp(0, 0)), CCCallFunc:create(function()
			if i == 3 then
				self.armNode:runAction(CCSequence:createWithTwoActions(CCRotateBy:create(1.73, 360), CCCallFunc:create(function()
					for j = 1, 3 do
						local armSp = tolua.cast(self.armNode:getChildByTag(j), "CCSprite")
						armSp:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.4, oldPosTb[j]), CCCallFunc:create(function()
							if j == 3 then
								for k, v in pairs(uiPointSpTb) do
									v:removeFromParentAndCleanup(true)
								end
								self.circleSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_texture5.png"))
								self.isRunningEffect = nil
								if type(effectCallback) == "function" then
									effectCallback()
								end
								self:setTouchEnabled(true)
							end
						end)))
					end
				end)))
				playPreFlow()
			end
			local preArmLightSp, preArmLightAnim = createAnim(preArmLightFrame)
			preArmLightSp:setPosition(armSp:getContentSize().width / 2, armSp:getContentSize().height / 2)
			armSp:addChild(preArmLightSp)
			preArmLightSp:runAction(CCSequence:createWithTwoActions(preArmLightAnim, CCCallFunc:create(function()
				preArmLightSp:removeFromParentAndCleanup(true)
				preArmLightSp = nil
			end)))
		end)))
	end

	local function playPreFlicker()
		self.chargeBtnSp:setOpacity(0)
		local preFlickerSp, preFlickerAnim = createAnim(preFlickerFrame)
		preFlickerSp:setPosition(self.chargeBtnSp:getPositionX(), self.chargeBtnSp:getPositionY() - 15)
		self.bgSp:addChild(preFlickerSp, 2)
		preFlickerSp:setScaleX(2)
		preFlickerSp:setScaleY(1)
		local preFlickerSpSeqArr = CCArray:create()
		preFlickerSpSeqArr:addObject(CCScaleTo:create(0.13, 1, 1))
		preFlickerSpSeqArr:addObject(CCRepeat:create(preFlickerAnim, 2))
		preFlickerSpSeqArr:addObject(CCCallFunc:create(function()
			self.chargeBtnSp:runAction(CCFadeTo:create(0.2, 255))
		end))
		preFlickerSpSeqArr:addObject(CCScaleTo:create(0.26, 0, 0))
		preFlickerSpSeqArr:addObject(CCCallFunc:create(function()
			preFlickerSp:removeFromParentAndCleanup(true)
			preFlickerSp = nil
		end))
		preFlickerSp:runAction(CCSequence:create(preFlickerSpSeqArr))
	end

	local preLightSp, preLightAnim = createAnim(preLightFrame)
	preLightSp:setPosition(self.chargeBtnSp:getPosition())
	self.bgSp:addChild(preLightSp, 2)
	preLightSp:setOpacity(0)
	local preLightSpSeqArr = CCArray:create()
	-- preLightSpSeqArr:addObject(CCDelayTime:create(0.2))
	preLightSpSeqArr:addObject(CCFadeTo:create(0.2, 255))
	preLightSpSeqArr:addObject(preLightAnim)
	preLightSpSeqArr:addObject(CCCallFunc:create(function()
		preLightSp:removeFromParentAndCleanup(true)
		preLightSp = nil
		self.circleSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(circleSpPic))
		playPreFlicker()
	end))
	preLightSp:runAction(CCSequence:create(preLightSpSeqArr))

	preCircle1:setPosition(self.chargeBtnSp:getPosition())
	preCircle1:setScale(0)
	self.bgSp:addChild(preCircle1, 2)
	local preCircle1SeqArr = CCArray:create()
	preCircle1SeqArr:addObject(CCDelayTime:create(0.13))
	preCircle1SeqArr:addObject(CCScaleTo:create(0.27, 1.26))
	local preCircle1SpawnArr = CCArray:create()
	preCircle1SpawnArr:addObject(CCScaleTo:create(0.74, 2))
	preCircle1SpawnArr:addObject(CCFadeTo:create(0.74, 0))
	preCircle1SeqArr:addObject(CCSpawn:create(preCircle1SpawnArr))
	preCircle1SeqArr:addObject(CCCallFunc:create(function()
		preCircle1:removeFromParentAndCleanup(true)
		preCircle1 = nil
	end))
	preCircle1:runAction(CCSequence:create(preCircle1SeqArr))

	preCircle2:setPosition(self.chargeBtnSp:getPosition())
	preCircle2:setScale(0)
	self.bgSp:addChild(preCircle2, 2)
	local preCircle2SeqArr = CCArray:create()
	preCircle2SeqArr:addObject(CCDelayTime:create(0.33))
	preCircle2SeqArr:addObject(CCScaleTo:create(0.27, 1.26))
	local preCircle2SpawnArr = CCArray:create()
	preCircle2SpawnArr:addObject(CCScaleTo:create(0.33, 2))
	preCircle2SpawnArr:addObject(CCFadeTo:create(0.33, 0))
	preCircle2SeqArr:addObject(CCSpawn:create(preCircle2SpawnArr))
	preCircle2SeqArr:addObject(CCCallFunc:create(function()
		preCircle2:removeFromParentAndCleanup(true)
		preCircle2 = nil
	end))
	preCircle2:runAction(CCSequence:create(preCircle2SeqArr))

	preCircle3:setPosition(self.chargeBtnSp:getPosition())
	preCircle3:setOpacity(0)
	self.bgSp:addChild(preCircle3)
	local preCircle3SeqArr = CCArray:create()
	preCircle3SeqArr:addObject(CCDelayTime:create(0.13))
	preCircle3SeqArr:addObject(CCFadeTo:create(0.27, 255))
	preCircle3SeqArr:addObject(CCDelayTime:create(1.67))
	preCircle3SeqArr:addObject(CCFadeTo:create(0.8, 0))
	preCircle3SeqArr:addObject(CCCallFunc:create(function()
		preCircle3:removeFromParentAndCleanup(true)
		preCircle3 = nil
	end))
	preCircle3:runAction(CCSequence:create(preCircle3SeqArr))

	local preUiExpSp = CCSprite:createWithSpriteFrameName("pre_uiExp_" .. colorKey .. ".png")
	preUiExpSp:setPosition(self.chargeBtnSp:getPosition())
	preUiExpSp:setOpacity(0)
	self.bgSp:addChild(preUiExpSp)
	local preUiExpSpSeqArr = CCArray:create()
	preUiExpSpSeqArr:addObject(CCDelayTime:create(0.33))
	local ccRepeat = CCRepeat:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.14, 255), CCFadeTo:create(0.13, 0)), 6)
	preUiExpSpSeqArr:addObject(ccRepeat)
	preUiExpSpSeqArr:addObject(CCCallFunc:create(function()
		preUiExpSp:removeFromParentAndCleanup(true)
		preUiExpSp = nil
	end))
	preUiExpSp:runAction(CCSequence:create(preUiExpSpSeqArr))

	if not isMaxLevel then
		local newLv = planeRefitVoApi:getEnergyLevel(self.curSelectedPlaceId)
		if newLv > prevLv then
			local preUpgradeFrame = {"pre_upgrade_#.png", 11}
			for k, v in pairs(self.planeBgTb) do
				local preUpgradeSp, preUpgradeAnim = createAnim(preUpgradeFrame)
				preUpgradeSp:setPosition(v:getPosition())
				self.bgSp:addChild(preUpgradeSp)
				preUpgradeSp:setVisible(false)
				local preUpgradeSpSeqArr = CCArray:create()
				preUpgradeSpSeqArr:addObject(CCDelayTime:create(1.5))
				preUpgradeSpSeqArr:addObject(CCCallFunc:create(function() preUpgradeSp:setVisible(true) end))
				preUpgradeSpSeqArr:addObject(preUpgradeAnim)
				preUpgradeSpSeqArr:addObject(CCCallFunc:create(function()
					preUpgradeSp:removeFromParentAndCleanup(true)
					preUpgradeSp = nil
				end))
				preUpgradeSp:runAction(CCSequence:create(preUpgradeSpSeqArr))
			end
		end

		local planeList = planeVoApi:getPlaneList()
		local prevMaxExp = planeRefitVoApi:getEnergyMaxExp(prevLv)
		for k, v in pairs(planeList) do
			local newExp = planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, v.pid)
			local prevExp = prevExpData[k]
			local addExp
			if newLv == prevLv then
				addExp = newExp - prevExp
			elseif newLv > prevLv then
				if prevExp <= prevMaxExp then
					addExp = prevMaxExp - prevExp + newExp
				elseif prevExp > prevMaxExp then
					addExp = newExp - (prevExp - prevMaxExp)
				end
			end
			if type(addExp) == "number" and addExp > 0 then
				local planeBg = self.planeBgTb[k]
				local addExpLb = GetTTFLabel("+" .. addExp, 22, true)
				addExpLb:setPosition(planeBg:getContentSize().width / 2, 0)
				addExpLb:setColor(G_ColorBlue)
				addExpLb:setOpacity(20)
				addExpLb:setScale(0.5)
				planeBg:addChild(addExpLb, 10)
				local addExpLbArr = CCArray:create()
				addExpLbArr:addObject(CCDelayTime:create(1.5))
				local addExpLbSpawnArr = CCArray:create()
				addExpLbSpawnArr:addObject(CCFadeTo:create(0.5, 255))
				addExpLbSpawnArr:addObject(CCScaleTo:create(0.5, 1.2))
				addExpLbSpawnArr:addObject(CCMoveBy:create(0.5, ccp(0, 20)))
				addExpLbArr:addObject(CCSpawn:create(addExpLbSpawnArr))
				addExpLbArr:addObject(CCMoveBy:create(0.09, ccp(0, 20)))
				addExpLbArr:addObject(CCDelayTime:create(0.5))
				addExpLbArr:addObject(CCCallFunc:create(function()
					addExpLb:removeFromParentAndCleanup(true)
				end))
				addExpLb:runAction(CCSequence:create(addExpLbArr))

				if self.chargeProgressBarTb and self.chargeProgressBarTb[k] then
					local chargeProgressBar = tolua.cast(self.chargeProgressBarTb[k][1], "CCProgressTimer")
					local barSeqArr = CCArray:create()
					barSeqArr:addObject(CCDelayTime:create(0.5))
					local fromToPercentage = (prevExp + addExp) / prevMaxExp * 100
					if fromToPercentage > 100 then
						fromToPercentage = 100
					end
					if type(self.chargeProgressBarTb[k][2]) == "function" then
						fromToPercentage = self.chargeProgressBarTb[k][2](fromToPercentage)
					end
					barSeqArr:addObject(CCProgressFromTo:create(1, chargeProgressBar:getPercentage(), fromToPercentage))
					if newLv > prevLv then
						local curExp = planeRefitVoApi:getEnergyCurExp(self.curSelectedPlaceId, v.pid)
						local maxExp = planeRefitVoApi:getEnergyMaxExp(newLv)
						local curPercentage = curExp / maxExp * 100
						if curPercentage > 100 then
							curPercentage = 100
						end
						local zeroPer = 0
						if type(self.chargeProgressBarTb[k][2]) == "function" then
							curPercentage = self.chargeProgressBarTb[k][2](curPercentage)
							zeroPer = self.chargeProgressBarTb[k][2](zeroPer)
						end
						barSeqArr:addObject(CCProgressFromTo:create(1, zeroPer, curPercentage))
					end
					chargeProgressBar:runAction(CCSequence:create(barSeqArr))
				end
			end
		end
		local expRateAction
		expRateAction = function(expRateActionIndex)
			if expRateTb[expRateActionIndex] == nil then
				return
			elseif expRateTb[expRateActionIndex] == 1 then
				expRateAction(expRateActionIndex + 1)
				return
			end
			local expRateLb = GetTTFLabel("x" .. expRateTb[expRateActionIndex], 40, true)
			expRateLb:setPosition(self.bgSp:getContentSize().width / 2, self.bgSp:getContentSize().height / 2 + 200)
			expRateLb:setColor(G_ColorYellowPro)
			expRateLb:setScale(0)
			self.bgSp:addChild(expRateLb, 10)
			local expRateLbArr = CCArray:create()
			if expRateActionIndex ~= 1 then
				expRateLbArr:addObject(CCDelayTime:create(0.5))
			end
			expRateLbArr:addObject(CCScaleTo:create(0.3, 1))
			expRateLbArr:addObject(CCCallFunc:create(function()
				expRateAction(expRateActionIndex + 1)
			end))
			expRateLbArr:addObject(CCMoveBy:create(0.3, ccp(0, 80)))
			expRateLbArr:addObject(CCScaleTo:create(0.3, 2))
			expRateLbArr:addObject(CCScaleTo:create(0.3, 1))
			-- expRateLbArr:addObject(CCFadeTo:create(0.5, 0))
			-- local expRateLbSpawnArr = CCArray:create()
			-- expRateLbSpawnArr:addObject(CCMoveBy:create(0.5, ccp(0, 40)))
			-- expRateLbSpawnArr:addObject(CCFadeTo:create(0.5, 0))
			-- expRateLbArr:addObject(CCSpawn:create(expRateLbSpawnArr))
			expRateLbArr:addObject(CCCallFunc:create(function()
				expRateLb:removeFromParentAndCleanup(true)
			end))
			expRateLb:runAction(CCSequence:create(expRateLbArr))
		end
		-- expRateAction(1)
		self.bgSp:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.7), CCCallFunc:create(function() expRateAction(1) end)))
	end
end

function planeChargeDialog:overDayEvent()
	if self then
		planeRefitVoApi:requestInit(function()
			self:refreshBottomCostUI()
			local resIndex, ownResNum = planeRefitVoApi:getChargeCostResIndex()
		    if resIndex then
		    	local resIcon = tolua.cast(self.resIcon, "CCSprite")
		    	if resIcon then
		    		resIcon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(G_getResourceIconByIndex(resIndex)))
		    	end
		    end
		end)
	end
end

function planeChargeDialog:tick()
end

function planeChargeDialog:dispose()
	planeRefitVoApi:removeEventListener(self.listenerFunc)
	self = nil
	spriteController:removePlist("public/planeRefitImages.plist")
    spriteController:removeTexture("public/planeRefitImages.png")
    spriteController:removePlist("public/planeRefitEffect.plist")
    spriteController:removeTexture("public/planeRefitEffect.png")
end