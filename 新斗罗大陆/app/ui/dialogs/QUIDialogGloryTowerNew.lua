--
-- Author: xurui
-- Date: 2015-12-30 11:12:20
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryTowerNew = class("QUIDialogGloryTowerNew", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogRule = import("..dialogs.QUIDialogRule")
local QUIViewController = import("..QUIViewController")
local QGloryDefenseArrangement = import("...arrangement.QGloryDefenseArrangement")
local QUIWidgetGloryTowerNew = import("..widgets.QUIWidgetGloryTowerNew")
local QGloryArrangement = import("...arrangement.QGloryArrangement")
local QGloryTowerAutoArrangement = import("...arrangement.QGloryTowerAutoArrangement")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QVIPUtil = import("...utils.QVIPUtil")
local QDialogChooseCard = import("...ui.battle.QDialogChooseCard")
local QBaseArrangement = import("...arrangement.QBaseArrangement")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

function QUIDialogGloryTowerNew:ctor(options)
	local ccbFile = "ccb/Dialog_GloryTower_New.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerIntroduce", callback = handler(self, self._onTriggerIntroduce)},     
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},     
        {ccbCallbackName = "onTriggerAwards", callback = handler(self, self._onTriggerAwards)},     
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},      
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},        
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},        
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},        
        {ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)}, 
        {ccbCallbackName = "onTriggerGradeIntroduce", callback = handler(self, self._onTriggerGradeIntroduce)},
        {ccbCallbackName = "onTriggerClickChest", callback = handler(self, self._onTriggerClickChest)},
        {ccbCallbackName = "onTriggerHistoryGlory", callback = handler(self, self._onTriggerHistoryGlory)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
    }
	QUIDialogGloryTowerNew.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page.topBar:showWithTower()
    page:setScalingVisible(false)

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    -- self._ccbOwner.ly_tip_bg:setContentSize(CCSize(display.width, 80))

    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    self._totalCount = config.TOWER_TIMES_LIMIT.value
    self._CDTime = config.TOWER_CD.value * MIN
    self._refreshToken = config.TOWER_REFRESH_COST.value or 10

    self._maxRefreshTimes = QVIPUtil:getTowerFreeRefreshCount() or 3

    self._oldScore = nil
    self._isUpFloor = false
    self._isFirst = false
    self._isExitFromBattle = false
    self._canReceiveAwards = false
    self._count = 0

	self._enemy = {}
	for i = 1, 3, 1 do
		self._enemy[i] = QUIWidgetGloryTowerNew.new()
        self._enemy[i]:addEventListener(QUIWidgetGloryTowerNew.GLORY_TOWER_EVENT_CLICK, handler(self, self._fighterClickHandler))
		self._ccbOwner["enemy_node"..i]:addChild(self._enemy[i])
	end

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
end

function QUIDialogGloryTowerNew:viewDidAppear()
    QUIDialogGloryTowerNew.super.viewDidAppear(self)
    
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.updateInfo, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogBuyCount.RFRESHE_GLORY_TOWER_FIGHT_NUM, self.itemCountDown, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_ENTER_DUNGEON_LOADER, self._onEventEnterBattle, self)

    self._towerEventProxy = cc.EventProxy.new(remote.tower)
    self._towerEventProxy:addEventListener(remote.tower.EVENT_UPDATE, handler(self, self.onEvent))
    self._towerEventProxy:addEventListener(remote.tower.EVENT_TOWER_STATE_STATUS_CHANGE, handler(self, self.onEvent))

    if not remote.tower:isTowerTiresOpen() then
        if self:checkInBattle() == false then
            self:removeSelfDialog()
        end
        return
    end

    self:_checkFloorNum()
	self:setEnemyInfo()
  	self:setScoreInfo()
    self:setTokenInfo()
    -- self:setGloryDefenseHero()
    self:setForceInfo()

    self:_checkChestState()
    self:_checkRedTips()


  	self:addBackEvent(false)
    
    -- self:_checkTowerAwards()
    self:_checkFristAlert()
end

function QUIDialogGloryTowerNew:viewWillDisappear()
    QUIDialogGloryTowerNew.super.viewWillDisappear(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.updateInfo, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogBuyCount.RFRESHE_GLORY_TOWER_FIGHT_NUM, self.itemCountDown, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_ENTER_DUNGEON_LOADER, self._onEventEnterBattle, self)

    if self._towerEventProxy then
        self._towerEventProxy:removeAllEventListeners()
    end
    self:_removeTimeHandler()
    self:_removeEnemy()
	self:removeBackEvent()
