-- @Author: zhouxiaoshu
-- @Date:   2019-06-20 18:04:21
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-09 15:10:02

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01SoulSpirit = class("QTutorialPhase01SoulSpirit", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01SoulSpirit:start()
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
    self._targetId = 2001
    app:getClient():guidanceRequest(6212)

    local stage = app.tutorial:getStage()
    stage.soulSpirit = 1
    app.tutorial:setStage(stage)
    app.tutorial:setFlag()

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSoulSpirit)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockSoulSpirit)
    end
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01SoulSpirit:stepManager()
    if self._step == 0 then
        self:_guideStart()
    elseif self._step == 1 then
        self:chooseNextStage()
    elseif self._step == 2 then
        self:_openScaling()
    elseif self._step == 3 then
        self:_openHero()
    elseif self._step == 4 then
        self:_openCopy()
    elseif self._step == 5 then
        self:_next()
    elseif self._step == 6 then
        self:_closeAvatar()
    elseif self._step == 7 then
        self:_selectTarget()
    elseif self._step == 8 then
        self:_clickTarget()
    elseif self._step == 9 then
        self:_clickAvatar()
    elseif self._step == 10 then
        self:_equipTarget()
    elseif self._step == 11 then
        self:_openScaling2()
    elseif self._step == 12 then
        self:_openInstence()
    elseif self._step == 13 then
        self:_openMap()
    elseif self._step == 14 then
        self:_openHeadInstance()
    elseif self._step == 15 then
        self:_openNext()
    elseif self._step == 16 then
        self:_guideClickSoulSpirit()
    elseif self._step == 17 then
        self:_showSoulSpiritArray()
    elseif self._step == 18 then
        self:_clickTargetSoulSpiritHead()
    elseif self._step == 19 then
        self:_showSoulSpiritInfo()
    end
end

--引导开始
function QTutorialPhase01SoulSpirit:_guideStart()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("6212")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01SoulSpirit:chooseNextStage()
    self:clearDialgue()
    self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self.firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self.firstDialog == nil and self.firstPage.class.__cname == "QUIPageMainMenu" or
            (self.firstDialog ~= nil and self.firstPage._scaling:isVisible()) then
        self._step = 2
        self:_guideClickHero()
    else        
        self:_guideClickScaling()
    end
end 

--引导玩家点击扩展标签
function QTutorialPhase01SoulSpirit:_guideClickScaling()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._ccbOwner.btn_home:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulSpirit:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHero()
    end,0.5)
end

--引导玩家点击英雄总览按钮
function QTutorialPhase01SoulSpirit:_guideClickHero()
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

function QTutorialPhase01SoulSpirit:_openHero()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:preSoulSpiritAni()
    page._scaling:_onTriggerOffSideMenu()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showSoulSpiritAni()
    end, 0.5)
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01SoulSpirit:_showSoulSpiritAni()
    self:clearSchedule()

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.class.__cname == "QUIPageMainMenu" then
        local callback = function()
            self:_guideClickHeroFrame()
        end
        page:showSoulSpiritAni(callback)
    else
        self:_jumpToEnd()
    end
end

--引导玩家点击英雄头像
function QTutorialPhase01SoulSpirit:_guideClickHeroFrame()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_soulSpirit:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_soulSpirit:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01SoulSpirit:_openCopy()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuSoulSpirit()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickBattle()
    end, 1)
end

--引导玩家点击下一步
function QTutorialPhase01SoulSpirit:_guideClickBattle()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._curIndex = 1
    local lists = self._dialog._data or {}
    for index, list in pairs(lists) do
        if list.id == self._targetId then
            self._curIndex = index
            break
        end
    end
    local frame = self._dialog._listView:getItemByIndex(self._curIndex)
    if frame then
        self._CP = frame._ccbOwner.card_size:convertToWorldSpaceAR(ccp(0,0))
        self._size = frame._ccbOwner.card_size:getContentSize()
        self._perCP = ccp(display.width/2, display.height/2)
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    else
        self:_jumpToEnd()
    end
end

function QTutorialPhase01SoulSpirit:_next()
    self._handTouch:removeFromParent()
    local frame = self._dialog._listView:getItemByIndex(self._curIndex)
    local info = frame:getSoulSpiritInfo()
    frame:_onTriggerClick()
    if info.isHave then
    	self._step = 8
       	self:_showTargetInfo()
    else
    	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
	end	
