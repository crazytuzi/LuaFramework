--
-- Author: xurui
-- Date: 2015-08-01 10:00:53
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Unlock = class("QTutorialPhase01Unlock", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01Unlock:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.cleanBuildLayer == nil then
		self:_jumpToEnd()
		return
	end
	page:cleanBuildLayer()

	self._unlockInfo = {}
	local unlockType = app.tip._unlockHandTouch
	for k, value in pairs(app.tip.unlockTutorialInfo) do
		if value.type == unlockType then
			self._unlockInfo = clone(value)
		end
	end

	local tipInfo = app.tip:getUnlockTutorial()
	if self._unlockInfo.tutorialTip and tipInfo[unlockType] == app.tip.UNLOCK_TUTORIAL_OPEN then
		tipInfo[unlockType] = app.tip.UNLOCK_TUTORIAL_TIP
		app.tip:setUnlockTutorial(tipInfo)

		if app.tip.UNLOCK_TIP_ISTRUE == false then
			app.tip:showUnlockTips(self._unlockInfo.configuration)
		else
			app.tip:addUnlockTips(self._unlockInfo.configuration)
		end
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:stepManager()
		end,UNLOCK_DELAY_TIME + 0.5)
	else
		self:stepManager()
	end
end

--步骤管理
function QTutorialPhase01Unlock:stepManager()
	if self._step == 0 then
		self:_guideClickHero()
	end
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01Unlock:_guideClickHero()
	if self._unlockInfo == nil then
		self:finished()
		return
	end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if not page._ccbOwner[self._unlockInfo.node] then
		self:finished()
		return
	end
	self.moveDistance = page._ccbOwner[self._unlockInfo.node]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(self._unlockInfo.index)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (-self.moveDistance.x + display.cx)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_openInstence()
	end, 0.1)
end

function QTutorialPhase01Unlock:_openInstence()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Unlock:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Unlock:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Unlock:createDialogue()
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

function QTutorialPhase01Unlock:_onTouch(event)
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

function QTutorialPhase01Unlock:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Unlock:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Unlock