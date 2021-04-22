--
-- Author: Your Name
-- Date: 2015-02-02 11:07:01
--
local QBaseModel = import("..models.QBaseModel")
local QTower = class("QTower",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")
local QUIViewController = import("..ui.QUIViewController")

QTower.EVENT_UPDATE = "EVENT_UPDATE"
QTower.EVENT_FIGHTER_UPDATE = "EVENT_FIGHTER_UPDATE"
QTower.EVENT_TOWER_STATE_CHANGE = "EVENT_TOWER_STATE_CHANGE"
QTower.EVENT_TOWER_GLORY_ARENA_YAOQING = "EVENT_TOWER_GLORY_ARENA_YAOQING"
QTower.EVENT_TOWER_STATE_STATUS_CHANGE = "EVENT_TOWER_STATE_STATUS_CHANGE"
QTower.EVENT_TOWER_AUTOWORSHIP = "EVENT_TOWER_AUTOWORSHIP"
--
QTower.GLORY_ARENA_REFRESH = "GLORY_ARENA_REFRESH"
QTower.GLORY_ARENA_REDTIPS_CHANGE = "GLORY_ARENA_REDTIPS_CHANGE"



QTower.ICON_MAPPING = {"GloryTower_lv_Bronze.png", "GloryTower_lv_silver.png", "GloryTower_lv_Glod.png", "GloryTower_lv_platinum.png", "GloryTower_lv_Diamond.png", "GloryTower_zi_zhizun.png", "GloryTower_Floor_lv.png"}
QTower.ROMAN_MAPPING = {"luoma1.png", "luoma2.png", "luoma3.png", "luoma4.png", "luoma5.png"}

function QTower:ctor()
	QTower.super.ctor(self)
	cc.GameObject.extend(self)

    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self._upgradeTowerRwards = false
    self._oldTowerFloor = 0
    self._historySeasonInfo = {}
    self._historyFighterInfo = {}

    self._curState = 0
    self._isEnd = true

    self._isInitGloryArena = false
    self._isNotInit = true
    self._isNotGetDefendTeam = true
end

function QTower:loginEnd(  )

end



function QTower:getTowerInfoByLogin( success,fail )
    -- body
    if app.unlock:getUnlockGloryTower() then
        self:updateTowerTime(true)
        if self:isTowerFightOpen() then
            self:initGloryArenaVar() 
        end

        self:requestGloryDefendTeam(function (data)
            self:updateGloryDefendTeam(data.defenseArmyResponse)
            self._isNotGetDefendTeam = nil
        end)

        self:getSimpleTowerInfo(success,fail)
        self._isNotInit = nil
    else
        if success then
            success()
        end
    end
end

function QTower:openGloryTower()
    if app.unlock:getUnlockGloryTower() then
        if self._isNotInit then
            self:updateTowerTime(true)
            self:getSimpleTowerInfo(success,fail)
            self._isNotInit = nil
        end
        if self:isTowerFightOpen() and not self._isInitGloryArena then
            self:initGloryArenaVar() 
        end
        if self._isNotGetDefendTeam then
            self:requestGloryDefendTeam(function (data)
                self:updateGloryDefendTeam(data.defenseArmyResponse)
                self._isNotGetDefendTeam = nil
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryEntrance"})
            end) 
        else
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryEntrance"})
        end
    end
end 

function QTower:getTowerInfo()
    return self._towerInfo or {}
end

function QTower:setTowerInfo(towerInfo)
    self._towerInfo = towerInfo
    if self._towerInfo.maxFloor > (remote.user.towerMaxFloor or 0) then
        remote.user:update({towerMaxFloor = self._towerInfo.maxFloor})
    end
    if self._towerInfo.avatar_account_floor then
        remote.user:update({towerAvatarAccountFloor = self._towerInfo.avatar_account_floor})
    end
    self:dispatchEvent({name = QTower.EVENT_UPDATE})
end

function QTower:getOldTowerFloor()
    return self._oldTowerFloor or 0
end

function QTower:setOldTowerFloor(floor)
    self._oldTowerFloor = floor
end

function QTower:getFighters()
    if self._oldFighters then
        return self._oldFighters
    else
        return self._fighters or {}
    end
end

function QTower:saveOldFighters()
    self._oldFighters = self._fighters
end

function QTower:removeOldFighters()
    self._oldFighters = nil
end

function QTower:hasOldFighters()
    return self._oldFighters ~= nil
end

function QTower:setFighters(fighters)
    self._fighters = fighters

    self:dispatchEvent({name = QTower.EVENT_FIGHTER_UPDATE})
end

function QTower:removeTowerAwards()
    self._towerInfo.awards = "" 
end

function QTower:requestTowerInfo(func)
    if app.unlock:getUnlockGloryTower() then
        self:towerInfoRequest(function (data)
            self:setTowerInfo(data.towerInfo)
            if func then
                func(data)
            end
        end)
    end
end

function QTower:checkGloryTowerRedTips()
    if app.unlock:getUnlockGloryTower() then
        if self:isTowerTiresOpen() then
            if self._towerInfo == nil then return true end
            local shopInfo = remote.stores:getShopResousceByShopId(SHOP_ID.gloryTowerShop)
            if remote.stores:checkFuncShopRedTips(SHOP_ID.gloryTowerShop) then
                return true
            end
            if self:hasAvailableTodayAward() then
                return true
            end
            if self._towerInfo.awardFloors ~= nil and next(self._towerInfo.awardFloors) ~= nil then
                return true
            end
        elseif self:isTowerFightOpen() and self._isInitGloryArena then
            if self:checkGloryArenaRedTips() then
                return true
            end
        end
        if not remote.teamManager:checkTeamStormIsFull(remote.teamManager.GLORY_DEFEND_TEAM) then
            return true
        end
    end
    -- local freeStroes = remote.stores:getStoresById(SHOP_ID.gloryTowerFreeShop)
    -- if next(freeStroes) == nil then return false end
    -- if freeStroes[1].count ~= 0 then return true end

    return false
end

function QTower:checkTowerCanFight()
    if self:isTowerTiresOpen() then
        if self._towerInfo and self._towerInfo.fightTimes and self._towerInfo.fightTimes > 0 then
            return true
        end
    elseif self:isTowerFightOpen() and self._isInitGloryArena then
        if self.gloryArenaCanFight then
            return true
        end
    end

    return false
end

function QTower:isTowerTiresOpen(  )
    -- body
    if self._curState == 1 and not self._isEnd then
        return true
    else
        return false
    end
end

function QTower:isTowerFightOpen(  )
    -- body
  
    if self._curState == 2 and not self._isEnd then
        return true
    else
        return false
    end
end

function QTower:isTowerFightStage(  )
    -- body
    return self._curState == 2
end

--魂师大赛 段位赛
function QTower:updateTowerTime( isNeedDispatch )
    -- body
    local curState = 0 --0 表示 段位赛 1 表示 争霸赛
    local isEnd = false
    local nowTime = q.serverTime() 
    --偏移半个小时
    local nowDateTable = q.date("*t", nowTime)

    if nowDateTable.wday < 2 then 
        nowDateTable.wday = nowDateTable.wday + 7
    end

    local leftTime = 0  --结束时间
    local nextOpenTiersTime = 0 --下次开启段位赛时间
    local nextOpenFightTime = 0 --下次开启争霸赛时间

    local startTime = nowTime - (nowDateTable.wday - 2) * DAY - nowDateTable.hour * HOUR - nowDateTable.min * MIN  - nowDateTable.sec
    local time1 = startTime
    local time2 = startTime + 5*DAY
    local time3 = startTime + 5*DAY + 30*MIN
    local time4 = startTime + 6*DAY + 22*HOUR
    local time5 = startTime + 7*DAY 


    if nowTime >= time1 -1 and  nowTime <= time3 -1 then
        curState = 1
        if nowTime >= time2 -1 then
            isEnd = true
            nextOpenFightTime = time3 - nowTime
            nextOpenTiersTime = time5 - nowTime
            leftTime = nextOpenFightTime
        else
            nextOpenFightTime = time3 - nowTime
            leftTime = time2 - nowTime
        end
    else
        curState = 2
        if nowTime >= time4 -1 then
            isEnd = true
            nextOpenTiersTime = time5 - nowTime
            nextOpenFightTime =  (time5 - nowTime) + 5*DAY + 30*MIN
            leftTime = nextOpenTiersTime
        else
            nextOpenTiersTime = time5 - nowTime
            leftTime = time4 - nowTime
        end
    end
    --周一00:00:00 到 周五23:59  段位赛
    if self._curState ~= 0 and self._curState ~= curState then
        self:towerStateChange(curState)
    end

    self._curState = curState
    self._isEnd = isEnd

    if isNeedDispatch then
        if leftTime > 0 then
            app:getAlarmClock():createNewAlarmClock("activityTurntableEnd", nowTime + leftTime , function (  )
                -- body
                 self:updateTowerTime(true) 
            end)
        end
        self:dispatchEvent({name = QTower.EVENT_TOWER_STATE_STATUS_CHANGE})
    end

    return curState, isEnd, leftTime, nextOpenTiersTime, nextOpenFightTime 
end


function QTower:towerStateChange( state )
    -- body
    if state == 1 then
        remote.stores:changeAwardId(SHOP_ID.gloryTowerShop,SHOP_ID.gloryTowerAwardsShop)
        app:getAlarmClock():createNewAlarmClock("requestTowerSimpleData", q.serverTime() + 2 , function (  )
                -- body
                 self:getSimpleTowerInfo() 
            end)
    elseif state == 2 then
        self:initGloryArenaVar()
        app:getAlarmClock():createNewAlarmClock("requestTowerGloryArenaSimpleData", q.serverTime() + 2 , function (  )
            -- body
            self:getSimpleTowerInfo() 
        end)
    end
    self:dispatchEvent({name = QTower.EVENT_TOWER_STATE_CHANGE})
end


-- 获得魂师大赛本赛季的结束时间
function QTower:getSeasonEndTime()

    local isEndTime = false
    local nowTime = q.serverTime()
    local nextEndTime = q.date("*t", nowTime)
    local lastEndTime = q.date("*t", nowTime)

    local refreshWday = 7    -- 星期几刷新
    local refreshHourTime = 00   -- 刷新小时
    local refreshMinTime = 00   -- 刷新分钟
    local endHourTime = 00   -- 结束小时
    local endMinTime = 10   -- 结束分钟

    local refreTime = q.getTimeForHMS(refreshHourTime, refreshMinTime, 0)
    local endTime = q.getTimeForHMS(endHourTime, endMinTime, 0)

    if nextEndTime.wday == refreshWday and nowTime >= refreTime and nowTime <= endTime then
        isEndTime = true
        lastEndTime.day = lastEndTime.day - 7
    elseif nextEndTime.wday == refreshWday and nowTime > endTime then
        nextEndTime.day = nextEndTime.day + 7
    else
        local offsetTime = refreshWday-nextEndTime.wday >= 0 and refreshWday-nextEndTime.wday or 7+refreshWday-nextEndTime.wday
        nextEndTime.day = nextEndTime.day + offsetTime
        lastEndTime.day = lastEndTime.day - (7-offsetTime)
    end
    nextEndTime.hour = refreshHourTime
    nextEndTime.min = refreshMinTime
    nextEndTime.sec = 0
    nextEndTime = q.OSTime(nextEndTime)

    lastEndTime.hour = endHourTime
    lastEndTime.min = endMinTime
    lastEndTime.sec = 0
    lastEndTime = q.OSTime(lastEndTime)

    return isEndTime, nextEndTime, lastEndTime
end

function QTower:getTodayAward()
    local data = self:getTowerInfo()
    return data.todayAward or ""
end

function QTower:setTodayAward(todayAward)
    local data = self:getTowerInfo()
    data.todayAward = todayAward
end

function QTower:addTodayAward(add_id)
    local data = self:getTowerInfo()
    local todayAward = data.todayAward or ""
    local ids = string.split(todayAward, ";")
    for _, id in ipairs(ids) do
        if tostring(id) == tostring(add_id) then
            return
        end
    end
    data.todayAward = todayAward .. ";" .. add_id
end

function QTower:hasAvailableTodayAward()
    local data = self:getTowerInfo()
    local todayAward = data.todayAward or ""
    local todayScore = data.todayScore or 0
    local ids = string.split(todayAward, ";")
    local rewards = QStaticDatabase:sharedDatabase():getGloryTowerDailyReward()
    for _, config in pairs(rewards) do
        if config.score_service <= todayScore then
            local alreadyRedeemed = false
            for _, id in ipairs(ids) do
                if tonumber(id) == tonumber(config.id) then
                    alreadyRedeemed = true
                    break
                end
            end
            if not alreadyRedeemed then
                return true
            end
        end
    end
    return false
end

function QTower:getFloorTextureName(floor)
    local config = QStaticDatabase:sharedDatabase():getGloryTower(floor)
    local towerIcon = string.split(config.icon or "", "^")

    local icon = QResPath("tower_icon_floor")[tonumber(towerIcon[1])]
    local level = nil
    if towerIcon[2] then
        level = QResPath("tower_level_floor")[tonumber(towerIcon[2])]
    end
    return config.name, icon, level
end

--[[
    当前层的敌人的攻击顺序(给QAIDPSARENA使用)
    返回一个array，或者nil
]]
function QTower:getCurrentFloorTargetOrder()
    if self._towerInfo then
        local floor = self._towerInfo.floor
        local config = QStaticDatabase:sharedDatabase():getGloryTower(floor)
        if config and config.enemy_ai then
            local arr = string.split(config.enemy_ai, ",")
            for i, order in ipairs(arr) do
                arr[i] = tonumber(order)
            end
            return arr
        end
    end
end

function QTower:setTowerSeasonInfo(info)
    self._historySeasonInfo = info.seasons

    for i = 1, #self._historySeasonInfo do
        local startAt = self._historySeasonInfo[i].startAt
        local endAt = self._historySeasonInfo[i].endAt
        self._historySeasonInfo[i].startAt = string.sub(startAt, 1, 4).."."..string.sub(startAt, 5, 6).."."..string.sub(startAt, 7, 8)
        self._historySeasonInfo[i].endAt = string.sub(endAt, 1, 4).."."..string.sub(endAt, 5, 6).."."..string.sub(endAt, 7, 8)
    end
end

function QTower:getTowerSeasonInfoBySeasonNo(seasonNo)
    for i = 1, #self._historySeasonInfo do
        if self._historySeasonInfo[i].seasonNo == seasonNo then
            return self._historySeasonInfo[i]
        end
    end
    return {}
end

function QTower:setTowerHistoryFighterInfo(areaType, seasonNo, fighters)
    if self._historyFighterInfo[areaType] == nil then
        self._historyFighterInfo[areaType] = {}
        self._historyFighterInfo[areaType][seasonNo] = fighters
    else
        self._historyFighterInfo[areaType][seasonNo] = fighters
    end
end

function QTower:getTowerHistoryFighterInfo(areaType, seasonNo)
    if self._historyFighterInfo[areaType] == nil then return {} end
    return self._historyFighterInfo[areaType][seasonNo] or {}
end

-------------------------------request Handler------------------------------

-- 魂师大赛
function QTower:towerResponse(response,success)
    if response.towerFighters ~= nil then
        self:setFighters(response.towerFighters)
    end
    if response.towerInfo ~= nil then
        self:setTowerInfo(response.towerInfo)
    end
    if response.towerGetLatestSeasonsResponse then
        self:setTowerSeasonInfo(response.towerGetLatestSeasonsResponse)
    end

    if success ~= nil then success(response) end
end

function QTower:towerInfoRequest(success, fail, status)
   
    local request = {api = "TOWER_INFO"}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_INFO", request, successCallback, fail)
    
end

function QTower:towerRefreshRequest(success, fail, status)
    local request = {api = "TOWER_REFRESH"}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_REFRESH", request, successCallback, fail)
end

function QTower:towerBuyFightCountRequest(success, fail, status)
    local request = {api = "TOWER_BUY_FIGHT_COUNT"}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_BUY_FIGHT_COUNT", request, successCallback, fail)
end

function QTower:towerFightStartRequest(rivalId, battleFormation, success, fail, status)
    local towerFightStartRequest = {rivalUserId = rivalId}
    local gfStartRequest = {battleType = BattleTypeEnum.GLORY_TOWER, battleFormation = battleFormation, towerFightStartRequest = towerFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, successCallback, fail)
end

function QTower:towerFightEndRequest(rivalUserId, fightResult, verifyDamages, battleKey, isQuickFight, battleFormation, success, fail, status)
    local towerFightEndRequest = {rivalUserId = rivalUserId, fightResult = fightResult, damage = {damages = verifyDamages}}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    towerFightEndRequest.isQuickFight = isQuickFight
    towerFightEndRequest.battleVerify = q.battleVerifyHandler(battleKey)
    
    local gfEndRequest = {battleType = BattleTypeEnum.GLORY_TOWER, battleVerify = towerFightEndRequest.battleVerify, isQuick = isQuickFight, isWin = nil,
                         fightReportData = fightReportData, towerFightEndRequest = towerFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    local successCallback = function (response)
        remote.user:addPropNumForKey("todayTowerFightCount")
        remote.user:addPropNumForKey("c_towerFightCount")
        if response.gfEndResponse and response.gfEndResponse.isWin then
            remote.activity:updateLocalDataByType(552, 1)
            app.taskEvent:updateTaskEventProgress(app.taskEvent.GLORY_ARENA_TASK_EVENT, 1, false, true)
        end
                      
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, fail, status)
end

function QTower:towerChangeDefenseHeroesRequest(battleFormation, success, fail, status)
    local towerChangeDefenseHerosRequest = {}
    local request = {api = "TOWER_CHANGE_DEFENSE_HEROS", towerChangeDefenseHerosRequest = towerChangeDefenseHerosRequest, battleFormation = battleFormation}
    local successCallback = function (response)
        self:changeGloryArenaMyTeamInfo(true)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_CHANGE_DEFENSE_HEROS", request, successCallback, fail)
end

function QTower:towerReceiveAwardsRequest(awards, success, fail, status)
    local towerReceiveAwardsRequest = {awards = awards}
    local request = {api = "TOWER_RECEIVE_AWARDS", towerReceiveAwardsRequest = towerReceiveAwardsRequest}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_RECEIVE_AWARDS", request, successCallback, fail)
end

function QTower:towerQueryHistoryRequest(success, fail, status)
    local request = {api = "TOWER_QUERY_HISTORY"}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_QUERY_HISTORY", request, successCallback, fail)
end

function QTower:towerQueryFightRequest(userId, env, actorIds, success, fail, status)
    local towerQueryFighterRequest = {userId = userId, env = env, actorIds = actorIds}
    local request = {api = "TOWER_QUERY_FIGHTER", towerQueryFighterRequest = towerQueryFighterRequest}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_QUERY_FIGHTER", request, successCallback, fail)
end

-- 领取魂师大赛段位奖励
function QTower:towerReceiveFloorAwards(floor, success, fail, status)
    local towerGetFloorPromoteAwardRequest = {floor = floor}
    local request = {api = "TOWER_GET_FLOOR_PROMOTE_AWARD", towerGetFloorPromoteAwardRequest = towerGetFloorPromoteAwardRequest}
    local successCallback = function (response)
        self:towerResponse(response,success)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.GLORY_ARENA_CLASS_AWARD_COUNT_EVENT, tonumber(floor))
    end
    app:getClient():requestPackageHandler("TOWER_GET_FLOOR_PROMOTE_AWARD", request, successCallback, fail)
