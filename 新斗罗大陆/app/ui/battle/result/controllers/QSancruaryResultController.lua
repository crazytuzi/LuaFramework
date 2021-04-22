local QBaseResultController = import(".QBaseResultController")
local QSancruaryResultController = class("QSancruaryResultController", QBaseResultController)
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")
local QBattleDialogWaveEnd = import("..dialogs.QBattleDialogWaveEnd")
local QReplayUtil = import(".....utils.QReplayUtil")

function QSancruaryResultController:ctor(options)
end

function QSancruaryResultController:requestResult(isWin)
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

function QSancruaryResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local info = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    local myInfo = dungeonConfig.myInfo

    local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(dungeonConfig.myInfo, dungeonConfig.rivalsInfo, dungeonConfig.pvpMultipleTeams, self._isWin, false)
    local gfEndResponse = dungeonConfig.fightEndResponse.gfEndResponse
    local scoreList = gfEndResponse.scoreList
    info.isSanctuary = true
    info.addScore = gfEndResponse.sanctuaryWarAuditionFightEndResponse.addScore or 0
    info.reward = gfEndResponse.sanctuaryWarAuditionFightEndResponse.reward or ""
    info.team1Score = self._heroScore or 0
    info.team2Score = self._enemyScore or 0
    info.team1avatar = dungeonConfig.team1Icon
    info.team2avatar = dungeonConfig.team2Icon
    info.team1Name = dungeonConfig.team1Name
    info.team2Name = dungeonConfig.team2Name
    info.scoreList = scoreList
    info.replayInfo = replayInfo
    battleScene.curModalDialog = QBattleDialogWaveEnd.new({info = info, isWin = self._isWin, rankInfo = self.response, rivalId = dungeonConfig.rivalId}, self:getCallTbl())  
end

return QSancruaryResultController