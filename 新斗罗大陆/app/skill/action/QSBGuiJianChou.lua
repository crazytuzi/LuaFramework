--[[
    Class name QSBGuiJianChou
    Create by wanghai 
    buff_id:存储治疗量的buff
    damage_percent:造成存储量X%的伤害
    limit_percent:不超过攻击力Y%
    recover_hp_limit_percent:伤害Z%的伤势
    percent:W%
    trigger_skill_id:
    skill_level:
    base_attack_percent:基础伤害
--]]
local QSBAction = import(".QSBAction")
local QSBGuiJianChou = class("QSBGuiJianChou", QSBAction)

local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

function QSBGuiJianChou:_execute(dt)
    local buffId = self._options.buff_id
    local actor = self._skill:getDamager() or self._attacker
    local damagePercent = self._options.damage_percent
    local limitPercent = self._options.limit_percent
    local triggerSkillId = self._options.trigger_skill_id
    local percent = self._options.percent
    local skillLevel = self._options.skill_level or 1
    local recoverHpLimitPercent = self._options.recover_hp_limit_percent
    local baseAttackPercent = self._options.base_attack_percent or 0
    local clear_save_treat = self._options.clear_save_treat == nil and true or false

    local target = self._attacker

    local buff = target:getBuffByID(buffId)
    if buff ~= nil and (buff:isSaveTreat() and buff:getSaveTreatTarget() == "attackee") then
        local value = buff:getSaveTreat()
        local damage = damagePercent * value
        if clear_save_treat then
            buff:saveTreat(-value)
        end

        if damage < target:getMaxAttack() * limitPercent * percent then
            local triggerSkill = actor._skills[triggerSkillId]
            if triggerSkill == nil then
                triggerSkill = QSkill.new(triggerSkillId, db:getSkillByID(triggerSkillId), actor, skillLevel)
                actor._skills[triggerSkillId] = triggerSkill
            end
            if triggerSkill:isReadyAndConditionMet() then
                actor:triggerAttack(triggerSkill, target)
            end
        end

        damage = math.min(damage, actor:getMaxAttack() * limitPercent) + actor:getMaxAttack() * baseAttackPercent

        self._skill:setInheritedDamage(damage)
        damage = actor:getCalcDamage(actor, self._skill, target)

        target:setRecoverHpLimit(damage * recoverHpLimitPercent, self._skill:getDepressRecoverHpLimit() * target:getMaxHp())
        local _, value, absorb = target:decreaseHp(damage, actor, self._skill, false, false)
        if absorb > 0 then
            local absorb_tip = "吸收 "
            target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                isHero = target:getType() ~= ACTOR_TYPES.NPC, 
                isDodge = false, 
                isBlock = false, 
                isCritical = false, 
                isTreat = false,
                isAbsorb = true, 
                number = absorb
            }})
        end
        if value > 0 then
            local tip = ""
            target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = tip .. tostring(math.floor(value)),
                rawTip = {
                    isHero = target:getType() ~= ACTOR_TYPES.NPC, 
                    isDodge = false, 
                    isBlock = false, 
                    isCritical = false, 
                    isTreat = false, 
                    number = value
                }})
        end
    end

    self:finished()
end

return QSBGuiJianChou