end

--[[
    获取简单的魂师大赛信息
]]
function QTower:getSimpleTowerInfo(success,fail)
    if self:isTowerTiresOpen() then
        local request = {api = "TOWER_GET_SIMPLE_INFO"}
        local successCallback = function (response)

            self:towerResponse(response,success)
        end
        app:getClient():requestPackageHandler("TOWER_GET_SIMPLE_INFO", request, successCallback, fail)
    elseif self:isTowerFightOpen() then
        local request = {api = "GLORY_COMPETITION_GET_INFO"}
        local successCallback = function (data)
            self:gloryArenaRefresh(data)
            if success then
                success()
            end
        end
        app:getClient():requestPackageHandler("GLORY_COMPETITION_GET_INFO", request, successCallback, fail)
    else
        if success then
            success()
        end
    end
end

--[[
    获取魂师大赛历史赛季信息
]]
function QTower:getTowerHistorySeasonInfo(success, fail, status)
    local request = {api = "TOWER_GET_LATEST_SEASONS"}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_GET_LATEST_SEASONS", request, successCallback, fail)
end

--[[
    获取荣耀墙魂师信息
]]
function QTower:getTowerHistoryFighterInfoRequest(isAllEnv, seasonNO, success, fail, status)
    local towerGetGloryWallInfoRequest = {isAllEnv = isAllEnv, seasonNO = seasonNO}
    local request = {api = "TOWER_GET_GLORY_WALL_INFO", towerGetGloryWallInfoRequest = towerGetGloryWallInfoRequest}
    local successCallback = function (response)
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("TOWER_GET_GLORY_WALL_INFO", request, successCallback, fail)
end



