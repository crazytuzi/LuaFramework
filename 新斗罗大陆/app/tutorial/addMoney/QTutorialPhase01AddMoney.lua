--
-- Author: Your Name
-- Date: 2015-08-31 14:38:49
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01AddMoney = class("QTutorialPhase01AddMoney", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01AddMoney:start()
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
	stage.addMoney = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	
   	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockAddmoney)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockAddmoney)
	end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)

end
--步骤管理
function QTutorialPhase01AddMoney:stepManager()
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
	-- elseif self._step == 5 then
	-- 	self:_openCopy()
	end
end
--引导开始
function QTutorialPhase01AddMoney:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("1803")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01AddMoney:chooseNextStage()
    self:clearDialgue()

    -- 数据埋点
	app:triggerBuriedPoint(21450)

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local topBar = self.firstPage.topBar:getTopBarStyle()
	local isHaveMoney = false
	for key, value in pairs(topBar) do
		if value == ITEM_TYPE.MONEY and self.firstPage.topBar._bars[value]:isVisible() then
			isHaveMoney = true
			break
		end
	end
	if (self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu") or 
		(self.firstDialog ~= nil and isHaveMoney) then
		self._step = 3
		self:_guideClickHero()
	else
		self._step = 2
		self:_guideClickScaling()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01AddMoney:_guideClickScaling()
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

function QTutorialPhase01AddMoney:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01AddMoney:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- self._CP = page._topRegion[1]._ccbOwner.plus:convertToWorldSpaceAR(ccp(0,0))
	-- self._size = page._topRegion[1]._ccbOwner.plus:getContentSize()
	self._CP = page.topBar:getBarForType(ITEM_TYPE.MONEY)._ccbOwner.plus:convertToWorldSpaceAR(ccp(0,0))
	self._size = page.topBar:getBarForType(ITEM_TYPE.MONEY)._ccbOwner.plus:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入购买界面", direction = "down"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01AddMoney:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- page._topRegion[1]:_onPlus()
	page.topBar:getBarForType(ITEM_TYPE.MONEY):_onPlus()
	
    -- 数据埋点
	app:triggerBuriedPoint(21460)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_openInstence()
	end,0.5)
end

-- --引导玩家点击魂师头像
-- function QTutorialPhase01AddMoney:_guideClickHeroFrame()
-- 	--  self:clearSchedule()
-- 	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
-- 	self._CP = self._dialog._ccbOwner.buy:convertToWorldSpaceAR(ccp(0,0))
-- 	self._size = self._dialog._ccbOwner.buy:getContentSize()
-- 	self._perCP = ccp(display.width/2, display.height/2)
-- 	self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击购买", direction = "left"})
-- 	self._handTouch:setPosition(self._CP.x, self._CP.y)
-- 	app.tutorialNode:addChild(self._handTouch)
-- end

-- --打开关卡页面
-- function QTutorialPhase01AddMoney:_openCopy()
-- 	self._handTouch:removeFromParent()
-- 	self._dialog:_onTriggerBuy()
-- 	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
-- 		self:_openInstence()
-- 	end, 0.5)
-- end

function QTutorialPhase01AddMoney:_openInstence()
    -- self:clearDialgue()
    self:clearSchedule()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01AddMoney:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01AddMoney:_nodeRunAction(posX,posY)
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

function QTutorialPhase01AddMoney:createDialogue()
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

function QTutorialPhase01AddMoney:_onTouch(event)
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

function QTutorialPhase01AddMoney:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01AddMoney:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01AddMoney
