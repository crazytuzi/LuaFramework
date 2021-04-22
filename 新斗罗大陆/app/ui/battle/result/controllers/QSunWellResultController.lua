local QBaseResultController = import(".QBaseResultController")
local QSunWellResultController = class("QSunWellResultController", QBaseResultController)
local QBattleDialogSunWell = import("..dialogs.QBattleDialogSunWell")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QSunWellResultController:ctor(options)
end

function QSunWellResultController:requestResult(isWin)
    -- print("[Kumo] QSunWellResultController:requestResult(isWin) ", isWin)
    if type(isWin) == "number" then
        if isWin == 1 then
            self._isWin = true
        else
            self._isWin = false
        end
    else
        self._isWin = isWin
    end

    local battleScene = self:getScene()
    self._dungeonConfig = battleScene:getDungeonConfig()
    -- 保留旧魂师
    self._teamName = self._dungeonConfig.teamName or remote.teamManager.SUNWAR_ATTACK_TEAM
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    self._heroOldInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end

    --自己魂师
    local selfHeros = {}
    local liveHeroes = app.battle:getHeroes()
    local deadHeroes = app.battle:getDeadHeroes()
    local heroes = {}
    table.mergeForArray(heroes, liveHeroes, function(actor) return actor ~= app.battle:getSupportSkillHero() and actor ~= app.battle:getSupportSkillHero2() end)
    table.mergeForArray(heroes, deadHeroes, function(actor) return actor ~= app.battle:getSupportSkillHero() and actor ~= app.battle:getSupportSkillHero2() end)
    for _, hero in ipairs(heroes) do
        local currMp
        if hero:isNeedComboPoints() then
            currMp = hero:getComboPoints() / hero:getComboPointsMax() * 1000
        else
            currMp = hero:getRage()
        end
        currMp = currMp ~= 0 and currMp or -1
        if hero:isDead() or (not isWin and not hero:isSupportHero()) then
            currMp = hero:getRageTotal()/2
            table.insert(selfHeros, {actorId = hero:getActorID(), currHp = -1, currMp = currMp})
        else
            table.insert(selfHeros, {actorId = hero:getActorID(), currHp = hero:getHp(), currMp = currMp})
        end
    end

    local soulSpirits = app.battle:getSoulSpiritHero() or {}
    for _,soulSpirit in pairs(soulSpirits) do
        local currMp = soulSpirit:getRage()
        table.insert(selfHeros, {actorId = soulSpirit:getActorID(), currHp = -1, currMp = currMp})
    end

    remote.sunWar:setMyHeroInfo(selfHeros)
    --敌方魂师
    local enemies = {}
    local liveEnemies = app.battle:getEnemies()
    local allEnemies = self._dungeonConfig.dungeonInfo.heros
    for _,enemy in pairs(allEnemies) do
        local isFind = false
        for _,liveEnemy in pairs(liveEnemies) do
            if enemy.actorId == liveEnemy:getActorID() then
                isFind = true
                local currMp, currHp
                if liveEnemy:isNeedComboPoints() then
                    currMp = liveEnemy:getComboPoints() / liveEnemy:getComboPointsMax() * 1000
                else
                    currMp = liveEnemy:getRage()
                end
                currMp = currMp ~= 0 and currMp or -1
                currHp = (isWin and -1 or app.battle:getSunwellEnemyHP(liveEnemy))
                currHp = currHp ~= 0 and currHp or -1
                table.insert(enemies, {actorId = liveEnemy:getActorID(), currHp = currHp, currMp = currMp})
                break
            end
        end
        if isFind == false then
            table.insert(enemies, {actorId = enemy.actorId, currHp = -1, currMp = -1})
        end
    end
    
    local soulSpirits = app.battle:getSoulSpiritEnemy() or {}
    for _,soulSpirit in pairs(soulSpirits) do
        local currMp = soulSpirit:getRage()
        table.insert(enemies, {actorId = soulSpirit:getActorID(), currHp = -1, currMp = currMp})
    end

    --更新对手信息
    local fighter = self._dungeonConfig.dungeonInfo
    local fightWave = remote.sunWar:getCurrentWaveID()
    -- fighter  = fighter["fighter"..dungeonInfo.hardIndex]
    for _,value in pairs(fighter.heros) do
        for _,value2 in pairs(enemies) do
            if value.actorId == value2.actorId then
                value.currHp = value2.currHp
                value.currMp = value2.currMp
                break
            end
        end
    end
    self._oldSunwellMoney = remote.user.sunwellMoney
    self._oldMoney = remote.user.money

    local oldUser = remote.user:clone()
   
    app:getClient():sunwarFightEndRequest(app.battle:getBattleLog().verifyDamageInfos, selfHeros, enemies, self._dungeonConfig.verifyKey, fightWave, false, false, function (data)
        remote.sunWar:responseHandler(data)
        remote.user:addPropNumForKey("todayBattlefieldFightCount")

        app.taskEvent:updateTaskEventProgress(app.taskEvent.SUN_WAR_TASK_EVENT, 1, false, self._isWin)

        if self._isWin == true then
            remote.activity:updateLocalDataByType(548, 1)
        end
        data = {result = data, oldUser = oldUser}
        self:setResponse(data)
    end, function(data)
        self:requestFail(data)
    end)
end

function QSunWellResultController:fightEndHandler()
    -- print("[Kumo] QSunWellResultController:fightEndHandler()")
    local battleScene = self:getScene()

    if self._isWin then
        local myTeam = clone(self._dungeonConfig.myTeam)
        local awards = {}
        local tbl = remote.sunWar:getFirstWinLuckyDraw()
        local firstNum = 0
        local firstMoney = 0 
        if tbl and tbl.prizes then
            for _, value in pairs(tbl.prizes) do
                if value.type == "SUNWELL_MONEY" then 
                    firstNum = value.count
                elseif value.type == "MONEY" then
                    firstMoney = value.count
                end
            end
        end
        
        print("myTeam : ", myTeam)
        local isTimeOver = battleScene:getIsTimeOver()
    
        if self.response and self.response.result and self.response.result.extraExpItem and type(self.response.result.extraExpItem) == "table" then
            for _, value in pairs(self.response.result.extraExpItem) do
                table.insert(awards, {id = value.id, type = value.type, count = value.count or 0})
            end
        end
        if remote.user.sunwellMoney then
            table.insert(awards, {id = nil, type = ITEM_TYPE.SUNWELL_MONEY, count = remote.user.sunwellMoney - self._oldSunwellMoney - firstNum})
        end
        local exp = 0
        local money = remote.user.money - self._oldMoney - firstMoney
        local yield = remote.sunWar:getLuckyDrawCritical() or 1
        local userComeBackRatio = self.response.result.userComeBackRatio or 1
        local activityYield = remote.activity:getActivityMultipleYield(609)
        if userComeBackRatio > 0 then
            activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
        end
        
        battleScene.curModalDialog = QBattleDialogSunWell.new({
            heroOldInfo = self._heroOldInfo,
            oldTeamLevel = self.response.oldUser.level,
            teamName = self._teamName,
            isTimeOver = isTimeOver, 
            exp = exp,
            timeType = "2",
            money = money, 
            awards = awards, -- 奖励物品
            yield = yield, -- 战斗奖励翻倍
            activityYield = activityYield, -- 活动双倍
            isWin = true
            }, self:getCallTbl())
    else
        battleScene.curModalDialog = QBattleDialogSunWell.new({
            isWin = false
            }, self:getLoseCallTbl())
    end
end

return QSunWellResultController