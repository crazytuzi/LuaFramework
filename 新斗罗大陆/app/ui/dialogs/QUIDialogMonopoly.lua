--
-- Author: Kumo.Wang
-- 大富翁主场景
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopoly = class("QUIDialogMonopoly", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QRichText = import("...utils.QRichText") 
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIWidgetTutorialFreeDialogue = import("..widgets.QUIWidgetTutorialFreeDialogue")
local QUIWidgetMonopolyMap = import("..widgets.QUIWidgetMonopolyMap")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogMonopoly:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_main.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerCheat", callback = handler(self, self._onTriggerCheat)},
        {ccbCallbackName = "onTriggerFlower", callback = handler(self, self._onTriggerFlower)},
		{ccbCallbackName = "onTriggerMainHero", callback = handler(self, self._onTriggerMainHero)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
        {ccbCallbackName = "onTriggerDebuff", callback = handler(self, self._onTriggerDebuff)},
        {ccbCallbackName = "onTriggerBoss", callback = handler(self, self._onTriggerBoss)},
        {ccbCallbackName = "onTriggerSet", callback = handler(self, self._onTriggerSet)},
        {ccbCallbackName = "onTriggerOneCheat",callback = handler(self, self._onTriggerOneCheat)},
        {ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
	}
	QUIDialogMonopoly.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
    if page.topBar then
        page.topBar:showWithMonopoly()
    end

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MONOPOLY) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.MONOPOLY)
    end

    self:_init()
end

function QUIDialogMonopoly:viewDidAppear()
    -- print("QUIDialogMonopoly:viewDidAppear()")
	QUIDialogMonopoly.super.viewDidAppear(self)
	self:addBackEvent(false)

    self._monopolyProxy = cc.EventProxy.new(remote.monopoly)
    self._monopolyProxy:addEventListener(remote.monopoly.AUTO_GO, handler(self, self._monopolyProxyHandler))
    self._monopolyProxy:addEventListener(remote.monopoly.MOVE_END, handler(self, self._monopolyProxyHandler))
    self._monopolyProxy:addEventListener(remote.monopoly.UPDATE_INFO, handler(self, self._monopolyProxyHandler))
    self._monopolyProxy:addEventListener(remote.monopoly.EVENT_COMPLETED, handler(self, self._monopolyProxyHandler))
    self._monopolyProxy:addEventListener(remote.monopoly.NEW_DAY, handler(self, self._monopolyProxyHandler))
    self._monopolyProxy:addEventListener(remote.monopoly.NEW_MAP, handler(self, self._monopolyProxyHandler))
    self._monopolyProxy:addEventListener(remote.monopoly.ONE_AUTO_GO, handler(self, self._monopolyProxyHandler))

    if not app.unlock:checkLock("UNLOCK_BINGHUOLIANGYIYAN_SHEZHI", false) then
       self._ccbOwner.btn_set:setVisible(false)
       self._ccbOwner.btn_setlabel:setVisible(false)
    else
       self._ccbOwner.node_set_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_BINGHUOLIANGYIYAN_SHEZHI"..remote.user.userId) )       
    end

    if not app.unlock:checkLock("UNLOCK_BINHUO_YIJIAN",false) then
       self._ccbOwner.node_oneCheat:setVisible(false)
    else
       self._ccbOwner.node_oneCheat_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_BINHUO_YIJIAN"..remote.user.userId) )
    end

    remote.monopoly:setMonopolySetConfig()


    self:_initUI()
    self:_checkGridEventState()
end

function QUIDialogMonopoly:viewWillDisappear()
    -- print("QUIDialogMonopoly:viewWillDisappear()")
	QUIDialogMonopoly.super.viewWillDisappear(self)
	self:removeBackEvent()

    remote.monopoly.beginOneCheatState = false
    remote.monopoly.notEnoughToken = false
    remote.monopoly.buyDiceNumFlag = false

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    self:_removeAction()

    if self._map then
        self._map:removeEventListener(QUIWidgetMonopolyMap.Map_Move)
    end

    self._monopolyProxy:removeAllEventListeners()

    if self._moveEndScheduler then
        scheduler.unscheduleGlobal(self._moveEndScheduler)
        self._moveEndScheduler = nil
    end

    if self._cloudManager then
        self._cloudManager:stopAnimation()
        self._cloudManager = nil
    end

    if self._showDiceScheduler then
        scheduler.unscheduleGlobal(self._showDiceScheduler)
        self._showDiceScheduler = nil
    end

    if self._talkHandler ~= nil then
        scheduler.unscheduleGlobal(self._talkHandler)
        self._talkHandler = nil
    end

    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end

    if self._schedulerTimeHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerTimeHandler)
        self._schedulerTimeHandler = nil
    end
end

function QUIDialogMonopoly:getMapWidget()
    return self._map
end

function QUIDialogMonopoly:_monopolyProxyHandler(event)
    -- print("QUIDialogMonopoly:_monopolyProxyHandler(event)", event.name)
    if event.name == remote.monopoly.EVENT_COMPLETED then
        self:_checkGridEventState()
    elseif event.name == remote.monopoly.NEW_MAP then
        if self._cloudManager then
            self._cloudManager:runAnimationsForSequenceNamed("open")
        else
            self._isMapEndBoo = false
            self._isMove = false
            if self._map then
                if self._map.creatMap then
                    self._map:creatMap()
                end
                if self._map.autoCheckActorPos then
                    self._map:autoCheckActorPos()
                end
                if self._map.setMapMoveState then
                    self._map:setMapMoveState(self._isMove)
                end
            end
            self:_checkGridEventState()
        end
    elseif event.name == remote.monopoly.NEW_DAY then
        self:_initMainHeroUI()
    elseif event.name == remote.monopoly.UPDATE_INFO then
        self:_initDiceInfo()
        self:_initBossUI()
        self:_initMainHeroUI()
        self:_updateRedTips()
    elseif event.name == remote.monopoly.AUTO_GO then
        self:_onTriggerGo()
    elseif event.name == remote.monopoly.MOVE_END then
        self:_checkGridEventState()
    elseif event.name == remote.monopoly.ONE_AUTO_GO then
        self:_initBtnState(true)
        self._map:showOneTrigerGoEffect()
        self:_oneTriggerGo()
    end
end

-- 地图初始化，相对于屏幕是上下左右居中摆放（这一点不能变，重要）
function QUIDialogMonopoly:_madeTouchLayer()
    self._pageWidth = display.width
    self._pageHeight = display.height
    self._mapContent = self._ccbOwner.node_map
    self._mapWidth = 0
    self._mapHeight = 0

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.node_map:getParent(), self._pageWidth, self._pageHeight, -self._pageWidth/2, -self._pageHeight/2, handler(self, self._onTouchEvent))

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
end

function QUIDialogMonopoly:_isOnTriggerMaterial(x, y)
    for index, _ in pairs(remote.monopoly.materialTbl) do
        local tbl = remote.monopoly:getMaterialTouchRegionByColour(index)
        if x >= tbl[1] and x <= tbl[2] and y >= tbl[3] and y <= tbl[4] then
            return true, index
        end
    end
    return false
end

function QUIDialogMonopoly:_onTriggerMaterial(colour)
    local config = remote.monopoly:getGridColorConfig(colour)
    if config and config.text then
        app.tip:floatTip(config.text)
    end
end

