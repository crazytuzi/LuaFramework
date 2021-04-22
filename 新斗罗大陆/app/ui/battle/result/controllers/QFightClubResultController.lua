local QBaseResultController = import(".QBaseResultController")
local QFightClubResultController = class("QFightClubResultController", QBaseResultController)
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")
local QBattleDialogFightClubWin = import("..dialogs.QBattleDialogFightClubWin")

function QFightClubResultController:ctor(options)
end

function QFightClubResultController:requestResult(isWin)
    print("<<<QFightClubResultController>>>")
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    self:setResponse(dungeonConfig.fightEndResponse)

    local heroScore, enemyScore = 0, 0
    local scoreList = dungeonConfig.fightEndResponse.fightClubResponse.scoreList or {}
    for _, score in ipairs(scoreList) do 
        if score then
            heroScore = heroScore + 1
        else
            enemyScore = enemyScore + 1
        end
    end
    app.battle:setPVPMultipleWaveScoreList(scoreList)
    app.battle:setPVPMultipleWaveScore(heroScore, enemyScore)
    app.battle:setPVPMultipleWaveLastWaveIsWin(scoreList[app.battle:getCurrentPVPWave()])
end

function QFightClubResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local isWin = self.response.fightClubResponse.success
    local info = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    local myInfo = dungeonConfig.myInfo
    info.team1Score , info.team2Score = app.battle:getPVPMultipleWaveScore()
    info.team1avatar = myInfo.avatar
    info.team2avatar = rivalsInfo.avatar
    info.team1Name = myInfo.name
    info.team2Name = rivalsInfo.name
    
    local tbl = {}
    if isWin then
        tbl = self:getCallTbl()
    else
        tbl = self:getLoseCallTbl()
    end
    battleScene.curModalDialog = QBattleDialogFightClubWin.new({
        info = info, 
        isWin = isWin, 
        rivaleName = rivalsInfo.name,
        rankInfo = self.response, 
        rivalId = dungeonConfig.rivalId
        }, tbl)  

    if app.battle:hasWinOrLose() then
        local file_name = "fight_club_result.txt"
        appendToFile(file_name, string.format("[%s]前端判定: %s, 后端判定: %s\n", q.date('%m-%d-%H:%M:%S'), 
            app.battle._onWin_Time and "胜利" or "失败", isWin and "胜利" or "失败"))
        if app.battle._onWin_Time ~= isWin then
            appendToFile(file_name, "检测到复盘不一致，以下是战报内容:\n")
            appendToFile(file_name, crypto.encodeBase64(readFromBinaryFile("last.reppb")))
            appendToFile(file_name, "\n")
        end
    end
end

return QFightClubResultController