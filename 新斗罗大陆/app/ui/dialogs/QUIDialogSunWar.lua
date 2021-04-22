--
-- Author: Kumo.Wang
-- Date: Mon Mar  7 18:34:53 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSunWar = class("QUIDialogSunWar", QUIDialog)
local QScrollViewTest = import("...views.QScrollViewTest")
local QUIWidgetSunWar = import("..widgets.QUIWidgetSunWar")
local QUIWidgetSunWarPlayerInfo = import("..widgets.QUIWidgetSunWarPlayerInfo")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QSunwarArrangement = import("...arrangement.QSunwarArrangement")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSunWarChest = import("..widgets.QUIWidgetSunWarChest")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIDialogSunWarAlert = import("..dialogs.QUIDialogSunWarAlert")

QUIDialogSunWar.NO_FIGHT_HEROES = "还未设置战队，无法参加战斗！现在就设置战队？"

function QUIDialogSunWar:ctor( option )
	local ccbFile = "ccb/Dialog_SunWar.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerStore", callback = handler(self, QUIDialogSunWar._onTriggerStore)},
		{ccbCallbackName = "onTriggerRevive", callback = handler(self, QUIDialogSunWar._onTriggerRevive)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIDialogSunWar._onTriggerRule)},
        {ccbCallbackName = "onPlus", callback = handler(self, QUIDialogSunWar._onTriggerPlus)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogSunWar._onTriggerRank)},
        {ccbCallbackName = "onTriggerReset", callback = handler(self, QUIDialogSunWar._onTriggerReset)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
	} 
	QUIDialogSunWar.super.ctor(self,ccbFile,callBacks,options)
    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self._page.setManyUIVisible then self._page:setManyUIVisible() end
    if self._page.setScalingVisible then self._page:setScalingVisible(false) end
    if self._page.topBar.showWithSunWar then self._page.topBar:showWithSunWar() end

    self._nameAni = "Default Timeline"
    self._isAnimationPlaying = false
    self._delayToUpdateMapInfo = false

    self._aniManagers = {}
    self._aniCcbViews = {}

    remote.sunWar:setIsNeedMapUpdate( true )
    remote.sunWar:setIsNeedPlayerUpdate( true )

    self:_init()
    self:_checkRedTips()
    
    self:checkTutorial()
end

function QUIDialogSunWar:checkTutorial()
    if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:buildLayer()
        local haveTutorial = false
        if app.tutorial:getStage().sunWar == app.tutorial.Guide_Start and app.unlock:getUnlockSunWar() then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_SunWar)
        end
        if haveTutorial == false then
            page:cleanBuildLayer()
        end
    end
end