--------跨服斗魂场--------
-------------------------

function QTower:updateGloryDefendTeam( data )
    -- body
    local battleFormation = data.defenseFormation or {}
    -- 
    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.GLORY_DEFEND_TEAM)
    if not(battleFormation.mainHeroIds ~= nil) then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.GLORY_DEFEND_TEAM)
        local battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:towerChangeDefenseHeroesRequest(battleFormation)
    end   
    teamVO:setTeamDataWithBattleFormation(battleFormation)
end

function QTower:changeGloryArenaMyTeamInfo( isNeedDispatch )
    -- body
    if self:isTowerFightOpen() then
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.GLORY_DEFEND_TEAM)
        local team1ActorIds = teamVO:getTeamActorsByIndex(1)
        local team2ActorIds = teamVO:getTeamActorsByIndex(2)
        local team3ActorIds = teamVO:getTeamActorsByIndex(3)
        local team4ActorIds = teamVO:getTeamActorsByIndex(4)
        local team4GodarmIds = teamVO:getTeamGodarmByIndex(5)

        QPrintTable(team4GodarmIds)
        
        local skill2 = teamVO:getTeamSkillByIndex(2)
        local skill3 = teamVO:getTeamSkillByIndex(3)
        local skill4 = teamVO:getTeamSkillByIndex(4)

        if team1ActorIds ~= nil then
            self.gloryArenaMyInfo.heros = {}
            for _,actorId in pairs(team1ActorIds) do
                table.insert(self.gloryArenaMyInfo.heros, remote.herosUtil:getHeroByID(actorId))
            end
        end
        self.gloryArenaMyInfo.subheros = {}
        if team2ActorIds ~= nil then
            for _,actorId in pairs(team2ActorIds) do
                table.insert(self.gloryArenaMyInfo.subheros, remote.herosUtil:getHeroByID(actorId))
            end
        end
        self.gloryArenaMyInfo.sub2heros = {}
        if team3ActorIds ~= nil then
            for _,actorId in pairs(team3ActorIds) do
                table.insert(self.gloryArenaMyInfo.sub2heros, remote.herosUtil:getHeroByID(actorId))
            end
        end
        self.gloryArenaMyInfo.sub3heros = {}
        if team4ActorIds ~= nil then
            for _,actorId in pairs(team4ActorIds) do
                table.insert(self.gloryArenaMyInfo.sub3heros, remote.herosUtil:getHeroByID(actorId))
            end
        end
        if skill2 then
            self.gloryArenaMyInfo.activeSubActorId =  skill2[1] or 0
        else
            self.gloryArenaMyInfo.activeSubActorId = 0
        end

        if skill3 then
            self.gloryArenaMyInfo.activeSub2ActorId =  skill3[1] or 0
        else
            self.gloryArenaMyInfo.activeSub2ActorId = 0
        end
        
        if skill4 then
            self.gloryArenaMyInfo.activeSub3ActorId =  skill4[1] or 0
        else
            self.gloryArenaMyInfo.activeSub3ActorId = 0
        end
       
        self.gloryArenaMyInfo.force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.GLORY_DEFEND_TEAM)
        self:updateGloryArenaSelfInWorship()

        if remote.selectServerInfo then
            self.gloryArenaMyInfo.game_area_name = remote.selectServerInfo.name
        end
        if not self.gloryArenaMyInfo.game_area_name then
            self.gloryArenaMyInfo.game_area_name = ""
        end
        if isNeedDispatch then
            self:dispatchEvent({name = QTower.GLORY_ARENA_REFRESH, isNotRefreshAvatar = true})
        end
    end
