-- @Author: zxs
-- @Date:   2018-09-18 21:11:52
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-11-28 11:37:46
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01FightClub = class("QTutorialPhase01FightClub", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01FightClub:start()
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
	stage.fightClub = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockFightClub)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockFightClub)
    end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01FightClub:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_guideClickMainpage()
	elseif self._step == 3 then
		self:_backMainPage()
	elseif self._step == 4 then
		self:_openFightClub()
	elseif self._step == 5 then
		self:endTutorial()
	end
end

--引导开始
function QTutorialPhase01FightClub:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("4002")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01FightClub:chooseNextStage()
    self:clearDialgue()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 3
		self:_guideClickFightClub()
	else
		self._step = 2
		self:_guideClickMainpage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01FightClub:_guideClickMainpage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01FightClub:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickFightClub()
	end,0.5)
end

--引导玩家点击地狱杀戮场
function QTutorialPhase01FightClub:_guideClickFightClub()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["fight_club_node"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_fight_club"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y + 80
		self._size = page._ccbOwner["btn_fight_club"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5710, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01FightClub:_openFightClub()
	self._handTouch:removeFromParent()
	if not remote.fightClub:checkCanFight() then 
   		self:_jumpToEnd()
        return 
   	end
	remote.fightClub:openDialog()
 
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord()
	end, 0.5)
end

function QTutorialPhase01FightClub:_sayWord()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5709")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01FightClub:endTutorial()
	self:clearDialgue()
	self:_tutorialFinished()
end

function QTutorialPhase01FightClub:_tutorialFinished()
    self:clearSchedule()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01FightClub:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01FightClub:_nodeRunAction(posX,posY)
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

function QTutorialPhase01FightClub:createDialogue()
	if self._dialogueRight ~= nil and self._distance ~= self._tutorialInfo[1][3] then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
    local heroInfo = db:getCharacterByID(self._tutorialInfo[1][1])
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

function QTutorialPhase01FightClub:_onTouch(event)
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

function QTutorialPhase01FightClub:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01FightClub:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01FightClub
