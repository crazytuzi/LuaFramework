local QBaseResultController = import(".QBaseResultController")
local QSocietyDungeonResultController = class("QSocietyDungeonResultController", QBaseResultController)
local QBattleDialogSocietyDungeon = import("..dialogs.QBattleDialogSocietyDungeon")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")
local QStaticDatabase = import(".....controllers.QStaticDatabase")

function QSocietyDungeonResultController:ctor(options)
end

function QSocietyDungeonResultController:requestResult(isWin)
    -- print("[Kumo] QSocietyDungeonResultController:requestResult(isWin) ", isWin)
    local battleScene = self:getScene()
    self._dungeonConfig = battleScene:getDungeonConfig()

    local hp = app.battle:getSocietyDungeonBossHpReduce()

    remote.union:unionFightEndRequest(self._dungeonConfig.societyDungeonWave, hp, self._dungeonConfig.verifyKey, self._dungeonConfig.societyDungeonChapter, function(data)
            self._dungeonConfig.fightEndResponse = data
            self:setResponse(data)
        end, function(data)
            self:requestFail(data)
        end)
end

function QSocietyDungeonResultController:fightEndHandler()
    local battleScene = self:getScene()

    local attackTeam = remote.teamManager:getActorIdsByKey(self._dungeonConfig.teamName, 1)
    local info = {heros = {}}
    for _,actorId in pairs(attackTeam) do
        table.insert(info.heros, remote.herosUtil:getHeroByID(actorId))
    end

    --xurui: 更新每日军团副本活跃任务
    remote.union.unionActive:updateActiveTaskProgress(20002, 1)

    local showChapter = remote.union:getShowChapter()
    local fightWave = remote.union:getFightWave()
    local config = QStaticDatabase.sharedDatabase():getScoietyWave(fightWave, showChapter)
    local bossList = remote.union:getConsortiaBossList(showChapter)
    local isWin = false
    local totalAward = remote.user.consortiaMoney - self._dungeonConfig.consortiaMoney
    local baseAward = config.battle_reward
    local killedAward = 0
    if bossList and #bossList > 0 then
        for _, value in pairs(bossList) do
            if value.chapter == showChapter and value.wave == fightWave and value.bossHp == 0 then
                isWin = true
            end
        end
    end

    if isWin then
        local tbl = QStaticDatabase.sharedDatabase():getluckyDrawById(config.reward_personal)
        killedAward = tbl[1].count
    end
    local activityYield = remote.activity:getActivityMultipleYield(702)
    if activityYield then
        baseAward = baseAward * activityYield
    end
    battleScene.curModalDialog = QBattleDialogSocietyDungeon.new({
        totalAward = totalAward, -- 总共获得
        baseAward = baseAward, -- 基础奖励
        killedAward = killedAward, -- 击杀奖励
        activityYield = activityYield,
        damageAward = totalAward - baseAward - killedAward, -- 伤害奖励
        isWin = isWin,
        damage = self.response.consortiaBossHurtHp or 0 -- 造成伤害
        }, self:getCallTbl())
    
    if self.response.extraExpItem then
        remote.union:setConsortiaBossSpecAward(self.response.extraExpItem or {})
    end
end

return QSocietyDungeonResultController