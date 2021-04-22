-- 
-- Kumo.Wang
-- 西尔维斯大斗魂场引导步骤
--

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01SilvesArena = class("QTutorialPhase01SilvesArena", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01SilvesArena:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

	local stage = app.tutorial:getStage()
	stage.silvesArena = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)
	
	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSilvesArena)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSilvesArena)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end
--步骤管理
function QTutorialPhase01SilvesArena:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickMainpage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_gotoArena() 
	elseif self._step == 4 then
		self:_gotoSubModule()
	elseif self._step == 5 then
		self:_showDescription()
	end
end

--引导开始
function QTutorialPhase01SilvesArena:_guideStart()
	self:clearSchedule()
    self:clearDialgue()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 2
		self:_guideClickArena()
	else
		self._step = 1
		self:_guideClickMainpage()
	end
end 

--引导玩家点击返回主界面按钮
function QTutorialPhase01SilvesArena:_guideClickMainpage()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)

	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

-- 返回主界面
function QTutorialPhase01SilvesArena:_backMainPage()
	self._handTouch:removeFromParent()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickArena()
	end,0.5)
end

--引导玩家点击斗魂场建筑
function QTutorialPhase01SilvesArena:_guideClickArena()
	self:clearSchedule()
    
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.arena_node:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_arena:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)

	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

-- 进入斗魂场
function QTutorialPhase01SilvesArena:_gotoArena()
	self._handTouch:removeFromParent()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onArena()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickSilvesModule()
	end, 0.5)
end

-- 引导玩家点击选择西尔维斯模块
function QTutorialPhase01SilvesArena:_guideClickSilvesModule()
	self:clearSchedule()
    
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local listViewLayout = nil
	if self._dialog.getListViewLayout then
		listViewLayout = self._dialog:getListViewLayout()
	end
	if not listViewLayout then
		self:_jumpToEnd()
	else
		listViewLayout:startScrollToIndex(3, false, 100, function()
			local subModuleItem = listViewLayout:getItemByIndex(3)
			if subModuleItem and subModuleItem.icon then
				self._CP = subModuleItem.icon._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
				self._size = subModuleItem.icon._ccbOwner.node_size:getContentSize()
				self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
				self._handTouch:setPosition(self._CP.x, self._CP.y)
				app.tutorialNode:addChild(self._handTouch)
			end
		end)
	end
end

-- 进入西尔维斯大斗魂场
function QTutorialPhase01SilvesArena:_gotoSubModule()
	self._handTouch:removeFromParent()

	remote.silvesArena:openDialog(handler(self, self._showPlot), handler(self, self._jumpToEnd))
end

-- 开始剧情对话
function QTutorialPhase01SilvesArena:_showPlot()
	self:clearSchedule()
    
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("17000")
	self:createDialogue()
end

-- 最后展示玩法介绍，结束
function QTutorialPhase01SilvesArena:_showDescription()
    self:clearDialgue()
	
	remote.silvesArena:showDescription(function()
		local state = remote.silvesArena:getCurState()
		if state == remote.silvesArena.STATE_PEAK then
			local silvesArenaDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
			if silvesArenaDialog and silvesArenaDialog.class.__cname == "QUIDialogSilvesArenaMain" and silvesArenaDialog:safeCheck() then
				silvesArenaDialog:_updateState(true)
			end
		end
	end)
	self:_guideEnd()
end

function QTutorialPhase01SilvesArena:createDialogue()
	if self._dialogueRight ~= nil and self._distance ~= self._tutorialInfo[1][3] then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
    local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._tutorialInfo[1][1])
	local name = heroInfo.name or "泰奶奶"
	self._word = self._tutorialInfo[1][4] or ""
	self._distance = self._tutorialInfo[1][3]
	self._avatarKey = self._tutorialInfo[1][2]
	self._isLeft = self._distance == "left" or false
	if self._dialogueRight == nil then
		self._dialogueRight = QUIWidgetTutorialDialogue.new({avatarKey = self._avatarKey, isLeftSide = self._isLeft, text = self._word, sound = self._sound[1], name = name, heroId = heroInfo.id, isSay = true, sayFun = function()
			self._CP = {x = 0, y = 0}
			self._size = {width = display.width*2, height = display.height*2}
		end})
		app.tutorialNode:addChild(self._dialogueRight)
	else
		if self._sound and self._sound[1] then
			self._dialogueRight:updateSound(self._sound[1])
		end
		self._dialogueRight:addWord(self._word)
	end
	table.remove(self._tutorialInfo, 1)
	table.remove(self._sound, 1)
end

function QTutorialPhase01SilvesArena:_guideEnd()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01SilvesArena:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:_guideEnd()
end

function QTutorialPhase01SilvesArena:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight._isSaying == true and self._dialogueRight:isVisible() then
			self._dialogueRight:printAllWord(self._word)
		elseif #self._tutorialInfo > 0 then
			self:createDialogue()
		elseif self._CP ~= nil and event.x >=  self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
			event.y >=  self._CP.y - self._size.height/2 and event.y <= self._CP.y + self._size.height/2  then
			self._step = self._step + 1
			self._perCP = self._CP
			self._CP = nil
			self:stepManager()
		else
			if self._handTouch and self._handTouch.showFocus then
				self._handTouch:showFocus( self._CP )
			end
		end
	end
end

function QTutorialPhase01SilvesArena:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01SilvesArena:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01SilvesArena