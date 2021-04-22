--
-- Author: Your Name
-- Date: 2014-08-20 18:40:27
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01InTreasure = class("QTutorialPhase01InTreasure", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")

QTutorialPhase01InTreasure.TREASURE_SUCCESS = 2

function QTutorialPhase01InTreasure:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._word = nil
	self._step = 0
    self._tutorialInfo = {}
    
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
    
    --添加一次判断如果有这个魂师了 则直接跳过抽宝箱的新手引导
    self._hero1 = remote.herosUtil:getHeroByID(1002)
    self._hero2 = remote.herosUtil:getHeroByID(1001)
    if self._hero1 ~= nil and self._hero2 ~= nil then
        local stage = app.tutorial:getStage()
        stage.forced = QTutorialPhase01InTreasure.TREASURE_SUCCESS
        app.tutorial:setStage(stage)
        app.tutorial:setFlag(stage)
        self:finished()
        return
    end

    self._perCP = ccp(display.width/2, display.height/2)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, 1)
end
--步骤管理
function QTutorialPhase01InTreasure:stepManager()
	if self._step == 0 then
		self:_dialog1()
	elseif self._step == 1 then
		self:_dialog2()
	elseif self._step == 2 then
		self:_guideClickTreasure()
	elseif self._step == 3 then
		self:_openChest()
	elseif self._step == 4 then
		self:_openSliverChest()
	elseif self._step == 5 then
		self:_openReward()
	elseif self._step == 6 then
		self:_waitClickOther()
	elseif self._step == 7 then
		self:_waitClickOther2()
	elseif self._step == 8 then
		self:_closeReward1()
	elseif self._step == 9 then
		self:openTavernMainPage()
	elseif self._step == 10 then
		self:_openGoldChest()
	elseif self._step == 11 then
		self:_openGoldReward()
	elseif self._step == 12 then
		self:_waitClickOther3()
	elseif self._step == 13 then
		self:_waitClickOther4()
	elseif self._step == 14 then
		self:_closeGoldReward()
	elseif self._step == 15 then
		self:openTavernMainPage2()
	elseif self._step == 16 then
		self:_closeBuy()
	end
end

--引导开始
function QTutorialPhase01InTreasure:_dialog1()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("201")
    QPrintTable(self._sound)
    self._distance = "left"
    self:createDialogue()
end

--引导开始
function QTutorialPhase01InTreasure:_dialog2()
	app:triggerBuriedPoint(20130)
 --    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("204")
 --    self._distance = "left"
 --    self:createDialogue()
    self._step = self._step + 1
	self:stepManager()
end

function QTutorialPhase01InTreasure:_guideClickTreasure()
	app:triggerBuriedPoint(20140)
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_chest:convertToWorldSpaceAR(ccp(0, 0))
	self._CP.y = self._CP.y + 50
	self._size = page._ccbOwner.btn_chest:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "去武魂殿再招募#一点小伙伴吧！", direction = "up"})
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入武魂殿", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10001, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InTreasure:_openChest()
	app:triggerBuriedPoint(20150)
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._onCheast == nil then
		self:_jumpToEnd()
		return
	end

	page:_onCheast()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_chooseWhichChect()
	end, 0.1)
end

function QTutorialPhase01InTreasure:_chooseWhichChect()
  	if self._hero1 == nil and self._hero2 == nil then
  		self:_guideGoldCheast()
  	elseif self._hero1 ~= nil and self._hero2 == nil then
  		self._step = 9
  		self:_clickBuyGoldChest()
  	end
end

--引导点击查看
function QTutorialPhase01InTreasure:_guideGoldCheast()
	self:clearSchedule()
	self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._sliverPanel._ccbOwner.sp_silver_bg:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._sliverPanel._ccbOwner.sp_silver_bg:getContentSize()
	self._CP.x = self._CP.x + 30
	self._CP.y = self._CP.y + 10
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入购买", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10002, attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InTreasure:_openSliverChest()
	app:triggerBuriedPoint(20160)
	self._handTouch:removeFromParent()
	if self._dialog._sliverPanel._onTriggerClick == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog._sliverPanel:_onTriggerClick()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBuyOne()
	end, 0.5)
