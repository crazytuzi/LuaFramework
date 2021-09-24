strategyCenterSmallDialog = smallDialog:new()

function strategyCenterSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function strategyCenterSmallDialog:showHeroDispatch(layerNum, titleStr, dispatchCallback)
	local sd = strategyCenterSmallDialog:new()
    sd:initHeroDispatch(layerNum, titleStr, dispatchCallback)
    return sd
end

function strategyCenterSmallDialog:initHeroDispatch(layerNum, titleStr, dispatchCallback)
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

    local function closeDialog()
    	heroVoApi:clearTroops()
    	self:close()
    end
    self.bgSize = CCSizeMake(570, G_isAsia() and 650 or 700)
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

    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
    nameBg:setContentSize(CCSizeMake(self.bgSize.width - 100, nameBg:getContentSize().height))
    nameBg:setAnchorPoint(ccp(0, 1))
    nameBg:setPosition(ccp(20, self.bgSize.height - 80))
    self.bgLayer:addChild(nameBg)
    local nameLabel = GetTTFLabel(getlocal("strategyCenter_everydayHero"), 22, true)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(15, nameBg:getContentSize().height / 2))
    nameLabel:setColor(G_ColorYellowPro)
    nameBg:addChild(nameLabel)
    local everydayHeroTb = strategyCenterVoApi:getHeroPool()
    if everydayHeroTb == nil then
    	do return end
    end
    local heroIconSize = 100
    for k, hid in pairs(everydayHeroTb) do
    	local heroIcon = heroVoApi:getHeroIcon(hid, nil, nil, nil, nil, nil, nil, {showAjt = false})
    	heroIcon:setScale(heroIconSize / heroIcon:getContentSize().width)
    	heroIcon:setAnchorPoint(ccp(0, 1))
    	heroIcon:setPosition(ccp(nameBg:getPositionX() + 15 + (k - 1) * (heroIconSize + 35), nameBg:getPositionY() - nameBg:getContentSize().height - 5))
    	self.bgLayer:addChild(heroIcon)
    	local heroNameLb = GetTTFLabel(getlocal(heroListCfg[hid].heroName), 22)
    	heroNameLb:setAnchorPoint(ccp(0.5, 1))
    	heroNameLb:setPosition(ccp(heroIcon:getPositionX() + heroIconSize / 2, heroIcon:getPositionY() - heroIconSize))
    	heroNameLb:setColor(G_ColorYellowPro)
    	self.bgLayer:addChild(heroNameLb)
    end

    local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
	spaceLineSp:setContentSize(CCSizeMake(self.bgSize.width - 40, spaceLineSp:getContentSize().height))
	spaceLineSp:setPosition(ccp(self.bgSize.width / 2, nameBg:getPositionY() - nameBg:getContentSize().height - heroIconSize - 50))
	self.bgLayer:addChild(spaceLineSp)

	local dispatchDescLb = GetTTFLabelWrap(getlocal("strategyCenter_heroDispatchDesc"), 22, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	dispatchDescLb:setAnchorPoint(ccp(0.5, 1))
	dispatchDescLb:setPosition(ccp(self.bgSize.width / 2, spaceLineSp:getPositionY() - 20))
	self.bgLayer:addChild(dispatchDescLb)

	local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function()end)
	rewardBg:setContentSize(CCSizeMake(self.bgSize.width - 40, 130))
	rewardBg:setAnchorPoint(ccp(0.5, 1))
	rewardBg:setPosition(ccp(self.bgSize.width / 2, dispatchDescLb:getPositionY() - dispatchDescLb:getContentSize().height - 20))
	self.bgLayer:addChild(rewardBg)
	local tempTitleLb = GetTTFLabel(getlocal("award"), G_isAsia() == false and 22 or 24, true)
	local rewardTitleBg, rewardTitleLb, rewardTitleLbHeight = G_createNewTitle({getlocal("award"), G_isAsia() == false and 22 or 24, G_ColorYellowPro}, CCSizeMake(tempTitleLb:getContentSize().width + (G_isAsia() == false and 130 or 100), 0), nil, true, "Helvetica-bold")
    rewardTitleBg:setAnchorPoint(ccp(0.5, 0))
    rewardTitleBg:setPosition(rewardBg:getContentSize().width / 2, rewardBg:getContentSize().height - rewardTitleLbHeight - 10)
    rewardBg:addChild(rewardTitleBg)
    local multipleLb
    local rewardTb = strategyCenterVoApi:getHeroDispatchReward()
    local rewardLbPosY = rewardTitleBg:getPositionY() - 5
    for k, v in pairs(rewardTb) do
    	local rewardLb = GetTTFLabel(v.name .. "：" .. v.num, G_isAsia() and 22 or 18)
    	local rewardLbPosX = 0
    	if k % 2 == 0 then
    		rewardLb:setAnchorPoint(ccp(1, 1))
    		rewardLbPosX = rewardBg:getContentSize().width - 20
    	else
    		rewardLb:setAnchorPoint(ccp(0, 1))
    		rewardLbPosX = 20
    		if k > 1 then
    			rewardLbPosY = rewardLbPosY - rewardLb:getContentSize().height - 5
    		end
    	end
    	rewardLb:setPosition(ccp(rewardLbPosX, rewardLbPosY))
    	rewardBg:addChild(rewardLb)
    	if k == 1 then
    		multipleLb = GetTTFLabel("", G_isAsia() and 22 or 18, true)
    		multipleLb:setAnchorPoint(ccp(0, 0.5))
    		multipleLb:setPosition(ccp(rewardLb:getPositionX() + rewardLb:getContentSize().width + 10, rewardLb:getPositionY() - rewardLb:getContentSize().height / 2))
    		multipleLb:setColor(G_ColorGreen)
    		rewardBg:addChild(multipleLb)
    	end
    end

    local dispatchCount = strategyCenterVoApi:getHeroDispatchCount()
    local selectedHeroTb = {}
    local iconBgTb = {}
    local dispatchBtnLb
    for i = 1, dispatchCount do
	    local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("icon_bg_gray.png", CCRect(34, 34, 1, 1), function()
	    	if selectedHeroTb[i] then
	    		local heroIcon = tolua.cast(selectedHeroTb[i].heroIcon, "CCSprite")
	    		if heroIcon then
	    			heroIcon:removeFromParentAndCleanup(true)
	    		end
	    		heroVoApi:deletTroopsByPos(i, 1)
	    		selectedHeroTb[i] = nil
	    		if dispatchBtnLb then
	    			dispatchBtnLb:setString(getlocal("strategyCenter_shortcutDispatch"))
	    		end
	    		if multipleLb then
	    			local matchedCount = 0
		    		for k, v in pairs(selectedHeroTb) do
		    			for kk, vv in pairs(everydayHeroTb) do
		    				if v.hid == vv then
		    					matchedCount = matchedCount + 1
		    					break
		    				end
		    			end
		    		end
	        		local multiple = strategyCenterVoApi:getHeroDispatchExpMultiple(matchedCount)
	        		if multiple > 1 then
	        			multipleLb:setString("x" .. tostring(multiple))
	        		else
	        			multipleLb:setString("")
	        		end
	        	end
	    		do return end
	    	end
	    	require "luascript/script/game/scene/gamedialog/heroDialog/selectHeroDialog"
	    	selectHeroDialog:showselectHeroDialog(1, self.layerNum + 1, function(hid, productOrder)
	    		heroVoApi:setTroopsByPos(i, hid, 1)
	    		local heroIcon = heroVoApi:getHeroIcon(hid, productOrder)
	    		heroIcon:setScale(iconBgTb[i]:getContentSize().width / heroIcon:getContentSize().width)
	    		heroIcon:setPosition(ccp(iconBgTb[i]:getContentSize().width / 2, iconBgTb[i]:getContentSize().height / 2))
	    		iconBgTb[i]:addChild(heroIcon)
	    		selectedHeroTb[i] = {hid = hid, heroIcon = heroIcon}
	    		if dispatchBtnLb and SizeOfTable(selectedHeroTb) == dispatchCount then
	    			dispatchBtnLb:setString(getlocal("strategyCenter_dispatch"))
	    		end
	    		if multipleLb then
	    			local matchedCount = 0
		    		for k, v in pairs(selectedHeroTb) do
		    			for kk, vv in pairs(everydayHeroTb) do
		    				if v.hid == vv then
		    					matchedCount = matchedCount + 1
		    					break
		    				end
		    			end
		    		end
	        		local multiple = strategyCenterVoApi:getHeroDispatchExpMultiple(matchedCount)
	        		if multiple > 1 then
	        			multipleLb:setString("x" .. tostring(multiple))
	        		else
	        			multipleLb:setString("")
	        		end
	        	end
	    	end)
		end)
		iconBg:setContentSize(CCSizeMake(90, 90))
		iconBg:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		iconBg:setAnchorPoint(ccp(0, 1))
		iconBg:setPosition(ccp(35 + (i - 1) * (iconBg:getContentSize().width + 25), rewardBg:getPositionY() - rewardBg:getContentSize().height - 20))
		self.bgLayer:addChild(iconBg)
		local addSp = CCSprite:createWithSpriteFrameName("believerAddBtn.png")
		addSp:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
		iconBg:addChild(addSp)
		iconBgTb[i] = iconBg
	end
	local function onClickDispatch(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local hidTb, hidTbSize = {}, 0
        for k, v in pairs(selectedHeroTb) do
        	table.insert(hidTb, v.hid)
        	hidTbSize = hidTbSize + 1
        end
        if hidTbSize == dispatchCount then --派遣
        	strategyCenterVoApi:requestHeroDispatch(function()
        		closeDialog()
        		G_showTipsDialog(getlocal("strategyCenter_dispatchSuccess"))
        		if type(dispatchCallback) == "function" then
        			dispatchCallback()
        		end
        	end, hidTb)
        else --一键选择
        	local heroList = heroVoApi:getHeroList()
        	if SizeOfTable(heroList) < 3 then
        		G_showTipsDialog(getlocal("strategyCenter_notDispatchTips"))
        		do return end
        	end
        	for k, v in pairs(selectedHeroTb) do
        		local heroIcon = tolua.cast(v.heroIcon, "CCSprite")
        		if heroIcon then
        			heroIcon:removeFromParentAndCleanup(true)
        		end
        		selectedHeroTb[k] = nil
        	end
        	selectedHeroTb = nil
        	selectedHeroTb = {}
        	local selectedHeroCount = 0
        	for k, v in pairs(heroList) do
        		for kk, vv in pairs(everydayHeroTb) do
        			if v.hid == vv then
        				table.insert(selectedHeroTb, {vo = v})
        				selectedHeroCount = selectedHeroCount + 1
        				break
        			end
        		end
        		if selectedHeroCount == dispatchCount then
        			break
        		end
        	end
        	if multipleLb then
        		local multiple = strategyCenterVoApi:getHeroDispatchExpMultiple(selectedHeroCount)
        		if multiple > 1 then
        			multipleLb:setString("x" .. tostring(multiple))
        		end
        	end
        	for k, iconBg in pairs(iconBgTb) do
        		if selectedHeroTb[k] == nil then
        			local defHeroVo
        			for kk, vv in pairs(heroList) do
        				local isEquality = false
        				for kkk, vvv in pairs(selectedHeroTb) do
        					if vv.hid == vvv.hid then
        						isEquality = true
        						break
        					end
        				end
        				if not isEquality then
        					defHeroVo = vv
        					break
        				end
        			end
        			if defHeroVo then
        				selectedHeroTb[k] = {vo = defHeroVo}
        			end
        		end
        		if selectedHeroTb[k] then
	        		local heroVoData = selectedHeroTb[k].vo
	        		if heroVoData then
		        		local heroIcon = heroVoApi:getHeroIcon(heroVoData.hid, heroVoData.productOrder)
			    		heroIcon:setScale(iconBg:getContentSize().width / heroIcon:getContentSize().width)
			    		heroIcon:setPosition(ccp(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2))
			    		iconBg:addChild(heroIcon)
			    		selectedHeroTb[k].hid = heroVoData.hid
			    		selectedHeroTb[k].heroIcon = heroIcon
			    		heroVoApi:setTroopsByPos(k, heroVoData.hid, 1)
			    	end
			    end
        	end
        	if dispatchBtnLb then
    			dispatchBtnLb:setString(getlocal("strategyCenter_dispatch"))
    		end
        end
	end
	local dispatchBtnScale = 0.8
	local dispatchBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickDispatch, 11, getlocal("strategyCenter_shortcutDispatch"), (G_isAsia() and 24 or 20) / dispatchBtnScale, 10)
	dispatchBtn:setScale(dispatchBtnScale)
	dispatchBtn:setAnchorPoint(ccp(1, 0.5))
	dispatchBtn:setPosition(self.bgSize.width - 35, rewardBg:getPositionY() - rewardBg:getContentSize().height - 20 - 90 / 2)
	local dispatchMenu = CCMenu:createWithItem(dispatchBtn)
	dispatchMenu:setPosition(ccp(0, 0))
	dispatchMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	self.bgLayer:addChild(dispatchMenu)
	dispatchBtnLb = tolua.cast(dispatchBtn:getChildByTag(10), "CCLabelTTF")
