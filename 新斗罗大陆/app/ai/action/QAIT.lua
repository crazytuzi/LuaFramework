
local QAIAction = import("..base.QAIAction")
local QAIT = class("QAIT", QAIAction)

function QAIT:ctor( options )
    QAIT.super.ctor(self, options)
    self:setDesc("")
end

function QAIT:_evaluate(args)
    if not args.actor or not args.actor:isForceAuto() then
        return false
    end

    return true
end

function QAIT:_charge(actor)
    local chargeSkill = self._chargeSkill

    if chargeSkill == nil then
        for _, skill in pairs(actor:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_ATTACK then
                chargeSkill = skill
                break
            end
        end

        if chargeSkill == nil then
            return
        else
            self._chargeSkill = chargeSkill
        end
    end

    if not actor:canAttack(chargeSkill) then
        return false
    end

    if chargeSkill:isNeedATarget() then
        local target = actor:getTarget()
        if target == nil or target:isDead() then
            return false
        elseif chargeSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
            return false
        end
    end

    actor:attack(chargeSkill, true)

    return true
end

function QAIT:_taunt(actor)
    local manualSkill = actor:getManualSkills()[next(actor:getManualSkills())]
    if manualSkill == nil then
        return false
    end

    -- 检查技能是否能够使用
    if not actor:canAttack(manualSkill) then
        return false
    end

    local skill = manualSkill
    if skill:getRangeType() == skill.MULTIPLE and skill:isNeedATarget() == false then
        local targets = actor:getMultipleTargetWithSkill(skill)
        if #targets < 1 then
            return false
        end
    end

    -- 寻找是否有敌人攻击伙伴
    -- local teammates = app.battle:getMyTeammates(actor, false)
    -- local enemies = app.battle:getMyEnemies(actor)
    -- local found = {}
    -- for _, enemy in ipairs(enemies) do
    --     for _, mate in ipairs(teammates) do
    --         if enemy:getTarget() == mate then
    --             table.insert(found, enemy)
    --             break
    --         end
    --     end
    -- end
    -- if #found == 0 then
    --     return false
    -- elseif #found == 1 and found[1]:isRanged() == false then
    --     actor:setTarget(found[1])
    --     return false
    -- else
    --     actor:setTarget(found[1])
    -- end

    -- if manualSkill:isNeedATarget() then
    --     local target = actor:getTarget()
    --     if target == nil or target:isDead() then
    --         return #found >= 1
    --     elseif manualSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
    --         return #found >= 1
    --     end
    -- end

    actor:attack(manualSkill, true)

    return true
end

function QAIT:_execute(args)
    local actor = args.actor

    -- if self:_charge(actor) then
    --     return true
    -- end

    if self:_taunt(actor) then
        return true
    end

    return false
end

return QAIT