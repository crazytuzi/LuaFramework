local QBaseResultController = import(".QBaseResultController")
local QArenaResultController = class("QArenaResultController", QBaseResultController)
local QArenaDialogWin = import("..dialogs.QArenaDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QArenaResultController:ctor(options)
end

function QArenaResultController:requestResult(isWin)
    print("<<<QArenaResultController>>>")
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    -- 保留旧魂师
    self._teamName = dungeonConfig.teamName or remote.teamManager.ARENA_ATTACK_TEAM
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    self._heroOldInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end

    local oldUser = remote.user:clone()
    local data = {result = dungeonConfig.fightEndResponse, oldUser = oldUser}
    self:setResponse(data)
end

function QArenaResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local awards = {}
    if self.response and self.response.result and self.response.result.extraExpItem and type(self.response.result.extraExpItem) == "table" then
        for _, value in pairs(self.response.result.extraExpItem) do
            table.insert(awards, {id = value.id, type = value.type, count = value.count or 0})
        end
    end
    local exp = 0
    local money = 0
    local score = self.response.result.arenaResponse.mySelf.arenaRewardIntegral - dungeonConfig.myInfo.arenaRewardIntegral
    local yield = self.response.result.arenaMoneyYield or 1
    local userComeBackRatio = self.response.result.userComeBackRatio or 1
    local activityYield = remote.activity:getActivityMultipleYield() or 1
    if userComeBackRatio > 0 then
        activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
    end

    local money = self.response.result.wallet.arenaMoney - dungeonConfig.myInfo.arenaMoney
    table.insert(awards, {id = nil, type = ITEM_TYPE.ARENA_MONEY, count = math.ceil(money/yield)})

    
    if self._isWin and dungeonConfig.rivalId then
        remote.arena:setTopRankUpdate(self.response.result, dungeonConfig.rivalId)
    end
    local tbl = {}
    if self._isWin then
        tbl = self:getCallTbl()
    else
        tbl = self:getLoseCallTbl()
    end
    battleScene.curModalDialog = QArenaDialogWin.new({
        heroOldInfo = self._heroOldInfo,
        oldTeamLevel = self.response.oldUser.level,
        teamName = self._teamName,
        timeType = "2",
        exp = exp,
        money = money, 
        score = score,
        awards = awards, -- 奖励物品
        yield = yield, -- 战斗奖励翻倍
        activityYield = activityYield, -- 活动双倍
        isWin = self._isWin
        },tbl) 

    if (device.platform == "windows" and app.battle:hasWinOrLose()) then
        local file_name = "arena_result.txt"
        appendToFile(file_name, string.format("[%s]前端判定: %s, 后端判定: %s\n", q.date('%m-%d-%H:%M:%S'), app.battle._onWin_Time and "胜利" or "失败", self._isWin and "胜利" or "失败"))
        if (not not app.battle._onWin_Time) ~= self._isWin then
            appendToFile(file_name, "检测到复盘不一致，以下是战报内容:\n")
            appendToFile(file_name, crypto.encodeBase64(readFromBinaryFile("last.reppb")))
            appendToFile(file_name, "\n")
        end
    end
end

return QArenaResultController