function QUIDialogSunWar:viewDidAppear()
    QUIDialogSunWar.super.viewDidAppear(self)
  	self:addBackEvent(false)

    self.sunWarProxy = cc.EventProxy.new(remote.sunWar)
    self.sunWarProxy:addEventListener(remote.sunWar.UPDATE_MAP_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.UPDATE_PLAYER_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.UPDATE_CHEST_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.UPDATE_MAP_INFO_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.REVIVE_COMPLETE_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.CHEST_OPENED_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.CHEST_INSPECT_EVENT, handler(self, self.updateSunWarHandler))
    self.sunWarProxy:addEventListener(remote.sunWar.REVIVE_EVENT, handler(self, self._showBuffEffect))

    self._scrollViewProxy = cc.EventProxy.new(self._mapScroll)
    self._scrollViewProxy:addEventListener(QScrollViewTest.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollViewProxy:addEventListener(QScrollViewTest.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
    self._scrollViewProxy:addEventListener(QScrollViewTest.GESTURE_END, handler(self, self._onScrollViewEnd))

    remote.sunWar:clearRedPointAtRevive()
    remote.sunWar:clearRedPointAtChest()
    remote.sunWar:setIsChestOpening(false)
    remote.sunWar:addBuff( true )
    remote.sunWar:setIsNeedMapUpdate( true )
    remote.sunWar:setIsNeedPlayerUpdate( true )
    remote.sunWar:setIsNeedChestUpdate( true )
    remote.sunWar:setIsMapFirstAppearance( true )

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
end

function QUIDialogSunWar:viewWillDisappear()
    QUIDialogSunWar.super.viewWillDisappear(self)
	self:removeBackEvent()
    self.sunWarProxy:removeAllEventListeners()
    self._map:removeAllEventListeners()

    for _, manager in pairs(self._aniManagers) do
        manager:stopAnimation()
        manager = nil
    end
    self._aniManagers = {}

    for _, view in pairs(self._aniCcbViews) do
        view:removeFromParent()
        view = nil
    end
    self._aniCcbViews = {}

    remote.sunWar:setIsNeedMapUpdate( true )
    remote.sunWar:setIsNeedPlayerUpdate( true )
    remote.sunWar:setIsNeedChestUpdate( true )
    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    if dialog and dialog.__cname == "QUIDialogHeroInfo" then
        remote.sunWar:removeBuff(false)
    else
        remote.sunWar:removeBuff(true)
    end
    remote.sunWar:setIsHeroFirstAppearance( false )
    remote.sunWar:setIsBuffEffectPlaying(false)
    
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

    self._scrollViewProxy:removeAllEventListeners()

    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    if self._fires then
        for _, fire in pairs(self._fires) do
            fire:removeFromParentAndCleanup(true)
        end
        self._fires = nil
    end

    if self._fireScheduleGlobal then
        scheduler.unscheduleGlobal(self._fireScheduleGlobal)
        self._fireScheduleGlobal = nil
    end

    if self._firePerformWithDelayGlobal then
        scheduler.unscheduleGlobal(self._firePerformWithDelayGlobal)
        self._firePerformWithDelayGlobal = nil
    end
end

function QUIDialogSunWar:_exitFromBattle()
    self:_checkRedTips()
    self:_showFirstWin()
end

function QUIDialogSunWar:updateSunWarHandler( event )
    -- print("[Kumo] event.name : ", event.name)
    if self._delayToUpdateMapInfo then return end
    
    if event.name == remote.sunWar.UPDATE_MAP_EVENT then
        local isMapFirstAppearance = remote.sunWar:getIsMapFirstAppearance()
        print("[Kumo] UPDATE_MAP_EVENT isMapFirstAppearance ", isMapFirstAppearance, self._isAnimationPlaying, remote.sunWar:getIsChestOpening())
        if (not isMapFirstAppearance or isMapFirstAppearance == false) and self._isAnimationPlaying == false and remote.sunWar:getIsChestOpening() == false then
            remote.sunWar:setCurrentMapID( remote.sunWar:getNextMapID() )
            self:_updateMapInfo()
            self._map:updateMap()
        end
        --默认移动到中间
        self._mapScroll:moveTo(self._size.width / 2 - self._map:getCurrentPosition(), 0)
    elseif event.name == remote.sunWar.UPDATE_PLAYER_EVENT then
        if not self._isAnimationPlaying then
            self._map:updatePlayerInfo()
        end
        --默认移动到中间
        self._mapScroll:moveTo(self._size.width / 2 - self._map:getCurrentPosition(), 0)
    elseif event.name == remote.sunWar.UPDATE_CHEST_EVENT then
        if not self._isAnimationPlaying then
            self._map:updateChest()
        end
    elseif event.name == remote.sunWar.UPDATE_MAP_INFO_EVENT then
        self:_updateMapInfo()
    elseif event.name == remote.sunWar.REVIVE_COMPLETE_EVENT then
        -- self:_showReviveTips()
    elseif event.name == remote.sunWar.CHEST_OPENED_EVENT then
        self:_showChestAward()
    elseif event.name == remote.sunWar.CHEST_INSPECT_EVENT then
        self:_inspectChestAward( event.waveID )
    end
end

function QUIDialogSunWar:_init()
    app:getClient():sunwarInfoRequest(function( response )
        remote.sunWar:responseHandler(response)
        self:_requestChapterAward()
    end)

    CalculateBattleUIPosition(self._ccbOwner.sheet , true)
    self._ccbOwner.sheet_layout:setContentSize(display.width,display.height)
    self._size = self._ccbOwner.sheet_layout:getContentSize()
    -- self._size.height = self._size.height + (display.height - UI_DESIGN_HEIGHT) / 2 + 100
	self._mapScroll = QScrollViewTest.new(self._ccbOwner.sheet, self._size, {sensitiveDistance = 10})
    -- self._mapScroll:setHorizontalBounce(true)
    self._map = QUIWidgetSunWar.new()
    self._map:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_AVATAR_CLICK, handler(self, self._onEvent))
    self._map:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_INFO_CLICK, handler(self, self._onEvent))
    self._map:addEventListener(QUIWidgetSunWar.UPDATE_COMPLETE, handler(self, self._onEvent))
    self._map:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_FAST_FIGHT_CLICK, handler(self, self._onEvent))
    self._map:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_AUTO_FIGHT_CLICK, handler(self, self._onEvent))
    self._mapScroll:addChildBox(self._map)
    self._map:setPosition(0, -display.height/2)
    self._mapScroll:setRect(0, -self._ccbOwner.sheet_layout:getContentSize().height , 0, self._map:getMaxWidth())

    self._ccbam = tolua.cast(self._ccbOwner.ccb_playerInfo:getUserObject(), "CCBAnimationManager")
    -- self._ccbam:runAnimationsForSequenceNamed("appear")
    self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
    self._ccbam:connectScriptHandler(function(str)
            if str == "disappear" then
                self._mapInfoDisappear = true
                local i = 1
                while(true) do
                    if self._ccbOwner["node_icon_"..i] then
                        self._ccbOwner["node_icon_"..i]:removeAllChildren()
                        self._ccbOwner["tf_dailyOutputNum_"..i]:setString("")
                        i = i + 1
                    else
                        break
                    end
                end
            elseif str == "appear" then
                self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
                self:_updateMapInfo()
                self:_showNewMapAlert()
            end
        end)

    
    self:_updateMapInfo()
    self:_showNewDayAlert()
end

function QUIDialogSunWar:_showNewMapAlert()
    if self._mapInfoDisappear then
        self._mapInfoDisappear = false

        local todayPassedWaves = remote.sunWar:getTodayPassedWaves()
        if q.isEmpty(todayPassedWaves) == false then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSunWarNewAlert", options = {isNewDay = false}})
        end
    end
end

