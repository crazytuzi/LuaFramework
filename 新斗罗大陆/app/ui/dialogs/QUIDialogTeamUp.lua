--
-- Author: wkwang
-- Date: 2014-07-16 15:52:09
--
local QUIDialog = import(".QUIDialog")
local QUIDialogTeamUp = class("QUIDialogTeamUp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
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

function QUIDialogTeamUp:ctor(options)
	local ccbFile = "ccb/Dialog_BattelTeamUp.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, QUIDialogTeamUp._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerGoto1", 	callback = handler(self, QUIDialogTeamUp._onTriggerGoto1)},
		{ccbCallbackName = "onTriggerGoto2", 	callback = handler(self, QUIDialogTeamUp._onTriggerGoto2)},
	}
	QUIDialogTeamUp.super.ctor(self,ccbFile,callBacks,options)
  	self.isAnimation = true
  	self._isEnd = false

	self._effectTime = 1.5
	self._effectTbl = {}
	self._CP = {x = 0, y = 0}
	self._size = CCSize(display.width, display.height)

	self._ccbOwner.tf_level:setString("")
	self._ccbOwner.tf_level_new:setString("")
	self._ccbOwner.tf_energy:setString("")
	self._ccbOwner.tf_energy_new:setString("")
	self._ccbOwner.tf_award:setString("")
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	if options ~= nil then
		self._ccbOwner.tf_level:setString(options.level)
		self._ccbOwner.tf_level_new:setString(options.level_new)
		self._ccbOwner.tf_energy:setString(options.energy)
		self._ccbOwner.tf_energy_new:setString(options.energy_new)
		self._ccbOwner.tf_award:setString("x "..options.award)

		self.unNewlockLevel = options.level_new
    	self.unOldlockLevel = options.level
    	self._callback = options.callback
	end
	
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
    self._animationManager:runAnimationsForSequenceNamed("one")

    self._old_level = options.level
    self:_unlockFunctions(options.level_new)

    app.sound:playSound("battle_level_up")
    
	self._timeScheduler = scheduler.performWithDelayGlobal(function()
    		self._isEnd = true
    	end, 2)
end

function QUIDialogTeamUp:_createTouchNode()
  	self._touchNode = CCNode:create()
    self._touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    self._touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchNode:setTouchSwallowEnabled(true)
    self:getView():addChild(self._touchNode)
	self._touchNode:setTouchEnabled( true )
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QUIDialogTeamUp:viewDidAppear()
	QUIDialogTeamUp.super.viewDidAppear(self)
end

function QUIDialogTeamUp:viewWillDisappear()
    QUIDialogTeamUp.super.viewWillDisappear(self)
    -- self:clearEffect()
	if self._effectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler)
		self._effectScheduler = nil
	end
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

function QUIDialogTeamUp:_onTouch(event)
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

function QUIDialogTeamUp:viewAnimationEndHandler()
	self._animationManager:disconnectScriptHandler()
	self._isEnd = true
	self._firstTime = q.serverTime()

	if self._effectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler)
		self._effectScheduler = nil
	end
end

