-- @Author: xurui
-- @Date:   2020-01-03 17:58:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-26 16:14:17
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01TotemChallenge = class("QTutorialPhase01TotemChallenge", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01TotemChallenge:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	local stage = app.tutorial:getStage()
	stage.totemChallenge = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)
	
	self:stepManager()

end
--步骤管理
function QTutorialPhase01TotemChallenge:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_backMainPage()
	elseif self._step == 2 then
		self:_openSunWar()
	elseif self._step == 3 then
		self:_openTotemChallenge()
	elseif self._step == 4 then
		self:_openTeamChangenge()
	elseif self._step == 5 then
		self:_onTriggerChallenge()
	elseif self._step == 6 then
		self:_openTeamGodarm()
	elseif self._step == 7 then 
		self:guideClickGodArmy()
	elseif self._step == 8 then
		self:_addGodArmyToTeam()
	elseif self._step == 9 then
		self:_guideEnd()
	end
end

--引导开始
function QTutorialPhase01TotemChallenge:_guideStart()
    self:clearDialgue()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 1
		self:_guideClickSunWar()
	else
		self:_guideClickMainpage()
	end
end

--引导玩家点击扩展标签
function QTutorialPhase01TotemChallenge:_guideClickMainpage()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01TotemChallenge:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickSunWar()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01TotemChallenge:_guideClickSunWar()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	
	self.moveDistance = page._ccbOwner["sunwell_node"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(3)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (-self.moveDistance.x + display.cx)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_sunwell"]:convertToWorldSpaceAR(ccp(0,0))
		self._size = page._ccbOwner["btn_sunwell"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 12001, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01TotemChallenge:_openSunWar()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onSunwell()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickTotemChallenge()
	end,0.5)
end

function QTutorialPhase01TotemChallenge:_guideClickTotemChallenge()
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	
	self._CP = dialog._ccbOwner["btn_right"]:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner["btn_right"]:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 12002, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01TotemChallenge:_openTotemChallenge()
	self._handTouch:removeFromParent()
	remote.totemChallenge:openDialog(true)

	-- self._schedulerHandler = scheduler.performWithDelayGlobal(function()
	-- 	self:_sayWord()
	-- end,0.5)
	-- self._schedulerHandler = scheduler.performWithDelayGlobal(function()
	-- 	self:_clickChallegeBtn()
	-- end,0.5)	
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_TOTEMCHALLEGENGE_CLOSE, self._clickChallegeBtn,self)
end

function QTutorialPhase01TotemChallenge:_clickChallegeBtn()
	self:clearSchedule()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_TOTEMCHALLEGENGE_CLOSE, self._clickChallegeBtn,self)
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._listView then
		local itemFrame= dialog._listView:getItemByIndex(1)
		if itemFrame then
			self._CP = itemFrame._ccbOwner.btn_challenge:convertToWorldSpaceAR(ccp(0,0))
			self._size = itemFrame._ccbOwner.btn_challenge:getContentSize()
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		else
			self:_guideEnd()
			return
		end	
	else
		self:_guideEnd()
		return
	end
end

function QTutorialPhase01TotemChallenge:_openTeamChangenge( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog._listView then
		local itemFrame = dialog._listView:getItemByIndex(1)
		itemFrame:_onTriggerChallenge({callback = function()
			self._schedulerHandler = scheduler.performWithDelayGlobal(function()
				self:_clickChallegeBtn2()
			end,0.5)	
		end})
	end
end

function QTutorialPhase01TotemChallenge:_clickChallegeBtn2( ... )
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = dialog._ccbOwner["btn_challenge"]:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._ccbOwner["btn_challenge"]:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)		
end

function QTutorialPhase01TotemChallenge:_onTriggerChallenge()
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	dialog:_onTriggerChallenge()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_clickOpenTeamGodarm()
	end,0.5)	
end


function QTutorialPhase01TotemChallenge:_clickOpenTeamGodarm( )
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = dialog._widgetHeroArray._ccbOwner["btn_godarm"]:convertToWorldSpaceAR(ccp(0,0))
	self._size = dialog._widgetHeroArray._ccbOwner["btn_godarm"]:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)		
end

function QTutorialPhase01TotemChallenge:_openTeamGodarm( )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog._widgetHeroArray.onTriggerGodarm then
		dialog._widgetHeroArray:onTriggerGodarm()
	else
		self:_guideEnd()
		return
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord()
	end,0.5)	
end

function QTutorialPhase01TotemChallenge:_sayWord()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("12005")
    self._distance = "left"
    self:createDialogue()
end


function QTutorialPhase01TotemChallenge:guideClickGodArmy()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if not self._dialog._widgetHeroArray._listViewLayout then
		self:finished()
		return
	end
	self._widget = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(1)
	if not self._widget then
		self:finished()
		return
	end
	self._CP = self._widget._ccbOwner.sp_head_bg:convertToWorldSpaceAR(ccp(0,0))
	q.floorPos(self._CP)
	self._size = self._widget._ccbOwner.sp_head_bg:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 12008, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x-4, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01TotemChallenge:_addGodArmyToTeam()
	self._handTouch:removeFromParent()
	if self._widget._onTriggerHeroOverview == nil then
		self:_jumpToEnd()
		return
	end

	self._widget:_onTriggerHeroOverview()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord1()
	end,0.5)
end

function QTutorialPhase01TotemChallenge:_sayWord1()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("12003")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01TotemChallenge:createDialogue()
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

function QTutorialPhase01TotemChallenge:_guideEnd()
    self:clearDialgue()
	self:finished()
end

--引导开始
function QTutorialPhase01TotemChallenge:_guideClickTotem()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.totemBtn:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.totemBtn:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击龙纹图腾", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01TotemChallenge:_guideClickEnd()
	self._handTouch:removeFromParent()
	self._dialog:_onTriggerTotem()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_openDragonTotem()
	end,0.5)
end

function QTutorialPhase01TotemChallenge:_openDragonTotem()
    self:clearDialgue()
	self:finished()
end

function QTutorialPhase01TotemChallenge:_onTouch(event)
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

function QTutorialPhase01TotemChallenge:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01TotemChallenge:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01TotemChallenge