--
-- zxs
-- 仙品引导
--

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01MagicHerb = class("QTutorialPhase01MagicHerb", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetArtifactBox = import("...ui.widgets.artifact.QUIWidgetArtifactBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01MagicHerb:start()
	self._stage:enableTouch(handler(self, self._onTouch))
	self._step = 0
    self._tutorialInfo = {}

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:cleanBuildLayer()

	if app.tutorial:checkCurrentDialog() == false then 
   		self:_jumpToEnd()
        return 
   	end
    
    app:getClient():guidanceRequest(6203, function()end)

	local stage = app.tutorial:getStage()
	stage.magicHerb = 1
	app.tutorial:setStage(stage)
	app.tutorial:setFlag(stage)

	self._perCP = ccp(display.width/2, display.height/2)

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMagicHerb)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMagicHerb)
    end
	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:stepManager()
	end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01MagicHerb:stepManager()
    if self._step == 0 then
        self:_guideStart()
    elseif self._step == 1 then
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
        self:_clickMagicHerbBtn()
    elseif self._step == 8 then
        self:_showMagicHerbInfo()
    elseif self._step == 9 then
        self:_showMagicHerbInfo2()
    elseif self._step == 10 then
        self:_showMagicHerbInfoDialog()
    elseif self._step == 11 then
        self:_showRefineMagicHerb()
    elseif self._step == 12 then
        self:_clickRefineMagicHerb()
    elseif self._step == 13 then
        self:_openEndScaling()
    end
end

--引导开始
function QTutorialPhase01MagicHerb:_guideStart()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("6203")
    self._distance = "left"
    self:createDialogue()
end

--引导开始
function QTutorialPhase01MagicHerb:chooseNextStage()
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
function QTutorialPhase01MagicHerb:_guideClickScaling()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._ccbOwner.btn_home:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01MagicHerb:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHero()
    end,0.5)
end

--引导玩家点击英雄总览按钮
function QTutorialPhase01MagicHerb:_guideClickHero()
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

function QTutorialPhase01MagicHerb:_openHero()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:_onTriggerOffSideMenu()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHeroFrame()
    end,0.5)
end

--引导玩家点击英雄头像
function QTutorialPhase01MagicHerb:_guideClickHeroFrame()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_hero:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_hero:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01MagicHerb:_openCopy()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuHero()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickBattle()
    end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01MagicHerb:_guideClickBattle()
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

function QTutorialPhase01MagicHerb:_openHeroInfo()
	self._handTouch:removeFromParent()
	local actorId = self.heros[self.heroIndex]
	self._dialog:selectHeroByActorId(actorId)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self:_guideClickMagicHerb()
	end, 0.5)
end

function QTutorialPhase01MagicHerb:_guideClickMagicHerb()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._ccbOwner.btn_MagicHerb:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner.tab_MagicHerb:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01MagicHerb:_clickMagicHerbBtn()
    self._handTouch:removeFromParent()
    self._dialog:_onTriggerMagicHerb()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickMagicHerbBox()
    end, 0.5)
end

function QTutorialPhase01MagicHerb:_guideClickMagicHerbBox()
    self:clearDialgue()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog._magicHerb == nil or self._dialog._magicHerb._magicHerbBoxlist == nil or 
        self._dialog._magicHerb._magicHerbBoxlist[1] == nil then
        self:_jumpToEnd()
        return 
    end
    local box = self._dialog._magicHerb._magicHerbBoxlist[1]
    self._CP = box:convertToWorldSpaceAR(ccp(0,0))
    self._size = box:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, id = 6204})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--引导对话
function QTutorialPhase01MagicHerb:_showMagicHerbInfo()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog._magicHerb == nil then
        self:_jumpToEnd()
        return 
    end
    self._dialog._magicHerb:_onClick({pos = 1}, true)
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideAddMagicHerb()
    end, 0.5)
end

--引导对话
function QTutorialPhase01MagicHerb:_guideAddMagicHerb()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    local magicHerbBox = self._dialog._contentListView:getItemByIndex(1)
    if magicHerbBox then
        self._CP = magicHerbBox._ccbOwner.btn_wear:convertToWorldSpaceAR(ccp(0,0))
        self._size = magicHerbBox._ccbOwner.btn_wear:getContentSize()
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    end
end

--引导对话
function QTutorialPhase01MagicHerb:_showMagicHerbInfo2()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    local magicHerbBox = self._dialog._contentListView:getItemByIndex(1)
    magicHerbBox:_onTriggerWear()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickMagicHerbBox2()
    end, 0.5)
end
-- 
function QTutorialPhase01MagicHerb:_guideClickMagicHerbBox2()
    self:clearDialgue()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog._magicHerb == nil or self._dialog._magicHerb._magicHerbBoxlist == nil or 
        self._dialog._magicHerb._magicHerbBoxlist[1] == nil then
        self:_jumpToEnd()
        return 
    end
    local box = self._dialog._magicHerb._magicHerbBoxlist[1]
    self._CP = box:convertToWorldSpaceAR(ccp(0,0))
    self._size = box:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--引导对话
function QTutorialPhase01MagicHerb:_showMagicHerbInfoDialog()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog._magicHerb == nil then
        self:_jumpToEnd()
        return 
    end
    self._dialog._magicHerb:_onClick({pos = 1}, true)
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideRefineMagicHerb()
    end, 0.5)
end

--引导对话
function QTutorialPhase01MagicHerb:_guideRefineMagicHerb()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._ccbOwner.btn_refine:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner.btn_refine:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--引导对话
function QTutorialPhase01MagicHerb:_showRefineMagicHerb()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:_onTriggerRefine()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickRefineMagicHerb()
    end, 0.5)
end

--引导对话
function QTutorialPhase01MagicHerb:_guideClickRefineMagicHerb()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog._refineWidget == nil then
        self:_jumpToEnd()
        return
    end
    self._CP = self._dialog._refineWidget._ccbOwner.btn_ok:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._refineWidget._ccbOwner.btn_ok:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, id = 6205})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--引导对话
function QTutorialPhase01MagicHerb:_clickRefineMagicHerb()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog._refineWidget:_onTriggerOK()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showEndDialog()
    end, 3)
end

--引导结束对话
function QTutorialPhase01MagicHerb:_showEndDialog()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.topLayer):getTopDialog()
    if self._dialog and self._dialog.class.__cname == "QUIDialogMagicHerbSuccess" then
        self._dialog:_backClickHandler()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
        self._size = page._ccbOwner.btn_home:getContentSize()
        self._perCP = ccp(display.width/2, display.height/2)
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    else
        self:finished()
    end
end

function QTutorialPhase01MagicHerb:_openEndScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_allEnd()
    end,0.5)
end

--引导玩家返回魂师总览页面
function QTutorialPhase01MagicHerb:_allEnd()
    self:clearDialgue()
    self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01MagicHerb:_jumpToEnd()
    app.tutorial._runingStage:jumpFinished()
    self:finished()
end

--移动到指定位置
function QTutorialPhase01MagicHerb:_nodeRunAction(posX,posY)
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

function QTutorialPhase01MagicHerb:createDialogue()
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

function QTutorialPhase01MagicHerb:_onTouch(event)
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

function QTutorialPhase01MagicHerb:clearSchedule()
    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
end

function QTutorialPhase01MagicHerb:clearDialgue()
    if self._dialogueRight ~= nil then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
end

return QTutorialPhase01MagicHerb