function QUIDialogSunWar:_showNewDayAlert()
    do return end

    local time = tonumber(app:getUserOperateRecord():getLastOpenSunWarTime())
    if time == 0 then
        app:getUserOperateRecord():recordLastOpenSunWarTime( q.serverTime() ) 
        return
    end
    local lastTimeTbl = q.date("*t", time)
    local curTimeTbl = q.date("*t", q.serverTime())
    if lastTimeTbl.year < curTimeTbl.year or lastTimeTbl.month < curTimeTbl.month or lastTimeTbl.day < curTimeTbl.day then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSunWarNewAlert", options = {isNewDay = true}})
    end
end

function QUIDialogSunWar:_checkRedTips()
    -- 设置商店小红点
    self._ccbOwner.store_tips:setVisible(false)
    if remote.stores:checkFuncShopRedTips(SHOP_ID.sunwellShop) then
        self._ccbOwner.store_tips:setVisible(true)
    end
end

function QUIDialogSunWar:_onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIDialogSunWar:_onScrollViewMoving( ... )
    self._isMoving = true
end

function QUIDialogSunWar:_onScrollViewEnd( ... )
    self._scheduler = scheduler.performWithDelayGlobal(function() 
        self._isMoving = false 
        if self._scheduler then
            scheduler.unscheduleGlobal(self._scheduler)
            self._scheduler = nil
        end
    end, 0.5)
end

function QUIDialogSunWar:_updateMapInfo()
    local mapID = remote.sunWar:getCurrentMapID()
    local mapInfo = remote.sunWar:getMapInfoByMapID( mapID )
    -- printTable(mapInfo, mapID..">>>")
    self._ccbOwner.tf_level:setString("LV."..mapInfo.chapter)
    self._ccbOwner.tf_name:setString(mapInfo.name)
    local i = 1
    while(true) do
        if mapInfo["reward_type_"..i] then
            local node = self:_getIcon(mapInfo["reward_type_"..i], mapInfo["item_id_"..i])
            self._ccbOwner["node_icon_"..i]:addChild(node)
            self._ccbOwner["tf_dailyOutputNum_"..i]:setString(mapInfo["reward_num_"..i])
            i = i + 1
        else
            break
        end
    end
    local count = remote.sunWar:getCanReviveCount()
    self._ccbOwner.tf_count:setString(tostring(count))
    self._ccbOwner.node_btn_plus:setVisible(count == 0 and not remote.sunWar:hasNoDeadHero())

    local buff = remote.sunWar:getBuffUpValue()
    if buff and buff > 0 then
        if self._page.topBar then
            self._page.topBar:getBarForType(TOP_BAR_TYPE.BATTLE_FORCE_FOR_SUNWAR):showSunWarBattleBuff( buff )
        end
    end

    self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)

    local lastPassedWave = remote.sunWar:getLastPassedWave()
    if not lastPassedWave or lastPassedWave == 0 then
        self._ccbOwner.node_max_wave:setVisible(false)
        self._ccbOwner.node_reset:setVisible(false)
    else
        self._ccbOwner.node_max_wave:setVisible(true)
        local mid = remote.sunWar:getMapIDWithLastWaveID()
        local v = remote.sunWar:getWaveInfoByWaveID(lastPassedWave, false)
        local index = (v and v.index) or 0
        self._ccbOwner.tf_max_wave:setString(mid.."-"..index)

        if (mid == 4 and index == 9) or mid > 4 then
            self._ccbOwner.node_reset:setVisible(true)
        else
            self._ccbOwner.node_reset:setVisible(false)
        end 
    end

    local buff = remote.sunWar:getInspectBuffUpValue()
    if buff > 0 then
        self._ccbOwner.node_buff_text:setVisible(true)
        self._ccbOwner.tf_buff_text:setString("本次复活提升"..buff.."%战力")
    else
        self._ccbOwner.node_buff_text:setVisible(false)
    end
end

--[[
    设置icon
]]
function QUIDialogSunWar:_getIcon( type, id )
    local info = remote.items:getWalletByType(type)
    local node = nil
    if info ~= nil and info.alphaIcon ~= nil then
        local texture = CCTextureCache:sharedTextureCache():addImage(info.alphaIcon)
        node = CCSprite:createWithTexture( texture )
        node:setScale(0.65)
    else
        node = QUIWidgetItemsBox.new({ccb = "small"})
        node:setGoodsInfo(id, type, 0)
        node:setScale(0.45)
    end

    return node
end

