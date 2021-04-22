local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01InSkill = class("QTutorialPhase01InSkill", QTutorialPhase)

local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QTutorialPhase01InSkill.SKILL_SUCCESS = 1

--步骤开始
function QTutorialPhase01InSkill:start()
	self._stage:enableTouch(handler(self, self._onTouch))
    self._tutorialInfo = {}

	--返回主界面，清除MidLayer层
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:startTutorial()
	end,0.2)	
end

function QTutorialPhase01InSkill:startTutorial()
	self:clearSchedule()
	--标志引导完成
	local stage = app.tutorial:getStage()
	stage.skill = QTutorialPhase01InSkill.SKILL_SUCCESS
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	if app.tip.UNLOCK_TIP_ISTRUE == false then
		app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSkill)
	else
		app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSkill)
	end

	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self.firstDialog ~= nil and self.firstDialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
		self._step = 5
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:_guideClickBack()
		end,UNLOCK_DELAY_TIME + 0.5)
	else
		self._perCP = ccp(display.width/2, display.height/2)
		self._step = 0
		self._schedulerHandler = scheduler.performWithDelayGlobal(function()
			self:stepManager()
		end,UNLOCK_DELAY_TIME + 0.5)
	end
end


--步骤管理
function QTutorialPhase01InSkill:stepManager()
	if self._step == 0 then
		self:chooseNextStage()
	elseif self._step == 1 then
		self:_backMainPage()
	elseif self._step == 2 then
		self:_openScaling()
	elseif self._step == 3 then
		self:_openHero()
	elseif self._step == 4 then
		self:_openHeroInfo()
	elseif self._step == 5 then
		self:_backHeroInfo()
	-- elseif self._step == 6 then
	-- 	self:_openHeroGrade()
	elseif self._step == 6 then
		self:_confrimHeroGrade()
	end
end

function QTutorialPhase01InSkill:chooseNextStage()
    self:clearDialgue()
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
			(self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
		self._step = 1
		self:_guideClickScaling()
	else
		self:_guideClickMainPage()
	end
end 

--引导玩家点击扩展标签
function QTutorialPhase01InSkill:_guideClickMainPage()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._ccbOwner.btn_home:getContentSize()
	self._perCP = ccp(display.width/2, display.height/2)
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回主界面", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = self._step + 1
end

function QTutorialPhase01InSkill:_backMainPage()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:_onTriggerHome()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickScaling()
	end,0.5)
end

--引导玩家点击伸缩按钮
function QTutorialPhase01InSkill:_guideClickScaling()
	--  self:clearSchedule()
    self:clearDialgue()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

	if page._scaling._DisplaySideMenu then
		self._step = self._step + 1
		self:_guideClickHero()
		return 
	end

	self._CP = page._scaling._ccbOwner.button_scaling:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.button_scaling:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击进入菜单", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = self._step + 1
end

function QTutorialPhase01InSkill:_openScaling()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:_onTriggerOffSideMenu()

    -- 数据埋点
    app:triggerBuriedPoint(21360)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHero()
	end,0.5)
end

--引导玩家点击魂师总览按钮
function QTutorialPhase01InSkill:_guideClickHero()
	self:clearSchedule()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
	self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看魂师", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = self._step + 1
end

function QTutorialPhase01InSkill:_openHero()
	self._handTouch:removeFromParent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._dialog = page._scaling:_onButtondownSideMenuHero()

    -- 数据埋点
    app:triggerBuriedPoint(21361)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickHeroFrame()
	end,0.5)
end

--引导玩家点击魂师头像
function QTutorialPhase01InSkill:_guideClickHeroFrame()
	self:clearSchedule()
	self.heros = self._dialog._datas
	for k, value in ipairs(self.heros) do
		if remote.herosUtil:getHeroByID(value) ~= nil then
			self.heroIndex = k
			break
		end
	end
	self._dialog._listView:startScrollToIndex(self.heroIndex, false, 100, function ()
		local heroFrame = self._dialog._listView:getItemByIndex(self.heroIndex)
		if heroFrame then
			self._CP = heroFrame._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
			self._size = heroFrame._ccbOwner.node_size:getContentSize()
			-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "选择魂师", direction = "right"})
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
			self._step = self._step + 1
		end
	end)
end

function QTutorialPhase01InSkill:_openHeroInfo()
	self._handTouch:removeFromParent()
	self._dialog:selectHeroByActorId(self.heros[self.heroIndex])

    -- 数据埋点
    app:triggerBuriedPoint(21370)

	self._step = 5
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickGradeBtn()
	end, 0.5)
end

--引导玩家点击返回
function QTutorialPhase01InSkill:_guideClickBack()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	self._CP = self._dialog._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._ccbOwner.btn_back:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击返回", direction = "right"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
	self._CP.y = self._CP.y - 10
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = self._step + 1
end

function QTutorialPhase01InSkill:_backHeroInfo()
	self._handTouch:removeFromParent()
	self._dialog:_onTriggerBack()
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickGradeBtn()
	end, 0.5)
end

--引导玩家点击加技能点按钮
function QTutorialPhase01InSkill:_guideClickGradeBtn()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.skillCell = self._dialog._skill.skillCell
	self._CP = self.skillCell[1]._ccbOwner.button_plus:convertToWorldSpaceAR(ccp(0,0))
	self._size = self.skillCell[1]._ccbOwner.button_plus:getContentSize()
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击升级魂技", direction = "left"})
	self._handTouch = QUIWidgetTutorialHandTouch.new({id = 10016, attack = true, pos = self._CP})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
	self._step = self._step + 1
end

function QTutorialPhase01InSkill:_confrimHeroGrade()
	self._handTouch:removeFromParent()
	self.skillCell[1]:_onPlus()

    -- 数据埋点
    app:triggerBuriedPoint(21380)

	self:_startBattle()
end

function QTutorialPhase01InSkill:_startBattle()
    self:clearDialgue()
	self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01InSkill:_jumpToEnd()
	app.tutorial._runingStage:jumpFinished()
	self:finished()
end

-- 移动到指定位置
function QTutorialPhase01InSkill:_nodeRunAction(posX,posY)
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

function QTutorialPhase01InSkill:createDialogue()
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
		self._dialogueRight = QUIWidgetTutorialDialogue.new({avatarKey = self._avatarKey, isLeftSide = self._isLeft, text = self._word, name = name, heroId = heroInfo.id, isSay = true, sayFun = function()
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
end

function QTutorialPhase01InSkill:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._dialogueRight ~= nil and self._dialogueRight._isSaying == true and self._dialogueRight:isVisible() then
			self._dialogueRight:printAllWord(self._word)
		elseif #self._tutorialInfo > 0 then
			self:createDialogue()
		elseif self._CP ~= nil and event.x >=  self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
			event.y >=  self._CP.y - self._size.height/2 and event.y <= self._CP.y + self._size.height/2  then
			-- self._step = self._step + 1
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

function QTutorialPhase01InSkill:clearSchedule()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QTutorialPhase01InSkill:clearDialgue()
	if self._dialogueRight ~= nil then
		self._dialogueRight:removeFromParent()
		self._dialogueRight = nil
	end
end

return QTutorialPhase01InSkill