end

function QUIDialogGloryTowerNew:_onEventEnterBattle(event)
    if event and event.dungeon and event.dungeon.isGlory then
        self._isEnterBattle = true
    end
end

-- function QUIDialogGloryTowerNew:checkSeasonIsEnd()
--     self:_removeTimeHandler()
--     -- check season info
--     local isEnd, endTime = remote.tower:getSeasonEndTime()
--     if isEnd then 
--         return true
--     else
--         local endTimeFunc
--         endTimeFunc = function()
--             local nowTime = q.serverTime()
--             if nowTime <= endTime then
--                 local leftTime = endTime - nowTime
--                 local day = math.floor(leftTime / (3600*24))
--                 local hour = math.floor((leftTime % (3600*24)) / 3600)
--                 local min = math.floor(((leftTime % (3600*24)) % 3600) / 60)
--                 local second = math.floor(((leftTime % (3600*24)) % 3600) % 60)
--                 local word = day.."天"..hour.."小时"..min.."分钟"
--                 if day == 0 then
--                     word = hour.."小时"..min.."分钟"..second.."秒"
--                 end
--                 self._ccbOwner.tf_left_time:setString(word)
--                 -- printInfo("~~~~~~~~~~~~~ %s小时 %s分钟 %s秒 ~~~~~~~~~~~~~~~~~~~", hour, min, second)
--             else
--                 self:_removeTimeHandler()
--                 if self:checkInBattle() == false then
--                     self:removeSelfDialog()
--                 end
--             end
--         end
--         self._endScheduler = scheduler.scheduleGlobal(endTimeFunc, 1)
--         endTimeFunc()

--         return false
--     end
-- end

function QUIDialogGloryTowerNew:checkInBattle()
    if self._isEnterBattle then
        return true
    end
    if app.battle then
        return true
    end
    return false
end 

function QUIDialogGloryTowerNew:removeSelfDialog() 
    self._removeScheduler = scheduler.performWithDelayGlobal(function()
            app.tip:floatTip("赛季已结束，正在结算奖励")
            self:popSelf()
        end, 0)
end

function QUIDialogGloryTowerNew:updateInfo(event)
    self._isEnterBattle = false
    if not remote.tower:isTowerTiresOpen() then
        if self:checkInBattle() == false then
            self:removeSelfDialog()
        end
        return
    end

    self._isExitFromBattle = true
    self:setEnemyInfo()
	self:_checkRedTips()

    self:_checkFloorNum(remote.tower:hasOldFighters())
  	self:setScoreInfo()
    self:setTokenInfo()
    self._isExitFromBattle = false
end

function QUIDialogGloryTowerNew:onEvent(event)
    if event.name == remote.tower.EVENT_TOWER_STATE_STATUS_CHANGE then
        if not remote.tower:isTowerTiresOpen() then
            if self:checkInBattle() == false then
                self:removeSelfDialog()
            end
            return
        end
    else
        self:setEnemyInfo()
        self:_checkRedTips()
    end
	
end

function QUIDialogGloryTowerNew:_updateScoreInfo()
  	self:setScoreInfo()
end

function QUIDialogGloryTowerNew:setEnemyInfo(refresh)
    if refresh then
        remote.tower:removeOldFighters()
    end

    self._towerData = remote.tower:getTowerInfo()

	local fighters = remote.tower:getFighters()
	for i = 1, 3, 1 do
        if self._enemy[i] ~= nil then
    		self._enemy[i]:setFighters(fighters[i], i, self._towerData.floor)
            if refresh then
                local effect = QUIWidgetAnimationPlayer.new()
                self._enemy[i]:addChild(effect)
                effect:setPositionY(-90)
                -- effect:retain()
                effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
                    effect:removeFromParent()
                    -- effect:release()
                    effect = nil
                end)
            end
        end
	end 
    if refresh then
        self._isExitFromBattle = false
    end
end