end


--[[
    检查自己是不是在膜拜阵容里面
]]
function QTower:updateGloryArenaSelfInWorship()
    if self.gloryArenaWorshipFighter ~= nil and self.gloryArenaWorshipFighter.fighter ~= nil then
        for _,fighter in ipairs(self.gloryArenaWorshipFighter.fighter) do
            if fighter.userId == self.gloryArenaMyInfo.userId then
                fighter.heros = self.gloryArenaMyInfo.heros
                fighter.subheros = self.gloryArenaMyInfo.subheros
                fighter.sub2heros = self.gloryArenaMyInfo.sub2heros
                fighter.sub3heros = self.gloryArenaMyInfo.sub3heros
                fighter.force = self.gloryArenaMyInfo.force
            end
        end

        table.sort(self.gloryArenaWorshipFighter.fighter, function (a,b)
            if a.rank ~= b.rank then
                return a.rank < b.rank
            end
            return a.userId > b.userId
        end)
    end
end

function QTower:initGloryArenaVar(  )
    -- body
    -- print("initGloryArenaVar")
    self._isShowedYaoqing ,self._arenaRank , self._gloryTowerFloor = app:getUserOperateRecord():getGloryArenaYaoqingInfo()
    
    self.gloryArenaFightCount = 0  --剩余挑战次数
    self._oldGloryArenaMyInfo = {}
    self.gloryArenaMyInfo = {}
    self.gloryArenaCanFight = false
    self.canJoinGloryArena = (self._arenaRank ~= 0 or self._gloryTowerFloor ~= 0)
    self._gloryArenaFreeFightCount = QStaticDatabase:sharedDatabase():getConfiguration().COMPETION_FREE_FIGHT_COUNT.value
    self._gloryArenaCDTime = QStaticDatabase:sharedDatabase():getConfiguration().COMPETION_CD.value
    self._gloryArenaTodayWorshipInfo = {}   
    self.gloryArenaRivals = {}
    self.gloryArenaWorshipFighter = {}

    self.gloryArenaRefreshTimes = 0
    self.gloryArenaSeasonNo  = 0

    self._isInitGloryArena = true

    remote.stores:changeAwardId(SHOP_ID.gloryTowerShop,SHOP_ID.gloryTowerArenaAwardsShop)
