-- 
-- Kumo.Wang
-- 圣柱挑战神罚引导步骤
--

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01TotemChallengeQuickPass = class("QTutorialPhase01TotemChallengeQuickPass", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01TotemChallengeQuickPass:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	local stage = app.tutorial:getStage()
	stage.totemChallengeQuickPass = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)
	
	local quickPassItemId = 1000548
	if remote.items:getItemsNumByID(quickPassItemId) < 2 then
		app:getClient():guidanceRequest(16006, function()end)
	end

	self:stepManager()

end
--步骤管理
function QTutorialPhase01TotemChallengeQuickPass:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideToClickPlayer()
	elseif self._step == 2 then
		self:_onTriggerPlayer()
	elseif self._step == 3 then
		self:_onTriggerQuickPassTeamOne()
	elseif self._step == 4 then
		self:_onTriggerConfirmBtnOne()
	elseif self._step == 5 then
		self:_onTriggerQuickPassTeamTwo()
	elseif self._step == 6 then
		self:_onTriggerConfirmBtnTwo()
	elseif self._step == 7 then
		self:_onTriggerFight()
	elseif self._step == 8 then
		self:_guideEnd()
	end
end

-- 引导开始
function QTutorialPhase01TotemChallengeQuickPass:_guideStart()
    self:clearDialgue()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("16006")
	self:createDialogue()
end

-- 引导点击对手
function QTutorialPhase01TotemChallengeQuickPass:_guideToClickPlayer()
	self:clearDialgue()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._listView then
		local userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
		local itemFrame = dialog._listView:getItemByIndex(tonumber(userInfoDict.currentDungeon))
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

-- 打开对战信息面板
function QTutorialPhase01TotemChallengeQuickPass:_onTriggerPlayer( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._listView then
		local userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
		local itemFrame = dialog._listView:getItemByIndex(tonumber(userInfoDict.currentDungeon))
		if itemFrame then
			itemFrame:_onTriggerChallenge({callback = function()
				self._schedulerHandler = scheduler.performWithDelayGlobal(function()
					local userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
					if userInfoDict then
						if not userInfoDict.team1IsQuickPass then
							self:_guideToClickQuickPassTeamOne()
						elseif not userInfoDict.team2IsQuickPass then
							self._step = 4
							self:_guideToClickQuickPassTeamTwo()
						else
							self._step = 6
							self:_guideToClickFight()
							return
						end
					else
						self._step = 6
						self:_guideToClickFight()
						return
					end
				end,0.5)	
			end})
		else
			self:_guideEnd()
			return
		end	
	else
		self:_guideEnd()
		return
	end
end

-- 引导神罚一队
function QTutorialPhase01TotemChallengeQuickPass:_guideToClickQuickPassTeamOne( ... )
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._ccbOwner.btn_quickPass_1 then
		self._CP = dialog._ccbOwner.btn_quickPass_1:convertToWorldSpaceAR(ccp(0,0))
		self._size = dialog._ccbOwner.btn_quickPass_1:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16007, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)		
	else
		self:_guideEnd()
		return
	end
end

-- 点击神罚一队
function QTutorialPhase01TotemChallengeQuickPass:_onTriggerQuickPassTeamOne( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._ccbOwner.btn_quickPass_1 and dialog._onTriggerSetQuickPass then
		dialog:_onTriggerSetQuickPass(nil, dialog._ccbOwner.btn_quickPass_1)

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideToClickQuickPass()
		end,0.5)	
	else
		self:_guideEnd()
		return
	end
end

-- 确定神罚操作
function QTutorialPhase01TotemChallengeQuickPass:_guideToClickQuickPass( ... )
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog and dialog._ccbOwner.btn_confirm then
		self._CP = dialog._ccbOwner.btn_confirm:convertToWorldSpaceAR(ccp(0,0))
		self._size = dialog._ccbOwner.btn_confirm:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)		
	else
		self:_guideEnd()
		return
	end
end

-- 点击确定神罚1
function QTutorialPhase01TotemChallengeQuickPass:_onTriggerConfirmBtnOne( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog and dialog._onTriggerConfirm then
		dialog:_onTriggerConfirm()

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			local userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
			if userInfoDict then
				if not userInfoDict.team2IsQuickPass then
					self:_guideToClickQuickPassTeamTwo()
				else
					self._step = 6
					self:_guideToClickFight()
					return
				end
			else
				self._step = 6
				self:_guideToClickFight()
				return
			end
		end,0.5)	
	else
		self:_guideEnd()
		return
	end
end

-- 引导神罚二队
function QTutorialPhase01TotemChallengeQuickPass:_guideToClickQuickPassTeamTwo( ... )
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._ccbOwner.btn_quickPass_2 then
		self._CP = dialog._ccbOwner.btn_quickPass_2:convertToWorldSpaceAR(ccp(0,0))
		self._size = dialog._ccbOwner.btn_quickPass_2:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16008, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)		
	else
		self:_guideEnd()
		return
	end
end

-- 点击神罚二队
function QTutorialPhase01TotemChallengeQuickPass:_onTriggerQuickPassTeamTwo( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._ccbOwner.btn_quickPass_2 and dialog._onTriggerSetQuickPass then
		dialog:_onTriggerSetQuickPass(nil, dialog._ccbOwner.btn_quickPass_2)

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideToClickQuickPass()
		end,0.5)	
	else
		self:_guideEnd()
		return
	end
end

-- 点击确定神罚2
function QTutorialPhase01TotemChallengeQuickPass:_onTriggerConfirmBtnTwo( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	if dialog and dialog._onTriggerConfirm then
		dialog:_onTriggerConfirm()

		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideToClickFight()
		end,0.5)	
	else
		self:_guideEnd()
		return
	end
end

-- 引导挑战
function QTutorialPhase01TotemChallengeQuickPass:_guideToClickFight( ... )
	self:clearSchedule()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._ccbOwner.btn_challenge then
		self._CP = dialog._ccbOwner.btn_challenge:convertToWorldSpaceAR(ccp(0,0))
		self._size = dialog._ccbOwner.btn_challenge:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 16009, attack = true, pos = self._CP})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)		
	else
		self:_guideEnd()
		return
	end
end

-- 点击开始挑战
function QTutorialPhase01TotemChallengeQuickPass:_onTriggerFight( ... )
	self._handTouch:removeFromParent()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog and dialog._onTriggerChallenge then
		dialog:_onTriggerChallenge()
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideEnd()
		end,0.5)	
	else
		self:_guideEnd()
		return
	end
end

function QTutorialPhase01TotemChallengeQuickPass:createDialogue()
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

function QTutorialPhase01TotemChallengeQuickPass:_guideEnd()
    self:clearDialgue()
	self:finished()
end

function QTutorialPhase01TotemChallengeQuickPass:_onTouch(event)
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

function QTutorialPhase01TotemChallengeQuickPass:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01TotemChallengeQuickPass:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01TotemChallengeQuickPass