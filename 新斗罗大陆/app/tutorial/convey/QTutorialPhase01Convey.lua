--
-- Author: Your Name
-- Date: 2015-12-15 19:38:14 
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Convey = class("QTutorialPhase01Convey", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01Convey:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}
    self._callHeroId = nil

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	
   	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

	local stage = app.tutorial:getStage()
	stage.convey = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self:stepManager()

end
--步骤管理
function QTutorialPhase01Convey:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideCloseCard()
	-- elseif self._step == 2 then
	-- 	self:_callBackClick()
	end
end

--引导开始
function QTutorialPhase01Convey:_guideStart()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("3001")
	self._distance = "left"
	self:createDialogue()
end

function QTutorialPhase01Convey:_guideCloseCard()
    self:clearDialgue()

    -- 数据埋点
    app:triggerBuriedPoint(21270)

	-- self._schedulerHandler = scheduler.performWithDelayGlobal(function()
	-- 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- 	local node = self._dialog._currentPage:getLastHead()
	-- 	if node == nil then
	--    		self:_jumpToEnd()
	--         return 
	-- 	end
	-- 	self._CP = node:convertToWorldSpaceAR(ccp(0,0))
	-- 	self._size = {width = 100, height = 100}
	-- 	self._perCP = ccp(display.width/2, display.height/2)
	-- 	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击传送门", direction = "left"})
	-- 	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10011, attack = true, pos = self._CP})
	-- 	-- self._handTouch:setPosition(self._CP.x, self._CP.y)
	-- 	node:addChild(self._handTouch)
	-- end, 0.5)

	self:finished()
end

function QTutorialPhase01Convey:_callBackClick()
	self._handTouch:removeFromParent()
	self._dialog:onTriggerBackHandler()
	self:_closeDialog()
end

function QTutorialPhase01Convey:_closeDialog()
    -- 数据埋点
    app:triggerBuriedPoint(21280)

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Convey:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Convey:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Convey:createDialogue()
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

function QTutorialPhase01Convey:_onTouch(event)
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

function QTutorialPhase01Convey:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Convey:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Convey
