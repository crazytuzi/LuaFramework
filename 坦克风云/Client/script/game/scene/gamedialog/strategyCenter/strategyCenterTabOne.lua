strategyCenterTabOne = {}

function strategyCenterTabOne:create(parent, topPosY)
	self.layerNum = parent.layerNum
	self.topPosY = topPosY
	G_addResource8888(function()
		spriteController:addPlist("public/squaredImgs.plist")
		spriteController:addTexture("public/squaredImgs.png")
		spriteController:addPlist("public/acyswj_images2.plist")
		spriteController:addTexture("public/acyswj_images2.png")
		spriteController:addPlist("public/youhuaUI3.plist")
		spriteController:addTexture("public/youhuaUI3.png")
	end)
	spriteController:addPlist("public/yellowFlicker.plist")
	self.bgLayer = CCLayer:create()
	self:initUI()
	return self.bgLayer
end

function strategyCenterTabOne:initUI()
	local function onLoadWebImage(fn, webImage)
        if self and self.bgLayer and tolua.cast(self.bgLayer, "CCLayer") then
            webImage:setAnchorPoint(ccp(0.5, 1))
            webImage:setPosition(G_VisibleSizeWidth / 2, self.topPosY)
            self.bgLayer:addChild(webImage)
        end
    end
    G_addResource8888(function() LuaCCWebImage:createWithURL(G_downloadUrl("function/strategyCenter_bg1.jpg"), onLoadWebImage) end)

    local spaceLine = LuaCCScale9Sprite:createWithSpriteFrameName("sci_spaceLine1.png", CCRect(0, 2, 640, 4), function()end)
    spaceLine:setContentSize(CCSizeMake(spaceLine:getContentSize().width, 355))
    spaceLine:setAnchorPoint(ccp(0.5, 1))
    spaceLine:setPosition(ccp(G_VisibleSizeWidth / 2, self.topPosY))
    self.bgLayer:addChild(spaceLine, 1)
    local spaceBg = CCNode:create()--CCLayerColor(ccc4(0, 0, 0, 255))
    spaceBg:setContentSize(CCSizeMake(spaceLine:getContentSize().width, spaceLine:getContentSize().height - 18))
    spaceBg:setAnchorPoint(ccp(0, 0))
    spaceBg:setPosition(ccp(0, 16))
    spaceLine:addChild(spaceBg)

	local topLevelBg = CCSprite:createWithSpriteFrameName("sci_levelBg1.png")
	topLevelBg:setAnchorPoint(ccp(0.5, 1))
	topLevelBg:setPosition(ccp(spaceBg:getContentSize().width / 2, spaceBg:getContentSize().height - 3))
	spaceBg:addChild(topLevelBg)
	self.scMaxLevel = strategyCenterVoApi:getMaxLevel(1)
	local scLevel = strategyCenterVoApi:getLevel(1)
	local levelLb = GetTTFLabel(getlocal("fightLevel", {scLevel}), 24, true)
	levelLb:setAnchorPoint(ccp(0.5, 1))
	levelLb:setPosition(ccp(topLevelBg:getContentSize().width / 2, topLevelBg:getContentSize().height - 8))
	topLevelBg:addChild(levelLb)

	local function playUpgradeEffect(callback)
		local firstFrameSp = CCSprite:createWithSpriteFrameName("sce_upgradeEffect_b_1.png")
	    G_setBlendFunc(firstFrameSp, GL_ONE, GL_ONE)
	    local frameArray = CCArray:create()
	    for i = 1, 10 do
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("sce_upgradeEffect_b_" .. i .. ".png")
	        frameArray:addObject(frame)
	    end
	    local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.07)
	    local animate = CCAnimate:create(animation)
	    firstFrameSp:runAction(CCSequence:createWithTwoActions(animate, CCCallFunc:create(function()
	    	firstFrameSp:removeFromParentAndCleanup(true)
	    	firstFrameSp = nil
	    	if type(callback) == "function" then
	    		callback()
	    	end
	    end)))
	    firstFrameSp:setPosition(ccp(topLevelBg:getPositionX(), topLevelBg:getPositionY() - topLevelBg:getContentSize().height / 2 + 10))
	    spaceBg:addChild(firstFrameSp, 3)
	end

	local function onClickInfoBtn(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = { getlocal("strategyCenter_basicsDesc1"), getlocal("strategyCenter_basicsDesc2"), getlocal("strategyCenter_basicsDesc3") }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickInfoBtn)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    infoMenu:setPosition(ccp(0, 0))
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.8)
    infoBtn:setPosition(ccp(spaceBg:getContentSize().width - 20, spaceBg:getContentSize().height - 20))
    spaceBg:addChild(infoMenu)

	local skillPointBg = CCSprite:createWithSpriteFrameName("sci_skillPointBg1.png")
	skillPointBg:setAnchorPoint(ccp(0, 1))
	skillPointBg:setPosition(15, topLevelBg:getPositionY() - topLevelBg:getContentSize().height)
	spaceBg:addChild(skillPointBg)

	local progressBarSp = CCSprite:createWithSpriteFrameName("sci_progressBar.png")
	local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("sci_progressBarBg.png", CCRect(10, 10, 2, 2), function()end)
	progressBarBg:setContentSize(CCSizeMake(spaceBg:getContentSize().width - 30, progressBarSp:getContentSize().height + 2))
	progressBarBg:setAnchorPoint(ccp(0.5, 1))
	progressBarBg:setPosition(ccp(spaceBg:getContentSize().width / 2, skillPointBg:getPositionY() - skillPointBg:getContentSize().height - 5))
	spaceBg:addChild(progressBarBg)
	local progressBar = CCProgressTimer:create(progressBarSp)
	progressBar:setType(kCCProgressTimerTypeBar)
	progressBar:setBarChangeRate(ccp(1, 0))
	progressBar:setMidpoint(ccp(0, 1))
	progressBar:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
	progressBar:setScaleX(progressBarBg:getContentSize().width / progressBar:getContentSize().width)
	progressBarBg:addChild(progressBar)
	local curExp, maxExp = strategyCenterVoApi:getExp(1), strategyCenterVoApi:getExpMax(scLevel, 1)
	progressBar:setPercentage(curExp / maxExp * 100)
	local expLabel = GetTTFLabel(curExp .. "/" .. maxExp, 18, true)
	expLabel:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
	progressBarBg:addChild(expLabel)

	local skillPointLb = GetTTFLabel(getlocal("strategyCenter_skillPoint"), 20, true)
	skillPointLb:setAnchorPoint(ccp(0, 0.5))
	skillPointLb:setPosition(ccp(20, skillPointBg:getContentSize().height / 2))
	skillPointBg:addChild(skillPointLb)
	local skillPoint = strategyCenterVoApi:getSkillPoint(1)
	local skillPointNumLb = GetTTFLabel(tostring(skillPoint), 26, true)
	skillPointNumLb:setAnchorPoint(ccp(0, 0.5))
	skillPointNumLb:setPosition(ccp(skillPointLb:getPositionX() + skillPointLb:getContentSize().width + 15, skillPointBg:getContentSize().height / 2))
	skillPointNumLb:setColor(G_ColorYellowPro)
	skillPointBg:addChild(skillPointNumLb, 1)
	local function playSkillPointEffect(newSkillPoint)
		local seqArr = CCArray:create()
		seqArr:addObject(CCScaleTo:create(0.2, 3.0))
		seqArr:addObject(CCScaleTo:create(0.2, 1.0))
		seqArr:addObject(CCCallFunc:create(function()
			skillPointNumLb:setString(tostring(newSkillPoint))
			self.resetPointBtn:setPositionX(skillPointNumLb:getPositionX() + skillPointNumLb:getContentSize().width + 10)
		end))
		skillPointNumLb:runAction(CCSequence:create(seqArr))
	end
	local function onClickResetPoint(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local costNum = strategyCenterVoApi:getResetPointCost(1)
        G_showSureAndCancle(getlocal("strategyCenter_resetPointTips", {costNum}), function()
        	local gems = playerVoApi:getGems()
	        if gems < costNum then
	            GemsNotEnoughDialog(nil, nil, costNum - gems, self.layerNum + 1, costNum)
	            do return end
	        end
        	strategyCenterVoApi:requestResetPoint(function()
        		playerVoApi:setGems(playerVoApi:getGems() - costNum)
        		skillPoint = strategyCenterVoApi:getSkillPoint(1)
        		playSkillPointEffect(skillPoint)
        		-- skillPointNumLb:setString(tostring(skillPoint))
        		self.resetPointBtn:setEnabled(strategyCenterVoApi:getCostSkillPoint(1) > 0)
        		if self.skillTv then
        			self.skillTv:reloadData()
        		end
        	end, 1)
        end)
	end
	local resetPointBtnScale = 0.6
	local resetPointBtn = GetButtonItem("yh_hero_switch1.png", "yh_hero_switch2.png", "yh_hero_switch1.png", onClickResetPoint)
	resetPointBtn:setScale(resetPointBtnScale)
	resetPointBtn:setAnchorPoint(ccp(0, 0.5))
	resetPointBtn:setPosition(ccp(skillPointNumLb:getPositionX() + skillPointNumLb:getContentSize().width + 10, skillPointBg:getContentSize().height / 2))
	local resetPointMenu = CCMenu:createWithItem(resetPointBtn)
	resetPointMenu:setPosition(ccp(0, 0))
	resetPointMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	skillPointBg:addChild(resetPointMenu)
	self.resetPointBtn = resetPointBtn
	self.resetPointBtn:setEnabled(strategyCenterVoApi:getCostSkillPoint(1) > 0)

	local contentLeftBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
	contentLeftBg:setContentSize(CCSizeMake(spaceBg:getContentSize().width / 2 - 12, progressBarBg:getPositionY() - progressBarBg:getContentSize().height - 5))
	contentLeftBg:setAnchorPoint(ccp(0, 1))
	contentLeftBg:setPosition(ccp(15, progressBarBg:getPositionY() - progressBarBg:getContentSize().height - 5))
	contentLeftBg:setOpacity(255 * 0.6)
	spaceBg:addChild(contentLeftBg)
	local contentRightBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
	contentRightBg:setContentSize(CCSizeMake(spaceBg:getContentSize().width / 2 - 12, progressBarBg:getPositionY() - progressBarBg:getContentSize().height - 5))
	contentRightBg:setAnchorPoint(ccp(1, 1))
	contentRightBg:setPosition(ccp(spaceBg:getContentSize().width - 15, progressBarBg:getPositionY() - progressBarBg:getContentSize().height - 5))
	contentRightBg:setOpacity(255 * 0.6)
	spaceBg:addChild(contentRightBg)

	local titleLb1 = GetTTFLabel(getlocal("strategyCenter_expTransform"), 20, true)
	local titleLine1Left = CCSprite:createWithSpriteFrameName("sci_titleLine1.png")
	local titleLine1Right = CCSprite:createWithSpriteFrameName("sci_titleLine1.png")
	titleLine1Left:setAnchorPoint(ccp(0, 0.5))
	titleLine1Left:setPosition(5, contentLeftBg:getContentSize().height - 5 - titleLb1:getContentSize().height / 2)
	titleLine1Right:setFlipX(true)
	titleLine1Right:setAnchorPoint(ccp(1, 0.5))
	titleLine1Right:setPosition(contentLeftBg:getContentSize().width - 5, contentLeftBg:getContentSize().height - 5 - titleLb1:getContentSize().height / 2)
	contentLeftBg:addChild(titleLine1Left)
	contentLeftBg:addChild(titleLine1Right)
	titleLb1 = nil
	local titleLb1Width = contentLeftBg:getContentSize().width - 10 - titleLine1Left:getContentSize().width - titleLine1Right:getContentSize().width
	titleLb1 = GetTTFLabel(getlocal("strategyCenter_expTransform"), 20, CCSizeMake(titleLb1Width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
	titleLb1:setPosition(contentLeftBg:getContentSize().width / 2, contentLeftBg:getContentSize().height - 5 - titleLb1:getContentSize().height / 2)
	titleLb1:setColor(G_ColorYellowPro)
	contentLeftBg:addChild(titleLb1)

	self.ownResLbTb, self.costResLbTb = {}, {}
	local resPosY = titleLb1:getPositionY() - titleLb1:getContentSize().height / 2 - 10
	local costResTb, costResNum = strategyCenterVoApi:getBasicsCostRes(scLevel)
	for k, resKey in ipairs(costResTb) do
		local resIcon = CCSprite:createWithSpriteFrameName(G_getResourceIcon(resKey))
		resIcon:setAnchorPoint(ccp(0, 0.5))
		if k % 2 == 0 then
			resIcon:setPositionX(contentLeftBg:getContentSize().width / 2)
		else
			resIcon:setPositionX(3)
		end
		resIcon:setPositionY(resPosY - resIcon:getContentSize().height / 2)
		if k > 1 and k % 2 == 0 then
			resPosY = resPosY - resIcon:getContentSize().height - 3
		end
		contentLeftBg:addChild(resIcon)
		local ownResNum = playerVoApi:getResNum(resKey)
		local ownResLb = GetTTFLabel(FormatNumber(ownResNum), 18)
		local costResLb = GetTTFLabel("/" .. FormatNumber(costResNum), 18)
		if ownResNum < costResNum then
			ownResLb:setColor(G_ColorRed)
		end
		ownResLb:setAnchorPoint(ccp(0, 0.5))
		ownResLb:setPosition(ccp(resIcon:getPositionX() + resIcon:getContentSize().width, resIcon:getPositionY()))
		contentLeftBg:addChild(ownResLb)
		costResLb:setAnchorPoint(ccp(0, 0.5))
		costResLb:setPosition(ccp(ownResLb:getPositionX() + ownResLb:getContentSize().width, resIcon:getPositionY()))
		contentLeftBg:addChild(costResLb)
		self.ownResLbTb[k] = ownResLb
		self.costResLbTb[k] = costResLb
	end
	local curTransformCount = strategyCenterVoApi:getExpTransformCount()
	local maxTransformCount = strategyCenterVoApi:getExpTransformMaxCount()
	local function onClickTransform(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        for k, resKey in ipairs(costResTb) do
			local ownResNum = playerVoApi:getResNum(resKey)
			if ownResNum < costResNum then
				G_showTipsDialog(getlocal("resourcelimit"))
				do return end
			end
		end
        strategyCenterVoApi:requestExpTransform(function()
        	for k, resKey in ipairs(costResTb) do
        		playerVoApi:useResNum(resKey, costResNum)
        	end
        	G_showTipsDialog(getlocal("strategyCenter_basicsDonateTips", {strategyCenterVoApi:getTransformExp()}))
			curTransformCount = strategyCenterVoApi:getExpTransformCount()
			if curTransformCount >= maxTransformCount then
				self.transformBtn:setEnabled(false)
				self.transformCountLb:setString(getlocal("strategyCenter_notCountTips"))
			else
				self.transformCountLb:setString(getlocal("exchangeNum", {curTransformCount, maxTransformCount}))
			end
			local oldSCLevel = scLevel
			scLevel = strategyCenterVoApi:getLevel(1)
			costResTb, costResNum = strategyCenterVoApi:getBasicsCostRes(scLevel)
			for k, resKey in ipairs(costResTb) do
				local ownResNum = playerVoApi:getResNum(resKey)
				local ownResLb = tolua.cast(self.ownResLbTb[k], "CCLabelTTF")
				local costResLb = tolua.cast(self.costResLbTb[k], "CCLabelTTF")
				if ownResNum < costResNum then
					ownResLb:setColor(G_ColorRed)
				end
				ownResLb:setString(FormatNumber(ownResNum))
				costResLb:setString("/" .. FormatNumber(costResNum))
				costResLb:setPositionX(ownResLb:getPositionX() + ownResLb:getContentSize().width)
			end
			curExp, maxExp = strategyCenterVoApi:getExp(1), strategyCenterVoApi:getExpMax(scLevel, 1)
			progressBar:setPercentage(curExp / maxExp * 100)
			expLabel:setString(curExp .. "/" .. maxExp)
			if scLevel > oldSCLevel then
				if scLevel == self.scMaxLevel then
					self.transformBtn:setEnabled(false)
				end
				playUpgradeEffect(function() levelLb:setString(getlocal("fightLevel", {scLevel})) end)
				skillPoint = strategyCenterVoApi:getSkillPoint(1)
				playSkillPointEffect(skillPoint)
	        	-- skillPointNumLb:setString(tostring(skillPoint))
	        	if self.skillTv then
	    			self.skillTv:reloadData()
	    		end
			end
        end)
	end
	local transformBtnScale = 0.5
	local transformBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickTransform, 11, getlocal("activity_recycling_tip3"), (G_isAsia() and 22 or 20) / transformBtnScale)
	transformBtn:setScale(transformBtnScale)
	transformBtn:setAnchorPoint(ccp(0.5, 0))
	transformBtn:setPosition(contentLeftBg:getContentSize().width / 2, 5)
	local transformMenu = CCMenu:createWithItem(transformBtn)
	transformMenu:setPosition(ccp(0, 0))
	transformMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	contentLeftBg:addChild(transformMenu)
	local transformCountLbStr = getlocal("exchangeNum", {curTransformCount, maxTransformCount})
	if curTransformCount >= maxTransformCount then
		transformBtn:setEnabled(false)
		transformCountLbStr = getlocal("strategyCenter_notCountTips")
	end
	local transformCountLb = GetTTFLabelWrap(transformCountLbStr, 20, CCSizeMake(contentLeftBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
	transformCountLb:setAnchorPoint(ccp(0.5, 0))
	transformCountLb:setPosition(ccp(transformBtn:getPositionX(), transformBtn:getPositionY() + transformBtn:getContentSize().height * transformBtnScale))
	contentLeftBg:addChild(transformCountLb)
	self.transformBtn = transformBtn
	self.transformCountLb = transformCountLb
	if scLevel == self.scMaxLevel then
		self.transformBtn:setEnabled(false)
	end

	local titleLb2 = GetTTFLabel(getlocal("strategyCenter_heroDispatch"), G_isAsia() and 20 or 18, true)
	local titleLine2Left = CCSprite:createWithSpriteFrameName("sci_titleLine1.png")
	local titleLine2Right = CCSprite:createWithSpriteFrameName("sci_titleLine1.png")
	titleLine2Left:setAnchorPoint(ccp(0, 0.5))
	titleLine2Left:setPosition(5, contentRightBg:getContentSize().height - 5 - titleLb2:getContentSize().height / 2)
	titleLine2Right:setFlipX(true)
	titleLine2Right:setAnchorPoint(ccp(1, 0.5))
	titleLine2Right:setPosition(contentRightBg:getContentSize().width - 5, contentRightBg:getContentSize().height - 5 - titleLb2:getContentSize().height / 2)
	contentRightBg:addChild(titleLine2Left)
	contentRightBg:addChild(titleLine2Right)
	titleLb2 = nil
	local titleLb2Width = contentRightBg:getContentSize().width - 10 - titleLine2Left:getContentSize().width - titleLine2Right:getContentSize().width
	titleLb2 = GetTTFLabelWrap(getlocal("strategyCenter_heroDispatch"), G_isAsia() and 20 or 18, CCSizeMake(titleLb2Width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
	titleLb2:setPosition(contentRightBg:getContentSize().width / 2, contentRightBg:getContentSize().height - 5 - titleLb2:getContentSize().height / 2)
	titleLb2:setColor(G_ColorYellowPro)
	contentRightBg:addChild(titleLb2)

	local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("icon_bg_gray.png", CCRect(34, 34, 1, 1), function()
		local dispatchState = strategyCenterVoApi:getHeroDispatchState()
		if dispatchState == 0 then
			strategyCenterVoApi:showHeroDispatchSmallDialog(self.layerNum + 1, function()
				self:refreshHeroDispatch()
			end)
		elseif dispatchState == 1 then --正在派遣中
			G_showTipsDialog(getlocal("strategyCenter_dispatchingTips"))
		elseif dispatchState == 2 then --领取派遣奖励
			local rewardTb = strategyCenterVoApi:getHeroDispatchReward()
			strategyCenterVoApi:requestRewardDispatch(function()
				G_showTipsDialog(getlocal("receivereward_received_success"))
				for k, v in pairs(rewardTb) do
					if v.key and v.id then
						G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
					end
				end
				G_showRewardTip(rewardTb)
				self:refreshHeroDispatch()
				local oldSCLevel = scLevel
				scLevel = strategyCenterVoApi:getLevel(1)
	        	curExp, maxExp = strategyCenterVoApi:getExp(1), strategyCenterVoApi:getExpMax(scLevel, 1)
				progressBar:setPercentage(curExp / maxExp * 100)
				expLabel:setString(curExp .. "/" .. maxExp)
				if scLevel > oldSCLevel then
					playUpgradeEffect(function() levelLb:setString(getlocal("fightLevel", {scLevel})) end)
					skillPoint = strategyCenterVoApi:getSkillPoint(1)
					playSkillPointEffect(skillPoint)
	        		-- skillPointNumLb:setString(tostring(skillPoint))
	        		costResTb, costResNum = strategyCenterVoApi:getBasicsCostRes(scLevel)
					for k, resKey in ipairs(costResTb) do
						local ownResNum = playerVoApi:getResNum(resKey)
						local ownResLb = tolua.cast(self.ownResLbTb[k], "CCLabelTTF")
						local costResLb = tolua.cast(self.costResLbTb[k], "CCLabelTTF")
						if ownResNum < costResNum then
							ownResLb:setColor(G_ColorRed)
						end
						ownResLb:setString(FormatNumber(ownResNum))
						costResLb:setString("/" .. FormatNumber(costResNum))
						costResLb:setPositionX(ownResLb:getPositionX() + ownResLb:getContentSize().width)
					end
					if self.skillTv then
	        			self.skillTv:reloadData()
	        		end
	        	end
			end)
		elseif dispatchState == 3 then
			G_showTipsDialog(getlocal("strategyCenter_dispatchCompleteTips"))
		end
	end)
	iconBg:setContentSize(CCSizeMake(90, 90))
	iconBg:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	iconBg:setPosition(ccp(contentRightBg:getContentSize().width / 2, contentRightBg:getContentSize().height / 2))
	contentRightBg:addChild(iconBg)
	local addSp = CCSprite:createWithSpriteFrameName("believerAddBtn.png")
	addSp:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
	iconBg:addChild(addSp)
	local heroTipsLb = GetTTFLabelWrap(getlocal("strategyCenter_clickDispatch"), G_isAsia() and 22 or 20, CCSizeMake(contentRightBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
	heroTipsLb:setAnchorPoint(ccp(0.5, 0))
	heroTipsLb:setPosition(ccp(contentRightBg:getContentSize().width / 2, 5))
	contentRightBg:addChild(heroTipsLb)
	self.iconBg = iconBg
	self.heroTipsLb = heroTipsLb
	self:refreshHeroDispatch()

	local skillList = strategyCenterVoApi:getSkillList(1)
	local skillTvSize = CCSizeMake(G_VisibleSizeWidth, spaceLine:getPositionY() - spaceLine:getContentSize().height - 20)
	local skillTv = G_createTableView(skillTvSize, SizeOfTable(skillList), CCSizeMake(skillTvSize.width, 170), function(cell, cellSize, idx, cellNum)
		local cellBg = CCSprite:createWithSpriteFrameName("sci_skillListBg.png")
		cellBg:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
		cell:addChild(cellBg)
		local cellTitleLineSpL = CCSprite:createWithSpriteFrameName("sci_titleLine2.png")
		local cellTitleLineSpR = CCSprite:createWithSpriteFrameName("sci_titleLine2.png")
		cellTitleLineSpL:setAnchorPoint(ccp(1, 0.5))
		cellTitleLineSpL:setPosition(ccp(cellBg:getContentSize().width / 2 - 20, cellBg:getContentSize().height - 15))
		cellBg:addChild(cellTitleLineSpL)
		cellTitleLineSpR:setFlipX(true)
		cellTitleLineSpR:setAnchorPoint(ccp(0, 0.5))
		cellTitleLineSpR:setPosition(ccp(cellBg:getContentSize().width / 2 + 20, cellBg:getContentSize().height - 15))
		cellBg:addChild(cellTitleLineSpR)
		local cellTitleLb = GetTTFLabel(idx + 1, 22, true)
		cellTitleLb:setPosition(ccp(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - 15))
		cellBg:addChild(cellTitleLb)
		for k, skillId in pairs(skillList[idx + 1]) do
			local skillCfgData = strategyCenterVoApi:getSkillCfgData(skillId)
			if skillCfgData then
				local skillIcon = LuaCCSprite:createWithSpriteFrameName(skillCfgData.icon, function()
					strategyCenterVoApi:showSkillDetailsSmallDialog(self.layerNum + 1, skillId, function()
						skillPoint = strategyCenterVoApi:getSkillPoint(1)
						playSkillPointEffect(skillPoint)
        				-- skillPointNumLb:setString(tostring(skillPoint))
        				self.resetPointBtn:setEnabled(strategyCenterVoApi:getCostSkillPoint(1) > 0)
        				if self.skillTv then
		        			self.skillTv:reloadData()
		        		end
					end)
				end)
				skillIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
				skillIcon:setScale(90 / skillIcon:getContentSize().width)
				skillIcon:setAnchorPoint(ccp(0.5, 1))
				if k == 1 then
					skillIcon:setPositionX(cellBg:getContentSize().width / 2 - skillIcon:getContentSize().width * skillIcon:getScale() - 100)
				elseif k == 2 then
					skillIcon:setPositionX(cellBg:getContentSize().width / 2)
				elseif k == 3 then
					skillIcon:setPositionX(cellBg:getContentSize().width / 2 + skillIcon:getContentSize().width * skillIcon:getScale() + 100)
				end
				skillIcon:setPositionY(cellBg:getContentSize().height - 30)
				cellBg:addChild(skillIcon)
				local skillLevel = strategyCenterVoApi:getSkillLevel(skillId)
				local skillLevelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png", CCRect(4, 4, 1, 1), function()end)
				skillLevelBg:setContentSize(CCSizeMake(skillIcon:getContentSize().width - 6, 22))
				skillLevelBg:setAnchorPoint(ccp(0.5, 0))
				skillLevelBg:setPosition(ccp(skillIcon:getContentSize().width / 2, 3))
				skillLevelBg:setOpacity(255 * 0.55)
				skillIcon:addChild(skillLevelBg, 1)
				local skillLevelLb = GetTTFLabel(getlocal("fightLevel", {skillLevel}), 18)
				skillLevelLb:setPosition(ccp(skillLevelBg:getContentSize().width / 2, skillLevelBg:getContentSize().height / 2))
				skillLevelBg:addChild(skillLevelLb)
				if skillLevel <= 0 then
					skillLevelLb:setString(getlocal("ineffectiveStr"))
					local skillIconGray = GraySprite:createWithSpriteFrameName(skillCfgData.icon)
					skillIconGray:setPosition(ccp(skillIcon:getContentSize().width / 2, skillIcon:getContentSize().height / 2))
					skillIcon:addChild(skillIconGray)
				end
				local skillNameLb = GetTTFLabel(getlocal(skillCfgData.skillName), 20)
				skillNameLb:setAnchorPoint(ccp(0.5, 1))
				skillNameLb:setPosition(ccp(skillIcon:getPositionX(), skillIcon:getPositionY() - skillIcon:getContentSize().height * skillIcon:getScale()))
				cellBg:addChild(skillNameLb)
				if strategyCenterVoApi:isCanUpgrade(skillId, skillLevel) then
					local canUpgradeBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png", CCRect(4, 4, 1, 1), function()end)
					canUpgradeBg:setContentSize(CCSizeMake(skillIcon:getContentSize().width - 6, 22))
					canUpgradeBg:setAnchorPoint(ccp(0.5, 1))
					canUpgradeBg:setPosition(ccp(skillIcon:getContentSize().width / 2, skillIcon:getContentSize().height - 3))
					canUpgradeBg:setOpacity(255 * 0.55)
					skillIcon:addChild(canUpgradeBg, 1)
					local canUpgradeLb = GetTTFLabel(getlocal("strategyCenter_canUpgradeText"), 18)
					canUpgradeLb:setPosition(ccp(canUpgradeBg:getContentSize().width / 2, canUpgradeBg:getContentSize().height / 2))
					canUpgradeLb:setColor(ccc3(24, 255, 0))
					canUpgradeBg:addChild(canUpgradeLb)
					canUpgradeLb:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
						CCFadeIn:create(1.5), CCFadeOut:create(1.5)
					)))
				end
			end
		end
	end)
	skillTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	skillTv:setPosition(ccp((G_VisibleSizeWidth - skillTvSize.width) / 2, 15))
	self.bgLayer:addChild(skillTv, 1)
	self.skillTv = skillTv
end

function strategyCenterTabOne:refreshHeroDispatch()
	if self then
		G_removeFlicker2(self.iconBg)
		local tempSp = tolua.cast(self.iconBg:getChildByTag(10), "CCSprite")
		if tempSp then
			tempSp:removeFromParentAndCleanup(true)
		end
		local heroTipsLb = tolua.cast(self.heroTipsLb, "CCLabelTTF")
		local dispatchState, timer = strategyCenterVoApi:getHeroDispatchState()
		if dispatchState == 0 then
			if heroTipsLb then
				heroTipsLb:setString(getlocal("strategyCenter_clickDispatch"))
			end
		elseif dispatchState == 1 or dispatchState == 2 then
			tempSp = CCSprite:createWithSpriteFrameName("yswj_box.png")
			tempSp:setScale(self.iconBg:getContentSize().width / tempSp:getContentSize().width)
			tempSp:setPosition(ccp(self.iconBg:getContentSize().width / 2, self.iconBg:getContentSize().height / 2))
			tempSp:setTag(10)
			self.iconBg:addChild(tempSp, 1)
			if heroTipsLb then
				if dispatchState == 1 then
					heroTipsLb:setString(getlocal("strategyCenter_dispatchingText", {GetTimeStr(timer)}))
				else
					G_addRectFlicker2(self.iconBg, 1.15, 1.15, 1, "y", nil, 10)
					heroTipsLb:setString(getlocal("canReward"))
				end
			end
		elseif dispatchState == 3 then
			if heroTipsLb then
				heroTipsLb:setString(getlocal("strategyCenter_dispatchCompleteTips"))
			end
		end
	end
end

function strategyCenterTabOne:overDayEvent()
	if self then
		strategyCenterVoApi:requestInit(function()
			self:refreshHeroDispatch()
			if self.transformBtn and self.transformCountLb then
				local curTransformCount = strategyCenterVoApi:getExpTransformCount()
				local maxTransformCount = strategyCenterVoApi:getExpTransformMaxCount()
				self.transformBtn:setEnabled(curTransformCount < maxTransformCount)
				if curTransformCount >= maxTransformCount then
					self.transformCountLb:setString(getlocal("strategyCenter_notCountTips"))
				else
					self.transformCountLb:setString(getlocal("exchangeNum", {curTransformCount, maxTransformCount}))
				end
			end
		end)
	end
end

function strategyCenterTabOne:tick()
	if self then
		local dispatchState, timer = strategyCenterVoApi:getHeroDispatchState()
		if dispatchState == 1 then
			self.dispatchState = dispatchState
			local heroTipsLb = tolua.cast(self.heroTipsLb, "CCLabelTTF")
			heroTipsLb:setString(getlocal("strategyCenter_dispatchingText", {GetTimeStr(timer)}))
		elseif self.dispatchState == 1 and dispatchState == 2 then
			self.dispatchState = dispatchState
			self:refreshHeroDispatch()
		end
	end
end

function strategyCenterTabOne:dispose()
	self = nil
	spriteController:removePlist("public/squaredImgs.plist")
    spriteController:removeTexture("public/squaredImgs.png")
    spriteController:removePlist("public/acyswj_images2.plist")
    spriteController:removeTexture("public/acyswj_images2.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/yellowFlicker.plist")
end