local QBaseResultController = import(".QBaseResultController")
local QSparFieldResultController = class("QSparFieldResultController", QBaseResultController)
local QBattleDialogSparField = import("..dialogs.QBattleDialogSparField")

function QSparFieldResultController:ctor(options)
end

function QSparFieldResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()

    local data = dungeonConfig.fightEndResponse
    local quickFightResult = dungeonConfig.quickFightResult
    local isWin, scoreList = quickFightResult.isWin, quickFightResult.scoreList
    local heroScore, enemyScore = 0, 0
    for _, score in ipairs(scoreList or {}) do
        if score then
            heroScore = heroScore + 1
        else
            enemyScore = enemyScore + 1
        end
    end
    app.battle:setPVPMultipleWaveScoreList(scoreList)
    app.battle:setPVPMultipleWaveScore(heroScore, enemyScore)
    app.battle:setPVPMultipleWaveLastWaveIsWin(not not scoreList[app.battle:getCurrentPVPWave()])
    
    self:setResponse(dungeonConfig.fightEndResponse)
end

function QSparFieldResultController:fightEndHandler()
    local battleScene = self:getScene()

    local dungeonConfig = battleScene:getDungeonConfig()
    local info = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    local myInfo = dungeonConfig.myInfo
    -- info.stormMoney = self.battleResult.wallet.stormMoney - dungeonConfig.myInfo.stormMoney
    -- info.arenaRewardIntegral = self.battleResult.stormResponse.mySelf.arenaRewardIntegral - self._dungeonConfig.myInfo.arenaRewardIntegral
    info.team1Score , info.team2Score = app.battle:getPVPMultipleWaveScore()
    info.team1avatar = myInfo.avatar
    info.team2avatar = rivalsInfo.avatar
    info.team1Name = myInfo.name
    info.team2Name = rivalsInfo.name
	
    battleScene.curModalDialog = QBattleDialogSparField.new({info = info, isWin = self._isWin, response = self.response, difficulty = dungeonConfig.difficulty}, self:getCallTbl())
end

return QSparFieldResultController