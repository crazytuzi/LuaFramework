planeAutoRefitDetailsDialog = commonDialog:new()

function planeAutoRefitDetailsDialog:new(layerNum, placeId, planeId, refitCount, refitConditionIndexTb, lockRefitTypeIndexTb, responseData, oldData)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.placeId = placeId
    self.planeId = planeId
    self.refitCount = refitCount
    self.refitConditionIndexTb = refitConditionIndexTb
    self.lockRefitTypeIndexTb = lockRefitTypeIndexTb
    self.responseData = responseData
    self.oldData = oldData
	spriteController:addPlist("public/platWar/platWarImage.plist")
	spriteController:addPlist("public/taskYouhua.plist")
	spriteController:addTexture("public/taskYouhua.png")
	self.moveDistance = 6 --每帧移动的距离
    return nc
end

function planeAutoRefitDetailsDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    if self.panelBottomLine then
        self.panelBottomLine:setVisible(false)
    end

    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 80 - 20)
    self.bgLayer:addChild(titleBg)
    local titleLb = GetTTFLabel(getlocal("planeRefit_autoRefitCourse"), 24, true)
    titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
    titleBg:addChild(titleLb)

    local progressBarBg = CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
    progressBarBg:setPosition(G_VisibleSizeWidth / 2, titleBg:getPositionY() - titleBg:getContentSize().height - 35 - progressBarBg:getContentSize().height / 2)
    self.bgLayer:addChild(progressBarBg)
    local progressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("taskBlueBar.png"))
    progressBar:setType(kCCProgressTimerTypeBar)
    progressBar:setMidpoint(ccp(0, 1))
    progressBar:setBarChangeRate(ccp(1, 0))
    progressBar:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
    progressBarBg:addChild(progressBar)
    progressBarBg:setScaleX(1.15)
    progressBarBg:setScaleY(1.3)
    self.progressBar = progressBar
    self.percentTb = {0, self.refitCount / 5, self.refitCount / 5 * 2, self.refitCount / 5 * 3, self.refitCount / 5 * 4, self.refitCount}
    local startPosX = progressBarBg:getPositionX() - progressBarBg:getContentSize().width * progressBarBg:getScaleX() / 2
    local spaceW = progressBarBg:getContentSize().width * progressBarBg:getScaleX() / 5 - 2
    self.pointSpTb = {}
    for k, v in pairs(self.percentTb) do
    	local pointSp = CCSprite:createWithSpriteFrameName((v == 0) and "taskActiveSp2.png" or "taskActiveSp1.png")
    	pointSp:setScale(1.4)
    	pointSp:setPosition(startPosX + (k - 1) * spaceW, progressBarBg:getPositionY())
    	self.bgLayer:addChild(pointSp)
    	local numLb = GetBMLabel(tostring(v), G_GoldFontSrc, 10)
    	numLb:setScale(0.3)
    	numLb:setPosition(pointSp:getPosition())
    	self.bgLayer:addChild(numLb)
    	self.pointSpTb[k] = pointSp
    end

    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, progressBarBg:getPositionY() - progressBarBg:getContentSize().height * progressBarBg:getScaleY() / 2 - 35 - 100))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(G_VisibleSizeWidth / 2, progressBarBg:getPositionY() - progressBarBg:getContentSize().height * progressBarBg:getScaleY() / 2 - 35)
    self.bgLayer:addChild(contentBg)

    local unlockRefitTypeIndexTb = {}
    for i = 1, 4 do
    	local isUnlock = true
    	for k, v in pairs(self.lockRefitTypeIndexTb) do
    		if i == v then
    			isUnlock = false
    			break
    		end
    	end
    	if isUnlock then
    		table.insert(unlockRefitTypeIndexTb, i)
    	end
    end

    local oldRefitExpTb = self.oldData[2] or {}
    local addValueTb = {}
    local tempRefitValue
    local isUpgrade = planeRefitVoApi:getEnergyLevel(self.placeId) > self.oldData[3]

    local refitTypeCount = SizeOfTable(unlockRefitTypeIndexTb)
    local refitTypeIconSize = 70
	local contentTvSize = CCSizeMake(contentBg:getContentSize().width - 6, contentBg:getContentSize().height - 6)
	self.cellHeightTb = {}
	local tempOldRefitExp, upgradeCountIndex, upgradeAddValue
	local function getCellHeight(countIndex)
		if self.cellHeightTb[countIndex] == nil then
			if countIndex == self.refitCount + 1 then
				self.cellHeightTb[countIndex] = math.ceil(refitTypeCount / 2) * refitTypeIconSize + 60
			else
				self.cellHeightTb[countIndex] = math.ceil(refitTypeCount / 2) * refitTypeIconSize + 32
				if self.responseData.flagTb[countIndex] == 1 then --保存的标志位
					self.cellHeightTb[countIndex] = self.cellHeightTb[countIndex] + 30
					if isUpgrade == true and upgradeCountIndex == nil then
						if tempOldRefitExp == nil then
							tempOldRefitExp = self.oldData[1]
						end
						local tempRefitExpValue = 0
			    		for kk, vv in pairs(self.responseData.allHandle[countIndex]) do
			    			tempRefitExpValue = tempRefitExpValue + vv[2]
			    		end
			    		tempOldRefitExp = tempOldRefitExp - tempRefitExpValue
			    		if tempOldRefitExp <= planeRefitVoApi:getRefitMaxExp(self.oldData[3]) - planeRefitVoApi:getNextNeedRefit(self.oldData[3]) then
			    			self.cellHeightTb[countIndex] = self.cellHeightTb[countIndex] + 30 * 2
			    			upgradeCountIndex = countIndex
			    		end
					end
				end
			end
		end
		return self.cellHeightTb[countIndex]
	end
	local cellLabelFontSize = 22
	if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "fr" then
		cellLabelFontSize = 18
		if G_isIOS() == false then
    		cellLabelFontSize = 16
    	end
	end
	self.cellTb = {}
	local contentTv = G_createTableView(contentTvSize, self.refitCount + 1, function(idx, cellNum)
		return CCSizeMake(contentTvSize.width, getCellHeight(idx + 1))
	end, function(cellP, cellSize, idx, cellNum)
		local countIndex = idx + 1
		local cell = CCNode:create()
		cell:setContentSize(cellSize)
		cell:setAnchorPoint(ccp(0, 0))
		cell:setPosition(ccp(0, 0))
		cell:setVisible(false)
		cellP:addChild(cell)
		local posY = cellSize.height
		if countIndex == self.refitCount + 1 then
			local tempCellTitleLb = GetTTFLabel(getlocal("purifying_finial_fruit"), 22, true)
			local cellTitleBg, cellTitleLb, cellTitleLbHeight = G_createNewTitle({getlocal("purifying_finial_fruit"), 22, G_ColorYellowPro}, CCSizeMake(tempCellTitleLb:getContentSize().width + 100, 0), nil, true, "Helvetica-bold")
            cellTitleBg:setAnchorPoint(ccp(0.5, 0))
            cellTitleBg:setPosition(cellSize.width / 2, cellSize.height - cellTitleLbHeight - 10)
            cell:addChild(cellTitleBg)
            posY = cellSize.height - cellTitleLbHeight - 10
		else
			local countLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
		    countLbBg:setContentSize(CCSizeMake(cellSize.width, countLbBg:getContentSize().height))
		    countLbBg:setAnchorPoint(ccp(0, 1))
		    countLbBg:setPosition(0, cellSize.height)
		    cell:addChild(countLbBg)
		    local countLb = GetTTFLabel(getlocal("raids_reward_num", {countIndex}), 22, true)
		    countLb:setAnchorPoint(ccp(0, 0.5))
		    countLb:setPosition(15, countLbBg:getContentSize().height / 2)
		    countLbBg:addChild(countLb)
		    local isSave = (self.responseData.flagTb[countIndex] == 1)
		    local stateLb = GetTTFLabel("(" .. (isSave and getlocal("collect_border_save") or getlocal("dailyTaskCancel")) .. ")", 22)
		    stateLb:setAnchorPoint(ccp(0, 0.5))
		    stateLb:setPosition(countLb:getPositionX() + countLb:getContentSize().width, countLb:getPositionY())
		    stateLb:setColor(isSave and G_ColorYellowPro or G_ColorRed)
		    countLbBg:addChild(stateLb)
		    posY = cellSize.height - countLbBg:getContentSize().height
		end
		local totalAddValue = 0
		for k, rtIndex in pairs(unlockRefitTypeIndexTb) do
			local oldValue, addValue
			if countIndex == self.refitCount + 1 then
				oldValue = oldRefitExpTb[rtIndex] or 0
				addValue = addValueTb[rtIndex] or 0
			else
				local isSave = (self.responseData.flagTb[countIndex] == 1)
    			local handleTb = self.responseData.allHandle[countIndex]
				oldValue = (oldRefitExpTb[rtIndex] or 0) + (addValueTb[rtIndex] or 0)
	    		for kk, vv in pairs(handleTb) do
	    			if vv[1] == rtIndex then
	    				addValue = vv[2]
	    				break
	    			end
	    		end
	    		if isSave then
	    			addValueTb[rtIndex] = (addValueTb[rtIndex] or 0) + addValue
	    			totalAddValue = totalAddValue + addValue
	    		end
	    	end
	    	local refitTypeIcon = CCSprite:createWithSpriteFrameName("pri_refitTypeIcon" .. rtIndex .. ".png")
	    	refitTypeIcon:setScale(refitTypeIconSize / refitTypeIcon:getContentSize().width)
	    	refitTypeIcon:setAnchorPoint(ccp(0, 0.5))
	    	refitTypeIcon:setPosition((k % 2 == 0) and cellSize.width / 2 or 0, posY - refitTypeIconSize / 2 - ((k >= 3) and refitTypeIconSize or 0))
	    	cell:addChild(refitTypeIcon)
	    	local refitTypeName = GetTTFLabelWrap(planeRefitVoApi:getRefitTypeName(self.placeId, self.planeId, rtIndex), cellLabelFontSize, CCSizeMake(cellSize.width / 2 - refitTypeIconSize, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	    	refitTypeName:setAnchorPoint(ccp(0, 0))
	    	refitTypeName:setPosition(refitTypeIcon:getPositionX() + refitTypeIconSize, refitTypeIcon:getPositionY())
	    	cell:addChild(refitTypeName)
	    	local oldValueLb = GetTTFLabel(tostring(oldValue), cellLabelFontSize)
	    	oldValueLb:setAnchorPoint(ccp(0, 1))
	    	oldValueLb:setPosition(refitTypeIcon:getPositionX() + refitTypeIconSize, refitTypeIcon:getPositionY())
	    	cell:addChild(oldValueLb)
	    	local addValueLb
	    	if countIndex == self.refitCount + 1 then
	    		local arrowSp = CCSprite:createWithSpriteFrameName("arrowUp.png")
	    		arrowSp:setScale(0.8)
	    		arrowSp:setAnchorPoint(ccp(0, 0.5))
	    		arrowSp:setPosition(oldValueLb:getPositionX() + oldValueLb:getContentSize().width + 10, oldValueLb:getPositionY() - oldValueLb:getContentSize().height / 2)
	    		cell:addChild(arrowSp)
	    		addValueLb = GetTTFLabel(tostring(oldValue + addValue), cellLabelFontSize)
	    		addValueLb:setAnchorPoint(ccp(0, 1))
	    		addValueLb:setPosition(arrowSp:getPositionX() + arrowSp:getContentSize().width * arrowSp:getScale() + 10, oldValueLb:getPositionY())
	    		addValueLb:setColor(G_ColorYellowPro)
	    	else
	    		addValueLb = GetTTFLabel(((addValue >= 0) and "+" or "") .. addValue, cellLabelFontSize)
		    	addValueLb:setAnchorPoint(ccp(0, 1))
		    	addValueLb:setPosition(oldValueLb:getPositionX() + oldValueLb:getContentSize().width + 5, oldValueLb:getPositionY())
		    	addValueLb:setColor((addValue >= 0) and G_ColorGreen or G_ColorRed)
	    	end
	    	cell:addChild(addValueLb)
	    end
	    if countIndex == self.refitCount + 1 or self.responseData.flagTb[countIndex] == 1 then
	    	local oldRefitValue, refitExpAddValue = 0, 0
	    	if countIndex == self.refitCount + 1 then
		    	oldRefitValue = self.oldData[1]
		    	for k, v in pairs(addValueTb) do
		    		refitExpAddValue = refitExpAddValue + v
		    	end
		    else
		    	if tempRefitValue == nil then
		    		tempRefitValue = 0
		    		oldRefitValue = self.oldData[1]
		    	else
		    		oldRefitValue = tempRefitValue
		    	end
		    	refitExpAddValue = totalAddValue
		    	tempRefitValue = oldRefitValue - refitExpAddValue
		    end
	    	local refitExpLb = GetTTFLabel(getlocal("planeRefit_energyText") .. "：" .. oldRefitValue, cellLabelFontSize)
	    	local arrowSp = CCSprite:createWithSpriteFrameName("arrowUp.png")
	    	arrowSp:setScale(0.8)
	    	local newExp = 0
	    	if (countIndex == self.refitCount + 1) or (upgradeCountIndex == countIndex) then
	    		newExp = oldRefitValue - refitExpAddValue + (upgradeAddValue or 0)
	    	else
	    		newExp = oldRefitValue - refitExpAddValue
	    	end
	    	local newRefitExpLb = GetTTFLabel(newExp, cellLabelFontSize)
	    	local startPosX = (cellSize.width - (refitExpLb:getContentSize().width + 10 + arrowSp:getContentSize().width * arrowSp:getScale() + 10 + newRefitExpLb:getContentSize().width)) / 2
	    	refitExpLb:setAnchorPoint(ccp(0, 0.5))
	    	refitExpLb:setPosition(startPosX, ((upgradeCountIndex == countIndex) and (30 * 2) or 0) + 15)
	    	cell:addChild(refitExpLb)
	    	arrowSp:setAnchorPoint(ccp(0, 0.5))
	    	arrowSp:setPosition(refitExpLb:getPositionX() + refitExpLb:getContentSize().width + 10, refitExpLb:getPositionY())
	    	cell:addChild(arrowSp)
	    	newRefitExpLb:setAnchorPoint(ccp(0, 0.5))
	    	newRefitExpLb:setPosition(arrowSp:getPositionX() + arrowSp:getContentSize().width * arrowSp:getScale() + 10, arrowSp:getPositionY())
	    	cell:addChild(newRefitExpLb)
	    	newRefitExpLb:setColor(G_ColorYellowPro)

	    	if upgradeCountIndex == countIndex then
		    	local levelLb = GetTTFLabel(getlocal("planeRefit_energyLevelText") .. getlocal("fightLevel", {self.oldData[3]}), cellLabelFontSize)
		    	local arrowLvSp = CCSprite:createWithSpriteFrameName("arrowUp.png")
		    	arrowLvSp:setScale(0.8)
		    	local newLevelLb = GetTTFLabel(getlocal("fightLevel", {planeRefitVoApi:getEnergyLevel(self.placeId)}), cellLabelFontSize)
		    	local startLvPosX = (cellSize.width - (levelLb:getContentSize().width + 10 + arrowLvSp:getContentSize().width * arrowLvSp:getScale() + 10 + newLevelLb:getContentSize().width)) / 2
		    	levelLb:setAnchorPoint(ccp(0, 0.5))
		    	levelLb:setPosition(startLvPosX, 30 + 15)
		    	cell:addChild(levelLb)
		    	arrowLvSp:setAnchorPoint(ccp(0, 0.5))
		    	arrowLvSp:setPosition(levelLb:getPositionX() + levelLb:getContentSize().width + 10, levelLb:getPositionY())
		    	cell:addChild(arrowLvSp)
		    	newLevelLb:setAnchorPoint(ccp(0, 0.5))
		    	newLevelLb:setPosition(arrowLvSp:getPositionX() + arrowLvSp:getContentSize().width * arrowLvSp:getScale() + 10, arrowLvSp:getPositionY())
		    	cell:addChild(newLevelLb)
		    	newLevelLb:setColor(G_ColorYellowPro)

		    	local level = planeRefitVoApi:getEnergyLevel(self.placeId)
		    	upgradeAddValue = planeRefitVoApi:getRefitMaxExp(level) - planeRefitVoApi:getRefitMaxExp(self.oldData[3])
		    	local upgradeOldRefitValue = oldRefitValue - refitExpAddValue
		    	tempRefitValue = upgradeOldRefitValue + upgradeAddValue
		    	local refitExpLb = GetTTFLabel(getlocal("planeRefit_energyText") .. "：" .. upgradeOldRefitValue, cellLabelFontSize)
		    	local arrowSp = CCSprite:createWithSpriteFrameName("arrowUp.png")
		    	arrowSp:setScale(0.8)
		    	local newRefitExpLb = GetTTFLabel(tempRefitValue, cellLabelFontSize)
		    	local startPosX = (cellSize.width - (refitExpLb:getContentSize().width + 10 + arrowSp:getContentSize().width * arrowSp:getScale() + 10 + newRefitExpLb:getContentSize().width)) / 2
		    	refitExpLb:setAnchorPoint(ccp(0, 0.5))
		    	refitExpLb:setPosition(startPosX, 15)
		    	cell:addChild(refitExpLb)
		    	arrowSp:setAnchorPoint(ccp(0, 0.5))
		    	arrowSp:setPosition(refitExpLb:getPositionX() + refitExpLb:getContentSize().width + 10, refitExpLb:getPositionY())
		    	cell:addChild(arrowSp)
		    	newRefitExpLb:setAnchorPoint(ccp(0, 0.5))
		    	newRefitExpLb:setPosition(arrowSp:getPositionX() + arrowSp:getContentSize().width * arrowSp:getScale() + 10, arrowSp:getPositionY())
		    	cell:addChild(newRefitExpLb)
		    	newRefitExpLb:setColor(G_ColorYellowPro)
		    end
	    end
		self.cellTb[countIndex] = cell
	end)
	contentTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	contentTv:setPosition(3, 3)
	contentBg:addChild(contentTv)
	self.contentTv = contentTv

	local function onClickButton(tag, obj)
		if G_checkClickEnable() == false then
	        do return end
	    else
	        base.setWaitTime = G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)
	    if self.isRunningAction then --立即完成
	    	if self.schedulerID ~= nil then
		        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
		        self.schedulerID = nil
		    end
		    for k, v in pairs(self.cellTb) do
		    	if tolua.cast(v, "CCNode") then
		    		v:stopAllActions()
		    		v:setVisible(true)
		    	end
		    end
		    local tvPoint = self.contentTv:getRecordPoint()
			tvPoint.y = 0
			self.contentTv:recoverToRecordPoint(tvPoint)
			self.progressBar:setPercentage(100)
			for k, v in pairs(self.pointSpTb) do
				local pointSp = tolua.cast(v, "CCSprite")
				if pointSp then
					pointSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("taskActiveSp2.png"))
				end
			end
	    	if self.button then
			    local buttonLb = tolua.cast(self.button:getChildByTag(11), "CCLabelTTF")
			    if buttonLb then
			    	buttonLb:setString(getlocal("planeRefit_autoRefitAgain", {self.refitCount}))
			    end
			end
			self.isRunningAction = nil
			planeRefitVoApi:checkSkillState(self.placeId, self.planeId, self.oldData[4])
	    else --再次改装
	    	local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
	    	if surplusCount <= 0 then
	    		G_showTipsDialog(getlocal("planeRefit_refitCountDissatisfy"))
	    		do return end
	    	end
	    	local needNum = planeRefitVoApi:getRefitCostPropNum(SizeOfTable(self.lockRefitTypeIndexTb))
			needNum = needNum * self.refitCount
			local pid = tonumber(RemoveFirstChar(planeRefitVoApi:getRefitCostPropId()))
			if bagVoApi:getItemNumId(pid) < needNum then
				G_showTipsDialog(getlocal("planeRefit_refitItemDissatisfy"))
				do return end
			end
	    	print("cjl --------->>> 再次改装")
	    	local level = planeRefitVoApi:getEnergyLevel(self.placeId)
		    local maxRefitExp = planeRefitVoApi:getRefitMaxExp(level)
			local usedRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId)
			local prevRefitExpTb = planeRefitVoApi:getRefitExpTb(self.placeId, self.planeId)
		    local oldData = { maxRefitExp - usedRefitExp, planeRefitVoApi:getRefitExpTb(self.placeId, self.planeId), level, prevRefitExpTb }
	    	planeRefitVoApi:requestAutoRefit(function(responseData)
	    		bagVoApi:useItemNumId(pid, needNum)
	    		self.progressBar:setPercentage(0)
				for k, v in pairs(self.pointSpTb) do
					local pointSp = tolua.cast(v, "CCSprite")
					if pointSp then
						pointSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("taskActiveSp1.png"))
					end
				end
		    	if self.button then
				    local buttonLb = tolua.cast(self.button:getChildByTag(11), "CCLabelTTF")
				    if buttonLb then
				    	buttonLb:setString(getlocal("gemCompleted"))
				    end
				end
	    		self.responseData = responseData
	    		self.oldData = oldData
	    		oldRefitExpTb = self.oldData[2] or {}
		    	addValueTb = {}
		    	tempRefitValue = nil
		    	isUpgrade = planeRefitVoApi:getEnergyLevel(self.placeId) > self.oldData[3]
		    	tempOldRefitExp = nil
		    	upgradeCountIndex = nil
		    	upgradeAddValue = nil
		    	self.cellHeightTb = {}
		    	self.cellTb = {}
		    	self.contentTv:reloadData()
		    	self:cellRunAction()
				local eventType = 1
				local newLevel = planeRefitVoApi:getEnergyLevel(self.placeId)
	    		if newLevel > level then
	    			eventType = 2
	    			G_showTipsDialog(getlocal("planeRefit_energyUpgradeTips", {getlocal("fightLevel", {newLevel})}))
	    		end
	    		local skillIdTb
	    		local rtData = planeRefitVoApi:getRefitTypeData(self.placeId, self.planeId)
	    		if rtData then
	    			skillIdTb = {}
	    			for k, v in pairs(rtData) do
	    				table.insert(skillIdTb, v.skill1)
	    				for kk, vv in pairs(v.skill2) do
	    					table.insert(skillIdTb, vv)
	    				end
	    			end
	    		end
	    		planeRefitVoApi:dispatchEvent(eventType, skillIdTb)
	    	end, self.placeId, self.planeId, self.refitCount, self.refitConditionIndexTb, self.lockRefitTypeIndexTb)
	    end
	end
	local btnScale, btnFontSize = 0.7, 24
	self.button = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickButton, 10, getlocal("gemCompleted"), btnFontSize / btnScale, 11)
	self.button:setScale(btnScale)
	self.button:setAnchorPoint(ccp(0.5, 0))
	local menu = CCMenu:createWithItem(self.button)
	menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	menu:setPosition(G_VisibleSizeWidth / 2, 30)
	self.bgLayer:addChild(menu)
	self:cellRunAction()
