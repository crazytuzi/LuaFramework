--
-- Author: Your Name
-- Date: 2016-01-24 11:39:47
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Activity = class("QTutorialPhase01Activity", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01Activity:start()
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
	stage.activity = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 1
	self._perCP = ccp(display.width/2, display.height/2)

	local weekday = tonumber(q.date("%w", q.serverTime()-(remote.user.c_systemRefreshTime*3600)))
	self._unlockType = UNLOCK_TUTORIAL_TIPS_TYPE.unlockSapientialTrial
	if weekday == 1 or weekday == 3 or weekday == 5 then
		self._unlockType = UNLOCK_TUTORIAL_TIPS_TYPE.unlockStrengthTrial
	end
    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(self._unlockType)
    else
        app.tip:addUnlockTips(self._unlockType)
    end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end
--步骤管理
function QTutorialPhase01Activity:stepManager()
	if self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_guideClickScaling()
	elseif self._step == 3 then
		self:_openScaling()
	elseif self._step == 4 then
		self:_openHero()
	elseif self._step == 5 then
		self:_openInstence()
	end
end

function QTutorialPhase01Activity:chooseNextStage()
    self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 3
		self:_guideClickHero()
	else
		self._step = 2
		self:_guideClickScaling()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01Activity:_guideClickScaling()
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

function QTutorialPhase01Activity:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01Activity:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["time_node"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (-moveDistance.x + display.cx)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._CP = page._ccbOwner.btn_time_machine:convertToWorldSpaceAR(ccp(0,0))
		self._size = page._ccbOwner.btn_time_machine:getContentSize()
		-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入试炼宝屋", direction = "up"})
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x-10, self._CP.y+50)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01Activity:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTimeMachine()
	
    -- 数据埋点
	app:triggerBuriedPoint(21440)

	-- self._schedulerHandler = scheduler.performWithDelayGlobal(function()
	-- 	self:_openInstence()
	-- end,0.5)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickbtnByType()
	end,0.5)	
end
function QTutorialPhase01Activity:_guideClickbtnByType()
	self:clearSchedule() 
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_strengthen:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._ccbOwner.btn_strengthen:getContentSize()
	if self._unlockType == UNLOCK_TUTORIAL_TIPS_TYPE.unlockSapientialTrial then
		self._CP = self._dialog._ccbOwner.btn_intellect:convertToWorldSpaceAR(ccp(0, 0))
		self._size = self._dialog._ccbOwner.btn_intellect:getContentSize()
	end
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true,pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)

end
function QTutorialPhase01Activity:_openInstence()
	self._handTouch:removeFromParent()
	if self._unlockType == UNLOCK_TUTORIAL_TIPS_TYPE.unlockSapientialTrial then --打开智慧秘境
		if self._dialog._onTriggerIntellect == nil then
			self:finished()
			return
		end

		self._dialog:_onTriggerIntellect()
	else  -- 打开力量秘境
		if self._dialog._onTriggerStrengthen == nil then
			self:finished()
			return
		end
		self._dialog:_onTriggerStrengthen()
	end

    self:clearSchedule()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Activity:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Activity:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Activity:createDialogue()
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

function QTutorialPhase01Activity:_onTouch(event)
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

function QTutorialPhase01Activity:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Activity:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Activity

