-- 
-- @Author: Kumo
-- @Date:   2018-09-18 21:11:52
-- 
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Monopoly = class("QTutorialPhase01Monopoly", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01Monopoly:start()
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
	stage.monopoly = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMonopoly)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMonopoly)
    end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01Monopoly:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_doOpenMonopoly()
	elseif self._step == 2 then
		self:_guideClickGrid()
	elseif self._step == 3 then
		self:_doClickGrid()
	elseif self._step == 4 then
		self:_doClickMaterial()
	elseif self._step == 5 then
		self:_doClickPoison()
	elseif self._step == 6 then
		self:_doClickBoss()
	elseif self._step == 7 then
		self:_doClickCloseFinalAward()
	elseif self._step == 8 then
		self:_doClickGoBtn()
	elseif self._step == 9 then
		self:endTutorial()
	end
end

--引导开始
function QTutorialPhase01Monopoly:_guideStart()
	local firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if firstDialog == nil and firstPage.class.__cname == "QUIPageMainMenu" then
		self:_clickMonopolyBtn()
	else
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_clickMonopolyBtn()
		end,0.8)
	end
end

function QTutorialPhase01Monopoly:_clickMonopolyBtn()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local node = "monopoly_node"
	local btn = "btn_monopoly"
	local offsetX = 0
	local offsetY = 0
	self.moveDistance = page._ccbOwner[node]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(5)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (-self.moveDistance.x + display.cx)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._CP = page._ccbOwner[btn]:convertToWorldSpaceAR(ccp(0,0))
		self._size = page._ccbOwner[btn]:getContentSize()
		self._CP.x = self._CP.x + offsetX
		self._CP.y = self._CP.y + offsetY
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5712, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01Monopoly:_doOpenMonopoly()
	self:clearSchedule()
    self._handTouch:removeFromParent()
	
	remote.monopoly:openDialog()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:_sayWord()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5713")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Monopoly:_guideClickGrid()
	self:clearDialgue()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local mapWidget = dialog:getMapWidget()

	local heroPos = ccp(mapWidget._ccbOwner.node_hero:getPosition())
	local gridPos = ccp(mapWidget._ccbOwner.grid_0:getPosition())
	if heroPos.x == gridPos.x and heroPos.y == gridPos.y then
		self._CP = mapWidget._ccbOwner.grid_1:convertToWorldSpaceAR(ccp(0,0))
	else
		self._CP = mapWidget._ccbOwner.node_hero:convertToWorldSpaceAR(ccp(0,0))
	end
	self._willClickPos = self._CP
	local colorConfig = remote.monopoly:getGridColorConfig(1)
	if colorConfig and colorConfig.picture then
		local sp = CCSprite:create(colorConfig.picture)
        self._size = sp:getContentSize()
	else
		self._size = {width = 30, height = 30}
	end
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5715, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Monopoly:_doClickGrid()
    self._handTouch:removeFromParent()
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local mapWidget = dialog:getMapWidget()
	mapWidget:onTriggerGrid(mapWidget:convertToNodeSpace(ccp(self._willClickPos.x, self._willClickPos.y)).x, mapWidget:convertToNodeSpace(ccp(self._willClickPos.x, self._willClickPos.y)).y)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickMaterial()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:_guideClickMaterial()
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	self._CP = dialog._ccbOwner.node_material_1:convertToWorldSpaceAR(ccp(0,0))
	local config = remote.monopoly:getItemConfigByID(13200001)
	if config and config.icon then
        local sp = CCSprite:create(config.icon)
        self._size = sp:getContentSize()
    else
        self._size = {width = 30, height = 30}
    end
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5716, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Monopoly:_doClickMaterial()
    self._handTouch:removeFromParent()
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    local config = remote.monopoly:getGridColorConfig(1)
    if config and config.text then
        app.tip:floatTip(config.text)
    end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickPoison()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:_guideClickPoison()
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	self._CP = dialog._ccbOwner.node_poison_1:convertToWorldSpaceAR(ccp(0,0))
    local sp = remote.monopoly:getPoisonImgById(1)
    if sp then
    	self._size = sp:getContentSize()
    else
    	self._size = {width = 30, height = 30}
    end
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5719, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Monopoly:_doClickPoison()
    self._handTouch:removeFromParent()
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    local config = remote.monopoly:getPoisonConfigById(1)
    if config and config.description then
        app.tip:floatTip(config.description)
    end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBoss()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:_guideClickBoss()
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	self._CP = dialog._ccbOwner.btn_reviewFinalReward_big:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner.btn_reviewFinalReward_big:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5720, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Monopoly:_doClickBoss()
    self._handTouch:removeFromParent()
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog:_onTriggerBoss("32")

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickCloseFinalAward()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:_guideClickCloseFinalAward()
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()

	self._CP = dialog._ccbOwner.btn_OK:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner.btn_OK:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5717, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Monopoly:_doClickCloseFinalAward()
    self._handTouch:removeFromParent()
	
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	dialog:_onTriggerOK()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickGoBtn()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:_guideClickGoBtn()
    self:clearDialgue()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = dialog._ccbOwner.btn_go:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner.btn_go:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 5714, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Monopoly:_doClickGoBtn()
    self._handTouch:removeFromParent()
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog:_onTriggerGo()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_tutorialFinished()
	end, 0.5)
end 

function QTutorialPhase01Monopoly:endTutorial()
	self:clearDialgue()
	self:_tutorialFinished()
end

function QTutorialPhase01Monopoly:_tutorialFinished()
    self:clearSchedule()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Monopoly:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Monopoly:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Monopoly:createDialogue()
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

function QTutorialPhase01Monopoly:_onTouch(event)
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

function QTutorialPhase01Monopoly:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Monopoly:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Monopoly