end

function planeAutoRefitDetailsDialog:cellRunAction()
	local cellPosY
	self.cellDataTb = {}
	for k = 1, self.refitCount + 1 do
		local tvPoint = self.contentTv:getRecordPoint()
		if tvPoint.y < 0 then
			if cellPosY == nil then
				cellPosY = tvPoint.y
			end
			local cellHeight = 0
			for i = 1, k do
				cellHeight = cellHeight + self.cellHeightTb[i]
			end
		    local tvSize = self.contentTv:getViewSize()
		    if cellHeight > tvSize.height then
		    	self.cellDataTb[k] = {
		    		cellPosY + math.abs(tvSize.height - cellHeight),
		    		self.cellTb[k],
		    	}
		    end
		end
	end
	self:cellAction(1)
	self.isRunningAction = true
end

function planeAutoRefitDetailsDialog:cellAction(index)
	if self and tolua.cast(self.bgLayer,"CCNode") and self.contentTv and self.cellTb and tolua.cast(self.cellTb[index], "CCNode") then
		local tvPoint = self.contentTv:getRecordPoint()
		if tvPoint.y < 0 then
			local cellHeight = 0
			for i = 1, index do
				cellHeight = cellHeight + self.cellHeightTb[i]
			end
		    local tvSize = self.contentTv:getViewSize()
		    if cellHeight > tvSize.height then
		    	self.showCellIndex = index
		    	self.schedulerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(...) self:update(...) end, 0, false)
		    	do return end
		    end
		end
		local arry = CCArray:create()
		-- arry:addObject(CCMoveTo:create(0.5,ccp(0,0)))
		arry:addObject(CCDelayTime:create(0.4))
		arry:addObject(CCCallFunc:create(function() self:cellAction(index + 1) end))
		self.cellTb[index]:runAction(CCSequence:create(arry))
		self.cellTb[index]:setVisible(true)
		self:updateProgressBar(index)
	end
