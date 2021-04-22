--
-- Author: xurui
-- Date: 2015-12-24 15:15:52
--
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01AddHero = class("QTutorialPhase01AddHero", QTutorialPhase)

local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01AddHero:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._word = nil
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()
	
	--提前标志完成
	local stage = app.tutorial:getStage()
	stage.addHero = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)
	
	self._step = 0
	self:stepManager()
end

function QTutorialPhase01AddHero:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:guideClickHero2()
	elseif self._step == 2 then
		self:_addHero2ToTeam()
	-- elseif self._step == 3 then
	-- 	self:startBattle()
	end
end

--引导开始
function QTutorialPhase01AddHero:_guideStart()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("3101")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01AddHero:guideClickHero2()
    self:clearDialgue()

    -- 数据埋点
    app:triggerBuriedPoint(21240)

	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._widget = self._dialog._widgetHeroArray
	self._heroIndex = 1
	local heroSelect = 1
	local items = self._widget._items
    for index, item in pairs(items) do
        if item.actorId == 1003 then
            heroSelect = index
            break
        end
    end
    if heroSelect > 5 then
    	self._widget:runTo(1003)
    end
	if heroSelect == 1 then
		self:_jumpToEnd()
		return
	end
	
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local items = self._widget._items
	    for index, item in pairs(items) do
	        if item.actorId == 1003 then
	            self._heroIndex = index
	            break
	        end
	    end
		self._widget = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(self._heroIndex)
		self._CP = self._widget._ccbOwner.sp_head_bg:convertToWorldSpaceAR(ccp(0,0))
		self._size = self._widget._ccbOwner.sp_head_bg:getContentSize()
		self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 1)
end

function QTutorialPhase01AddHero:_addHero2ToTeam()
	self._handTouch:removeFromParent()
	self._widget = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(self._heroIndex)
	if self._widget._onTriggerHeroOverview == nil then
		self:_jumpToEnd()
		return
	end
	self._widget:_onTriggerHeroOverview()

    -- 数据埋点
    app:triggerBuriedPoint(21250)

	self:startBattle()

end

function QTutorialPhase01AddHero:startBattle()

	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01AddHero:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

-- 移动到指定位置
function QTutorialPhase01AddHero:_nodeRunAction(posX,posY)
	self._isMove = true
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveBy:create(0.2, ccp(posX,posY)))
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self._isMove = false
		self._actionHandler = nil
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	self._actionHandler = self._handTouch:runAction(ccsequence)
end

function QTutorialPhase01AddHero:createDialogue()
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

function QTutorialPhase01AddHero:_onTouch(event)
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

function QTutorialPhase01AddHero:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01AddHero:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01AddHero