function QUIDialogMonopoly:_onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end

    if event.name == "began" then
        self._tmpX = event.x
        self._tmpY = event.y
    elseif event.name == "ended" then
        if math.abs(event.x - self._tmpX) <= 5 and math.abs(event.y - self._tmpY) <= 5 then
            if not self._isTouchScreen then
                local isOnTrigger, colour = self:_isOnTriggerMaterial(event.x, event.y)
                if isOnTrigger then
                    self:_onTriggerMaterial(colour)
                else
                    if self._map and self._map.onTriggerGrid then
                        self._map:onTriggerGrid(self._map:convertToNodeSpace(ccp(event.x, event.y)).x, self._map:convertToNodeSpace(ccp(event.x, event.y)).y)
                    end
                end
            end
        end
        self._isTouchScreen = false
    end

    if self._mapWidth <= self._pageWidth and self._mapHeight <= self._pageHeight then
        return 
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == QUIGestureRecognizer.EVENT_SWIPE_GESTURE then
    elseif event.name == "began" then
        self:_removeAction()
        self._startX = event.x
        self._startY = event.y

        self._mapX = self._mapContent:getPositionX()
        self._mapY = self._mapContent:getPositionY()
    elseif event.name == "moved" then
        if math.abs(event.x - self._startX) > 5 then
            self._isMove = true
            local offsetX = self:_checkMapX(self._mapX + event.x - self._startX)
            self._mapContent:setPositionX(offsetX)
        end

        if math.abs(event.y - self._startY) > 5 then
            self._isMove = true
            local offsetY = self:_checkMapY(self._mapY + event.y - self._startY)
            self._mapContent:setPositionY(offsetY)
        end
        self._map:setMapMoveState(self._isMove)
    elseif event.name == "ended" then
        if self._moveEndScheduler then
            scheduler.unscheduleGlobal(self._moveEndScheduler)
            self._moveEndScheduler = nil
        end
        self._moveEndScheduler = scheduler.performWithDelayGlobal(self:safeHandler(function ()
                    self._isMove = false
                    self._map:setMapMoveState(self._isMove)
                    end), 10)
    end
end

function QUIDialogMonopoly:_contentRunAction(posX, posY)
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(0.5, ccp(posX, posY))
    local speed = CCEaseExponentialOut:create(curveMove)
    actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
            self:_removeAction()
        end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._mapContent:runAction(ccsequence)
end

function QUIDialogMonopoly:_removeAction()
    if self._actionHandler ~= nil then
        self._mapContent:stopAction(self._actionHandler)        
        self._actionHandler = nil
    end
end

function QUIDialogMonopoly:_resetAll()
    self._ccbOwner.tf_refineMedicineProportion:setString("当前炼药成功率0%")
    self._ccbOwner.tf_material_1:setString("0")
    self._ccbOwner.tf_material_2:setString("0")
    self._ccbOwner.tf_material_3:setString("0")
    self._ccbOwner.tf_material_4:setString("0")
    self._ccbOwner.tf_boss_info:setString("帮独孤博解毒后领取奖励，进度：0/6")
    self._ccbOwner.tf_dice_count:setString("0/15")

    self._ccbOwner.tf_mainHeroName:setVisible(false)
    self._ccbOwner.tf_mainHeroInfo:setVisible(false)
    -- self._ccbOwner.ly_baseView:setVisible(false)
    self._ccbOwner.btn_reviewFinalReward:setVisible(true)
    self._ccbOwner.btn_reviewFinalReward_big:setVisible(true)
    self._ccbOwner.btn_reviewMainHero:setVisible(true)
    self._ccbOwner.btn_plus:setVisible(true)
    self._ccbOwner.btn_plus_big:setVisible(true)
    self._ccbOwner.btn_flower:setVisible(true)
    self._ccbOwner.node_btnGo:setVisible(true)
    self._ccbOwner.btn_go:setVisible(true)
    self._ccbOwner.btn_cheat:setVisible(true)
    self._ccbOwner.flower_tips:setVisible(false)
    self._ccbOwner.node_mainHeroHead:setVisible(true)
    self._ccbOwner.node_map:setVisible(true)
    self._ccbOwner.node_showGoNumber:setVisible(true)
    self._ccbOwner.node_showGoAnimation:setVisible(true)
    self._ccbOwner.node_nike:setVisible(true)
    self._ccbOwner.node_curPoison:setVisible(true)

    self._ccbOwner.node_mainHeroHead:removeAllChildren()
    self._ccbOwner.node_map:removeAllChildren()
    self._ccbOwner.node_showGoNumber:removeAllChildren()
    self._ccbOwner.node_nike:removeAllChildren()
    self._ccbOwner.node_curPoison:removeAllChildren()

    for i = 1, #remote.monopoly.formulaTbl, 1 do
        local poisonImg = remote.monopoly:getPoisonImgById(i)
        local node = self._ccbOwner["node_poison_"..i]
        if node then
            if poisonImg then
                node:addChild(poisonImg)
                node:setVisible(true)
            else
                node:setVisible(false)
            end
        end
    end

    for index, itemId in pairs(remote.monopoly.materialTbl) do
        local node = self._ccbOwner["node_material_"..index]
        local config = remote.monopoly:getItemConfigByID(itemId)
        if node then
            if config and config.icon then
                local sp = CCSprite:create(config.icon)
                node:removeAllChildren()
                node:addChild(sp)
                node:setVisible(true)
                self:_saveMaterialTouchRegion(index, node, sp)
            else
                node:setVisible(false)
            end
        end
    end

    self._facEffect = tolua.cast(self._ccbOwner.fca_effect, "QFcaSkeletonView_cpp")
    self._facEffect:stopAnimation()
    self._facEffect:setVisible(false)
end

function QUIDialogMonopoly:_saveMaterialTouchRegion(colour, node, sp)
    if not colour or not node or not sp then return end

    local cx = node:getParent():convertToWorldSpace(ccp(node:getPosition())).x
    local cy = node:getParent():convertToWorldSpace(ccp(node:getPosition())).y
    local w = sp:getContentSize().width  * node:getScaleX() * sp:getScaleX()
    local h = sp:getContentSize().height * node:getScaleY() * sp:getScaleY()
    -- print(colour, cx, cy, w, h)
    local tbl = {cx-w/2, cx+w/2, cy-h/2, cy+h/2}
    remote.monopoly:setMaterialTouchRegionByColour(colour, tbl)
end

function QUIDialogMonopoly:_init()
    self:_resetAll()

    self._stepList = {}
    self._showNikeList = {}
    self._stepIndex = 1
    self._isMapEndBoo = false
    self._curPosX = display.width/2
end

function QUIDialogMonopoly:_initUI()
    self:_madeTouchLayer()
    self:_initMapUI()
    self:_initDiceInfo()
    self:_initMainHeroUI()
    self:_initBossUI()
    self:_initBtnState(false)
end

function QUIDialogMonopoly:_initBtnState(isBegin)
    self._ccbOwner.node_btnGo:setVisible(not isBegin)
    self._ccbOwner.node_stop:setVisible(isBegin)
    if not isBegin then
        self._map:hideOneTrigerGoEffect()
        remote.monopoly.buyDiceNumFlag = false
    end
end
function QUIDialogMonopoly:_initDiceInfo()
    self._ccbOwner.tf_dice_count:setString(remote.monopoly:getCurDiceCount().." / "..remote.monopoly:getBaseDiceCount())
end