function QUIDialogSunWar:_onEvent( event )
    -- print("[Kumo] QUIDialogSunWar:_onEvent", event.name, event.waveID)
    if event.name == QUIWidgetSunWarPlayerInfo.EVENT_AVATAR_CLICK then
        if not self._isMoving and not self._isAnimationPlaying then
            app.sound:playSound("common_small")
            self:_gotoTeamArrangement()
        end
    elseif event.name == QUIWidgetSunWarPlayerInfo.EVENT_INFO_CLICK then
        if not self._isMoving and not self._isAnimationPlaying then
            app.sound:playSound("common_small")
            local data = remote.sunWar:getWaveFigtherByWaveID(event.waveID)
            local allDead = false
            if event.waveID ~= remote.sunWar:getCurrentWaveID() then
                allDead = true
            else
                if remote.sunWar:getLastPassedWave() == event.waveID then
                    local todayPassedWaves = remote.sunWar:getTodayPassedWaves()
                    local isFind = false
                    for _, id in pairs(todayPassedWaves) do
                        if id == event.waveID then
                            -- 说明是今天打的，而不是之前打的
                            isFind = true
                        end
                    end

                    if isFind then
                        allDead = true
                    else
                        allDead = false
                    end
                else
                    allDead = false
                end
            end

            local waveInfo = remote.sunWar:getWaveInfoByWaveID( event.waveID )
            local firstAward = QStaticDatabase.sharedDatabase():getluckyDrawById( waveInfo.first_drop )
            local award = QStaticDatabase.sharedDatabase():getluckyDrawById( waveInfo.lucky_draw_id )
            local initMp = remote.sunWar:getNPCInitMpByWaveID( event.waveID )

            -- print(event.waveID, remote.sunWar:getCurrentWaveID())
            -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSunWarFigterInfo", 
            --     options = {info = data, allDead = allDead, firstAward = firstAward, award = award, initMp = initMp, waveID = event.waveID}})
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
                options = {fighter = data, awardTitle2 = "首胜奖励：", awardValue2 = firstAward, 
                awardTitle1 = "胜利奖励：", awardValue1 = award, 
                model = GAME_MODEL.SUNWAR, 
                allDead = allDead, initMp = initMp, 
                waveID = event.waveID, isShowHpMp = true, isPVP = true}}, {isPopCurrentDialog = false})
        end
    elseif event.name == QUIWidgetSunWar.UPDATE_COMPLETE then
        if self._cloudManager then
            self._cloudManager:runAnimationsForSequenceNamed("open")
            -- self._ccbam:runAnimationsForSequenceNamed("appear")
            self._mapScroll:runToLeft()
            -- self:_updateMapInfo()
        end
    elseif event.name == QUIWidgetSunWarPlayerInfo.EVENT_FAST_FIGHT_CLICK then
        if not self._isMoving and not self._isAnimationPlaying then
            local oldSunwellMoney = remote.user.sunwellMoney
            local battleType = BattleTypeEnum.BATTLEFIELD
            remote.sunWar:requestSunWarFastFight(battleType, event.waveID, false, function(data)
                if self:safeCheck() then
                    remote.activity:updateLocalDataByType(548, 1)
                    remote.user:addPropNumForKey("todayBattlefieldFightCount")

                    app.taskEvent:updateTaskEventProgress(app.taskEvent.SUN_WAR_TASK_EVENT, 1, false, true)

                    local batchAwards = {}
                    local awards = {}
                    local prizes = data.gfQuickResponse.battlefieldQuickFightResponse.luckyDraw.prizes

                    for _, value in pairs(prizes) do
                        if value.id ~= nil and value.id > 0 then
                            table.insert(awards, {id = value.id, type = value.type ,count = value.count})
                        else
                            table.insert(awards, {type = value.type ,count = value.count})
                        end
                    end

                    --节日掉落
                    if type(data.extraExpItem) == "table" then
                        for k, v in pairs(data.extraExpItem)do
                            table.insert(awards, v)
                        end
                    end
                    table.insert(batchAwards, {awards = awards})

                    local waveInfo = remote.sunWar:getWaveInfoByWaveID( event.waveID )
                    local currentMapID = remote.sunWar:getCurrentMapID()
                    local titleStringFormat = currentMapID.." - "..waveInfo.index

                    local yield = remote.sunWar:getLuckyDrawCritical() or 1
                    local activityYeild = remote.sunWar:getLuckyDrawActivityYeild() or 1
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
                        options = {fast_type = FAST_FIGHT_TYPE.RANK_FAST,awards = batchAwards, yield = yield, yieldType = "battlefield_box_crit", activityYield = activityYeild, title = "海神岛扫荡", name = titleStringFormat, 
                                    titleStringFormat = "第"..titleStringFormat.."关奖励", callback = function ()
                            if self:safeCheck() then
                                self:_checkRedTips()
                                self:_showFirstWin()
                            end
                        end}},{isPopCurrentDialog = false})
                end
            end)
        end
    elseif event.name == QUIWidgetSunWarPlayerInfo.EVENT_AUTO_FIGHT_CLICK then
        print("自动战斗。。。。。")
        self:autoFightStart(event)
    end
end

function QUIDialogSunWar:_gotoTeamArrangement()
    local waveID = remote.sunWar:getCurrentWaveID()
    local info = remote.sunWar:getWaveFigtherByWaveID( waveID )

    local teamKey = remote.sunWar:getSunWarTeamKey()
    local teamVO = remote.teamManager:getTeamByKey(teamKey)
    local heros = clone(remote.teamManager:getActorIdsByKey(teamKey))
    for _, actorId in pairs(heros) do
        -- print(actorId)
        local heroInfo = remote.sunWar:getMyHeroInfoByActorID(actorId)
        -- printTable(heroInfo, actorId..">>>")
        if heroInfo ~= nil and heroInfo.currHp and heroInfo.currHp <= 0 then
            teamVO:delHeroByIndex(1, actorId)
        end
    end
    remote.teamManager:saveTeamToLocal(teamVO, teamKey)

    local sunwellArrangement = QSunwarArrangement.new({dungeonInfo = info, teamKey = teamKey})
    sunwellArrangement:setIsLocal(true)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
        options = {arrangement = sunwellArrangement}})
