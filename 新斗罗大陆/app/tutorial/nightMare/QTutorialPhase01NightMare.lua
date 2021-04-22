-- @Author: xurui
-- @Date:   2016-09-02 15:25:57
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-02-24 10:04:10
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01NightMare = class("QTutorialPhase01NightMare", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01NightMare:start()
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
	stage.night = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	self:stepManager()

end
--步骤管理
function QTutorialPhase01NightMare:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:clickConvey()
	elseif self._step == 2 then
		self:guideNightMare()
	elseif self._step == 3 then
		self:clickNightMare()
	elseif self._step == 4 then
		self:guideMonster()
	elseif self._step == 5 then
		self:clickMonster()
	elseif self._step == 6 then
		self:clickBattle()
	end
end

--引导开始
function QTutorialPhase01NightMare:_guideStart()
	self:clearSchedule()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
		self._CP = self._dialog._currentPage:getLastHead():convertToWorldSpaceAR(ccp(0,0))
		self._size = {width = 100, height = 100}
		self._perCP = ccp(display.width/2, display.height/2)
		-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击传送门", direction = "left"})
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.5)
end

function QTutorialPhase01NightMare:clickConvey()
	self._handTouch:removeFromParent()
	self._dialog:onTriggerBackHandler()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:sayWord1()
	end, 5.5)
end 

function QTutorialPhase01NightMare:sayWord1()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("3701")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01NightMare:guideNightMare()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self._dialog._nightMap[11] == nil then
		self:_jumpToEnd()
	end

	self._CP = self._dialog._nightMap[11]._ccbOwner.btn_click:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._nightMap[11]._ccbOwner.btn_click:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "有敌人！准备战斗！", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01NightMare:clickNightMare()
	self._handTouch:removeFromParent()
	self._dialog._nightMap[11]:_onTriggerClick()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:sayWord2()
	end, 0.5)
end

function QTutorialPhase01NightMare:sayWord2()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("3703")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01NightMare:guideMonster()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.virtualFrames = self._dialog._virtualFrames[1].widget._infoWidget1
	self._CP = self.virtualFrames._ccbOwner.btn_fight:convertToWorldSpaceAR(ccp(0,0))
	self._size = self.virtualFrames._ccbOwner.btn_fight:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "开始战前准备", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01NightMare:clickMonster()
	self._handTouch:removeFromParent()
	self.virtualFrames:_onTriggerFighter()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:guideBattle()
	end,0.5)
end

function QTutorialPhase01NightMare:guideBattle()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = page._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_battle:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "我们上！", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01NightMare:clickBattle()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog._ccbOwner.btn_battle:setEnabled(false)
	self._CP = nil
	scheduler.performWithDelayGlobal(function()
		dialog:_onTriggerFight()
	end, 0)

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01NightMare:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

function QTutorialPhase01NightMare:createDialogue()
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

function QTutorialPhase01NightMare:_onTouch(event)
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

function QTutorialPhase01NightMare:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01NightMare:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01NightMare
