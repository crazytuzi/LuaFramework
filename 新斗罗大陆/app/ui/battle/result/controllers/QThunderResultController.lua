local QBaseResultController = import(".QBaseResultController")
local QThunderResultController = class("QThunderResultController", QBaseResultController)

local QThunderDialogWin = import("..dialogs.QThunderDialogWin")
local QStaticDatabase = import(".....controllers.QStaticDatabase")

function QThunderResultController:ctor(options)
end

function QThunderResultController:requestResult(isWin)
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    -- 保留旧魂师
    self._teamName = dungeonConfig.teamName or remote.teamManager.THUNDER_TEAM
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    self._heroOldInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end

    dungeonConfig.heros = {}
    local attackTeam = remote.teamManager:getActorIdsByKey(remote.teamManager.THUNDER_TEAM, 1)
    for _,actorId in pairs(attackTeam) do
        table.insert(dungeonConfig.heros, remote.herosUtil:getHeroByID(actorId))
    end

    dungeonConfig.oldThunderInfo = {}
    local oldThunderInfo = remote.thunder:getThunderFighter()
    table.insert(dungeonConfig.oldThunderInfo, oldThunderInfo)

    self._thunderMoney = {money = remote.user.money, thunderMoney = remote.user.thunderMoney}
    local oldUser = remote.user:clone()
    remote.thunder:thunderFightEndRequest(dungeonConfig.rivalUserId, dungeonConfig.waveType, self._isWin, dungeonConfig.hard, dungeonConfig.hard, dungeonConfig.eliteWave,
     dungeonConfig.verifyKey, function (data)
        data = {result = data, oldUser = oldUser}
        self:setResponse(data)
    end, function(data)
        self:requestFail(data)
    end)
end

function QThunderResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    if self._isWin then
        local awards = {}
        local prizesThunderMoney = 0
        if dungeonConfig.waveType == "ELITE_WAVE" then
            if self.response.result.apiThunderFightEndResponse.luckyDraw ~= nil then
                local level, thunderInfo = remote.thunder:getEliteBattleInfo()  
                local monsetrInfo = dungeonConfig
                local rewards = string.split(monsetrInfo.thunder_drop, "^")
                table.insert(awards, {id = rewards[1], type = ITEM_TYPE.ITEM, count = tonumber(rewards[2])})
            end
        else
            if self.response.result.apiThunderFightEndResponse.luckyDraw ~= nil then
                local prizes = self.response.result.apiThunderFightEndResponse.luckyDraw.prizes 
                if prizes ~= nil then
                    for _, value in pairs(prizes) do
                        if value.type == "THUNDER_MONEY" then
                            prizesThunderMoney = value.count
                        end
                    end
                end
            end
        end

        --节假日活动掉落
        if self.response and self.response.result and self.response.result.extraExpItem and type(self.response.result.extraExpItem) == "table" then
            for _, value in pairs(self.response.result.extraExpItem) do
                table.insert(awards, {id = value.id, type = value.type, count = value.count or 0})
            end
        end

        local exp = 0
        local money = remote.user.money - self._thunderMoney.money
        local yield = self.response.result.apiThunderFightEndResponse.yield or 1
        local userComeBackRatio = self.response.result.userComeBackRatio or 1
        local activityYield = remote.activity:getActivityMultipleYield(607)
        if userComeBackRatio > 0 then
            activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
        end
        local dungeonId = dungeonConfig.dungeonId
        local thunderMoney = remote.user.thunderMoney - self._thunderMoney.thunderMoney - prizesThunderMoney
        if thunderMoney > 0 and dungeonConfig.waveType ~= "ELITE_WAVE" then
            table.insert(awards,{id = nil, type = ITEM_TYPE.THUNDER_MONEY, count = thunderMoney})
        end
        -- print(remote.activity:getActivityMultipleYield(607), userComeBackRatio, activityYield)
        local winNpc = dungeonConfig.oldThunderInfo[1] and dungeonConfig.oldThunderInfo[1].thunderEliteAlreadyWinNpc or {}
        remote.thunder:setEliteBattleInfo(dungeonConfig.eliteWave, winNpc)

        battleScene.curModalDialog = QThunderDialogWin.new({
            heroOldInfo = self._heroOldInfo,
            oldTeamLevel = self.response.oldUser.level,
            teamName = self._teamName,
            exp = exp,
            money = money, 
            timeType = "2",
            awards = awards, -- 奖励物品
            yield = yield, -- 战斗奖励翻倍
            activityYield = activityYield, -- 活动双倍
            dungeonId = dungeonId,
            isWin = true
            },self:getCallTbl())
    else
        battleScene.curModalDialog = QThunderDialogWin.new({
            isWin = false
            }, self:getLoseCallTbl())
    end
end

return QThunderResultController