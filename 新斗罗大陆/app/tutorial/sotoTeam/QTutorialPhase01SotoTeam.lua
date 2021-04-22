-- @Author: zhouxiaoshu
-- @Date:   2019-09-11 16:27:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-29 19:22:47
-- @Author: xurui
-- @Date:   2018-11-16 20:27:33
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-05-07 12:28:20
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01SotoTeam = class("QTutorialPhase01SotoTeam", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetTutorialHandTouchMove = import("...ui.widgets.QUIWidgetTutorialHandTouchMove")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01SotoTeam:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}
	self._handTouchMove = nil
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		page:cleanBuildLayer()
	end

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

	local stage = app.tutorial:getStage()
	stage.sotoTeam = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 0
	self._perCP = ccp(display.width/2, display.height/2)

   	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSotoTeam)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSotoTeam)
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)

end
--步骤管理
function QTutorialPhase01SotoTeam:stepManager()
	if self._step == 0 then
		self:_guideStart()
	elseif self._step == 1 then
		self:_guideClickMainpage()
	elseif self._step == 2 then
		self:_backMainPage()
	elseif self._step == 3 then
		self:_openArena()
	elseif self._step == 4 then
		self:_guideEntrance()
	elseif self._step == 5 then
		self:_openSotoTeam()
	elseif self._step == 6 then 
		self:_waitClickEnemyInfo()
	elseif self._step == 7 then 
		self:_clickEnemyInfo()
	elseif self._step == 8 then 
		self:_showAlternateArray()
	elseif self._step == 9 then
		self:_guideClickBackPage()
	elseif self._step == 10 then
		self:_backSotoDialog()
	elseif self._step == 11 then
		self:_changeDescription()
	elseif self._step == 12 then
		self:_closeDescription()
	elseif self._step == 13 then
        self:_tutorialFinished()
    end
end

function QTutorialPhase01SotoTeam:_guideStart()
    self:clearDialgue()

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" then
		self._step = 2
		self:_guideClickArena()
	else
		self._step = 1
		self:_guideClickMainpage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01SotoTeam:_guideClickMainpage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if not page or not page._ccbOwner or not page._ccbOwner.btn_home then
		self:_jumpToEnd()
		return
	end
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)

	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SotoTeam:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickArena()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01SotoTeam:_guideClickArena()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local moveDistance = page._ccbOwner.btn_arena:convertToWorldSpaceAR(ccp(0, 0))
	page._pageSilder:stopAllAction()
	local speedRateX = page._pageSilder:getSpeedRateByIndex(3)
	page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		self._CP = page._ccbOwner.btn_arena:convertToWorldSpaceAR(ccp(0,0))
		self._size = page._ccbOwner.btn_arena:getContentSize()
		self._CP.y = self._CP.y + 70
		self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10031, attack = true, pos = pos})
		self._handTouch:setPosition(self._CP.x, self._CP.y)
		app.tutorialNode:addChild(self._handTouch)
	end, 0.8)
end

function QTutorialPhase01SotoTeam:_openArena()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onArena()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_sayWord1()
	end, 0.5)
end

function QTutorialPhase01SotoTeam:_sayWord1()
	self:clearSchedule()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("10032")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01SotoTeam:_guideEntrance()
    self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self._dialog and self._dialog.getListViewLayout then
		local listview = self._dialog:getListViewLayout()
		local item = listview:getItemByIndex(2)
		if item and item._ccbOwner.node_module then
			self._CP = item._ccbOwner.node_module:convertToWorldSpaceAR(ccp(0,0))
			self._size = item:getContentSize()
			self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10033, attack = true, pos = self._CP})
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

function QTutorialPhase01SotoTeam:_openSotoTeam()
	self._handTouch:removeFromParent()

	remote.sotoTeam:openDialog(function()
		local callback = function()
			self:_SotoTeamMoveStart()
		end
		self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
		self._dialog:showPlayerMoveAni(nil,false,0,false)
		self._dialog:showPlayerMoveAni(callback,true,3,true)
	end)

