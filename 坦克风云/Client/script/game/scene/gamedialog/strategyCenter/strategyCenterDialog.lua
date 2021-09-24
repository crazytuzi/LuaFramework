strategyCenterDialog = commonDialog:new()

function strategyCenterDialog:new(layerNum)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/strategyCenterImages.plist")
        spriteController:addTexture("public/strategyCenterImages.png")
        spriteController:addPlist("public/strategyCenterSkillIcon.plist")
        spriteController:addTexture("public/strategyCenterSkillIcon.png")
        spriteController:addPlist("public/strategyCenterEffect.plist")
        spriteController:addTexture("public/strategyCenterEffect.png")
    end)
    return nc
end

function strategyCenterDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))

    self.tabButton1 = LuaCCSprite:createWithSpriteFrameName("sci_tabTitleBg1_focus.png", function(...) self:onSwitchTab(1) end)
    self.tabButton2 = LuaCCSprite:createWithSpriteFrameName("sci_tabTitleBg2.png", function(...) self:onSwitchTab(2) end)
    self.tabButton1:setAnchorPoint(ccp(1, 1))
    self.tabButton2:setAnchorPoint(ccp(0, 1))
    self.tabButton1:setPosition(G_VisibleSizeWidth / 2 + 10, G_VisibleSizeHeight - 75)
    self.tabButton2:setPosition(G_VisibleSizeWidth / 2 - 10, G_VisibleSizeHeight - 75)
    self.tabButton2:setFlipX(true)
    self.tabButton1:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.tabButton2:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(self.tabButton1, 1)
    self.bgLayer:addChild(self.tabButton2, 1)
    local tabTitleLb1 = GetTTFLabelWrap(getlocal("strategyCenter_basics"), 25, CCSizeMake(self.tabButton1:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    local tabTitleLb2 = GetTTFLabelWrap(getlocal("strategyCenter_peakedness"), 25, CCSizeMake(self.tabButton2:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    tabTitleLb1:setPosition((self.tabButton1:getContentSize().width - 10) / 2, self.tabButton1:getContentSize().height / 2 - 10)
    tabTitleLb2:setPosition((self.tabButton2:getContentSize().width - 10) / 2 + 10, self.tabButton2:getContentSize().height / 2 - 10)
    self.tabButton1:addChild(tabTitleLb1)
    self.tabButton2:addChild(tabTitleLb2)
    self:onSwitchTab(1)

    local openLv = strategyCenterVoApi:getPeakednessOpenLv()
	if playerVoApi:getPlayerLevel() < openLv then
		tabTitleLb2:setVisible(false)
		local grayTabSp2 = GraySprite:createWithSpriteFrameName("sci_tabTitleBg2.png")
		grayTabSp2:setFlipX(true)
		grayTabSp2:setPosition(ccp(self.tabButton2:getContentSize().width / 2, self.tabButton2:getContentSize().height / 2))
		self.tabButton2:addChild(grayTabSp2)
		local lockSp = CCSprite:createWithSpriteFrameName("lockingIcon.png")
		local lockTipsLb = GetTTFLabel(getlocal("functionUnlockStr", {openLv}), 24)
		local startPosX = ((grayTabSp2:getContentSize().width - 10) - (lockSp:getContentSize().width + lockTipsLb:getContentSize().width)) / 2 + 10
		lockSp:setAnchorPoint(ccp(0, 0.5))
		lockSp:setPosition(ccp(startPosX, grayTabSp2:getContentSize().height / 2 - 10))
		grayTabSp2:addChild(lockSp)
		lockTipsLb:setAnchorPoint(ccp(0, 0.5))
		lockTipsLb:setPosition(ccp(lockSp:getPositionX() + lockSp:getContentSize().width, lockSp:getPositionY()))
		lockTipsLb:setColor(G_ColorRed)
		grayTabSp2:addChild(lockTipsLb)
	end

	--添加战力值变化的监听
  	self.powerChangeListener = function(eventKey, eventData)
  		G_showNumberChange(eventData[1], eventData[2])
 	end
  	eventDispatcher:addEventListener("user.power.change", self.powerChangeListener)
end

function strategyCenterDialog:onSwitchTab(index)
	if self.curShowTabIndex == index then
		do return end
	end
	if index == 1 then
		self.tabButton1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("sci_tabTitleBg1_focus.png"))
		self.tabButton2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("sci_tabTitleBg2.png"))
		if self.tabTwoLayer then
			self.tabTwoLayer:setVisible(false)
			self.tabTwoLayer:setPosition(ccp(G_VisibleSizeWidth * 5, G_VisibleSizeHeight * 5))
		end
		if self.tabOneLayer == nil then
			-- _G.strategyCenterTabOne = nil
			-- _G.package.loaded["luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterTabOne"] = nil
			-- require "luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterTabOne"
			G_reloadModule("luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterTabOne", "strategyCenterTabOne")
			self.tabOneLayer = strategyCenterTabOne:create(self, self.tabButton1:getPositionY() - self.tabButton1:getContentSize().height)
			self.bgLayer:addChild(self.tabOneLayer)
		end
		self.tabOneLayer:setVisible(true)
		self.tabOneLayer:setPosition(ccp(0, 0))
	elseif index == 2 then
		local openLv = strategyCenterVoApi:getPeakednessOpenLv()
		if playerVoApi:getPlayerLevel() < openLv then
			G_showTipsDialog(getlocal("elite_challenge_unlock_level", {openLv}))
			do return end
		end
		self.tabButton2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("sci_tabTitleBg2_focus.png"))
		self.tabButton1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("sci_tabTitleBg1.png"))
		if self.tabOneLayer then
			self.tabOneLayer:setVisible(false)
			self.tabOneLayer:setPosition(ccp(G_VisibleSizeWidth * 5, G_VisibleSizeHeight * 5))
		end
		if self.tabTwoLayer == nil then
			-- _G.strategyCenterTabTwo = nil
			-- _G.package.loaded["luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterTabTwo"] = nil
			-- require "luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterTabTwo"
			G_reloadModule("luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterTabTwo", "strategyCenterTabTwo")
			self.tabTwoLayer = strategyCenterTabTwo:create(self, self.tabButton2:getPositionY() - self.tabButton2:getContentSize().height)
			self.bgLayer:addChild(self.tabTwoLayer)
		end
		self.tabTwoLayer:setVisible(true)
		self.tabTwoLayer:setPosition(ccp(0, 0))
	end
	self.curShowTabIndex = index