end

function QTutorialPhase01SoulSpirit:_guideCloseCard()
    self:clearSchedule()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
    self._CP = {x = 0, y = 0}
    self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01SoulSpirit:_closeAvatar()
    self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    self._dialog._canCloseDialog = true
    self._dialog:_backClickHandler()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_combineFinish()
    end, 0.5)
end

function QTutorialPhase01SoulSpirit:_combineFinish()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("6213")
    self:createDialogue()
    self._step = 6
end

function QTutorialPhase01SoulSpirit:_selectTarget()
    self:clearDialgue()
    self:clearSchedule()
    self._curIndex = 1
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    local lists = self._dialog._data
    for index, list in pairs(lists) do
        if list.id == self._targetId then
            self._curIndex = index
            break
        end
    end
    local callback = function()
        local frame = self._dialog._listView:getItemByIndex(self._curIndex)
        if frame then
            self._CP = frame._ccbOwner.card_size:convertToWorldSpaceAR(ccp(0,0))
            self._size = frame._ccbOwner.card_size:getContentSize()
            self._perCP = ccp(display.width/2, display.height/2)
            self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
            self._handTouch:setPosition(self._CP.x, self._CP.y)
            app.tutorialNode:addChild(self._handTouch)
        else
            self:_jumpToEnd()
        end
    end
    self._dialog:runTo(self._targetId, callback)
end

function QTutorialPhase01SoulSpirit:_clickTarget()
    self._handTouch:removeFromParent()
    local frame = self._dialog._listView:getItemByIndex(self._curIndex)
    frame:_onTriggerClick()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showTargetInfo()
    end, 0.5)
end

function QTutorialPhase01SoulSpirit:_showTargetInfo()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._ccbOwner.btn_avatar:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner.btn_avatar:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulSpirit:_clickAvatar()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:_onTriggerAvatar()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showHeroSelect()
    end,0.5)
end

function QTutorialPhase01SoulSpirit:_showHeroSelect()
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
        self._CP = heroFrame._ccbOwner.node_size:convertToWorldSpaceAR(ccp(0,0))
        self._size = heroFrame._ccbOwner.node_size:getContentSize()
        self._perCP = ccp(display.width/2, display.height/2)
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    else
        self:_jumpToEnd()
    end
end

function QTutorialPhase01SoulSpirit:_equipTarget()
    self._handTouch:removeFromParent()
    self._dialog:selectHeroByActorId(self._actorId)
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickScaling2()
    end,2.0)
end

--引导玩家点击扩展标签
function QTutorialPhase01SoulSpirit:_guideClickScaling2()
    self:clearSchedule()
    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if dialog and dialog.class.__cname == "QUIDialogSoulSpiritDetail" then
        dialog:disableTouchSwallowTop()
    end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._ccbOwner.btn_home:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--副本
function QTutorialPhase01SoulSpirit:_openScaling2()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickInstence()
    end,0.5)
end

--引导玩家打开关卡界面
function QTutorialPhase01SoulSpirit:_guideClickInstence()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local moveDistance = page._ccbOwner["Node_InstanceIcon"]:convertToWorldSpaceAR(ccp(0, 0))
    page._pageSilder:stopAllAction()
    local speedRateX = page._pageSilder:getSpeedRateByIndex(6)
    page._pageSilder:_onTouch({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = (display.cx - moveDistance.x)/speedRateX, y = 0}})

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        self._CP = self._dialog._ccbOwner["btn_instance"]:convertToWorldSpaceAR(ccp(0,0))
        self._CP.y = self._CP.y + 20
        self._size = self._dialog._ccbOwner["btn_instance"]:getContentSize()
        self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
        self._handTouch:setPosition(self._CP.x, self._CP.y)
        app.tutorialNode:addChild(self._handTouch)
    end, 0.8)
end

function QTutorialPhase01SoulSpirit:_openInstence()
    self._handTouch:removeFromParent()

    self._dialog:_onInstance()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickMap()
    end,0.5)
end

--引导玩家点击第一个副本
function QTutorialPhase01SoulSpirit:_guideClickMap()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog.class.__cname ~= "QUIDialogMap" then
        self:_jumpToEnd()
        return
    end
    local curIndex, curPos = self._dialog:getCurIndex()
    self._curIndex = curIndex
    self._CP = self._dialog._ccbOwner["btn"..curPos.."_normal"]:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner["btn"..curPos.."_normal"]:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01SoulSpirit:_openMap()
    self._handTouch:removeFromParent()
    self._dialog:selectMap(self._curIndex)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickCopy()
    end, 0.5)