end

function strategyCenterSmallDialog:showSkillDetails(layerNum, titleStr, skillId, upgradeCallback)
	local sd = strategyCenterSmallDialog:new()
    sd:initSkillDetails(layerNum, titleStr, skillId, upgradeCallback)
    return sd
end

function strategyCenterSmallDialog:initSkillDetails(layerNum, titleStr, skillId, upgradeCallback)
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

    local function closeDialog()
    	self:close()
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

    local skillCfgData = strategyCenterVoApi:getSkillCfgData(skillId)
    if skillCfgData == nil then
    	do return end
    end
    local skillLevel = strategyCenterVoApi:getSkillLevel(skillId)

    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
    nameBg:setContentSize(CCSizeMake(self.bgSize.width - 100, nameBg:getContentSize().height))
    nameBg:setAnchorPoint(ccp(0, 1))
    nameBg:setPosition(ccp(20, self.bgSize.height - 80))
    self.bgLayer:addChild(nameBg)
    local nameStr = getlocal(skillCfgData.skillName) .. " " .. getlocal("fightLevel", {skillLevel})
    local nameLabel = GetTTFLabel(nameStr, 22, true)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(15, nameBg:getContentSize().height / 2))
    nameLabel:setColor(G_ColorYellowPro)
    nameBg:addChild(nameLabel)
    local skillIcon = CCSprite:createWithSpriteFrameName(skillCfgData.icon)
    skillIcon:setAnchorPoint(ccp(0, 1))
    skillIcon:setPosition(ccp(nameBg:getPositionX() + 5, nameBg:getPositionY() - nameBg:getContentSize().height - 15))
    self.bgLayer:addChild(skillIcon)
    local curLbStr, nextLbStr = getlocal("current_text"), getlocal("upgrade_text")
    curLbStr = curLbStr .. strategyCenterVoApi:getSkillDesc(skillId, skillLevel)
    nextLbStr = nextLbStr .. strategyCenterVoApi:getSkillDesc(skillId, skillLevel + 1)
    local skillDescLbFontSize = G_isAsia() and 20 or 15
    if G_getCurChoseLanguage() == "ko" then
        skillDescLbFontSize = skillDescLbFontSize - 2
    end
    local skillCurDescLb = GetTTFLabelWrap(curLbStr, skillDescLbFontSize, CCSizeMake(self.bgSize.width - skillIcon:getContentSize().width - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    local skillNextDescLb = GetTTFLabelWrap(nextLbStr, skillDescLbFontSize, CCSizeMake(self.bgSize.width - skillIcon:getContentSize().width - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    skillCurDescLb:setAnchorPoint(ccp(0, 1))
    skillCurDescLb:setPosition(ccp(skillIcon:getPositionX() + skillIcon:getContentSize().width + 10, skillIcon:getPositionY()))
    self.bgLayer:addChild(skillCurDescLb)
    skillNextDescLb:setAnchorPoint(ccp(0, 1))
    skillNextDescLb:setPosition(ccp(skillCurDescLb:getPositionX(), skillIcon:getPositionY() - skillIcon:getContentSize().height / 2))
    self.bgLayer:addChild(skillNextDescLb)

    local conditionTb = strategyCenterVoApi:getSkillUpgradeCondition(skillId, skillLevel)
    local conditionTbSize = SizeOfTable((conditionTb == 0) and {} or conditionTb)
    local isCanUpgrade = true
    local conditionBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    conditionBg:setContentSize(CCSizeMake(self.bgSize.width - 40, skillIcon:getPositionY() - skillIcon:getContentSize().height - 15 - 90))
    conditionBg:setAnchorPoint(ccp(0.5, 1))
    conditionBg:setPosition(ccp(self.bgSize.width / 2, skillIcon:getPositionY() - skillIcon:getContentSize().height - 15))
    self.bgLayer:addChild(conditionBg)
    local tempTitleLb = GetTTFLabel(getlocal("condition_text"), G_isAsia() == false and 22 or 24, true)
	local conditionTitleBg, conditionTitleLb, conditionTitleLbHeight = G_createNewTitle({getlocal("condition_text"), G_isAsia() == false and 22 or 24, G_ColorYellowPro}, CCSizeMake(tempTitleLb:getContentSize().width + (G_isAsia() == false and 130 or 100), 0), nil, true, "Helvetica-bold")
    conditionTitleBg:setAnchorPoint(ccp(0.5, 0))
    conditionTitleBg:setPosition(conditionBg:getContentSize().width / 2, conditionBg:getContentSize().height - conditionTitleLbHeight - 10)
    conditionBg:addChild(conditionTitleBg)
    local conditionTvSize = CCSizeMake(conditionBg:getContentSize().width - 20, conditionBg:getContentSize().height - conditionTitleLbHeight - 20)
    local conditionTv = G_createTableView(conditionTvSize, function() return conditionTbSize end, CCSizeMake(conditionTvSize.width, 65), function(cell, cellSize, idx, cellNum)
    	local data = conditionTb[idx + 1]
    	if data == nil then
    		do return end
    	end
    	local flag = false
    	if data.key == 1 then --需要消耗的技能点
    		local skillPoint = strategyCenterVoApi:getSkillPoint(skillCfgData.tabType)
    		local tempStr = ""
    		if skillCfgData.tabType == 1 then
    			tempStr = getlocal("strategyCenter_basics")
    		elseif skillCfgData.tabType == 2 then
    			tempStr = getlocal("strategyCenter_peakedness")
    		end
    		local spLabel = GetTTFLabel(getlocal("strategyCenter_skillUpgradeCostTips1", {tempStr, skillPoint, data.value}), 22)
    		spLabel:setAnchorPoint(ccp(0, 0.5))
    		spLabel:setPosition(ccp(10, cellSize.height / 2))
    		cell:addChild(spLabel)
    		if skillPoint >= data.value then
    			flag = true
    		end
    	elseif data.key == 2 then --需要消耗的道具
    		local itemData = FormatItem(data.value)[1]
    		if itemData then
    			local itemIconSize = cellSize.height - 30
    			local itemIcon, scale = G_getItemIcon(itemData, 100, false, self.layerNum, function()
    				G_showNewPropInfo(self.layerNum + 1, true, true, nil, itemData, nil, nil, nil, nil, true)
    			end)
	            itemIcon:setScale(itemIconSize / itemIcon:getContentSize().height)
	            scale = itemIcon:getScale()
	            itemIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	            itemIcon:setAnchorPoint(ccp(0, 0.5))
	            itemIcon:setPosition(10, cellSize.height / 2)
	            cell:addChild(itemIcon, 1)
	            local ownNum = bagVoApi:getItemNumId(itemData.id)
	            local itemOwnNumLb = GetTTFLabel(tostring(ownNum), 20)
	            local itemNeedNumLb = GetTTFLabel("/" .. itemData.num, 20)
	            if ownNum < itemData.num then
	            	itemOwnNumLb:setColor(G_ColorRed)
	            else
	            	flag = true
	            end
	            itemOwnNumLb:setAnchorPoint(ccp(0, 0.5))
	            itemOwnNumLb:setPosition(ccp(itemIcon:getPositionX() + itemIconSize + 5, itemIcon:getPositionY()))
	            cell:addChild(itemOwnNumLb)
	            itemNeedNumLb:setAnchorPoint(ccp(0, 0.5))
	            itemNeedNumLb:setPosition(ccp(itemOwnNumLb:getPositionX() + itemOwnNumLb:getContentSize().width, itemOwnNumLb:getPositionY()))
	            cell:addChild(itemNeedNumLb)
    		end
    	elseif data.key == 3 then --需要已使用掉的基础技能点
    		local costSkillPoint = strategyCenterVoApi:getCostSkillPoint(1)
    		local spLabel = GetTTFLabel(getlocal("strategyCenter_skillUpgradeCostTips2", {costSkillPoint, data.value}), 22)
    		spLabel:setAnchorPoint(ccp(0, 0.5))
    		spLabel:setPosition(ccp(10, cellSize.height / 2))
    		cell:addChild(spLabel)
    		if costSkillPoint >= data.value then
    			flag = true
    		end
    	elseif data.key == 4 then --需要已使用掉的巅峰技能点
    		local costSkillPoint = strategyCenterVoApi:getCostSkillPoint(2)
    		local spLabel = GetTTFLabel(getlocal("strategyCenter_skillUpgradeCostTips3", {costSkillPoint, data.value}), 22)
    		spLabel:setAnchorPoint(ccp(0, 0.5))
    		spLabel:setPosition(ccp(10, cellSize.height / 2))
    		cell:addChild(spLabel)
    		if costSkillPoint >= data.value then
    			flag = true
    		end
    	end
    	if flag == false then
    		isCanUpgrade = false
    	end
    	local stateSp = CCSprite:createWithSpriteFrameName(flag and "IconCheck.png" or "IconFault.png")
    	stateSp:setAnchorPoint(ccp(1, 0.5))
    	stateSp:setPosition(ccp(cellSize.width - 10, cellSize.height / 2))
    	cell:addChild(stateSp)
    	if idx + 1 < cellNum then
    		local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    		lineSp:setContentSize(CCSizeMake(cellSize.width, lineSp:getContentSize().height))
    		lineSp:setPosition(ccp(cellSize.width / 2, 0))
    		cell:addChild(lineSp)
    	else
    		if self.upgradeBtn then
    			self.upgradeBtn:setEnabled(isCanUpgrade)
    		end
    	end
    end)
    conditionTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    conditionTv:setPosition(ccp((conditionBg:getContentSize().width - conditionTvSize.width) / 2, 5))
    conditionBg:addChild(conditionTv)

    local showMaxLevelUI
    local function onClickUpgrade(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        strategyCenterVoApi:requestSkillUpgrade(function()
        	G_showTipsDialog(getlocal("decorateUpSucess"))
        	for k, v in pairs(conditionTb) do
        		if v.key == 2 then
        			local itemData = FormatItem(v.value)[1]
        			if itemData then
        				bagVoApi:useItemNumId(itemData.id, itemData.num)
        			end
        		end
        	end
        	skillLevel = strategyCenterVoApi:getSkillLevel(skillId)
        	nameStr = getlocal(skillCfgData.skillName) .. " " .. getlocal("fightLevel", {skillLevel})
        	nameLabel:setString(nameStr)
        	conditionTb = strategyCenterVoApi:getSkillUpgradeCondition(skillId, skillLevel)
        	curLbStr = getlocal("current_text")
		    curLbStr = curLbStr .. strategyCenterVoApi:getSkillDesc(skillId, skillLevel)
        	skillCurDescLb:setString(curLbStr)
        	if conditionTb == 0 then
        		showMaxLevelUI()
        	else
        		conditionTbSize = SizeOfTable((conditionTb == 0) and {} or conditionTb)
	        	nextLbStr = getlocal("upgrade_text")
	        	nextLbStr = nextLbStr .. strategyCenterVoApi:getSkillDesc(skillId, skillLevel + 1)
	        	skillNextDescLb:setString(nextLbStr)
	        	isCanUpgrade = true
	        	conditionTv:reloadData()
	        end
        	if type(upgradeCallback) == "function" then
        		upgradeCallback()
        	end
        end, skillCfgData.tabType, skillId)
	end
	local upgradeBtnScale = 0.8
	local upgradeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickUpgrade, 11, getlocal("upgradeBuild"), 24 / upgradeBtnScale)
	upgradeBtn:setScale(upgradeBtnScale)
	upgradeBtn:setAnchorPoint(ccp(0.5, 1))
	upgradeBtn:setPosition(self.bgSize.width / 2, conditionBg:getPositionY() - conditionBg:getContentSize().height - 15)
	local upgradeMenu = CCMenu:createWithItem(upgradeBtn)
	upgradeMenu:setPosition(ccp(0, 0))
	upgradeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	self.bgLayer:addChild(upgradeMenu)
	upgradeBtn:setEnabled(isCanUpgrade)

	self.upgradeBtn = upgradeBtn
	self.upgradeMenu = upgradeMenu

	showMaxLevelUI = function()
		local tempSizeHeight = self.bgSize.height
    	self.bgSize.height = self.bgSize.height - conditionBg:getPositionY() + 15
    	local tempH = tempSizeHeight - self.bgSize.height
    	self.upgradeMenu:removeFromParentAndCleanup(true)
    	conditionBg:removeFromParentAndCleanup(true)
    	self.bgLayer:setContentSize(self.bgSize)
    	titleBg:setPositionY(titleBg:getPositionY() - tempH)
    	closeBtn:setPositionY(closeBtn:getPositionY() - tempH)
    	nameBg:setPositionY(nameBg:getPositionY() - tempH)
    	skillIcon:setPositionY(skillIcon:getPositionY() - tempH)
    	skillCurDescLb:setPositionY(skillCurDescLb:getPositionY() - tempH)
    	skillNextDescLb:setPositionY(skillNextDescLb:getPositionY() - tempH)
    	skillNextDescLb:setString(getlocal("decorateMax"))
	end
	if conditionTb == 0 then
		showMaxLevelUI()
	end
end

function strategyCenterSmallDialog:showPeakednessUpgrade(layerNum, titleStr, upgradeCallback)
	local sd = strategyCenterSmallDialog:new()
    sd:initPeakednessUpgrade(layerNum, titleStr, upgradeCallback)
    return sd
end

function strategyCenterSmallDialog:initPeakednessUpgrade(layerNum, titleStr, upgradeCallback)
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

    local function closeDialog()
    	self:close()
    end
    self.bgSize = CCSizeMake(570, 550)
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

    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 180))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 80))
    self.bgLayer:addChild(contentBg)
    local tempTitleLb = GetTTFLabel(getlocal("condition_text"), G_isAsia() == false and 22 or 24, true)
	local conditionTitleBg, conditionTitleLb, conditionTitleLbHeight = G_createNewTitle({getlocal("condition_text"), G_isAsia() == false and 22 or 24, G_ColorYellowPro}, CCSizeMake(tempTitleLb:getContentSize().width + (G_isAsia() == false and 130 or 100), 0), nil, true, "Helvetica-bold")
    conditionTitleBg:setAnchorPoint(ccp(0.5, 0))
    conditionTitleBg:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height - conditionTitleLbHeight - 10)
    contentBg:addChild(conditionTitleBg)
    local scLevel = strategyCenterVoApi:getLevel(2)
    local costTb = strategyCenterVoApi:getPeakednessUpgardeCost(scLevel)
    local costTbSize = SizeOfTable(costTb)
    local isCanUpgrade = (costTbSize > 0)
    local conditionTvSize = CCSizeMake(contentBg:getContentSize().width - 20, contentBg:getContentSize().height - conditionTitleLbHeight - 20)
    local conditionTv = G_createTableView(conditionTvSize, costTbSize, CCSizeMake(conditionTvSize.width, 65), function(cell, cellSize, idx, cellNum)
    	local data = costTb[idx + 1]
    	if data == nil then
    		do return end
    	end
    	local resIcon = CCSprite:createWithSpriteFrameName(G_getResourceIcon(data.key))
    	resIcon:setAnchorPoint(ccp(0, 0.5))
    	resIcon:setPosition(ccp(10, cellSize.height / 2))
    	cell:addChild(resIcon)
    	local ownResNum = playerVoApi:getResNum(data.key)
		local ownResLb = GetTTFLabel(FormatNumber(ownResNum), 18)
		local costResLb = GetTTFLabel("/" .. FormatNumber(data.value), 18)
		ownResLb:setAnchorPoint(ccp(0, 0.5))
		ownResLb:setPosition(ccp(resIcon:getPositionX() + resIcon:getContentSize().width, resIcon:getPositionY()))
		cell:addChild(ownResLb)
		costResLb:setAnchorPoint(ccp(0, 0.5))
		costResLb:setPosition(ccp(ownResLb:getPositionX() + ownResLb:getContentSize().width, resIcon:getPositionY()))
		cell:addChild(costResLb)
		local stateSp
		if ownResNum < data.value then
			isCanUpgrade = false
			ownResLb:setColor(G_ColorRed)
			stateSp = CCSprite:createWithSpriteFrameName("IconFault.png")
		else
			stateSp = CCSprite:createWithSpriteFrameName("IconCheck.png")
		end
    	stateSp:setAnchorPoint(ccp(1, 0.5))
    	stateSp:setPosition(ccp(cellSize.width - 10, cellSize.height / 2))
    	cell:addChild(stateSp)
    	if idx + 1 < cellNum then
    		local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    		lineSp:setContentSize(CCSizeMake(cellSize.width, lineSp:getContentSize().height))
    		lineSp:setPosition(ccp(cellSize.width / 2, 0))
    		cell:addChild(lineSp)
    	end
    end)
    conditionTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    conditionTv:setPosition(ccp((contentBg:getContentSize().width - conditionTvSize.width) / 2, 5))
    contentBg:addChild(conditionTv)

    local function onClickUpgrade(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        strategyCenterVoApi:requestPeakednessUpgrade(function()
        	G_showTipsDialog(getlocal("decorateUpSucess"))
        	for k, v in ipairs(costTb) do
        		playerVoApi:useResNum(v.key, v.value)
        	end
        	closeDialog()
        	if type(upgradeCallback) == "function" then
        		upgradeCallback()
        	end
        end)
	end
	local upgradeBtnScale = 0.8
	local upgradeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickUpgrade, 11, getlocal("upgradeBuild"), 24 / upgradeBtnScale)
	upgradeBtn:setScale(upgradeBtnScale)
	upgradeBtn:setAnchorPoint(ccp(0.5, 1))
	upgradeBtn:setPosition(self.bgSize.width / 2, contentBg:getPositionY() - contentBg:getContentSize().height - 15)
	local upgradeMenu = CCMenu:createWithItem(upgradeBtn)
	upgradeMenu:setPosition(ccp(0, 0))
	upgradeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	self.bgLayer:addChild(upgradeMenu)
	upgradeBtn:setEnabled(isCanUpgrade)
end

function strategyCenterSmallDialog:dispose()
	self = nil
end