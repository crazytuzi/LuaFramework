-- @Author: zhouxiaoshu
-- @Date:   2019-09-18 14:29:42
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-09-19 11:46:30
local QBaseResultController = import(".QBaseResultController")
local QSotoTeamResultController = class("QSotoTeamResultController", QBaseResultController)
local QSotoTeamDialogWin = import("..dialogs.QSotoTeamDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QSotoTeamResultController:ctor(options)
end

function QSotoTeamResultController:requestResult(isWin)
    print("<<<QSotoTeamResultController>>>")
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

function QSotoTeamResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local awards = {}
    if self.response.result.extraExpItem then
        for _, value in pairs(self.response.result.extraExpItem) do
            table.insert(awards, value)
        end
    end
    if self.response.result.prizes then
        for _, value in pairs(self.response.result.prizes) do
            table.insert(awards, value)
        end
    end

    local exp = 0
    local money = 0
    local score = self.response.result.sotoTeamUserInfoResponse.myInfo.integral - dungeonConfig.myInfo.integral
    local yield = self.response.result.yield or 1
    local userComeBackRatio = self.response.result.userComeBackRatio or 1
    local activityYield = remote.activity:getActivityMultipleYield() or 1
    if userComeBackRatio > 0 then
        activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
    end
    local tbl = {}
    if self._isWin then
        tbl = self:getCallTbl()
    else
        tbl = self:getLoseCallTbl()
    end
    battleScene.curModalDialog = QSotoTeamDialogWin.new({
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

return QSotoTeamResultController
