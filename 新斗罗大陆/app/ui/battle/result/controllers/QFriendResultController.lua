local QBaseResultController = import(".QBaseResultController")
local QFriendResultController = class("QFriendResultController", QBaseResultController)
local QFriendDialogWin = import("..dialogs.QFriendDialogWin")
local QReplayUtil = import(".....utils.QReplayUtil") 
local QBattleDialogWaveEnd = import("..dialogs.QBattleDialogWaveEnd")

function QFriendResultController:ctor(options)
end

function QFriendResultController:requestResult(isWin)   
	self._isWin = isWin 
	
	local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()
    if dungeonConfig.isPvpMultipleNew ~= true then
    	-- 保留旧魂师
        self._teamName = dungeonConfig.teamName or remote.teamManager.INSTANCE_TEAM
        local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
        local heroTotalCount = #teamHero
        
        self._heroOldInfo = {}
        for i = 1, heroTotalCount, 1 do
            self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
        end
        local oldUser = remote.user:clone()
        self:setResponse({oldUser = oldUser})
    else
        self:setResponse({})
    end
end

function QFriendResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    if dungeonConfig.isPvpMultipleNew ~= true then
        if self._isWin then
    	    local exp = 0
    	    battleScene.curModalDialog = QFriendDialogWin.new({
    	    	heroOldInfo = self._heroOldInfo,
                oldTeamLevel = self.response.oldUser.level,
                teamName = self._teamName,
                exp = exp,
                isWin = true
    	    	}, self:getCallTbl())
    	else
        	battleScene.curModalDialog = QFriendDialogWin.new({
                isWin = false
                }, self:getLoseCallTbl())
        end
    else
        local info = {}
        local rivalsInfo = dungeonConfig.rivalsInfo
        local myInfo = dungeonConfig.myInfo
        local scoreInfo = app.battle:getPVPMultipleWaveNewScoreInfo()

        local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(dungeonConfig.myInfo, dungeonConfig.rivalsInfo, dungeonConfig.pvpMultipleTeams, self._isWin, false)
        info.isFriend = true
        info.maritimeMoney = 0
        info.team1Score = scoreInfo.heroScore or 0
        info.team2Score = scoreInfo.enemyScore or 0
        info.team1avatar = myInfo.avatar
        info.team2avatar = rivalsInfo.avatar
        info.team1Name = myInfo.name
        info.team2Name = rivalsInfo.name
        info.scoreList = scoreInfo.scoreList
        info.replayInfo = replayInfo
        info.activityYield = 0
        battleScene.curModalDialog = QBattleDialogWaveEnd.new({info = info, isWin = self._isWin, rankInfo = self.response, rivalId = dungeonConfig.rivalId}, self:getCallTbl())  
    end
end

return QFriendResultController