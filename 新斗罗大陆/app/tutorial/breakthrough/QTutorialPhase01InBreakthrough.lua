local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01InBreakthrough = class("QTutorialPhase01InBreakthrough", QTutorialPhase)

local QUIDialogBreakthrough = import("...ui.dialogs.QUIDialogBreakthrough")
local QUIDialogHeroEquipmentDetail = import("...ui.dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroEquipmentEvolution = import("...ui.widgets.QUIWidgetHeroEquipmentEvolution")

function QTutorialPhase01InBreakthrough:start()
	self._stage:enableTouch(handler(self, self._onTouch))
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname ~= "QUIPageEmpty"  then
	  app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	--标志副本引导完成
	local stage = app.tutorial:getStage()
	stage.forced = 5
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	local hero = remote.herosUtil:getHeroByID(1001)
	if hero == nil or hero.breakthrough > 0 then
		local stage = app.tutorial:getStage()
		stage.breakth = 1
		app.tutorial:setStage(stage)
		app.tutorial:setFlag(stage)
    	self:finished()
    end

	local value = remote.herosUtil:checkHerosBreakthroughByID(1001)
	if value == false or remote.user.money < 1500 then
		app:getClient():guidanceRequest(401, function()end)
	end

	self.equNum = 0
	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	self:stepManager()
end

function QTutorialPhase01InBreakthrough:stepManager()
	if self._step == 0 then
		self:startGuide()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openScaling()
	elseif self._step == 4 then
		self:_openHero()
	elseif self._step == 5 then
		self:next()
	elseif self._step == 6 then
		self:_openEquipment()
	elseif self._step == 7 then
		self:_clickEquBtn()
	elseif self._step == 8 then
		self:_closeBreakSuccess()
	end
end

function QTutorialPhase01InBreakthrough:startGuide()

	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("401")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01InBreakthrough:chooseNextStage()
    self:clearDialgue()

    -- 数据埋点
    app:triggerBuriedPoint(20900)

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog and self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
		self._step = 7
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideClickEquBtn()
		end, 1)
	elseif self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self._step = 2
		self:_guideClickScaling()
	else
		self:_guideClickMainPage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01InBreakthrough:_guideClickMainPage()
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

function QTutorialPhase01InBreakthrough:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickScaling()
	end,0.5)
end

--引导玩家点击扩展标签
function QTutorialPhase01InBreakthrough:_guideClickScaling()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if page._scaling._DisplaySideMenu then
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

function QTutorialPhase01InBreakthrough:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()

    -- 数据埋点
    app:triggerBuriedPoint(20910)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01InBreakthrough:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InBreakthrough:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()

    -- 数据埋点
    app:triggerBuriedPoint(20920)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01InBreakthrough:_guideClickHeroFrame()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- self.hero = self._dialog._page:getVirtualFrames()[1]

	self.heros = self._dialog._datas
	for index, actorId in ipairs(self.heros) do
		if actorId == 1001 then
			self._dialog:runTo(1001)
		end
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
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

		local heroFrame= self._dialog._listView:getItemByIndex(self.upGradeHeroNum)
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
	end, 0.5)
end

function QTutorialPhase01InBreakthrough:next()
	self._handTouch:removeFromParent()
	self._dialog:selectHeroByActorId(self.heros[self.upGradeHeroNum])

    -- 数据埋点
    app:triggerBuriedPoint(20930)

	self:_clearDialgue()
end

function QTutorialPhase01InBreakthrough:_clearDialgue()
    self:clearDialgue()
	self:_wearEqu()
end

function QTutorialPhase01InBreakthrough:_wearEqu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquipment()
	end, 1.5)
end

function QTutorialPhase01InBreakthrough:guideClick()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquipment()
	end, 0.5)
end

--引导玩家点击装备
function QTutorialPhase01InBreakthrough:_guideClickEquipment()
	self:clearSchedule()

	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogEquipmentBreakthroughSuccess" then
		dialog:_onTriggerClose()
	end

	self._heroDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self._heroDialog == nil or self._heroDialog._equipBox == nil then --如果获取界面失败 则直接跳转到完成
		app.tutorial._runingStage:jumpFinished()
		self:finished()
		return
	end

	self._heroUIModel = remote.herosUtil:getUIHeroByID(1001)
	for i = 1, #self._heroDialog._equipBox, 1 do
		local equipmentInfo = self._heroUIModel:getEquipmentInfoByPos(self._heroDialog._equipBox[i]:getType())
		if equipmentInfo ~= nil and equipmentInfo.state == self._heroUIModel.EQUIPMENT_STATE_BREAK and i > self.equNum then
			self.equNum = i
			self:waitClick()
			return
		end
	end

	self:finished()
end

function QTutorialPhase01InBreakthrough:waitClick()
	self._CP = self._heroDialog._equipBox[self.equNum]._ccbOwner.btn_touch:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._heroDialog._equipBox[self.equNum]._ccbOwner.btn_touch:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)

	local direction = "up"
	if self.equNum == 1 or self.equNum == 3 then
		direction = "right"
	end
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "请点击装备", direction = direction})
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "选择一件装备", direction = direction})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end
--打开装备信息页面
function QTutorialPhase01InBreakthrough:_openEquipment()
	self._handTouch:removeFromParent()
	if self._heroDialog ~= nil then
		self._heroDialog._equipBox[self.equNum]:_onTriggerTouch()
	end

    -- 数据埋点
    if self.equNum == 2 then
    	app:triggerBuriedPoint(20940)
	elseif self.equNum == 3 then
    	app:triggerBuriedPoint(20960)
	elseif self.equNum == 4 then
    	app:triggerBuriedPoint(20980)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquBtn()
	end, 0.1)
end

--引导玩家点击装备按钮
function QTutorialPhase01InBreakthrough:_guideClickEquBtn()
	self:clearSchedule()
	self.dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self.dialog._evolution._ccbOwner.btn_break:convertToWorldSpaceAR(ccp(0, 10))
	self._size = self.dialog._evolution._ccbOwner.btn_break:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InBreakthrough:_clickEquBtn()
	self._handTouch:removeFromParent()

    -- 数据埋点
    if self.equNum == 2 then
    	app:triggerBuriedPoint(20950)
	elseif self.equNum == 3 then
    	app:triggerBuriedPoint(20970)
	elseif self.equNum == 4 then
    	app:triggerBuriedPoint(20990)
	end

	self.dialog._evolution:_onTriggerEvolution()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_showBreakSuccess()
	end, 1)
end
function QTutorialPhase01InBreakthrough:_showBreakSuccess()
	self:clearSchedule()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

--引导玩家关闭突破成功界面
function QTutorialPhase01InBreakthrough:_guideClickConfrimBtn()
 	self:clearDialgue()
	
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01InBreakthrough:_closeBreakSuccess()
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog then
		self._dialog:_onTriggerClose()
	end

	self._step = 5
	self:guideClick()
end

function QTutorialPhase01InBreakthrough:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

function QTutorialPhase01InBreakthrough:_nodeRunAction(posX,posY)
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

function QTutorialPhase01InBreakthrough:createDialogue()
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

function QTutorialPhase01InBreakthrough:_onTouch(event)
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


function QTutorialPhase01InBreakthrough:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01InBreakthrough:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01InBreakthrough