end

--引导玩家点击第一个副本
function QTutorialPhase01SoulSpirit:_guideClickCopy()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if self._dialog.class.__cname ~= "QUIDialogInstance" then
        self:_jumpToEnd()
        return
    end
    local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    if dialog and dialog.class.__cname == "QUIDialogDungeonAside" then
        self:_jumpToEnd()
        return
    end
    self._copy = self._dialog:getSelectHead()
    self._CP = self._copy._ccbOwner.btn_head:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._copy._ccbOwner.btn_head:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01SoulSpirit:_openHeadInstance()
    self._handTouch:removeFromParent()
    self._copy:_onTriggerClick()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickNext()
    end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01SoulSpirit:_guideClickNext()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._ccbOwner.btn_battle:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner.btn_battle:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulSpirit:_openNext()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:_onTriggerTeam()

    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:addBackEvent(true)
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showEndDialog()
    end, 0.5)
end

function QTutorialPhase01SoulSpirit:_showEndDialog()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("6214")
    self:createDialogue()
end

--引导玩家点击下一步
function QTutorialPhase01SoulSpirit:_guideClickSoulSpirit()
    self:clearDialgue()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._widgetHeroArray._ccbOwner.soul:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._widgetHeroArray._ccbOwner.soul:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulSpirit:_showSoulSpiritArray()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog._widgetHeroArray:_onTriggerSoul(CCControlEventTouchUpInside)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickSoulSpiritHead()
    end, 0.5)
end

function QTutorialPhase01SoulSpirit:_guideClickSoulSpiritHead()
    self:clearSchedule()
    self._curIndex = 1
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    local lists = self._dialog._widgetHeroArray._items or {}
    for index, list in pairs(lists) do
        if list.data.soulSpiritId == self._targetId then
            self._curIndex = index
            break
        end
    end
    local callback = function()
        local frame = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(self._curIndex)
        if frame then
            self._CP = frame._ccbOwner.sp_head_bg:convertToWorldSpaceAR(ccp(0,0))
            self._size = frame._ccbOwner.sp_head_bg:getContentSize()
            self._perCP = ccp(display.width/2, display.height/2)
            self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
            self._handTouch:setPosition(self._CP.x, self._CP.y)
            app.tutorialNode:addChild(self._handTouch)
        else
            self:_jumpToEnd()
        end
    end
    if self._curIndex > 5 then
        self._dialog._widgetHeroArray:runTo(self._targetId, callback)
    else
        callback()
    end
end

function QTutorialPhase01SoulSpirit:_clickTargetSoulSpiritHead()
    self._handTouch:removeFromParent()
    local frame = self._dialog._widgetHeroArray._listViewLayout:getItemByIndex(self._curIndex)
    frame:_onTriggerHeroOverview()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickSoulSpiritInfo()
    end, 0.5)
end

--引导玩家点击下一步
function QTutorialPhase01SoulSpirit:_guideClickSoulSpiritInfo()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._CP = self._dialog._ccbOwner.btn_soul_spirit:convertToWorldSpaceAR(ccp(0,0))
    self._size = self._dialog._ccbOwner.btn_soul_spirit:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01SoulSpirit:_showSoulSpiritInfo()
    self._handTouch:removeFromParent()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._dialog:_onTriggerSoulInfo()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_allEnd()
    end, 0.5)
end


function QTutorialPhase01SoulSpirit:_allEnd()
    self:clearDialgue()
    self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01SoulSpirit:_jumpToEnd()
    app.tutorial._runingStage:jumpFinished()
    self:finished()
end

--移动到指定位置
function QTutorialPhase01SoulSpirit:_nodeRunAction(posX,posY)
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

function QTutorialPhase01SoulSpirit:createDialogue()
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

function QTutorialPhase01SoulSpirit:_onTouch(event)
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

function QTutorialPhase01SoulSpirit:clearSchedule()
    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
end

function QTutorialPhase01SoulSpirit:clearDialgue()
    if self._dialogueRight ~= nil then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
end

return QTutorialPhase01SoulSpirit