end

--检测 是否需要显示邀请
function QTower:isNeedShowYaoqing(  )
    -- body
    if app.unlock:getUnlockGloryTower() and self._isInitGloryArena then
        if self:isTowerFightOpen() and not self._isShowedYaoqing then
            return true
        end
    end
    return false
end


--显示邀请对话框
function QTower:showYaoqing( )
    -- body
    if (self._arenaRank ~= 0 or self._gloryTowerFloor ~= 0) then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryarenaYaoqing", options = {rank = self._arenaRank,floor = self._gloryTowerFloor}})
        self._isShowedYaoqing = true
        app:getUserOperateRecord():setGloryArenaYaoqingInfo(self._arenaRank, self._gloryTowerFloor)
    else
        --服务器获取数据
        self:requestGloryArenaYaoqingInfo(function ( data )
            -- body
            local response = data.gloryCompetitionInviteResponse or {}
            self._arenaRank = response.arenaRank or 0
            self._gloryTowerFloor = response.towerFloor or 0
            self.canJoinGloryArena = (self._arenaRank ~= 0 or self._gloryTowerFloor ~= 0)
            if self.canJoinGloryArena then
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryarenaYaoqing",options = {rank = self._arenaRank,floor = self._gloryTowerFloor}})
            end
            app:getUserOperateRecord():setGloryArenaYaoqingInfo(self._arenaRank, self._gloryTowerFloor)
            self._isShowedYaoqing = true
        end)
    end
