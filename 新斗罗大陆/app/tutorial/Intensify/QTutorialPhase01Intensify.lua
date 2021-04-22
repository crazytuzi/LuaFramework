local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Intensify = class("QTutorialPhase01Intensify", QTutorialPhase)

local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01Intensify.INTENSIFY_SUCCESS = 1

function QTutorialPhase01Intensify:start()
	self._stage:enableTouch(handler(self, self._onTouch))
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	
   	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end
	
    local stage = app.tutorial:getStage()
    stage.intencify = QTutorialPhase01Intensify.INTENSIFY_SUCCESS
    app.tutorial:setStage(stage)
    app.tutorial:setFlag(stage)

	--检查是否拥有新加入的魂师
	local canTutorial = false
	local heros = remote.herosUtil:getHaveHero()
	for _, value in pairs(heros) do
		if value == 1003 then
			canTutorial = true
			break
		end
	end
	if canTutorial == false then
		local stage = app.tutorial:getStage()
		stage.intencify= QTutorialPhase01Intensify.INTENSIFY_SUCCESS
		app.tutorial:setStage(stage)
		app.tutorial:setFlag(stage)

		self:_jumpToEnd()
		return
	end

	--检查是否拥有魂师升级所需的物品，没有则向后台请求
	if remote.items:getItemsNumByID(3) == 0 then
		app:getClient():guidanceRequest(501, function()end)
	end

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	self:stepManager()

end
--步骤管理
function QTutorialPhase01Intensify:stepManager()
	print("self._step = "..self._step)
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_guideClickScaling()
	elseif self._step == 3 then
		self:_openScaling()
	elseif self._step == 4 then
		self:_openHero()
	elseif self._step == 5 then
		self:_openHeroInfo()
	elseif self._step == 6 then
		self:_openHeroIntensify()
	elseif self._step == 7 then
		self:_autoAdd()
	end
end

function QTutorialPhase01Intensify:_guideStart()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("501")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Intensify:chooseNextStage()
    self:clearDialgue()

    -- 数据埋点
    app:triggerBuriedPoint(21200)

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self.firstDialog and self.firstDialog.class.__cname == ".QUIDialogHeroOverview" then
		print("1self.firstDialog.class.__cname = "..self.firstDialog.class.__cname)
		self._step = 4
		self:_guideClickHeroFrame()
	else
		self._step = 2
		self:_guideClickScaling()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01Intensify:_guideClickScaling()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if page._scaling == nil then
		self:_jumpToEnd()
		return
	end

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

function QTutorialPhase01Intensify:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01Intensify:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Intensify:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01Intensify:_guideClickHeroFrame()
	--  self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	local callback = function()
		self.heros = self._dialog._datas
		local isHave = false
		for k, value in ipairs(self.heros) do
			if value == 1003 then
				self.upGradeHeroNum = k
				isHave = true
				break
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
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		else
			self:_jumpToEnd()
		end
	end

	self.hero = self._dialog:getActorIds()
	self.upGradeHeroNum = 1
	local isHave = false
	for i = 1, #self.hero, 1 do
		if self.hero[i] == 1003 then
			self._dialog:runTo(1003, callback)
			isHave = true
			break
		end
	end

	if isHave == false then
		self:_jumpToEnd()
		return
	end
end

function QTutorialPhase01Intensify:_openHeroInfo()
	self._handTouch:removeFromParent()
	self:clearSchedule()
	self._dialog:selectHeroByActorId(1003)
    -- 数据埋点
    app:triggerBuriedPoint(21210)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickIntensify()
	end, 0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01Intensify:_guideClickBack()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_back:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Intensify:_clickBack()
	self._handTouch:removeFromParent()
	self.hero[self.upGradeHeroNum]:_onTriggerBack()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickIntensify()
	end, 0.5)
end

--引导玩家打开魂师升级页面
function QTutorialPhase01Intensify:_guideClickIntensify()
	--  self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_upgrade:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._ccbOwner.tab_upgrade:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "打开升级界面", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Intensify:_openHeroIntensify()
	self._handTouch:removeFromParent()
	self._dialog:_onUpgrade()

    -- 数据埋点
    app:triggerBuriedPoint(21220)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBread()
	end, 0.5)
end

--引导玩家点击面包
function QTutorialPhase01Intensify:_guideClickBread()
	--  self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._upgrade._items[1]._itemBox:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._upgrade._items[1]._itemBox:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击使用道具", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10010, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Intensify:_autoAdd()
	self._handTouch:removeFromParent()
	self._dialog._upgrade._items[1]._ccbOwner.node_btn_state_down:setVisible(true)
	self._dialog._upgrade._items[1]:_eatExpItem()
	self._dialog._upgrade._items[1]:_onUpHandler()

    -- 数据埋点
    app:triggerBuriedPoint(21230)

	self:_finishing()
end

--引导结束
function QTutorialPhase01Intensify:_finishing()
    self:clearDialgue()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Intensify:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Intensify:createDialogue()
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

function QTutorialPhase01Intensify:_onTouch(event)
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

function QTutorialPhase01Intensify:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Intensify:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Intensify:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

return QTutorialPhase01Intensify