function QUIDialogGloryTowerNew:setScoreInfo()

    local nextConfig = QStaticDatabase:sharedDatabase():getGloryTower((self._towerData.floor or 0)+1)

    --分数显示
    local score = self._towerData.score or 1
    local nextScore = nextConfig.score or 1
    if self._oldScore == nil then
        self._oldScore = score
        self._isFirst = true
        self._ccbOwner.score_bar:setScaleX(score/nextScore)
    else
        self:showAddTips(score-self._oldScore)
        self._oldScore = score
    end

    if self._isUpFloor then
        self._isUpFloor = false
        self._ccbOwner.score_bar:setScaleX(0)
    end

    local scale = score/nextScore
    scale = scale > 1 and 1 or scale
    if self._isFirst then
        self._isFirst = false
        self._ccbOwner.score_bar:setScaleX(scale)

    else
        self._ccbOwner.score_bar:runAction(CCScaleTo:create(0.2, scale, 1))
    end

    if nextConfig.score == nil then 
        self._ccbOwner.label_score_progress:setString(math.floor(score))
        self._ccbOwner.score_bar:setScaleX(1)
    else
        self._ccbOwner.label_score_progress:setString(string.format("%d/%d", math.floor(score), math.floor(nextScore)))
    end

    local config = db:getGloryTower(self._towerData.floor or 0)
    self._ccbOwner.rank_name:setString(config.name or "")

    self._ccbOwner.icon_big:setScale(0.6)
    self._ccbOwner.icon_big:removeAllChildren()
    local floorNode = QUIWidgetFloorIcon.new({floor = self._towerData.floor or 1, iconType = "tower", isLarge = true})
    self._ccbOwner.icon_big:addChild(floorNode)
    floorNode:setShowName(false)

    self:itemCountDown()
end

function QUIDialogGloryTowerNew:showAddTips(value)
    if self._effect ~= nil then 
        self._effect:disappear()
        self._effect = nil
    end
    local effectName = nil
    if value > 0 then
        effectName = "effects/Tips_add.ccbi"
    elseif value < 0 then 
        effectName = "effects/Tips_Decrease.ccbi"
    end

    if effectName then
        local content = (value > 0) and ("+" .. value) or value

        self._effect = QUIWidgetAnimationPlayer.new()
        self._ccbOwner.add_tip_node:addChild(self._effect)
        self._effect:playAnimation(effectName, function(ccbOwner)
            ccbOwner.content:setString(content)
        end, function()
            self._effect:disappear()
        end)
    end
end

function QUIDialogGloryTowerNew:itemCountDown()
    -- self._ccbOwner.node_time:setVisible(false)
    self._count = self._towerData.fightTimes or 0
    self._ccbOwner.tf_count:setString(self._count)

    self:showBuyCount()
end

function QUIDialogGloryTowerNew:showBuyCount()
    local totalVIPNum = QVIPUtil:getCountByWordField("tower_buy_fight_times_limit", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("tower_buy_fight_times_limit")
    local buyCount = remote.tower:getTowerInfo().fightTimesBuyCount or 0

    self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)

    -- self._ccbOwner.node_time:setVisible(self._count < self._totalCount)
end

function QUIDialogGloryTowerNew:setTokenInfo()
    if (self._towerData.refreshTimes or 0) < self._maxRefreshTimes then
        self._ccbOwner.tf_token:setString("免费")
    else
        self._ccbOwner.tf_token:setString(self._refreshToken)
    end
end

function QUIDialogGloryTowerNew:setForceInfo()
    local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.GLORY_DEFEND_TEAM, false)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
    local num, unit
    num,unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
    local color = string.split(fontInfo.force_color, ";")
    self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
    
    self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.GLORY_DEFEND_TEAM))

    self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
    self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
end

function QUIDialogGloryTowerNew:checkDenfensIsChange(teams)
    if teams == nil then 
        teams = {}
    end
    local defenseHeros = {}
    for _,value in pairs(teams) do
        if remote.herosUtil:getHeroByID(value) ~= nil then
            table.insert(defenseHeros, value)
        end
    end
   teams = defenseHeros
    if #teams == 0 then
        return true, remote.teamManager:getActorIdsByKey(remote.teamManager.ARENA_DEFEND_TEAM)
    else
        local localTeams = remote.teamManager:getActorIdsByKey(remote.teamManager.GLORY_DEFEND_TEAM)
        if table.nums(localTeams) > 0 then
            if table.nums(localTeams) ~= table.nums(teams) then
                return true,localTeams
            end
            for _,actorId in pairs(teams) do
                local isFind = false
                for _,localActorId in pairs(localTeams) do
                    if actorId == localActorId then
                        isFind = true
                    end
                end
                if isFind == false then
                    return true,localTeams
                end
            end
        end
    end
    return false,nil
end