function QUIDialogMonopoly:_initMapUI()
    if self._map and self._mapId and self._mapId == remote.monopoly.monopolyInfo.mapId then return end
    self._mapId = remote.monopoly.monopolyInfo.mapId
    -- self._map = QUIWidgetMonopolyMap.new({mapId = remote.monopoly.monopolyInfo.mapId, baseView = self._ccbOwner.ly_baseView})
    self._map = QUIWidgetMonopolyMap.new({mapId = remote.monopoly.monopolyInfo.mapId, baseView = self._ccbOwner.node_baseView})
    self._map:addEventListener(QUIWidgetMonopolyMap.Map_Move, self:safeHandler(handler(self, self._autoMapMove)))
    self._map:addEventListener(QUIWidgetMonopolyMap.Actor_Move_End, self:safeHandler(handler(self, self._actorMoveEnd)))
    self._map:addEventListener(QUIWidgetMonopolyMap.Actor_Move, self:safeHandler(handler(self, self._actorMoveEnd)))
    self._ccbOwner.node_map:addChild(self._map)

    self._mapWidth, self._mapHeight = self._map:getMapSize()
end

function QUIDialogMonopoly:_autoMapMove(event)
    if event.name == QUIWidgetMonopolyMap.Map_Move then
        if self._isMove then return end
        local x = self:_checkMapX(self._mapContent:getPositionX() + event.moveX)
        local y = self:_checkMapY(self._mapContent:getPositionY() + event.moveY)
        -- print(self._mapContent:getPositionX(), self._mapContent:getPositionX(), x, y)
        self:_contentRunAction(x, y)
    end
end

function QUIDialogMonopoly:_actorMoveEnd(event)
    -- print("QUIDialogMonopoly:_actorMoveEnd(event)", event.name)
    if event.name == QUIWidgetMonopolyMap.Actor_Move_End then
        -- 记录当三当前位置
        self._curPosX = event.curPosX
        self:_checkGridEventState()
    elseif event.name == QUIWidgetMonopolyMap.Actor_Move then
        local standGridId = event.curGridIndex
        self:_checkNearFlowerEvent(standGridId)
    end
end

-- 每次第一次进入这个功能、每次Actor停下、每次事件触发完成拿到response之后，要调用一下这个方法，通过格子事件状态来判断接下去的行为
function QUIDialogMonopoly:_checkGridEventState()
    -- 优先领取终极大奖
    if remote.monopoly.monopolyInfo.removePoisonCount >= #remote.monopoly.formulaTbl then
        if remote.monopoly.beginOneCheatState then
            self:oneGetBossAwards()
        else
            self:_onTriggerBoss()
            self._showNikeList = {}
        end
        return
    end

    -- 这里先判断一下，用于断线重连的时候，确定格子是不是起点
    -- 事件结束即为起点
    -- 事件没有结束，则属于终点，触发了MONOPOLY_MOVE_EVENT，但是没有完成事件，则继续做事件
    -- 如果，断线前连MONOPOLY_MOVE_EVENT也没有触发，那么nowGridId和nowFootIndex都应该是之前的数据，重新投骰子，重新走
    local curGridId = remote.monopoly.monopolyInfo.nowGridId
    local curGridInfo = remote.monopoly.monopolyInfo.gridInfos[curGridId]
    -- 这里需要判断下curGridInfo是否存在，如果curGridId为0的时候，curGridInfo是不存在的。
    if curGridInfo and curGridInfo.state ~= remote.monopoly.Event_State_End then
        self:_startGridEvent(curGridInfo.eventId, curGridId, curGridInfo.colour, curGridInfo.param)
        self:_checkBtnGoState(true)
        return
    end
    if curGridId == remote.monopoly:getMaxGridId() then
        self:_checkToChangeMap()
        return
    end

    print("[Kumo] BONUS ", remote.monopoly.beginOneCheatState, remote.monopoly.monopolyInfo.randomFootGroup, remote.monopoly.monopolyInfo.hiddenRewardExist)
    if not remote.monopoly.beginOneCheatState then --一键投掷不显示奇遇界面
        -- 触发Bonus
        if remote.monopoly.monopolyInfo.randomFootGroup and remote.monopoly.monopolyInfo.hiddenRewardExist then
            while true do
                local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
                if dialog then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                else
                    break
                end
            end

            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyBonus", options = {callback = function()
                    remote.monopoly.monopolyInfo.randomFootGroup = nil
                    if self._tempPrizes then
                        remote.monopoly:showRewardForTips(self._tempPrizes)
                        self._tempPrizes = nil
                    end
                    self:_checkGridEventState()
                end}}, {isPopCurrentDialog = false})
           
            return
        end
    end

    local standGridId = self:_getStandGridId()
    -- 停下来后检测是否靠近仙品，并提示
    self:_checkNearFlowerEvent(standGridId, true)

    -- 接下去是判断正常走路触发的事件
    -- 所以，没有self._stepList或者#self._stepList < self._stepIndex，则视为还没开始投骰子或者已经走完了。
    -- 注意，途径炼药炉，虽然也会触发事件，但是如果不是终点，后端是不应该记为nowGridId数据的
    if not self._stepList or #self._stepList < self._stepIndex then
        self._isActorMove = false
        self._startGridId = nil
        self:_checkBtnGoState()
        if remote.monopoly.beginOneCheatState then
            self:_oneTriggerGo()
        end        
        return
    end

    local standGridInfo = remote.monopoly.monopolyInfo.gridInfos[standGridId]
    if standGridInfo and standGridInfo.state ~= remote.monopoly.Event_State_End then
        self:_startGridEvent(standGridInfo.eventId, standGridId, standGridInfo.colour, standGridInfo.param)
    else
        -- 格子事件触发完毕
        self._stepIndex = self._stepIndex + 1
        if #self._stepList >= self._stepIndex then
            -- 如果还有剩余的步数，就继续走
            self._map:actorMoveTo(self:_getStandGridId())
        else
            -- 如果还没有剩余的步数，就结束这轮投骰子的行为
            self._isActorMove = false
            self._startGridId = nil
            self:_checkBtnGoState()
            self:_checkToChangeMap()
            if remote.monopoly.beginOneCheatState then
                self:_oneTriggerGo()
            end
        end
    end
end

-- 检测是否靠近仙品步数 n <= 6
function QUIDialogMonopoly:_checkNearFlowerEvent(standGridId, isShow)
    local gridInfos = remote.monopoly.monopolyInfo.gridInfos
    local step = 0
    local isNearFlower = false
    for index = standGridId+1, #gridInfos do
        if gridInfos[index].eventId == remote.monopoly.flowerEventId then
            isNearFlower = true
            break
        end        
        step = step + 1
        if step >= 6 then
            break
        end
    end

    -- 停下来提示
    if isShow and isNearFlower then
        if not self._flowerTips then
            local tips = "前方有仙品出现，  \n注意使用遥控骰子！"
            if self._curPosX and self._curPosX > display.width/2 then
                self._flowerTips = QUIWidgetTutorialFreeDialogue.new({model = QUIWidgetTutorialFreeDialogue.RIGHT, words = tips})
                self._flowerTips:setPosition(-display.width/2+100, -50)
            else
                self._flowerTips = QUIWidgetTutorialFreeDialogue.new({model = QUIWidgetTutorialFreeDialogue.LEFT, words = tips})
                self._flowerTips:setPosition(display.width/2-100, -50)
            end
            self._ccbOwner.node_cloud:addChild(self._flowerTips)
        end
    end

    -- 移动的时候移除
    if not isNearFlower then
        if self._flowerTips then
            self._flowerTips:removeFromParent()
            self._flowerTips = nil
        end
    end
