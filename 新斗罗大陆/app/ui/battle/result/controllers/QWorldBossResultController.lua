-- @Author: xurui
-- @Date:   2017-04-27 11:05:49
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-04-27 11:25:00
local QBaseResultController = import(".QBaseResultController")
local QWorldBossResultController = class("QWorldBossResultController", QBaseResultController)

local QWorldBossDialogWin = import("..dialogs.QWorldBossDialogWin")

function QWorldBossResultController:ctor(options)
end

function QWorldBossResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()
    local quickFightResult = dungeonConfig.quickFightResult
    local hp = app.battle:getWorldBossFightBossHp()
    self.intrusion_money = remote.user.intrusion_money
    remote.worldBoss:requestWorldBossFightEnd(hp, dungeonConfig.worldBossLevel, dungeonConfig.verifyKey, function (data)
        dungeonConfig.fightEndResponse = data
        self:setResponse(data)
    end, function(data)
        self:requestFail(data)
    end, false)
end

function QWorldBossResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local worldBoss = remote.worldBoss:getWorldBossInfo()
    local index = 1
    local awards = {}
    if worldBoss.fightHurtReward ~= nil then
        awards[index] = string.split(worldBoss.fightHurtReward, "^")
        awards[index].title = "基础奖励"
        index = index + 1
    end
    if worldBoss.fightLuckyReward ~= nil then
        awards[index] = string.split(worldBoss.fightLuckyReward, "^")
        awards[index].title = "幸运一击"
        index = index + 1
    end
    if worldBoss.fightKillReward ~= nil then
        awards[index] = string.split(worldBoss.fightKillReward, "^")
        awards[index].title = "击杀奖励"
        index = index + 1
    end

    app.taskEvent:updateTaskEventProgress(app.taskEvent.WORLD_BOSS_TASK_EVENT, 1)

 	battleScene.curModalDialog = QWorldBossDialogWin.new(
            {
                meritorious = math.floor((remote.worldBoss:getWorldBossInfo().allHurt - dungeonConfig.worldBossMerit)/1000),
                damage = remote.worldBoss:getWorldBossInfo().allHurt - dungeonConfig.worldBossMerit, 
                oldHurtRank = worldBoss.oldHurtRank,
                hurtRank = worldBoss.hurtRank,
                awards = awards,
                isWin = true,
            }, self:getCallTbl())
end

return QWorldBossResultController