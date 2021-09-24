strategyCenterTabTwo = {}

function strategyCenterTabTwo:create(parent, topPosY)
	self.layerNum = parent.layerNum
	self.topPosY = topPosY
	G_addResource8888(function()
		spriteController:addPlist("public/xcjh.plist")
    	spriteController:addTexture("public/xcjh.png")
    	spriteController:addPlist("public/rewardCenterImage.plist")
    	spriteController:addTexture("public/rewardCenterImage.png")
    end)
	self.bgLayer = CCLayer:create()
	self:initUI()
	return self.bgLayer
end

function strategyCenterTabTwo:initUI()
	local function onLoadWebImage(fn, webImage)
        if self and self.bgLayer and tolua.cast(self.bgLayer, "CCLayer") then
            webImage:setAnchorPoint(ccp(0.5, 1))
            webImage:setPosition(G_VisibleSizeWidth / 2, self.topPosY)
            self.bgLayer:addChild(webImage)
        end
    end
    G_addResource8888(function() LuaCCWebImage:createWithURL(G_downloadUrl("function/strategyCenter_bg2.jpg"), onLoadWebImage) end)

    local spaceLine = LuaCCScale9Sprite:createWithSpriteFrameName("sci_spaceLine2.png", CCRect(0, 2, 640, 4), function()end)
    spaceLine:setContentSize(CCSizeMake(spaceLine:getContentSize().width, 180))
    spaceLine:setAnchorPoint(ccp(0.5, 1))
    spaceLine:setPosition(ccp(G_VisibleSizeWidth / 2, self.topPosY))
    self.bgLayer:addChild(spaceLine, 1)
    local spaceBg = CCNode:create()--CCLayerColor(ccc4(0, 0, 0, 255))
    spaceBg:setContentSize(CCSizeMake(spaceLine:getContentSize().width, spaceLine:getContentSize().height - 18))
    spaceBg:setAnchorPoint(ccp(0, 0))
    spaceBg:setPosition(ccp(0, 16))
    spaceLine:addChild(spaceBg)

	local topLevelBg = CCSprite:createWithSpriteFrameName("sci_levelBg2.png")
	topLevelBg:setAnchorPoint(ccp(0.5, 1))
	topLevelBg:setPosition(ccp(spaceBg:getContentSize().width / 2, spaceBg:getContentSize().height - 3))
	spaceBg:addChild(topLevelBg)
	self.scMaxLevel = strategyCenterVoApi:getMaxLevel(2)
	local scLevel = strategyCenterVoApi:getLevel(2)
	local levelLb = GetTTFLabel(getlocal("fightLevel", {scLevel}), 24, true)
	levelLb:setAnchorPoint(ccp(0.5, 1))
	levelLb:setPosition(ccp(topLevelBg:getContentSize().width / 2, topLevelBg:getContentSize().height - 8))
	topLevelBg:addChild(levelLb)

	local function playUpgradeEffect(callback)
		local firstFrameSp = CCSprite:createWithSpriteFrameName("sce_upgradeEffect_p_1.png")
	    G_setBlendFunc(firstFrameSp, GL_ONE, GL_ONE)
	    local frameArray = CCArray:create()
	    for i = 1, 10 do
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("sce_upgradeEffect_p_" .. i .. ".png")
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
        local tabStr = { getlocal("strategyCenter_peakednessDesc1"), getlocal("strategyCenter_peakednessDesc2") }
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

    local skillPointBg = CCSprite:createWithSpriteFrameName("sci_skillPointBg2.png")
	skillPointBg:setAnchorPoint(ccp(0, 1))
	skillPointBg:setPosition(15, topLevelBg:getPositionY() - topLevelBg:getContentSize().height - 10)
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
	local curExp, maxExp = strategyCenterVoApi:getExp(2), strategyCenterVoApi:getExpMax(scLevel, 2)
	progressBar:setPercentage(curExp / maxExp * 100)
	local expLabel = GetTTFLabel(curExp .. "/" .. maxExp, 18, true)
	expLabel:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
	progressBarBg:addChild(expLabel)

	local skillPointLb = GetTTFLabel(getlocal("strategyCenter_skillPoint"), 20, true)
	skillPointLb:setAnchorPoint(ccp(0, 0.5))
	skillPointLb:setPosition(ccp(20, skillPointBg:getContentSize().height / 2))
	skillPointBg:addChild(skillPointLb)
	local skillPoint = strategyCenterVoApi:getSkillPoint(2)
	local skillPointNumLb = GetTTFLabel(skillPoint, 26, true)
	skillPointNumLb:setAnchorPoint(ccp(0, 0.5))
	skillPointNumLb:setPosition(ccp(skillPointLb:getPositionX() + skillPointLb:getContentSize().width + 15, skillPointBg:getContentSize().height / 2))
	skillPointNumLb:setColor(G_ColorYellowPro)
	skillPointBg:addChild(skillPointNumLb, 1)
	self.skillPointNumLb = skillPointNumLb
	local function onClickResetPoint(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local costNum = strategyCenterVoApi:getResetPointCost(2)
        G_showSureAndCancle(getlocal("strategyCenter_resetPointTips", {costNum}), function()
        	local gems = playerVoApi:getGems()
	        if gems < costNum then
	            GemsNotEnoughDialog(nil, nil, costNum - gems, self.layerNum + 1, costNum)
	            do return end
	        end
        	strategyCenterVoApi:requestResetPoint(function()
        		playerVoApi:setGems(playerVoApi:getGems() - costNum)
        		skillPoint = strategyCenterVoApi:getSkillPoint(2)
        		self:playSkillPointEffect(skillPoint)
        		-- skillPointNumLb:setString(tostring(skillPoint))
        		self.resetPointBtn:setEnabled(strategyCenterVoApi:getCostSkillPoint(2) > 0)
        		if self.curPageItem and self.pageLayer then
        			self:createPageItem(self.pageLayer:getContentSize(), self.showPageIndex, self.curPageItem)
        		end
        	end, 2)
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
	self.resetPointBtn:setEnabled(strategyCenterVoApi:getCostSkillPoint(2) > 0)

	--升级
	local function onClickUpgrade(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        strategyCenterVoApi:showPeakednessUpgradeSmallDialog(self.layerNum + 1, function()
        	G_showTipsDialog(getlocal("decorateUpSucess"))
        	scLevel = strategyCenterVoApi:getLevel(2)
			playUpgradeEffect(function() levelLb:setString(getlocal("fightLevel", {scLevel})) end)
        	curExp, maxExp = strategyCenterVoApi:getExp(2), strategyCenterVoApi:getExpMax(scLevel, 2)
			progressBar:setPercentage(curExp / maxExp * 100)
			expLabel:setString(curExp .. "/" .. maxExp)
			self.upgradeBtn:setEnabled(curExp >= maxExp)
			if scLevel == self.scMaxLevel then
				self.upgradeBtn:setEnabled(false)
			end
			skillPoint = strategyCenterVoApi:getSkillPoint(2)
			self:playSkillPointEffect(skillPoint)
        	-- skillPointNumLb:setString(tostring(skillPoint))
        	if self.curPageItem and self.pageLayer then
    			self:createPageItem(self.pageLayer:getContentSize(), self.showPageIndex, self.curPageItem)
    		end
        	if parent and tolua.cast(parent.tabOneLayer, "CCLayer") then
        		strategyCenterTabOne:dispose()
        		parent.tabOneLayer:removeFromParentAndCleanup(true)
        		parent.tabOneLayer = nil
        	end
        end)
	end
	local upgradeBtnScale = 0.6
	local upgradeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickUpgrade, 11, getlocal("upgradeBuild"), 24 / upgradeBtnScale)
	upgradeBtn:setScale(upgradeBtnScale)
	upgradeBtn:setAnchorPoint(ccp(1, 0))
	upgradeBtn:setPosition(ccp(progressBarBg:getPositionX() + progressBarBg:getContentSize().width / 2, progressBarBg:getPositionY() + 10))
	local upgradeMenu = CCMenu:createWithItem(upgradeBtn)
	upgradeMenu:setPosition(ccp(0, 0))
	upgradeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	spaceBg:addChild(upgradeMenu)
	self.upgradeBtn = upgradeBtn
	self.upgradeBtn:setEnabled(curExp >= maxExp)
	if scLevel == self.scMaxLevel then
		self.upgradeBtn:setEnabled(false)
	end
	local todayExpLbFontSize = G_isAsia() and 22 or 20
	if G_isIOS() == false then
		todayExpLbFontSize = todayExpLbFontSize - 2
	end
	local todayExpLbWidth = upgradeBtn:getPositionX() - upgradeBtn:getContentSize().width * upgradeBtnScale - (skillPointBg:getPositionX() + skillPointBg:getContentSize().width) - 20
	local todayExpLb = GetTTFLabelWrap(getlocal("strategyCenter_todayGetExp", {math.floor(strategyCenterVoApi:getTodayExpPeakedness()), math.floor(strategyCenterVoApi:getTodayMaxExpPeakedness())}), todayExpLbFontSize, CCSizeMake(todayExpLbWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	todayExpLb:setAnchorPoint(ccp(1, 0.5))
	todayExpLb:setPosition(ccp(upgradeBtn:getPositionX() - upgradeBtn:getContentSize().width * upgradeBtnScale - 20, upgradeBtn:getPositionY() + upgradeBtn:getContentSize().height * upgradeBtnScale / 2))
	spaceBg:addChild(todayExpLb)

	self.skillList = strategyCenterVoApi:getSkillList(2)
	local skillListSize = SizeOfTable(self.skillList)
	self.showPageIndex = 1
	local pageTurning = false
	local function onPageEvent(pageLayer, direction)
		if direction == 0 then
			self.curPageItem = self:createPageItem(pageLayer:getContentSize(), self.showPageIndex)
			pageLayer:addChild(self.curPageItem)
		else
			if pageTurning == true then
	            do return end
	        end
	        pageTurning = true
	        self.showPageIndex = self.showPageIndex + direction
	        if self.showPageIndex <= 0 then
	            self.showPageIndex = skillListSize
	        end
	        if self.showPageIndex > skillListSize then
	            self.showPageIndex = 1
	        end
	        local cPos = ccp(self.curPageItem:getPosition())
	        local nextPageItem = self:createPageItem(pageLayer:getContentSize(), self.showPageIndex)
	        nextPageItem:setPosition(cPos.x + direction * pageLayer:getContentSize().width, cPos.y)
	        pageLayer:addChild(nextPageItem)
	        self.curPageItem:runAction(CCMoveTo:create(0.3, ccp(cPos.x - direction * pageLayer:getContentSize().width, cPos.y)))
	        local arry = CCArray:create()
	        arry:addObject(CCMoveTo:create(0.3, cPos))
	        arry:addObject(CCMoveTo:create(0.06, ccp(cPos.x - direction * 50, cPos.y)))
	        arry:addObject(CCMoveTo:create(0.06, cPos))
	        arry:addObject(CCCallFunc:create(function()
	        	self.curPageItem:removeFromParentAndCleanup(true)
	        	self.curPageItem = nil
	        	self.curPageItem = nextPageItem
	        	pageTurning = false
	        	if self.buffTv then
	        		self.buffTvCellTb = nil
	        		self:initBuffTvCellTb(self.showPageIndex)
	        		self.buffTv:reloadData()
	        	end
	        end))
	        nextPageItem:runAction(CCSequence:create(arry))
	    end
	end
	local pageLayer = self:createPageLayer(CCSizeMake(G_VisibleSizeWidth, 480), - (self.layerNum - 1) * 20 - 1, onPageEvent)
	pageLayer:setPosition(ccp((G_VisibleSizeWidth - pageLayer:getContentSize().width) / 2, spaceLine:getPositionY() - spaceLine:getContentSize().height - pageLayer:getContentSize().height))
	self.bgLayer:addChild(pageLayer, 1)
	self.pageLayer = pageLayer

	local bottomSpaceLine = LuaCCScale9Sprite:createWithSpriteFrameName("sci_spaceLine2.png", CCRect(0, 2, 640, 4), function()end)
	bottomSpaceLine:setContentSize(CCSizeMake(bottomSpaceLine:getContentSize().width, pageLayer:getPositionY()))
	bottomSpaceLine:setRotation(180)
	bottomSpaceLine:setAnchorPoint(ccp(0.5, 1))
	bottomSpaceLine:setPosition(ccp(G_VisibleSizeWidth / 2, 0))
	self.bgLayer:addChild(bottomSpaceLine, 1)

	self.buffTvSize = CCSizeMake(bottomSpaceLine:getContentSize().width, bottomSpaceLine:getContentSize().height - 30)
	self:initBuffTvCellTb(self.showPageIndex)
	local buffTv = G_createTableView(self.buffTvSize, function() return SizeOfTable(self.buffTvCellTb) end, function(idx, cellNum)
		return CCSizeMake(self.buffTvSize.width, self.buffTvCellTb[idx + 1].height)
	end, function(cell, cellSize, idx, cellNum)
		local buffLb = self.buffTvCellTb[idx + 1].label
		buffLb:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
		if idx + 1 == 1 then
			buffLb:setColor(G_ColorYellowPro)
		end
		cell:addChild(buffLb)
	end)
	buffTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 2)
	buffTv:setPosition(ccp((G_VisibleSizeWidth - self.buffTvSize.width) / 2, bottomSpaceLine:getPositionY() + 10))
	buffTv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(buffTv, 1)
	self.buffTv = buffTv
end

function strategyCenterTabTwo:playSkillPointEffect(newSkillPoint)
	if self.skillPointNumLb then
		local seqArr = CCArray:create()
		seqArr:addObject(CCScaleTo:create(0.2, 3.0))
		seqArr:addObject(CCScaleTo:create(0.2, 1.0))
		seqArr:addObject(CCCallFunc:create(function()
			self.skillPointNumLb:setString(tostring(newSkillPoint))
			self.resetPointBtn:setPositionX(self.skillPointNumLb:getPositionX() + self.skillPointNumLb:getContentSize().width + 10)
		end))
		self.skillPointNumLb:runAction(CCSequence:create(seqArr))
	end
end

function strategyCenterTabTwo:createPageItem(pageLayerSize, pageIndex, refreshPageItem)
	local pageItem
	if refreshPageItem then
		refreshPageItem:removeAllChildrenWithCleanup(true)
		pageItem = refreshPageItem
	else
		pageItem = CCNode:create()
		pageItem:setContentSize(pageLayerSize)
		pageItem:setAnchorPoint(ccp(0, 0))
		pageItem:setPosition(ccp(0, 0))
	end
	local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("sci_titleLine.png", CCRect(0, 2, 462, 4), function()end)
	titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width, 40))
	titleBg:setAnchorPoint(ccp(0.5, 1))
	titleBg:setPosition(ccp(pageItem:getContentSize().width / 2, pageItem:getContentSize().height))
	pageItem:addChild(titleBg)
	local titleLb = GetTTFLabel(getlocal("strategyCenter_peakednessPageTitle", {G_formatArabicDigit(pageIndex)}), 35, true)
	titleLb:setPosition(ccp(titleBg:getPositionX(), titleBg:getPositionY() - titleBg:getContentSize().height * titleBg:getScaleY() / 2))
	titleLb:setColor(ccc3(157, 128, 84))
	pageItem:addChild(titleLb)
	for k, skillId in ipairs(self.skillList[pageIndex].sid) do
		local skillBg = CCSprite:createWithSpriteFrameName((k == 1) and "sci_skillBg_big.png" or "sci_skillBg_small.png")
		if k == 1 then
			skillBg:setAnchorPoint(ccp(0.5, 1))
			skillBg:setPosition(ccp(titleBg:getPositionX(), titleBg:getPositionY() - titleBg:getContentSize().height * titleBg:getScaleY()))
		else
			if k == 2 then
				skillBg:setAnchorPoint(ccp(1, 0))
				skillBg:setPositionX(titleBg:getPositionX() - 10)
			elseif k == 3 then
				skillBg:setAnchorPoint(ccp(0, 0))
				skillBg:setPositionX(titleBg:getPositionX() + 10)
			end
			skillBg:setPositionY(10)
		end
		pageItem:addChild(skillBg)
		local skillCfgData = strategyCenterVoApi:getSkillCfgData(skillId)
		if skillCfgData then
			local skillIcon = LuaCCSprite:createWithSpriteFrameName(skillCfgData.icon, function()
				strategyCenterVoApi:showSkillDetailsSmallDialog(self.layerNum + 1, skillId, function()
					if self.curPageItem and self.pageLayer then
		    			self:createPageItem(self.pageLayer:getContentSize(), self.showPageIndex, self.curPageItem)
		    		end
		    		if self.skillPointNumLb then
			    		local skillPoint = strategyCenterVoApi:getSkillPoint(2)
			    		self:playSkillPointEffect(skillPoint)
		        		-- self.skillPointNumLb:setString(tostring(skillPoint))
		        	end
		        	if self.resetPointBtn then
	        			self.resetPointBtn:setEnabled(strategyCenterVoApi:getCostSkillPoint(2) > 0)
	        		end
					if self.buffTv then
		        		self.buffTvCellTb = nil
		        		self:initBuffTvCellTb(pageIndex)
		        		self.buffTv:reloadData()
		        	end
				end)
			end)
			skillIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
			local topSpace
			if k == 1 then
				skillIcon:setScale(95 / skillIcon:getContentSize().width)
				topSpace = 60
			else
				skillIcon:setScale(90 / skillIcon:getContentSize().width)
				topSpace = 40
			end
			skillIcon:setAnchorPoint(ccp(0.5, 1))
			skillIcon:setPosition(ccp(skillBg:getContentSize().width / 2, skillBg:getContentSize().height - topSpace))
			skillBg:addChild(skillIcon)
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
			local skillNameLb = GetTTFLabelWrap(getlocal(skillCfgData.skillName), G_isAsia() and 20 or 18, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
			skillNameLb:setAnchorPoint(ccp(0.5, 1))
			skillNameLb:setPosition(ccp(skillIcon:getPositionX(), skillIcon:getPositionY() - skillIcon:getContentSize().height * skillIcon:getScale()))
			skillBg:addChild(skillNameLb)
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
	return pageItem
end

function strategyCenterTabTwo:createPageLayer(pageLayerSize, touchPriority, onPageCallback)
	local pageLayer = CCLayer:create()
	pageLayer:setContentSize(pageLayerSize)
    -- pageLayer:setPosition(pageLayerPos)
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
                		onPageCallback(pageLayer, -1)
                	end
                elseif moveDisTmp.x < - 50 then
                    if type(onPageCallback) == "function" then
                    	onPageCallback(pageLayer, 1)
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
    pageLayer:registerScriptTouchHandler(touchHandler, false, touchPriority, true)
    -- pageLayer:registerScriptTouchHandler(touchHandler, false, - (self.layerNum - 1) * 20 - 1, true)
    -- self.bgLayer:addChild(pageLayer, 1)

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

    local leftTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if type(onPageCallback) == "function" then onPageCallback(pageLayer, -1) end end)
    local rightTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if type(onPageCallback) == "function" then onPageCallback(pageLayer, 1) end end)
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
    if type(onPageCallback) == "function" then
    	onPageCallback(pageLayer, 0)
    end

    return pageLayer
