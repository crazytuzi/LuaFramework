local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Equipment = class("QTutorialPhase01Equipment", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIDialogHeroEquipmentDetail = import("...ui.dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01Equipment.EQUIPMENT_SUCCESS = 4

function QTutorialPhase01Equipment:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()


	local hero = remote.herosUtil:getHeroByID(1001)
	local isBreakEqu = true
	if hero and hero.equipments then
		for _, equipment in pairs(hero.equipments) do
			if equipment.itemId == 19901 then
				isBreakEqu = false
				break
			end
		end
	end
	if hero == nil or hero.breakthrough > 0 or isBreakEqu then
		local stage = app.tutorial:getStage()
		stage.forced = QTutorialPhase01Equipment.EQUIPMENT_SUCCESS
		app.tutorial:setStage(stage)
		app.tutorial:setFlag(stage)
    	self:finished()
    	return
    end

    if remote.items:getItemsNumByID(7001) <= 2 or remote.user.money < 500 then
       	app:getClient():guidanceRequest(301, function()end)
    end

	local stage = app.tutorial:getStage()
	if stage.forced == 2 then
		stage.forced = 3
		app.tutorial:setFlag(stage)
	end
	self:stepManager()

end
--步骤管理
function QTutorialPhase01Equipment:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickScaling()
	elseif self._step == 2 then
		self:_openScaling()
	elseif self._step == 3 then
		self:_openHero()
	elseif self._step == 4 then
		self:_openHeroInfo()
	elseif self._step == 5 then
		self:_openEquipment()
	elseif self._step == 6 then
		self:_clickEquBtn()
	elseif self._step == 7 then
		self:_closeBreakSuccess()
	elseif self._step == 8 then
		self:_guideClickBack3()
	end
end
--引导开始
function QTutorialPhase01Equipment:_guideStart()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("301")
    self._distance = "left"
    self:createDialogue()
end

--引导玩家点击扩展标签
function QTutorialPhase01Equipment:_guideClickScaling()
    -- 数据埋点
    app:triggerBuriedPoint(20520)

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

function QTutorialPhase01Equipment:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()

    -- 数据埋点
    app:triggerBuriedPoint(20530)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01Equipment:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Equipment:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()

    -- 数据埋点
    app:triggerBuriedPoint(20540)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01Equipment:_guideClickHeroFrame()
	--  self:clearSchedule()
	self.heros = self._dialog._datas
	local isHave = false
	for index, actorId in ipairs(self.heros) do
		if actorId == 1001 then
			self.upGradeHeroNum = index
			isHave = true
		end
	end

	if isHave == false then
		self:_jumpToEnd()
		return
	end

	local heroFrame = self._dialog._listView:getItemByIndex(self.upGradeHeroNum)
	if heroFrame then
		self._CP = heroFrame._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
		self._size = heroFrame._ccbOwner.node_size:getContentSize()
		-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "选择魂师", direction = "right"})
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	else
		self:_jumpToEnd()
		return
	end
end

function QTutorialPhase01Equipment:_openHeroInfo()
	self._handTouch:removeFromParent()
	-- self.heros[self.upGradeHeroNum]:_onTriggerHeroOverview()
	-- self._dialog:selectHeroByActorId(1001)
	self._dialog:selectHeroByActorId(self.heros[self.upGradeHeroNum])

    -- 数据埋点
    app:triggerBuriedPoint(20550)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquipment()
	end, 0.5)
end

--引导玩家点击装备
function QTutorialPhase01Equipment:_guideClickEquipment()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._equipBox[1]._ccbOwner.btn_touch:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._equipBox[1]._ccbOwner.btn_touch:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "请点击装备", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开装备信息页面
function QTutorialPhase01Equipment:_openEquipment()
	self._handTouch:removeFromParent()
	self._dialog._equipBox[1]:_onTriggerTouch()

    -- 数据埋点
    app:triggerBuriedPoint(20560)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquBtn()
	end, 0.1)
end

--引导玩家点击装备按钮
function QTutorialPhase01Equipment:_guideClickEquBtn()
	--  self:clearSchedule()
	self.dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self.dialog._evolution._ccbOwner.btn_break:convertToWorldSpaceAR(ccp(0, 10))
	self._size = self.dialog._evolution._ccbOwner.btn_break:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "确认突破装备", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10007, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Equipment:_clickEquBtn()
	self._handTouch:removeFromParent()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_EQUIPMENT_BREAKTHROUGH, self._guideClickConfrimBtn, self)

    -- 数据埋点
    app:triggerBuriedPoint(20570)

	self.dialog._evolution:_onTriggerEvolution()
end

-- 引导玩家关闭突破成功界面
function QTutorialPhase01Equipment:_guideClickConfrimBtn()
	--  self:clearSchedule()
    self:clearDialgue()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_EQUIPMENT_BREAKTHROUGH, self._guideClickConfrimBtn, self)
	
	local stage = app.tutorial:getStage()
	stage.forced = QTutorialPhase01Equipment.EQUIPMENT_SUCCESS
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)
	
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}

	-- self._step = self._step + 1
	-- self:_closeBreakSuccess()
end

function QTutorialPhase01Equipment:_closeBreakSuccess()
    -- 数据埋点
    app:triggerBuriedPoint(20580)

	self._dialog:_onTriggerClose()
	self:waitClick6()

end

function QTutorialPhase01Equipment:waitClick6()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("303")
    self:createDialogue()
end


--引导玩家返回魂师总览页面
function QTutorialPhase01Equipment:_guideClickBack3()
    -- 数据埋点
    app:triggerBuriedPoint(20581)

    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Equipment:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Equipment:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Equipment:createDialogue()
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

function QTutorialPhase01Equipment:_onTouch(event)
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

function QTutorialPhase01Equipment:clearSchedule()
	print("clear")
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Equipment:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Equipment