end

function QUIDialogSunWar:_showCloud()
    app.sound:playSound("map_fireworks")

    local waveID = remote.sunWar:getCurrentWaveID()
    if remote.sunWar:isLastMapLastWaveByWaveID(waveID) then
        self._isAnimationPlaying = false
        return 
    end
    
    local pos, ccbFile = remote.sunWar:getCloudAniURL()
    local proxy = CCBProxy:create()
    local aniCcbOwner = {}
    local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
    if pos then
        aniCcbView:setPosition(ccp(pos.x, pos.y))
    end
    self._ccbOwner.node_guochang:addChild(aniCcbView)

    self._isAnimationPlaying = true
    self._ccbam:runAnimationsForSequenceNamed("disappear")

    self._cloudManager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
    self._cloudManager:runAnimationsForSequenceNamed("close")
    self._cloudManager:connectScriptHandler(function(str)
            if str == "close" then
                self._delayToUpdateMapInfo = false
                remote.sunWar:setCurrentMapID( remote.sunWar:getNextMapID() )
                remote.sunWar:setIsNeedMapUpdate( true )
                remote.sunWar:setIsNeedPlayerUpdate( true )
                remote.sunWar:setIsNeedChestUpdate( true )
                self._map:clearMap()
                self._map:updateMap()
                self._map:clearPlayerInfo()
                self._map:updatePlayerInfo()
                self._map:clearChest()
                self._map:updateChest()
            elseif str == "open" then
                remote.sunWar:setIsMapFirstAppearance(false)        
                -- self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
                self._ccbam:runAnimationsForSequenceNamed("appear")
                self:_updateMapInfo()
                self._isAnimationPlaying = false
            end
        end)
    table.insert(self._aniManagers, self._cloudManager)
    table.insert(self._aniCcbViews, aniCcbView)
end

function QUIDialogSunWar:_requestChapterAward()
    local mapID = remote.sunWar:getCurrentMapID()

    if remote.sunWar:isMapChestAllOpened(mapID) then
        local isChaptersAwarded = remote.sunWar:IsChaptersAwardedByMapID(mapID)
        if isChaptersAwarded then
            if remote.sunWar:getIsChestOpening() then
                self._delayToUpdateMapInfo = true
                self:_showPromote(true)
            end
        else
            app:getClient():sunwarGetChapterAwardRequest(mapID, false, function( response )
                self._delayToUpdateMapInfo = true
                remote.sunWar:responseHandler(response)
                self:_showPromote()
            end)
        end
    else
        remote.sunWar:setIsChestOpening(false)
    end
end

function QUIDialogSunWar:_showPromote( isPass )
    if not self._isAnimationPlaying then
        self._isAnimationPlaying = true
        remote.sunWar:setIsChestOpening(false)
        if isPass then
            self:_showCloud()
        else
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSunWarPromote", 
                options = {callBack = handler(self, QUIDialogSunWar._showCloud)}}, {isPopCurrentDialog = false} )
        end
    end
end

function QUIDialogSunWar:_showReviveTips()
    -- print("QUIDialogSunWar:_showReviveTips")
    local pos, ccbFile = remote.sunWar:getReviveTipsURL()
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function ( ccbOwner )
        local buff = remote.sunWar:getBuffUpValue()
        ccbOwner.tf_buff:setString(buff.."%的战力加成")
    end)
end

function QUIDialogSunWar:_showChestAward()
    local awards = remote.sunWar:getChestAwards()
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards, callBack = handler(self, self._requestChapterAward)}}, {isPopCurrentDialog = false} )
    dialog:setTitle("恭喜您获得海神岛宝箱奖励")
end

function QUIDialogSunWar:_inspectChestAward( waveID )
    local waveInfo = remote.sunWar:getWaveInfoByWaveID( waveID )
    if waveInfo.chest_id then
        app:luckyDrawAlert( waveInfo.chest_id )
    end
end

