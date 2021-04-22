
--
-- Author: wkwang
-- Date: 2014-08-11 11:22:48
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01InTeamAndDungeon = class("QTutorialPhase01InTeamAndDungeon", QTutorialPhase)

local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01InTeamAndDungeon.ADD_HERO_TEAM = 0.5

function QTutorialPhase01InTeamAndDungeon:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._word = nil
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	-- page:_onTriggerHome()
	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		if dialog ~= nil then
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		end
	end, 0.1)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if page and page.class.__cname == "QUIDialogInstance" then
		self._step = 5
		self:_guideClickInstanceGo()
	else
		self._step = 0
		self:stepManager()
	end
end

function QTutorialPhase01InTeamAndDungeon:stepManager()
	if self._step == 0 then
		self:_dialog1()
	elseif self._step == 1 then
		self:_guideClickMap()
	elseif self._step == 2 then
		self:_openMap()
	elseif self._step == 3 then
		self:_openCopy()
	elseif self._step == 4 then 
		self:_waitClickOther()
	elseif self._step == 5 then
		self:_waitClickOther2()
	elseif self._step == 6 then
		self:_openInstance()
	elseif self._step == 7 then
		self:_next()
	elseif self._step == 8 then
		self:_addHero1ToTeam()
	elseif self._step == 9 then
		self:_addHero2ToTeam()
	elseif self._step == 10 then
		self:startBattle()
	end
end

--引导开始
function QTutorialPhase01InTeamAndDungeon:_dialog1()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("105")
    self._distance = "left"
    self:createDialogue()
end

--引导玩家点击地图按钮
function QTutorialPhase01InTeamAndDungeon:_guideClickMap()
    app:triggerBuriedPoint(20300)
	self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_instance:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = page._ccbOwner.btn_instance:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10004, attack = true, pos = self._CP})
	self._CP.y = self._CP.y + 35
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InTeamAndDungeon:_openMap()
    app:triggerBuriedPoint(20310)
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onInstance()

	self:waitClick2()
end

function QTutorialPhase01InTeamAndDungeon:waitClick2()
	scheduler.performWithDelayGlobal(handler(self, self._guideClickCopy), 0.5)
	-- self:_guideClickCopy()
end

--引导玩家点击第一个副本
function QTutorialPhase01InTeamAndDungeon:_guideClickCopy()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn1_normal:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = self._dialog._ccbOwner.btn1_normal:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01InTeamAndDungeon:_openCopy()
    app:triggerBuriedPoint(20320)
	self._handTouch:removeFromParent()
	self._dialog:selectMap(1)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:closeHeroCard()
	end, 0.5)
end

--引导点击关闭魂师大图
function QTutorialPhase01InTeamAndDungeon:closeHeroCard()
	self._dialog2 = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog2 ~= nil and self._dialog2.class.__cname == "QUIDialogDungeonAside" then 
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self._CP = {x = 0, y = 0}
			self._perCP = ccp(display.width/2, display.height/2)
			self._size = {width = display.width*2, height = display.height*2}
		end, 2+2/3)
	else
		self._step = 5
		self:_guideClickInstanceGo()
		return 
	end
end

function QTutorialPhase01InTeamAndDungeon:_waitClickOther()
	self:clearSchedule()
    app:triggerBuriedPoint(20330)
   	self._dialog2:_backClickHandler()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:closeHeroCard2()
	end, 0.5)
end


--引导点击关闭魂师大图
function QTutorialPhase01InTeamAndDungeon:closeHeroCard2()
	self._dialog2 = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog2 ~= nil and self._dialog2.class.__cname == "QUIDialogDungeonAside" then 
		self._CP = {x = 0, y = 0}
		self._perCP = ccp(display.width/2, display.height/2)
		self._size = {width = display.width*2, height = display.height*2}
	else
		self._step = 5
		self:_guideClickInstanceGo()
		return 
	end
end

function QTutorialPhase01InTeamAndDungeon:_waitClickOther2()
	self:clearSchedule()
   	self._dialog2:_onTriggerClose()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickInstanceGo()
	end, 0.5)
end

--引导玩家点击第一个副本
function QTutorialPhase01InTeamAndDungeon:_guideClickInstanceGo()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._copy = page._currentPage._heads[1]
	self._CP = self._copy._ccbOwner.btn_head:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = self._copy._ccbOwner.btn_head:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10005, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01InTeamAndDungeon:_openInstance()
    app:triggerBuriedPoint(20340)
	self._handTouch:removeFromParent()
	self._copy:_onTriggerClick()
    -- 数据埋点
    -- app:triggerBuriedPoint(27)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBattle()
	end, 1)
