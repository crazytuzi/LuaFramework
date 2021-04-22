--[[
    根据某个值来添加护盾
    coefficient                         增幅系数
    buff_id                             存储伤害的buff id
    save_damage_percent                 取存储治疗量的百分比
    is_add_skill_physical_damage        是否加上技能的物理伤害
    is_add_skill_magic_damage           是否加上技能的魔法伤害
    absorb_buff_id                      存储护盾的buff id
    hp_percent                          根据生命百分比增加护盾
    single_max_percent                  单体最大分摊百分比
    absorb_on_every_target              为true时计算护盾值时不除以目标数量
    targets                             来自技能脚本传递的目标
--]]
local QSBNode = import("..QSBNode")
local QSBAddAbsorb = class("QSBAddAbsorb", QSBNode)

function QSBAddAbsorb:_execute(dt)    
    local buff_id = self._options.buff_id
    

    local coefficient = self._options.coefficient or 1
    local targets = {self._attacker}
    if self._options.target_enemy then
        targets = app.battle:getMyEnemies(self._attacker)
    end
    if self._options.multiple_target_with_skill then
        if self._skill:getRangeType() == self._skill.MULTIPLE then
            targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target)
        end
    end
    if self._options.targets then
        targets = self._options.targets
    elseif self._options.selectTargets then
        targets = self._options.selectTargets
    end
    if self._options.is_target then
        targets = {self._target}
    end

    if targets and #targets > 0 then
        if self._options.just_hero then
            local ghostIndexs = {}
            for i, target in ipairs(targets) do
                if target:isGhost() then
                    table.insert(ghostIndexs, i)
                end
            end
            for _, index in ipairs(ghostIndexs) do
                table.remove(targets, index)
            end
        end

        local limit = 1
        if self._options.single_max_percent then
            limit = self._options.single_max_percent
        end
        
        for i,target in ipairs(targets) do
            local totalAbsorb = 0
            for i, buff in ipairs(self._attacker:getBuffs()) do
                if buff:getId() == buff_id and buff:isSaveDamage() then
                    totalAbsorb = totalAbsorb + buff:getSavedDamage() * self._options.save_damage_percent
                end
            end
            if self._options.hp_percent and type(self._options.hp_percent) == "number" then
                local maxHP =  self._options.absorb_on_every_target and target:getMaxHp() or self._attacker:getMaxHp()
                totalAbsorb = totalAbsorb + maxHP * self._options.hp_percent
            end
            if self._options.is_add_skill_physical_damage then
                totalAbsorb = totalAbsorb + self._skill:getPhysicalDamage()
            end
            if self._options.is_add_skill_magic_damage then
                totalAbsorb = totalAbsorb + self._skill:getMagicDamage()
            end
            local real_absorb = 0
            if self._options.absorb_on_every_target then
                real_absorb = math.min((totalAbsorb * coefficient), limit * totalAbsorb)
            else
                real_absorb = math.min((totalAbsorb * coefficient)/(#targets), limit * totalAbsorb)
            end
            local buff = target:applyBuff(self._options.absorb_buff_id, self._attacker, self._skill)
            if buff then
                local old_value = buff:getAbsorbDamageValue()
                local newValue = buff:setAbsorbDamageValue(old_value + real_absorb, true)
                target:dispatchAbsorbChangeEvent(newValue - old_value)
            end
        end
    end
    self:finished()
end

return QSBAddAbsorb