function QUIDialogTeamUp:_unlockFunctions(level)
	local locked = QStaticDatabase:sharedDatabase():getUnlock()
	local lockedLevels = {}
	local unlockLevels = {}

	local unlockList = {}
	for k, v in pairs(locked) do
					v.isLock = false

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

	for i=self._old_level+1,level do
		for k, v in ipairs(unlockList) do
			if v.team_level and v.team_level >= 0 and v.team_level <= 120 then
				if v.team_level == i and v.show_level_up == 1 then
					v.isLock = false
					if v.key == "UNLOCK_SHOP_2" then
					 	if remote.stores:checkMystoryStore(SHOP_ID.blackShop) == false then
							table.insert(unlockLevels, v)
					 	end
					else
						table.insert(unlockLevels, v)
					end
				elseif v.team_level > i and v.show_level_up == 1 then
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
	local index = 1
	self._guidanceIndex = 0
	-- for i = 1, 2 do	
	for i = 1, 1 do	
		if showLevels[i] then
			self._ccbOwner["forecast" .. i]:setVisible(true)
			if showLevels[i].icon then
	    		self._ccbOwner["unlock"..i]:addChild(CCSprite:createWithTexture(CCTextureCache:sharedTextureCache():addImage(showLevels[i].icon)))
	    	end
			self._ccbOwner["unlock_title_"..i]:setString(showLevels[i].name)
			self._ccbOwner["unlock_dec_"..i]:setString(showLevels[i].description)

			if showLevels[i].isLock then
				self._ccbOwner["unlock_level_"..i]:setString(string.format("%s级开启", showLevels[i].team_level))
			end
			self._ccbOwner["unlock_level_"..i]:setVisible(showLevels[i].isLock)
			self._ccbOwner["node_btn_"..i]:setVisible(showLevels[i].show_go ~= 2 and showLevels[i].isLock == false)

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
	-- if #showLevels == 2 then
	-- 	self._ccbOwner.forecast1:setPositionY(-85)
	-- end

	self._ccbOwner.forecast:setVisible(#showLevels >= 1)
	
	--xurui 检查黑市商店是否开启
	remote.stores:getBlackShopIsUnlock(level)

	if self._guidanceIndex > 0 then
		self:_createTouchNode()
	end
	self:enableTouchSwallowTop()
	self._timeScheduler1 = scheduler.performWithDelayGlobal(function()
			self:checkCanGuidance()
			self:disableTouchSwallowTop()
    	end, 1)
end

function QUIDialogTeamUp:checkCanGuidance()
	if self._guidanceIndex == 0 then return end

	local node = self._ccbOwner["node_tutorial_"..self._guidanceIndex]
	if not node then
		return
	end
	self._CP = node:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._ccbOwner["btn_goto"..self._guidanceIndex]:getContentSize()

    self._timeScheduler2 = scheduler.performWithDelayGlobal(function()
    		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
			node:addChild(self._handTouch)
    	end, 0.5)
end

function QUIDialogTeamUp:getTutorialStated()
	return self._guidanceIndex > 0
end

function QUIDialogTeamUp:checkClickEvent()
	if self._guidanceIndex == 1 then
		self:_onTriggerGoto1()
	elseif self._guidanceIndex == 2 then
		self:_onTriggerGoto1()
	else
		self:_onTriggerConfirm()
	end
end

function QUIDialogTeamUp:_onTriggerConfirm()
    self:_onTriggerClose()
end

function QUIDialogTeamUp:_onTriggerGoto1()
	print("QUIDialogTeamUp:_onTriggerGoto1----")
    if self._guidanceIndex ~= 0 and self._guidanceIndex ~= 1 then return end
    if self._handTouch then
    	self._handTouch:removeFromParent()
    	self._handTouch = nil
    end
    self:openUnlockDialog(1)
end

function QUIDialogTeamUp:_onTriggerGoto2()
	print("QUIDialogTeamUp:_onTriggerGoto2----")
    if self._guidanceIndex ~= 0 and self._guidanceIndex ~= 2 then return end
    if self._handTouch then
    	self._handTouch:removeFromParent()
    	self._handTouch = nil
    end
    self:openUnlockDialog(2)
end

function QUIDialogTeamUp:openUnlockDialog(index)
	print("QUIDialogTeamUp:openUnlockDialog--index=",index)
  	local num = tonumber(index) or self._guidanceIndex
  	local unlockInfo = self._unlockInfo[num]
  	print(num)

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

    self:viewAnimationOutHandler()
	local options = unlockInfo.options
	local isShowTanNian = (options and options.isShowTanNian) and options.isShowTanNian or false
	if unlockInfo.event == QTutorialDefeatedGuide.GROW or unlockInfo.event == QTutorialDefeatedGuide.TRAIN then
		options = {actorId = remote.herosUtil:getHaveHero()[1], guideGrow = false,isShowTanNian = isShowTanNian}
	elseif unlockInfo.event == QTutorialDefeatedGuide.GEMSTONE then
		local heroInfos, count = remote.herosUtil:getMaxForceHeros()
		options = {actorId = heroInfos[1].id}
	end
	print("QUIDialogTeamUp:openUnlockDialog--unlockInfo.event=",unlockInfo.event)
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = unlockInfo.event, 
		options = options})
end

function QUIDialogTeamUp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTeamUp:_onTriggerClose()
	if self._guidanceIndex ~= 0 then return end
	if self._isEnd == false then 
		return 
	end
	self:playEffectOut()
end

function QUIDialogTeamUp:viewAnimationOutHandler()
	local callback = self._callback
	app.tip:checkUnlock(self.unNewlockLevel, self.unOldlockLevel)   -- The process for check unlock is already move to QTips
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	local page  = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_checkUnlock()
	page:checkGuiad()
	page:_checkUnlockTutorial()
	page:_checkShopRedTips()

	if self:getOptions().isFromRobot then
		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
	end

	if callback then
		callback()
	end
end

return QUIDialogTeamUp