local QBaseResultController = import(".QBaseResultController")
local QGloryResultController = class("QGloryResultController", QBaseResultController)
local QFriendDialogWin = import("..dialogs.QFriendDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")
local QReplayUtil = import(".....utils.QReplayUtil")
local QGloryTowerDialogWin = import("..dialogs.QGloryTowerDialogWin")
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")

function QGloryResultController:ctor(options)
end

function QGloryResultController:requestResult(isWin)   
    self._isWin = isWin 
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local EnemyDead = 50
    local selfDead = 50
    if isWin == true then
        selfDead = nil
    else
        EnemyDead = nil
    end
    local fighterInfo = {}
    local selfInfo = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    for _,value in pairs(rivalsInfo.heros) do
        local result = {actor_id = value.actorId, showed_at = 10, died_at = EnemyDead}
        table.insert(fighterInfo, result)
    end
    for _,actorId in pairs(dungeonConfig.selfHeros) do
        local result = {actor_id = actorId, showed_at = 10, died_at = selfDead}
        table.insert(selfInfo, result)
    end

     -- 保留旧武将
    self._teamName = dungeonConfig.teamName or remote.teamManager.GLORY_TEAM
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    self._heroOldInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end


    local myInfo = {name = dungeonConfig.team1Name, avatar = dungeonConfig.team1Icon, level = remote.user.level}
    myInfo.heros = self:_constructGloryAttackHero()

    local replayInfo = QReplayUtil:generateReplayInfo(myInfo, dungeonConfig.rivalsInfo, isWin and 1 or 2, self._teamName)

    -- towerFightReportId
    remote.tower:setOldTowerFloor(remote.tower:getTowerInfo().floor)
    if isWin == true then
        remote.tower:saveOldFighters()
    end
    local battleFormation = dungeonConfig.battleFormation
    local oldUser = remote.user:clone()
    remote.tower:towerFightEndRequest(dungeonConfig.rivalsInfo.userId, {selfHerosStatus = selfInfo, rivalHerosStatus = fighterInfo}, app.battle:getBattleLog().verifyDamageInfos, dungeonConfig.verifyKey, false, battleFormation, function (data)
        -- QReplayUtil:uploadReplay(data.towerFightReportId, replayInfo, function ()
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function ()
            data.oldUser = oldUser
            self:setResponse(data)
        end, function ()
            data.oldUser = oldUser
            self:setResponse(data)
        end, REPORT_TYPE.GLORY_TOWER)   
    end, function(data)
        self:requestFail(data)
    end, false)
end

function QGloryResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local score = (remote.tower:getTowerInfo().score or 0) - (dungeonConfig.score or 0)
    score = score < 0 and 0 or score

    local awards = {}
    --节假日活动
    if self.response and type(self.response.extraExpItem) == "table" then
        for _, value in pairs(self.response.extraExpItem) do
            table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
        end
    end

    if remote.user.towerMoney - dungeonConfig.towerMoney > 0 then
        table.insert(awards, {type = ITEM_TYPE.TOWER_MONEY, count = remote.user.towerMoney - dungeonConfig.towerMoney})
    end
    

    local exp = 0
    local money = 0
    local yield = 1
    local userComeBackRatio = self.response.userComeBackRatio or 1
    local activityYield = remote.activity:getActivityMultipleYield(611)
    if userComeBackRatio > 0 then
        activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
    end
    
    battleScene.curModalDialog = QGloryTowerDialogWin.new({
            heroOldInfo = self._heroOldInfo,
            oldTeamLevel = self.response.oldUser.level,
            teamName = self._teamName,
            exp = exp,
            timeType = "2",
            money = money, 
            score = score,
            awards = awards, -- 奖励物品
            yield = yield, -- 战斗奖励翻倍
            activityYield = activityYield, -- 活动双倍
            isWin = self._isWin,
            towerInfo = self.response,
            extraAwards = self.response.towerInfo.awards,
        },self:getCallTbl()) 
end

function QGloryResultController:_constructGloryAttackHero()
    local attackHeroInfo = {}
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    for k, v in ipairs(teamHero) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

return QGloryResultController