end

function planeAutoRefitDetailsDialog:updateProgressBar(countIndex)
	if self.progressBar then 
		self.progressBar:setPercentage(countIndex / self.refitCount * 100)
	end
	if self.percentTb and self.pointSpTb then
		local pointSpIndex
		for k, v in pairs(self.percentTb) do
			if countIndex == v then
				pointSpIndex = k
				break
			end
		end
		if pointSpIndex and self.pointSpTb[pointSpIndex] then
			local pointSp = tolua.cast(self.pointSpTb[pointSpIndex], "CCSprite")
			if pointSp then
				pointSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("taskActiveSp2.png"))
			end
		end
	end
end

function planeAutoRefitDetailsDialog:update(dt)
	if self and tolua.cast(self.bgLayer, "CCNode") and self.contentTv and self.cellDataTb and self.showCellIndex then
		if self.cellDataTb[self.showCellIndex] == nil then
			if self.schedulerID ~= nil then
		        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
		        self.schedulerID = nil
		    end
		    if self.button then
			    local buttonLb = tolua.cast(self.button:getChildByTag(11), "CCLabelTTF")
			    if buttonLb then
			    	buttonLb:setString(getlocal("planeRefit_autoRefitAgain", {self.refitCount}))
			    end
			end
			self.isRunningAction = nil
			planeRefitVoApi:checkSkillState(self.placeId, self.planeId, self.oldData[4])
			do return end
		end
		local tvPoint = self.contentTv:getRecordPoint()
		tvPoint.y = tvPoint.y + self.moveDistance
		self.contentTv:recoverToRecordPoint(tvPoint)
		local posY = self.cellDataTb[self.showCellIndex][1]
		if tvPoint.y >= posY - self.cellHeightTb[self.showCellIndex] / 2 then
			local cell = self.cellDataTb[self.showCellIndex][2]
			if tolua.cast(cell, "CCNode") then
				cell:setVisible(true)
				self:updateProgressBar(self.showCellIndex)
			end
		end
		if tvPoint.y >= posY then
			self.showCellIndex = self.showCellIndex + 1
		end
	end
end

function planeAutoRefitDetailsDialog:checkCloseHandler()
	if self.isRunningAction == nil then
		self:close()
	end
end

function planeAutoRefitDetailsDialog:tick()
end

function planeAutoRefitDetailsDialog:dispose()
	self = nil
    spriteController:removePlist("public/platWar/platWarImage.plist")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end