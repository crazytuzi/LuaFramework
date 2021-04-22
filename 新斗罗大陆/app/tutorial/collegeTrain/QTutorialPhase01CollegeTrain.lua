-- @Author: liaoxianbo
-- @Date:   2019-11-24 15:19:03
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-26 11:37:06

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01CollegeTrain = class("QTutorialPhase01CollegeTrain", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01CollegeTrain:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

   	-- app:getClient():guidanceRequest(3601, function()end)

	local stage = app.tutorial:getStage()
	local tutorialTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockCollegeTrain
	self._guideType = 1
	self._talkId = 11001
	if stage.collegeTrain == 0 then
		self._guideType = 1
		stage.collegeTrain = 1
	elseif stage.collegeTrain == 1 then
		self._guideType = 2
		stage.collegeTrain = 2
		self._talkId = 11004
		tutorialTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockCollegeTrain2	
	elseif stage.collegeTrain == 2 then
		self._guideType = 3
		stage.collegeTrain = 3
		tutorialTips = UNLOCK_TUTORIAL_TIPS_TYPE.unlockCollegeTrain3	
		self._talkId = 11005
	end

	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	
	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(tutorialTips)
	else
		app.tip:addUnlockTips(tutorialTips)
	end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)

end
--步骤管理
function QTutorialPhase01CollegeTrain:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickMainpage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openCollegeTrain()
	elseif self._step == 4 then
		self:_openCollegeTrainChapter()
	elseif self._step == 5 then
		self:_openCollegeTrainChoose()
	elseif self._step == 6 then
		self:_openCollegeBattle()
	elseif self._step == 7 then
		self:endTutorial()
	end
end

--引导开始
function QTutorialPhase01CollegeTrain:_guideStart()
	self:clearSchedule()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 2
		self:_guideClickCollegeTrain()
	else
		self._step = 1
		self:_guideClickMainpage()
	end
end

--引导玩家点击扩展标签
function QTutorialPhase01CollegeTrain:_guideClickMainpage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01CollegeTrain:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickCollegeTrain()
	end,0.5)
end

--引导玩家点击训练关
function QTutorialPhase01CollegeTrain:_guideClickCollegeTrain()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner["node_collegeTrain"]:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner["btn_collegeTrain"]:convertToWorldSpaceAR(ccp(0,0))
		self._CP.y = self._CP.y
		self._size = page._ccbOwner["btn_collegeTrain"]:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = self._talkId, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01CollegeTrain:_openCollegeTrain()
	self._handTouch:removeFromParent()
	remote.collegetrain:openMainDialog()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickCollegeLevel()
	end, 0.5)
end

function QTutorialPhase01CollegeTrain:_guideClickCollegeLevel(  )
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._ccbOwner.node_college_tutorial:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.sp_icon_left:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 11006,attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01CollegeTrain:_openCollegeTrainChapter( )
	self._handTouch:removeFromParent()
	remote.collegetrain:openCollegeTrainDialog()

	if self._guideType == 1 then
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideChilckLowChapter()
		end, 0.5)
	else
		self:_jumpToEnd()
	end
end

function QTutorialPhase01CollegeTrain:_guideChilckLowChapter( )
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self._dialog and self._dialog._ccbOwner.chapter1 then
		self._CP = self._dialog._ccbOwner.chapter1:convertToWorldSpaceAR(ccp(0,0))
		self._size = CCSize(290,422)
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 11002,attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	else
		self:_jumpToEnd()
	end
end

function QTutorialPhase01CollegeTrain:_openCollegeTrainChoose()
	self._handTouch:removeFromParent()
 	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCollegeTrainChapterChoose",
 		options = {chapterType = 1}})
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickBattle()
	end, 0.5)
end

function QTutorialPhase01CollegeTrain:_guideClickBattle()
	self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._chapterInfoWidget._ccbOwner.node_button:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._chapterInfoWidget._ccbOwner.button:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 11003, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01CollegeTrain:_openCollegeBattle(  )
	self._handTouch:removeFromParent()
	if self._dialog._chapterInfoWidget._onTriggerConfirm then
		self._dialog._chapterInfoWidget:_onTriggerConfirm()
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord()
	end, 0.5)
end

function QTutorialPhase01CollegeTrain:_sayWord()
	self:clearSchedule()

    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("11003")

    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01CollegeTrain:endTutorial()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01CollegeTrain:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01CollegeTrain:_nodeRunAction(posX,posY)
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

function QTutorialPhase01CollegeTrain:createDialogue()
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

function QTutorialPhase01CollegeTrain:_onTouch(event)
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

function QTutorialPhase01CollegeTrain:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01CollegeTrain:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01CollegeTrain