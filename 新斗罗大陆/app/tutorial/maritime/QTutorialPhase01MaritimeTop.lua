--
-- Kumo.Wang
-- 聚宝盆开启特级仙品引导
--

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01MaritimeTop = class("QTutorialPhase01MaritimeTop", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01MaritimeTop:start()
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
	stage.maritimeTop = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)
	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, 0.5)

end
--步骤管理
function QTutorialPhase01MaritimeTop:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickTransport()
	elseif self._step == 2 then
		self:_onClickTransport()
	elseif self._step == 3 then
		self:_guideEnd()
	end
end

--引导开始
function QTutorialPhase01MaritimeTop:_guideStart()
	self:clearSchedule()
    self:clearDialgue()

	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("18100")
	self:createDialogue()
end 

--引导玩家点击运送
function QTutorialPhase01MaritimeTop:_guideClickTransport()
    self:clearDialgue()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogMaritimeMain" then
		self._CP = dialog._ccbOwner.btn_transport:convertToWorldSpaceAR(ccp(0,0))
		self._size = dialog._ccbOwner.btn_transport:getContentSize()
		self._perCP = ccp(display.width/2, display.height/2)
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	else
		self:_jumpToEnd()
        return 
	end
end

-- 点击运送
function QTutorialPhase01MaritimeTop:_onClickTransport()
	self._handTouch:removeFromParent()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogMaritimeMain" and dialog._onTriggerTransport then
		remote.maritime.startShipId = 1
		dialog:_onTriggerTransport()

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideShowEffect()
		end, 1)
	else
		self:_jumpToEnd()
        return 
	end
end

--动画表现
function QTutorialPhase01MaritimeTop:_guideShowEffect()
    self:clearSchedule()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogMaritimeChooseShip" then
		if dialog._listView then
			local item = dialog._listView:getItemByIndex(1)
			local arrAction = CCArray:create()
			arrAction:addObject(CCEaseSineOut:create(CCMoveBy:create(1, ccp(item:getPositionX(), item:getPositionY() + item:getContentSize().height))))
			arrAction:addObject(CCCallFunc:create(function()
					item:setPositionY(1000)
					dialog._listView:startScrollToPosScheduler(-190, 1, true, function()
						self._schedulerHandler = scheduler.performWithDelayGlobal(function()
							self:_guideShowDialogue()
						end, 0.5)
					end, false)
			    end))
			item:runAction(CCSequence:create(arrAction))
		end
	else
		self:_jumpToEnd()
        return 
	end
end

--引导对话
function QTutorialPhase01MaritimeTop:_guideShowDialogue()
    self:clearSchedule()

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogMaritimeChooseShip" then
		self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("18102")
		self:createDialogue()
	else
		self:_jumpToEnd()
        return 
	end
end

function QTutorialPhase01MaritimeTop:createDialogue()
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

function QTutorialPhase01MaritimeTop:_onTouch(event)
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

function QTutorialPhase01MaritimeTop:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01MaritimeTop:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

function QTutorialPhase01MaritimeTop:_guideEnd()
	remote.maritime.startShipId = 2
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog.class.__cname == "QUIDialogMaritimeChooseShip" and dialog.updateShipInfo then
		dialog:updateShipInfo(true)
	end
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01MaritimeTop:_jumpToEnd()
	remote.maritime.startShipId = 2
	app.tutorial._runingStage:jumpFinished()
	self:_guideEnd()
end

return QTutorialPhase01MaritimeTop