end

-- 这里的直接获得道具的事件，直接请求MONOPOLY_MOVE_EVENT的格子事件一并处理。特殊的事情，如炼药、猜拳、答题、仙品、购买等，再之后另弹出界面做另外请求
-- 注意，路过的格子，不发MONOPOLY_MOVE_EVENT，比如路过炼药炉，直接做炼药的弹出界面做另外请求
function QUIDialogMonopoly:_startGridEvent( eventId, gridId, colour, param )
    if #self._stepList <= self._stepIndex and remote.monopoly.monopolyInfo.nowGridId ~= gridId then
        if eventId == remote.monopoly.refineMedicineEventId then
            -- 当前走到炼药炉的时候，前端先保存一份药材的数量，用于显示，这样可以无需关注reponse
            remote.monopoly:tmpSaveMaterialNumTbl()
        end
        -- 已经达到骰子的目的地，途径不请求，这里还可能触发bonus或奇遇，需要另外弹框展示结果，其他金币、药水、过炉奖励都合并在一个tips显示
        remote.monopoly:monopolyGridEventRequest(gridId, function(data)
                if self:safeCheck() then
                    app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_MOVE_EVENT, 1, false)

                    if self._map.showActorAwardEffect then
                        self._map:showActorAwardEffect(colour, 1)
                    end
                    self:_showMaterialEffect(colour)
                    if data.monopolyResponse.nowGridId == gridId and data.prizes then
                        if eventId == remote.monopoly.luckyEventId then
                            if not remote.monopoly.beginOneCheatState then
                                -- 奇遇事件触发
                                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyLuckyAward", options = {prizes = data.prizes}}, {isPopCurrentDialog = false})
                            end
                        elseif not remote.monopoly.beginOneCheatState and remote.monopoly.monopolyInfo.randomFootGroup and remote.monopoly.monopolyInfo.hiddenRewardExist then   
                            self._tempPrizes = data.prizes
                        else
                            remote.monopoly:showRewardForTips(data.prizes)
                        end
                    end
                end
            end)
    end
    if eventId == remote.monopoly.refineMedicineEventId then
        -- 炼药炉事件触发
        if remote.monopoly.beginOneCheatState then
            self:quickMedicineEvent(gridId,colour,true)
        else
            local lianyaoConfig = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_LIANYAO)
            if lianyaoConfig then
                self:quickMedicineEvent(gridId,colour)
            else
                if remote.monopoly.monopolyInfo.lastRewardIsExist then
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyRefineMedicine", options = {standGridId = gridId, colour = colour}}, {isPopCurrentDialog = false})
                else
                    remote.monopoly.tmpMaterialNumTbl = {}
                    -- remote.monopoly:monopolyRefineMedicineRequest(false, gridId, self:safeHandler(function(data)
                    --     remote.monopoly:showRewardForTips(data.prizes, "路过炼药炉，获得：")
                    -- end))
                    remote.monopoly:monopolyRefineMedicineRequest(false, gridId)
                end
            end
        end
    elseif eventId == remote.monopoly.flowerEventId then
        -- 仙品事件触发
        if remote.monopoly.beginOneCheatState then
            -- local oneSetId = remote.monopoly:getMonpolyXianPingOneSetIDById(param)
            -- if oneSetId ~= 0 then
            --     local curSetting = remote.monopoly:getOneSetMonopolyId(oneSetId)
            --     local isOpen = curSetting.isOpen or false
            --     if isOpen then
                    -- self:quickFlowerEvent(gridId, param, isOpen)
            --     else
            --         remote.monopoly:monopolyPlantRequest(0) 
            --     end
            -- else
            --     remote.monopoly:monopolyPlantRequest(0)               
            -- end
            local levelUp = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_LEVELUP)
            local checkQuickLevelup = remote.monopoly:checkUpLevel(param)
            if levelUp and checkQuickLevelup then
                self:quickFlowerEvent(gridId, param, true)
            else
                remote.monopoly:monopolyPlantRequest(0) 
            end
        else
            local levelUp = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_LEVELUP)
            local checkQuickLevelup = remote.monopoly:checkUpLevel(param)
            if levelUp and checkQuickLevelup then
                self:quickFlowerEvent(gridId,param)
            else
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyFlower", options = {flowerId = param}}, {isPopCurrentDialog = false})
            end
        end
    elseif eventId == remote.monopoly.answerEventId then
        -- 答题事件触发
        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass=""}, {isPopCurrentDialog = false})
    elseif eventId == remote.monopoly.buyEventId then
        -- 购买事件触发
        if remote.monopoly.beginOneCheatState then
           self:OneQuickOpenChest(gridId)           
        else
            if not remote.monopoly.notEnoughToken then
                local openSetConfig = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_OPEN)
                if openSetConfig then
                    self:quickOpenChest(gridId)
                else
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyOpenChest"}, {isPopCurrentDialog = false})
                end
            end
        end
    elseif eventId == remote.monopoly.fingerEventId then
        -- 猜拳事件触发
        if remote.monopoly.beginOneCheatState then
            self:quickFingerEvent(true)
        else
            local caiQuanConfig = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_CAIQUAN)
            if caiQuanConfig then
                self:quickFingerEvent()
            else
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyFingerguessing"}, {isPopCurrentDialog = false})
            end
        end
    elseif #self._stepList > self._stepIndex then
        -- 这里仅仅处理路过最后一个格子的情况
        self:_checkToChangeMap()
    end
end

function QUIDialogMonopoly:quickMedicineEvent(standGridId,colour,isOneFlag)
    local curPoisonConfig = remote.monopoly:getCurPoisonConfig()
    self._poisonName = curPoisonConfig and (curPoisonConfig.poison or "") or ""
    if remote.monopoly.monopolyInfo.lastRewardIsExist then
        if remote.monopoly:getCurRefineMedicineRate() == 0 then
            remote.monopoly.tmpMaterialNumTbl = {}
            remote.monopoly:monopolyRefineMedicineRequest(false, standGridId,self:safeHandler(function(data)
                if self:safeCheck() then
                    remote.monopoly:continueSuccessToGo()
                end
            end))
        else
            remote.monopoly.tmpMaterialNumTbl = {}
            remote.monopoly:monopolyRefineMedicineRequest(true, standGridId, self:safeHandler(function(data)
                    if self:safeCheck() then
                        if data.monopolyResponse.removePoisonCount then
                            self._map:playEffectByGridPos(standGridId,true,1,self._poisonName)
                            if isOneFlag then
                                remote.monopoly:continueSuccessToGo()
                                local curDebuffId = remote.monopoly.monopolyInfo.removePoisonCount
                                local curPoisonConfig = remote.monopoly:getPoisonConfigById(curDebuffId)
                                local poisonName = curPoisonConfig and (curPoisonConfig.poison or "") or ""                              
                                app.tip:floatTip("成功解毒："..poisonName)
                                app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT, 1)
                            else
                                remote.monopoly:showRefineMedicineSuccessForDialog()
                            end
                        else
                            self._map:playEffectByGridPos(standGridId,false,1)
                            app.tip:floatTip("炼药失败，请继续采集药材")
                        end
                    end
                end))        
        end
    else
        remote.monopoly.tmpMaterialNumTbl = {}
        remote.monopoly:monopolyRefineMedicineRequest(false, standGridId,self:safeHandler(function(data)
                if self:safeCheck() then
                    remote.monopoly:continueSuccessToGo()
                end
            end))
    end

