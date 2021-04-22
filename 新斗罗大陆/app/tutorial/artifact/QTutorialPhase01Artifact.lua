--
-- zxs
-- 武魂真身引导
--

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Artifact = class("QTutorialPhase01Artifact", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetArtifactBox = import("...ui.widgets.artifact.QUIWidgetArtifactBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01Artifact:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end
    
    app:getClient():guidanceRequest(5722, function()end)

	local stage = app.tutorial:getStage()
	stage.artifact = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._step = 1
	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockArtifact)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockArtifact)
    end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01Artifact:stepManager()
    if self._step == 1 then
        self:chooseNextStage()
    elseif self._step == 2 then
        self:_guideClickScaling()
    elseif self._step == 3 then
        self:_openScaling()
    elseif self._step == 4 then
        self:_openHero()
    elseif self._step == 5 then
        self:_openCopy()
    elseif self._step == 6 then
        self:_openHeroInfo()
    elseif self._step == 7 then
        self:_showArtifactInfo()
    elseif self._step == 8 then
        self:_guideClickSkillBtn()
    elseif self._step == 9 then
        self:_showSkillInfo()
    elseif self._step == 10 then
        self:_allEnd()
    end
end

--引导开始
function QTutorialPhase01Artifact:chooseNextStage()
    self:clearDialgue()
    self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
            (self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
        self._step = 3
        self:_guideClickHero()
    else   
        self._step = 2     
        self:_guideClickScaling()
    end
end 

--引导玩家点击扩展标签
function QTutorialPhase01Artifact:_guideClickScaling()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._ccbOwner.btn_home:getContentSize()

    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if dialog.class.__cname == "QUIDialogMonopoly" then
        self._CP = page._ccbOwner.btn_back:convertToWorldSpaceAR(ccp(0,0))
        self._size = page._ccbOwner.btn_back:getContentSize()
    end
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, id = 5721})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Artifact:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHero()
    end,0.5)
end

--引导玩家点击英雄总览按钮
function QTutorialPhase01Artifact:_guideClickHero()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    
    if page._scaling._DisplaySideMenu then
        self._step = self._step + 1
        self:_guideClickHeroFrame()
        return 
    end

    self._CP = page._scaling._ccbOwner.button_scaling:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.button_scaling:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Artifact:_openHero()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:_onTriggerOffSideMenu()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHeroFrame()
    end,0.5)
end

--引导玩家点击英雄头像
function QTutorialPhase01Artifact:_guideClickHeroFrame()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01Artifact:_openCopy()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuHero()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickBattle()
    end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01Artifact:_guideClickBattle()
	self:clearSchedule()
	self.heros = self._dialog._datas
	for k, value in ipairs(self.heros) do
		if remote.herosUtil:getHeroByID(value) ~= nil then
			self.heroIndex = k
			break
		end
	end
	if self.heros[self.heroIndex] == nil then
		self:finished()
		return 
	end
	self._dialog._listView:startScrollToIndex(self.heroIndex, false, 100, function ()
		local heroFrame = self._dialog._listView:getItemByIndex(self.heroIndex)
		if heroFrame then
			self._CP = heroFrame._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
			self._size = heroFrame._ccbOwner.node_size:getContentSize()
			self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
			self._handTouch:setPosition(self._CP.x, self._CP.y)
			app.tutorialNode:addChild(self._handTouch)
		end
	end)
end

function QTutorialPhase01Artifact:_openHeroInfo()
	self:clearSchedule()
	self._handTouch:removeFromParent()
	local actorId = self.heros[self.heroIndex]
	self._dialog:selectHeroByActorId(actorId)

	local artifactId = remote.artifact:getArtiactByActorId(actorId)
	if not artifactId then
		self:finished()
		return
	end

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickArtifact()
	end, 0.5)
end

--引导玩家点击真身
function QTutorialPhase01Artifact:_guideClickArtifact()
	self:clearSchedule()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._CP = self._dialog._artifactBox._ccbOwner.btn_touch:convertToWorldSpaceAR(ccp(0,0))
	self._size = self._dialog._artifactBox._ccbOwner.btn_touch:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, id = 5722})
	self._handTouch:setPosition(self._CP.x, self._CP.y)
	app.tutorialNode:addChild(self._handTouch)
end

--真身展示
function QTutorialPhase01Artifact:_showArtifactInfo()
	self._handTouch:removeFromParent()
	local event = { name = QUIWidgetArtifactBox.ARTIFACT_EVENT_CLICK }
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self._dialog:onEvent(event)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideShowDialog()
    end,0.5)
end

--引导对话
function QTutorialPhase01Artifact:_guideShowDialog()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5723")
    self._distance = "left"
    self:createDialogue()
end

--引导玩家点击天赋技能标签
function QTutorialPhase01Artifact:_guideClickSkillBtn()
	self:clearDialgue()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local position = self._dialog._ccbOwner.tab_skill:convertToWorldSpaceAR(ccp(0,0))
	self._CP = ccp(position.x-53, position.y-35)
	self._size = self._dialog._ccbOwner.tab_skill:getContentSize()
	self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, id = 5724})
	self._handTouch:setPosition(self._CP.x, self._CP.y+10)
	app.tutorialNode:addChild(self._handTouch)
end

--天赋技能展示
function QTutorialPhase01Artifact:_showSkillInfo()
    self._handTouch:removeFromParent()
	self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:selectedTabSkill()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showEndDialog()
    end, 0.5)
end

--引导结束对话
function QTutorialPhase01Artifact:_showEndDialog()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5725")
    self:createDialogue()
end

--引导玩家返回魂师总览页面
function QTutorialPhase01Artifact:_allEnd()
    self:clearDialgue()
    self:finished()
end

function QTutorialPhase01Artifact:_openInstence()
    self:clearDialgue()
    self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Artifact:_jumpToEnd()
    app.tutorial._runingStage:jumpFinished()
    self:finished()
end

--移动到指定位置
function QTutorialPhase01Artifact:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Artifact:createDialogue()
    if self._dialogueRight ~= nil and self._distance ~= self._tutorialInfo[1][3] then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
    local heroInfo = db:getCharacterByID(self._tutorialInfo[1][1])
    local name = heroInfo.name or "小舞"
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

function QTutorialPhase01Artifact:_onTouch(event)
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
        end
    end
end

function QTutorialPhase01Artifact:clearSchedule()
    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
end

function QTutorialPhase01Artifact:clearDialgue()
    if self._dialogueRight ~= nil then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
end

return QTutorialPhase01Artifact