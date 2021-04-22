-- @Author: liaoxianbo
-- @Date:   2020-01-08 11:29:22
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-12 16:02:29

local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhase01Godarm = class("QTutorialPhase01Godarm", QTutorialPhase)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("..event.QTutorialEvent")
local QTutorialDirector = import("..QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")

function QTutorialPhase01Godarm:start()
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
    -- heroShop^1;eliteBox^1;jewelry^2;metal^1;gloryTower^1;intencify^1;invasion^1;soulSpirit^1;night^0;thunder^1;addHero^1;unlockHelp^2;archaeology^1;training^1;artifact^1;secretary^1;monopoly^1;fightClub^1;heroYwd^0;storm^1;mockBattle^1;strengthen^1;eliteStar^1;addHeroYwd^0;gemstone^1;convey^1;collegeTrain^3;ssgemstone^1;blackRock^1;dragonTotem^0;sotoTeam^1;totemChallenge^0;mount^1;silver^1;activity^1;call^2;guideEnd^0;maritime^1;addMoney^1;spar^1;sanctuary^1;skill^1;breakth^1;sunWar^1;refine^0;useSkin^0;magicHerb^1;glyph^1;forced^6;enchant^1;godarm^1;arena^1
    -- 11091373404456800
    self._targetId = 30001
   app:getClient():guidanceRequest(12006)

    local stage = app.tutorial:getStage()
    stage.godarm = 1
    app.tutorial:setStage(stage)
    app.tutorial:setFlag()

    if app.tip.UNLOCK_TIP_ISTRUE == false then
        app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockGodarm)
    else
        app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockGodarm)
    end
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:stepManager()
    end, UNLOCK_DELAY_TIME + 0.5)
end

--步骤管理
function QTutorialPhase01Godarm:stepManager()
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
    end
end

--引导开始
function QTutorialPhase01Godarm:_guideStart()
    self:clearSchedule()
    self._tutorialInfo, self._sound = app.tutorial:splitTutorialWord("12006")
    self._distance = "left"
    self:createDialogue()
end

function QTutorialPhase01Godarm:chooseNextStage()
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
function QTutorialPhase01Godarm:_guideClickScaling()
    self:clearDialgue()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._ccbOwner.btn_home:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._ccbOwner.btn_home:getContentSize()
    self._perCP = ccp(display.width/2, display.height/2)
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

function QTutorialPhase01Godarm:_openScaling()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:_onTriggerHome()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickHero()
    end,0.5)
end

--引导玩家点击英雄总览按钮
function QTutorialPhase01Godarm:_guideClickHero()
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

function QTutorialPhase01Godarm:_openHero()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page._scaling:preGodarmAni()
    page._scaling:_onTriggerOffSideMenu()

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_showGodarmtAni()
    end, 0.5)
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Godarm:_showGodarmtAni()
    self:clearSchedule()

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.class.__cname == "QUIPageMainMenu" then
        local callback = function()
            self:_guideClickHeroFrame()
        end
        page:showGodarmAni(callback)
    else
        self:_jumpToEnd()
    end
end

--引导玩家点击英雄头像
function QTutorialPhase01Godarm:_guideClickHeroFrame()
    self:clearSchedule()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._CP = page._scaling._ccbOwner.btn_godarm:convertToWorldSpaceAR(ccp(0,0))
    self._size = page._scaling._ccbOwner.btn_godarm:getContentSize()
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    self._handTouch:setPosition(self._CP.x, self._CP.y)
    app.tutorialNode:addChild(self._handTouch)
end

--打开关卡页面
function QTutorialPhase01Godarm:_openCopy()
    self._handTouch:removeFromParent()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._dialog = page._scaling:_onButtondownSideMenuGodarm()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_guideClickBattle()
    end, 1)
end

--引导玩家点击下一步
function QTutorialPhase01Godarm:_guideClickBattle()
    self:clearSchedule()
    self._dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    self._curIndex = 1
    local lists = self._dialog._godarmList or {}
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

function QTutorialPhase01Godarm:_next()
    self._handTouch:removeFromParent()
    local frame = self._dialog._listView:getItemByIndex(self._curIndex)
    local info = frame:getGodarmInfo()
    frame:_onTriggerClick()
    if info.isHave then
    	self._step = 8
       	self:_showTargetInfo()
    else
    	QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
	end	
end

function QTutorialPhase01Godarm:_guideCloseCard()
    self:clearSchedule()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialEvent.EVENT_CALL_HERO_SUCCESS, handler(self, self._guideCloseCard))
    self._CP = {x = 0, y = 0}
    self._size = {width = display.width*2, height = display.height*2}
end

function QTutorialPhase01Godarm:_closeAvatar()
    self._dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
    self._dialog._canCloseDialog = true
    self._dialog:_backClickHandler()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self:_allEnd()
    end, 0.5)
end


function QTutorialPhase01Godarm:_allEnd()
    self:clearDialgue()
    self:finished()
end

--如果出错则直接跳掉引导过程
function QTutorialPhase01Godarm:_jumpToEnd()
    app.tutorial._runingStage:jumpFinished()
    self:finished()
end

--移动到指定位置
function QTutorialPhase01Godarm:_nodeRunAction(posX,posY)
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

function QTutorialPhase01Godarm:createDialogue()
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

function QTutorialPhase01Godarm:_onTouch(event)
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

function QTutorialPhase01Godarm:clearSchedule()
    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
end

function QTutorialPhase01Godarm:clearDialgue()
    if self._dialogueRight ~= nil then
        self._dialogueRight:removeFromParent()
        self._dialogueRight = nil
    end
end

return QTutorialPhase01Godarm