end

function strategyCenterDialog:tick()
	if self then
		if self.tabOneLayer and strategyCenterTabOne and strategyCenterTabOne.tick then
			strategyCenterTabOne:tick()
		end
		if self.tabTwoLayer and strategyCenterTabTwo and strategyCenterTabTwo.tick then
			strategyCenterTabTwo:tick()
		end
	end
end

function strategyCenterDialog:overDayEvent()
	if self then
		if self.tabOneLayer and strategyCenterTabOne and strategyCenterTabOne.overDayEvent then
			strategyCenterTabOne:overDayEvent()
		end
		if self.tabTwoLayer and strategyCenterTabTwo and strategyCenterTabTwo.overDayEvent then
			strategyCenterTabTwo:overDayEvent()
		end
	end
end

function strategyCenterDialog:dispose()
	if self.tabOneLayer and strategyCenterTabOne and strategyCenterTabOne.dispose then
		strategyCenterTabOne:dispose()
	end
	if self.tabTwoLayer and strategyCenterTabTwo and strategyCenterTabTwo.dispose then
		strategyCenterTabTwo:dispose()
	end
	if self.powerChangeListener then
  		eventDispatcher:removeEventListener("user.power.change", self.powerChangeListener)
  		self.powerChangeListener = nil
  	end
	self = nil
	spriteController:removePlist("public/strategyCenterImages.plist")
    spriteController:removeTexture("public/strategyCenterImages.png")
    spriteController:removePlist("public/strategyCenterSkillIcon.plist")
    spriteController:removeTexture("public/strategyCenterSkillIcon.png")
    spriteController:removePlist("public/strategyCenterEffect.plist")
    spriteController:removeTexture("public/strategyCenterEffect.png")
end