
--zxs

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Mount = class("QTutorialPhase01Mount", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")

function QTutorialPhase01Mount:start()
    self._stage:enableTouch(handler(self, self._onTouch))
    self._step = 0
    self._tutorialInfo = {}
    self._perCP = ccp(display.width/2, display.height/2)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:cleanBuildLayer()

    if app.tutorial:checkCurrentDialog() == false then 
        self:_jumpToEnd()
        return 
    end
    self._mountId = 1501

    app:getClient():guidanceRequest(5706, function()end)

    local stage = app.tutorial:getStage()
    stage.mount = 1
    app.tutorial:setStage(stage)
    app.tutorial:setFlag()

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMount)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockMount)
    end
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01Mount:stepManager()
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
        self:_next()
    elseif self._step == 7 then
        self:_closeAvatar()
    elseif self._step == 8 then
        self:_selectMount()
    elseif self._step == 9 then
        self:_clickMount()
    elseif self._step == 10 then
        self:_clickAvatar()
    elseif self._step == 11 then
        self:_equipMount()
    elseif self._step == 12 then
        self:_allEnd()
    end
end

--引导开始
function QTutorialPhase01Mount:_guideStart()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5706")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Mount:chooseNextStage()
    self:clearDialgue()
    self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
            (self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
        self._step = 3
        self:_guideClickHero()
    else        
        self:_guideClickScaling()
    end
end 

--引导玩家点击扩展标签
function QTutorialPhase01Mount:_guideClickScaling()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._ccbOwner.btn_home:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Mount:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHero()
    end,0.5)
end

--引导玩家点击英雄总览按钮
function QTutorialPhase01Mount:_guideClickHero()
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

function QTutorialPhase01Mount:_openHero()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:_onTriggerOffSideMenu()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHeroFrame()
    end,0.5)
end

--引导玩家点击英雄头像
function QTutorialPhase01Mount:_guideClickHeroFrame()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_mount:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_mount:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01Mount:_openCopy()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuMount()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickBattle()
    end, 1)
end

--引导玩家点击下一步
function QTutorialPhase01Mount:_guideClickBattle()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._curIndex = 1
    local mounts = self._dialog._mountList
    for index, mount in pairs(mounts) do
        if mount.mountId == self._mountId then
            self._curIndex = index
            break
        end
    end
    local mountFrame = self._dialog._listView:getItemByIndex(self._curIndex)
    if mountFrame then
        self._CP = mountFrame._ccbOwner.card_size:convertToWorldSpaceAR(ccp(0,0))
        self._size = mountFrame._ccbOwner.card_size:getContentSize()
        self._perCP = ccp(display.width/2, display.height/2)
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    else
        self:_jumpToEnd()
    end
end

function QTutorialPhase01Mount:_next()
    self._handTouch:removeFromParent()
    local mountFrame = self._dialog._listView:getItemByIndex(self._curIndex)
    mountFrame:_onTriggerClick()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
end

function QTutorialPhase01Mount:_guideCloseCard()
    self:clearSchedule()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
    self._CP = {x = 0, y = 0}
    self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01Mount:_closeAvatar()
    self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    self._dialog._canCloseDialog = true
    self._dialog:_backClickHandler()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_combineFinish()
    end, 0.5)
end

function QTutorialPhase01Mount:_combineFinish()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5707")
    self:createDialogue()
    self._step = 11
end

function QTutorialPhase01Mount:_selectMount()
    self:clearDialgue()
    self:clearSchedule()
    self._curIndex = 1
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    local mounts = self._dialog._mountList
    for index, mount in pairs(mounts) do
        if mount.mountId == self._mountId then
            self._curIndex = index
            break
        end
    end
    local callback = function()
        local mountFrame = self._dialog._listView:getItemByIndex(self._curIndex)
        if mountFrame then
            self._CP = mountFrame._ccbOwner.card_size:convertToWorldSpaceAR(ccp(0,0))
            self._size = mountFrame._ccbOwner.card_size:getContentSize()
            self._perCP = ccp(display.width/2, display.height/2)
            self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
            self._handTouch:setPosition(self._CP.x, self._CP.y)
            app.tutorialNode:addChild(self._handTouch)
        else
            self:_jumpToEnd()
        end
    end
    self._dialog:runTo(self._mountId, callback)
end

function QTutorialPhase01Mount:_clickMount()
    self._handTouch:removeFromParent()
    local mountFrame = self._dialog._listView:getItemByIndex(self._curIndex)
    mountFrame:_onTriggerClick()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showMountInfo()
    end, 0.5)
end

function QTutorialPhase01Mount:_showMountInfo()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._ccbOwner.btn_avatar:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner.btn_avatar:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Mount:_clickAvatar()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:_onTriggerAvatar()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showHeroSelect()
    end,0.5)
end

function QTutorialPhase01Mount:_showHeroSelect()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    local heros = self._dialog._datas
    self._curIndex = 1
    self._actorId = 1001
    for index, actorId in pairs(heros) do
        if remote.herosUtil:getHeroByID(actorId) ~= nil then
            self._curIndex = index
            self._actorId = actorId
            break
        end
    end
    local heroFrame = self._dialog._listView:getItemByIndex(self._curIndex)
    if heroFrame then
        self._CP = heroFrame._ccbOwner.card_size:convertToWorldSpaceAR(ccp(0,0))
        self._size = heroFrame._ccbOwner.card_size:getContentSize()
        self._perCP = ccp(display.width/2, display.height/2)
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    else
        self:_jumpToEnd()
    end
end

function QTutorialPhase01Mount:_equipMount()
    self._handTouch:removeFromParent()
    self._dialog:selectHeroByActorId(self._actorId)
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showEndDialog()
    end,1.5)
end

function QTutorialPhase01Mount:_showEndDialog()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("5707")
    self:createDialogue()
end

--引导玩家返回魂师总览页面
function QTutorialPhase01Mount:_allEnd()
    self:clearDialgue()
    self:finished()
end

function QTutorialPhase01Mount:_openInstence()
    self:clearDialgue()
    self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Mount:_jumpToEnd()
    app.tutorial._runingStage:jumpFinished()
    self:finished()
end

--移动到指定位置
function QTutorialPhase01Mount:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Mount:createDialogue()
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

function QTutorialPhase01Mount:_onTouch(event)
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

function QTutorialPhase01Mount:clearSchedule()
    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
end

function QTutorialPhase01Mount:clearDialgue()
    if self._dialogueRight ~= nil then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
end

return QTutorialPhase01Mount