end

function QUIDialogMonopoly:quickFlowerEvent(gridId,flowerId,isopen)
    self._flowerId = flowerId
    local immortalInfos = remote.monopoly.monopolyInfo.immortalInfos or {}
    local exp = 0
    local uplevelel = false

    local curConfig, nextConfig = remote.monopoly:getFlowerCurAndNextConfigById(self._flowerId)
    if curConfig.cost then
        local tbl = string.split(curConfig.cost, ",")
        self._costItemId = tbl[1]
        self._costItemCount = tbl[2]
    end

    if immortalInfos[tonumber(self._flowerId)] then
        self._actionType = 2 --升级
    else
        self._actionType = 1
    end

    if not nextConfig then
        app.tip:floatTip("仙品等级已满，无法升级")
        remote.monopoly:monopolyPlantRequest(0)
        return false
    end

    if nextConfig and nextConfig.exp then
        if exp >= nextConfig.exp then
            uplevelel = true
        else
            uplevelel = false
        end
    end

    if remote.items:getItemsNumByID(self._costItemId) >= tonumber(self._costItemCount) then
        local oldImmortalInfo = clone(remote.monopoly.monopolyInfo.immortalInfos or {})
        local actionType = self._actionType
        remote.monopoly:monopolyPlantRequest(self._flowerId, function(data)
                --播放升级动画
                if self:safeCheck() then
                    if isopen then
                        if self._actionType == 2 then
                            app.tip:floatTip("升级成功")
                        else
                            app.tip:floatTip("种植成功")
                        end
                    else
                        local newImmortalInfo = clone(remote.monopoly.monopolyInfo.immortalInfos or {})
                        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyFlowerUpgrade",
                            options = {actionType = self._actionType, newImmortalInfo = newImmortalInfo[tonumber(flowerId)], oldImmortalInfo = oldImmortalInfo[tonumber(flowerId)], flowerId = self._flowerId}})

                        self._map:playEffectByGridPos(gridId,true,2,nil) 
                    end
                end            
            end)
    else
        if self._actionType == 2 then
            app.tip:floatTip("道具不足，升级失败")
        else
            app.tip:floatTip("道具不足，种植失败")
        end
        remote.monopoly:monopolyPlantRequest(0)
    end    
end

function QUIDialogMonopoly:quickOpenChest(gridId)
    local setconfig = remote.monopoly:getSelectByMonopolyId(remote.monopoly.ZIDONG_OPEN)
    local num = setconfig.openNum or 1
    local openRealNum = remote.monopoly:getOpenRealNum(num)
    remote.monopoly:monopolyBuyChestRequest(true,openRealNum, function(data)
        if self:safeCheck() then
            self._currentChestAwards = data.prizes or {}
            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                options = {awards = self._currentChestAwards, callback = nil}},{isPopCurrentDialog = false} )
            dialog:setTitle("开箱"..openRealNum.."次成功")

            remote.monopoly:monopolyBuyChestRequest(false,openRealNum, function(data)
            end)
        end
    end)
end

function QUIDialogMonopoly:OneQuickOpenChest(gridId)
    if remote.monopoly.oneQuickOpenCheatFlag then
        return
    end
    local curSetting = remote.monopoly:getOneSetMonopolyId(3)
    local isOpen = curSetting.isOpen or false
    local num = curSetting.openNum or 1
    local xpgjopen = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_OPEN)
    if not xpgjopen then
        num = 1
    else
        local setconfig = remote.monopoly:getSelectByMonopolyId(remote.monopoly.ZIDONG_OPEN)
        if setconfig then
            num = setconfig.openNum or 1
        end
    end
    local openRealNum = remote.monopoly:getOpenRealNum(num)
    if openRealNum == num then
        remote.monopoly.oneQuickOpenCheatFlag = true
        remote.monopoly:monopolyBuyChestRequest(true,num, function(data)
            if self:safeCheck() then
                -- app.tip:floatTip("开箱"..num.."次成功")
                local chestAwards = data.prizes or {}
                self:showOneTouZhiGetAwards(chestAwards)
                remote.monopoly:monopolyBuyChestRequest(false,num, function(data)
                    remote.monopoly.oneQuickOpenCheatFlag = false
                end)
            end
        end)        
    else
        -- 开箱不充值默认开箱一次
        remote.monopoly.beginOneCheatState = false
        remote.monopoly.notEnoughToken = true     
        self:_initBtnState(false)
        local tipsOptions = {}
        tipsOptions.canBackClick = true
        tipsOptions.layer = app.middleLayer
        tipsOptions.textType = VIPALERT_TYPE.NO_TOKEN
        tipsOptions.callBack = function(btnType)
            if btnType ~= "confrim" then
                remote.monopoly.notEnoughToken = false

                if self._schedulerHandler ~= nil then
                    scheduler.unscheduleGlobal(self._schedulerHandler)
                    self._schedulerHandler = nil
                end
                self._schedulerHandler = scheduler.performWithDelayGlobal(function()
                    self:_checkGridEventState()
                end,0.5) 
            end  
        end

        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVipAlert", options = tipsOptions}, {isPopCurrentDialog = false})

    end    
end
function QUIDialogMonopoly:quickFingerEvent(isOneFlag)
    --设置1次，1/2的概率胜利， 2次 1/4的概率  3次 1/8的概率
    local setconfig = remote.monopoly:getSelectByMonopolyId(remote.monopoly.ZIDONG_CAIQUAN)
    local winCount = setconfig.caiQuanNum or 1

    local isopen = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_CAIQUAN)
    if not isopen then
        winCount = 1
    end

    math.randomseed(q.OSTime())
    local randomNum = math.random(1, 100)
    local isWin = false
    if winCount == 1 and randomNum >= 50 then
        isWin = true
    elseif winCount == 2 and randomNum >= 75 then
        isWin = true
    elseif winCount == 3 and randomNum >= 88 then
        isWin = true
    end

    if not isWin then
        remote.monopoly.fingerGuessWinCount = 0
        remote.monopoly:monopolyGetFingerRewardRequest(remote.monopoly.fingerGuessWinCount, function()
                if self:safeCheck() then
                    app.tip:floatTip("你输掉了比试，什么都没有获得")
                end
            end)        
    else
        remote.monopoly.fingerGuessWinCount = winCount
        if winCount >= 3 then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT, 1)
        end
        local awards = remote.monopoly:getFingerAwards()
        remote.monopoly:monopolyGetFingerRewardRequest(remote.monopoly.fingerGuessWinCount, function()
            if self:safeCheck() then
                if isOneFlag then
                    local newAward = {}
                    local index = 0
                    for _,v in pairs(awards) do
                        index = index + 1
                        newAward[index] = {}
                        newAward[index].count = v.count
                        newAward[index].type = v.typeName
                        newAward[index].id = v.id
                    end                    
                    self:showOneTouZhiGetAwards(newAward)
                else
                    self:showFingerRewards(winCount,awards)
                end
            end
        end)
    end 
end

function QUIDialogMonopoly:showFingerRewards(winCount,awards)
    local newAward = {}
    local index = 0
    for _,v in pairs(awards) do
        index = index + 1
        newAward[index] = {}
        newAward[index].count = v.count
        newAward[index].type = v.typeName
        newAward[index].id = v.id
    end
    local tipsStr = string.format("恭喜魂师大人猜拳获得了%d胜", winCount)
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = newAward, callback = function()
            remote.monopoly.fingerGuessWinCount = 0
        end}},{isPopCurrentDialog = false} )
    dialog:setTitle(tipsStr)
