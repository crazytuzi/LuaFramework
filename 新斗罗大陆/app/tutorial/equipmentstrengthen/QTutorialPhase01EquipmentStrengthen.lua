local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01EquipmentStrengthen = class("QTutorialPhase01Equipment", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogHeroEquipmentDetail = import("...ui.dialogs.QUIDialogHeroEquipmentDetail")

QTutorialPhase01EquipmentStrengthen.EQUIPMENT_STRENGTHEN_SUCCESS = 1

function QTutorialPhase01EquipmentStrengthen:start()
	self._stage:enableTouch(handler(self, self._onTouch))
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	
	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockEnhance)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockEnhance)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:startTutorial()
	end, UNLOCK_DELAY_TIME+0.5)
end

function QTutorialPhase01EquipmentStrengthen:startTutorial()
	self:clearSchedule()
	--提前标志完成
	local stage = app.tutorial:getStage()
	stage.strengthen = QTutorialPhase01EquipmentStrengthen.EQUIPMENT_STRENGTHEN_SUCCESS
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	--检查是否拥有强化一次所需的金魂币，没有则向后台请求
	if remote.user.money < 600 then
		app:getClient():guidanceRequest(601, function()end)
	end

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
		self._step = 6
		if self.firstDialog._currentTab ~= QUIDialogHeroEquipmentDetail.TAB_STRONG then 
			self.firstDialog:_onTriggerTabStrong()
		end
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideClickEquBtn()
		end, 1)
	else
		self:stepManager()
	end
end

--步骤管理
function QTutorialPhase01EquipmentStrengthen:stepManager()
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
		self:_openHeroInfo()
	elseif self._step == 6 then
		self:_clickEqu()
	elseif self._step == 7 then
		self:_clickEnhanceBtn()
	elseif self._step == 8 then
		self:_clickEquStrengthenBtn()
	end
end
--引导开始
function QTutorialPhase01EquipmentStrengthen:_guideStart()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("601")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01EquipmentStrengthen:chooseNextStage()
    self:clearDialgue()

    -- 数据埋点
    app:triggerBuriedPoint(21280)

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
function QTutorialPhase01EquipmentStrengthen:_guideClickMainPage()
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

function QTutorialPhase01EquipmentStrengthen:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickScaling()
	end,0.5)
end

--引导玩家点击扩展标签
function QTutorialPhase01EquipmentStrengthen:_guideClickScaling()
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


function QTutorialPhase01EquipmentStrengthen:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()

    -- 数据埋点
    app:triggerBuriedPoint(21290)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01EquipmentStrengthen:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EquipmentStrengthen:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()

    -- 数据埋点
    app:triggerBuriedPoint(21300)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01EquipmentStrengthen:_guideClickHeroFrame()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.hero = self._dialog:getActorIds()

	local maxForceHero = remote.herosUtil:getMaxForceHero() 
	local actorId = maxForceHero.id
	self._dialog:runTo(actorId)

	self.upGradeHeroNum = 1
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self.heros = self._dialog._datas
		local isHave = false
		for k, value in pairs(self.heros) do
			if value == actorId and remote.herosUtil:getHeroByID(actorId) then
				self.upGradeHeroNum = k
				isHave = true
				break
			end
		end
		if isHave == false then
			for k, value in pairs(self.heros) do
				if remote.herosUtil:getHeroByID(value) ~= nil then
					self.upGradeHeroNum = k
					break
				end
			end
		end

		if self.upGradeHeroNum == nil then
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
		end
	end, 0.5)
end

function QTutorialPhase01EquipmentStrengthen:_openHeroInfo()
	self:clearSchedule()
	self._handTouch:removeFromParent()
	self._dialog:selectHeroByActorId(self.heros[self.upGradeHeroNum])

    -- 数据埋点
    app:triggerBuriedPoint(21310)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquipment()
	end, 0.5)
end

--引导玩家点击装备
function QTutorialPhase01EquipmentStrengthen:_guideClickEquipment()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._equipBox[1]._ccbOwner.btn_touch:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._equipBox[1]._ccbOwner.btn_touch:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "请点击装备", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--点击装备
function QTutorialPhase01EquipmentStrengthen:_clickEqu()
	self._handTouch:removeFromParent()
	self._dialog._equipBox[1]:_onTriggerTouch()

    -- 数据埋点
    app:triggerBuriedPoint(21320)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_choseEquEnhance()
	end, 0.1)
end

--引导玩家点击强化标签
function QTutorialPhase01EquipmentStrengthen:_choseEquEnhance()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local position = self._dialog._ccbOwner.tab_strong:convertToWorldSpaceAR(ccp(0,0))
	self._CP = ccp(position.x-53, position.y-35)
	self._size = self._dialog._ccbOwner.tab_strong:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击强化标签", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y+10)
	app.tutorialNode:addChild(self._handTouch)
end

--点击强化标签
function QTutorialPhase01EquipmentStrengthen:_clickEnhanceBtn()
	self._handTouch:removeFromParent()
	self._dialog:_onTriggerTabStrong()

    -- 数据埋点
    app:triggerBuriedPoint(21330)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquBtn()
	end, 0.5)
end

--引导玩家点击强化按钮
function QTutorialPhase01EquipmentStrengthen:_guideClickEquBtn()
	self:clearSchedule()
	self.dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self.dialog._equipmentStrengthen._ccbOwner.stengthen_equ:convertToWorldSpaceAR(ccp(0, 10))
	self._size = self.dialog._equipmentStrengthen._ccbOwner.stengthen_equ:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击强化", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10012, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--点击强化
function QTutorialPhase01EquipmentStrengthen:_clickEquStrengthenBtn()
	self._handTouch:removeFromParent()
	self.dialog._equipmentStrengthen:_onTriggerOneWearMax()

    -- 数据埋点
    app:triggerBuriedPoint(21340)

	self:_backMainMenu()
end

function QTutorialPhase01EquipmentStrengthen:_backMainMenu()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01EquipmentStrengthen:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01EquipmentStrengthen:_nodeRunAction(posX,posY)
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

function QTutorialPhase01EquipmentStrengthen:createDialogue()
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

function QTutorialPhase01EquipmentStrengthen:_onTouch(event)
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

function QTutorialPhase01EquipmentStrengthen:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01EquipmentStrengthen:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01EquipmentStrengthen
