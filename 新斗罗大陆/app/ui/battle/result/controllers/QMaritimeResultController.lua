-- @Author: xurui
-- @Date:   2017-04-20 17:59:19
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-20 11:50:09
local QBaseResultController = import(".QBaseResultController")
local QMaritimeResultController = class("QMaritimeResultController", QBaseResultController)

local QBattleDialogWaveEnd= import("..dialogs.QBattleDialogWaveEnd")

function QMaritimeResultController:ctor(options)
end

function QMaritimeResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()
    local quickFightResult = dungeonConfig.quickFightResult
    if app.battle:isInQuick() then

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
end

function QMaritimeResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local userComeBackRatio = self.response.userComeBackRatio or 1
    local activityYield = 1
    if userComeBackRatio > 0 then
        activityYield = userComeBackRatio
    end

 	local info = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    local myInfo = dungeonConfig.myInfo
    info.team1Score , info.team2Score = app.battle:getPVPMultipleWaveScore()
    info.team1avatar = myInfo.avatar
    info.team2avatar = rivalsInfo.avatar
    info.team1Name = myInfo.name
    info.team2Name = rivalsInfo.name
    info.activityYield = activityYield
    info.isMaritime = true
    
    local isWin = false
    if self._isWin == 1 or self._isWin == true then
        isWin = true
    end 

    app.taskEvent:updateTaskEventProgress(app.taskEvent.MARITIME_TASK_EVENT, 1, false, isWin)

    battleScene.curModalDialog = QBattleDialogWaveEnd.new({info = info, isWin = isWin, rankInfo = self.response, 
        rivalId = dungeonConfig.rivalId}, self:getCallTbl())
end

return QMaritimeResultController