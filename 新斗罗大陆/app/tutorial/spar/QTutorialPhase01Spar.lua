-- @Author: xurui
-- @Date:   2017-04-10 21:17:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 13:22:10
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Spar = class("QTutorialPhase01Spar", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01Spar:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

   	app:getClient():guidanceRequest(4001, function()end)

	local stage = app.tutorial:getStage()
	stage.spar = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSpar)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSpar)
    end
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, UNLOCK_DELAY_TIME + 0.5)
end
--步骤管理
function QTutorialPhase01Spar:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:chooseNextStage()
	elseif self._step == 2 then
		self:_openScaling()
	elseif self._step == 3 then
		self:_openBackpack()
	elseif self._step == 4 then
		self:_openGemstoneBackpack()
	elseif self._step == 5 then
		self:_clickSparTab() 
	elseif self._step == 6 then
		self:_clickCompose()
	elseif self._step == 7 then
		self:_closeDialog()
	elseif self._step == 8 then
		self:_clickGoHome()
	end
end

--引导开始
function QTutorialPhase01Spar:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("4001")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Spar:chooseNextStage()
    self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self:_guideClickScaling()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01Spar:_guideClickScaling()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.button_scaling:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.button_scaling:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Spar:_openScaling()
	self._handTouch:removeFromParent()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBackPack()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01Spar:_guideClickBackPack()
	self:clearSchedule()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_bag:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_bag:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Spar:_openBackpack()
	self._handTouch:removeFromParent()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onButtondownSideMenuBag()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickGemStoneBackpack()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01Spar:_guideClickGemStoneBackpack()
	 self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog._listView then
		local itemFrame= dialog._listView:getItemByIndex(2)
		if itemFrame then
			self._CP = itemFrame._ccbOwner.btn_click:convertToWorldSpaceAR(ccp(0,0))
			self._size = itemFrame._ccbOwner.btn_click:getContentSize()
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		else
			self:_jumpToEnd()
			return
		end	
	else
		self:_jumpToEnd()
		return
	end	
end

--打开关卡页面
function QTutorialPhase01Spar:_openGemstoneBackpack()
	self._handTouch:removeFromParent()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack"})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickSparTab()
	end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01Spar:_guideClickSparTab()
	self:clearSchedule()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	if dialog._selectTab == "TAB_SPAR_PIECE" then
		self._step = self._step + 1
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideClickCompose()
		end, 0.5)
	else
		self._CP = dialog._ccbOwner.node_btn_spar_piece:convertToWorldSpaceAR(ccp(0, 0))
		self._size = dialog._ccbOwner.btn_spar_piece:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._CP.x = self._CP.x
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end
end

function QTutorialPhase01Spar:_clickSparTab()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog:_onTriggerTabSparPiece()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickCompose()
	end, 0.5)
end

function QTutorialPhase01Spar:_guideClickCompose()
	self:clearSchedule()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = dialog._sparPanel._ccbOwner.button_compose:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._sparPanel._ccbOwner.button_compose:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Spar:_clickCompose()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog._sparPanel:_onTirggerCompose()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_waitCloseDialog()
	end, 1)
end

function QTutorialPhase01Spar:_waitCloseDialog()
	self:clearSchedule()

	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01Spar:_closeDialog()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	dialog:_onTriggerConfirm()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickGoHome()
	end, 0.5)
end

function QTutorialPhase01Spar:_guideClickGoHome()
	self:clearSchedule()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Spar:_clickGoHome()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Spar:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Spar:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Spar:createDialogue()
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

function QTutorialPhase01Spar:_onTouch(event)
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

function QTutorialPhase01Spar:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Spar:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Spar