end

--引导点击抽取一次
function QTutorialPhase01InTreasure:_guideClickBuyOne()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_buy_one:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._ccbOwner.btn_buy_one:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "确认购买", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开奖励页面
function QTutorialPhase01InTreasure:_openReward()
	app:triggerBuriedPoint(20170)
	self._handTouch:removeFromParent()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, self.closeHeroCard, self)
	if self._dialog._onTriggerBuyOne == nil then
		self:_jumpToEnd()
		return
	end

	self._dialog:_onTriggerBuyOne({})
end

--引导点击关闭魂师大图
function QTutorialPhase01InTreasure:closeHeroCard()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, self.closeHeroCard, self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end

function QTutorialPhase01InTreasure:_waitClickOther()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END, self.closeHeroInfo, self)

	app:triggerBuriedPoint(20180)
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog._backClickHandler == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_backClickHandler()
end

--引导点击关闭魂师大图
function QTutorialPhase01InTreasure:closeHeroInfo()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END, self.closeHeroInfo, self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end

function QTutorialPhase01InTreasure:_waitClickOther2()
	app:triggerBuriedPoint(20181)
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog._backClickHandler == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_backClickHandler()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideCloseReward1()
	end, 1)
end

function QTutorialPhase01InTreasure:_guideCloseReward1()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_back:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "收入队伍", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--关闭奖励获得页面
function QTutorialPhase01InTreasure:_closeReward1()
	app:triggerBuriedPoint(20190)
	self._handTouch:removeFromParent()
	if self._dialog._onTriggerConfirm == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_onTriggerConfirm()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:clickBackBtn()
	end, 0.5)
end

--返回酒馆主界面
function QTutorialPhase01InTreasure:clickBackBtn()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_back:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP, moveStartPos = self._perCP})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--返回酒馆主界面
function QTutorialPhase01InTreasure:openTavernMainPage()
	app:triggerBuriedPoint(20200)
	self._handTouch:removeFromParent()
	if self._dialog._onTriggerBack == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_onTriggerBack()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_clickBuyGoldChest()
	end, 0.5)
end

--引导点击查看
function QTutorialPhase01InTreasure:_clickBuyGoldChest()
	 self:clearSchedule()
	self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._goldPanel._ccbOwner.sp_gold_bg:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._goldPanel._ccbOwner.sp_gold_bg:getContentSize()
	self._CP.x = self._CP.x
	self._CP.y = self._CP.y
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入购买", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10003, attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01InTreasure:_openGoldChest()
	app:triggerBuriedPoint(20210)
	self._handTouch:removeFromParent()
	if self._dialog._goldPanel._onTriggerClick == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog._goldPanel:_onTriggerClick()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickGoldBuyOne()
	end, 0.5)
end

--引导点击抽取一次
function QTutorialPhase01InTreasure:_guideClickGoldBuyOne()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_buy_one:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._ccbOwner.btn_buy_one:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "确认购买", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开奖励页面
function QTutorialPhase01InTreasure:_openGoldReward()
	app:triggerBuriedPoint(20220)
	self._handTouch:removeFromParent()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, self.closeOtherHeroCard, self)
	if self._dialog._onTriggerBuyOne == nil then
		self:_jumpToEnd()
		return
	end

	self._dialog:_onTriggerBuyOne({})
end

--引导点击关闭魂师大图
function QTutorialPhase01InTreasure:closeOtherHeroCard()
	local stage = app.tutorial:getStage()
	stage.forced = QTutorialPhase01InTreasure.TREASURE_SUCCESS
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, self.closeOtherHeroCard, self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end

function QTutorialPhase01InTreasure:_waitClickOther3()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END, self.closeOtherHeroInfo, self)

	app:triggerBuriedPoint(20230)
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog._backClickHandler == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_backClickHandler()
end

--引导点击关闭魂师大图
function QTutorialPhase01InTreasure:closeOtherHeroInfo()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END, self.closeOtherHeroInfo, self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end

function QTutorialPhase01InTreasure:_waitClickOther4()
	app:triggerBuriedPoint(20231)
	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog._backClickHandler == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_backClickHandler()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideCloseSilverReward1()
	end, 1)
