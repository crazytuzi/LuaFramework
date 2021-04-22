-- @Author: zhouxiaoshu
-- @Date:   2019-07-02 20:19:45
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-27 15:40:53

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01SoulTowerChange = class("QTutorialPhase01SoulTowerChange", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01SoulTowerChange:start()
    -- handbook^1;arena^1;jewelry^2;metal^1;gloryTower^1;intencify^1;monthSignIn^1;soultowerChange^0;night^0;offerReward^1;thunder^1;addHero^1;training^1;heroYwd^0;totemChallengeChoose^0;soulTower^1;strengthen^1;eliteStar^1;addHeroYwd^0;gemstone^1;blackRock^1;totemChallenge^1;activity^1;totemChallengeQuickPass^0;spar^1;sanctuary^2;breakth^1;sotoTeam^1;silver^1;godarm^1;heroShop^1;eliteBox^1;mockBattle2^1;invasion^1;soulSpirit^1;unlockHelp^2;enchant^1;archaeology^1;artifact^1;secretary^1;fightClub^1;weeklyMission^1;mockBattle^1;convey^1;dragonTotem^1;soulSpiritOccult^2;silvesArenaSubModuleChoose^1;mount^1;call^2;guideEnd^0;addMoney^1;maritime^1;silvesArenaFighting^0;collegeTrain^3;refine^0;skill^1;silvesArena^1;ssgemstone^1;sunWar^1;useSkin^0;magicHerb^1;glyph^1;maritimeTop^0;storm^1;monopoly^1;forced^6
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

 	app:getClient():guidanceRequest(16003)
	local stage = app.tutorial:getStage()
	stage.soultowerChange = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)
	
	self:stepManager()

end

--步骤管理
function QTutorialPhase01SoulTowerChange:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_openBlackRock()
	elseif self._step == 3 then
		self:_openSoulTower()
	elseif self._step == 4 then
		self:_sayWord2()
	elseif self._step == 5 then
		self:_sayWord3()
	elseif self._step == 6 then
		self:endTutorial()
	end
end

--引导开始
function QTutorialPhase01SoulTowerChange:_guideStart()
	-- self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	-- self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
	-- 	self._step = 2
	-- 	self:_guideClickBlackRock()
	-- else
	-- 	self._step = 1
	-- 	self:_guideClickMainpage()
	-- end 
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("16011")
    self._distance = "left"
    self:createDialogue()	
end

function QTutorialPhase01SoulTowerChange:chooseNextStage()
    self:clearDialgue()

	self:_guideClickBlackRock()
end 

--引导玩家返回主界面
function QTutorialPhase01SoulTowerChange:_guideClickMainpage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulTowerChange:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBlackRock()
	end,0.5)
end

--引导玩家点击传灵塔
function QTutorialPhase01SoulTowerChange:_guideClickBlackRock()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["node_blackRock"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_blackRock"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y
		self._size = page._ccbOwner["btn_blackRock"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16001, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01SoulTowerChange:_openBlackRock()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerBlackRock()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickSoulTower()
	end, 0.5)
end

--引导玩家点击升灵台
function QTutorialPhase01SoulTowerChange:_guideClickSoulTower()
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	
	self._CP = dialog._ccbOwner["btn_right"]:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner["btn_right"]:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16002, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulTowerChange:_openSoulTower( )
	self._handTouch:removeFromParent()
	remote.soultower:openDialog(true)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_SOULTOWER_CLOSE, self._sayWord1,self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_SOULTOWER_QIANGZHI_CLOSE, self._closeTutorial,self)
end
function QTutorialPhase01SoulTowerChange:_sayWord1()
	self:clearSchedule()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_SOULTOWER_CLOSE, self._sayWord1,self)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
		
		self._CP = dialog._ccbOwner["node_tutorial"]:convertToWorldSpaceAR(ccp(0,0))
		self._size = dialog._ccbOwner["node_tutorial"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16012, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end,0.3)
end

function QTutorialPhase01SoulTowerChange:_sayWord2()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	
	self._CP = dialog._ccbOwner["sp_award_png"]:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner["sp_award_png"]:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16013, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulTowerChange:_sayWord3( )
	self._handTouch:removeFromParent()
	self:clearSchedule()
	self:clearDialgue()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("16014")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01SoulTowerChange:_closeTutorial()
	self:clearSchedule()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_SOULTOWER_CLOSE, self._closeTutorial,self)
	self:endTutorial()
end

function QTutorialPhase01SoulTowerChange:endTutorial()
	self:clearDialgue()
	self:_tutorialFinished()
end

function QTutorialPhase01SoulTowerChange:_tutorialFinished()
    self:clearSchedule()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01SoulTowerChange:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01SoulTowerChange:_nodeRunAction(posX,posY)
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

function QTutorialPhase01SoulTowerChange:createDialogue()
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

function QTutorialPhase01SoulTowerChange:_onTouch(event)
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

function QTutorialPhase01SoulTowerChange:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01SoulTowerChange:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01SoulTowerChange
