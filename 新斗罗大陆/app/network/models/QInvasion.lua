--
-- Author: qinyuanji
-- Date: 2015-10-23 11:07:01
--
local QBaseModel = import("...models.QBaseModel")
local QInvasion = class("QInvasion",QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QNavigationController = import("...controllers.QNavigationController")

QInvasion.BOSSAPPLICABLE = "QINVASION_BOSSAPPLICABLE"
QInvasion.BOSSNOTAPPLICABLE = "QINVASION_BOSSNOTAPPLICABLE"
QInvasion.REWARDACCEPTED = "QInvasion_REWARDACCEPTED"
QInvasion.TOKEN_ID = 201

QInvasion.EVENT_UPDATE = "EVENT_UPDATE"
QInvasion.EVNET_SHOW_KILL_AWARD = "EVNET_SHOW_KILL_AWARD"

QInvasion.CHEST = {}
QInvasion.KEY = {}

function QInvasion:ctor()
    QInvasion.super.ctor(self)
    self.selfInvasion = {}

    self._killAwards = {}
    self._killAwardTip = false
    self._afterBattle = false
end

function QInvasion:didappear()
    QInvasion.super.didappear(self)
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    local chests = config.INTRUSION_KEY.value
    chests = string.split(chests, ";")
    for _,value in ipairs(chests) do
        local value2 = string.split(value, ":")
        table.insert(QInvasion.CHEST, tonumber(value2[1]))
        table.insert(QInvasion.KEY, tonumber(value2[2]))
    end
end

function QInvasion:loginEnd()
    self:getInvasionRequest()
end

--[[
    设置推送的要塞信息
]]
function QInvasion:pushInvasion(sendIntrusionChangeResponse)
    if self._isRobot then return end
    if self.invasions == nil then return end
    for _, invasion in ipairs(self.invasions) do
        if invasion.userId == sendIntrusionChangeResponse.userId and invasion.bossId == sendIntrusionChangeResponse.bossId then
            invasion.isFighting = (sendIntrusionChangeResponse.messageType == "FIGHT_START")
            if sendIntrusionChangeResponse.bossHp ~= nil then
                invasion.bossHp = sendIntrusionChangeResponse.bossHp
            end
            invasion.hurtHp = sendIntrusionChangeResponse.hurtHp
            invasion.fightingNickname = sendIntrusionChangeResponse.fightingNickname
            invasion.fightingUserId = sendIntrusionChangeResponse.fightingUserId
        end
    end
    
    self:dispatchEvent({name = QInvasion.EVENT_UPDATE})
end

function QInvasion:setInvasions(invasions)
    self.invasions = invasions
end

function QInvasion:getInvasions()
    self:_checkInvasion()
    self.invasions = self.invasions or {}
    table.sort(self.invasions, function (a,b)
        if a.userId == remote.user.userId then
            return true
        end
        if b.userId == remote.user.userId then
            return false
        end
        return a.bossRefreshAt > b.bossRefreshAt
    end)
    return self.invasions
end

function QInvasion:getInvasionByUserId(userId)
    if self.invasions == nil then return nil end
    for _,invasion in ipairs(self.invasions) do
        if invasion.userId == userId then
            return invasion
        end
    end
    return nil
end

function QInvasion:setSelfInvasion(invasions)
    self.selfOldInvasion = clone(self.selfInvasion)
    for k, v in pairs(invasions) do
        self.selfInvasion[k] = v
    end
end

function QInvasion:getSelfInvasion()
    return self.selfInvasion or {}
end

function QInvasion:getSelfOldInvasion()
    return self.selfOldInvasion or {}
end

--战斗之后
function QInvasion:setAfterBattle(b)
    self._afterBattle = b
end

function QInvasion:getAfterBattle()
    return self._afterBattle
end

--获得消耗的体力   
function QInvasion:getEnergyConsume()
    return self._energyConsume or 0
end

--获得消耗的体力   
function QInvasion:getBossSummonCount()
    return self._bossSummonCount or 0
end

--战斗掉落物品
function QInvasion:setBattleItems(items)
    self._items = items
end

function QInvasion:getBattleItems()
    local items = clone(self._items)
    self._items = nil
    return items
end

--设置需要刷新
function QInvasion:setInvasionUpdate(b)
    self._isUpdate = b
end

function QInvasion:getInvasionUpdate(b)
    return self._isUpdate
end

--要塞击杀奖励
function QInvasion:setInvasionKillAwards(awards)
    self._killAwards = awards
end

function QInvasion:getInvasionKillAwards()
    return self._killAwards or {}
end

function QInvasion:deleteKillAward(awardId)
    if awardId == nil then 
        self._killAwards = {}
        return 
    end

    for k, value in pairs(self._killAwards or {}) do
        if value.awardId == awardId then
            table.remove(self._killAwards, k)
            break
        end
    end
end

--检查是否逃跑了
function QInvasion:_checkInvasion()
    local delInvasions = {}
    if self.invasions == nil then return end
    for _,invasion in ipairs(self.invasions) do
        local cd = QStaticDatabase:sharedDatabase():getIntrusionEscapeTime(invasion.teamLevel) * 60
        local timeDiff = math.floor((q.serverTime()*1000 - invasion.bossRefreshAt)/1000)
        if timeDiff >= cd then 
            table.insert(delInvasions, invasion)
        end
    end
    for _,invasion in ipairs(delInvasions) do
        for index,invasion2 in ipairs(self.invasions) do
            if invasion == invasion2 then
                table.remove(self.invasions, index)
                break
            end
        end
    end
end

--检查是否有奖励未领取
function QInvasion:invasionRewardApplicable()
    local invasion = remote.invasion:getSelfInvasion()
    local dailyRewards = QStaticDatabase:sharedDatabase():getIntrusionReward(1)
    local rewards = string.split(invasion.rewardInfo, "#")
    local conditionLevel = remote.user.dailyTeamLevel == 0 and 1 or remote.user.dailyTeamLevel

    -- sort out drawn and undrawn rewards
    local undrawnRewards = {}
    for k, v in pairs(dailyRewards) do
        local drawn = false
        for k1, v1 in ipairs(rewards) do
            if tonumber(v1) == tonumber(v.id) then
                drawn = true
                break
            end
        end

        if not drawn and conditionLevel >= v.lowest_levels and conditionLevel <= v.maximum_levels then
            table.insert(undrawnRewards, v)
        end
    end    

    for k, v in ipairs(undrawnRewards) do
        if v.meritorious_service <= (invasion.allHurt or 0) then
            return true
        end
    end

    return false
end

function QInvasion:setKillAwardTipState(state)
     self._killAwardTip = state
     if state then
        self:dispatchEvent({name = QInvasion.EVNET_SHOW_KILL_AWARD})
     end
end

-- 检查是否有要塞击杀奖励
function QInvasion:checkKillAwards()
    local awards = self:getInvasionKillAwards()

    if (awards and next(awards) ~= nil) or self._killAwardTip then 
        return true
    end
    return false
end

-- 检查是否有要塞击杀奖励
function QInvasion:checkCanGenerateBoss()

    if not app.unlock:checkLock("UNLOCK_MONSTER_INVOKE", false) then
        return false
    end

    local bossSummonCount = self:getBossSummonCount()
    local totalCount  = db:getConfigurationValue("intrusion_boss_summon_max_count") or 1 
    if bossSummonCount >=totalCount then
        return false
    end

    local energyConsume = self:getEnergyConsume()
    local cost  = db:getConfigurationValue("intrusion_energy_consume") or 1 
    if energyConsume > cost then
        return true
    end
    return false
end


function QInvasion:specialMoment(type)
    local hour = q.date("%H", q.serverTime())
    if type == 1 then
        if tonumber(hour) == 11 or tonumber(hour) == 12 or tonumber(hour) == 13 then
            return true
        end
    else
        local value = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_HURT_DOUBLE"].value
        local minHours = string.split(value,"#")
        return tonumber(hour) >= tonumber(minHours[1]) and tonumber(hour) < tonumber(minHours[2])
    end

    return false
end

function QInvasion:currentTokenNumber()
    local interval = (QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_REPLY_TIME"].value or 60) * 60
    local token = remote.user.intrusion_token or 0
    local maxToken = 10
    if token < maxToken then
        local timeDiff = (q.serverTime() * 1000 - remote.user.intrusion_token_refresh_at)/1000
        local tokenGrown = math.floor(timeDiff/interval)
        return (token + tokenGrown > maxToken) and maxToken or (token + tokenGrown)
    end

    return token
end

function QInvasion:getBossColorByType(bossType)
    local bossColor = BREAKTHROUGH_COLOR_LIGHT.green
    local bossBreakthoughLevel = 0

    if bossType == 2 then
        bossColor = BREAKTHROUGH_COLOR_LIGHT.blue
        bossBreakthoughLevel = 2
    elseif bossType == 3 then
        bossColor = BREAKTHROUGH_COLOR_LIGHT.purple
        bossBreakthoughLevel = 7
    elseif bossType == 4 then
        bossColor = BREAKTHROUGH_COLOR_LIGHT.orange
        bossBreakthoughLevel = 12
    elseif bossType == 5 then
        bossColor = BREAKTHROUGH_COLOR_LIGHT.red
        bossBreakthoughLevel = 17
    elseif bossType == 6 then
        bossColor = BREAKTHROUGH_COLOR_LIGHT.yellow
        bossBreakthoughLevel = 22
    end

    return bossColor, bossBreakthoughLevel
end

-------------------------------request Handler------------------------------
-- 
function QInvasion:invasionResponse(response, success, fail, succeeded, isRobot)
    if response.error == "NO_ERROR" then
        local bossState = self.bossId
        local bossHp = self.bossHp
        local invasions = {}
        if response.userIntrusionResponse then
            if response.api == "GET_INTRUSION"  or response.api == "INTRUSION_GENERATE_BOSS" then
                self._energyConsume = 0
                self._energyConsume = response.userIntrusionResponse.energy_consume
                self._bossSummonCount = response.userIntrusionResponse.boss_summon_count
            end
            response.userIntrusionResponse.userId = remote.user.userId
            response.userIntrusionResponse.teamLevel = remote.user.level
            self:setSelfInvasion(response.userIntrusionResponse)
            if response.userIntrusionResponse.bossId ~= nil and response.userIntrusionResponse.bossId ~= 0 then
                table.insert(invasions, clone(self.selfInvasion))
            end
        end
        if response.friendIntrusionBoss then
            for _,friendIntrusion in ipairs(response.friendIntrusionBoss) do
                table.insert(invasions, friendIntrusion)
            end
        end
      
        -- if response.api == "GET_INTRUSION" or response.api == "INTRUSION_FIGHT_END" then
        if response.api == "GET_INTRUSION" or response.api == "GLOBAL_FIGHT_END" or response.api == "INTRUSION_REFRESH_BOSS"  or response.api == "INTRUSION_GENERATE_BOSS" then
            print("response.api = "..response.api)
            self:setInvasions(invasions)
        end
        -- if response.intrusionFightEndResponse then
        --     -- self:setSelfInvasion(response.intrusionFightEndResponse)
        --     for k, v in pairs(response.intrusionFightEndResponse) do
        --         self.selfInvasion[k] = v
        --     end
        -- end
        if response.intrusionAwardList then
            self:setInvasionKillAwards(response.intrusionAwardList)
        end
        
        if not isRobot then
            self:dispatchEvent({name = QInvasion.EVENT_UPDATE})
        else
            self._isRobot = false
        end

        -- Check if invasion boss becomes applicable or unapplicable
        -- Check bossId first and bossHp, server doesn't guarantee to return bossId = 0 when boss is defeated
        if succeeded then
            local checked = false
            if bossState and bossState ~= 0 then
                if (not self.selfInvasion.bossId or self.selfInvasion.bossId == 0) then
                    print("dispatchEvent({name = QInvasion.BOSSNOTAPPLICABLE})")
                    self:dispatchEvent({name = QInvasion.BOSSNOTAPPLICABLE})
                    checked = true
                end
            else
                if self.selfInvasion.bossId and self.selfInvasion.bossId ~= 0 then
                    print("dispatchEvent({name = QInvasion.BOSSAPPLICABLE})")
                    self:dispatchEvent({name = QInvasion.BOSSAPPLICABLE})
                    checked = true
                end
            end
            if not checked then
                if bossHp and bossHp > 0 then
                    if self.selfInvasion.bossHp == 0 then
                        print("dispatchEvent({name = QInvasion.BOSSNOTAPPLICABLE})")
                        self:dispatchEvent({name = QInvasion.BOSSNOTAPPLICABLE})
                    end
                else
                    if self.selfInvasion.bossHp > 0 then
                        print("dispatchEvent({name = QInvasion.BOSSAPPLICABLE})")
                        self:dispatchEvent({name = QInvasion.BOSSAPPLICABLE})
                    end
                end
            end
        end

        if success then 
            success(response) 
            return
        end
    else
        if fail then 
            fail(response)
        else
            print("Pop to main page")
            --app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
        end
    end
end

-- 获取入侵信息
function QInvasion:getInvasionRequest(success, fail, status)
    if app.unlock:getUnlockInvasion() == true then
        local request = {api = "GET_INTRUSION"}
        app:getClient():requestPackageHandler("GET_INTRUSION", request, function (response)
            self:invasionResponse(response, success, nil, true)
        end, function (response)
            self:invasionResponse(response, nil, fail)
        end)
    end
end

-- 挑战入侵BOSS开始
function QInvasion:invasionStartRequest(type, userId, battleFormation, isQuick, success, fail, status)
    local intrusionFightStartRequest = {type = type, userId = userId}
    local gfStartRequest = {battleType = BattleTypeEnum.INTRUSION, battleFormation = battleFormation, intrusionFightStartRequest = intrusionFightStartRequest, isQuick = isQuick}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

-- 挑战入侵BOSS结束
function QInvasion:invasionEndRequest(bossHp, userId, battleKey, isRobot, success, fail, isHandlerError)
    self._isRobot = isRobot
    local intrusionFightEndRequest = {bossHp = bossHp, userId = userId}
    intrusionFightEndRequest.battleVerify = q.battleVerifyHandler(battleKey)

    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    
    local gfEndRequest = {battleType = BattleTypeEnum.INTRUSION, battleVerify = intrusionFightEndRequest.battleVerify, isQuick = isRobot, isWin = nil,
                                fightReportData = fightReportData, intrusionFightEndRequest = intrusionFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:invasionResponse(response, success, nil, true, isRobot)
        local boosData = self:getInvasionByUserId(userId)
        local bossHp = boosData and boosData.bossHp or 0
        if bossHp == 0 then
            remote.activity:updateLocalDataByType(544, 1)
        end
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end, nil, nil, isHandlerError)
end

-- 扫荡入侵BOSS结束
function QInvasion:invasionFastFightEndRequest(targetUserId, autoConsumeToken, isAllOut, autoShare, battleKey, success, fail, isHandlerError)
    self._isRobot = true
    local intrusionQuickFightRequest = {targetUserId = targetUserId, autoConsumeToken = autoConsumeToken, isAllOut = isAllOut, autoShare = autoShare}
    local battleVerify = q.battleVerifyHandler(battleKey)

    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)

    local selfInvasion = self:getSelfInvasion()
    local isShared = selfInvasion.share
    
    local gfEndRequest = {battleType = BattleTypeEnum.INTRUSION, battleVerify = battleVerify, isQuick = false, isWin = nil,
                                fightReportData = fightReportData, intrusionQuickFightRequest = intrusionQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        if response.intrusionFightEndAward then
            self:setBattleItems(response.intrusionFightEndAward)
        end

        local fightCount = response.gfEndResponse.intrusionQuickFightResponse.fightCount or 0
        app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_EVENT, fightCount, false, true)

        self:invasionResponse(response, success, nil, true, true)
        local boosData = self:getInvasionByUserId(targetUserId)
        local bossHp = boosData and boosData.bossHp or 0

        if bossHp == 0 then
            remote.activity:updateLocalDataByType(544, 1)
            -- 假分享
            if isShared == false and autoShare then
                remote.user:addPropNumForKey("todayIntrusionShareCount")
                app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_SHARE_BOSS_EVENT, 1)
            end
        else
            -- 真分享，攻打一次不算，两次以上做假分享
            if isShared == false and autoShare then
                self:shareIntrusionBossRequest()
            end
        end
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end, nil, nil, isHandlerError)
end