end

function QUIDialogMonopoly:_initMainHeroUI()
    if self._mainHeroId and self._mainHeroId == remote.monopoly:getCurMainHeroId() then return end
    self._mainHeroId = remote.monopoly:getCurMainHeroId()
    -- print(" self._mainHeroId = ", self._mainHeroId)
    local heroHead = QUIWidgetHeroHead.new()
    heroHead:setHero(self._mainHeroId)
    heroHead:setHeadScale(1)
    heroHead:setBreakthrough(17)
    heroHead:showSabc()
    -- heroHead:setStar(4)
    self._ccbOwner.node_mainHeroHead:addChild(heroHead)
    local name, info = remote.monopoly:getCurMainHeroInfo(self._mainHeroId)
    self._ccbOwner.tf_mainHeroName:setString(name)
    self._ccbOwner.tf_mainHeroName:setVisible(true)
    self._ccbOwner.tf_mainHeroInfo:setString(info)
    self._ccbOwner.tf_mainHeroInfo:setVisible(true)
end

function QUIDialogMonopoly:oneGetBossAwards( )
    local curSetting = remote.monopoly:getOneSetMonopolyId(1)
    if curSetting and curSetting.finalSaveId then
        remote.monopoly:monopolyGetFinalRewardRequest(curSetting.finalSaveId, self:safeHandler(function(data)
                remote.monopoly:showRewardForTips(data.prizes,"恭喜获得最终大奖：") 
                remote.monopoly:continueSuccessToGo()
                self._showNikeList = {} 
            end))        
    end
end

function QUIDialogMonopoly:showOneTouZhiGetAwards(awards)
    remote.monopoly:showRewardForTips(awards)  
end

function QUIDialogMonopoly:_initBossUI()
    for index, itemId in pairs(remote.monopoly.materialTbl) do
        local tf = self._ccbOwner["tf_material_"..index]
        if tf then
            local itemNum = remote.items:getItemsNumByID(itemId)
            tf:setString(itemNum)
            tf:setVisible(true)
        end
    end

    if remote.monopoly.monopolyInfo.removePoisonCount >= #remote.monopoly.formulaTbl then
        self._ccbOwner.tf_refineMedicineProportion:setString("已完成解毒")
    else
        self._ccbOwner.tf_refineMedicineProportion:setString("当前炼药成功率"..remote.monopoly:getCurRefineMedicineRate().."%")
    end

    local removePoisonCount = (remote.monopoly.monopolyInfo.removePoisonCount or 0)
    local totalPoisonCount = #remote.monopoly.formulaTbl

    if remote.monopoly.monopolyInfo.lastRewardIsExist then
        self._ccbOwner.tf_boss_info:setString("帮独孤博解毒后领取奖励，进度："..removePoisonCount.."/"..totalPoisonCount)
        self._ccbOwner.btn_reviewFinalReward:setVisible(true)
        self._ccbOwner.btn_reviewFinalReward_big:setVisible(true)
    else
        self._ccbOwner.tf_boss_info:setString("已领取独孤博终极奖励，本周已无法解毒")
        self._ccbOwner.btn_reviewFinalReward:setVisible(false)
        self._ccbOwner.btn_reviewFinalReward_big:setVisible(false)
    end
    -- QPrintTable(self._showNikeList)
    self._ccbOwner.node_nike:removeAllChildren()
    for i = 1, totalPoisonCount, 1 do
        if i <= removePoisonCount then
            local pos = ccp(self._ccbOwner["node_poison_"..i]:getPosition())
            if not self._showNikeList[i] then
                -- 没有播放过的放一次动画
                self:_showNikeAnimation(pos, i)
            else
                local nikeImg = remote.monopoly:getNikeImg()
                self._ccbOwner.node_nike:addChild(nikeImg)
                nikeImg:setScale(0.7)
                nikeImg:setPosition(pos)
            end
        end
    end
    self._ccbOwner.node_curPoison:removeAllChildren()
    local curPoisonImg = remote.monopoly:getPoisonImgById(removePoisonCount + 1)
    if curPoisonImg then
        self._ccbOwner.node_curPoison:addChild(curPoisonImg)
    end
end

function QUIDialogMonopoly:_showNikeAnimation(pos, i)
    -- print(" QUIDialogMonopoly:_showNikeAnimation(pos) ", pos)
    local ccbFile = remote.monopoly:getNikeAnimation()
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_nike:addChild(aniPlayer)
    aniPlayer:setPosition(pos)
    aniPlayer:playAnimation(ccbFile, nil, function()
        self._showNikeList[i] = true
        end, false)
end

function QUIDialogMonopoly:_updateRedTips()
    self._ccbOwner.flower_tips:setVisible(remote.monopoly.pickFlowerRedTips)
end

function QUIDialogMonopoly:_checkMapX(x)
    if not x or x > (self._mapWidth - self._pageWidth)/2 then
        x = (self._mapWidth - self._pageWidth)/2
    elseif x < -(self._mapWidth - self._pageWidth)/2 then
        x = -(self._mapWidth - self._pageWidth)/2
    end

    return x
end

function QUIDialogMonopoly:_checkMapY(y)
    if not y or y > (self._mapHeight - self._pageHeight)/2 then
        y = (self._mapHeight - self._pageHeight)/2
    elseif y < -(self._mapHeight - self._pageHeight)/2 then
        y = -(self._mapHeight - self._pageHeight)/2
    end

    return y
end

function QUIDialogMonopoly:_checkBtnGoState( isForceDisEnable )
    -- print("QUIDialogMonopoly:_checkBtnGoState() ", isForceDisEnable, self._isActorMove, self:_isMapEnd())
    if isForceDisEnable or self._isActorMove or self:_isMapEnd() or remote.monopoly.beginOneCheatState then
        -- 骰子变灰
        makeNodeFromNormalToGray(self._ccbOwner.node_btnGo)
        self._ccbOwner.btn_go:setEnabled(false)
        makeNodeFromNormalToGray(self._ccbOwner.btn_cheat)
        self._ccbOwner.btn_cheat:setEnabled(false)

        makeNodeFromNormalToGray(self._ccbOwner.btn_oneCheat)
        self._ccbOwner.btn_oneCheat:setEnabled(false)

        self._isStandbyState = false
        if self._talkHandler ~= nil then
            scheduler.unscheduleGlobal(self._talkHandler)
            self._talkHandler = nil
        end
    else
        makeNodeFromGrayToNormal(self._ccbOwner.node_btnGo)
        self._ccbOwner.btn_go:setEnabled(true)
        makeNodeFromGrayToNormal(self._ccbOwner.btn_cheat)
        self._ccbOwner.btn_cheat:setEnabled(true)

        makeNodeFromGrayToNormal(self._ccbOwner.btn_oneCheat)
        self._ccbOwner.btn_oneCheat:setEnabled(true)

        if not remote.monopoly.beginOneCheatState then
            self:_startStandbyState()
        end
        -- self._ccbOwner.node_showGoNumber:removeAllChildren()
    end
end

function QUIDialogMonopoly:_checkToChangeMap()
    if self:_isMapEnd() then
        -- print("QUIDialogMonopoly:_checkToChangeMap() work")
        if not self._isWaitChangeMap then
            self._isWaitChangeMap = true
            self:_showCloud()
        end
    end
end

