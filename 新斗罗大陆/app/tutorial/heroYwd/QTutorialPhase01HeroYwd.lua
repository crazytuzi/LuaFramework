--
-- Author: xurui
-- Date: 2016-06-12 16:47:21
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01HeroYwd = class("QTutorialPhase01HeroYwd", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01HeroYwd:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

    local stage = app.tutorial:getStage()
    stage.heroYwd = 1
    app.tutorial:setStage(stage)
    app.tutorial:setFlag(stage)
    self._heroIndex = 0
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

-- heroShop^0;eliteBox^1;jewelry^0;metal^0;gloryTower^0;intencify^0;invasion^0;soulSpirit^0;night^0;thunder^0;addHero^0;archaeology^0;training^0;artifact^0;secretary^0;monopoly^0;fightClub^0;storm^0;strengthen^0;eliteStar^1;gemstone^0;convey^0;blackRock^0;dragonTotem^0;heroYwd^0;mount^0;silver^0;activity^0;call^0;guideEnd^0;maritime^0;addMoney^0;spar^0;sanctuary^0;skill^0;breakth^1;sunWar^0;refine^0;useSkin^0;magicHerb^0;glyph^0;forced^6;enchant^0;unlockHelp^0;arena^0

	self._copyIndex = 5

	self:stepManager()
end

function QTutorialPhase01HeroYwd:getEliteBossBoxUnlock()
	local dungeonInfo = remote.instance:getDungeonById("wailing_caverns_16")
	if dungeonInfo == nil then return false end

	if  dungeonInfo.dungeon_isboss == true and dungeonInfo.info and dungeonInfo.info.bossBoxOpened == false then
		return true
	end
	return false
end 

function QTutorialPhase01HeroYwd:isHaveHeroYwd( )
	local hero = remote.herosUtil:getHeroByID(1005)
	if hero then
		return true
	else
		return false
	end
end

--步骤管理
function QTutorialPhase01HeroYwd:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then --引导开箱
		self:_openHeroInfo()
	elseif self._step == 2 then
		self:_receiveReward()
	elseif self._step == 3 then
		self:_backMainMenu()
	elseif self._step == 4 then
		self:_openChest()
	elseif self._step == 5 then
		self:_openGoldChest()
	elseif self._step == 6 then
		self:_openGoldReward()
	elseif self._step == 7 then
		self:_waitClickOther3()
	elseif self._step == 8 then
		self:_waitClickOther4()
	elseif self._step == 9 then
		self:_closeGoldReward()
	elseif self._step == 10 then
		self:openTavernMainPage2()
	elseif self._step == 11 then
		self:_closeBuy()	
	elseif self._step == 12 then
		self:_openInstence()		
	end
end

function QTutorialPhase01HeroYwd:_guideStart()
	if self:getEliteBossBoxUnlock() == true then
		self:_guideClickHeroFrame()	
	else
		self:_jumpToEnd()
	end
end

function QTutorialPhase01HeroYwd:_openChest()

	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._onCheast == nil then
		self:_jumpToEnd()
		return
	end

	page:_onCheast()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_clickBuyGoldChest()
	end, 0.1)
end

--引导点击查看
function QTutorialPhase01HeroYwd:_clickBuyGoldChest()
	 self:clearSchedule()
	self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._goldPanel._ccbOwner.sp_gold_bg:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._goldPanel._ccbOwner.sp_gold_bg:getContentSize()
	self._CP.x = self._CP.x
	self._CP.y = self._CP.y
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入购买", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01HeroYwd:_openGoldChest()

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
function QTutorialPhase01HeroYwd:_guideClickGoldBuyOne()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.btn_buy_one:convertToWorldSpaceAR(ccp(0, 0))
	self._size = self._dialog._ccbOwner.btn_buy_one:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "确认购买", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10021,attack = true,pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--打开奖励页面
function QTutorialPhase01HeroYwd:_openGoldReward()

	self._handTouch:removeFromParent()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, self.closeOtherHeroCard, self)
	if self._dialog._onTriggerBuyOne == nil then
		self:_jumpToEnd()
		return
	end

	self._dialog:_onTriggerBuyOne({})
end

--引导点击关闭魂师大图
function QTutorialPhase01HeroYwd:closeOtherHeroCard()
	local stage = app.tutorial:getStage()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, self.closeOtherHeroCard, self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end

