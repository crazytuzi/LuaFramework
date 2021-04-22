--
-- Author: Qinyuanji
-- Date: 2015-01-13
-- 
-- 


local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01ArenaAddName = class("QTutorialPhase01ArenaAddName", QTutorialPhase)

local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")

--步骤开始
function QTutorialPhase01ArenaAddName:start()
	self._stage:enableTouch(handler(self, self._onTouch))
		
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
		
	self._tutorialInfo = {}
	self._step = 0
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, 0.1)
end

--步骤管理
function QTutorialPhase01ArenaAddName:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:waitClick1()
	elseif self._step == 2 then
		self:nameSetOver()
	end
end

--引导开始
function QTutorialPhase01ArenaAddName:_guideStart()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("101")
	self._distance = "left"
	self:createDialogue()
end

--显示取名对话框
function QTutorialPhase01ArenaAddName:waitClick1()
    if self._word ~= nil then
        self._word = nil
    end
    
    -- 数据埋点
    app:triggerBuriedPoint(20270)

    self:clearDialgue()

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChangeName", 
        options = {arena = true, isTutorial = true, nameChangedCallBack = function(newName)
        self._stage._touchNode:setTouchSwallowEnabled(true)
        app:sendGameEvent(GAME_EVENTS.GAME_EVENT_CREATE_ROLE, true)
        -- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_MAIN_PAGE, true)

        self._schedulerHandler = scheduler.performWithDelayGlobal(function()
            self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("104")
            self:createDialogue()
        end, 0.7)

        -- 数据埋点
    	app:triggerBuriedPoint(20280)
        
    end, cancelCallBack = function ( ... )
        self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("103")
        self:createDialogue()
        self._step = self._step - 1
        self._stage._touchNode:setTouchSwallowEnabled(true)
    end}}, {isPopCurrentDialog = false})

    self._stage._touchNode:setTouchSwallowEnabled(false)
end

function QTutorialPhase01ArenaAddName:createDialogue()
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

function QTutorialPhase01ArenaAddName:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight:isVisible() then 
			if self._dialogueRight._isSaying == true then 
				self._dialogueRight:printAllWord(self._word)
			elseif #self._tutorialInfo > 0 then
				self:createDialogue()
			else    
				self._step = self._step + 1
				self:stepManager()
			end
		end
	end
end

function QTutorialPhase01ArenaAddName:clearDialgue()
		if self._dialogueRight ~= nil then
			self._dialogueRight:removeFromParent()
			self._dialogueRight = nil
		end
end

function QTutorialPhase01ArenaAddName:nameSetOver( ... )
    app:triggerBuriedPoint(20290)
	self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:buildLayer()
	self:finished()
end

function QTutorialPhase01ArenaAddName:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end


return QTutorialPhase01ArenaAddName
