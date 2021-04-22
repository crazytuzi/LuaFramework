--[[
    治疗后每个人的血量百分比是相同的(治疗量足够的话)
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBAverageTreat = class("QSBAverageTreat", QSBAction)
local QActor = import("...models.QActor")

function QSBAverageTreat:ctor(director, attacker, target, skill, options)
    QSBAverageTreat.super.ctor(self, director, attacker, target, skill, options)
end

function QSBAverageTreat:_execute(dt)
    local override_damage = {}
    local damage, tip, critical, hit_status, original_damage, ignore_absorb
    damage, tip, critical, hit_status, original_damage, ignore_absorb = self._attacker:getCalcDamage(self._attacker, self._skill, self._target, nil, true)

    local teammates = app.battle:getMyTeammates(self._attacker, true, true)
    table.sort( teammates, function(a, b)
        return a:getHp()/a:getMaxHp() < b:getHp()/b:getMaxHp()
    end)

    local meanHp = function(team, count, value, tab)
        local total = 0
        for i = 1, count do
            total = total + team[i]:getMaxHp()
        end
        for i = 1, count do
            if not tab[i] then tab[i] = 0 end
            tab[i] = tab[i] + (team[i]:getMaxHp()/total)*value
        end
    end

    local count = #teammates
    local damageTab = {}
    for i = 2, count do
        local actor1, actor2 = teammates[i-1], teammates[i]
        local percent1, percent2 = actor1:getHp()/actor1:getMaxHp(), actor2:getHp()/actor2:getMaxHp()
        local delta = (percent2 - percent1)
        local total = 0
        for j = 1, i - 1 do
            local deltaValue = delta * teammates[j]:getMaxHp()
            total = total + deltaValue
        end
        if damage >= total then
            for j = 1, i - 1 do
                local deltaValue = delta * teammates[j]:getMaxHp()
                if not damageTab[j] then
                    damageTab[j] = 0
                end
                damageTab[j] = damageTab[j] + deltaValue
            end
            damage = damage - total
        else
            meanHp(teammates, i-1, damage, damageTab)
            damage = 0
            break
        end
    end
    if damage > 0 then
        meanHp(teammates, #teammates, damage, damageTab)
    end

    for index, actor in ipairs(teammates) do
        if damageTab[index] then
            local override_damage = {}
            override_damage.damage = damageTab[index]
            override_damage.tip = tip
            override_damage.critical = critical
            override_damage.hit_status = hit_status
            self._attacker:hit(self._skill, actor, nil, override_damage, nil, true)
        end
    end

    self:finished()
end

return QSBAverageTreat