end


function QTutorialPhase01SotoTeam:_SotoTeamMoveStart()
	
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._handTouchMove = QUIWidgetTutorialHandTouchMove.new()
	local callback = function()
		self:_SotoTeamMoveEnd()
	end
	self._handTouchMove:addCallBack(callback)
	self._CP = self._dialog._ccbOwner.touch_node:convertToWorldSpaceAR(ccp(0,0))
	self._handTouchMove:setPosition(self._CP.x, self._CP.y)
	self._handTouchMove:setActionPosition(-500)

	app.tutorialNode:addChild(self._handTouchMove)
end

function QTutorialPhase01SotoTeam:_SotoTeamMoveEnd()
	self._handTouchMove:removeFromParent()
	self._dialog:showPlayerMoveAni(nil,false,3,true)
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._handTouchMove = nil
		self:_sayWord2()
	end,3.1)
end

function QTutorialPhase01SotoTeam:_sayWord2()
	self:clearSchedule()
	self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("10034")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01SotoTeam:_waitClickEnemyInfo()
    self:clearDialgue()

	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local item = self._dialog:getPlayerByIndex(8)
	if not item then
		self:_jumpToEnd()
		return
	end
	self._widget = item
	self._CP = self._widget._ccbOwner.btn_avatar:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._widget._ccbOwner.btn_avatar:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SotoTeam:_clickEnemyInfo()
	self._handTouch:removeFromParent()
	self._widget:_onTriggerAvatar()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickAlternate()
	end,0.5)
end

--引导玩家点击下一步
function QTutorialPhase01SotoTeam:_guideClickAlternate()
    self:clearDialgue()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if not self._dialog or not self._dialog._widgetHeroArray then
    	self:_jumpToEnd()
    	return
    end
    self._CP = self._dialog._widgetHeroArray._ccbOwner.btn_alternate:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._widgetHeroArray._ccbOwner.btn_alternate:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SotoTeam:_showAlternateArray()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog._widgetHeroArray:onTriggerAlternate()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showEndDialog()
    end, 0.5)
end

function QTutorialPhase01SotoTeam:_showEndDialog()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("10035")
    self:createDialogue()
end

--引导玩家点击扩展标签
function QTutorialPhase01SotoTeam:_guideClickBackPage()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_back:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)

	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SotoTeam:_backSotoDialog()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerBack()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_showDescription()
	end,0.5)
end

function QTutorialPhase01SotoTeam:_showDescription()
    self:clearSchedule()

	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._dialog:showFunctionDescription()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_waitChangeDescription()
	end,0.5)
end

function QTutorialPhase01SotoTeam:_waitChangeDescription()
    self:clearSchedule()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01SotoTeam:_changeDescription()
    self:clearDialgue()

	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._dialog:_onTriggerClickRight()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_waitCloseDescription()
	end,0.5)
end

function QTutorialPhase01SotoTeam:_waitCloseDescription()
    self:clearSchedule()
	self._CP = {x = 0, y = 0}
	self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01SotoTeam:_closeDescription()
    self:clearDialgue()

	self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	self._dialog:_onTriggerClose()

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_tutorialFinished()
	end,0.5)
end

function QTutorialPhase01SotoTeam:_tutorialFinished()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01SotoTeam:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

--移动到指定位置
function QTutorialPhase01SotoTeam:_nodeRunAction(posX,posY)
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

function QTutorialPhase01SotoTeam:createDialogue()
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

function QTutorialPhase01SotoTeam:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight._isSaying == true and self._dialogueRight:isVisible() then
			self._dialogueRight:printAllWord(self._word)
		elseif #self._tutorialInfo > 0 then
			self:createDialogue()
		elseif self._handTouchMove ~= nil then

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

function QTutorialPhase01SotoTeam:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01SotoTeam:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01SotoTeam