function QUIDialogSunWar:_showFirstWin()
    if remote.sunWar:getIsWaveFirstWin() then
        remote.sunWar:setIsWaveFirstWin( false )
        local luckyDraw, userComeBackRatio = remote.sunWar:getFirstWinLuckyDraw()
        local activityYield = remote.activity:getActivityMultipleYield(609)
        app:getNavigationManager():pushViewController(app.middleLayer, 
            {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWarFirstWin", options = {luckyDraw = luckyDraw, activityYield = activityYield, userComeBackRatio = userComeBackRatio}})
        remote.sunWar:setFirstWinLuckyDraw( {} )
    end
end

function QUIDialogSunWar:_onTriggerStore()
    if self._isMoving or self._isAnimationPlaying or remote.sunWar:getIsChestOpening() then return end

    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.sunwellShop)
end

function QUIDialogSunWar:_onTriggerRevive(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_revive) == false then return end
    if self._isMoving or self._isAnimationPlaying or remote.sunWar:getIsChestOpening() then return end

    app.sound:playSound("common_small")
    if remote.sunWar:hasNoDeadHero() then
        app.tip:floatTip("魂师大人，您的队伍中没有魂师阵亡，不需要使用复活功能！")
        return
    end

    if remote.sunWar:getCanReviveCount() > 0 then
        -- if self._revive then
        --     self._revive:removeEventListener(QUIDialogSunWarAlert.REVIVE_EVENT)
        --     self._revive = nil
        -- end
        -- self._revive = 
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWarAlert"}) 
        -- self._revive:addEventListener(QUIDialogSunWarAlert.REVIVE_EVENT, handler(self, self._showBuffEffect))
    else
        self:_buyReviveCount()
    end
end

function QUIDialogSunWar:_onTriggerPlus(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
    if self._isMoving or self._isAnimationPlaying or remote.sunWar:getIsChestOpening() then return end

    app.sound:playSound("common_small")
    if remote.sunWar:hasNoDeadHero() then
        app.tip:floatTip("魂师大人，您的队伍中没有魂师阵亡，不需要购买复活次数！")
        return
    end

    if remote.sunWar:getCanReviveCount() > 0 then
        app.tip:floatTip(string.format("魂师大人，您还有%d次复活机会！", remote.sunWar:getCanReviveCount()))
        return
    end

    self:_buyReviveCount()
end

function QUIDialogSunWar:_buyReviveCount()
    local buyDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
        options = {typeName = ITEM_TYPE.SUNWAR_REVIVE_COUNT}})
    local _viewWillDisappear = buyDialog.viewWillDisappear
    function buyDialog:viewWillDisappear()
        _viewWillDisappear(self)
        if remote.sunWar:getCanReviveCount() > 0 then
            app:getClient():sunwarHeroReviveRequest(false, function(response)
                remote.sunWar:sendReviveEvent()
                remote.sunWar:responseHandler(response)

                -- remote.sunWar:addBuff( true )
                -- self:dispatchEvent({name = QUIDialogSunWarAlert.REVIVE_EVENT})
            end)
            -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWarAlert"}) 
            -- self._revive:addEventListener(QUIDialogSunWarAlert.REVIVE_EVENT, handler(self, QUIDialogSunWar._showBuffEffect))
        end
        self.viewWillDisappear = _viewWillDisappear
    end
end

function QUIDialogSunWar:_showBuffEffect()
    self._fireEndX, self._fireEndY = self._ccbOwner.node_menu:getPosition()
    self._fireEndX = self._fireEndX - 40
    self._fireEndY = self._fireEndY - 30
    -- print("[Kumo] QUIDialogSunWar:_showBuffEffect(), 战力坐标： ", self._fireEndX, self._fireEndY)
   
    self._fireStartX, self._fireStartY = self._ccbOwner.node_tips:getPosition()
    self._fireStartX = self._fireStartX + 67 + 148
    self._fireStartY = self._fireStartY + 24 + 2 + 22
    -- print("[Kumo] QUIDialogSunWar:_showBuffEffect(), 火源坐标： ", self._fireStartX, self._fireStartY)

    if not self._fires or #self._fires == 0 then
        self._fires = {}
        self._scaleTbl = {}

        for i = 1, 3, 1 do
            -- local _, urls = remote.sunWar:getBuffFireURL(i)
            local _, ccbFile = remote.sunWar:getBuffFireURL()
            self._fires[i] = QUIWidgetAnimationPlayer.new()
            self._fires[i]:playAnimation(ccbFile, nil, nil, false)
            self._fires[i]:setScaleX(1)
            self._fires[i]:setScaleY(1)
            self:getView():addChild(self._fires[i])
            self._fires[i]:setVisible(false)
        end
    end

    local pos, ccbFile = remote.sunWar:getBuffTextToFireURL()
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(aniPlayer)
    aniPlayer:setPosition(self._fireStartX, self._fireStartY)
    aniPlayer:playAnimation(ccbFile, function ()
        self._ccbOwner.node_buff_text:setVisible(false)
    end, function ()
        self:_getFirePostions()
        self._fireScheduleGlobal = scheduler.scheduleGlobal(handler(self, QUIDialogSunWar._fireAnimations), 0)
    end)
end

function QUIDialogSunWar:_getFirePostions()
    if not self._firePositions or #self._firePositions == 0 then
        self._firePositions = {}
        local totalFrame = 20
        local step = 1 / totalFrame
        -- (x, y) 三段贝塞尔曲线公式中间点的坐标， SF是前段空多少祯（不动，保持原来的坐标），EF是后段空多少祯（没有坐标）
        local ps = {{x = 0, y = -30, sf = 0, ef = 10}, {sf = 10, ef = 0}, {x = ((self._fireEndX - self._fireStartX)/2 + self._fireStartX)*2, y = 30, sf = 5, ef = 5}}
        
        for _, p in pairs(ps) do
            local tbl = {}
            if not p.x then
                -- 直线
                -- print("[Kumo] 直线")
                local step = 1 / (totalFrame - p.ef)
                local x0, x1 = self._fireStartX, self._fireEndX
                local y0, y1 = self._fireStartY, self._fireEndY
                table.insert(tbl, {x = x0, y = y0})
                for i = 0, 1, step do
                    local x = x0
                    local y = y0
                    if i > p.sf * step then
                        x = (1-i)*x0 + i*x1
                        y = (1-i)*y0 + i*y1
                    end
                    table.insert(tbl, {x = x, y = y})
                end
                table.insert(tbl, {x = x1, y = y1})
            else
                -- 曲线
                -- print("[Kumo] 曲线")
                local step = 1 / (totalFrame - p.ef)
                local x0, x1, x2 = self._fireStartX, p.x, self._fireEndX
                local y0, y1, y2 = self._fireStartY, p.y, self._fireEndY
                table.insert(tbl, {x = x0, y = y0})
                for i = 0, 1, step do
                    local x = x0
                    local y = y0
                    if i > p.sf * step then
                        x = (1-i)*(1-i)*x0 + 2*i*(1-i)*x1 + i*i*x2
                        y = (1-i)*(1-i)*y0 + 2*i*(1-i)*y1 + i*i*y2
                    end
                    table.insert(tbl, {x = x, y = y})
                end
                table.insert(tbl, {x = x2, y = y2})
            end
            table.insert(self._firePositions, tbl)
        end
    end
    
    -- QPrintTable(self._firePositions)
