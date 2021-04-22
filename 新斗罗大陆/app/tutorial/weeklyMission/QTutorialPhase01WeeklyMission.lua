-- @Author: liaoxianbo
-- @Date:   2019-11-24 15:19:03
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-19 18:09:03

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01WeeklyMission = class("QTutorialPhase01WeeklyMission", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01WeeklyMission:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}
    print("QTutorialPhase01WeeklyMission:start()")
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end
   	self._stageType = 1
   	local UnlockTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockWeeklyMission

	local stage = app.tutorial:getStage()
	stage.weeklyMission = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UnlockTips)
    else
        app.tip:addUnlockTips(UnlockTips)
    end
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, UNLOCK_DELAY_TIME + 0.5)
end
--步骤管理
function QTutorialPhase01WeeklyMission:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_guideClickMainpage()
	elseif self._step == 3 then
		self:_backMainPage()
	elseif self._step == 4 then
		self:_guideClickScaling()
	elseif self._step == 5 then
		self:_openScaling()
	elseif self._step == 6 then
		self:_openTask()
	elseif self._step == 7 then
		self:openTaskDialog()
	elseif self._step == 8 then
		self:_guideClickWeeklyTaskBtn()
	elseif self._step == 9 then
		self:_onClickWeeklyTag()		
	elseif self._step == 10 then
		self:endTutorial()
	end
end

function QTutorialPhase01WeeklyMission:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("14001")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01WeeklyMission:chooseNextStage()
    self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if remote.godarm:checkGodArmUnlock() then
		if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
			self._step = 3
			self:_guideClickTask()
		else
			self._step = 2
			self:_guideClickMainpage()
		end
	else

		if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
				(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
			self._step = 5
			self:_guideClickTaskScaling()
		else
			self._step = 4
			self:_guideClickScaling()
		end
	end


end 

function QTutorialPhase01WeeklyMission:_guideClickMainpage()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01WeeklyMission:_backMainPage()
    self:clearDialgue()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickTask()
	end, 0.5)
end


function QTutorialPhase01WeeklyMission:_guideClickTask()
	self._step = 6
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	local widgetIcon = page._pageMainMenuIcon._iconWidgets[1].node_task
	if widgetIcon == nil then
		widgetIcon = page._pageMainMenuIcon._iconWidgets[2].node_task
	end
	if widgetIcon == nil then
		self:_jumpToEnd()
		return
	end

	self._CP = widgetIcon._ccbOwner.btn_activity:convertToWorldSpaceAR(ccp(0,0))
	self._size = widgetIcon._ccbOwner.btn_activity:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--引导玩家点击扩展标签
function QTutorialPhase01WeeklyMission:_guideClickScaling()
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

function QTutorialPhase01WeeklyMission:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickTaskScaling()
	end,0.5)
end


function QTutorialPhase01WeeklyMission:_guideClickTaskScaling()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._scaling._DisplaySideMenu then
		self._step = self._step + 1
		self:_guideClickTaskFrame()
		return 
	end
	self._CP = page._scaling._ccbOwner.button_scaling:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.button_scaling:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入菜单", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01WeeklyMission:_openTask()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickTaskFrame()
	end,0.5)
end

--引导玩家点击任务头像
function QTutorialPhase01WeeklyMission:_guideClickTaskFrame()
	 self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_task:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_task:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看任务", direction = "left"})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01WeeklyMission:openTaskDialog()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onButtondownSideMenuTask()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord2()
	end,0.5)
end


function QTutorialPhase01WeeklyMission:_sayWord2()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("14002")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01WeeklyMission:_guideClickWeeklyTaskBtn()
    self:clearDialgue()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = dialog._ccbOwner.node_weekly:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner.tab_weekly:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)

end


function QTutorialPhase01WeeklyMission:_onClickWeeklyTag()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog:_onTriggerWeekly()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:endTutorial()
	end, 0.5)	
end

function QTutorialPhase01WeeklyMission:endTutorial()
	--self._handTouch:removeFromParent()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01WeeklyMission:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01WeeklyMission:_nodeRunAction(posX,posY)
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

function QTutorialPhase01WeeklyMission:createDialogue()
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

function QTutorialPhase01WeeklyMission:_onTouch(event)
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

function QTutorialPhase01WeeklyMission:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01WeeklyMission:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01WeeklyMission