function QUIDialogMonopoly:_showCloud()
    app.sound:playSound("map_fireworks")
    local pos, ccbFile = remote.sunWar:getCloudAniURL()
    local proxy = CCBProxy:create()
    local aniCcbOwner = {}
    local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
    if pos then
        aniCcbView:setPosition(ccp(pos.x, pos.y))
    end
    self._ccbOwner.node_cloud:removeAllChildren()
    self._ccbOwner.node_cloud:addChild(aniCcbView)
    self._cloudManager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
    self._cloudManager:runAnimationsForSequenceNamed("close")
    self._cloudManager:connectScriptHandler(function(str)
            if str == "close" then
                remote.monopoly:monopolyMapChangeRequest(self:safeHandler(function(data)
                    self._newMapPrizes = data.prizes
                    if #self._stepList > self._stepIndex then
                        local tbl = {}
                        for i = self._stepIndex + 1, #self._stepList, 1 do
                            table.insert(tbl, self._stepList[i])
                        end
                        self._stepList = tbl
                        self._stepIndex = 0
                        self._startGridId = 0
                        self._isActorMove = true
                    else
                        self._stepList = {}
                        self._stepIndex = 1
                        self._isActorMove = false
                        self._startGridId = nil
                    end
                    self._isMove = false
                    if self._map then
                        if self._map.creatMap then
                            self._map:creatMap()
                        end
                        if self._map.autoCheckActorPos then
                            self._map:autoCheckActorPos()
                        end
                        if self._map.setMapMoveState then
                            self._map:setMapMoveState(self._isMove)
                        end
                    end
                end), self:safeHandler(function()
                end))
            elseif str == "open" then
                self._isWaitChangeMap = false
                self._isMapEndBoo = false
                remote.monopoly:showRewardForTips(self._newMapPrizes, "恭喜完成整张地图探索，奖励")
                self._newMapPrizes = nil
                self:_checkGridEventState()
            end
        end)
end

-- 判断当前的位置，是不是地图的最后一个格子
function QUIDialogMonopoly:_isMapEnd()
    if not self._isMapEndBoo then
        local curGridId = remote.monopoly.monopolyInfo.nowGridId or 0
        local standGridId = self:_getStandGridId()
        local maxGridId = remote.monopoly:getMaxGridId()
        if curGridId >= maxGridId or standGridId >= maxGridId then
            self._isMapEndBoo = true
        end
    end
    return self._isMapEndBoo
end

function QUIDialogMonopoly:_showMaterialEffect(colour)
    local node = self._ccbOwner["node_material_"..colour]
    if node then
        local effectNode = CCNode:create()
        node:getParent():addChild(effectNode)
        effectNode:setPosition(ccp(node:getPosition()))

        local effectPath = remote.monopoly:getMaterialEffectPath()
        if effectPath then
            local ccbFile = effectPath
            local aniPlayer = QUIWidgetAnimationPlayer.new()
            effectNode:addChild(aniPlayer)
            aniPlayer:playAnimation(ccbFile, nil, self:safeHandler(function()
                    effectNode:removeFromParent()
                end), true)
        end
    end
end

function QUIDialogMonopoly:_onTriggerPlus(e)
    if e then
        self._isTouchScreen = true
        app.sound:playSound("common_small")
    end
    
    if not e or e == "32" then
        -- 点击购买骰子次数
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", 
            options = {cls = "QBuyCountMonopoly"}}, {isPopCurrentDialog = false})
    end
end

function QUIDialogMonopoly:_onTriggerGo(e)
    if e then
        app.sound:playSound("common_small")
        self._isTouchScreen = true
    end
    if not e or e == "32" then --32表示按钮状态
        -- 点击投掷骰子
        if remote.monopoly:getCurDiceCount() == 0 then
            self:_onTriggerPlus()
            return
        end
        self._stepList, self._showStep = remote.monopoly:getStepList()
        -- QPrintTable(self._stepList)
        self._stepIndex = 1
        self._startGridId = remote.monopoly.monopolyInfo.nowGridId or 0
        self._isActorMove = true
        
        self:_checkBtnGoState()
        self:_showDiceAnimation()
    end
end

function QUIDialogMonopoly:oneGoBuyFinish()
    app.tip:floatTip("一键投掷已终止")
    remote.monopoly.beginOneCheatState = false
    self:_initBtnState(false)
    self:_checkBtnGoState(false)
end

function QUIDialogMonopoly:_oneTriggerGo()
    app.sound:playSound("common_small")
    self._isTouchScreen = true

    if remote.monopoly:getCurDiceCount() == 0 then
        local canNotBuyNum = true
        local curSetting = remote.monopoly:getOneSetMonopolyId(2) 
        local isOpen = curSetting.isOpen or false
        if isOpen and not remote.monopoly.buyDiceNumFlag then
            local lastBuyNum = remote.monopoly:getLastBuyDiceNum()
            if lastBuyNum > 0 then
                local setBuyNum = curSetting.buyNum or 1
                local canbuy,realNum = remote.monopoly:checkCanBuyDices(setBuyNum)
                print("canbuy=",canbuy)
                print("realNum=",realNum)
                if canbuy and realNum > 0 then
                    canNotBuyNum = false
                    remote.monopoly.buyDiceNumFlag = true
                    remote.monopoly:monopolyBuyDiceRequest(realNum,function(data)
                        self:_oneTriggerGo()
                        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.MONOPOLY_YJZSZ_BUYNUM)
                    end,function(data)
                        self:oneGoBuyFinish()
                    end)
                else
                    self:oneGoBuyFinish()
                    -- 有购买次数，钻石不够
                    if realNum > 0 then 
                        app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
                    end
                end 
            end
        end
        if canNotBuyNum then
            if self._schedulerTimeHandler ~= nil then
                scheduler.unscheduleGlobal(self._schedulerTimeHandler)
                self._schedulerTimeHandler = nil
            end
            self._schedulerTimeHandler = scheduler.performWithDelayGlobal(function()
                    self:oneGoBuyFinish()
                end,0.5)   
        end
        return
    end

    self._stepList, self._showStep = remote.monopoly:getStepList()
    local isControl, realShowStep = self:retrieveStandGridId()
    if isControl then
        -- self._cheatItemIds = {13300006, 13300007, 13200000} -- 目前写死
        local useItemId = 13200000
        if realShowStep <= 3 and remote.items:getItemsNumByID(13300006) >= 1 then
            useItemId = 13300006 
        elseif realShowStep > 3 and remote.items:getItemsNumByID(13300007) >= 1 then
            useItemId = 13300007
        end

        if remote.items:getItemsNumByID(useItemId) >= 1 then
            remote.monopoly:monopolyCheatRequest(useItemId, realShowStep, self:safeHandler(function()
                -- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
                self._stepIndex = 1
                self._startGridId = remote.monopoly.monopolyInfo.nowGridId or 0
                self._isActorMove = true
                self:_checkBtnGoState()
            end))

            return        
        end
    end

    self._stepIndex = 1
    self._startGridId = remote.monopoly.monopolyInfo.nowGridId or 0
    self._isActorMove = true
    self:_checkBtnGoState()
    self:_showDiceAnimation()
end