end

--引导玩家点击下一步
function QTutorialPhase01InTeamAndDungeon:_guideClickBattle()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = page._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = page._ccbOwner.btn_battle:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "开始战前准备", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InTeamAndDungeon:_next()
    app:triggerBuriedPoint(20350)
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	page:_onTriggerTeam()

    -- 数据埋点
    -- app:triggerBuriedPoint(28)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_chooseHero()
	end, 0.5)
end

function QTutorialPhase01InTeamAndDungeon:_chooseHero()
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	local actorIds = teamVO:getTeamActorsByIndex(1)
	local heroNum = 0
	if not q.isEmpty(actorIds) then
		heroNum = #actorIds
	end
	if heroNum == 2 then
		self._step = 9
		self:_clickBattle()
	elseif heroNum == 1 then
		self._step = 8
		self:guideClickHero2()
	else
		self:guideClickHero1()
	end
end

function QTutorialPhase01InTeamAndDungeon:guideClickHero1()
	--    self:clearSchedule()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- local heros = self._dialog._page:getHeroFrames()
	--  if #heros > 0 then
	if not self._dialog._widgetHeroArray._listViewLayout then
		self:finished()
		return
	end
	self._widget = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(1)
	self._CP = self._widget._ccbOwner.sp_head_bg:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = self._widget._ccbOwner.sp_head_bg:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "选择魂师出战", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10006, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x-4, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	-- else
	--   self:_jumpToEnd()
	-- end
end

function QTutorialPhase01InTeamAndDungeon:_addHero1ToTeam()
    app:triggerBuriedPoint(20360)
	self._handTouch:removeFromParent()
	if self._widget._onTriggerHeroOverview == nil then
		self:_jumpToEnd()
		return
	end

    -- 数据埋点
    -- app:triggerBuriedPoint(29)

	self._widget:_onTriggerHeroOverview()
	self:guideClickHero2()

end

function QTutorialPhase01InTeamAndDungeon:guideClickHero2()
	--    self:clearSchedule()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- local heros = self._dialog._page:getHeroFrames()
	--  if #heros > 0 then
	self._widget = self._dialog._widgetHeroArray
	if #self._widget._items == 1 then
		self._step = 9
		self:_clickBattle()
		return
	end
	self._widget = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(2)
	self._CP = self._widget._ccbOwner.sp_head_bg:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = self._widget._ccbOwner.sp_head_bg:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "选择魂师出战", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	-- else
	--   self:_jumpToEnd()
	-- end
end

function QTutorialPhase01InTeamAndDungeon:_addHero2ToTeam()
    app:triggerBuriedPoint(20370)
	self._handTouch:removeFromParent()
	if self._dialog._widgetHeroArray == nil then
		self:_jumpToEnd()
		return
	end
	
	self._widget = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(2)
	if self._widget._onTriggerHeroOverview == nil then
		self:_jumpToEnd()
		return
	end
	self._widget:_onTriggerHeroOverview()

    -- 数据埋点
    -- app:triggerBuriedPoint(30)

	self:_waitClick()
end

--等待玩家点击后对话消失
function QTutorialPhase01InTeamAndDungeon:_waitClick()
	--  self:clearSchedule()
    self:clearDialgue()
	self:_clickBattle()
end

function QTutorialPhase01InTeamAndDungeon:_clickBattle()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = page._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = page._ccbOwner.btn_battle:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "我们上！", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	--  self:_nodeRunAction(self._CP.x - self._perCP.x, self._CP.y - self._perCP.y)
end

function QTutorialPhase01InTeamAndDungeon:startBattle()
    app:triggerBuriedPoint(20380)
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog._ccbOwner.btn_battle:setEnabled(false)
	self._CP = nil
	scheduler.performWithDelayGlobal(function()
		dialog:_onTriggerFight()
	end, 0)

    -- 数据埋点
    -- app:triggerBuriedPoint(31)

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01InTeamAndDungeon:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

-- 移动到指定位置
function QTutorialPhase01InTeamAndDungeon:_nodeRunAction(posX,posY)
	self._isMove = true
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveBy:create(0.2, ccp(posX,posY)))
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self._isMove = false
		self._actionHandler = nil
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	self._actionHandler = self._handTouch:runAction(ccsequence)
end

function QTutorialPhase01InTeamAndDungeon:createDialogue()
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

function QTutorialPhase01InTeamAndDungeon:_onTouch(event)
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

function QTutorialPhase01InTeamAndDungeon:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01InTeamAndDungeon:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01InTeamAndDungeon