function QUIDialogGloryTowerNew:_removeTimeHandler()
    if self._endScheduler ~= nil then
        scheduler.unscheduleGlobal(self._endScheduler)
        self._endScheduler = nil
    end
    if self._removeScheduler ~= nil then
        scheduler.unscheduleGlobal(self._removeScheduler)
        self._removeScheduler = nil
    end
end

function QUIDialogGloryTowerNew:_removeEnemy()
	if next(self._enemy) then
		for _, value in pairs(self._enemy) do
			value:removeFromParent()
			value = nil
		end
	end
    self._enemy = {}
end

function QUIDialogGloryTowerNew:_checkFloorNum(hasOldFighters)
	local oldFloor = remote.tower:getOldTowerFloor()
	local floor = remote.tower:getTowerInfo().floor or 1
	local dialogType = "win"

	if oldFloor == 0 then
        if hasOldFighters then
            self:setEnemyInfo(true)
        end
		return
	elseif oldFloor == floor then 
        if hasOldFighters then
            self:setEnemyInfo(true)
        end
		remote.tower:setOldTowerFloor(0)
        return 
	elseif floor - oldFloor < 0 then
		dialogType = "lose"
        return 
	end
    
    self._isUpFloor = true
	remote.tower:setOldTowerFloor(0)
    app.taskEvent:updateTaskEventProgress(app.taskEvent.GLORY_ARENA_CLASS_UP_EVENT, 1)
    
    local callback = function ( ... )
        if self:safeCheck() then
            self:setEnemyInfo(true)
            self:_checkChestState()
        end
    end

    local successTip = app.master.GLORY_TOWER_FLOOR_TIP
    if app.master:getMasterShowState(successTip) then
    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryTowerTips", 
    		options = {lastFloor = oldFloor, floor = floor, dialogType = dialogType, callFunc = callback, successTip = successTip}})
    else
        callback()
    end
end

function QUIDialogGloryTowerNew:_checkRedTips()
	self._ccbOwner.record_tips:setVisible(false)
	self._ccbOwner.awards_tips:setVisible(false)
	self._ccbOwner.shop_tips:setVisible(false)

  	if remote.stores:checkFuncShopRedTips(SHOP_ID.gloryTowerShop) then
  		self._ccbOwner.shop_tips:setVisible(true)
  	end
    if remote.tower:hasAvailableTodayAward() then
        self._ccbOwner.awards_tips:setVisible(true)
    end
end

function QUIDialogGloryTowerNew:_checkChestState()
    local towerInfo = remote.tower:getTowerInfo()
    if towerInfo.awardFloors ~= nil and next(towerInfo.awardFloors) ~= nil then
        self._canReceiveAwards = true
        self._ccbOwner.node_gold_light:setVisible(true)
    else
        self._ccbOwner.node_gold_light:setVisible(false)
        self._canReceiveAwards = false
    end

    if self._canReceiveAwards == false then
        -- local floor = self._towerData.floor+1
        -- local towerConfig = QStaticDatabase:sharedDatabase():getGloryTower(floor)
        -- self._ccbOwner.node_gold_close:setVisible(next(towerConfig) ~= nil)
        if self._towerData.weekMaxFloor >= 28 then
            self._ccbOwner.node_gold_light:setVisible(false)
            self._ccbOwner.node_gold_close:setVisible(false)
        end
    end
end 

-- function QUIDialogGloryTowerNew:_checkTowerAwards()
--     local towerData = remote.tower:getTowerInfo()
--     if towerData.awards and not (towerData.awards == "") then
--         local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
--         self.dialogCard = QDialogChooseCard.new({rewrad =  towerData.awards}, {onCloseCard = function ( ... )
--             page:setManyUIVisible(true)
--             page:setBackBtnVisible(true)
--             page:setScalingVisible(false)
--             page.topBar:showWithTower()
--             self.dialogCard:removeFromParent()
--         end})
--         page:setManyUIVisible(false)
--         page.topBar:hideAll()
--         page:setBackBtnVisible(false)
--         page:setScalingVisible(false)
--         self.dialogCard:setPosition(ccp(0, 0))
--         self:getView():addChild(self.dialogCard)
--     end
-- end

function QUIDialogGloryTowerNew:_checkFristAlert()
    -- local lastTime = (self._towerData.enterTowerTime or 0)/1000

    -- local isEnd, endTime, gloryTowerClearTime = remote.tower:getSeasonEndTime()

    -- if gloryTowerClearTime <= lastTime then
    --     return 
    -- end
    -- self._towerData.enterTowerTime = q.serverTime()*1000
    if not remote.tower:isTowerTiresOpen() then

        local towerAlert = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryTowerSeasonEnd",
                            options = {lastFloor = self._towerData.weekendFloor}})
    end
