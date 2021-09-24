planeRefitSmallDialog = smallDialog:new()

function planeRefitSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function planeRefitSmallDialog:showAttributeDetails(layerNum, titleStr, paramsTb)
    local sd = planeRefitSmallDialog:new()
    sd:initAttributeDetails(layerNum, titleStr, paramsTb)
end

function planeRefitSmallDialog:initAttributeDetails(layerNum, titleStr, paramsTb)
	self.layerNum = layerNum
    self.isUseAmi = true

    if type(paramsTb) ~= "table" then
    	print("cjl --------->>> ERROR：[paramsTb]参数错误！")
    	do return end
    end
    local placeId = paramsTb[1]
    local planeId = paramsTb[2]
    local refitTypeIndex = paramsTb[3]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    G_addResource8888(function()
        spriteController:addPlist("public/accessoryImage.plist")
        spriteController:addPlist("public/accessoryImage2.plist")
        spriteController:addPlist("public/nbSkill.plist")
        spriteController:addTexture("public/nbSkill.png")
    end)

    local function closeDialog()
    	self:close()
        spriteController:removePlist("public/nbSkill.plist")
        spriteController:addTexture("public/nbSkill.png")
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

    local bgSp
    G_addResource8888(function()
    	bgSp = CCSprite:create("public/pri_attributeBg.jpg")
    end)
    bgSp:setAnchorPoint(ccp(0.5, 1))
    bgSp:setPosition(self.bgSize.width / 2, self.bgSize.height - 68)
    self.bgLayer:addChild(bgSp)

    local function onClickInfo(tag, obj)
    	if G_checkClickEnable() == false then
			do return end
		else
			base.setWaitTime = G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local tabStr = { 
			getlocal("planeRefit_attributeDetailsDesc1"),
			getlocal("planeRefit_attributeDetailsDesc2"),
			getlocal("planeRefit_attributeDetailsDesc3"),
			getlocal("planeRefit_attributeDetailsDesc4"),
			getlocal("planeRefit_attributeDetailsDesc5"),
			getlocal("planeRefit_attributeDetailsDesc6"),
		}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickInfo)
    infoItem:setAnchorPoint(ccp(1, 1))
    infoItem:setScale(0.7)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    infoBtn:setPosition(self.bgSize.width - 20, self.bgSize.height - 80)
    self.bgLayer:addChild(infoBtn)

    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 30, bgSp:getPositionY() - bgSp:getContentSize().height - 20))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, bgSp:getPositionY() - bgSp:getContentSize().height)
    self.bgLayer:addChild(contentBg)

    local refitTypeData = planeRefitVoApi:getRefitTypeData(placeId, planeId, refitTypeIndex)
    local refitExp = planeRefitVoApi:getRefitExp(placeId, planeId, refitTypeIndex)
    local selectedSkillId = tonumber(refitTypeData.skill1)
    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
    nameBg:setContentSize(CCSizeMake(contentBg:getContentSize().width - 20, nameBg:getContentSize().height))
    nameBg:setAnchorPoint(ccp(0, 1))
    nameBg:setPosition(10, contentBg:getContentSize().height - 5)
    contentBg:addChild(nameBg)
    local nameLb = GetTTFLabel("", 22, true)
    nameLb:setAnchorPoint(ccp(0, 0.5))
    nameLb:setPosition(15, nameBg:getContentSize().height / 2)
    nameLb:setColor(G_ColorYellowPro)
    nameBg:addChild(nameLb)

    local skillLevelLbTb = {}
    local bottomNode = CCNode:create()
    bottomNode:setContentSize(CCSizeMake(contentBg:getContentSize().width, contentBg:getContentSize().height - nameBg:getContentSize().height))
    bottomNode:setPosition(0, 0)
    contentBg:addChild(bottomNode)
    local function initBottomUI(skillIndex)
    	bottomNode:removeAllChildrenWithCleanup(true)
    	local skillCfg = planeRefitVoApi:getSkillCfg(selectedSkillId)
    	if skillCfg then
    		local bottomHeight = 150
    		local skillLv = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex, skillIndex)
    		local tipsStr, isCanUpgrade, skillValidMaxLv, skillAttrValue
    		if skillIndex then
	    		local needRefitExp = refitTypeData.powerNeed[skillIndex]
	    		if refitExp < needRefitExp then --未达到改装进度(未激活)
	    			tipsStr = getlocal("planeRefit_skillActiveTips", {needRefitExp})
	    		else --已达改装进度(已激活)
	    			local nextLvNeedRefitExp = planeRefitVoApi:getSkillNeedRefitExp(skillLv + 1)
	    			if nextLvNeedRefitExp then
	    				if refitExp >= nextLvNeedRefitExp then --可以升级
	    					isCanUpgrade = true
	    				else --不能升级
	    					local curLvNeedRefitExp = planeRefitVoApi:getSkillNeedRefitExp(skillLv)
	    					if refitExp < curLvNeedRefitExp then
	    						tipsStr = getlocal("planeRefit_skillActiveTips1", {curLvNeedRefitExp, skillLv})
	    						skillValidMaxLv = planeRefitVoApi:getSkillValidMaxLv(refitExp)
	    					else
	    						tipsStr = getlocal("planeRefit_skillUpgradeTips", {nextLvNeedRefitExp})
	    					end
	    				end
	    			else --已满级
	    				local curLvNeedRefitExp = planeRefitVoApi:getSkillNeedRefitExp(skillLv)
    					if refitExp < curLvNeedRefitExp then
    						tipsStr = getlocal("planeRefit_skillActiveTips1", {curLvNeedRefitExp, skillLv})
    						skillValidMaxLv = planeRefitVoApi:getSkillValidMaxLv(refitExp)
    					else
	    					tipsStr = getlocal("alliance_lvmax")
	    				end
	    			end
	    		end
	    		nameLb:setString(getlocal(skillCfg.skillName) .. getlocal("fightLevel", {skillValidMaxLv or skillLv}))
	    		skillAttrValue = planeRefitVoApi:getSkillAttributeValue(selectedSkillId, skillValidMaxLv or skillLv)
	    	else
	    		nameLb:setString(getlocal(skillCfg.skillName))
	    		skillAttrValue = planeRefitVoApi:getSkillAttributeValue(selectedSkillId, 0, refitExp)
	    	end

    		local descLbTvSize = CCSizeMake(bottomNode:getContentSize().width - 20, bottomNode:getContentSize().height - ((skillIndex == nil) and 0 or bottomHeight))
    		if skillCfg.percent == 1 then
    			skillAttrValue = skillAttrValue * 100
    		end
	    	local descLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 20, CCSize(descLbTvSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	    	local descTipsLb
	    	local descLbTvCellHeight = descLb:getContentSize().height + 20
	    	if skillIndex == nil then
	    		descTipsLb = GetTTFLabelWrap(getlocal("planeRefit_refitTypeSkillAttributeTips"), 20, CCSize(descLbTvSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	    		descLbTvCellHeight = descLb:getContentSize().height + descTipsLb:getContentSize().height + 30
	    	end
	    	local descLbTv = G_createTableView(descLbTvSize, 1, CCSizeMake(descLbTvSize.width, descLbTvCellHeight), function(cell, cellSize, idx, cellNum)
	    		descLb:setAnchorPoint(ccp(0.5, 1))
	    		descLb:setPosition(cellSize.width / 2, cellSize.height - 10)
	    		cell:addChild(descLb)
	    		if descTipsLb then
		    		descTipsLb:setAnchorPoint(ccp(0.5, 1))
		    		descTipsLb:setPosition(cellSize.width / 2, descLb:getPositionY() - descLb:getContentSize().height - 10)
		    		cell:addChild(descTipsLb)
		    	end
	    	end)
	    	descLbTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	    	descLbTv:setMaxDisToBottomOrTop(0)
	    	descLbTv:setPosition((bottomNode:getContentSize().width - descLbTvSize.width) / 2, (skillIndex == nil) and 0 or bottomHeight)
	    	bottomNode:addChild(descLbTv)

    		if tipsStr then
    			local tipLb = GetTTFLabelWrap(tipsStr, 20, CCSizeMake(bottomNode:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    			tipLb:setPosition(bottomNode:getContentSize().width / 2, bottomHeight / 2)
    			tipLb:setColor(G_ColorGray)
    			bottomNode:addChild(tipLb)
    		end
    		if isCanUpgrade then
    			local costItemTb = planeRefitVoApi:getSkillUpgradeCost(skillLv)
    			local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
				spaceLineSp:setContentSize(CCSizeMake(bottomNode:getContentSize().width - 10, spaceLineSp:getContentSize().height))
				spaceLineSp:setPosition(bottomNode:getContentSize().width / 2, bottomHeight)
				bottomNode:addChild(spaceLineSp)
				local arrowSp = CCSprite:createWithSpriteFrameName("csi_arrowUp_yellow.png")
				arrowSp:setScale(0.35)
				arrowSp:setRotation(90)
				arrowSp:setPosition(bottomNode:getContentSize().width / 2, spaceLineSp:getPositionY() - 15)
				bottomNode:addChild(arrowSp)
				local curAttrValueLb = GetTTFLabel("+" .. ((skillCfg.percent == 1) and (skillAttrValue .. "%") or tostring(skillAttrValue)), 20)
				curAttrValueLb:setAnchorPoint(ccp(1, 0.5))
				curAttrValueLb:setPosition(arrowSp:getPositionX() - arrowSp:getContentSize().height * arrowSp:getScale(), arrowSp:getPositionY())
				bottomNode:addChild(curAttrValueLb)
				local nextSkillAttrValue = planeRefitVoApi:getSkillAttributeValue(selectedSkillId, skillLv + 1)
				local nextAttrValueLb = GetTTFLabel("+" .. ((skillCfg.percent == 1) and (nextSkillAttrValue * 100 .. "%") or tostring(nextSkillAttrValue)), 20)
				nextAttrValueLb:setAnchorPoint(ccp(0, 0.5))
				nextAttrValueLb:setPosition(arrowSp:getPositionX() + arrowSp:getContentSize().height * arrowSp:getScale(), arrowSp:getPositionY())
				nextAttrValueLb:setColor(G_ColorGreen)
				bottomNode:addChild(nextAttrValueLb)
				local function onClickUpgrade(tag, obj)
					if G_checkClickEnable() == false then
			            do return end
			        else
			            base.setWaitTime = G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)
			        for k, v in pairs(costItemTb) do
			        	if bagVoApi:getItemNumId(v.id) < v.num then
			        		G_showTipsDialog(getlocal("notenoughprop"))
			        		do return end
			        	end
			        end
			        print("cjl ------->>> 升级")
			        planeRefitVoApi:requestSkillUpgrade(function()
			        	G_showTipsDialog(getlocal("decorateUpSucess"))
			        	for k, v in pairs(costItemTb) do
			        		bagVoApi:useItemNumId(v.id, v.num)
			        	end
			        	initBottomUI(skillIndex)
			        	local skillLevelLb = tolua.cast(skillLevelLbTb[skillIndex], "CCLabelTTF")
			        	if skillLevelLb then
			        		local skillLv_b = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex, skillIndex, true)
				        	local nextLvNeedRefitExp_b = planeRefitVoApi:getSkillNeedRefitExp(skillLv_b + 1)
				        	local levelLbStr, levelLbColor
				        	if nextLvNeedRefitExp_b then
				        		skillLevelLb:setString(getlocal("fightLevel", {skillLv_b}))
				        		skillLevelLb:setColor(G_ColorWhite)
				        	else
				        		skillLevelLb:setString(getlocal("donatePointMax"))
				        		skillLevelLb:setColor(G_ColorRed)
				        	end
			        	end
			        	planeRefitVoApi:dispatchEvent(3, {selectedSkillId})
			        end, placeId, planeId, refitTypeIndex, skillIndex)
				end
				local btnScale, btnFontSize = 0.7, 24
				local upgradeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickUpgrade, 10, getlocal("upgradeBuild"), btnFontSize / btnScale)
				upgradeBtn:setScale(btnScale)
				upgradeBtn:setAnchorPoint(ccp(1, 0))
				local upgradeMenu = CCMenu:createWithItem(upgradeBtn)
				upgradeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
				upgradeMenu:setPosition(bottomNode:getContentSize().width - 30, 35)
				bottomNode:addChild(upgradeMenu)
				local itemIconSize = 75
				local costItemTvSize = CCSizeMake(upgradeMenu:getPositionX() - upgradeBtn:getContentSize().width * btnScale - 50, itemIconSize + 25)
				local costItemTv = G_createTableView(costItemTvSize, SizeOfTable(costItemTb), CCSizeMake(itemIconSize + 30, costItemTvSize.height), function(cell, cellSize, idx, cellNum)
					local item = costItemTb[idx + 1]
					if item == nil then
						do return end
					end
					local itemIcon, iconScale = G_getItemIcon(item, 100, false, self.layerNum, function()
				        G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
				    end)
				    itemIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
				    itemIcon:setScale(itemIconSize / itemIcon:getContentSize().height)
				    iconScale = itemIcon:getScale()
				    itemIcon:setPosition(cellSize.width / 2, cellSize.height - 2 - itemIconSize / 2)
				    cell:addChild(itemIcon)
				    local ownNum = bagVoApi:getItemNumId(item.id)
				    local itemOwnNumLb = GetTTFLabel(tostring(ownNum), 20)
				    local itemNeedNumLb = GetTTFLabel("/" .. item.num, 20)
				    itemOwnNumLb:setColor((ownNum >= item.num) and G_ColorGreen or G_ColorRed)
				    local itemNumLbStartPosX = (cellSize.width - (itemOwnNumLb:getContentSize().width + itemNeedNumLb:getContentSize().width)) / 2
				    itemOwnNumLb:setAnchorPoint(ccp(0, 1))
				    itemOwnNumLb:setPosition(itemNumLbStartPosX, itemIcon:getPositionY() - itemIconSize / 2)
				    cell:addChild(itemOwnNumLb)
				    itemNeedNumLb:setAnchorPoint(ccp(0, 1))
				    itemNeedNumLb:setPosition(itemNumLbStartPosX + itemOwnNumLb:getContentSize().width, itemIcon:getPositionY() - itemIconSize / 2)
				    cell:addChild(itemNeedNumLb)
				end, true)
				costItemTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
				costItemTv:setPosition(30, 10)
				bottomNode:addChild(costItemTv)
    		end
    	end
    end
    initBottomUI()

    local refitTypeIconBg = CCSprite:createWithSpriteFrameName("pri_refitTypeIconBg.png")
	refitTypeIconBg:setPosition(bgSp:getContentSize().width / 2, bgSp:getContentSize().height / 2 - 30)
	bgSp:addChild(refitTypeIconBg)
	local focusSp_A = CCSprite:createWithSpriteFrameName("pri_focus_a.png")
	focusSp_A:setPosition(refitTypeIconBg:getContentSize().width / 2, refitTypeIconBg:getContentSize().height / 2)
	refitTypeIconBg:addChild(focusSp_A, 2)
	local focusSp = CCSprite:createWithSpriteFrameName("pri_focus.png")
	focusSp:setVisible(false)
	refitTypeIconBg:addChild(focusSp, 2)
	local refitTypeIcon = LuaCCSprite:createWithSpriteFrameName("pri_refitTypeIcon" .. refitTypeIndex .. ".png", function()
		if selectedSkillId == tonumber(refitTypeData.skill1) then
    		do return end
    	end
		focusSp:setVisible(false)
		focusSp:setPosition(0, 0)
		focusSp_A:setVisible(true)
		selectedSkillId = tonumber(refitTypeData.skill1)
		initBottomUI()
	end)
	refitTypeIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	refitTypeIcon:setPosition(refitTypeIconBg:getContentSize().width / 2, refitTypeIconBg:getContentSize().height / 2)
	refitTypeIconBg:addChild(refitTypeIcon)
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
        progressBarBg:addChild(progressBar)
        local percentage = planeRefitVoApi:getRefitPercentageByIndex(refitTypeData, refitExp, j)
        progressBar:setPercentage(percentage)

        local needRefitExp = refitTypeData.powerNeed[j]
        local linePic = (j == 3) and "pri_uiLine2.png" or "pri_uiLine1.png"
        local lineSp
        if refitExp < needRefitExp then
        	lineSp = GraySprite:createWithSpriteFrameName(linePic)
        else
        	lineSp = CCSprite:createWithSpriteFrameName(linePic)
        end
        if j == 3 then
        	lineSp:setAnchorPoint(ccp(0.5, 0))
        	lineSp:setPosition(G_getPointOfCircle(circleBottomPos, circleRadius, 90))
        else
        	if j == 1 then
        		lineSp:setFlipX(true)
        		lineSp:setAnchorPoint(ccp(0, 1))
        	else
        		lineSp:setAnchorPoint(ccp(1, 1))
        	end
        	lineSp:setPosition(G_getPointOfCircle(circleBottomPos, circleRadius, 90 - j * (360 / 3)))
        end
        refitTypeIconBg:addChild(lineSp)
        local skillIcon
        local skillId = refitTypeData.skill2[j]
        local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
        if skillCfg then
        	local skillIconSize = 90
        	local function onClickSkillIcon()
        		if selectedSkillId == tonumber(skillId) then
	        		do return end
	        	end
	        	focusSp_A:setVisible(false)
	        	focusSp:setScale((skillIconSize + 16) / focusSp:getContentSize().width)
	        	focusSp:setPosition(skillIcon:getPosition())
	        	focusSp:setVisible(true)
	        	selectedSkillId = tonumber(skillId)
	        	initBottomUI(j)
        	end
        	if refitExp < needRefitExp then
        		skillIcon = GraySprite:createWithSpriteFrameName(skillCfg.icon)
        		local clickSkillIcon = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), onClickSkillIcon)
        		clickSkillIcon:setContentSize(skillIcon:getContentSize())
        		clickSkillIcon:setPosition(skillIcon:getContentSize().width / 2, skillIcon:getContentSize().height / 2)
        		clickSkillIcon:setOpacity(0)
        		skillIcon:addChild(clickSkillIcon)
        		clickSkillIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        	else
        		skillIcon = LuaCCSprite:createWithSpriteFrameName(skillCfg.icon, onClickSkillIcon)
        		skillIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        	end
        	skillIcon:setScale(skillIconSize / skillIcon:getContentSize().width)
        	if j == 1 then
	    		skillIcon:setPosition(lineSp:getPositionX() + lineSp:getContentSize().width - 15 + skillIcon:getContentSize().width * skillIcon:getScale() / 2, lineSp:getPositionY() - lineSp:getContentSize().height)
	    	elseif j == 2 then
	    		skillIcon:setPosition(lineSp:getPositionX() - lineSp:getContentSize().width + 15 - skillIcon:getContentSize().width * skillIcon:getScale() / 2, lineSp:getPositionY() - lineSp:getContentSize().height)
	    	elseif j == 3 then
	    		skillIcon:setPosition(lineSp:getPositionX(), lineSp:getPositionY() + lineSp:getContentSize().height - 20 + skillIcon:getContentSize().height * skillIcon:getScale() / 2)
	    	end
        	refitTypeIconBg:addChild(skillIcon)
        	local skillLv = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex, j, true)
        	local nextLvNeedRefitExp = planeRefitVoApi:getSkillNeedRefitExp(skillLv + 1)
        	local levelLbStr, levelLbColor
        	if nextLvNeedRefitExp then
        		levelLbStr = getlocal("fightLevel", {skillLv})        		
        	else
        		levelLbStr = getlocal("donatePointMax")
        		levelLbColor = G_ColorRed
        	end
        	local levelLb = GetTTFLabel(levelLbStr, 20)
        	if levelLbColor then
        		levelLb:setColor(levelLbColor)
        	end
            local levelBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            levelBg:setAnchorPoint(ccp(0, 1))
            levelBg:setRotation(180)
            levelBg:setScaleX((levelLb:getContentSize().width + 20) / levelBg:getContentSize().width)
            levelBg:setScaleY(levelLb:getContentSize().height / levelBg:getContentSize().height)
            levelBg:setPosition(skillIcon:getPositionX() + skillIconSize / 2 - 5, skillIcon:getPositionY() - skillIconSize / 2 + 5)
            refitTypeIconBg:addChild(levelBg)
            levelLb:setAnchorPoint(ccp(1, 0))
            levelLb:setPosition(levelBg:getPosition())
            refitTypeIconBg:addChild(levelLb)
            skillLevelLbTb[j] = levelLb
        	if refitExp < needRefitExp then
        		local tipLbFontSize = 18
        		if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "fr" then
        			tipLbFontSize = 13
        			if G_isIOS() == false then
			    		tipLbFontSize = 11
			    	end
        		end
        		local tipLb = GetTTFLabelWrap(getlocal("planeRefit_skillActiveTips", {needRefitExp}), tipLbFontSize, CCSizeMake(230, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        		tipLb:setPosition(skillIcon:getPositionX(), skillIcon:getPositionY() - skillIcon:getContentSize().height * skillIcon:getScale() / 2 - tipLb:getContentSize().height / 2)
        		if j == 3 then
        			tipLb:setPositionY(skillIcon:getPositionY() + skillIcon:getContentSize().height * skillIcon:getScale() / 2 + tipLb:getContentSize().height / 2 + 2)
        		end
        		tipLb:setColor(G_ColorRed)
        		refitTypeIconBg:addChild(tipLb)
        	end
        end
	end
	local refitExpLb = GetTTFLabel(refitExp .. "/" .. refitTypeData.powerMax, 22, true)
	refitExpLb:setAnchorPoint(ccp(0.5, 1))
	refitExpLb:setPosition(refitTypeIconBg:getContentSize().width / 2, - 5)
	refitTypeIconBg:addChild(refitExpLb)

	if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 88 then
		otherGuideMgr:toNextStep()
	end
end

function planeRefitSmallDialog:showAttributePandect(layerNum, titleStr, paramsTb)
    local sd = planeRefitSmallDialog:new()
    sd:initAttributePandect(layerNum, titleStr, paramsTb)
end

function planeRefitSmallDialog:initAttributePandect(layerNum, titleStr, paramsTb)
	self.layerNum = layerNum
    self.isUseAmi = true

    if type(paramsTb) ~= "table" then
    	print("cjl --------->>> ERROR：[paramsTb]参数错误！")
    	do return end
    end
    local placeId = paramsTb[1]
    local planeId = paramsTb[2]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")

    local function closeDialog()
    	self:close()
        spriteController:removePlist("public/nbSkill.plist")
        spriteController:addTexture("public/nbSkill.png")
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

    local attributeTv, refitTypeIndex
    local refitTypeData = planeRefitVoApi:getRefitTypeData(placeId, planeId, refitTypeIndex)
    local refitExp = planeRefitVoApi:getRefitExp(placeId, planeId, refitTypeIndex)
    local focusIndex = 1
    local iconFocus = CCSprite:createWithSpriteFrameName("pri_selectedBg.png")
    self.bgLayer:addChild(iconFocus)
    local topIconSize = 75
    for i = 1, 5 do
    	local iconPic, iconSp
    	if i == 1 then
    		local pVo = planeVoApi:getPlaneVoById(planeId)
    		iconPic = pVo:getPic()
		else
			iconPic = "pri_refitTypeIcon" .. (i - 1) .. ".png"
		end
		iconSp = LuaCCSprite:createWithSpriteFrameName(iconPic, function()
			if focusIndex == i then
				return
			end
			iconFocus:setPosition(iconSp:getPosition())
			focusIndex = i
			if i == 1 then
				refitTypeIndex = nil
			else
				refitTypeIndex = i - 1
			end
			refitTypeData = planeRefitVoApi:getRefitTypeData(placeId, planeId, refitTypeIndex)
			refitExp = planeRefitVoApi:getRefitExp(placeId, planeId, refitTypeIndex)
			if attributeTv then
				attributeTv:reloadData()
			end
		end)
		iconSp:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
		iconSp:setScale(topIconSize / iconSp:getContentSize().width)
		iconSp:setPosition(10 + (i - 1) * ((self.bgSize.width - 10) / 5) + (self.bgSize.width - 10) / 5 / 2, self.bgSize.height - 85 - topIconSize / 2)
		self.bgLayer:addChild(iconSp)
		if i == 1 then
			local placeData = planeRefitVoApi:getPlaceData()
		    local placeIcon = CCSprite:createWithSpriteFrameName(placeData[placeId].icon)
		    placeIcon:setAnchorPoint(ccp(0, 1))
		    placeIcon:setPosition(iconSp:getPositionX() - iconSp:getContentSize().width * iconSp:getScale() / 2, iconSp:getPositionY() + iconSp:getContentSize().height * iconSp:getScale() / 2)
		    placeIcon:setScale(0.5)
		    self.bgLayer:addChild(placeIcon)
		    iconFocus:setPosition(iconSp:getPosition())
		end
	end
	local cellHeightTb = {}
	local skillIconSize = 100
	local attributeTvSize = CCSizeMake(self.bgSize.width - 30, iconFocus:getPositionY() - iconFocus:getContentSize().height / 2 - 25)
	attributeTv = G_createTableView(attributeTvSize, 2, function(idx, cellNum)
		if cellHeightTb[focusIndex] == nil then
			cellHeightTb[focusIndex] = {}
		end
		if cellHeightTb[focusIndex][idx + 1] == nil then
			local height = 40
			if idx == 0 then
				local refitTypeData_a = refitTypeIndex and {refitTypeData} or refitTypeData
	        	for k, v in pairs(refitTypeData_a) do
	        		local skillId = v.skill1
		        	local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
		        	if skillCfg then
		        		local refitExp_a = refitTypeIndex and refitExp or planeRefitVoApi:getRefitExp(placeId, planeId, k)
		        		local skillAttrValue = planeRefitVoApi:getSkillAttributeValue(skillId, 0, refitExp_a)
		        		if skillCfg.percent == 1 then
			    			skillAttrValue = skillAttrValue * 100
			    		end
		        		local descLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 20, CCSize(attributeTvSize.width - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		        		height = height + descLb:getContentSize().height + 10
		        	end
	        	end
			else
				if refitTypeIndex then
		    		local skillSize = SizeOfTable(refitTypeData.skill2)
		    		for k, skillId in pairs(refitTypeData.skill2) do
		    			local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
		    			if skillCfg then
		    				local skillLv = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex, k, true)
		    				local skillNameLb = GetTTFLabel(getlocal(skillCfg.skillName) .. " " .. getlocal("fightLevel", {skillLv}), 20)
		    				local skillAttrValue = planeRefitVoApi:getSkillAttributeValue(skillId, skillLv, refitExp)
		    				if skillCfg.percent == 1 then
				    			skillAttrValue = skillAttrValue * 100
				    		end
		    				local skillDescLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 18, CCSize(attributeTvSize.width - 10 - skillIconSize - 10 - 5, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		    				local lbTotalHeight = skillNameLb:getContentSize().height + 10 + skillDescLb:getContentSize().height
		    				if refitExp < refitTypeData.powerNeed[k] then
		    					local unlockTipsLb = GetTTFLabelWrap(getlocal("planeRefit_skillActiveTips", {refitTypeData.powerNeed[k]}), 18, CCSize(attributeTvSize.width - 10 - skillIconSize - 10 - 5, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		    					lbTotalHeight = lbTotalHeight + 10 + unlockTipsLb:getContentSize().height
		    				end
		    				if lbTotalHeight > skillIconSize then
		    					height = height + lbTotalHeight
		    				else
		    					height = height + skillIconSize
		    				end
		    				height = height + 10
		    			end
		    		end
				else
					local nullTipsStr = getlocal("planeRefit_notActiveSkillTips")
					for refitTypeIndex_a, refitTypeData_a in pairs(refitTypeData) do
		    			local refitExp_a = planeRefitVoApi:getRefitExp(placeId, planeId, refitTypeIndex_a)
		    			for skillIndex, skillId in pairs(refitTypeData_a.skill2) do
			    			local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
			    			if skillCfg and refitExp_a >= refitTypeData_a.powerNeed[skillIndex] then
			    				nullTipsStr = nil
			    				local skillLv = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex_a, skillIndex, true)
			    				local skillNameLb = GetTTFLabel(getlocal(skillCfg.skillName) .. " " .. getlocal("fightLevel", {skillLv}), 20)
			    				local skillAttrValue = planeRefitVoApi:getSkillAttributeValue(skillId, skillLv, refitExp_a)
			    				if skillCfg.percent == 1 then
					    			skillAttrValue = skillAttrValue * 100
					    		end
			    				local skillDescLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 18, CCSize(attributeTvSize.width - 10 - skillIconSize - 10 - 5, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
			    				local lbTotalHeight = skillNameLb:getContentSize().height + 10 + skillDescLb:getContentSize().height
			    				if lbTotalHeight > skillIconSize then
			    					height = height + lbTotalHeight
			    				else
			    					height = height + skillIconSize
			    				end
			    				height = height + 10
			    			end
			    		end
		    		end
		    		if nullTipsStr then
		    			local tipsLb = GetTTFLabelWrap(nullTipsStr, 20, CCSizeMake(attributeTvSize.width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		    			height = height + tipsLb:getContentSize().height + 50
		    		end
				end
			end
			cellHeightTb[focusIndex][idx + 1] = height + 10
		end
		return CCSizeMake(attributeTvSize.width, cellHeightTb[focusIndex][idx + 1])
	end, function(cell, cellSize, idx, cellNum)
		local headlineStr
		local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
		cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 5))
		if idx == 0 then
			headlineStr = getlocal("planeRefit_refitAttributeText")
			cellBg:setAnchorPoint(ccp(0.5, 1))
			cellBg:setPosition(cellSize.width / 2, cellSize.height)
		else
			headlineStr = getlocal("planeRefit_refitSkillText")
			cellBg:setAnchorPoint(ccp(0.5, 0))
			cellBg:setPosition(cellSize.width / 2, 0)
		end
		cell:addChild(cellBg)
		local tempHeadlineLb = GetTTFLabel(headlineStr, 22, true)
		local headlineBg, headlineLb, headlineLbHeight = G_createNewTitle({headlineStr, 22, G_ColorWhite}, CCSizeMake(tempHeadlineLb:getContentSize().width + 150, 0), nil, true, "Helvetica-bold")
        headlineBg:setAnchorPoint(ccp(0.5, 0))
        headlineBg:setPosition(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - headlineLbHeight - 10)
        cellBg:addChild(headlineBg)

        local headlineBottomPosY = cellBg:getContentSize().height - 40
        if idx == 0 then
        	local refitTypeData_a = refitTypeIndex and {refitTypeData} or refitTypeData
        	for k, v in pairs(refitTypeData_a) do
        		local skillId = v.skill1
	        	local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
	        	if skillCfg then
	        		local refitExp_a = refitTypeIndex and refitExp or planeRefitVoApi:getRefitExp(placeId, planeId, k)
	        		local skillAttrValue = planeRefitVoApi:getSkillAttributeValue(skillId, 0, refitExp_a)
	        		if skillCfg.percent == 1 then
		    			skillAttrValue = skillAttrValue * 100
		    		end
	        		local descLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 20, CCSize(cellBg:getContentSize().width - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	        		descLb:setAnchorPoint(ccp(0.5, 1))
	        		descLb:setPosition(cellBg:getContentSize().width / 2, headlineBottomPosY - 5)
	        		cellBg:addChild(descLb)
	        		headlineBottomPosY = descLb:getPositionY() - descLb:getContentSize().height - 5
	        	end
        	end
	    else
	    	if refitTypeIndex then
	    		local skillSize = SizeOfTable(refitTypeData.skill2)
	    		for k, skillId in pairs(refitTypeData.skill2) do
	    			local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
	    			if skillCfg then
	    				local skillLv = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex, k, true)
	    				local skillNameLb = GetTTFLabel(getlocal(skillCfg.skillName) .. " " .. getlocal("fightLevel", {skillLv}), 20)
	    				local skillAttrValue = planeRefitVoApi:getSkillAttributeValue(skillId, skillLv, refitExp)
	    				if skillCfg.percent == 1 then
			    			skillAttrValue = skillAttrValue * 100
			    		end
	    				local skillDescLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 18, CCSize(cellBg:getContentSize().width - 10 - skillIconSize - 10 - 5, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	    				local lbTotalHeight = skillNameLb:getContentSize().height + 10 + skillDescLb:getContentSize().height
	    				local skillIcon, unlockTipsLb
	    				if refitExp >= refitTypeData.powerNeed[k] then
	    					skillIcon = CCSprite:createWithSpriteFrameName(skillCfg.icon)
	    				else
	    					skillIcon = GraySprite:createWithSpriteFrameName(skillCfg.icon)
	    					unlockTipsLb = GetTTFLabelWrap(getlocal("planeRefit_skillActiveTips", {refitTypeData.powerNeed[k]}), 18, CCSize(cellBg:getContentSize().width - 10 - skillIconSize - 10 - 5, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	    					lbTotalHeight = lbTotalHeight + 10 + unlockTipsLb:getContentSize().height
	    				end
	    				local rowHeight
	    				if lbTotalHeight > skillIconSize then
	    					rowHeight = lbTotalHeight + 10
	    				else
	    					rowHeight = skillIconSize + 10
	    				end
	    				skillIcon:setScale(skillIconSize / skillIcon:getContentSize().height)
	    				skillIcon:setAnchorPoint(ccp(0, 0.5))
	    				skillIcon:setPosition(10, headlineBottomPosY - rowHeight / 2)
	    				cellBg:addChild(skillIcon)
	    				skillNameLb:setAnchorPoint(ccp(0, 1))
	    				skillNameLb:setPosition(skillIcon:getPositionX() + skillIconSize + 10, headlineBottomPosY - (rowHeight - lbTotalHeight) / 2)
	    				skillNameLb:setColor(G_ColorYellowPro)
	    				cellBg:addChild(skillNameLb)
	    				skillDescLb:setAnchorPoint(ccp(0, 1))
	    				skillDescLb:setPosition(skillNameLb:getPositionX(), skillNameLb:getPositionY() - skillNameLb:getContentSize().height - 10)
	    				cellBg:addChild(skillDescLb)
	    				if unlockTipsLb then
	    					unlockTipsLb:setAnchorPoint(ccp(0, 1))
	    					unlockTipsLb:setPosition(skillDescLb:getPositionX(), skillDescLb:getPositionY() - skillDescLb:getContentSize().height - 10)
		    				unlockTipsLb:setColor(G_ColorRed)
		    				cellBg:addChild(unlockTipsLb)
	    				end
	    				headlineBottomPosY = headlineBottomPosY - rowHeight
	    				if k < skillSize then
	    					local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
				            lineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width - 20, lineSp:getContentSize().height))
				            lineSp:setPosition(cellBg:getContentSize().width / 2, headlineBottomPosY)
				            lineSp:setRotation(180)
				            cellBg:addChild(lineSp)
	    				end
	    			end
	    		end
	    	else
	    		local nullTipsStr = getlocal("planeRefit_notActiveSkillTips")
	    		local lastLineSp
	    		for refitTypeIndex_a, refitTypeData_a in pairs(refitTypeData) do
	    			local refitExp_a = planeRefitVoApi:getRefitExp(placeId, planeId, refitTypeIndex_a)
	    			for skillIndex, skillId in pairs(refitTypeData_a.skill2) do
		    			local skillCfg = planeRefitVoApi:getSkillCfg(skillId)
		    			if skillCfg and refitExp_a >= refitTypeData_a.powerNeed[skillIndex] then
		    				nullTipsStr = nil
		    				local skillIcon = CCSprite:createWithSpriteFrameName(skillCfg.icon)
		    				local skillLv = planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex_a, skillIndex, true)
		    				local skillNameLb = GetTTFLabel(getlocal(skillCfg.skillName) .. " " .. getlocal("fightLevel", {skillLv}), 20)
		    				local skillAttrValue = planeRefitVoApi:getSkillAttributeValue(skillId, skillLv, refitExp_a)
		    				if skillCfg.percent == 1 then
				    			skillAttrValue = skillAttrValue * 100
				    		end
		    				local skillDescLb = GetTTFLabelWrap(getlocal(skillCfg.skillDes, {skillAttrValue}), 18, CCSize(cellBg:getContentSize().width - 10 - skillIconSize - 10 - 5, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		    				local lbTotalHeight = skillNameLb:getContentSize().height + 10 + skillDescLb:getContentSize().height
		    				local rowHeight
		    				if lbTotalHeight > skillIconSize then
		    					rowHeight = lbTotalHeight + 10
		    				else
		    					rowHeight = skillIconSize + 10
		    				end
		    				skillIcon:setScale(skillIconSize / skillIcon:getContentSize().height)
		    				skillIcon:setAnchorPoint(ccp(0, 0.5))
		    				skillIcon:setPosition(10, headlineBottomPosY - rowHeight / 2)
		    				cellBg:addChild(skillIcon)
		    				skillNameLb:setAnchorPoint(ccp(0, 1))
		    				skillNameLb:setPosition(skillIcon:getPositionX() + skillIconSize + 10, headlineBottomPosY - (rowHeight - lbTotalHeight) / 2)
		    				skillNameLb:setColor(G_ColorYellowPro)
		    				cellBg:addChild(skillNameLb)
		    				skillDescLb:setAnchorPoint(ccp(0, 1))
		    				skillDescLb:setPosition(skillNameLb:getPositionX(), skillNameLb:getPositionY() - skillNameLb:getContentSize().height - 10)
		    				cellBg:addChild(skillDescLb)
		    				headlineBottomPosY = headlineBottomPosY - rowHeight
		    				local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
				            lineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width - 20, lineSp:getContentSize().height))
				            lineSp:setPosition(cellBg:getContentSize().width / 2, headlineBottomPosY)
				            lineSp:setRotation(180)
				            cellBg:addChild(lineSp)
				            lastLineSp = lineSp
		    			end
		    		end
	    		end
	    		if lastLineSp then
	    			lastLineSp:removeAllChildrenWithCleanup(true)
	    			lastLineSp = nil
	    		end
	    		if nullTipsStr then
	    			local tipsLb = GetTTFLabelWrap(nullTipsStr, 20, CCSizeMake(cellBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	    			tipsLb:setPosition(cellBg:getContentSize().width / 2, headlineBottomPosY - 25 - tipsLb:getContentSize().height / 2)
	    			tipsLb:setColor(G_ColorGray)
	    			cellBg:addChild(tipsLb)
	    		end
	    	end
	    end
	end)
	attributeTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	attributeTv:setPosition(15, 25)
	self.bgLayer:addChild(attributeTv)
end

function planeRefitSmallDialog:dispose()
	self = nil
end