end

function QUIDialogSunWar:_fireAnimations()
    if not self._firePositions or #self._firePositions < 3 then return end

    if not self._fires or #self._fires == 0 then
        self._fires = {}
        self._scaleTbl = {}

        for i = 1, 3, 1 do
            -- local _, urls = remote.sunWar:getBuffFireURL(i)
            local _, ccbFile = remote.sunWar:getBuffFireURL()
            self._fires[i] = QUIWidgetAnimationPlayer.new()
            self._fires[i]:playAnimation(ccbFile, nil, nil, false)
            self._fires[i]:setScaleX(1)
            self._fires[i]:setScaleY(1)
            self:getView():addChild(self._fires[i])
            self._fires[i]:setVisible(false)
        end
    end

    if not self._isFirePlaying then
        -- 准备播放
        self._fireIndex = 1
        self._isfireEnd = {false, false, false}
        self._isShowBuff = false
        for _, fire in pairs(self._fires) do
            fire:setVisible(true)
            fire:setScaleX(1)
            fire:setScaleY(1)
            fire:setRotation(0)
        end
        remote.sunWar:setIsBuffEffectPlaying(true)
    end

    self._isFirePlaying = true
    
    for id = 1, #self._fires, 1 do
        local node = self._fires[id]
        -- print(id, self._fireIndex, self._firePositions[id][self._fireIndex].x, self._firePositions[id][self._fireIndex].y)
        if self._firePositions[id][self._fireIndex] then
            if self._firePositions[id][self._fireIndex].x ~= self._fireStartX or self._firePositions[id][self._fireIndex].y ~= self._fireStartY then
                if node:getRotation() == 0 then
                    local moveFrame = #self._firePositions[id] - self._fireIndex - 1
                    local scaleYStep = 1 / moveFrame
                    local scaleXStep = 0.1 / moveFrame
                    self._scaleTbl[id] = {scaleXStep = scaleXStep, scaleYStep = scaleYStep}
                    -- print("[Kumo] ",id, #self._firePositions[id], self._fireIndex, moveFrame)
                    -- QPrintTable(self._scaleTbl)
                end

                local x1, y1 = self._firePositions[id][self._fireIndex - 1].x, self._firePositions[id][self._fireIndex - 1].y
                local x2, y2 = self._firePositions[id][self._fireIndex].x, self._firePositions[id][self._fireIndex].y
                local a = math.deg(math.atan((x2-x1)/(y2-y1)))
                
                node:setRotation(180 + a)
                -- print("[Kumo] 角度： ", id, 180+a)
                if self._scaleTbl[id] then
                    local scaleX = node:getScaleX() - self._scaleTbl[id].scaleXStep
                    local scaleY = node:getScaleY() + self._scaleTbl[id].scaleYStep
                    node:setScaleX(scaleX)
                    node:setScaleY(scaleY)
                    -- print("[Kumo] 形变， ", id, scaleX, scaleY)
                end
            end
            node:setPosition(self._firePositions[id][self._fireIndex].x, self._firePositions[id][self._fireIndex].y)
        else
            self._isfireEnd[id] = true
            node:setVisible(false)
        end
    end

    self._fireIndex = self._fireIndex + 1

    local isEnd = true

    for id = 1, #self._fires, 1 do
        if not self._isfireEnd[id] then
            isEnd = false
        else
            if not self._isShowBuff then
                self._isShowBuff = true
                remote.sunWar:addBuff( true )
            end
        end
    end

    if isEnd then
        -- print("[Kumo] scheduler.unscheduleGlobal")
        scheduler.unscheduleGlobal(self._fireScheduleGlobal)
        self._fireScheduleGlobal = nil

        for _, fire in pairs(self._fires) do
            fire:setVisible(false)
        end

        self._isFirePlaying = false
        self._ccbOwner.node_buff_text:setVisible(true)
        self._firePerformWithDelayGlobal = scheduler.performWithDelayGlobal(function ()
            scheduler.unscheduleGlobal(self._firePerformWithDelayGlobal)
            self._firePerformWithDelayGlobal = nil
            self:_showReviveTips()
        end, 0.5)
        -- self:_showBuffEffect()
    end
end


function QUIDialogSunWar:autoFightStart(event)
    local waveID = remote.sunWar:getCurrentWaveID()
    local info = remote.sunWar:getWaveFigtherByWaveID( waveID )
    local teamKey = remote.sunWar:getSunWarTeamKey()
    local heros = clone(remote.teamManager:getActorIdsByKey(teamKey))
    local teamVO = remote.teamManager:getTeamByKey(teamKey)
    for _, actorId in pairs(heros) do
        local heroInfo = remote.sunWar:getMyHeroInfoByActorID(actorId)
        if heroInfo ~= nil and heroInfo.currHp and heroInfo.currHp <= 0 then
            teamVO:delHeroByIndex(1, actorId)
        end
    end
    remote.teamManager:saveTeamToLocal(teamVO, teamKey)

    local sunwellArrangement = QSunwarArrangement.new({dungeonInfo = info, teamKey = teamKey})
    sunwellArrangement:setIsLocal(true)
    local callback = function()     
        sunwellArrangement:setIsLocal(true)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
            options = {arrangement = sunwellArrangement}})
    end

    --阵容合理性判断
    local heroIdList = teamVO:getAllTeam()
    if #heroIdList == 0 or sunwellArrangement:teamValidity(heroIdList[1].actorIds, 1, callback) == false then 
        return
    end

    self._oldSunwellMoney = remote.user.sunwellMoney or 0
    self._oldMoney = remote.user.money or 0
    sunwellArrangement:startAutoFight(function(data)
            if self:safeCheck() then
                self:_checkRedTips()
                self:showAuotFightResult(data)
            end
        end)
