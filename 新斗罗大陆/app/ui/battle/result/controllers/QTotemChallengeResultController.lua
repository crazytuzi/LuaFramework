-- @Author: xurui
-- @Date:   2019-12-31 17:08:06
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-12 16:43:37
local QBaseResultController = import(".QBaseResultController")
local QTotemChallengeResultController = class("QTotemChallengeResultController", QBaseResultController)

local QBattleDialogWaveEnd = import("..dialogs.QBattleDialogWaveEnd")
local QReplayUtil = import(".....utils.QReplayUtil")

function QTotemChallengeResultController:ctor(options)
end

function QTotemChallengeResultController:requestResult(isWin)
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local heroScore, enemyScore = 0, 0
    self._scoreList = app.battle:getPVPMultipleWaveScoreList()
    for _, score in ipairs(self._scoreList or {}) do 
        if score then
            heroScore = heroScore + 1
        else
            enemyScore = enemyScore + 1
        end
    end
    self._heroScore = heroScore
    self._enemyScore = enemyScore

    if self._isWin then
	    remote.totemChallenge:requestTotemChallengeFightEndRequest(dungeonConfig.rivalPos, dungeonConfig.verifyKey, dungeonConfig.battleFormation, dungeonConfig.battleFormation2,
    	    function (data)
                remote.totemChallenge:setDungeonPassRivalPos(dungeonConfig.rivalPos)
    	        self:setResponse(data)
    	    end, function(data)
    	        self:requestFail(data)
    	    end)
    else
        remote.totemChallenge:requestTotemChallengeFightEndRequest(dungeonConfig.rivalPos, dungeonConfig.verifyKey, dungeonConfig.battleFormation, dungeonConfig.battleFormation2,
            function (data)
            end, function(data)
            end)        
        self:setResponse({})
    end
end

function QTotemChallengeResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local info = {}
    local rivalsInfo = dungeonConfig.rivalsInfo
    local myInfo = dungeonConfig.myInfo
    local reward = ""
    if self.response.totemChallengeFightEndResponse and self.response.totemChallengeFightEndResponse.fightEndReward then
        reward = reward..(self.response.totemChallengeFightEndResponse.fightEndReward.reward or "")
    end
    
    local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(dungeonConfig.myInfo, dungeonConfig.rivalsInfo, dungeonConfig.pvpMultipleTeams, self._isWin, false)
    local scoreList = self._scoreList
    info.isTotemChallenge = true
    info.team1Score = self._heroScore or 0
    info.team2Score = self._enemyScore or 0
    info.team1avatar = myInfo.avatar
    info.team2avatar = rivalsInfo.avatar
    info.team1Name = myInfo.name
    info.team2Name = rivalsInfo.name
    info.scoreList = scoreList
    info.replayInfo = replayInfo  
    info.reward = reward
    battleScene.curModalDialog = QBattleDialogWaveEnd.new({info = info, isWin = self._isWin, rankInfo = self.response, rivalId = dungeonConfig.rivalId}, self:getCallTbl())  
end

return QTotemChallengeResultController
