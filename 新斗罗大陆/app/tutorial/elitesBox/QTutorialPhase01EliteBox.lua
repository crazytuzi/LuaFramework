--
-- Author: xurui
-- Date: 2015-06-03 14:32:08
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01EliteBox = class("QTutorialPhase01EliteBox", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01EliteBox.ACHIEVE_SUCCESS = 1

function QTutorialPhase01EliteBox:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog ~= nil then
		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogInstance" then
		self._step = 4
		self:_guideClickHeroFrame()
	elseif self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 2
		self:_guideClickHero()
	else
		self:stepManager()
	end

end
--步骤管理
function QTutorialPhase01EliteBox:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickScaling()
	elseif self._step == 2 then
		self:_openScaling()
	elseif self._step == 3 then
		self:_openHero()
	elseif self._step == 4 then
		self:_openCopy()
	elseif self._step == 5 then
		self:_openHeroInfo()
	elseif self._step == 6 then
		self:_receiveReward()
	end
end
--引导开始
function QTutorialPhase01EliteBox:_guideStart()
	-- self:clearSchedule()
 --    self._tutorialInfo = self:splitWord("1001")
 --    self._distance = "left"
 --    self:createDialogue()
 	self._step = 1
 	self:_guideClickScaling()
end

--引导玩家点击扩展标签
function QTutorialPhase01EliteBox:_guideClickScaling()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回主界面", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EliteBox:_openScaling()
    app:triggerBuriedPoint(21030)
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01EliteBox:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_instance:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_instance:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "继续冒险！", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y + 35
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EliteBox:_openHero()
	self._handTouch:removeFromParent()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog:_onInstance()

    -- 数据埋点
    app:triggerBuriedPoint(21040)
	scheduler.performWithDelayGlobal(handler(self, self._guideClickCopy), 0.5)
	-- self:_guideClickCopy()
end

--引导玩家点击第一个副本
function QTutorialPhase01EliteBox:_guideClickCopy()
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
function QTutorialPhase01EliteBox:_openCopy()
	self._handTouch:removeFromParent()
	self._dialog:selectMap(1)

    -- 数据埋点
    app:triggerBuriedPoint(21041)
	scheduler.performWithDelayGlobal(handler(self, self._guideClickHeroFrame), 0.5)
	-- self:_guideClickHeroFrame()
end

--引导玩家点击魂师头像
function QTutorialPhase01EliteBox:_guideClickHeroFrame()
	--  self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._copy = self._dialog._currentPage._heads[4]

	self._CP = self._copy._chest._ccbOwner.btn_chest:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._copy._chest._ccbOwner.btn_chest:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击领取宝箱", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EliteBox:_openHeroInfo()
	self._handTouch:removeFromParent()
	self._copy:_onTriggerBoxGold()
  	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_ELITE_BOX_SUCCESS, handler(self, self._guideClickOK))
end

--引导玩家点击魂师头像
function QTutorialPhase01EliteBox:_guideClickOK()
    app:triggerBuriedPoint(21050)
  	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_ELITE_BOX_SUCCESS, handler(self, self._guideClickOK))
	local stage = app.tutorial:getStage()
	stage.eliteBox = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01EliteBox:_receiveReward()
	 self:clearSchedule()
	self._dialog._isShowing = false
	self._dialog:_onTriggerConfirm()
    app:triggerBuriedPoint(21051)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:finished()
	end, 0.5)
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01EliteBox:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01EliteBox:_nodeRunAction(posX,posY)
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

function QTutorialPhase01EliteBox:createDialogue()
	if self._dialogueRight ~= nil and self._distance ~= self._tutorialInfo[1][3] then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
	self._word = self._tutorialInfo[1][3] or ""
	self._distance = self._tutorialInfo[1][3]
	self._avatarKey = self._tutorialInfo[1][2]
	self._isLeft = self._distance == "left" or false
	if self._dialogueRight == nil then
		self._dialogueRight = QUIWidgetTutorialDialogue.new({avatarKey = self._avatarKey, isLeftSide = self._isLeft, text = self._word, isSay = true, sayFun = function()
			self._CP = {x = 0, y = 0}
			self._size = {width = display.width*2, height = display.height*2}
		end})
		self._dialogueRight:setActorImage(self._tutorialInfo[1][1])
		app.tutorialNode:addChild(self._dialogueRight)
	else
		if self._sound and self._sound[1] then
			self._dialogueRight:updateSound(self._sound[1])
		end
		self._dialogueRight:addWord(self._word)
	end
	table.remove(self._tutorialInfo, 1)
end

function QTutorialPhase01EliteBox:_onTouch(event)
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


function QTutorialPhase01EliteBox:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01EliteBox:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01EliteBox
