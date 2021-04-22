-- 
-- Author: xurui
-- Date: 2015-08-17 10:41:55
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01UnlockHelp = class("QTutorialPhase01UnlockHelp", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01UnlockHelp:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local dialog2 = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog2 ~= nil then
		if dialog2.class.__cname == "QUIDialogAchieveCard" or dialog2.class.__cname == "QUIDialogTeamUp" or dialog2.class.__cname == "QUIDialogAwardsAlert" then 
	   		self:_jumpToEnd()
	        return
	    else
	    	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		end
	end
	if dialog ~= nil then
		if dialog.class.__cname == "QUIDialogShowHeroAvatar" then 
	   		self:_jumpToEnd()
	        return
    	end		
   	end

   	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockHelper)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockHelper)
	end

	self._isSecond = false
	local stage = app.tutorial:getStage()
	if stage.unlockHelp == 1 then
		stage.unlockHelp = 2
		self._isSecond = true
	else
		stage.unlockHelp = 1
	end
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end,UNLOCK_DELAY_TIME + 0.5)

end
--步骤管理
function QTutorialPhase01UnlockHelp:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_openScaling()
	elseif self._step == 3 then
		self:_openHero()
	elseif self._step == 4 then
		self:_openCopy()
	elseif self._step == 5 then
		self:_next()
	elseif self._step == 6 then
		self:_clickHelp()
	elseif self._step == 7 then
		self:_openInstence()
	end
end
--引导开始
function QTutorialPhase01UnlockHelp:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("1701")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01UnlockHelp:chooseNextStage()
    self:clearDialgue()
	-- self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- if self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogInstance" then
	-- 	self._step = 3
	-- 	self:_guideClickHeroFrame()
	-- elseif self.firstDialog.class.__cname == "QUIPageMainMenu" then
	-- 	self._step = 2
	-- 	self:_guideClickHero()
	-- else
	self._step = 5
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_chooseHelp()
	end, 0.5)
	-- end
end 

--引导玩家点击扩展标签
function QTutorialPhase01UnlockHelp:_guideClickScaling()
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

function QTutorialPhase01UnlockHelp:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01UnlockHelp:_guideClickHero()
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

function QTutorialPhase01UnlockHelp:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onInstance()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01UnlockHelp:_guideClickHeroFrame()
	--  self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._copy = page._currentPage._heads
	self._currentIndex = 1
	for i = 1, #self._copy, 1 do
		if self._copy[i]:getDungeonId() == page._needPassID then
			self._currentIndex = i
		end
	end
	self._CP = self._copy[self._currentIndex]._ccbOwner.btn_head:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._copy[self._currentIndex]._ccbOwner.btn_head:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "继续出发！", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01UnlockHelp:_openCopy()
	self._handTouch:removeFromParent()
	self._copy[self._currentIndex]:_onTriggerClick()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBattle()
	end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01UnlockHelp:_guideClickBattle()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = page._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_battle:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "有敌人！准备战斗！", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UnlockHelp:_next()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	page:_onTriggerTeam()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_chooseHelp()
	end, 0.5)
end

function QTutorialPhase01UnlockHelp:_chooseHelp()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local btn_node = page._widgetHeroArray._ccbOwner.btn_helper
	local words = "点击援助"
	if self._isSecond then
		btn_node = page._widgetHeroArray._ccbOwner.btn_helper2
		words = "点击援助2"
	end
	self._CP = btn_node:convertToWorldSpaceAR(ccp(0,0))
	self._size = btn_node:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = words, direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01UnlockHelp:_clickHelp()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self._isSecond then
		page._widgetHeroArray:onTriggerHelper2()
	else
		page._widgetHeroArray:onTriggerHelper()
	end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_speak()
	end, 0.5)
end

function QTutorialPhase01UnlockHelp:_speak()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("1702")
    self:createDialogue()
end

function QTutorialPhase01UnlockHelp:_openInstence()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01UnlockHelp:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01UnlockHelp:_nodeRunAction(posX,posY)
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

function QTutorialPhase01UnlockHelp:createDialogue()
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

function QTutorialPhase01UnlockHelp:_onTouch(event)
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

function QTutorialPhase01UnlockHelp:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01UnlockHelp:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01UnlockHelp
