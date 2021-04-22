--
-- Author: Your Name
-- Date: 2014-07-23 15:25:18
--
local QBattleDialog = import(".QBattleDialog")
local QDialogTeamUp = class("QDialogTeamUp", QBattleDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIViewController = import("..QUIViewController")
local QTips = import("...utils.QTips")
local QUIDialogMystoryStoreAppear = import("..dialogs.QUIDialogMystoryStoreAppear")
local QTutorialDefeatedGuide = import("...tutorial.defeated.QTutorialDefeatedGuide")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QDialogTeamUp:ctor(options,owner)
	local ccbFile = "ccb/Dialog_BattelTeamUp.ccbi";
	local callBacks = {
    	{ccbCallbackName = "onTriggerClose",  callback = handler(self, QDialogTeamUp._onTriggerClose)},
		{ccbCallbackName = "onTriggerGoto1", 	callback = handler(self, QDialogTeamUp._onTriggerGoto1)},
		{ccbCallbackName = "onTriggerGoto2", 	callback = handler(self, QDialogTeamUp._onTriggerGoto2)},
	}
	if owner == nil then 
		owner = {} 
	end
	QDialogTeamUp.super.ctor(self,ccbFile,owner,callBacks)

  	self._isEnd = false
	self._effectTime = 2
	self._effectTbl = {}
	self._CP = {x = 0, y = 0}
	self._size = CCSize(display.width, display.height)
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._ccbOwner.tf_level:setString("")
	self._ccbOwner.tf_level_new:setString("")
	self._ccbOwner.tf_energy:setString("")
	self._ccbOwner.tf_energy_new:setString("")
	self._ccbOwner.tf_award:setString("")

	if options ~= nil then
		self._ccbOwner.tf_level:setString(options.level)
		self._ccbOwner.tf_level_new:setString(options.level_new)
		self._ccbOwner.tf_energy:setString(options.energy)
		self._ccbOwner.tf_energy_new:setString(options.energy_new)
		self._ccbOwner.tf_award:setString("x "..options.award)

		self.unNewlockLevel = options.level_new
		self.unOldlockLevel = options.level
	end

    self._animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
    self._animationManager:runAnimationsForSequenceNamed("one")
    app.sound:playSound("battle_level_up")

    self:_unlockFunctions(options.level_new)

	self._timeScheduler = scheduler.performWithDelayGlobal(function()
    		self._isEnd = true
    	end, 2)
end

function QDialogTeamUp:nodeEffect(node, startNum, endNum)
	if endNum <= startNum then return end
	if node ~= nil then
		local update = QTextFiledScrollUtils.new()
		update:addUpdate(startNum, endNum, function(value)
				node:setString(math.ceil(value))
			end, self._effectTime)
		node:setScale(1)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1.5))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		local handler = node:runAction(ccsequence)
		table.insert(self._effectTbl,{update = update, handler = handler, node = node})
	end
end