end

------------------------------------------- event click ---------------------------------------

function QUIDialogGloryTowerNew:onFighterHandler(event)
    local fighter = event.fighter
    remote.tower:towerQueryFightRequest(fighter.userId, fighter.env, fighter.actorIds, function(data)
        local fighterResponse = data.towerFightersDetail[1] or {}
        local gloryArrangement = QGloryArrangement.new({fighter = fighterResponse, towerData = self._towerData})
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
            options = {arrangement = gloryArrangement}})
    end)    
end
function QUIDialogGloryTowerNew:onAutoFighterHandler(event)
    if self.gloryTowerAutoArrangement then return end

    local fighter = event.fighter
    remote.tower:towerQueryFightRequest(fighter.userId, fighter.env, fighter.actorIds, function(data)
        local fighterResponse = data.towerFightersDetail[1] or {}
        self.gloryTowerAutoArrangement = QGloryTowerAutoArrangement.new({rivalInfo = fighterResponse, towerData = self._towerData, callback = function ()
            if self:safeCheck() then
                self:updateInfo()
                self.gloryTowerAutoArrangement = nil
            end
        end})
    end) 
    

end

function QUIDialogGloryTowerNew:_fighterClickHandler(event)
    if event.name == QUIWidgetGloryTowerNew.GLORY_TOWER_EVENT_CLICK then
        if self._isExitFromBattle then return end
        app.sound:playSound("common_small")

        -- 说要加的，撤销了
        -- local nowTime = q.serverTime() 
        -- local nowDateTable = q.date("*t", nowTime)
        -- if 0 <= nowDateTable.hour and nowDateTable.hour < 5 then
        --     app.tip:floatTip("每日0点—5点期间无法挑战")
        --     return
        -- end

        if self._count == 0 then
             if self:_onPlusHandler() == false then
                app.tip:floatTip("挑战次数已达到上限")
            end
            return
        end 

        if not event.isQuickFight then
            self:onFighterHandler(event)
        else
            self:onAutoFighterHandler(event)
        end
    end
end

function QUIDialogGloryTowerNew:_getItemTypeById( itemId )
    local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( itemId )
    if not itemConfig then
        app.tip:floatTip("没有id["..itemId.."]的配置，请策划检查量表")
        return ITEM_TYPE.ITEM
    end
    if itemConfig.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
        return ITEM_TYPE.GEMSTONE_PIECE
    elseif itemConfig.type == ITEM_CONFIG_TYPE.GEMSTONE then
        return ITEM_TYPE.GEMSTONE
    else
        return ITEM_TYPE.ITEM
    end
    return ITEM_TYPE.ITEM
end

function QUIDialogGloryTowerNew:_onTriggerRecord()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAgainstRecord", options = {reportType = REPORT_TYPE.GLORY_TOWER}}, 
	        {isPopCurrentDialog = false})
end

function QUIDialogGloryTowerNew:_onTriggerIntroduce()
    app.sound:playSound("common_small")
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRule", options = {ruleType = QUIDialogRule.GLORYTOWER_RULE}})

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryTowerRewardRules", options = {info = {rank = self._towerData.rank, floor = self._towerData.floor, maxFloor = self._towerData.maxFloor}}})
end

--跳转到 段位说明
function QUIDialogGloryTowerNew:_onTriggerGradeIntroduce()
    app.sound:playSound("common_small")
    -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRule", options = {ruleType = QUIDialogRule.GLORYTOWER_RULE}})
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryTowerRewardRules", options = {info = {rank = self._towerData.rank, floor = self._towerData.floor, maxFloor = self._towerData.maxFloor}, scrollDistance = 105}})
end

function QUIDialogGloryTowerNew:_onTriggerShop()
    app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.gloryTowerShop)
end

function QUIDialogGloryTowerNew:_onTriggerRank()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "gloryTower"}}, {isPopCurrentDialog = false})
end

function QUIDialogGloryTowerNew:_onTriggerTeam(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
    app.sound:playSound("common_small") 
	local arenaArrangement = QGloryDefenseArrangement.new({selectSkillHero = self._towerData.activeSubActorId, teamKey = remote.teamManager.GLORY_DEFEND_TEAM})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = arenaArrangement, isBattle = true}})
end