end

function strategyCenterTabTwo:initBuffTvCellTb(pageIndex)
	if self.buffTvCellTb == nil then
		self.buffTvCellTb = {}
		local buffId = self.skillList[pageIndex].bid
		local buffLevel = strategyCenterVoApi:getBuffLevel(buffId)
		local isMaxLevel = strategyCenterVoApi:isMaxBuffLevel(buffId, buffLevel)
		local lbCount = 4
		if buffLevel == 0 then
			lbCount = 3
		elseif isMaxLevel then
			lbCount = 2
		end
		for i = 1, lbCount do
			local buffStr, buffLbFontSize = "", 22
			if i == 1 then
				local buffCfgData = strategyCenterVoApi:getBuffCfgData(buffId)
				buffStr = getlocal(buffCfgData.skillName) .. " " .. getlocal("fightLevel", {buffLevel})
				if isMaxLevel then
					buffStr = buffStr .. " (" .. getlocal("decorateMax") .. ")"
				end
				buffLbFontSize = 24
			elseif i == 2 then
				if buffLevel == 0 then
					buffStr = getlocal("upgrade_text") .. strategyCenterVoApi:getBuffDesc(buffId, buffLevel + 1)
				else
					if not isMaxLevel then
						buffStr = getlocal("current_text")
					end
					buffStr = buffStr .. strategyCenterVoApi:getBuffDesc(buffId, buffLevel)
				end
			elseif i == 3 then
				if buffLevel == 0 then
					buffStr = getlocal("deblocking_condition") .. strategyCenterVoApi:getBuffUnlockDesc(buffId, buffLevel)
				else
					buffStr = getlocal("upgrade_text") .. strategyCenterVoApi:getBuffDesc(buffId, buffLevel + 1)
				end
			elseif i == 4 then
				buffStr = getlocal("deblocking_condition") .. strategyCenterVoApi:getBuffUnlockDesc(buffId, buffLevel)
			end
			local buffLb = GetTTFLabelWrap(buffStr, buffLbFontSize, CCSizeMake(self.buffTvSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
			self.buffTvCellTb[i] = { label = buffLb, height = buffLb:getContentSize().height + 10 }
		end
	end
end

function strategyCenterTabTwo:dispose()
	self = nil
	spriteController:removePlist("public/xcjh.plist")
    spriteController:removeTexture("public/xcjh.png")
    spriteController:removePlist("public/rewardCenterImage.plist")
	spriteController:removeTexture("public/rewardCenterImage.png")
end