end


function QTower:setGloryArenaTodayWorshipInfo( worshipStr )
    -- body
    if worshipStr ~= nil then
        local pos = string.split(worshipStr, ";")
        for _,value in ipairs(pos) do
            if value ~= "" then
                self._gloryArenaTodayWorshipInfo[tonumber(value)+1] = true
            end
        end
    end
end

--判断每日积分奖励领取
function QTower:dailyGloryArenaScoreIsGet( rewardId )
    -- body
    if self.gloryArenaMyInfo.arenaRewardInfo then
        for _,id in ipairs(self.gloryArenaMyInfo.arenaRewardInfo) do
            if id == rewardId then
                return true
            end
        end
    end
    return false
end

--
function QTower:gloryArenaTodayWorshipByPos( pos )
    -- body
    return self._gloryArenaTodayWorshipInfo[pos]
end

function QTower:getGloryArenaScore(  )
    -- body
    local score = self.gloryArenaMyInfo.arenaRewardIntegral or 0
    return score
end
-- 红点检查机制

---积分奖励 红点
function QTower:checkGloryArenaScoreAwardRedtips( )
    -- body
    local configs = QStaticDatabase:sharedDatabase():getGloryArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    local curScore = self.gloryArenaMyInfo.arenaRewardIntegral or 0
    for k ,v in pairs(configs) do
        local isGet = self:dailyGloryArenaScoreIsGet(v.ID)
        if not isGet and curScore >= v.condition then
            return true
        end
    end
    return false

end

function QTower:checkGloryArenaRecordRedTips(  )
    -- body
    return false
end

-- 一键膜拜红点检查
function QTower:checkAutoWorshipRedTips()
    for i = 1, 10 do
        if not self._gloryArenaTodayWorshipInfo[i] then
            return true
        end
    end
	return false
end

-- 获取一键膜拜的列表
function QTower:_getAutoWorshipList()
    local worshipList = {}
    for index, value in ipairs(self.gloryArenaWorshipFighter.fighter) do
        if not self._gloryArenaTodayWorshipInfo[index] then
            table.insert(worshipList, { userId = value.userId , pos = index - 1 })
        end
    end

    return worshipList
end

-- 一键膜拜
function QTower:autoWorship()
    local oldTowerMoney = remote.user.towerMoney
    local targetList = self:_getAutoWorshipList()
    local yieldList = {}

    self:requestGloryAutoArenaWorship(targetList, function(data)
        local response = data.gloryCompetitionWorshipResponse
        local worshipBJCount = 0
        local worshipXYBJCount = 0

        if response then
            yieldList = response.yieldList or {}
            for _, yield in ipairs(yieldList) do
                if yield > 1 then
                    if yield > 2 then
                        worshipXYBJCount = worshipXYBJCount + 1
                    else
                        worshipBJCount = worshipBJCount + 1
                    end
                end
            end

            self:setGloryArenaTodayWorshipInfo(response.todayWorshipPos)

            local wallet = {}
            if data.wallet then
                wallet = data.wallet
            end
            remote.user:update({wallet = wallet})
            if data.items then remote.items:setItems(data.items) end

            self:dispatchEvent({ 
                name = QTower.EVENT_TOWER_AUTOWORSHIP, 
                targetList = targetList,
                worshipBJCount = worshipBJCount,
                worshipXYBJCount = worshipXYBJCount,
                addMoney = data.wallet.towerMoney - oldTowerMoney
            })
        end
    end)
end

--商店红点
function QTower:checkGloryArenaShopRedTips(  )
    -- body
    local shopInfo = remote.stores:getShopResousceByShopId(SHOP_ID.gloryTowerShop)
    if remote.stores:checkFuncShopRedTips(SHOP_ID.gloryTowerShop) or remote.stores:checkCanRefreshShop(SHOP_ID.gloryTowerShop) then
        return true
    end
    return false
end

function QTower:checkGloryArenaRedTips()
    --积分奖励没有领取
    if self:checkGloryArenaScoreAwardRedtips() then
        return true
    end

    if self:checkGloryArenaShopRedTips( ) then
         return true
    end

    if not remote.teamManager:checkTeamStormIsFull(remote.teamManager.GLORY_DEFEND_TEAM) then
        return true
    end

    return false
end


function QTower:handleYaoqingNotify( data )
    -- body
    self._arenaRank = data.arenaRank or 0
    self._gloryTowerFloor = data.towerFloor or 0
    self.canJoinGloryArena = (self._arenaRank ~= 0 or self._gloryTowerFloor ~= 0)
    self:dispatchEvent({name = QTower.EVENT_TOWER_GLORY_ARENA_YAOQING})
end




function QTower:getGloryArenaMoneyByRivals(pos, rank)
    if pos == nil then return end
    rank = math.min(rank, self.gloryArenaMyInfo.rank)
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
   
    if config["GLORY_COMPETION_NPC_"..pos] ~= nil then
      
        local rate = config["GLORY_COMPETION_NPC_"..pos].value
        local rankItemInfo = QStaticDatabase:sharedDatabase():getAreanRewardConfigByRank(rank, remote.user.level)
        local gloryArenaMoney = math.floor(rankItemInfo.competion_victory * rate)
        gloryArenaMoney = math.floor(gloryArenaMoney + 1 * ((math.floor((remote.user.level - 10) / 20)) * 5 + 30))
        return math.floor(gloryArenaMoney * 2)
    end
    return 0