end

-- --等待玩家点击后对话消失
-- function QTutorialPhase01InTreasure:_waitClick2()
--     self:clearDialgue()
-- 	self._CP = nil
-- 	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
-- 		self:_guideCloseSilverReward()
-- 	end, 1.2)
-- end

-- --引导点击确认，返回
-- function QTutorialPhase01InTreasure:_guideCloseSilverReward()
-- 	self:clearSchedule()
-- 	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
-- 	self._CP = {x = 0, y = 0}
-- 	self._size = {width = display.width*2, height = display.height*2}
-- end

-- --关闭奖励获得页面
-- function QTutorialPhase01InTreasure:_closeSilverReward()
-- 	if self._dialog._backClickHandler == nil then
-- 		self:_jumpToEnd()
-- 		return
-- 	end
-- 	self._dialog:_backClickHandler()

--     -- 数据埋点
--     app:triggerBuriedPoint(22)

-- 	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
-- 		self:_guideCloseSilverReward1()
-- 	end, 0.5)
-- end

-- function QTutorialPhase01InTreasure:_guideCloseSilverReward3()
-- 	self:clearSchedule()

-- 	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
-- 		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
-- 		self._CP = {x = 0, y = 0}
-- 		self._size = {width = display.width*2, height = display.height*2}
-- 	end, 2)
-- end

-- --关闭奖励获得页面
-- function QTutorialPhase01InTreasure:_closeSilverReward3()
-- 	if self._dialog._backClickHandler == nil then
-- 		self:_jumpToEnd()
-- 		return
-- 	end
-- 	self._dialog._animationIsDone = true
-- 	self._dialog:_backClickHandler() 

-- 	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
-- 		self:_guideCloseSilverReward1()
-- 	end, 0.5)
-- end

--引导点击确认，返回
function QTutorialPhase01InTreasure:_guideCloseSilverReward1()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_back:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "收入队伍", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--关闭奖励获得页面
function QTutorialPhase01InTreasure:_closeGoldReward()
	app:triggerBuriedPoint(20240)
	self._handTouch:removeFromParent()
	if self._dialog._onTriggerConfirm == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_onTriggerConfirm()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:clickBackBtn2()
	end, 0)
end

--返回酒馆主界面
function QTutorialPhase01InTreasure:clickBackBtn2()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_back:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP, moveStartPos = self._perCP})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--返回酒馆主界面
function QTutorialPhase01InTreasure:openTavernMainPage2()
	app:triggerBuriedPoint(20250)
	self._handTouch:removeFromParent()
	if self._dialog._onTriggerBack == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_onTriggerBack()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideCloseBuyDialog()
	end, 0.5)
end

--引导
function QTutorialPhase01InTreasure:_guideCloseBuyDialog()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local chestDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if chestDialog and chestDialog._goldPanel and chestDialog._goldPanel.init then
		chestDialog._goldPanel:init()
	end
	self._CP = self._dialog._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_home:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "返回主城", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--关闭购买页面
function QTutorialPhase01InTreasure:_closeBuy()
	app:triggerBuriedPoint(20260)
	self._handTouch:removeFromParent()
	if self._dialog._onTriggerHome == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_onTriggerHome()

    -- 数据埋点
    app:triggerBuriedPoint(24)

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01InTreasure:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01InTreasure:_nodeRunAction(posX,posY)
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

function QTutorialPhase01InTreasure:createDialogue()
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

function QTutorialPhase01InTreasure:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight._isSaying == true and self._dialogueRight:isVisible() then
			self._dialogueRight:printAllWord(self._word)
        elseif #self._tutorialInfo > 0 then
        	QPrintTable(self._sound)
            self:createDialogue()
        -- elseif self._handTouch and self._handTouch.isPlaying and self._handTouch:isPlaying() then
        	-- 跳过动画阶段，暂不实装
			-- self._handTouch:onClick()
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

function QTutorialPhase01InTreasure:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01InTreasure:clearDialgue()
    if self._dialogueRight ~= nil then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
end

return QTutorialPhase01InTreasure
