accessoryPromoteSmallDialog = smallDialog:new()

function accessoryPromoteSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function accessoryPromoteSmallDialog:showPromote(layerNum, titleStr, tankID, partID)
	local sd = accessoryPromoteSmallDialog:new()
    sd:initPromote(layerNum, titleStr, tankID, partID)
    return sd
end

function accessoryPromoteSmallDialog:initPromote(layerNum, titleStr, tankID, partID)
	self.layerNum = layerNum
    self.isUseAmi = true

    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    G_addResource8888(function()
		spriteController:addPlist("public/squaredImgs.plist")
		spriteController:addTexture("public/squaredImgs.png")
	end)
	--添加战力值变化的监听
  	local powerChangeListener = function(eventKey, eventData)
  		G_showNumberChange(eventData[1], eventData[2])
 	end
  	eventDispatcher:addEventListener("user.power.change", powerChangeListener)

    local function closeDialog()
    	if powerChangeListener then
	  		eventDispatcher:removeEventListener("user.power.change", powerChangeListener)
	  		powerChangeListener = nil
	  	end
    	self:close()
    	spriteController:removePlist("public/squaredImgs.plist")
    	spriteController:removeTexture("public/squaredImgs.png")
    end
    self.bgSize = CCSizeMake(570, 750)
    local function onClickClose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 28, nil, self.layerNum, true, onClickClose, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    local topBg
    G_addResource8888(function()
    	topBg = CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	end)
	topBg:setAnchorPoint(ccp(0.5, 1))
	topBg:setOpacity(255 * 0.6)
	topBg:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 69))
	topBg:setScaleX((self.bgSize.width - 10) / topBg:getContentSize().width)
	topBg:setScaleY(330 / topBg:getContentSize().height)
	self.bgLayer:addChild(topBg)

	local UILayer = CCNode:create()
	UILayer:setContentSize(self.bgSize)
	UILayer:setAnchorPoint(ccp(0, 0))
	UILayer:setPosition(ccp(0, 0))
	self.bgLayer:addChild(UILayer)
	local initPromoteUI
	initPromoteUI = function()
		UILayer:removeAllChildrenWithCleanup(true)
		local accessoryData = accessoryVoApi:getAccessoryByPart(tankID, partID)
	    local propertyBg = LuaCCScale9Sprite:createWithSpriteFrameName("accessoryPromote_propBg.png", CCRect(20, 20, 90, 40), function()end)
	    propertyBg:setContentSize(CCSizeMake(280, topBg:getContentSize().height * topBg:getScaleY() - 30))
	    propertyBg:setAnchorPoint(ccp(1, 0.5))
	    propertyBg:setPosition(ccp(topBg:getPositionX() + topBg:getContentSize().width * topBg:getScaleX() / 2 - 50, topBg:getPositionY() - topBg:getContentSize().height * topBg:getScaleY() / 2))
	    UILayer:addChild(propertyBg)
	    local accessoryIcon = accessoryVoApi:getAccessoryIcon(accessoryData.type, 80, 100)
	    accessoryIcon:setPosition(ccp((propertyBg:getPositionX() - propertyBg:getContentSize().width) / 2, propertyBg:getPositionY() + accessoryIcon:getContentSize().height / 2))
	    UILayer:addChild(accessoryIcon)
	    local rankBg = CCSprite:createWithSpriteFrameName("IconLevel.png")
	    local rankLb = GetTTFLabel(accessoryData.rank, 30)
	    rankLb:setPosition(getCenterPoint(rankBg))
	    rankBg:addChild(rankLb)
	    rankBg:setScale(0.5)
		rankBg:setAnchorPoint(ccp(0, 1))
		rankBg:setPosition(ccp(0, 100))
		accessoryIcon:addChild(rankBg)
		local levelLb = GetTTFLabel(getlocal("fightLevel", {accessoryData.lv}), 20)
		levelLb:setAnchorPoint(ccp(1, 0))
		levelLb:setPosition(ccp(85, 5))
		accessoryIcon:addChild(levelLb)
		if accessoryData.bind == 1 and accessoryData:getConfigData("quality") > 3 and base.accessoryTech == 1 then
			local techBg = CCSprite:createWithSpriteFrameName("IconLevelBlue.png")
			local techLb = GetTTFLabel(accessoryData.techLv or 0, 30)
			techLb:setPosition(getCenterPoint(techBg))
			techBg:addChild(techLb)
			techBg:setScale(0.5)
			techBg:setAnchorPoint(ccp(1, 1))
			techBg:setPosition(ccp(98, 100))
			accessoryIcon:addChild(techBg)
		end
		local promoteLvBg = CCSprite:createWithSpriteFrameName("accessoryPromote_IconLevel.png")
		local promoteLvLb = GetTTFLabel(accessoryData.promoteLv or 0, 30)
		promoteLvLb:setPosition(getCenterPoint(promoteLvBg))
		promoteLvBg:addChild(promoteLvLb)
		promoteLvBg:setScale(0.5)
		promoteLvBg:setAnchorPoint(ccp(0, 0))
		promoteLvBg:setPosition(ccp(0, 0))
		accessoryIcon:addChild(promoteLvBg)
		local accessoryNameLb = GetTTFLabelWrap(getlocal(accessoryData:getConfigData("name")), 24, CCSizeMake(accessoryIcon:getContentSize().width + 80, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
		accessoryNameLb:setAnchorPoint(ccp(0.5, 1))
		accessoryNameLb:setPosition(ccp(accessoryIcon:getPositionX(), accessoryIcon:getPositionY() - accessoryIcon:getContentSize().height / 2 - 5))
		UILayer:addChild(accessoryNameLb)

		local costItemsTb = accessoryVoApi:getPromoteCostItems(accessoryData.type, accessoryData.promoteLv + 1)
		local isMaxLevel
		if costItemsTb == nil and accessoryData.promoteLv > 0 then
			isMaxLevel = true
		end

		local promoteLb = GetTTFLabel(getlocal("accessory_promote", {accessoryData.promoteLv}), 22)
		local upArrowSp = nil
		local riseValueLb = GetTTFLabel(isMaxLevel and getlocal("donatePointMax") or "+1", 22)
		local firstPosX
		if isMaxLevel then
			firstPosX = ((propertyBg:getPositionX() - propertyBg:getContentSize().width) - (promoteLb:getContentSize().width + 25 + riseValueLb:getContentSize().width)) / 2
		else
			upArrowSp = CCSprite:createWithSpriteFrameName("accessoryPromote_upArrow.png")
			firstPosX = ((propertyBg:getPositionX() - propertyBg:getContentSize().width) - (promoteLb:getContentSize().width + 20 + upArrowSp:getContentSize().width + 5 + riseValueLb:getContentSize().width)) / 2
		end
		promoteLb:setAnchorPoint(ccp(0, 0.5))
		if isMaxLevel then
			promoteLb:setPosition(ccp(firstPosX, accessoryNameLb:getPositionY() - accessoryNameLb:getContentSize().height - 35 - promoteLb:getContentSize().height / 2))
		else
			promoteLb:setPosition(ccp(firstPosX, accessoryNameLb:getPositionY() - accessoryNameLb:getContentSize().height - 35 - upArrowSp:getContentSize().height / 2))
		end
		UILayer:addChild(promoteLb)
		if not isMaxLevel then
			upArrowSp:setAnchorPoint(ccp(0, 0.5))
			upArrowSp:setPosition(ccp(promoteLb:getPositionX() + promoteLb:getContentSize().width + 20, promoteLb:getPositionY()))
			UILayer:addChild(upArrowSp)
		end
		riseValueLb:setAnchorPoint(ccp(0, 0.5))
		if isMaxLevel then
			riseValueLb:setPosition(ccp(promoteLb:getPositionX() + promoteLb:getContentSize().width + 5, promoteLb:getPositionY()))
		else
			riseValueLb:setPosition(ccp(upArrowSp:getPositionX() + upArrowSp:getContentSize().width + 5, promoteLb:getPositionY()))
		end
		UILayer:addChild(riseValueLb)
		riseValueLb:setColor(G_ColorGreen)

		local propertyTitleLbWidth = 100
		for i = 1, 2 do
			local lineSp = CCSprite:createWithSpriteFrameName("newPointLine.png")
			local pointSp = CCSprite:createWithSpriteFrameName("newPointRect.png")
			if i == 1 then
				lineSp:setFlipX(true)
				lineSp:setAnchorPoint(ccp(0, 0.5))
				pointSp:setAnchorPoint(ccp(0, 0.5))
				lineSp:setPosition(ccp(5, propertyBg:getContentSize().height - 30))
				pointSp:setPosition(ccp(lineSp:getPositionX() + lineSp:getContentSize().width + 10, lineSp:getPositionY()))
				propertyTitleLbWidth = propertyBg:getContentSize().width - (pointSp:getPositionX() + pointSp:getContentSize().width) * 2
			elseif i == 2 then
				lineSp:setAnchorPoint(ccp(1, 0.5))
				pointSp:setAnchorPoint(ccp(1, 0.5))
				lineSp:setPosition(ccp(propertyBg:getContentSize().width - 5, propertyBg:getContentSize().height - 30))
				pointSp:setPosition(ccp(lineSp:getPositionX() - lineSp:getContentSize().width - 10, lineSp:getPositionY()))
			end
			propertyBg:addChild(lineSp)
			propertyBg:addChild(pointSp)
		end
		local propertyTitleLb = GetTTFLabelWrap(getlocal("accessory_promoteText"), 24, CCSizeMake(propertyTitleLbWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
		propertyTitleLb:setColor(G_ColorYellowPro)
		propertyTitleLb:setPosition(ccp(propertyBg:getContentSize().width / 2, propertyBg:getContentSize().height - 30))
		propertyBg:addChild(propertyTitleLb)

		local posY = propertyBg:getContentSize().height - 80
		local attrTb = accessoryVoApi:getPromoteAttrTb(accessoryData.type, accessoryData.promoteLv)
		local addAttrTb = accessoryVoApi:getPromoteAddAttrTb(accessoryData.type, accessoryData.promoteLv + 1)
		for attrType, attrValue in pairs(attrTb) do
			local str, addStr
			local attrStr = getlocal("accessory_attAdd_" .. attrType, {attrValue .. ((accessoryCfg.attEffect[attrType] == 1) and "%%" or "") })
			local attrLb = GetTTFLabel(attrStr, 22)
			attrLb:setAnchorPoint(ccp(1, 0.5))
			attrLb:setPosition(ccp(propertyBg:getContentSize().width / 2, posY - attrLb:getContentSize().height / 2))
			propertyBg:addChild(attrLb)
			if isMaxLevel then
				attrLb:setPositionX(attrLb:getPositionX() + 50)
			end
			if addAttrTb and addAttrTb[attrType] then
				local attUpArrowSp = CCSprite:createWithSpriteFrameName("accessoryPromote_upArrow.png")
				attrLb:setPositionY(posY - attUpArrowSp:getContentSize().height / 2)
				attUpArrowSp:setAnchorPoint(ccp(0, 0.5))
				attUpArrowSp:setPosition(ccp(attrLb:getPositionX() + 10, attrLb:getPositionY()))
				propertyBg:addChild(attUpArrowSp)
				local addAttrLb = GetTTFLabel("+" .. addAttrTb[attrType] .. ((accessoryCfg.attEffect[attrType] == 1) and "%" or ""), 22)
				addAttrLb:setAnchorPoint(ccp(0, 0.5))
				addAttrLb:setPosition(ccp(attUpArrowSp:getPositionX() + attUpArrowSp:getContentSize().width + 5, attUpArrowSp:getPositionY()))
				addAttrLb:setColor(G_ColorGreen)
				propertyBg:addChild(addAttrLb)
				posY = posY - attUpArrowSp:getContentSize().height - 20
			else
				posY = posY - attrLb:getContentSize().height - 15
			end
		end
		local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(accessoryData.type, accessoryData.promoteLv)
		local upperLimitTbNext = accessoryVoApi:getPromoteUpperLimitTb(accessoryData.type, accessoryData.promoteLv + 1)
		local addPosx = G_isAsia() and 0 or 25
		if upperLimitTb then
			for i, value in pairs(upperLimitTb) do
				local upperLimitLb = GetTTFLabel(getlocal("accessory_promotePropertyText" .. i, {value}), G_isAsia() and 22 or 18 )
				upperLimitLb:setAnchorPoint(ccp(1, 0.5))
				upperLimitLb:setPosition(ccp(propertyBg:getContentSize().width / 2 + 50 + addPosx, posY - upperLimitLb:getContentSize().height / 2))
				propertyBg:addChild(upperLimitLb)
				if isMaxLevel then
					upperLimitLb:setPositionX(upperLimitLb:getPositionX() + 50)
				end
				if upperLimitTbNext and upperLimitTbNext[i] then
					local upArrowSp = CCSprite:createWithSpriteFrameName("accessoryPromote_upArrow.png")
					upperLimitLb:setPositionY(posY - upArrowSp:getContentSize().height / 2)
					upArrowSp:setAnchorPoint(ccp(0, 0.5))
					upArrowSp:setPosition(ccp(upperLimitLb:getPositionX() + 10, upperLimitLb:getPositionY()))
					propertyBg:addChild(upArrowSp)
					local addUpperLimitLb = GetTTFLabel("+" .. (upperLimitTbNext[i] - value), G_isAsia() and 22 or 18 )
					addUpperLimitLb:setAnchorPoint(ccp(0, 0.5))
					addUpperLimitLb:setPosition(ccp(upArrowSp:getPositionX() + upArrowSp:getContentSize().width + 5, upArrowSp:getPositionY()))
					addUpperLimitLb:setColor(G_ColorGreen)
					propertyBg:addChild(addUpperLimitLb)
					posY = posY - upArrowSp:getContentSize().height - 20
				else
					posY = posY - upperLimitLb:getContentSize().height - 15
				end
			end
		end

		local tempTitleLb = GetTTFLabel(getlocal("alien_tech_consume_material"), 25, true)
		local costTitleBg, costTitleLb, costTitleLbHeight = G_createNewTitle({getlocal("alien_tech_consume_material"), 25, G_ColorYellowPro}, CCSizeMake(tempTitleLb:getContentSize().width + (G_isAsia() and 100 or 130), 0), nil, true, "Helvetica-bold")
	    costTitleBg:setAnchorPoint(ccp(0.5, 0))
	    costTitleBg:setPosition(ccp(self.bgSize.width / 2, topBg:getPositionY() - topBg:getContentSize().height * topBg:getScaleY() - costTitleLbHeight - 10))
	    UILayer:addChild(costTitleBg)

	    local selectedFData = nil
	    local promoteBtnTips
	    local needGlobalFragmentNum = accessoryVoApi:getPromoteCostGlobalFragmentNum(accessoryData.type, accessoryData.promoteLv + 1)
	    local needOrangeFragment = accessoryVoApi:getPromoteCostOrangeFragment(accessoryData.type, accessoryData.promoteLv + 1)
	    if costItemsTb then
	    	local itemIconSize = 100
	    	local itemIconSpaceW = 20
	    	local itemIconCount = SizeOfTable(costItemsTb)
	    	local itemIconFirstPosX = (self.bgSize.width - ((itemIconCount + 1) * itemIconSize + itemIconCount * itemIconSpaceW)) / 2
	    	local itemIconPosY = costTitleBg:getPositionY() - 25 - itemIconSize / 2
	    	for k, v in pairs(costItemsTb) do
				local itemIcon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
					G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
				end)
	            itemIcon:setScale(itemIconSize / itemIcon:getContentSize().height)
	            scale = itemIcon:getScale()
	            itemIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	            itemIcon:setAnchorPoint(ccp(0, 0.5))
	            itemIcon:setPosition(ccp(itemIconFirstPosX + (k - 1) * (itemIconSize + itemIconSpaceW), itemIconPosY))
	            UILayer:addChild(itemIcon)
	            local needNum = v.num
	            v.num = 0
	            if v.type == "e" then
		            if v.eType == "p" then
		            	v.num = accessoryVoApi:getPropNumsById(v.id)
		            elseif v.eType == "f" then
		            	local fVo = accessoryVoApi:getFragmentByID(v.id)
		            	if fVo then
		            		v.num = fVo.num or 0
		            	end
		            end
		        else
		        	v.num = bagVoApi:getItemNumId(v.id)
		        end
	            local ownNum = v.num
	            local itemNumLb = GetTTFLabel(ownNum .. "/" .. needNum, 20)
	            if ownNum < needNum then
	            	itemNumLb:setColor(G_ColorRed)
	            	if promoteBtnTips == nil then
	            		promoteBtnTips = (v.eType == "f") and getlocal("accessory_promoteTips1") or getlocal("accessory_promoteTips3")
	            	end
	            else
	            	itemNumLb:setColor(G_ColorGreen)
	            end
	            itemNumLb:setAnchorPoint(ccp(0.5, 1))
	            itemNumLb:setPosition(ccp(itemIcon:getPositionX() + itemIconSize / 2, itemIconPosY - itemIconSize / 2 - 5))
	            UILayer:addChild(itemNumLb)
	    	end
	    	local itemNumLb = GetTTFLabel("0/" .. needGlobalFragmentNum, 20)
	    	local addSp = CCSprite:createWithSpriteFrameName("believerAddBtn.png")
	    	local checkSp = CCSprite:createWithSpriteFrameName("accessoryPromote_check.png")
	    	local addIcon = LuaCCSprite:createWithSpriteFrameName("fragmentBg5.png", function()
	    		accessoryPromoteSmallDialog:showSelectFragment(self.layerNum + 1, accessoryData, function(params)
	    			selectedFData = params
	    			if selectedFData then
	    				local selectedNum = 0
		    			for kk, vv in pairs(selectedFData) do
		    				selectedNum = selectedNum + vv
		    			end
		    			itemNumLb:setString(selectedNum .. "/" .. needGlobalFragmentNum)
		    			if selectedNum >= needGlobalFragmentNum then
		    				itemNumLb:setColor(G_ColorGreen)
		    				checkSp:setVisible(true)
		    				addSp:setVisible(false)
		    			else
		    				itemNumLb:setColor(G_ColorRed)
		    				checkSp:setVisible(false)
		    				addSp:setVisible(true)
		    			end
		    		end
	    		end, selectedFData)
	    	end)
	    	addIcon:setScale(itemIconSize / addIcon:getContentSize().width)
	    	addIcon:setAnchorPoint(ccp(0, 0.5))
	    	addIcon:setPosition(ccp(itemIconFirstPosX + itemIconCount * (itemIconSize + itemIconSpaceW), itemIconPosY))
	    	addIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	    	UILayer:addChild(addIcon)
	    	addSp:setPosition(ccp(addIcon:getContentSize().width / 2, addIcon:getContentSize().height / 2))
	    	addSp:setColor(ccc3(253, 242, 191))
	    	addIcon:addChild(addSp)
	    	checkSp:setVisible(false)
	    	checkSp:setPosition(ccp(addIcon:getContentSize().width / 2, addIcon:getContentSize().height / 2))
	    	addIcon:addChild(checkSp)
	    	itemNumLb:setAnchorPoint(ccp(0.5, 1))
	        itemNumLb:setPosition(ccp(addIcon:getPositionX() + itemIconSize / 2, itemIconPosY - itemIconSize / 2 - 5))
	        itemNumLb:setColor(G_ColorRed)
	        UILayer:addChild(itemNumLb)
	    end
	    if isMaxLevel then
	    	local maxLvTipsBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
	    	maxLvTipsBg:setContentSize(CCSizeMake(self.bgSize.width - 60, 120))
	    	maxLvTipsBg:setAnchorPoint(ccp(0.5, 1))
	    	maxLvTipsBg:setPosition(ccp(self.bgSize.width / 2, costTitleBg:getPositionY() - 25))
	    	self.bgLayer:addChild(maxLvTipsBg)
	    	local maxLvTipsLb = GetTTFLabelWrap(getlocal("accessory_promoteMaxLvTips"), 24, CCSizeMake(maxLvTipsBg:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	    	maxLvTipsLb:setPosition(ccp(maxLvTipsBg:getContentSize().width / 2, maxLvTipsBg:getContentSize().height / 2))
	    	maxLvTipsBg:addChild(maxLvTipsLb)
	    end

	    local clickTipsLbStr = isMaxLevel and getlocal("accessory_promoteMaxLvClickTips") or getlocal("accessory_promoteClickTips")
	    local clickTipsLb = GetTTFLabelWrap(clickTipsLbStr, G_isAsia() and 22 or 18, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	    clickTipsLb:setColor(G_ColorYellow)
	    UILayer:addChild(clickTipsLb)

	    local function onClickPromote(tag, obj)
	    	if G_checkClickEnable() == false then
	            do return end
	        else
	            base.setWaitTime = G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        if promoteBtnTips then
	        	G_showTipsDialog(promoteBtnTips)
	        else
	        	if selectedFData then
	        		local selectedNum = 0
	    			for kk, vv in pairs(selectedFData) do
	    				selectedNum = selectedNum + vv
	    			end
	    			if selectedNum < needGlobalFragmentNum then
	    				G_showTipsDialog(getlocal("accessory_promoteTips2"))
	        			do return end
	    			end
	        	else
	        		G_showTipsDialog(getlocal("accessory_promoteTips2"))
	        		do return end
	        	end
		        G_showSureAndCancle(getlocal("accessory_promoteTips4"), function()
		        	accessoryVoApi:requestPromote(function()
		        		G_showTipsDialog(getlocal("accessory_promoteSuccessTips"))
		        		initPromoteUI()
		        	end, "t" .. tankID, "p" .. partID, selectedFData)
		        end)
		    end
	    end
	    local promoteBtnScale = 0.8
		local promoteBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickPromote, 11, getlocal("promotion"), (G_isAsia() and 24 or 22) / promoteBtnScale, 10)
		promoteBtn:setScale(promoteBtnScale)
		promoteBtn:setAnchorPoint(ccp(0.5, 0))
		promoteBtn:setPosition(ccp(self.bgSize.width / 2, 25))
		local promoteMenu = CCMenu:createWithItem(promoteBtn)
		promoteMenu:setPosition(ccp(0, 0))
		promoteMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		UILayer:addChild(promoteMenu)
		promoteBtn:setEnabled(not isMaxLevel)
		clickTipsLb:setPosition(ccp(self.bgSize.width / 2, promoteBtn:getPositionY() + promoteBtn:getContentSize().height * promoteBtnScale + clickTipsLb:getContentSize().height / 2 + 20))
	end
	initPromoteUI()
end

function accessoryPromoteSmallDialog:showSelectFragment(layerNum, accessoryVo, sureCallback, selectedFData)
	local sd = accessoryPromoteSmallDialog:new()
    sd:initSelectFragment(layerNum, accessoryVo, sureCallback, selectedFData)
    return sd
end

function accessoryPromoteSmallDialog:initSelectFragment(layerNum, accessoryVo, sureCallback, selectedFData)
	self.layerNum = layerNum
    self.isUseAmi = true

    G_addResource8888(function()
    	spriteController:addPlist("public/newButton180711.plist")
        spriteController:addTexture("public/newButton180711.png")
    end)
    local function closeDialog()
    	self:close()
    	spriteController:removePlist("public/newButton180711.plist")
    	spriteController:removeTexture("public/newButton180711.png")
    end
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), closeDialog)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    self.bgSize = CCSizeMake(570, 750)
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 20))
    self.bgLayer:addChild(titleBg)
    local titleLb = GetTTFLabelWrap(getlocal("accessory_promoteSelectTitle"), G_isAsia() and 24 or 20, CCSizeMake(titleBg:getContentSize().width - 124, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    titleLb:setPosition(ccp(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2))
    titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)
    local unknownFragmentIcon = CCSprite:createWithSpriteFrameName("fragmentBg5.png")
    unknownFragmentIcon:setAnchorPoint(ccp(0, 1))
    unknownFragmentIcon:setPosition(ccp(30, titleBg:getPositionY() - titleBg:getContentSize().height - 15))
    self.bgLayer:addChild(unknownFragmentIcon)
    local questionSp = CCSprite:createWithSpriteFrameName("accessoryPromote_questionMark.png")
    questionSp:setPosition(ccp(unknownFragmentIcon:getContentSize().width / 2, unknownFragmentIcon:getContentSize().height / 2))
    unknownFragmentIcon:addChild(questionSp)

    local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
    progressBarBg:setContentSize(CCSizeMake(self.bgSize.width - 30 - (unknownFragmentIcon:getPositionX() + unknownFragmentIcon:getContentSize().width + 5), 28))
    progressBarBg:setAnchorPoint(ccp(1, 0))
    progressBarBg:setPosition(ccp(self.bgSize.width - 30, unknownFragmentIcon:getPositionY() - unknownFragmentIcon:getContentSize().height + 15))
    self.bgLayer:addChild(progressBarBg)
    local progressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("csi_progressBar.png"))
    progressBar:setMidpoint(ccp(0, 1))
    progressBar:setBarChangeRate(ccp(1, 0))
    progressBar:setType(kCCProgressTimerTypeBar)
    progressBar:setScaleX((progressBarBg:getContentSize().width - 8) / progressBar:getContentSize().width)
    progressBar:setScaleY((progressBarBg:getContentSize().height - 8) / progressBar:getContentSize().height)
    progressBar:setPosition(ccp(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2))
    progressBarBg:addChild(progressBar)
    local curSelectCount = 0
    local needCount = accessoryVoApi:getPromoteCostGlobalFragmentNum(accessoryVo.type, accessoryVo.promoteLv + 1)
    progressBar:setPercentage(curSelectCount / needCount * 100)
    local progressLb = GetTTFLabel(curSelectCount .. "/" .. needCount, 24)
    progressLb:setAnchorPoint(ccp(0.5, 0))
    progressLb:setPosition(ccp(progressBarBg:getPositionX() - progressBarBg:getContentSize().width / 2, progressBarBg:getPositionY() + progressBarBg:getContentSize().height + 5))
    self.bgLayer:addChild(progressLb)

    local tempData = {}
    local fNum, fId = accessoryVoApi:getPromoteCostFragmentNum(accessoryVo.type, accessoryVo.promoteLv + 1)
    local fragmentBag = accessoryVoApi:getFragmentBag()
    for k, fVo in pairs(fragmentBag) do
    	if fVo:getConfigData("quality") == 5 then
    		if fId == fVo.id then
    			if fVo.num - fNum > 0 then
    				local tankID = accessoryVo:getConfigData("tankID")
    				if tempData[tankID] == nil then
    					tempData[tankID] = {}
    				end
    				-- table.insert(tempData[tankID], {id = fVo.id, num = fVo.num - fNum})
    				tempData[tankID][fVo:getConfigData("part")] = {id = fVo.id, num = fVo.num - fNum}
    			end
    		elseif fVo.num > 0 then
    			local aid = fVo:getConfigData("output")
    			local tankID = accessoryCfg.aCfg[aid].tankID
    			if tempData[tankID] == nil then
					tempData[tankID] = {}
				end
				-- table.insert(tempData[tankID], {id = fVo.id, num = fVo.num})
				tempData[tankID][fVo:getConfigData("part")] = {id = fVo.id, num = fVo.num}
    		end
    	end
    end
    local tvDataCount = 0
    local tvData = {}
    for tankID, v in pairs(tempData) do
    	tvDataCount = tvDataCount + 1
    	table.insert(tvData, { tankID = tankID, fVo = v })
    end
    local col = 4
    local fIconSize = 100
    local fIconSpaceW, fIconSpaceH = 25, 5
    local tvCellHeightTb = {}
    local function getTvCellHeight(index)
    	if tvCellHeightTb[index] == nil then
    		local height = 0
    		height = height + 40
    		height = height + 10
    		local fVoCount = SizeOfTable(tvData[index].fVo)
    		local row = math.ceil(fVoCount / col)
    		height = height + row * (fIconSize + 30) + (row - 1) * fIconSpaceH
    		height = height + 10
    		tvCellHeightTb[index] = height
    	end
    	return tvCellHeightTb[index]
    end
    selectedFData = selectedFData and G_clone(selectedFData) or {}

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, unknownFragmentIcon:getPositionY() - unknownFragmentIcon:getContentSize().height - 10 - 135))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(ccp(self.bgSize.width / 2, unknownFragmentIcon:getPositionY() - unknownFragmentIcon:getContentSize().height - 10))
    self.bgLayer:addChild(tvBg)
    if tvDataCount <= 0 then
    	local notTipsLb = GetTTFLabelWrap(getlocal("accessory_promoteSelectNullTips"), 24, CCSizeMake(tvBg:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    	notTipsLb:setPosition(ccp(tvBg:getContentSize().width / 2, tvBg:getContentSize().height / 2))
    	notTipsLb:setColor(G_ColorGray)
    	tvBg:addChild(notTipsLb)
    else
    	self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    end
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvBg:getContentSize().height - 6)
    local tv = G_createTableView(tvSize, tvDataCount, function(idx, cellNum) return CCSizeMake(tvSize.width, getTvCellHeight(idx + 1)) end, function(cell, cellSize, idx, cellNum)
    	local cellTitleBg = CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    	cellTitleBg:setScaleX((cellSize.width - 80) / cellTitleBg:getContentSize().width)
    	cellTitleBg:setScaleY(40 / cellTitleBg:getContentSize().height)
    	cellTitleBg:setAnchorPoint(ccp(0.5, 0))
    	cellTitleBg:setPosition(ccp(cellSize.width / 2, cellSize.height - cellTitleBg:getContentSize().height * cellTitleBg:getScaleY()))
    	cell:addChild(cellTitleBg)
    	for i = 1, 2 do
			local lineSp = CCSprite:createWithSpriteFrameName("newPointLine.png")
			local pointSp = CCSprite:createWithSpriteFrameName("newPointRect.png")
			if i == 1 then
				lineSp:setFlipX(true)
				pointSp:setAnchorPoint(ccp(1, 0.5))
				lineSp:setAnchorPoint(ccp(1, 0.5))
				pointSp:setPosition(ccp(cellTitleBg:getPositionX() - cellTitleBg:getContentSize().width * cellTitleBg:getScaleX() / 2 * 0.5, cellTitleBg:getPositionY() + cellTitleBg:getContentSize().height * cellTitleBg:getScaleY() / 2 - 4))
				lineSp:setPosition(ccp(pointSp:getPositionX() - pointSp:getContentSize().width - 10, pointSp:getPositionY()))
			elseif i == 2 then
				pointSp:setAnchorPoint(ccp(0, 0.5))
				lineSp:setAnchorPoint(ccp(0, 0.5))
				pointSp:setPosition(ccp(cellTitleBg:getPositionX() + cellTitleBg:getContentSize().width * cellTitleBg:getScaleX() / 2 * 0.5, cellTitleBg:getPositionY() + cellTitleBg:getContentSize().height * cellTitleBg:getScaleY() / 2 - 4))
				lineSp:setPosition(ccp(pointSp:getPositionX() + pointSp:getContentSize().width + 10, pointSp:getPositionY()))
			end
			cell:addChild(lineSp)
			cell:addChild(pointSp)
		end
		local data = tvData[idx + 1]
		if data == nil then
			return
		end
		local tankStr = ""
		if data.tankID == 1 then
			tankStr = getlocal("tanke")
		elseif data.tankID == 2 then
			tankStr = getlocal("jianjiche")
		elseif data.tankID == 3 then
			tankStr = getlocal("zixinghuopao")
		elseif data.tankID == 4 then
			tankStr = getlocal("huojianche")
		end
    	local cellTitleLb = GetTTFLabel(getlocal("accessory_promoteFragmentTitle", {tankStr}), G_isAsia() and 22 or 18, true)
    	cellTitleLb:setPosition(ccp(cellTitleBg:getPositionX(), cellTitleBg:getPositionY() + cellTitleBg:getContentSize().height * cellTitleBg:getScaleY() / 2 - 4))
    	cellTitleLb:setColor(G_ColorYellowPro)
    	cell:addChild(cellTitleLb)
    	local fIconFirstPosX = (cellSize.width - (col * fIconSize + (col - 1) * fIconSpaceW)) / 2
    	local fIconFirstPosY = cellTitleBg:getPositionY() - 10
    	local k = 0
    	for _, v in pairs(data.fVo) do
    		k = k + 1
    		local curSelectNum = 0
    		local fIcon, shadeSp, minusSp
    		local fNumLb = GetTTFLabel(curSelectNum .. "/" .. v.num, 22)
    		local function onClickMinus()
    			curSelectNum = curSelectNum - 1
    			fNumLb:setString(curSelectNum .. "/" .. v.num)
    			curSelectCount = curSelectCount - 1
    			progressBar:setPercentage(curSelectCount / needCount * 100)
				progressLb:setString(curSelectCount .. "/" .. needCount)
				selectedFData[v.id] = curSelectNum
				if curSelectNum <= 0 then
					minusSp:removeFromParentAndCleanup(true)
					minusSp = nil
					selectedFData[v.id] = nil
				end
				if shadeSp then
					shadeSp:removeFromParentAndCleanup(true)
					shadeSp = nil
				end
    		end
    		local function onClickFIcon()
    			if curSelectCount >= needCount then
    				G_showTipsDialog(getlocal("accessory_promoteSelectFullTips2"))
    			elseif curSelectNum < v.num then
    				curSelectNum = curSelectNum + 1
	    			fNumLb:setString(curSelectNum .. "/" .. v.num)
	    			curSelectCount = curSelectCount + 1
	    			progressBar:setPercentage(curSelectCount / needCount * 100)
    				progressLb:setString(curSelectCount .. "/" .. needCount)
    				selectedFData[v.id] = curSelectNum
	    			if curSelectNum >= v.num then
	    				if shadeSp == nil then
	    					shadeSp = CCSprite:createWithSpriteFrameName("accessoryPromote_itemShade.png")
	    					shadeSp:setPosition(ccp(fIcon:getContentSize().width / 2, fIcon:getContentSize().height / 2))
	    					shadeSp:setOpacity(255 * 0.6)
	    					fIcon:addChild(shadeSp)
	    					local fullLb = GetTTFLabelWrap(getlocal("accessory_promoteSelectFullTips"), G_isAsia() and 20 or 18, CCSizeMake(shadeSp:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	    					fullLb:setPosition(ccp(shadeSp:getContentSize().width / 2, shadeSp:getContentSize().height / 2))
	    					fullLb:setColor(G_ColorYellowPro)
	    					shadeSp:addChild(fullLb)
	    				end
	    			end
	    			if minusSp == nil then
	    				minusSp = LuaCCSprite:createWithSpriteFrameName("accessoryPromote_numBg.png", onClickMinus)
	    				local minus = CCSprite:createWithSpriteFrameName("accessoryPromote_minus.png")
	    				minus:setScale(0.7)
	    				minus:setPosition(ccp(minusSp:getContentSize().width / 2, minusSp:getContentSize().height / 2))
	    				minusSp:addChild(minus)
	    				minusSp:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
	    				minusSp:setAnchorPoint(ccp(1, 1))
	    				minusSp:setPosition(ccp(fIcon:getContentSize().width + 5, fIcon:getContentSize().height + 5))
	    				fIcon:addChild(minusSp, 1)
	    			end
	    		else
	    			G_showTipsDialog(getlocal("accessory_promoteSelectFullTips1"))
    			end
    		end
    		fIcon = accessoryVoApi:getFragmentIcon(v.id, 80, fIconSize, onClickFIcon)
    		fIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    		fIcon:setAnchorPoint(ccp(0, 1))
    		fIcon:setPosition(ccp(fIconFirstPosX + ((k - 1) % col) * (fIconSize + fIconSpaceW), fIconFirstPosY - math.floor(((k - 1) / col)) * (fIconSize + 30 + fIconSpaceH)))
    		cell:addChild(fIcon)
    		fNumLb:setAnchorPoint(ccp(0.5, 1))
    		fNumLb:setPosition(ccp(fIcon:getPositionX() + fIconSize / 2, fIcon:getPositionY() - fIconSize - 4))
    		cell:addChild(fNumLb)
    		if selectedFData and selectedFData[v.id] then
    			for ii = 1, selectedFData[v.id] do
    				onClickFIcon()
    			end
    		end
    	end
    end)
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	tv:setPosition(ccp((tvBg:getContentSize().width - tvSize.width) / 2, (tvBg:getContentSize().height - tvSize.height) / 2))
	-- tv:setMaxDisToBottomOrTop(0)
	tvBg:addChild(tv)

	--添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), closeDialog)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(ccp(tvBg:getContentSize().width / 2, tvBg:getContentSize().height))
    upShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    upShiedldBg:setOpacity(0)
    tvBg:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), closeDialog)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(ccp(tvBg:getContentSize().width / 2, 0))
    downShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    downShiedldBg:setOpacity(0)
    tvBg:addChild(downShiedldBg)

    local clickTipsLb = GetTTFLabelWrap(getlocal("accessory_promoteClickTips"), G_isAsia() and 22 or 18, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickTipsLb:setAnchorPoint(ccp(0.5, 1))
    clickTipsLb:setPosition(ccp(self.bgSize.width / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10))
    clickTipsLb:setColor(G_ColorYellow)
    self.bgLayer:addChild(clickTipsLb)
    local function onClickSure(tag, obj)
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
        if type(sureCallback) == "function" then
        	sureCallback(selectedFData)
        end
    end
    local sureBtnScale = 0.8
	local sureBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickSure, 11, getlocal("accessory_promoteSelectSure"), (G_isAsia() and 24 or 22) / sureBtnScale, 10)
	sureBtn:setScale(sureBtnScale)
	sureBtn:setAnchorPoint(ccp(0.5, 1))
	sureBtn:setPosition(ccp(self.bgSize.width / 2, clickTipsLb:getPositionY() - clickTipsLb:getContentSize().height - 10))
	local sureMenu = CCMenu:createWithItem(sureBtn)
	sureMenu:setPosition(ccp(0, 0))
	sureMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	self.bgLayer:addChild(sureMenu)
	sureBtn:setEnabled(tvDataCount > 0)

    -------- 点击屏幕继续 --------
    local clickLbPosy = - 80
    local tmpLb = GetTTFLabel(getlocal("click_screen_continue"), 25)
    local clickLb = GetTTFLabelWrap(getlocal("click_screen_continue"), 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = self.bgSize.width / 2 - maxWidth / 2
        arrowPosx2 = self.bgSize.width / 2 + maxWidth / 2
    else
        arrowPosx1 = self.bgSize.width / 2 - realWidth / 2
        arrowPosx2 = self.bgSize.width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow( - 1, space))
    smallArrowSp4:runAction(G_actionArrow( - 1, space))
end

function accessoryPromoteSmallDialog:dispose()
	self = nil
end
