--[[
    根据护盾造成伤害
    coefficient                         伤害系数
    buff_id                             护盾的buff id
    is_single_buff                      相同buff id的只读取一个
    is_by_save_damage                   是否是根据存储治疗量来造成伤害
    save_damage_percent                 取存储治疗量的百分比
    is_add_skill_physical_damage        是否加上技能的物理伤害
    is_add_skill_magic_damage           是否加上技能的魔法伤害
    is_phsical_armor_percent            是否根据最大物理防御来造成伤害
    is_attack_percent                   是否根据最大攻击力来造成伤害
    phsical_armor_percent               取最大物理防御百分比
    attack_percent                      取最大攻击力的百分比
    is_max_hp_percent                   是否根据最大生命来造成伤害
    hp_percent                          取最大生命百分比
    single_max_percent                  单体最大分摊百分比
    is_not_split_damage                 不会根据目标个数分摊伤害
    coef_by_status                      根据status的buff层数去放缩伤害的系数
    scale_status                        根据scale_status层数去放大伤害
--]]
local QSBAction = import(".QSBAction")
local QSBDecreaseHpByAbsorb = class("QSBDecreaseHpByAbsorb", QSBAction)

function QSBDecreaseHpByAbsorb:_execute(dt)    
    local buff_id = self._options.buff_id
    local damage = 0
    if self._options.is_by_save_damage then
        for i, buff in ipairs(self._attacker:getBuffs()) do
            if buff:getId() == buff_id and buff:isSaveDamage() then
                damage = damage + buff:getSavedDamage() * self._options.save_damage_percent
                if self._options.is_single_buff then break end
            end
        end
    else
        for i, buff in ipairs(self._attacker:getBuffs()) do
            if buff:getId() == buff_id and buff:isAbsorbDamage() then
                damage = damage + buff:getAbsorbDamageValue()
                if self._options.is_single_buff then break end
            end
        end
    end
    if self._options.is_add_skill_physical_damage then
        damage = damage + self._skill:getPhysicalDamage()
    end
    if self._options.is_add_skill_magic_damage then
        damage = damage + self._skill:getMagicDamage()
    end
    if self._options.is_phsical_armor_percent then
        local percent = 1
        if self._options.phsical_armor_percent then
            percent = self._options.phsical_armor_percent
        end
        damage = damage + self._attacker:getMaxPhysicalArmor() * percent
    end
    if self._options.is_attack_percent then
        local percent = 1
        if self._options.attack_percent then
            percent = self._options.attack_percent
        end
        damage = damage + self._attacker:getAttack() * percent
    end
    if self._options.is_max_hp_percent then
        local percent = 1
        if self._options.hp_percent then
            percent = self._options.hp_percent
        end
        damage = damage + self._attacker:getMaxHp() * percent
    end

    local coefficient = self._options.coefficient or 1
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
    if targets and #targets > 0 and damage > 0 then
        local limit = 1
        if self._options.single_max_percent then
            limit = self._options.single_max_percent
        end
        local real_damage = 0
        if self._options.is_not_split_damage then
            real_damage = math.min(damage * coefficient, limit * damage)
        else
            real_damage = math.min((damage * coefficient)/(#targets), limit * damage)
        end
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
                if self._options.coef_by_status then
                    local status = self._options.scale_status
                    local has, count = target:isUnderStatus(status, true)
                    override_damage.damage = real_damage *  (self._options.coef_by_status * count)
                end
                override_damage.damage = override_damage.damage * self:getDragonModifier()
            end
            self._attacker:hit(self._skill, target, nil, override_damage, nil, true)
        end
    end
    self:finished()
end

return QSBDecreaseHpByAbsorb