end

function QTower:updateGloryArenaBuyCount(  )
    -- body
    self:gloryArenaRefresh({
            gloryCompetitionResponse = {
                mySelf = {
                    fightBuyCount = self.gloryArenaMyInfo.fightBuyCount + 1
                }
            }
        })
end





function QTower:setTopRankUpdate( result, rivalId )
    -- body
    self.gloryArenaFightWinResult = clone(result)
    self.gloryArenaRivalId = rivalId
end


function QTower:getTopRankUpdate()
    return self.gloryArenaFightWinResult, self.gloryArenaRivalId
end


function QTower:updateGloryArenaSelfInfo( data )
    --设置 膜拜信息
    if not self.canJoinGloryArena then
        self._oldGloryArenaMyInfo = clone(self.gloryArenaMyInfo)
        for key,value in pairs(data) do
            self.gloryArenaMyInfo[key] = value
        end

        if data.todayWorshipPos then
            self:setGloryArenaTodayWorshipInfo(data.todayWorshipPos)
        end
    else

        local selfInfoChange = false
      
        if data.todayWorshipPos then
            self:setGloryArenaTodayWorshipInfo(data.todayWorshipPos)
        end

        if data.arenaRewardInfo and #data.arenaRewardInfo ~= #(self.gloryArenaMyInfo.arenaRewardInfo or {}) then
            selfInfoChange = true 
        end

        if data.arenaRewardIntegral and data.arenaRewardIntegral ~= (self.gloryArenaMyInfo.arenaRewardIntegral or 0)  then
            selfInfoChange = true
        end
        
        -- local rank = data.rank or 0
        if data.topRank and data.topRank ~= (remote.user.gloryCompetitionTopRank or 999999) then
            remote.user:update({gloryCompetitionTopRank = data.topRank})
            selfInfoChange = true
        end

        self._oldGloryArenaMyInfo = clone(self.gloryArenaMyInfo)
        for key,value in pairs(data) do
            self.gloryArenaMyInfo[key] = value
        end

        self:changeGloryArenaMyTeamInfo()
     

        --更新斗魂场可攻打次数
        local gloryArenaCanFight = false
        local totalCount = self._gloryArenaFreeFightCount + self.gloryArenaMyInfo.fightBuyCount
        self.gloryArenaFightCount =  totalCount - self.gloryArenaMyInfo.fightCount

        if self.gloryArenaFightCount > 0 then
            local canFightTime = (self.gloryArenaMyInfo.lastFrozenTime or 0)/1000 + self._gloryArenaCDTime
            local passTime = canFightTime - q.serverTime()
           
            if passTime > 0  then
                gloryArenaCanFight = false
                app:getAlarmClock():createNewAlarmClock("gloryArenaCanFight", canFightTime, function (  )
                    -- body
                   self.gloryArenaCanFight = true
                   self:dispatchEvent({name = QTower.GLORY_ARENA_REDTIPS_CHANGE})
                end)
            else
                gloryArenaCanFight = true
            end
        end

        if gloryArenaCanFight ~= self.gloryArenaCanFight then
            selfInfoChange = true
            self.gloryArenaCanFight = gloryArenaCanFight
        end

        if selfInfoChange then

            self:dispatchEvent({name = QTower.GLORY_ARENA_REDTIPS_CHANGE})
        end

    end
end

function QTower:updateGloryArenaRivalsInfo( rivals )
    -- body
    self.oldGloryArenaRivals = self.gloryArenaRivals
    self.gloryArenaRivals = rivals
    table.insert(self.gloryArenaRivals, self.gloryArenaMyInfo)
    table.sort(self.gloryArenaRivals, function (a,b)
            if a.rank ~= b.rank then
                return a.rank < b.rank
            end
            return a.userId > b.userId
        end)

end


function QTower:gloryArenaRefresh(data, isNotNeedDispatch)
    local gloryData = data.gloryCompetitionResponse
    if gloryData == nil then
        return
    end
    -- 
    if not self.canJoinGloryArena then
        if gloryData.rivals ~= nil  then
            --前后端不一致 特殊处理
            app:getUserOperateRecord():setGloryArenaYaoqingInfo(0, 0, 0)
            self.canJoinGloryArena = true

        end
    end
   
    local isNotRefreshAvatar = true
    if gloryData.mySelf then
        self:updateGloryArenaSelfInfo(gloryData.mySelf)
      
    end
    --膜拜玩家信息
    if gloryData.worshipFighter ~= nil then
        self.gloryArenaWorshipFighter = gloryData.worshipFighter
        self:updateGloryArenaSelfInWorship()
        isNotRefreshAvatar = false
    end

    if gloryData.rivals ~= nil  then
        self:updateGloryArenaRivalsInfo(gloryData.rivals)
        isNotRefreshAvatar = false
    end

    if gloryData.refreshTimes ~= nil then
        self.gloryArenaRefreshTimes = gloryData.refreshTimes
    end

    if gloryData.seasonNo ~= nil then
        self.gloryArenaSeasonNo = gloryData.seasonNo
    end

    if not isNotNeedDispatch then
        self:dispatchEvent({name = QTower.GLORY_ARENA_REFRESH, isNotRefreshAvatar = isNotRefreshAvatar})
    end
end


function QTower:requestGloryArenaYaoqingInfo( success )
    -- body
    local request = {api = "GLORY_COMPETITION_GET_INVITE"}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_GET_INVITE", request, success, fail)
