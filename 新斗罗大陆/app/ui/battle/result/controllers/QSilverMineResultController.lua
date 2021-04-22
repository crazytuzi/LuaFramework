local QBaseResultController = import(".QBaseResultController")
local QSilverMineResultController = class("QSilverMineResultController", QBaseResultController)
local QBattleDialogSilverMine = import("..dialogs.QBattleDialogSilverMine")

function QSilverMineResultController:ctor(options)
end

function QSilverMineResultController:requestResult(isWin)
    -- print("[Kumo] QSilverMineResultController:requestResult(isWin) ", isWin)
    if type(isWin) == "number" then
        if isWin == 1 then
            self._isWin = true
        else
            self._isWin = false
        end
    else
        self._isWin = isWin
    end
    -- print("[Kumo] QSilverMineResultController:requestResult(isWin) ", isWin)
    local battleScene = self:getScene()
    self._dungeonConfig = battleScene:getDungeonConfig()

    -- 保留旧武将
    
    self._heroOldInfo = {}
    if app.battle:isInPlunder() then
        self._teamName = remote.teamManager.PLUNDER_ATTACK_TEAM
    else
        self._teamName = remote.teamManager.SILVERMINE_ATTACK_TEAM
    end
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end

    if app.battle:isInQuick() then
        -- print("[Kumo] QSilverMineResultController:requestResult(isWin) app.battle:isInQuick() ")
        local data = self._dungeonConfig.fightEndResponse
        -- QPrintTable(data)
        if app.battle:isInPlunder() then
            remote.plunder:responseHandler(data)
        else
            remote.silverMine:responseHandler(data)
        end

        local oldUser = remote.user:clone()
        data = {result = self._dungeonConfig.fightEndResponse, oldUser = oldUser}
        self:setResponse(data)
    else
        -- print("[Kumo] QSilverMineResultController:requestResult(isWin) not app.battle:isInQuick() ")
        local replayInfo = nil
        if app.battle:isPVPMode() then
            local dungeonConfig = self._dungeonConfig
            replayInfo = QReplayUtil:generateReplayInfo(
                {name = dungeonConfig.team1Name, avatar = dungeonConfig.team1Icon, level = dungeonConfig.team1Level, heros = dungeonConfig.heroInfos}, 
                {name = dungeonConfig.team2Name, avatar = dungeonConfig.team2Icon, level = dungeonConfig.team2Level, heros = dungeonConfig.pvp_rivals}, 1)
        end

        local content = readFromBinaryFile("last.reppb")
        local fightReportData = crypto.encodeBase64(content)
        remote.silverMine:silvermineFightEndRequest(
            self._dungeonConfig.mineId, -- mineId
            self._dungeonConfig.mineOwnerId, -- mineOwnerId
            fightReportData, -- fightReportData
            self._dungeonConfig.verifyKey, -- battleVerify
            self._isWin, -- isWin
            false, -- isQuick
            function(data) -- success
                remote.silverMine:responseHandler(data)
                -- if replayInfo and data.silverMineFightEndResponse.fightReportId then
                --     QReplayUtil:uploadReplay(data.silverMineFightEndResponse.fightReportId, replayInfo, function ()
                if replayInfo and data.gfEndResponse.reportId then
                    QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function ()
                        local oldUser = remote.user:clone()
                        data = {result = self._dungeonConfig.fightEndResponse, oldUser = oldUser}
                        self:setResponse(data)
                    end, function ()
                        local oldUser = remote.user:clone()
                        data = {result = self._dungeonConfig.fightEndResponse, oldUser = oldUser}
                        self:setResponse(data)
                    end, REPORT_TYPE.SILVERMINE)
                else
                    local oldUser = remote.user:clone()
                    data = {result = self._dungeonConfig.fightEndResponse, oldUser = oldUser}
                    self:setResponse(data)
                end
            end,
            function(data) -- fail
                self:requestFail(data)
            end)
    end
end

function QSilverMineResultController:fightEndHandler()
    local battleScene = self:getScene()

    local info = {}
    info.heros = {}
    local attackTeam
    if app.battle:isInPlunder() then
        attackTeam = remote.teamManager:getActorIdsByKey(remote.teamManager.PLUNDER_ATTACK_TEAM, 1)
    else
        attackTeam = remote.teamManager:getActorIdsByKey(remote.teamManager.SILVERMINE_ATTACK_TEAM, 1)
    end
    for _,actorId in pairs(attackTeam) do
        table.insert(info.heros, remote.herosUtil:getHeroByID(actorId))
    end
    if self.response and self.response.wallet then
        if not self._dungeonConfig.isPlunder then
            info.money = self.response.wallet.money - self._dungeonConfig.myInfo.money
            info.silvermineMoney = self.response.result.wallet.silvermineMoney - self._dungeonConfig.myInfo.silvermineMoney
        end
    else
        info.money = 0
        info.silvermineMoney = 0
    end
    if self._dungeonConfig.isPlunder and self.response.result.kuafuMineLootFightEndResponse then
        info.plunderScore = self.response.result.kuafuMineLootFightEndResponse.lootScore or 0
    end
    -- 不确定
    if self._dungeonConfig.isPlunder and self.response.result.gfEndResponse.kuafuMineLootFightEndResponse then
        info.plunderScore = self.response.result.gfEndResponse.kuafuMineLootFightEndResponse.lootScore or 0
    end


    --掉落物品显示
    local awards = {}
    --节假日活动掉落
    if self.response.result and type(self.response.result.extraExpItem) == "table" then
        for _, value in pairs(self.response.result.extraExpItem) do
            table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
        end
    end
    if info.silvermineMoney and info.silvermineMoney > 0 then
        table.insert(awards,{id = nil, type = ITEM_TYPE.SILVERMINE_MONEY, count = info.silvermineMoney})
    end

    if info.plunderScore and info.plunderScore > 0 then
        table.insert(awards,{id = nil, type = ITEM_TYPE.PLUNDER_SCORE, count = info.plunderScore})
    end

    local exp = 0
    local money = info.money
    local yield = 1
    local activityYeild = 1
    -- battleScene.curModalDialog = QBattleDialogSilverMine.new({info = info, isWin = self._isWin, rankInfo = self.response.result, isPlunder = self._dungeonConfig.isPlunder}, self:getCallTbl())
    battleScene.curModalDialog = QBattleDialogSilverMine.new({
        heroOldInfo = self._heroOldInfo,
        oldTeamLevel = self.response.oldUser.level,
        teamName = self._teamName,
        timeType = "2",
        exp = exp,
        money = money, 
        awards = awards, -- 奖励物品
        yield = yield, -- 战斗奖励翻倍
        activityYeild = activityYeild, -- 活动双倍
        isWin = self._isWin,
        isPlunder = self._dungeonConfig.isPlunder
        },self:getCallTbl()) 
end

return QSilverMineResultController