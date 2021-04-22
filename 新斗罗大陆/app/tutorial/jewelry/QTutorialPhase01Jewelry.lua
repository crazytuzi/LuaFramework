--
-- Author: Your Name
-- Date: 2015-09-01 19:50:35
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Jewelry = class("QTutorialPhase01Jewelry", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01Jewelry:start()
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
	self._equipIndex = 5
	self._wordIndex = "1901"
	local unlockType = UNLOCK_TUTORIAL_TIPS_TYPE.unlockBadge
	if stage.jewelry == 0 then
		stage.jewelry = 1
		app:getClient():guidanceRequest(1901, function()end)
	elseif stage.jewelry == 1 then
		stage.jewelry = 2
		self._equipIndex = 6
		unlockType = UNLOCK_TUTORIAL_TIPS_TYPE.unlockGad
		self._wordIndex = "3401"
		app:getClient():guidanceRequest(3401, function()end)
	end
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)


   	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(unlockType)
	else
		app.tip:addUnlockTips(unlockType)
	end

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01Jewelry:stepManager()
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
		self:_clickEvolutionBtn()
	elseif self._step == 8 then
		self:_closeEvolutionDialog()
	elseif self._step == 9 then
		self:_startTutorialStrengthen()
	elseif self._step == 10 then
		self:_clickStrengthenBtn()
	elseif self._step == 11 then
		self:_clickStrengthen()
	elseif self._step == 12 then
		self:_finishTutorial()
	end
end

--引导开始
function QTutorialPhase01Jewelry:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord(self._wordIndex)
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Jewelry:chooseNextStage()
    self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogHeroInformation" then
		self._step = 5
		self:_chooseHelp()
	elseif self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self._step = 2
		self:_guideClickHero()
	else
		self._step = 1
		self:_guideClickScaling()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01Jewelry:_guideClickScaling()
	--  self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回主界面", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Jewelry:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01Jewelry:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if page._scaling._DisplaySideMenu then
		self._step = self._step + 1
		self:_guideClickHeroFrame()
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

function QTutorialPhase01Jewelry:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01Jewelry:_guideClickHeroFrame()
	 self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01Jewelry:_openCopy()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBattle()
	end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01Jewelry:_guideClickBattle()
	self:clearSchedule()
	self.heros = self._dialog._datas
	for k, value in ipairs(self.heros) do
		if remote.herosUtil:getHeroByID(value) ~= nil then
			self.heroIndex = k
			break
		end
	end
	self._dialog._listView:startScrollToIndex(self.heroIndex, false, 100, function ()
		local heroFrame = self._dialog._listView:getItemByIndex(self.heroIndex)
		if heroFrame then
			self._CP = heroFrame._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
			self._size = heroFrame._ccbOwner.node_size:getContentSize()
			-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "选择魂师", direction = "right"})
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		end
	end)
end

function QTutorialPhase01Jewelry:_next()
	self._handTouch:removeFromParent()
	self._dialog:selectHeroByActorId(self.heros[self.heroIndex])
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_chooseHelp()
	end, 0.5)
end

function QTutorialPhase01Jewelry:_chooseHelp()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._equipBox[self._equipIndex]._ccbOwner.btn_touch:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._equipBox[self._equipIndex]._ccbOwner.btn_touch:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "请点击装备", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Jewelry:_clickHelp()
	self._handTouch:removeFromParent()
	self._dialog._equipBox[self._equipIndex]:_onTriggerTouch()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		if self._equipIndex == 5 then
			self:_tutorialClickEvolutionBtn()
		else
			self:_finishTutorial()
		end
	end, 0.5)
end

function QTutorialPhase01Jewelry:_tutorialClickEvolutionBtn()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	local level = self._dialog._evolution._itemNewConfig.level or 0
	local heroInfo = remote.herosUtil:getHeroByID(self._dialog._evolution._actorId)
	if level > heroInfo.level then
		self:_jumpToEnd()
		return 
	end

	self._CP = self._dialog._evolution._ccbOwner.btn_break:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._evolution._ccbOwner.btn_break:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击突破", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Jewelry:_clickEvolutionBtn()
	self._handTouch:removeFromParent()
	self._dialog._evolution:_onTriggerEvolution()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_tutorialCloseEvolutionDialog()
	end, 2)
end

function QTutorialPhase01Jewelry:_tutorialCloseEvolutionDialog()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01Jewelry:_closeEvolutionDialog()
	if self._dialog == nil then
		self:_jumpToEnd()
		return 
	end

	self._dialog:_onTriggerClose()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:waitTalk()
	end, 0.5)
end

function QTutorialPhase01Jewelry:waitTalk()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("1903")
    printTable(self._tutorialInfo)
    self:createDialogue()
end

function QTutorialPhase01Jewelry:_startTutorialStrengthen()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local position = self._dialog._ccbOwner.tab_strong:convertToWorldSpaceAR(ccp(0,0))
	self._CP = ccp(position.x-53, position.y-35)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击强化标签", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y+10)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Jewelry:_clickStrengthenBtn()
	self._handTouch:removeFromParent()
	self._dialog:_onTriggerTabStrong()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_tutorialClickStrengthenBtn()
	end, 0.5)
end

function QTutorialPhase01Jewelry:_tutorialClickStrengthenBtn()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._equipmentStrengthen._ccbOwner.click_btn2:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._equipmentStrengthen._ccbOwner.click_btn2:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击强化", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Jewelry:_clickStrengthen()
	self._handTouch:removeFromParent()
	self._dialog._equipmentStrengthen:_onDownHandler(2)
	self._dialog._equipmentStrengthen:_onUpHandler(2)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:waitTalk2()
	end, 0.5)
end

function QTutorialPhase01Jewelry:waitTalk2()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("1905")
    self:createDialogue()
end

function QTutorialPhase01Jewelry:_finishTutorial()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Jewelry:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Jewelry:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Jewelry:createDialogue()
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

function QTutorialPhase01Jewelry:_onTouch(event)
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

function QTutorialPhase01Jewelry:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Jewelry:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Jewelry