-- 购买入侵令牌
function QInvasion:buyInvasionTokenRequest(success, fail, status)
    local request = {api = "BUY_INTRUSION_TOKEN"}
    app:getClient():requestPackageHandler("BUY_INTRUSION_TOKEN", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

-- 使用征讨令
function QInvasion:useInvasionTokenRequest(count, success, fail, status)
    local itemOpenRequest = {itemId = QInvasion.TOKEN_ID, count = count or 1}
    local request = {api = "ITEM_OPEN", itemOpenRequest = itemOpenRequest}
    app:getClient():requestPackageHandler("ITEM_OPEN", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

-- 领取功勋奖励
function QInvasion:getInvasionRewardRequest(rewardIds, isSecretary,success, fail, status)
    local luckyDrawIntrusionRequest = {rewardIds = rewardIds,isSecretary = isSecretary}
    local request = {api = "LUCKY_DRAW_INTRUSION", luckyDrawIntrusionRequest = luckyDrawIntrusionRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_INTRUSION", request, function (response)
        self:invasionResponse(response, success, nil, true)
        self:dispatchEvent({name = QInvasion.REWARDACCEPTED})
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

--分享给好友
function QInvasion:shareIntrusionBossRequest(success, fail, status)
    local request = {api = "SHARE_INTRUSION_BOSS"}
    app:getClient():requestPackageHandler("SHARE_INTRUSION_BOSS", request, function (response)
        self.selfInvasion.share = true
        self:invasionResponse(response, success, nil, true)
        remote.user:addPropNumForKey("todayIntrusionShareCount")
        app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_SHARE_BOSS_EVENT, 1)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

--要塞开宝箱 
function QInvasion:intrusionOpenBossBoxRequest(boxType, boxCount, bosList,success, fail, status)
    local intrusionOpenBossBoxRequest = {boxType = boxType, boxCount = boxCount,bosList = bosList}
    local request = {api = "INTRUSION_OPEN_BOSS_BOX", intrusionOpenBossBoxRequest = intrusionOpenBossBoxRequest}
    app:getClient():requestPackageHandler("INTRUSION_OPEN_BOSS_BOX", request, function (response)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_REWARD_COUNT_EVENT, tonumber(boxCount))
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

--拉取要塞击杀奖励 
function QInvasion:intrusionKillAwardRequest(success, fail, status)
    local request = {api = "INTRUSION_GET_AWARD_LIST"}
    app:getClient():requestPackageHandler("INTRUSION_GET_AWARD_LIST", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

--领取要塞击杀奖励 
function QInvasion:getIntrusionKillAwardRequest(awardId,isSecretary, success, fail, status)
    local intrusionTakeAwardRequest = {awardId = awardId,isSecretary = isSecretary}
    local request = {api = "INTRUSION_TAKE_AWARD", intrusionTakeAwardRequest = intrusionTakeAwardRequest}
    app:getClient():requestPackageHandler("INTRUSION_TAKE_AWARD", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

--boss刷新
function QInvasion:intrusionBossRefreshRequest(success, fail, status)
    local request = {api = "INTRUSION_REFRESH_BOSS"}
    app:getClient():requestPackageHandler("INTRUSION_REFRESH_BOSS", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end

function QInvasion:intrusionGenerateBossRequest(success, fail, status)
    local request = {api = "INTRUSION_GENERATE_BOSS"}
    app:getClient():requestPackageHandler("INTRUSION_GENERATE_BOSS", request, function (response)
        self:invasionResponse(response, success, nil, true)
    end, function (response)
        self:invasionResponse(response, nil, fail)
    end)
end




return QInvasion
