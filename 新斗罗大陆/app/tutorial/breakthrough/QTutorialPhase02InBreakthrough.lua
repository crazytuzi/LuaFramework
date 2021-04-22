--
-- Author: wkwang
-- Date: 2014-08-13 16:08:30
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase02InBreakthrough = class("QTutorialPhase02InBreakthrough", QTutorialPhase)

local QUIDialogBreakthrough = import("...ui.dialogs.QUIDialogBreakthrough")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

--步骤开始
function QTutorialPhase02InBreakthrough:start()
	self._stage:enableTouch(handler(self, self._onTouch))

	self._step = 0
    self._tutorialInfo = {}

    if remote.herosUtil:checkHerosBreakthroughByID(1001) == false then
    	self:_jumpToEnd()
    	return
    end

    self:stepManager()
 
end

--步骤管理
function QTutorialPhase02InBreakthrough:stepManager()
	if self._step == 0 then
		self:sayWord()
	elseif self._step == 1 then
		self:_guideClickHeroBreakthrough()
	elseif self._step == 2 then
		self:_openHeroBreakthrough()
	elseif self._step == 3 then
		self:_openBreakthrough()
	elseif self._step == 4 then
		self:_closeBreakSuccess()
	elseif self._step == 5 then
		self:_writeWord()
	elseif self._step == 6 then
		self:_closeBreak()
	elseif self._step == 7 then
		self:_guideClickBack3()
	elseif self._step == 8 then
		self:_backMainMenu()
	elseif self._step == 9 then
		self:_closeHeroBreakthrough()
	elseif self._step == 10 then
		self:_openCopy()
	end
end

function QTutorialPhase02InBreakthrough:sayWord()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("405")
    self._distance = "left"
    self:createDialogue()
end

--引导玩家点击突破按钮
function QTutorialPhase02InBreakthrough:_guideClickHeroBreakthrough()
    -- 数据埋点
    app:triggerBuriedPoint(21000)

    self:clearDialgue()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBreakBtn()
	end, 1.5)
	
end

function QTutorialPhase02InBreakthrough:_guideClickBreakBtn()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	local btn = nil
	if self._dialog and self._dialog.class.__cname == "QUIDialogHeroInformation" then
		btn = self._dialog._ccbOwner.node_breakthrough
		self._size = CCSize(60, 60)
	else
		btn = self._dialog._breakThrough._ccbOwner.btn_break
		self._size = btn:getContentSize()
	end

	self._CP = btn:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._CP.y = self._CP.y+10 -- 66像素的位置会有一条线
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "开始魂师突破", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10008, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end 

function QTutorialPhase02InBreakthrough:_openHeroBreakthrough()
	self._handTouch:removeFromParent()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_HERO_BREAKTHROUGH, self._wordGuide, self)
	if self._dialog and self._dialog.class.__cname == "QUIDialogHeroInformation" then
		self._dialog._equipBox[1]:_onTriggerTouch()
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideClickBreakBtn()
		end, 0.5)
	else
		self._step = 3
		self._dialog._breakThrough:_onTriggerEvolution()
	end

    -- 数据埋点
    app:triggerBuriedPoint(21010)
end

function QTutorialPhase02InBreakthrough:_guideClickBreakthrough()
	self:clearSchedule()

	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_break:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = self._dialog._ccbOwner.btn_break:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击突破", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase02InBreakthrough:_openBreakthrough()
	self._handTouch:removeFromParent()
	
	self._dialog._breakThrough:_onTriggerEvolution()
end

function QTutorialPhase02InBreakthrough:_wordGuide()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_HERO_BREAKTHROUGH, self._wordGuide, self)
	local stage = app.tutorial:getStage()
	stage.breakth = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		-- self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("407")
  --       self:createDialogue()
        
	    -- -- 数据埋点
	    -- app:triggerBuriedPoint(21020)

		self:_confrimHeroBreakSuccess()
	end, 1.5)
end

--引导玩家点击关闭按钮
function QTutorialPhase02InBreakthrough:_confrimHeroBreakSuccess()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase02InBreakthrough:_closeBreakSuccess()
	self:clearSchedule()
    app:triggerBuriedPoint(21011)
	self._dialog._animationStage = "2"
	self._dialog:_onTriggerClose()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_confrimHeroBreak()
	end, 1)
end

--引导玩家点击关闭按钮
function QTutorialPhase02InBreakthrough:_confrimHeroBreak()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._step = self._step + 1
		self._CP = nil
		self._size = nil
		self:_onCloseBreak()
	end, 1.8)
end

function QTutorialPhase02InBreakthrough:_writeWord()
	self:clearSchedule()
	if self._dialog._isEnd == false then
		self._dialog:_onTriggerClose()
	end
	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_onCloseBreak()
	end, 1)
end 

function QTutorialPhase02InBreakthrough:_onCloseBreak()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase02InBreakthrough:_closeBreak()
	self:clearSchedule()
    app:triggerBuriedPoint(21012)
	self._dialog._isEnd = true
	self._dialog:_onTriggerClose()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("407")
	    self:createDialogue()
	end, 0.5)
end

--引导玩家返回魂师总览页面
function QTutorialPhase02InBreakthrough:_guideClickBack3()
    self:clearDialgue()

    -- 数据埋点
    app:triggerBuriedPoint(21020)

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase02InBreakthrough:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

-- 移动到指定位置
function QTutorialPhase02InBreakthrough:_nodeRunAction(posX,posY)
	self._isMove = true
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveBy:create(0.2, ccp(posX,posY)))
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self._isMove = false
		self._actionHandler = nil
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	self._actionHandler = self._handTouch:runAction(ccsequence)
end

function QTutorialPhase02InBreakthrough:createDialogue()
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
		self._dialogueRight:setActorImage(self._tutorialInfo[1][2])
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

function QTutorialPhase02InBreakthrough:_onTouch(event)
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

function QTutorialPhase02InBreakthrough:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase02InBreakthrough:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase02InBreakthrough