function QDialogTeamUp:_unlockFunctions(level)
	local locked = QStaticDatabase:sharedDatabase():getUnlock()
	local lockedLevels = {}
	local unlockLevels = {}
	
	local unlockList = {}
	for k, v in pairs(locked) do
		unlockList[#unlockList+1] = v
	end
	
	table.sort(unlockList, function(a, b)
			if a.order ~= b.order then
				if a.order == nil or b.order == nil then
					return a.order ~= nil
				else
					return a.order < b.order
				end
			else
				return false
			end
		end)

	for k, v in pairs(locked) do
		if v.team_level and v.team_level > 120 then

		elseif v.team_level and v.team_level == level and v.show_level_up == 1 then
			v.isLock = false
			if v.key == "UNLOCK_SHOP_2" then
			 	if remote.stores:checkMystoryStore(SHOP_ID.blackShop) == false then
					table.insert(unlockLevels, v)
			 	end
			else
				table.insert(unlockLevels, v)
			end
		elseif v.team_level and v.team_level > level and v.show_level_up == 1 then
			v.isLock = true
			if v.key == "UNLOCK_SHOP_2" then
			 	if remote.stores:checkMystoryStore(SHOP_ID.blackShop) == false then
					table.insert(lockedLevels, v)
			 	end
			else
				table.insert(lockedLevels, v)
			end
		end
	end
	table.sort(lockedLevels, function (a, b)
		return a.team_level < b.team_level
	end)

	if next(unlockLevels) == nil then 
		unlockLevels = lockedLevels
	end

	local showLevels = {}
	if unlockLevels[1] and unlockLevels[2] and unlockLevels[1].team_level == unlockLevels[2].team_level then
		showLevels[1] = unlockLevels[1]
		showLevels[2] = unlockLevels[2]
	else
		showLevels[1] = unlockLevels[1]
	end

	for i = 1, 2 do
		self._ccbOwner["forecast" .. i]:setVisible(false)
	end

	self._unlockInfo = {}
	self._guidanceIndex = 0
	-- for i = 1, 2 do
	for i = 1, 1 do	
		if showLevels[i] then
			self._ccbOwner["forecast" .. i]:setVisible(true)
	    	self._ccbOwner["unlock"..i]:addChild(CCSprite:createWithTexture(CCTextureCache:sharedTextureCache():addImage(showLevels[i].icon)))
			self._ccbOwner["unlock_title_"..i]:setString(showLevels[i].name)
			self._ccbOwner["unlock_dec_"..i]:setString(showLevels[i].description)

			if showLevels[i].isLock then
				self._ccbOwner["unlock_level_"..i]:setString(string.format("%s级开启", showLevels[i].team_level))
			end
			self._ccbOwner["unlock_level_"..i]:setVisible(showLevels[i].isLock)

			self._ccbOwner["node_btn_"..i]:setVisible(false)
			if showLevels[i].isLock == false then
				if showLevels[i].show_go and showLevels[i].show_go ~= 2 then
					self._ccbOwner["node_btn_"..i]:setVisible(true)
				end

				self._unlockInfo[i] = UNLOCK_INFO[showLevels[i].key]
				if self._guidanceIndex == 0 and showLevels[i].force_guidance == 1 then
					self._guidanceIndex = i
				end
			end
		end
	end
	self._ccbOwner.forecast:setVisible(#showLevels >= 1)

	local stage = app.tutorial:getStage()
	if stage.call == 0 and remote.instance:checkIsPassByDungeonId("wailing_caverns_9") == true then
		self:setGotoVisible()
	elseif stage.call == 1 and remote.instance:checkIsPassByDungeonId("wailing_caverns_20") == true then
		self:setGotoVisible()
	elseif stage.skill == 0 and remote.instance:checkIsPassByDungeonId("wailing_caverns_22") == true then
		self:setGotoVisible()
	elseif stage.strengthen == 0 and remote.instance:checkIsPassByDungeonId("wailing_caverns_14") == true then
		self:setGotoVisible()
	elseif stage.heroYwd == 0 and remote.instance:checkIsPassByDungeonId("wailing_caverns_16") and not remote.instance:checkIsPassByDungeonId("wailing_caverns_17") then
		self:setGotoVisible()
	end

	if self._guidanceIndex > 0 then
		self:_createTouchNode()
	end

	--xurui 检查黑市商店是否开启
	remote.stores:getBlackShopIsUnlock(level)
	
	self._timeScheduler1 = scheduler.performWithDelayGlobal(function()
			self:checkCanGuidance()
    	end, 1)
end

function QDialogTeamUp:_createTouchNode()
  	self._touchNode = CCNode:create()
    self._touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    self._touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchNode:setTouchSwallowEnabled(true)
    self:addChild(self._touchNode)
	self._touchNode:setTouchEnabled( true )
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QDialogTeamUp:setGotoVisible()
	for i = 1, 2 do
		self._ccbOwner["node_btn_"..i]:setVisible(false)
	end
	self._guidanceIndex = 0
	if self._tutorial ~= nil then
		self._tutorial:removeFromParent()
		self._tutorial = nil
	end
end

function QDialogTeamUp:checkCanGuidance()
	if self._guidanceIndex == 0 then return end

	local node = self._ccbOwner["node_tutorial_"..self._guidanceIndex]
	self._CP = node:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._ccbOwner["btn_goto"..self._guidanceIndex]:getContentSize()

    self._timeScheduler2 = scheduler.performWithDelayGlobal(function()
    		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
    		if node then
    			if node.addChild and self._handTouch then
					node:addChild(self._handTouch)
				end
			end
    	end, 0.5)
end

function QDialogTeamUp:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._CP ~= nil and event.x >=  self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
			event.y >=  self._CP.y - self._size.height/2 and event.y <= self._CP.y + self._size.height/2  then
			self:checkClickEvent()
		else
			if self._handTouch and self._handTouch.showFocus then
				self._handTouch:showFocus( self._CP )
			end
		end
	end
end

function QDialogTeamUp:checkClickEvent()
	if self._guidanceIndex == 1 then
		self:_onTriggerGoto1()
	elseif self._guidanceIndex == 2 then
		self:_onTriggerGoto1()
	else
		self:_onTriggerClose()
	end
end

function QDialogTeamUp:clearEffect()
	for _,value in pairs(self._effectTbl) do
		if value.update ~= nil then
			value.update:stopUpdate()
		end
		if value.handler ~= nil and value.node ~= nil then
			value.node:stopAction(value.handler)
		end
	end
end

function QDialogTeamUp:_onTriggerGoto1()
    if self._guidanceIndex ~= 0 and self._guidanceIndex ~= 1 then return end
    self:viewAnimationEndHandler()
    self:openUnlockDialog(1)
end

function QDialogTeamUp:_onTriggerGoto2()
    if self._guidanceIndex ~= 0 and self._guidanceIndex ~= 2 then return end
    self:viewAnimationEndHandler()
    self:openUnlockDialog(2)
end

function QDialogTeamUp:openUnlockDialog(index)
  	app.tip:checkUnlock(self.unNewlockLevel, self.unOldlockLevel) -- The process for check unlock is already move to QTips  
  	self:clearEffect()
    self:removeAllScheduler()

  	local num = tonumber(index) or self._guidanceIndex
  	local unlockInfo = self._unlockInfo[num]
  	if unlockInfo == nil then return end

	local stage = app.tutorial:getStage()
	if unlockInfo.tutorialMark ~= nil and stage[unlockInfo.tutorialMark] then
		stage[unlockInfo.tutorialMark] = 1
		app.tutorial:setStage(stage)
		app.tutorial:setFlag(stage)
	end

	local unlock = app.tip:getUnlockTutorial()
	if unlockInfo.tutorialMark ~= nil and unlock[unlockInfo.tutorialMark] then
		unlock[unlockInfo.tutorialMark] = 2
		app.tip:setUnlockTutorial(unlock)
	end

	if unlockInfo == nil then return end
	local options = unlockInfo.options
	if unlockInfo.event == QTutorialDefeatedGuide.GROW or unlockInfo.event == QTutorialDefeatedGuide.TRAIN then
		options = {actorId = remote.herosUtil:getHaveHero()[1], guideGrow = false}
	elseif unlockInfo.event == QTutorialDefeatedGuide.GEMSTONE then
		local heroInfos, count = remote.herosUtil:getMaxForceHeros()
		options = {actorId = heroInfos[1].id}
	end
	
  	self._ccbOwner:onChoose({name = unlockInfo.event, options = options})
end

function QDialogTeamUp:viewAnimationEndHandler()
	self._isEnd = true
	self._animationManager:disconnectScriptHandler()
end

function QDialogTeamUp:_onTriggerClose()
	if self._guidanceIndex ~= 0 then return end

    -- 埋点 第一关副本点击
    if self.unOldlockLevel == 1 then
        app:triggerBuriedPoint(20510)
    elseif self.unOldlockLevel == 2 then
        app:triggerBuriedPoint(20700)
    elseif self.unOldlockLevel == 3 then
        app:triggerBuriedPoint(20770)
    elseif self.unOldlockLevel == 4 then
        app:triggerBuriedPoint(20890)
    end

    self:removeAllScheduler()
  	self:clearEffect()
  	
  	app.tip:checkUnlock(self.unNewlockLevel, self.unOldlockLevel) -- The process for check unlock is already move to QTips  
  	self._ccbOwner:onChoose()
end

function QDialogTeamUp:removeAllScheduler()
	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	if self._timeScheduler1 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler1)
		self._timeScheduler1 = nil
	end
	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QDialogTeamUp:_backClickHandler()
	if self._isEnd == false then 
		return 
	end
    self:_onTriggerClose()
end

return QDialogTeamUp