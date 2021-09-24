planeAutoRefitDialog = commonDialog:new()

function planeAutoRefitDialog:new(layerNum, dialogObj)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.dialogObj = dialogObj
    G_addResource8888(function()
	    spriteController:addPlist("public/squaredImgs.plist")
	  	spriteController:addTexture("public/squaredImgs.png")
	end)
    return nc
end

function planeAutoRefitDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    if self.panelBottomLine then
        self.panelBottomLine:setVisible(false)
    end

    if self.dialogObj == nil then
    	print("cjl -------->>>> ERROR:数据错误！！！")
    	do return end
    end
	self.placeId = self.dialogObj.curSelectedPlaceId
    self.planeId = self.dialogObj.curSelectedPlaneId
    self.curSelectedRefitCount = 0
    local fontSize = 22
    if G_getCurChoseLanguage() == "de" then
    	fontSize = 23
    end

    --////改装锁定
    local posY = G_VisibleSizeHeight - 80 - 25
    local refitLockLb = GetTTFLabel(getlocal("planeRefit_refitLockText"), fontSize, true)
    refitLockLb:setAnchorPoint(ccp(0, 1))
    refitLockLb:setPosition(15, posY)
    self.bgLayer:addChild(refitLockLb)
    posY = refitLockLb:getPositionY() - refitLockLb:getContentSize().height - 10

    local costListItemTb = {}
    local lockRefitTypeIndexTb = {}
    self.dialogObj:getCurLockCount(lockRefitTypeIndexTb)
    for i = 1, 4 do
    	local unlockSp
    	local unlockPic = "pri_unlockIcon.png"
    	for k, v in pairs(lockRefitTypeIndexTb) do
    		if i == v then
    			unlockPic = "pri_lockIcon.png"
    			break
    		end
    	end
    	unlockSp = LuaCCSprite:createWithSpriteFrameName(unlockPic, function()
    		local lockSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_lockIcon.png")
			local unlockSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pri_unlockIcon.png")
			if unlockSp:isFrameDisplayed(unlockSpriteFrame) then
				local lockCount = self.dialogObj:getCurLockCount()
				if lockCount >= 3 then
					G_showTipsDialog(getlocal("planeRefit_lockErrorTips"))
					do return end
				end
				print("cjl -------->>> 上锁")
				unlockSp:setDisplayFrame(lockSpriteFrame)
				table.insert(lockRefitTypeIndexTb, i)
				self.dialogObj:lockStateLogic(1, i)
				self:refreshCostItemNum()
				if costListItemTb[i + 2] then
					costListItemTb[i + 2].costLb:setVisible(false)
					costListItemTb[i + 2].grayLb:setVisible(true)
					costListItemTb[i + 2].checkBoxItem:setEnabled(false)
					costListItemTb[i + 2].checkBoxItem:setSelectedIndex(0)
				end
				local refitTypeIconBg = tolua.cast(self.dialogObj.bgSp:getChildByTag(100 + i), "CCSprite")
				local prevUnlockSp = tolua.cast(refitTypeIconBg:getChildByTag(2), "CCSprite")
				prevUnlockSp:setDisplayFrame(lockSpriteFrame)
			elseif unlockSp:isFrameDisplayed(lockSpriteFrame) then
				print("cjl -------->>> 开锁")
				unlockSp:setDisplayFrame(unlockSpriteFrame)
				for k, v in pairs(lockRefitTypeIndexTb) do
					if v == i then
						table.remove(lockRefitTypeIndexTb, k)
						break
					end
				end
				self.dialogObj:lockStateLogic(2, i)
				self:refreshCostItemNum()
				if costListItemTb[i + 2] then
					costListItemTb[i + 2].grayLb:setVisible(false)
					costListItemTb[i + 2].costLb:setVisible(true)
					costListItemTb[i + 2].checkBoxItem:setEnabled(true)
				end
				local refitTypeIconBg = tolua.cast(self.dialogObj.bgSp:getChildByTag(100 + i), "CCSprite")
				local prevUnlockSp = tolua.cast(refitTypeIconBg:getChildByTag(2), "CCSprite")
				prevUnlockSp:setDisplayFrame(unlockSpriteFrame)
			end
		end)
		unlockSp:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    	local refitTypeIcon = CCSprite:createWithSpriteFrameName("pri_refitTypeIcon" .. i .. ".png")
    	unlockSp:setAnchorPoint(ccp(0, 0.5))
    	refitTypeIcon:setAnchorPoint(ccp(0, 0.5))
    	local startPosX = (i - 1) * (G_VisibleSizeWidth / 4) + (G_VisibleSizeWidth / 4 - (unlockSp:getContentSize().width + refitTypeIcon:getContentSize().width)) / 2
    	unlockSp:setPosition(startPosX, posY - refitTypeIcon:getContentSize().height / 2)
    	refitTypeIcon:setPosition(startPosX + unlockSp:getContentSize().width, posY - refitTypeIcon:getContentSize().height / 2)
    	self.bgLayer:addChild(unlockSp)
    	self.bgLayer:addChild(refitTypeIcon)
    	if i == 4 then
    		posY = refitTypeIcon:getPositionY() - refitTypeIcon:getContentSize().height / 2
    	end
    end
    posY = posY - 10

    local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
    spaceLineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, spaceLineSp:getContentSize().height))
    spaceLineSp:setPosition(G_VisibleSizeWidth / 2, posY - spaceLineSp:getContentSize().height / 2)
    self.bgLayer:addChild(spaceLineSp)
    posY = spaceLineSp:getPositionY() - spaceLineSp:getContentSize().height / 2 - 20

    --////连续改装
    local refitContinuousLb = GetTTFLabel(getlocal("planeRefit_refitContinuousText"), fontSize, true)
    refitContinuousLb:setAnchorPoint(ccp(0, 1))
    refitContinuousLb:setPosition(refitLockLb:getPositionX(), posY)
    self.bgLayer:addChild(refitContinuousLb)
    posY = refitContinuousLb:getPositionY() - refitContinuousLb:getContentSize().height - 15

    local checkBoxScale = 1
    local autoRefitCountTb = planeRefitVoApi:getAutoRefitCountTb()
    local autoRefitSize = SizeOfTable(autoRefitCountTb)
    local checkBoxItemTb = {}
    local function onClickCheckBox(tag, obj)
    	if obj and tolua.cast(obj, "CCMenuItemToggle") then
			local isSelected = (obj:getSelectedIndex() == 1)
			if isSelected then
				local limitLv = planeRefitVoApi:getAutoRefitCountOfLvLimit(tag)
				if planeRefitVoApi:getEnergyLevel(self.placeId) < limitLv then
					obj:setSelectedIndex(0)
					G_showTipsDialog(planeRefitVoApi:getPlaceName(self.placeId) .. "-" .. getlocal("planeRefit_autoRefitCountLimitTips", {limitLv, autoRefitCountTb[tag]}))
					do return end
				end
			end
			for k, v in pairs(checkBoxItemTb) do
				if v == obj then
					if isSelected then
						self.curSelectedRefitCount = autoRefitCountTb[k]
						self:refreshCostItemNum()
					else
						v:setSelectedIndex(1)
					end
				else
					v:setSelectedIndex(0)
				end
			end
		end
    end
    for k, v in pairs(autoRefitCountTb) do
    	local checkBox, checkBoxItem = G_createCheckBox("LegionCheckBtnUn.png", "LegionCheckBtn.png", onClickCheckBox)
	    checkBox:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	    checkBoxItem:setScale(checkBoxScale)
	    local checkBoxLb = GetTTFLabel(getlocal("purifying_num", {v}), fontSize)
	    local startPosX = (k - 1) * (G_VisibleSizeWidth / autoRefitSize) + (G_VisibleSizeWidth / autoRefitSize - (checkBoxItem:getContentSize().width * checkBoxScale + 10 + checkBoxLb:getContentSize().width)) / 2
	    checkBoxItem:setAnchorPoint(ccp(0, 0.5))
	    checkBox:setPosition(startPosX, posY - checkBoxItem:getContentSize().height * checkBoxScale / 2)
	    checkBoxLb:setAnchorPoint(ccp(0, 0.5))
	    checkBoxLb:setPosition(startPosX + 10 + checkBoxItem:getContentSize().width * checkBoxScale, checkBox:getPositionY())
	    self.bgLayer:addChild(checkBox)
	    self.bgLayer:addChild(checkBoxLb)
	    checkBoxItem:setTag(k)
	    if k == 1 then
	    	checkBoxItem:setSelectedIndex(1)
	    	self.curSelectedRefitCount = v
	    end
	    checkBoxItemTb[k] = checkBoxItem
	    if k == autoRefitSize then
	    	posY = checkBox:getPositionY() - checkBoxItem:getContentSize().height * checkBoxScale / 2
	    end
    end
    posY = posY - 10

    local spaceLineSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
    spaceLineSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, spaceLineSp2:getContentSize().height))
    spaceLineSp2:setPosition(G_VisibleSizeWidth / 2, posY - spaceLineSp2:getContentSize().height / 2)
    self.bgLayer:addChild(spaceLineSp2)
    posY = spaceLineSp2:getPositionY() - spaceLineSp2:getContentSize().height / 2 - 20

    --////改装消耗
    local refitCostLb = GetTTFLabel(getlocal("planeRefit_refitCostText"), fontSize, true)
    refitCostLb:setAnchorPoint(ccp(0, 1))
    refitCostLb:setPosition(refitLockLb:getPositionX(), posY)
    self.bgLayer:addChild(refitCostLb)
    posY = refitCostLb:getPositionY() - refitCostLb:getContentSize().height - 15

    local refitCostTb = { --该id是根据后端要求格式定义的，用于向后端传参
    	{id = 5, text = getlocal("planeRefit_autoRefitCostTypeDesc1"), 
    		getTips = function(self)
    			local level = planeRefitVoApi:getEnergyLevel(self.placeId)
				local maxRefitExp = planeRefitVoApi:getRefitMaxExp(level)
				local usedRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId)
				local surplusRefitExp = maxRefitExp - usedRefitExp
				if surplusRefitExp == 0 then
    				return getlocal("planeRefit_autoRefitCostTypeDesc1Tips")
    			end
    		end},
    	{id = 6, text = getlocal("planeRefit_autoRefitCostTypeDesc2"), 
    		getTips = function(self)
    			local level = planeRefitVoApi:getEnergyLevel(self.placeId)
				local maxRefitExp = planeRefitVoApi:getRefitMaxExp(level)
				local usedRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId)
				local surplusRefitExp = maxRefitExp - usedRefitExp
				if surplusRefitExp == maxRefitExp then
    				return getlocal("planeRefit_autoRefitCostTypeDesc2Tips")
    			end
    		end},
    	{id = 1, text = getlocal("planeRefit_autoRefitCostTypeDesc3", {planeRefitVoApi:getRefitTypeName(self.placeId, self.planeId, 1)}), 
    		getTips = function(self)
    			local refitTypeData = planeRefitVoApi:getRefitTypeData(self.placeId, self.planeId, 1)
				local curRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId, 1)
				if curRefitExp >= refitTypeData.powerMax then
    				return getlocal("planeRefit_autoRefitCostTypeDesc3Tips")
    			end
    		end},
    	{id = 2, text = getlocal("planeRefit_autoRefitCostTypeDesc3", {planeRefitVoApi:getRefitTypeName(self.placeId, self.planeId, 2)}), 
    		getTips = function(self)
    			local refitTypeData = planeRefitVoApi:getRefitTypeData(self.placeId, self.planeId, 2)
				local curRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId, 2)
				if curRefitExp >= refitTypeData.powerMax then
    				return getlocal("planeRefit_autoRefitCostTypeDesc3Tips")
    			end
    		end},
    	{id = 3, text = getlocal("planeRefit_autoRefitCostTypeDesc3", {planeRefitVoApi:getRefitTypeName(self.placeId, self.planeId, 3)}), 
    		getTips = function(self)
    			local refitTypeData = planeRefitVoApi:getRefitTypeData(self.placeId, self.planeId, 3)
				local curRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId, 3)
				if curRefitExp >= refitTypeData.powerMax then
    				return getlocal("planeRefit_autoRefitCostTypeDesc3Tips")
    			end
    		end},
    	{id = 4, text = getlocal("planeRefit_autoRefitCostTypeDesc3", {planeRefitVoApi:getRefitTypeName(self.placeId, self.planeId, 4)}), 
    		getTips = function(self)
    			local refitTypeData = planeRefitVoApi:getRefitTypeData(self.placeId, self.planeId, 4)
				local curRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId, 4)
				if curRefitExp >= refitTypeData.powerMax then
    				return getlocal("planeRefit_autoRefitCostTypeDesc3Tips")
    			end
    		end},
	}
	local selectedIndexTb = {}

	--////底部UI
	local bottomPosY = (G_getIphoneType() == G_iphone4) and 20 or 35
	local function onClickRefit(tag, obj)
		if G_checkClickEnable() == false then
	        do return end
	    else
	        base.setWaitTime = G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)
	    local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
    	if surplusCount <= 0 then
    		G_showTipsDialog(getlocal("planeRefit_refitCountDissatisfy"))
    		do return end
    	end
	    if self.curSelectedRefitCount == nil or self.curSelectedRefitCount <= 0 then
	    	G_showTipsDialog(getlocal("planeRefit_autoRefitCountSelectTips"))
	    	do return end
	    end
	    local needNum = planeRefitVoApi:getRefitCostPropNum(SizeOfTable(lockRefitTypeIndexTb))
		needNum = needNum * self.curSelectedRefitCount
		if self.refitCostItem and self.refitCostItem.num < needNum then
			G_showTipsDialog(getlocal("planeRefit_refitItemDissatisfy"))
			do return end
		end
		local refitConditionIndexTb, refitConditionIndexSize = {}, 0
	    for k, v in pairs(costListItemTb) do
	    	if v.checkBoxItem:getSelectedIndex() == 1 then
	    		table.insert(refitConditionIndexTb, refitCostTb[k].id)
	    		refitConditionIndexSize = refitConditionIndexSize + 1
	    		selectedIndexTb[k] = 1
	    	else
	    		selectedIndexTb[k] = 0
	    	end
	    end
	    if refitConditionIndexSize == 0 then
	    	G_showTipsDialog(getlocal("purifying_select_tip"))
	    	do return end
	    end
	    print("cjl ------->>> 开始自动改装")
	    local level = planeRefitVoApi:getEnergyLevel(self.placeId)
	    local maxRefitExp = planeRefitVoApi:getRefitMaxExp(level)
		local usedRefitExp = planeRefitVoApi:getRefitExp(self.placeId, self.planeId)
		local prevRefitExpTb = planeRefitVoApi:getRefitExpTb(self.placeId, self.planeId)
	    local oldData = { maxRefitExp - usedRefitExp, planeRefitVoApi:getRefitExpTb(self.placeId, self.planeId), level, prevRefitExpTb }
	    planeRefitVoApi:requestAutoRefit(function(responseData)
	    	planeRefitVoApi:showAutoRefitDetailsDialog(self.layerNum + 1, self.placeId, self.planeId, self.curSelectedRefitCount, refitConditionIndexTb, lockRefitTypeIndexTb, responseData, oldData)
	    	if self.refitCostItem then
    			bagVoApi:useItemNumId(self.refitCostItem.id, needNum)
    			self.refitCostItem.num = self.refitCostItem.num - needNum
    		end
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
	    end, self.placeId, self.planeId, self.curSelectedRefitCount, refitConditionIndexTb, lockRefitTypeIndexTb)
	end
	local btnScale, btnFontSize = 0.7, 24
	local refitBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickRefit, 10, getlocal("planeRefit_refitText"), btnFontSize / btnScale)
	refitBtn:setScale(btnScale)
	refitBtn:setAnchorPoint(ccp(0.5, 0))
	local refitMenu = CCMenu:createWithItem(refitBtn)
	refitMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	refitMenu:setPosition(G_VisibleSizeWidth / 2, bottomPosY)
	self.bgLayer:addChild(refitMenu)

	bottomPosY = refitMenu:getPositionY() + refitBtn:getContentSize().height * btnScale + 10
	local pid = planeRefitVoApi:getRefitCostPropId()
    if pid then
    	local costLb = GetTTFLabel(getlocal("oneKeyDonateTitle2"), fontSize)
    	self.bgLayer:addChild(costLb)
    	local item = FormatItem({p = {[pid] = 0}})[1]
    	item.num = bagVoApi:getItemNumId(item.id)
    	local iconSize = 35
    	local itemIcon, iconScale = G_getItemIcon(item, 100, false, self.layerNum, function()
	        G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
	    end)
	    itemIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	    itemIcon:setScale(iconSize / itemIcon:getContentSize().height)
	    iconScale = itemIcon:getScale()
	    self.bgLayer:addChild(itemIcon)
	    local numLb = GetTTFLabel(item.num, fontSize)
	    self.bgLayer:addChild(numLb)
	    local needNum = planeRefitVoApi:getRefitCostPropNum(SizeOfTable(lockRefitTypeIndexTb))
	    if self.curSelectedRefitCount > 0 then
	    	needNum = needNum * self.curSelectedRefitCount
	    end
	    if item.num < needNum then
	    	numLb:setColor(G_ColorRed)
	    else
	    	numLb:setColor(G_ColorGreen)
	    end
	    local needNumLb = GetTTFLabel("/" .. needNum, fontSize)
	    self.bgLayer:addChild(needNumLb)
	    local startPosX = (G_VisibleSizeWidth - (costLb:getContentSize().width + 5 + iconSize + 3 + numLb:getContentSize().width + needNumLb:getContentSize().width)) / 2
	    costLb:setAnchorPoint(ccp(0, 0.5))
	    costLb:setPosition(startPosX, bottomPosY + iconSize / 2)
	    itemIcon:setPosition(costLb:getPositionX() + costLb:getContentSize().width + 5 + iconSize / 2, bottomPosY + iconSize / 2)
	    numLb:setAnchorPoint(ccp(0, 0.5))
	    numLb:setPosition(itemIcon:getPositionX() + iconSize / 2 + 3, bottomPosY + iconSize / 2)
	    needNumLb:setAnchorPoint(ccp(0, 0.5))
	    needNumLb:setPosition(numLb:getPositionX() + numLb:getContentSize().width, bottomPosY + iconSize / 2)
	    bottomPosY = bottomPosY + iconSize + 10
	    self.numLb = numLb
	    self.needNumLb = needNumLb
	    self.refitCostItem = item
	    local buyItem = LuaCCSprite:createWithSpriteFrameName("believerAddBtn.png", function()
	    	local function onBuyHander(buyNum)
	    		print("cjl --------->>> 购买消耗道具", buyNum)
	    		local function socketCallback(fn, data)
					local ret, sData = base:checkServerData(data)
			        if ret == true then
			        	self:refreshCostItemNum()
			        	G_showTipsDialog(getlocal("buyPropPrompt", {item.name}))
			        	self.dialogObj:refreshBottomItemNum()
			        end
				end
	    		socketHelper:buyProc(item.id, socketCallback, buyNum)
	    	end
	    	shopVoApi:showBatchBuyPropSmallDialog(item.key, self.layerNum + 1, onBuyHander)
	    end)
	    buyItem:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	    buyItem:setScale((iconSize - 10) / buyItem:getContentSize().height)
	    buyItem:setPosition(needNumLb:getPositionX() + needNumLb:getContentSize().width + 10 + buyItem:getContentSize().width * buyItem:getScale() / 2, needNumLb:getPositionY())
	    buyItem:setColor(ccc3(135, 253, 139))
	    self.bgLayer:addChild(buyItem)
	    self.buyItem = buyItem
    end
    local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
    local surplusLb = GetTTFLabel(getlocal("equip_explore_num", {surplusCount}), fontSize)
    surplusLb:setAnchorPoint(ccp(0.5, 0))
    surplusLb:setPosition(G_VisibleSizeWidth / 2, bottomPosY)
    self.bgLayer:addChild(surplusLb)
    bottomPosY = surplusLb:getPositionY() + surplusLb:getContentSize().height + 10
    self.surplusLb = surplusLb

	local spaceLineSp3 = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
    spaceLineSp3:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, spaceLineSp3:getContentSize().height))
    spaceLineSp3:setPosition(G_VisibleSizeWidth / 2, bottomPosY + spaceLineSp3:getContentSize().height / 2)
    self.bgLayer:addChild(spaceLineSp3)

    local function onClickCostCheckBox(tag, obj)
		if obj and tolua.cast(obj, "CCMenuItemToggle") then
			local isSelected = (obj:getSelectedIndex() == 1)
			if tag == 1 and isSelected and costListItemTb[2].checkBoxItem:getSelectedIndex() == 1 then
				costListItemTb[2].checkBoxItem:setSelectedIndex(0)
			elseif tag == 2 and isSelected and costListItemTb[1].checkBoxItem:getSelectedIndex() == 1 then
				costListItemTb[1].checkBoxItem:setSelectedIndex(0)
			end
		end
	end
	local costListTvSize = CCSizeMake(G_VisibleSizeWidth - 100, posY - (spaceLineSp3:getPositionY() + spaceLineSp3:getContentSize().height / 2 + 15))
	local costListItemHeightTb = {}
	local function initCostListItem()
		for k, v in pairs(refitCostTb) do
			local checkBox, checkBoxItem = G_createCheckBox("LegionCheckBtnUn.png", "LegionCheckBtn.png", onClickCostCheckBox)
			checkBox:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		    checkBoxItem:setScale(checkBoxScale)
		    checkBoxItem:setTag(k)
		    local lbStr, lbStrColorTb, grayLbStr = v.text, {}, v.text
		    local tipsStr = v.getTips(self)
		    if tipsStr then
		    	lbStr = lbStr .. "<rayimg>" .. tipsStr
		    	lbStrColorTb = {nil, G_ColorRed}
		    	grayLbStr = grayLbStr .. tipsStr
		    end
		    local lbWidth = costListTvSize.width - checkBoxItem:getContentSize().width * checkBoxScale - 10
		    local costLb, costLbHeight = G_getRichTextLabel(lbStr, lbStrColorTb, fontSize, lbWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
		    local grayLb = GetTTFLabelWrap(grayLbStr, fontSize, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
		    local rowHeight = math.max(checkBoxItem:getContentSize().height * checkBoxScale, costLbHeight)
		    costListItemHeightTb[k] = rowHeight + 20
		    costListItemTb[k] = { checkBox = checkBox, checkBoxItem = checkBoxItem, costLb = costLb, costLbHeight = costLbHeight, grayLb = grayLb }
			if selectedIndexTb and selectedIndexTb[k] then
				checkBoxItem:setSelectedIndex(selectedIndexTb[k])
			elseif k == 1 then --默认勾选第一条
				checkBoxItem:setSelectedIndex(1)
			end
		end
	end
	initCostListItem()
	local costListTv = G_createTableView(costListTvSize, SizeOfTable(costListItemTb), function(idx, cellNum)
		return CCSizeMake(costListTvSize.width, costListItemHeightTb[idx + 1])
	end, function(cell, cellSize, idx, cellNum)
		local listItem = costListItemTb[idx + 1]
		listItem.grayLb:setAnchorPoint(ccp(0, 0.5))
		listItem.grayLb:setPosition(0, cellSize.height / 2)
		listItem.grayLb:setColor(G_ColorGray)
		listItem.grayLb:setVisible(false)
		cell:addChild(listItem.grayLb)
		listItem.costLb:setAnchorPoint(ccp(0, 0.5))
		listItem.costLb:setPosition(0, cellSize.height / 2 + listItem.costLbHeight / 2)
		cell:addChild(listItem.costLb)
		listItem.checkBoxItem:setAnchorPoint(ccp(1, 0.5))
		listItem.checkBox:setPosition(cellSize.width, cellSize.height / 2)
		cell:addChild(listItem.checkBox)
		if idx + 1 < cellNum then
			local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            lineSp:setContentSize(CCSizeMake(cellSize.width, lineSp:getContentSize().height))
            lineSp:setPosition(cellSize.width / 2, 0)
            lineSp:setRotation(180)
            cell:addChild(lineSp)
		end
	end)
	costListTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	costListTv:setPosition((G_VisibleSizeWidth - costListTvSize.width) / 2, spaceLineSp3:getPositionY() + spaceLineSp3:getContentSize().height / 2 + 15)
	costListTv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(costListTv)

	for k, v in pairs(lockRefitTypeIndexTb) do
		if costListItemTb[v + 2] then
			costListItemTb[v + 2].costLb:setVisible(false)
			costListItemTb[v + 2].grayLb:setVisible(true)
			costListItemTb[v + 2].checkBoxItem:setEnabled(false)
			costListItemTb[v + 2].checkBoxItem:setSelectedIndex(0)
		end
	end

    self.listenerFunc = function(eventKey, eventData)
  		if self and type(eventData) == "table" and (eventData.eventType == 1 or eventData.eventType == 2) then
  			self:refreshCostItemNum()
    		local surplusLb = tolua.cast(self.surplusLb, "CCLabelTTF")
    		if surplusLb then
    			local surplusCount = planeRefitVoApi:getRefitMaxCount() - planeRefitVoApi:getRefitCount()
				surplusLb:setString(getlocal("equip_explore_num", {surplusCount}))
			end
			costListItemTb = {}
			costListItemHeightTb = {}
			initCostListItem()
			costListTv:reloadData()
			for k, v in pairs(lockRefitTypeIndexTb) do
				if costListItemTb[v + 2] then
					costListItemTb[v + 2].costLb:setVisible(false)
					costListItemTb[v + 2].grayLb:setVisible(true)
					costListItemTb[v + 2].checkBoxItem:setEnabled(false)
					costListItemTb[v + 2].checkBoxItem:setSelectedIndex(0)
				end
			end
		end
  	end
  	planeRefitVoApi:addEventListener(self.listenerFunc)
end

function planeAutoRefitDialog:refreshCostItemNum()
	local needNumLb = tolua.cast(self.needNumLb, "CCLabelTTF")
	if needNumLb then
		local needNum = planeRefitVoApi:getRefitCostPropNum(self.dialogObj:getCurLockCount())
		if self.curSelectedRefitCount > 0 then
			needNum = needNum * self.curSelectedRefitCount
		end
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
		if self.buyItem then
			self.buyItem:setPositionX(needNumLb:getPositionX() + needNumLb:getContentSize().width + 10 + self.buyItem:getContentSize().width * self.buyItem:getScale() / 2)
		end
	end
end

function planeAutoRefitDialog:tick()
end

function planeAutoRefitDialog:dispose()
	planeRefitVoApi:removeEventListener(self.listenerFunc)
	self = nil
	spriteController:removePlist("public/squaredImgs.plist")
    spriteController:removeTexture("public/squaredImgs.png")
end