local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01OfferReward = class("QTutorialPhase01OfferReward", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01OfferReward:start()
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
	stage.offerReward = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)
	app:getClient():guidanceRequest(18000)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	local delay_time =  UNLOCK_DELAY_TIME + 0.5
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, delay_time)

end
--步骤管理
function QTutorialPhase01OfferReward:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickMainpage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:sayOfferStartWord()
	elseif self._step == 4 then
		self:_guideClickSocietyUnion()
	elseif self._step == 5 then
		self:openSocietyUnionDialog()
	elseif self._step == 6 then
		self:openOfferReward()
	elseif self._step == 7 then
		self:endTutorial()
	end
end

--引导开始
function QTutorialPhase01OfferReward:_guideStart()
   self:clearDialgue()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 3
		self:sayOfferStartWord()
	else
		self._step = 1
		self:_guideClickMainpage()
	end
end

function QTutorialPhase01OfferReward:_guideClickMainpage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01OfferReward:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._step = 3
		self:sayOfferStartWord()
	end,0.5)
end


function QTutorialPhase01OfferReward:sayOfferStartWord()
   	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("18000")
    self._distance = "left"
    self:createDialogue()
end


--引导玩家点击宗门界面
function QTutorialPhase01OfferReward:_guideClickSocietyUnion()
	print("_guideClickSocietyUnion")
	self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["node_fuzhou"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_union"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y
		self._size = page._ccbOwner["btn_union"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = self._talkId, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

--打开宗门界面
function QTutorialPhase01OfferReward:openSocietyUnionDialog()
	self:clearHandeTouch()
 	remote.union:openDialog(nil,true) 
 	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_ENTER_UNION_MAIN_PAGE, self._delayguideClickOfferReward, self)
 	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_ENTER_NOTHAVE_UNION, self._jumpToEnd, self)
end

function QTutorialPhase01OfferReward:_delayguideClickOfferReward()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_ENTER_UNION_MAIN_PAGE, self._delayguideClickOfferReward, self)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickOfferReward()
	end,0.5)
end

--引导玩家点击悬赏任务
function QTutorialPhase01OfferReward:_guideClickOfferReward()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local moveDistance = self._dialog._ccbOwner["xs"]:convertToWorldSpaceAR(ccp(0, 0))
	self._dialog:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x), y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._CP = self._dialog._ccbOwner["offerRewardBtn"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y
		self._size = self._dialog._ccbOwner["offerRewardBtn"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = self._talkId, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

--打开悬赏任务
function QTutorialPhase01OfferReward:openOfferReward()
	self:clearHandeTouch()
 	remote.offerreward:openDialog()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:sayWord()
		end, 0.5)

end

function QTutorialPhase01OfferReward:sayWord()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("18001")
    self._distance = "left"
    self:createDialogue()
end


function QTutorialPhase01OfferReward:endTutorial()
	--self._handTouch:removeFromParent()
	self:clearHandeTouch()
	self:clearSchedule()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01OfferReward:_jumpToEnd()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_ENTER_NOTHAVE_UNION, self._jumpToEnd, self)
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

function QTutorialPhase01OfferReward:createDialogue()
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

function QTutorialPhase01OfferReward:_onTouch(event)
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

function QTutorialPhase01OfferReward:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01OfferReward:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

function QTutorialPhase01OfferReward:clearHandeTouch()
	if self._handTouch ~= nil then
		self._handTouch:removeFromParent()
		self._handTouch = nil
	end
end

return QTutorialPhase01OfferReward