function QUIDialogGloryTowerNew:_onTriggerAwards()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryTowerDailyReward", options = {closeCallback = handler(self, self._checkRedTips)}}, {isPopCurrentDialog = false})
end

function QUIDialogGloryTowerNew:_onTriggerClickChest()
    if self._ccbOwner.node_gold_close:isVisible() == false then return end
    app.sound:playSound("common_small")

    local floor = (self._towerData.weekMaxFloor or 1)+1
    if self._canReceiveAwards then
        floor = remote.tower:getTowerInfo().awardFloors[1]
    end
    
    local awardFloors = remote.tower:getTowerInfo().awardFloors or {}
    local awards = {}
    for _, value in ipairs(awardFloors) do
        local towerConfig = QStaticDatabase:sharedDatabase():getGloryTower(value)
        table.insert(awards, {id = nil, typeName = "token", count = tonumber(towerConfig.award) or 0})
    end

    local isQuickUnlock = app.unlock:checkLock("UNLOCK_TOWER_OF_GLORY_QUICK_BOX")
    if self._canReceiveAwards and next(awards) then
        remote.tower:towerReceiveFloorAwards(tonumber(floor), function()
                if self.class ~= nil then
                    if app.unlock:checkLock("UNLOCK_TOWER_OF_GLORY_QUICK_BOX") then
                        local newFloor = remote.tower:getTowerInfo().floor or 1
                        local oldFloor = (floor or 1) - 1
                        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryTowerAwardsAlert",
                            options = {awards = awards, lastFloor = oldFloor, floor = newFloor, callBack = function()
                            end}},{isPopCurrentDialog = false} )
                    else
                        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                            options = {awards = {awards[1]}, callBack = function()
                            end}},{isPopCurrentDialog = false} )
                        dialog:setTitle("恭喜获得升段奖励")
                    end
                    self:_checkChestState()
                end
            end)
    else
        local towerConfig = QStaticDatabase:sharedDatabase():getGloryTower(floor)
        local award = {}
        table.insert(award, {id = nil, typeName = "token", count = tonumber(towerConfig.award) or 0})
        local tips = "领取条件：当大魂师赛达到"..(towerConfig.name).."段位"
        app:luckyDrawAlert(nil, tips, award)
    end
end

function QUIDialogGloryTowerNew:_onTriggerRefresh(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_refresh) == false then return end
    app.sound:playSound("common_small")
    local todayAward = remote.tower:getTodayAward()
    remote.tower:towerRefreshRequest(function()
            -- http://jira.joybest.com.cn/browse/WOW-10048
            remote.tower:setTodayAward(todayAward)
            self:_checkRedTips()

            self:setTokenInfo()
            self:setEnemyInfo(true)
        end)
end

function QUIDialogGloryTowerNew:_onPlusHandler(callback) 
    -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
    --     options = {typeName = QUIDialogBuyCount["BUY_TYPE_9"], buyCallback = function ()
    --         if self:safeCheck() then
    --             self:itemCountDown()
    --             if callback ~= nil then callback() end
    --         end
    --     end}})
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
        options = {cls = "QBuyCountGloryTower", buyCallback = function ()
            if self:safeCheck() then
                self:itemCountDown()
                if callback ~= nil then callback() end
            end
        end}})

    return true
end

function QUIDialogGloryTowerNew:_onTriggerPlus(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_plus) == false then return end
    app.sound:playSound("common_small")
    if self:_onPlusHandler() == false then
        app.tip:floatTip("可购买挑战次数已达到上限")
    end
end

function QUIDialogGloryTowerNew:_onTriggerHistoryGlory()
    app.sound:playSound("common_small")
   
  
    remote.tower:requestTowerGloryWallInfo(function(data)
        if self:safeCheck() then
            
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryTowerHistoryGlory", options = {historyType = 1, data = data.towerGetGloryWallInfoResponse.towerloryWallInfos}})
        end
    end)

    -- else
    --     app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryTowerHistoryGlory"})
    -- end
end

function QUIDialogGloryTowerNew:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.GLORY_DEFEND_TEAM}}, {isPopCurrentDialog = false})
end

function QUIDialogGloryTowerNew:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogGloryTowerNew:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogGloryTowerNew:_showVipAlert()
    app.tip:floatTip("魂师大人大人，当前购买次数已用完。")
    -- app:vipAlert({title = "挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.TOWER_BUY_COUNT}, false)
end

return QUIDialogGloryTowerNew