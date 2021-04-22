-- 
-- Author: Kumo
-- Date: 2015-08-17 10:41:55
-- 杀戮之都首次进入界面剧情
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Invasion = class("QTutorialPhase01Invasion", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhase01Invasion:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.cleanBuildLayer then
		page:cleanBuildLayer()
	end

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local dialog2 = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog2 ~= nil then
		if dialog2.class.__cname == "QUIDialogAchieveCard" or dialog2.class.__cname == "QUIDialogTeamUp" or dialog2.class.__cname == "QUIDialogAwardsAlert" then 
	   		self:_jumpToEnd()
	        return
	    else
	    	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		end
	end
	if dialog ~= nil then
		if dialog.class.__cname == "QUIDialogShowHeroAvatar" then 
	   		self:_jumpToEnd()
	        return
    	end		
   	end

 --   	if app.tip.UNLOCK_TIP_ISTRUE == false then
	-- 	app.tip:showUnlockTips("UNLOCK_FORTRESS")
	-- else
	-- 	app.tip:addUnlockTips("UNLOCK_FORTRESS")
	-- end

	local stage = app.tutorial:getStage()
	stage.invasion = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

	
	-- self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	-- end,UNLOCK_DELAY_TIME + 0.5)

end
--步骤管理
function QTutorialPhase01Invasion:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideEnd()
	end
end
--引导开始
function QTutorialPhase01Invasion:_guideStart()
	self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5301")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Invasion:_guideEnd()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Invasion:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01Invasion:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Invasion:createDialogue()
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
		-- self._dialogueRight:setActorImage(self._tutorialInfo[1][2])
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

function QTutorialPhase01Invasion:_onTouch(event)
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

function QTutorialPhase01Invasion:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01Invasion:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01Invasion
