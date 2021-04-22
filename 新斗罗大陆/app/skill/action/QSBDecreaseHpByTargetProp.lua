-- @Author: wanghai
-- @Date:   2020-06-02 14:48:47
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-09-18 15:17:03

-- attack_percent                   根据攻击者的最大攻击力计算伤害
-- attacker_current_hp_percent      根据攻击者的当前血量计算伤害
-- attacker_max_hp_percent          根据攻击者的最大血量计算伤害

--[[
    根据目标属性造成伤害
--]]
local QSBAction = import(".QSBAction")
local QSBDecreaseHpByTargetProp = class("QSBDecreaseHpByTargetProp", QSBAction)

function QSBDecreaseHpByTargetProp:_execute(dt)
    local targets
    if self._options.selectTargets then
        targets = self._options.selectTargets
    elseif self._options.target_enemy then
        targets = app.battle:getMyEnemies(self._attacker)
    elseif self._skill:getRangeType() == self._skill.MULTIPLE then
        targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition())   
    else
        targets = {self._target}
    end
    if targets and #targets > 0 then
        local limit = 1
        local real_damage = 0
        local override_damage = 
        {
            damage = real_damage,
            tip = "",
            critical = false,
            hit_status = "hit",
            ignore_damage_to_absorb = true,
        }
        for i,target in ipairs(targets) do
            if self:isDeflection(self._attacker, target, true) then
                override_damage.damage = 0
                override_damage.tip = "闪避"
                override_damage.isDodge = true
                override_damage.isHero = target:getType() ~= ACTOR_TYPES.NPC
            else
                local damage = self:getDamage(target)
                local limit = self:getLimit()
                if limit > 0 then
                    damage = math.min(limit, damage)
                end
                damage = damage * self:getDragonModifier()
                override_damage.damage = damage
            end
            self._attacker:hit(self._skill, target, nil, override_damage, nil, true)
        end
    end
    self:finished()
end

function QSBDecreaseHpByTargetProp:getDamage(target)
    local damage = 0
    if self._options.is_max_hp_percent then
        local percent = self._options.hp_percent or 1
        local targetHp = self._options.current_hp_percent and target:getHp() or target:getMaxHp()
        damage = damage + targetHp * percent
    elseif self._options.attack_percent then
        damage = self._attacker:getAttack() * self._options.attack_percent
    elseif self._options.attacker_current_hp_percent then
        damage = self._attacker:getHp() * self._options.attacker_current_hp_percent
    elseif self._options.attacker_max_hp_percent then
        damage = self._attacker:getMaxHp() * self._options.attacker_max_hp_percent
    end

    return damage
end

function QSBDecreaseHpByTargetProp:getLimit()
    local limit = 0
    if self._options.attacker_attack_limit then
        limit = limit + self._attacker:getAttack() *
            self._options.attacker_attack_limit
    end

    return limit
end

return QSBDecreaseHpByTargetProp