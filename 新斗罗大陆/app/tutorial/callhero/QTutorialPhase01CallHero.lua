--
-- Author: xurui
-- Date: 2015-06-03 14:32:08
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01CallHero = class("QTutorialPhase01CallHero", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01CallHero.ACHIEVE_SUCCESS = 1

function QTutorialPhase01CallHero:start()
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
   	
   	self._talkId = "1201"
	local stage = app.tutorial:getStage()
	local tutorialTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockHero3
	if stage.call == 0 then
		stage.call = 1
		self._callHeroId = 1003
	elseif stage.call == 1 then
   		self._talkId = "1203"
		stage.call = 2
		self._callHeroId = 1004
		tutorialTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockHero4
	end
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	local heroInfo = remote.herosUtil:getHeroByID(self._callHeroId)
	if heroInfo ~= nil then
		self:finished()
     	return 
	end

	if remote.user.money < 1000 then
		app:getClient():guidanceRequest(1201, function()end)
	end

	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(tutorialTips)
	else
		app.tip:addUnlockTips(tutorialTips)
	end

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME+0.5)

end
--步骤管理
function QTutorialPhase01CallHero:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openScaling()
	elseif self._step == 4 then
		self:_openHero()
	elseif self._step == 5 then
		self:_openCallHero()
	elseif self._step == 6 then
		self:_openCard()
	elseif self._step == 7 then
		self:_closeCard()
	elseif self._step == 8 then
		self:_closeAvatar()
	end
end

--引导开始
function QTutorialPhase01CallHero:_guideStart()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord(self._talkId)
	self._distance = "left"
	self:createDialogue()
end

function QTutorialPhase01CallHero:chooseNextStage()
    self:clearDialgue()

    -- 数据埋点
    if self._callHeroId == 1003 then
    	app:triggerBuriedPoint(21150)
	else
    	app:triggerBuriedPoint(21390)
	end

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self._step = 2
		self:_guideClickScaling()
	else
		self:_guideClickMainPage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01CallHero:_guideClickMainPage()
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

function QTutorialPhase01CallHero:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickScaling()
	end,0.5)
end

--引导玩家点击扩展标签
function QTutorialPhase01CallHero:_guideClickScaling()
    --  self:clearSchedule()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    
	if page._scaling._DisplaySideMenu then
		self._step = self._step + 1
		self:_guideClickHero()
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

function QTutorialPhase01CallHero:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:_onTriggerOffSideMenu()

    -- 数据埋点
    if self._callHeroId == 1003 then
    	app:triggerBuriedPoint(21160)
	else
    	app:triggerBuriedPoint(21400)
	end

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHero()
    end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01CallHero:_guideClickHero()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
    -- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01CallHero:_openHero()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuHero()

    -- 数据埋点
    if self._callHeroId == 1003 then
    	app:triggerBuriedPoint(21170)
	else
    	app:triggerBuriedPoint(21410)
	end

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
   		self:_guideClickHeroFrame()
    end,0.5)
end

--引导玩家点击魂师
function QTutorialPhase01CallHero:_guideClickHeroFrame()
	--  self:clearSchedule()
    self:clearDialgue()

	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- self.heros = self._dialog._page:getVirtualFrames()[1]
	self.hero = self._dialog:getActorIds()
	self.upGradeHeroNum = 1
	for i = 1, #self.hero, 1 do
		if tostring(self.hero[i]) == tostring(self._callHeroId) then
			self._dialog:runTo(self._callHeroId)
		end
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self.heros = self._dialog._datas
		for index, actorId in pairs(self.heros) do
			if actorId == self._callHeroId  then
				self.upGradeHeroNum = index
			end
		end

		local heroFrame = self._dialog._listView:getItemByIndex(self.upGradeHeroNum)
		if heroFrame then
			self._CP = heroFrame._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
			self._size = heroFrame._ccbOwner.node_size:getContentSize()
			self._perCP = ccp(display.width/2, display.height/2)
			-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击召唤魂师", direction = "right"})
			if self._callHeroId == 1003 then
				self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10009, attack = true, pos = self._CP})
			else
				self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10017, attack = true, pos = self._CP})
			end
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		else
			self:_jumpToEnd()
			return
		end
	end, 0.5)
end

function QTutorialPhase01CallHero:_openCallHero()
	self._handTouch:removeFromParent()
	-- self._dialog:selectHeroByActorId(self._callHeroId)
	self._dialog:selectHeroByActorId(self.heros[self.upGradeHeroNum])

    -- 数据埋点
    if self._callHeroId == 1003 then
    	app:triggerBuriedPoint(21180)
	else
    	app:triggerBuriedPoint(21420)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		-- self:_confrimCall()
		self._step = 6
		self:_openCard()
	end,0.5)
end

function QTutorialPhase01CallHero:_confrimCall()
	-- self:clearSchedule()
	-- self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	-- self._CP = self._dialog._ccbOwner.bt_confirm:convertToWorldSpaceAR(ccp(0,0))
	-- self._size = self._dialog._ccbOwner.bt_confirm:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "确认召唤", direction = "left"})
	-- self._handTouch:setPosition(self._CP.x, self._CP.y)
	-- app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01CallHero:_openCard()
	-- self._handTouch:removeFromParent()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
	-- self._dialog:_onTriggerConfirm()

    -- 数据埋点
    if self._callHeroId == 1003 then
    	app:triggerBuriedPoint(21190)
	else
    	app:triggerBuriedPoint(21430)
	end
end

function QTutorialPhase01CallHero:_guideCloseCard()
	self:clearSchedule()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01CallHero:_closeCard()
	-- self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._dialog:_backClickHandler()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideCloseAvatar()
	end, 1.2)
end

function QTutorialPhase01CallHero:_guideCloseAvatar()
	 self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01CallHero:_closeAvatar()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog then
		self._dialog._canCloseDialog = true
		self._dialog:_backClickHandler()
	end

	self:finished()
end

function QTutorialPhase01CallHero:_guideCloseAssistDialog()
	 self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01CallHero:_closeAssistDialog()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._dialog._animationIsDone = true
	self._dialog:_backClickHandler()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_openInstence()
	end, 0.5)
end


function QTutorialPhase01CallHero:_openInstence()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01CallHero:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01CallHero:_nodeRunAction(posX,posY)
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

function QTutorialPhase01CallHero:createDialogue()
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

function QTutorialPhase01CallHero:_onTouch(event)
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

function QTutorialPhase01CallHero:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01CallHero:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01CallHero
