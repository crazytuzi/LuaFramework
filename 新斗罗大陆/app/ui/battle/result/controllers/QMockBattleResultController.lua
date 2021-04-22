


local QBaseResultController = import(".QBaseResultController")
local QMockBattleResultController = class("QMockBattleResultController", QBaseResultController)
local QMockBattle = import("..network.models.QMockBattle")
local QBattleDialogWaveEnd = import("..dialogs.QBattleDialogWaveEnd")
local QReplayUtil = import(".....utils.QReplayUtil")
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")
local QBattleDialogMockLose = import("..dialogs.QBattleDialogMockLose")
function QMockBattleResultController:ctor(options)
end

function QMockBattleResultController:requestResult(isWin)
    self._isWin = isWin
    self._teamName = remote.teamManager.MOCK_BATTLE_TEAM
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    -- local content = readFromBinaryFile("last.reppb")
    -- local fightReportData = crypto.encodeBase64(content)
    --local battleFormation = dungeonConfig.battleFormation
    local heroScore, enemyScore = 0, 0
    self._scoreList = dungeonConfig.fightEndResponse.gfEndResponse.scoreList
    for _, score in ipairs(self._scoreList or {}) do 
        if score then
            heroScore = heroScore + 1
            self._isWin = true
        else
            enemyScore = enemyScore + 1
        end
    end
    self._heroScore = heroScore
    self._enemyScore = enemyScore
    
    local passTime = math.floor(app.battle:getTime())
    -- local teamVO = remote.teamManager:getTeamByKey( self._teamName, false)
    -- teamVO:initBattleFormation()
	self:setResponse(dungeonConfig.fightEndResponse)
 
end

function QMockBattleResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    if dungeonConfig.isPvpMultipleNew then
        local info = {}
        local rivalsInfo = dungeonConfig.rivalsInfo
        local myInfo = dungeonConfig.myInfo
        local reward = ""
        local awards =  {}
        -- 获取服务器发送的首胜奖励
        if remote.mockbattle:getMockBattleWinReward() ~= "" then
            reward = reward..remote.mockbattle:getMockBattleWinReward()..";"
            remote.mockbattle:setMockBattleWinReward("") 
        end

        -- if dungeonConfig.fightEndResponse.prizes then
        --     for i,v in ipairs(dungeonConfig.fightEndResponse.prizes ) do
        --     end
        -- end
        if self._isWin then
            local win_num = remote.mockbattle:getMockBattleRoundInfo().winCount or 0
            local old_win_num = remote.mockbattle:getMockBattleOldWinCount() or 0
            local  num = win_num - old_win_num
            -- for _, score in ipairs(self._scoreList or {}) do 
            --     if score then
            --         num = num + 1
            --     end
            -- end
            local score_item_num = 0
            for i=1,num do
                local cur_win_num = win_num - i + 1
                if cur_win_num > 0 then
                    score_item_num = score_item_num + db:getMockBattleScoreRewardById(cur_win_num , QMockBattle.SEASON_TYPE_DOUBLE)
                end
            end

            if score_item_num > 0 then
                reward = reward.."mock_battle_integral^"..score_item_num
            end
        end
        
        local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(dungeonConfig.myInfo, dungeonConfig.rivalsInfo, dungeonConfig.pvpMultipleTeams, self._isWin, false)
        local scoreList = self._scoreList or {0,0}
        info.isMockBattle = true
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

    else

        local awards =  {}
        -- if dungeonConfig.fightEndResponse.prizes then
        --     awards = dungeonConfig.fightEndResponse.prizes 
        --     remote.mockbattle:setMockBattleWinReward("") 
        -- end

        if remote.mockbattle:getMockBattleWinReward() ~= "" then
            local  reward =  {}
            reward = remote.items:analysisServerItem(remote.mockbattle:getMockBattleWinReward()or "", reward)
            for k,v in pairs(reward) do
                table.insert(awards, {id = 0, type = v.typeName,count = tonumber(v.count)})
            end
            remote.mockbattle:setMockBattleWinReward("")
        end

        if self._isWin then
            local win_num = remote.mockbattle:getMockBattleRoundInfo().winCount or 0
            if win_num > 0 then
                local score_item_num = db:getMockBattleScoreRewardById(win_num , QMockBattle.SEASON_TYPE_SINGLE)
                table.insert(awards, {id = 70, type = "mock_battle_integral",count = tonumber(score_item_num)})
            end
        end
      
        local activityYield = remote.activity:getActivityMultipleYield() or 1
        if self._isWin then
        battleScene.curModalDialog = QArenaDialogWin.new({
            heroOldInfo = dungeonConfig.heros or {} , 
            teamName = self._teamName,
            exp = 0,
            money = 0,
            timeType = "2",
            score = 0,
            awards = awards, -- 奖励物品
            yield = 1,
            activityYield = activityYield, -- 活动双倍
            isWin = self._isWin,
            skipLocal = true,
            isMockBattle = true
            },self:getCallTbl()) 
        else
            battleScene.curModalDialog = QBattleDialogMockLose.new({},self:getLoseCallTbl())
        end
    end 



end

return QMockBattleResultController