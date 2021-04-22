local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01EquipmentEnchant = class("QTutorialPhase01EquipmentEnchant", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogHeroEquipmentDetail = import("...ui.dialogs.QUIDialogHeroEquipmentDetail")

QTutorialPhase01EquipmentEnchant.EQUIPMENT_ENCHANT_SUCCESS = 1

function QTutorialPhase01EquipmentEnchant:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	
	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

	--提前标志完成
	local stage = app.tutorial:getStage()
	stage.enchant = QTutorialPhase01EquipmentEnchant.EQUIPMENT_ENCHANT_SUCCESS
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockEnchant)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockEnchant)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:startTutorial()
	end, 0.5)
end

function QTutorialPhase01EquipmentEnchant:startTutorial()
	self:clearSchedule()

	--不检查是否拥有觉醒材料，向后台请求
	-- local enchantMaterials = remote.items:getAllEnchantMaterial()
	-- if remote.items:getItemsNumByID(50) < 20 or remote.user.money < 100 then
	app:getClient():guidanceRequest(1502, function()end)
	-- end

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogHeroInformation" then
		self._step = 4
		self:_guideClickEquipment()
	elseif self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
		self._step = 5
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			if self.firstDialog._currentTab ~= QUIDialogHeroEquipmentDetail.TAB_MAGIC then 
				self.firstDialog:_onTriggerTabMagic()
			end
			self:_guideClickEquBtn()
		end, 1)
	else
		self:stepManager()
	end
end

--步骤管理
function QTutorialPhase01EquipmentEnchant:stepManager()
	if self._step == 0 then
		self:chooseNextStage()
	elseif self._step == 1 then
		self:_backMainPage()
	elseif self._step == 2 then
		self:_openScaling()
	elseif self._step == 3 then
		self:_openHero()
	elseif self._step == 4 then
		self:_openHeroInfo()
	elseif self._step == 5 then
		self:_openEquipment()
	elseif self._step == 6 then
		self:_clickEnchantBtn()
	elseif self._step == 7 then
		self:_clickEquStrengthenBtn()
	end
end

--引导开始
-- function QTutorialPhase01EquipmentEnchant:_guideStart()
-- 	self._tutorialInfo = app.tutorial:splitTutorialWord("1501")
--     self._distance = "left"
--     self:createDialogue()
-- end

function QTutorialPhase01EquipmentEnchant:chooseNextStage()
    self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self._step = 1
		self:_guideClickScaling()
	else
		self:_guideClickMainPage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01EquipmentEnchant:_guideClickMainPage()
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

function QTutorialPhase01EquipmentEnchant:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickScaling()
	end,0.5)
end

--引导玩家点击扩展标签
function QTutorialPhase01EquipmentEnchant:_guideClickScaling()
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


function QTutorialPhase01EquipmentEnchant:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01EquipmentEnchant:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01EquipmentEnchant:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01EquipmentEnchant:_guideClickHeroFrame()
	--  self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.heros = self._dialog._datas
	self.selectIndex = 1
	for k, actorId in pairs(self.heros) do
		if remote.herosUtil:getHeroByID(actorId) ~= nil then
			self.heroId = actorId
			self.selectIndex = k
			break
		end
	end
	self._dialog._listView:startScrollToIndex(self.selectIndex, false, 100, function ()
		local heroFrame = self._dialog._listView:getItemByIndex(self.selectIndex)
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

function QTutorialPhase01EquipmentEnchant:_openHeroInfo()
	self:clearSchedule()
	self._handTouch:removeFromParent()
	-- self._dialog:selectHeroByActorId(self.heroId)
	self._dialog:selectHeroByActorId(self.heros[self.selectIndex])
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquipment()
	end, 0.5)
end

--引导玩家点击变强标签
-- function QTutorialPhase01EquipmentEnchant:_guideClickStrengthenMaster()
-- 	self:clearSchedule()
-- 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
-- 	self._CP = self._dialog._ccbOwner.bianqiang_normal:convertToWorldSpaceAR(ccp(0,0))
-- 	self._size = self._dialog._ccbOwner.bianqiang_normal:getContentSize()
-- 	self._handTouch = QUIWidgetTutorialHandTouch.new({word = "打开变强界面", direction = "left"})
-- 	self._handTouch:setPosition(self._CP.x, self._CP.y)
-- 	app.tutorialNode:addChild(self._handTouch)
-- end

--打开强化大师信息页面
-- function QTutorialPhase01EquipmentEnchant:_openStrengthen()
-- 	self._handTouch:removeFromParent()
-- 	self._dialog._strengthenMasterStartUp = app.master.ENCHANT_MASTER
-- 	self._dialog:_onTriggerStrengthenMaster()
-- 	self._dialog._strengthenMaster._pageContent:setPositionY(200)
-- 	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
-- 		self:_guideClickEquipment()
-- 	end, 0.1)
-- end

--引导玩家点击装备
function QTutorialPhase01EquipmentEnchant:_guideClickEquipment()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._equipBox[3]._ccbOwner.btn_touch:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._equipBox[3]._ccbOwner.btn_touch:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "请点击装备", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开装备信息页面
function QTutorialPhase01EquipmentEnchant:_openEquipment()
	self._handTouch:removeFromParent()
	self._dialog._equipBox[3]:_onTriggerTouch()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_choseEquEnchant()
	end, 0.1)
end

--引导玩家点击觉醒标签
function QTutorialPhase01EquipmentEnchant:_choseEquEnchant()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local position = self._dialog._ccbOwner.tab_magic:convertToWorldSpaceAR(ccp(0,0))
	self._CP = ccp(position.x-53, position.y-35)
	self._size = self._dialog._ccbOwner.tab_magic:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击觉醒标签", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y+10)
	app.tutorialNode:addChild(self._handTouch)
end

--点击觉醒标签
function QTutorialPhase01EquipmentEnchant:_clickEnchantBtn()
	self._handTouch:removeFromParent()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self._dialog == nil then 
		self:_jumpToEnd()
		return 
	end
	self._dialog:_onTriggerTabMagic()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickEquBtn()
	end, 0.5)
end

--引导玩家点击强化按钮
function QTutorialPhase01EquipmentEnchant:_guideClickEquBtn()
	self:clearSchedule()
	self.dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self.dialog._enchant == nil then
		self:_jumpToEnd()
		return 
	end
	self._CP = self.dialog._enchant._ccbOwner.enchant_btn:convertToWorldSpaceAR(ccp(0, 10))
	self._size = self.dialog._enchant._ccbOwner.enchant_btn:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击觉醒", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--点击强化
function QTutorialPhase01EquipmentEnchant:_clickEquStrengthenBtn()
	self._handTouch:removeFromParent()
	self.dialog._enchant:_onTriggerEnchant()
	self:_backMainMenu()
end

-- function QTutorialPhase01EquipmentEnchant:_guideClickBack3()
--     self._tutorialInfo = app.tutorial:splitTutorialWord("1503")
--     self:createDialogue()
-- end

function QTutorialPhase01EquipmentEnchant:_backMainMenu()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01EquipmentEnchant:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01EquipmentEnchant:_nodeRunAction(posX,posY)
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

function QTutorialPhase01EquipmentEnchant:createDialogue()
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

function QTutorialPhase01EquipmentEnchant:_onTouch(event)
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

function QTutorialPhase01EquipmentEnchant:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01EquipmentEnchant:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01EquipmentEnchant
