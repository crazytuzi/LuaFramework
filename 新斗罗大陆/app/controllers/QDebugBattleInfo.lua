
local QDebugBattleInfo = class("QDebugBattleInfo")

function QDebugBattleInfo:ctor(options)
    QUtility:debugClearBattleInfo()
end

local function topercentstring(percent, is_percentage)
    return string.format("%0.1f%%", is_percentage and percent or percent * 100)
end

function QDebugBattleInfo:update()
    if app.battle and app.battle.getBattleLog then
        QUtility:debugClearBattleInfo()
        local log = app.battle:getBattleLog()
        local _heroes1 = app.battle:getHeroes()
        local _heroes2 = app.battle:getDeadHeroes()
        local heroes = {}
        table.mergeForArray(heroes, _heroes1)
        table.mergeForArray(heroes, _heroes2)
        for _, hero in ipairs(app.battle._heroGhosts or {}) do
            if hero.actor.isSoulSpirit and hero.actor:isSoulSpirit() then
                table.insert(heroes, hero.actor)
            end
        end
        for index, hero in ipairs(heroes) do
            local stat_obj = log.heroStats[hero:getActorID()]
            QUtility:debugSetBattleInfo(tostring(hero:getDisplayName()), "name", index - 1)
            QUtility:debugSetBattleInfo(tostring(hero:getLevel()), "level", index - 1)
            QUtility:debugSetBattleInfo(tostring(hero:getHp()), "hp", index - 1)
            QUtility:debugSetBattleInfo(tostring(hero:getMaxHp()), "maxHp", index - 1)
            local attack = tostring(hero:getAttack()) .. "(" .. tostring(topercentstring(hero:getTargetPhysicalArmorCoefficient())) .. ")" .. "(" .. tostring(topercentstring(hero:getTargetMagicArmorCoefficient())) .. ")"
            QUtility:debugSetBattleInfo(attack, "attack", index - 1)
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:getPhysicalArmor()), "physicalArmor", index - 1)
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:getMagicArmor()), "magicArmor", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getPhysicalDamagePercentUnderAttack())), "physicalDamagePercentUnderAttack", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getMagicDamagePercentUnderAttack())), "magicDamagePercentUnderAttack", index - 1)
            QUtility:debugSetBattleInfo(tostring(hero:getMoveSpeed()), "speed", index - 1)
            -- QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getCrit(), true)), "critical", index - 1)
            QUtility:debugSetBattleInfo(hero:getCritDetailString(), "critical", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getBaseCritDamage())), "criticalDamage", index - 1)
            -- QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getDodge(), true)), "dodge", index - 1)
            QUtility:debugSetBattleInfo(hero:getDodgeDetailString(), "dodge", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getBlock(hero:getLastAttacker()), true)), "block", index - 1)
            -- QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getHit(), true)), "hit", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(hero:getMaxHaste(), true)), "haste", index - 1)
            QUtility:debugSetBattleInfo(tostring(stat_obj and stat_obj.damage), "totalDamage", index - 1)
            QUtility:debugSetBattleInfo(tostring(stat_obj and stat_obj.treat), "totalTreat", index - 1)

            QUtility:debugSetBattleInfo(string.format("%d", hero:getRage()), "rage", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%d", hero:getAbsorbDamageValue()), "absorbDamage", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:_getActorNumberPropertyValue("physical_damage_percent_beattack") + hero:getPhysicalDamagePercentAttack()), "physicalBeattack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:_getActorNumberPropertyValue("magic_damage_percent_beattack") + hero:getMagicDamagePercentAttack()), "magicBeattack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:getPVPPhysicalAttackPercent()), "PVPPhysicalAttack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:getPVPPhysicalReducePercent()), "PVPPhysicalReduce", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:getPVPMagicAttackPercent()), "PVPMagicAttack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", hero:getPVPMagicReducePercent()), "PVPMagicReduce", index - 1 )
        end

        local enemies = {}
        table.mergeForArray(enemies, app.battle:getEnemies())
        for _, enemy in ipairs(app.battle._enemyGhosts or {}) do
            if enemy.actor.isSoulSpirit and enemy.actor:isSoulSpirit() then
                table.insert(enemies, enemy.actor)
            end
        end
        for index, enemy in ipairs(enemies) do
            if index == 5 then
                break
            end
            index = index + 4
            local stat_obj = log.enemyHeroStats[enemy:getActorID()]
            QUtility:debugSetBattleInfo(tostring(enemy:getDisplayName()), "name", index - 1)
            QUtility:debugSetBattleInfo(tostring(enemy:getLevel()), "level", index - 1)
            QUtility:debugSetBattleInfo(tostring(enemy:getHp()), "hp", index - 1)
            QUtility:debugSetBattleInfo(tostring(enemy:getMaxHp()), "maxHp", index - 1)
            local attack = tostring(enemy:getAttack()) .. "(" .. tostring(topercentstring(enemy:getTargetPhysicalArmorCoefficient())) .. ")" .. "(" .. tostring(topercentstring(enemy:getTargetMagicArmorCoefficient())) .. ")"
            QUtility:debugSetBattleInfo(attack, "attack", index - 1)
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:getPhysicalArmor()), "physicalArmor", index - 1)
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:getMagicArmor()), "magicArmor", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getPhysicalDamagePercentUnderAttack())), "physicalDamagePercentUnderAttack", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getMagicDamagePercentUnderAttack())), "magicDamagePercentUnderAttack", index - 1)
            QUtility:debugSetBattleInfo(tostring(enemy:getMoveSpeed()), "speed", index - 1)
            -- QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getCrit(), true)), "critical", index - 1)
            QUtility:debugSetBattleInfo(enemy:getCritDetailString(), "critical", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getBaseCritDamage())), "criticalDamage", index - 1)
            -- QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getDodge(), true)), "dodge", index - 1)
            QUtility:debugSetBattleInfo(enemy:getDodgeDetailString(), "dodge", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getBlock(enemy:getLastAttacker()), true)), "block", index - 1)
            -- QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getHit(), true)), "hit", index - 1)
            QUtility:debugSetBattleInfo(tostring(topercentstring(enemy:getMaxHaste(), true)), "haste", index - 1)
            QUtility:debugSetBattleInfo(tostring(stat_obj and stat_obj.damage), "totalDamage", index - 1)
            QUtility:debugSetBattleInfo(tostring(stat_obj and stat_obj.treat), "totalTreat", index - 1)

            QUtility:debugSetBattleInfo(string.format("%d", enemy:getRage()), "rage", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%d", enemy:getAbsorbDamageValue()), "absorbDamage", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:_getActorNumberPropertyValue("physical_damage_percent_beattack") + enemy:getPhysicalDamagePercentAttack()), "physicalBeattack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:_getActorNumberPropertyValue("magic_damage_percent_beattack") + enemy:getMagicDamagePercentAttack()), "magicBeattack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:getPVPPhysicalAttackPercent()), "PVPPhysicalAttack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:getPVPPhysicalReducePercent()), "PVPPhysicalReduce", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:getPVPMagicAttackPercent()), "PVPMagicAttack", index - 1 )
            QUtility:debugSetBattleInfo(string.format("%0.3f", enemy:getPVPMagicReducePercent()), "PVPMagicReduce", index - 1 )
        end
    else

    end
end

function QDebugBattleInfo:start()
    if self._schedule_id then
        return
    end

    self._schedule_id = scheduler.scheduleGlobal(function()
        self:update()
    end, 0.5)
end

function QDebugBattleInfo:finish()
    if self._schedule_id == nil then
        return
    end
    
    self:update()

    scheduler.unscheduleGlobal(self._schedule_id)
    self._schedule_id = nil
end

return QDebugBattleInfo
