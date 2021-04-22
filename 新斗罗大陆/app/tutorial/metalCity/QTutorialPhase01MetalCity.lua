-- @Author: xurui
-- @Date:   2018-08-16 21:11:52
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-12 17:08:51
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01MetalCity = class("QTutorialPhase01MetalCity", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01MetalCity:start()
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
	stage.metal = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMetalCity)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMetalCity)
    end
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, UNLOCK_DELAY_TIME + 0.5)
end
--步骤管理
function QTutorialPhase01MetalCity:stepManager()
	if self._step == 0 then
		self:chooseNextStage()
	elseif self._step == 1 then
		self:_guideClickMainpage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openMetalCity()
	elseif self._step == 4 then
		self:_showTutorialDialog()
	elseif self._step == 5 then
		self:checkToturialAwardDialog()
	elseif self._step == 6 then
		self:_closeTutorialDialog() 
	elseif self._step == 7 then
		self:_closeTutorialDialog2()
	elseif self._step == 8 then
		self:_openSkillInfo() 
	elseif self._step == 9 then 
		self:_clickFight()
	elseif self._step == 10 then
		self:endTutorial()
	end
end

function QTutorialPhase01MetalCity:chooseNextStage()
    self:clearDialgue()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 2
		self:_guideClickMetalCity()
	else
		self._step = 1
		self:_guideClickMainpage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01MetalCity:_guideClickMainpage()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01MetalCity:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickMetalCity()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01MetalCity:_guideClickMetalCity()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	
	local node = "metalCity_node"
	local btn = "btn_metalcity"
	local direction = "up"
	local offsetX = 0
	local offsetY = 0
	self.moveDistance = page._ccbOwner[node]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(5)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (-self.moveDistance.x + display.cx)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner[btn]:convertToWorldSpaceAR(ccp(0,0))
		self._size = page._ccbOwner[btn]:getContentSize()
		self._CP.x = self._CP.x + offsetX
		self._CP.y = self._CP.y + offsetY
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5702, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01MetalCity:_openMetalCity()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	
	remote.metalCity:openDialog({tutorialMetalNum = 0})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord()
	end, 0.5)
end

function QTutorialPhase01MetalCity:_sayWord()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5701")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01MetalCity:_showTutorialDialog()
	self:clearDialgue()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local metalCityInfo = remote.metalCity:getMetalCityMyInfo()
	if metalCityInfo.metalNum > 0 then
		dialog:showTutorialLocateEffect()

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_sayWord2()
		end, 1.5)
	else
		self._step = self._step + 1
		self:checkToturialAwardDialog()
	end
end

function QTutorialPhase01MetalCity:_sayWord2()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5708")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01MetalCity:checkToturialAwardDialog()
	self:clearDialgue()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog:showTutorialAwardDialog()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:waitCloseTutorialDialog()
	end, 0.5)
end

function QTutorialPhase01MetalCity:waitCloseTutorialDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01MetalCity:_closeTutorialDialog()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogAwardsAlert" then
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			dialog._isShowing = false
			dialog:_onTriggerConfirm()
			local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
			page:cleanBuildLayer()
			self._schedulerHandler = scheduler.performWithDelayGlobal(function()
				self:waitCloseTutorialDialog2()
			end, 0.5)
		end, 2)
	elseif dialog and dialog.class.__cname == "QUIDialogMetalCityTutorialDialog" then
		self._step = self._step + 1
		dialog:_onTriggerClose()

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_waitClickSkillInfo()
		end, 0.5)
	end
end

function QTutorialPhase01MetalCity:waitCloseTutorialDialog2()
	self:clearSchedule()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01MetalCity:_closeTutorialDialog2()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog then
		dialog:_onTriggerClose()
	end
	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_waitClickSkillInfo()
	end, 0.5)
end

function QTutorialPhase01MetalCity:_waitClickSkillInfo()
    self:clearDialgue()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local item = dialog:getTutorialItem()
	self._CP = item._ccbOwner.btn_skill_1:convertToWorldSpaceAR(ccp(0,0))
	self._size = item._ccbOwner.btn_skill_1:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5703, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01MetalCity:_openSkillInfo()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog then
		local item = dialog:getTutorialItem()
		item:_onTriggerSkill1({})
	end

	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_METAL_CITY_SKILL_CLOSE, self._closeSkillInfo, self)
end

function QTutorialPhase01MetalCity:_closeSkillInfo()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_METAL_CITY_SKILL_CLOSE, self._closeSkillInfo, self)
	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_waitClickFight()
		end, 0.5)
end

function QTutorialPhase01MetalCity:_waitClickFight()
    self:clearDialgue()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local item = dialog:getTutorialItem()
	self._CP = item._ccbOwner.btn_fight:convertToWorldSpaceAR(ccp(0,0))
	self._size = item._ccbOwner.btn_fight:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = ccp(self._CP.x, self._CP.y)})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01MetalCity:_clickFight()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog then
		local item = dialog:getTutorialItem()
		item:_onTriggerFight()
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_sayEndWord()
		end, 0.5)
end

function QTutorialPhase01MetalCity:_sayEndWord()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5705")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01MetalCity:endTutorial()
	self:clearDialgue()
	self:_tutorialFinished()
end

function QTutorialPhase01MetalCity:_tutorialFinished()
    self:clearSchedule()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01MetalCity:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01MetalCity:_nodeRunAction(posX,posY)
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

function QTutorialPhase01MetalCity:createDialogue()
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

function QTutorialPhase01MetalCity:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight._isSaying == true and self._dialogueRight:isVisible() then
			self._dialogueRight:printAllWord(self._word)
		elseif #self._tutorialInfo > 0 then
			self:createDialogue()
		elseif self._CP ~= nil and event.x >= self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
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

function QTutorialPhase01MetalCity:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01MetalCity:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01MetalCity