end

function QTower:requestGloryArenaInfo(isManualRefresh,callBack,isNotNeedDispatch)
    if isManualRefresh == nil then isManualRefresh = false end
    
    local gloryCompetitionRefreshRequest = {isManualRefresh = isManualRefresh}
    local request = {api = "GLORY_COMPETITION_REFRESH", gloryCompetitionRefreshRequest = gloryCompetitionRefreshRequest}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_REFRESH", request, function ( data )
        -- body
        self:gloryArenaRefresh(data)
        if callBack then
            callBack()
        end
    end, fail)
end


function QTower:requestGloryDefendTeam( success,fail, isNeedShowError )
    -- body
    local request = {api = "GET_CENTER_DEFENSE_ARMY"}

    app:getClient():requestPackageHandler("GET_CENTER_DEFENSE_ARMY", request, success, fail, nil, nil, isNeedShowError)
end


function QTower:requestGloryArenaBuyFightTimes(success )
    -- body
    local request = {api = "GLORY_COMPETITION_BUY_FIGHT_COUNT"}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_BUY_FIGHT_COUNT", request, success, fail)
end

function QTower:requestGloryArenaCleanFightCD(success )
    -- body
    local request = {api = "GLORY_COMPETITION_CLEAR_FROZEN_TIME"}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_CLEAR_FROZEN_TIME", request, success, fail)
end

function QTower:requestGloryArenaFightStartRequest(battleType, rivalUserId, battleFormation,success,fail)
    -- body
    -- local arenaFightStartRequest = {rivalUserId = rivalUserId}
    local gfStartRequest = {battleType = battleType,battleFormation = battleFormation}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail, true)
end

function QTower:requestGloryArenaFightEndRequest(rivalUserId, battleFormation, pos, fightResult, verifyDamages, battleKey, success, fail, status, isShow)
    local gloryCompetitionFightEndRequest = {rivalUserId = rivalUserId, pos = pos, fightResult = fightResult, damage = {damages = verifyDamages}}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)
   
    local gfEndRequest = {battleType = BattleTypeEnum.GLORY_COMPETITION, battleVerify = battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData, gloryCompetitionFightEndRequest = gloryCompetitionFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    
    local successCallback = function (response)
        remote.user:addPropNumForKey("todayTowerFightCount")
        remote.user:addPropNumForKey("c_towerFightCount")
        if response.gfEndResponse and response.gfEndResponse.isWin then
            remote.activity:updateLocalDataByType(552, 1)
            app.taskEvent:updateTaskEventProgress(app.taskEvent.GLORY_ARENA_TASK_EVENT, 1, false, true)
        end
                    
        self:towerResponse(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, fail, true)
end

function QTower:requestGloryArenaQuickFight( rivalUserId,pos, success, fail )
    local gloryCompetitionQuickFightRequest = {rivalUserId = rivalUserId, pos = pos}
    local gfQuickRequest = {battleType = BattleTypeEnum.GLORY_COMPETITION,gloryCompetitionQuickFightRequest = gloryCompetitionQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK",gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail, false)
end


--请求领取每日积分奖励
function QTower:requestGloryArenaIntegralReward(box_ids, success, fail)
    local request = {api = "GLORY_COMPETITION_INTEGRAL_REWARD", gloryCompetitionIntegralRewardRequest = {box_ids = box_ids}}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_INTEGRAL_REWARD", request, success, fail)
end

-- 一键膜拜
function QTower:requestGloryAutoArenaWorship( targetList, success, fail)
    -- body
    local gloryCompetitionWorshipRequest = {userId = targetList[1].userId, pos = targetList[1].pos, isSecretaryGet = true, posIds = targetList}
    local request = {api = "GLORY_COMPETITION_WORSHIP", gloryCompetitionWorshipRequest = gloryCompetitionWorshipRequest}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_WORSHIP", request, success, fail)
end

function QTower:requestGloryArenaWorship( userId, pos, success, fail)
    -- body
    local gloryCompetitionWorshipRequest = {userId = userId, pos = pos, isSecretaryGet = false}
    local request = {api = "GLORY_COMPETITION_WORSHIP", gloryCompetitionWorshipRequest = gloryCompetitionWorshipRequest}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_WORSHIP", request, success, fail)
end

function QTower:requestGloryArenaAgainstRecordRequest(success, fail, status)
    local request = {api = "GLORY_COMPETITION_QUERY_HISTORY"}
    app:getClient():requestPackageHandler("GLORY_COMPETITION_QUERY_HISTORY", request, success, fail)
end


function QTower:requestTowerGloryWallInfo( success,fail)
    -- body
    local towerGetGloryWallInfoRequest = {isAllEnv = true, seasonNO = nil}
    local request = {api = "TOWER_GET_GLORY_WALL_INFO", towerGetGloryWallInfoRequest = towerGetGloryWallInfoRequest}
    app:getClient():requestPackageHandler("TOWER_GET_GLORY_WALL_INFO", request, success, fail)
end

-- 荣耀争霸赛开始战斗检查
function QTower:towerFightStartCheckRequest(selfUserId, selfPos, rivalUserId, rivalPos, success,fail)
    local towerFightStartCheckRequest = {selfUserId = selfUserId, selfPos = selfPos, rivalUserId = rivalUserId, rivalPos = rivalPos}
    local gfStartCheckRequest = {battleType = BattleTypeEnum.GLORY_TOWER,towerFightStartCheckRequest = towerFightStartCheckRequest}   
    local request = {api = "GLOBAL_FIGHT_START_CHECK", gfStartCheckRequest = gfStartCheckRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START_CHECK", request, success, fail)
    
end

return QTower
