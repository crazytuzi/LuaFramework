--
-- Author: xurui
-- Date: 2016-06-12 16:47:21
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01EnterCopy = class("QTutorialPhase01EnterCopy", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01EnterCopy.EQUIPMENT_SUCCESS = 4

function QTutorialPhase01EnterCopy:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	self._copyIndex = 2
	if remote.instance:checkIsPassByDungeonId("wailing_caverns_2") == false then
		self._copyIndex = 2
	elseif remote.instance:checkIsPassByDungeonId("wailing_caverns_3") == false then
		self._copyIndex = 3
	elseif remote.instance:checkIsPassByDungeonId("wailing_caverns_4") == false then
		self._copyIndex = 4
	elseif remote.instance:checkIsPassByDungeonId("wailing_caverns_5") == false then
		self._copyIndex = 5
	end

	self:stepManager()
end
--步骤管理
function QTutorialPhase01EnterCopy:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickBackMainPage()
	elseif self._step == 2 then
		self:_backMainMenu()
	elseif self._step == 3 then
		self:_openInstence()
	elseif self._step == 4 then
		self:_openMap()
	elseif self._step == 5 then
		self:_openCopy()
	elseif self._step == 6 then
		self:_openNext()
	elseif self._step == 7 then
		self:startBattle()
	end
end

function QTutorialPhase01EnterCopy:_guideStart()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if self.firstDialog and self.firstDialog.class.__cname == "QUIDialogInstance" then
		self._step = 4
		self:_guideClickCopy()
	elseif (self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu") then
		self._step = 2
		self:_guideClickInstence()
	else
		self._step = 1
		self:_guideClickBackMainPage()
	end
end

--引导玩家返回魂师总览页面
function QTutorialPhase01EnterCopy:_guideClickBackMainPage()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_home:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回主界面", direction = "down"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EnterCopy:_backMainMenu()
	self._handTouch:removeFromParent()
	self._dialog:_onTriggerHome()

    -- 数据埋点
    if self._copyIndex == 2 then
    	app:triggerBuriedPoint(20590)
    end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickInstence()
	end, 0.5)
end

--引导玩家打开关卡界面
function QTutorialPhase01EnterCopy:_guideClickInstence()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_instance:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_instance:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "继续冒险！", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y + 35
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EnterCopy:_openInstence()
	self._handTouch:removeFromParent()

    -- 数据埋点
    if self._copyIndex == 2 then
    	app:triggerBuriedPoint(20600)
    end

	self._dialog:_onInstance()
	scheduler.performWithDelayGlobal(handler(self, self._guideClickMap), 0.5)
	-- self:_guideClickMap()
end

--引导玩家点击第一个副本
function QTutorialPhase01EnterCopy:_guideClickMap()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- self._copy = page._currentPage._heads[1]
	self._CP = self._dialog._ccbOwner.btn1_normal:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn1_normal:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "继续出发！", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01EnterCopy:_openMap()
	self._handTouch:removeFromParent()
	self._dialog:selectMap(1)

    -- 数据埋点
    if self._copyIndex == 2 then
    	app:triggerBuriedPoint(20610)
    end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickCopy()
	end, 0.5)
end

--引导玩家点击第一个副本
function QTutorialPhase01EnterCopy:_guideClickCopy()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._copy = page._currentPage._heads[self._copyIndex]
	if self._copy == nil then
		self:_jumpToEnd()
		return
	end
	self._CP = self._copy._ccbOwner.btn_head:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._copy._ccbOwner.btn_head:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "有敌人！准备战斗！", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01EnterCopy:_openCopy()
	self._handTouch:removeFromParent()
	self._copy:_onTriggerClick()

    -- 数据埋点
    if self._copyIndex == 2 then
    	app:triggerBuriedPoint(20620)
	elseif self._copyIndex == 3 then
    	app:triggerBuriedPoint(20710)
	elseif self._copyIndex == 4 then
    	app:triggerBuriedPoint(20780)
	elseif self._copyIndex == 5 then
    	app:triggerBuriedPoint(21060)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickNext()
	end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01EnterCopy:_guideClickNext()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = page._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_battle:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "开始战前准备", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EnterCopy:_openNext()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	page:_onTriggerTeam()

    -- 数据埋点
    if self._copyIndex == 2 then
    	app:triggerBuriedPoint(20630)
	elseif self._copyIndex == 3 then
    	app:triggerBuriedPoint(20720)
	elseif self._copyIndex == 4 then
    	app:triggerBuriedPoint(20790)
	elseif self._copyIndex == 5 then
    	app:triggerBuriedPoint(21070)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBattle()
	end, 0.5)
end

function QTutorialPhase01EnterCopy:_guideClickBattle()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = page._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_battle:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "我们上！", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	--  self:_nodeRunAction(self._CP.x - self._perCP.x, self._CP.y - self._perCP.y)
end

function QTutorialPhase01EnterCopy:startBattle()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog._ccbOwner.btn_battle:setEnabled(false)
	self._CP = nil
	scheduler.performWithDelayGlobal(function()
		dialog:_onTriggerFight()
	end, 0)
    -- 数据埋点
    if self._copyIndex == 2 then
    	app:triggerBuriedPoint(20640)
	elseif self._copyIndex == 3 then
    	app:triggerBuriedPoint(20730)
	elseif self._copyIndex == 4 then
    	app:triggerBuriedPoint(20800)
	elseif self._copyIndex == 5 then
    	app:triggerBuriedPoint(21080)
	end
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01EnterCopy:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01EnterCopy:_nodeRunAction(posX,posY)
	self._isMove = true
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveBy:create(0.1, ccp(posX,posY)))
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self._isMove = false
		self._actionHandler = nil
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	self._actionHandler = self._handTouch:runAction(ccsequence)
end

function QTutorialPhase01EnterCopy:createDialogue()
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
		self._dialogueRight = QUIWidgetTutorialDialogue.new({avatarKey = self._avatarKey, isLeftSide = self._isLeft, text = self._word, name = name, heroId = heroInfo.id, isSay = true, sayFun = function()
			self._CP = {x = 0, y = 0}
			self._size = {width = display.width*2, height = display.height*2}
		end})
		self._dialogueRight:setActorImage(self._tutorialInfo[1][2])
		app.tutorialNode:addChild(self._dialogueRight)
	else
		if self._sound and self._sound[1] then
			self._dialogueRight:updateSound(self._sound[1])
		end
		self._dialogueRight:addWord(self._word)
	end
	table.remove(self._tutorialInfo, 1)
end

function QTutorialPhase01EnterCopy:_onTouch(event)
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

function QTutorialPhase01EnterCopy:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01EnterCopy:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01EnterCopy