function QUIDialogMonopoly:retrieveStandGridId()
    print("remote.monopoly.monopolyInfo.nowGridId = ",remote.monopoly.monopolyInfo.nowGridId)
    local nowGridId = remote.monopoly.monopolyInfo.nowGridId or 0
    local endGridId = nowGridId
    for ii = 1,6 do
        local standGridInfo = remote.monopoly.monopolyInfo.gridInfos[endGridId + ii]
        if standGridInfo and standGridInfo.eventId == remote.monopoly.flowerEventId then -- 仙品升级
            local oneSetId = remote.monopoly:getMonpolyXianPingOneSetIDById(standGridInfo.param)
            if oneSetId ~= 0 then
                local curSetting = remote.monopoly:getOneSetMonopolyId(oneSetId)
                local isOpen = curSetting.isOpen or false
                if isOpen then
                   return true,ii
                end         
            end
        end
        if standGridInfo and standGridInfo.eventId == remote.monopoly.buyEventId then --开宝箱
            local curSetting = remote.monopoly:getOneSetMonopolyId(3) 
            local isOpen = curSetting.isOpen or false  
            if isOpen then          
                return true,ii
            end
        end

        if standGridInfo and standGridInfo.eventId == remote.monopoly.fingerEventId then --猜拳
            local curSetting = remote.monopoly:getOneSetMonopolyId(4) 
            local isOpen = curSetting.isOpen or false  
            if isOpen then          
                return true,ii
            end
        end
    end

    return false,self._showStep
end

function QUIDialogMonopoly:_getStandGridId()
    if not self._startGridId or #self._stepList == 0 then 
        return remote.monopoly.monopolyInfo.nowGridId
    end
    local endGridId = self._startGridId
    for i = 1, self._stepIndex, 1 do
        endGridId = endGridId + (self._stepList[i] or 0)
    end
    return endGridId
end

function QUIDialogMonopoly:_showDiceAnimation()
    if self._showDiceScheduler then
        scheduler.unscheduleGlobal(self._showDiceScheduler)
        self._showDiceScheduler = nil
    end
    local spDiceNum = remote.monopoly:getDiceImgByNum(self._showStep)
    self._ccbOwner.node_showGoNumber:addChild(spDiceNum)
    self._ccbOwner.node_showGoNumber:setVisible(false)

    self._facEffect:setVisible(true)
    self._facEffect:resumeAnimation()
    self._facEffect:connectAnimationEventSignal(handler(self, self._fcaHandler))
    self._facEffect:playAnimation("animation", false)
end

function QUIDialogMonopoly:_fcaHandler(eventType)
    -- print("QUIDialogMonopoly:_fcaHandler(eventType)", eventType)
    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
        self._ccbOwner.node_showGoNumber:setVisible(true)
        self._facEffect:stopAnimation()
        self._facEffect:setVisible(false)
        if self._moveEndScheduler then
            scheduler.unscheduleGlobal(self._moveEndScheduler)
            self._moveEndScheduler = nil
        end
        self._isMove = false
        self._map:setMapMoveState(self._isMove)
        self._map:actorMoveTo(self:_getStandGridId())

        if self._showDiceScheduler then
            scheduler.unscheduleGlobal(self._showDiceScheduler)
            self._showDiceScheduler = nil
        end
        self._showDiceScheduler = scheduler.performWithDelayGlobal(self:safeHandler(function ()
                self._ccbOwner.node_showGoNumber:removeAllChildren()
            end), 1)
        
    end
end

function QUIDialogMonopoly:_startStandbyState()
    if self._isStandbyState then return end
    self._isStandbyState = true
    if self._talkHandler ~= nil then
        scheduler.unscheduleGlobal(self._talkHandler)
        self._talkHandler = nil
    end
    self._talkHandler = scheduler.performWithDelayGlobal(function()
        self._map:startTalk()
    end, 6)
end

function QUIDialogMonopoly:_onTriggerCheat(e)
    if e then
        app.sound:playSound("common_small")
        self._isTouchScreen = true
    end
    if not e or e == "32" then
        if not self._isActorMove then
            -- 点击打开鬼影迷踪界面
            if remote.monopoly:getCurDiceCount() == 0 then
                app.tip:floatTip("当前没有骰子次数，无法使用遥控骰子")
                return
            end
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolySelectCheat"})
        end
    end
end

function QUIDialogMonopoly:_onTriggerFlower(event)
    if event then
        self._isTouchScreen = true
    end
    if q.buttonEventShadow(event, self._ccbOwner.btn_flower) == false then return end
    app.sound:playSound("common_small")
    -- 点击打开仙品管理界面
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyPickFlower"})
end

function QUIDialogMonopoly:_onTriggerSet(event)
    if event then
        self._isTouchScreen = true
    end    
    if q.buttonEventShadow(event, self._ccbOwner.btn_set) == false then return end
    app.sound:playSound("common_small")
    if not app:getUserData():getValueForKey("UNLOCK_BINGHUOLIANGYIYAN_SHEZHI"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_BINGHUOLIANGYIYAN_SHEZHI"..remote.user.userId, "true")
        self._ccbOwner.node_set_effect:setVisible(false)
    end 

    if not app.unlock:checkLock("UNLOCK_BINGHUOLIANGYIYAN_SHEZHI", true) then
       return false
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolySeting"})        
    end
end

function QUIDialogMonopoly:_onTriggerOneCheat( event )
    if event then
        self._isTouchScreen = true
    end    
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneCheat) == false then return end
    app.sound:playSound("common_small")
    if not app:getUserData():getValueForKey("UNLOCK_BINHUO_YIJIAN"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_BINHUO_YIJIAN"..remote.user.userId, "true")
        self._ccbOwner.node_oneCheat_effect:setVisible(false)
    end 

    if not app.unlock:checkLock("UNLOCK_BINHUO_YIJIAN", true) then
       return false
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyOneSeting"})        
    end
end
function QUIDialogMonopoly:_onTriggerStop( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_stop) == false then return end
    remote.monopoly.beginOneCheatState = false
    app.tip:floatTip("一键投掷已终止")
    self:_initBtnState(false)
end
function QUIDialogMonopoly:_onTriggerMainHero(e)
    if e then
        app.sound:playSound("common_small")
        self._isTouchScreen = true
        q.setButtonEnableShadow(self._ccbOwner.btn_reviewMainHero)
    end
    if not e or e == "32" then
        -- 点击查看主题魂师的图鉴
        if self._mainHeroId then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroImageCard", 
                options = {actorId = self._mainHeroId}})
        end
    end
end

function QUIDialogMonopoly:_onTriggerRule(e)
    if e then
        app.sound:playSound("common_small")
        self._isTouchScreen = true
    end
    if not e or e == "32" then
        -- 点击查看帮助
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyRule"})
    end
end

function QUIDialogMonopoly:_onTriggerDebuff(event, target)
    app.sound:playSound("common_small")
    -- 点击查看毒的信息
    for i = 1, #remote.monopoly.formulaTbl, 1 do
        if target == self._ccbOwner["btn_poison_"..i] then
            local config = remote.monopoly:getPoisonConfigById(i)
            app.tip:floatTip(config.description)
            return
        end
    end
end

function QUIDialogMonopoly:_onTriggerBoss(e)
    if e then
        app.sound:playSound("common_small")
        self._isTouchScreen = true
        q.setButtonEnableShadow(self._ccbOwner.btn_reviewFinalReward)
    end
    if not e or e == "32" then
        -- 点击预览最终奖励
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyFinalAward", options = {callBack = self:safeHandler(function()
                self._isTouchScreen = false
            end)}})
    end
end

function QUIDialogMonopoly:onTriggerBackHandler()
    self:_onTriggerClose()
end

function QUIDialogMonopoly:_onTriggerClose()
	self:popSelf()
end

function QUIDialogMonopoly:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMonopoly:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMonopoly