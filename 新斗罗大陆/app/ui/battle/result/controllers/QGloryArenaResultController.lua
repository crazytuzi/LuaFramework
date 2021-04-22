local QBaseResultController = import(".QBaseResultController")
local QGloryArenaResultController = class("QGloryArenaResultController", QBaseResultController)
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QGloryArenaResultController:ctor(options)
end

function QGloryArenaResultController:requestResult(isWin)
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    -- 保留旧魂师
    self._teamName = dungeonConfig.teamName or remote.teamManager.GLORY_TEAM
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    self._heroOldInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end

    local oldUser = remote.user:clone()
    local data = {result = dungeonConfig.fightEndResponse, oldUser = oldUser}
    self:setResponse(data)
end

function QGloryArenaResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local awards = {}
    --节假日活动
    if self.response.result and type(self.response.result.extraExpItem) == "table" then
        for _, value in pairs(self.response.result.extraExpItem) do
            table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
        end
    end

    table.insert(awards, {id = nil, type = ITEM_TYPE.TOWER_MONEY, count = self.response.result.wallet.towerMoney - dungeonConfig.myInfo.towerMoney})

    local exp = 0
    local money = 0
    local score = self.response.result.gloryCompetitionResponse.mySelf.arenaRewardIntegral - dungeonConfig.myInfo.arenaRewardIntegral
    local yield = self.response.result.gloryCompetitionFightEndResponse.yield or 1
    local userComeBackRatio = self.response.result.userComeBackRatio or 1
    local activityYield = remote.activity:getActivityMultipleYield(611)
    if userComeBackRatio > 0 then
        activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
    end
    
    battleScene.curModalDialog = QArenaDialogWin.new({
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
        isWin = self._isWin
        },self:getCallTbl()) 
end

return QGloryArenaResultController