end

function QUIDialogSunWar:showAuotFightResult(data)
    local isWin = data.gfEndResponse.battlefieldFightEndResponse.isWin == 1 and true or false
    if isWin == true then
        remote.activity:updateLocalDataByType(548, 1)
    end
    remote.user:addPropNumForKey("todayBattlefieldFightCount")
    app.taskEvent:updateTaskEventProgress(app.taskEvent.SUN_WAR_TASK_EVENT, 1, false, isWin)
 
    if isWin then
        local awards = {}
        local bonusAwards = {}
        
        if data.extraExpItem and type(data.extraExpItem) == "table" then
            for _, value in pairs(data.extraExpItem or {}) do
                table.insert(awards, {id = value.id or 0, typeName = value.type, count = value.count or 0})
            end
        end
        local tbl = remote.sunWar:getFirstWinLuckyDraw()
        local firstNum = 0
        local firstMoney = 0 
        if tbl and tbl.prizes then
            for _, value in pairs(tbl.prizes) do
                if value.type == "SUNWELL_MONEY" then
                    firstNum = value.count
                elseif value.type == "MONEY" then
                    firstMoney = value.count
                end
            end
        end
        table.insert(awards, {typeName = ITEM_TYPE.SUNWELL_MONEY, count = remote.user.sunwellMoney - self._oldSunwellMoney - firstNum})
        table.insert(awards, {typeName = ITEM_TYPE.MONEY, count = remote.user.money - self._oldMoney - firstMoney})
       
        local activityYield = remote.activity:getActivityMultipleYield(609)
        local userComeBackRatio = data.userComeBackRatio or 1
        local yield = remote.sunWar:getLuckyDrawCritical() or 1
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
            options = {awards = awards, activityYield = activityYield, userComeBackRatio = userComeBackRatio, yield = yield, callback = function()
                self:_showFirstWin()
            end}}, {isPopCurrentDialog = true})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", options = {callback = function()
                
            end}}, {isPopCurrentDialog = true})
    end
end

function QUIDialogSunWar:_onTriggerRule()
    -- print("QUIDialogSunWar:_onTriggerRule()", self._isMoving, self._isAnimationPlaying, remote.sunWar:getIsChestOpening())
    if self._isMoving or self._isAnimationPlaying or remote.sunWar:getIsChestOpening() then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWarRule"})
end

function QUIDialogSunWar:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogSunWar:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogSunWar:_onTriggerBack()
    -- print("QUIDialogSunWar:_onTriggerBack()", self._isMoving, self._isAnimationPlaying, remote.sunWar:getIsChestOpening())
    if self._isMoving or self._isAnimationPlaying or remote.sunWar:getIsChestOpening() then return end

    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSunWar:_onTriggerHome()
    -- print("QUIDialogSunWar:_onTriggerHome()", self._isMoving, self._isAnimationPlaying, remote.sunWar:getIsChestOpening())
    if self._isMoving or self._isAnimationPlaying or remote.sunWar:getIsChestOpening() then return end
    
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogSunWar:_onTriggerRank( )
    -- body
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "sunwell"}}, {isPopCurrentDialog = false})
end

function QUIDialogSunWar:_onTriggerReset()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWarReset", options = {resetMode = remote.sunWar:getResetMode()}}, {isPopCurrentDialog = false})
end

function QUIDialogSunWar:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    local teamKey = remote.sunWar:getSunWarTeamKey()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = teamKey}}, {isPopCurrentDialog = false})
end

function QUIDialogSunWar:_getSprite( tbl )
    local sprite = nil
    QPrintTable(tbl)
    if #tbl == 1 then
        local texture = CCTextureCache:sharedTextureCache():addImage(tbl[1])
        sprite = CCSprite:createWithTexture( texture )
    elseif #tbl == 2 then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(tbl[1])
        local spriteFrameName = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tbl[2])
        sprite = CCSprite:createWithSpriteFrame(spriteFrameName)
    end
    return sprite
end

return QUIDialogSunWar