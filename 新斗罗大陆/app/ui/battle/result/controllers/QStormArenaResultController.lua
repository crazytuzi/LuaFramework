local QBaseResultController = import(".QBaseResultController")
local QStormArenaResultController = class("QStormArenaResultController", QBaseResultController)
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")
local QBattleDialogWaveEnd = import("..dialogs.QBattleDialogWaveEnd")
local QReplayUtil = import(".....utils.QReplayUtil")

function QStormArenaResultController:ctor(options)
end

function QStormArenaResultController:requestResult(isWin)
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    self:setResponse(dungeonConfig.fightEndResponse)

    local heroScore, enemyScore = 0, 0
    local scoreList = dungeonConfig.fightEndResponse.gfEndResponse.scoreList
    for _, score in ipairs(scoreList or {}) do 
        if score then
            heroScore = heroScore + 1
        else
            enemyScore = enemyScore + 1
        end
    end
    self._heroScore = heroScore
    self._enemyScore = enemyScore
end

function QStormArenaResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local info = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    local myInfo = dungeonConfig.myInfo

    local rankAward = 0
    if dungeonConfig.fightEndResponse.stormFightEndResponse then
        rankAward = string.split((dungeonConfig.fightEndResponse.stormFightEndResponse.topRankPrize or ""), "^")
        rankAward = tonumber(rankAward[2] or 0)
    end

    local userComeBackRatio = self.response.userComeBackRatio or 1
    local activityYield = 1
    if userComeBackRatio > 0 then
        activityYield = userComeBackRatio
    end
    
    local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(dungeonConfig.myInfo, dungeonConfig.rivalsInfo, dungeonConfig.pvpMultipleTeams, self._isWin, false)
    local scoreList = dungeonConfig.fightEndResponse.gfEndResponse.scoreList
    info.isStormArena = true
    info.maritimeMoney = (self.response.wallet.maritimeMoney or 0) - dungeonConfig.myInfo.maritimeMoney - (rankAward or 0)
    info.team1Score = self._heroScore or 0
    info.team2Score = self._enemyScore or 0
    info.team1avatar = myInfo.avatar
    info.team2avatar = rivalsInfo.avatar
    info.team1Name = myInfo.name
    info.team2Name = rivalsInfo.name
    info.scoreList = scoreList
    info.replayInfo = replayInfo
    info.activityYield = activityYield
    battleScene.curModalDialog = QBattleDialogWaveEnd.new({info = info, isWin = self._isWin, rankInfo = self.response, rivalId = dungeonConfig.rivalId}, self:getCallTbl())  
end

return QStormArenaResultController