function QTutorialPhase01HeroYwd:_waitClickOther3()
	-- dldl-25322
	local haveHerosID = remote.herosUtil:getHaveHero()
	-- QPrintTable(haveHerosID)
    for _, id in pairs(haveHerosID) do
        if id ~= 1001 and id ~= 1002 and id ~= 1003 and id ~= 1005 then
          	self:_jumpToEnd()
          	return
        end
    end


	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END, self.closeOtherHeroInfo, self)

	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if self._dialog._backClickHandler == nil then
		self:_jumpToEnd()
		return
	end
	self._dialog:_backClickHandler()
end

--引导点击关闭魂师大图
function QTutorialPhase01HeroYwd:closeOtherHeroInfo()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END, self.closeOtherHeroInfo, self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end

function QTutorialPhase01HeroYwd:_waitClickOther4()

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

--引导点击确认，返回
function QTutorialPhase01HeroYwd:_guideCloseSilverReward1()
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
function QTutorialPhase01HeroYwd:_closeGoldReward()

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
function QTutorialPhase01HeroYwd:clickBackBtn2()
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
function QTutorialPhase01HeroYwd:openTavernMainPage2()

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
function QTutorialPhase01HeroYwd:_guideCloseBuyDialog()
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
function QTutorialPhase01HeroYwd:_closeBuy()

	self._handTouch:removeFromParent()
	if self._dialog._onTriggerHome == nil then
		self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()		
	end
	self._dialog:_onTriggerHome()

	-- self._step = 2
	self:_guideClickInstence(1)
end

--引导玩家返回魂师总览页面
function QTutorialPhase01HeroYwd:_guideClickBackMainPage(diaType)
    -- self:clearDialgue()
    self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_home:getContentSize()
	if diaType == 1 then
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10019, attack = true,pos = self._CP})
	else
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	end
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01HeroYwd:_backMainMenu()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickChast()
	end, 0.5)
end

--引导玩家打开关卡界面
function QTutorialPhase01HeroYwd:_guideClickInstence(diaType)

	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["btn_instance"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_instance"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y + 35
		self._size = page._ccbOwner["btn_instance"]:getContentSize()
		if diaType == 1 then
			self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10022,attack = true,pos = self._CP})
		else
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		end
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

--引导玩家打开武魂殿界面
function QTutorialPhase01HeroYwd:_guideClickChast()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["btn_chest"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_chest"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y + 35
		self._size = page._ccbOwner["btn_chest"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10020, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end


function QTutorialPhase01HeroYwd:_openInstence()
	self._handTouch:removeFromParent()

 	self._dialog:_onInstance()
 	self:_jumpToEnd()
end

--引导玩家点击第一个副本
function QTutorialPhase01HeroYwd:_guideClickCopy()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._copy = page._currentPage._heads[self._copyIndex]
	self._CP = self._copy._ccbOwner.btn_head:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._copy._ccbOwner.btn_head:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "有敌人！准备战斗！", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end


--引导玩家点击魂师头像
function QTutorialPhase01HeroYwd:_guideClickHeroFrame()
	--  self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if not self._dialog then
		self:_jumpToEnd()
		return
	end

	self._copy = self._dialog._currentPage._heads[4]

	self._CP = self._copy._chest._ccbOwner.btn_chest:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._copy._chest._ccbOwner.btn_chest:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击领取宝箱", direction = "up"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10018, attack = true,pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end
function QTutorialPhase01HeroYwd:_openHeroInfo()
	self._handTouch:removeFromParent()
	self._copy:_onTriggerBoxGold()
  	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_ELITE_BOX_SUCCESS, handler(self, self._guideClickOK))
end

--引导玩家点击魂师头像
function QTutorialPhase01HeroYwd:_guideClickOK()

  	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_ELITE_BOX_SUCCESS, handler(self, self._guideClickOK))


	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		self._CP = {x = 0, y = 0}
		self._size = {width = display.width*2, height = display.height*2}
	end, 1)
end


function QTutorialPhase01HeroYwd:_receiveReward()

	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	page._isShowing = false
	page:_onTriggerConfirm()

	if not self:isHaveHeroYwd() and remote.user.totalLuckyDrawAdvanceCount == 0 then  --没有杨无敌，并且高级招募次数等于1
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideClickBackMainPage(1)	
		end, 0.5)	
	else
		self:_jumpToEnd()	
	end
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01HeroYwd:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01HeroYwd:_nodeRunAction(posX,posY)
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

function QTutorialPhase01HeroYwd:createDialogue()
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

function QTutorialPhase01HeroYwd:_onTouch(event)
	print(event.name)
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

function QTutorialPhase01HeroYwd:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01HeroYwd:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01HeroYwd
