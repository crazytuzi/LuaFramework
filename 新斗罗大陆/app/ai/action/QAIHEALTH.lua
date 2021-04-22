
local QAIAction = import("..base.QAIAction")
local QAIHEALTH = class("QAIHEALTH", QAIAction)

function QAIHEALTH:ctor( options )
    QAIHEALTH.super.ctor(self, options)
    self:setDesc("")

    self:createRegulator(5)
end

function QAIHEALTH:_evaluate(args)
    if not args.actor or not args.actor:isForceAuto() then
        return false
    end

    return true
end

function QAIHEALTH:_blinkOrCharge(actor)
    if self._blinkOrChargeSkill == false then
        return
    end

    local blinkOrChargeSkill = self._blinkOrChargeSkill

    if blinkOrChargeSkill == nil then
        for _, skill in pairs(actor:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK then
                blinkOrChargeSkill = skill
                break
            end
        end

        if blinkOrChargeSkill == nil then
            self._blinkOrChargeSkill = false
            return
        end
    end

    if not actor:canAttack(blinkOrChargeSkill) then
        return false
    end

    --远程闪现 近战冲锋
    if actor:isRanged() then
        if blinkOrChargeSkill:isExtraConditionMet() == false then
            return false
        end

        local enemies = app.battle:getMyEnemies(actor)
        local beingattacked = false
        for _, enemy in ipairs(enemies) do
            if not enemy:isRanged() then
                if enemy:isAttacking() and enemy:getCurrentSkillTarget() == actor then
                    beingattacked = true
                    break
                end
            end
        end

        if beingattacked then
            local positions = {}
            for _, enemy in ipairs(enemies) do
                if not enemy:isRanged() then
                    local _, gridPos = app.grid:_toGridPos(enemy:getPosition().x, enemy:getPosition().y)
                    table.insert(positions, gridPos)
                end
            end
            local nx, ny = app.grid._nx, app.grid._ny
            local forbid_length = math.ceil(ny / 3)
            local dist_max = 3 / 6 * nx
            local weights = {}
            local index = 1
            for i = 1, nx do
                for j = 1, ny do
                    weights[index] = 0

                    if (i < forbid_length and j > ny - forbid_length)
                        or (i > nx - forbid_length and j > ny - forbid_length)
                        or (i > nx - forbid_length and j < forbid_length) then
                        weights[index] = -999999
                    end

                    index = index + 1
                end
            end
            for _, pos in ipairs(positions) do
                local index = 1
                for i = 1, nx do
                    for j = 1, ny do
                        weights[index] = weights[index] + math.min(q.distOf2Points(pos, {x = i, y = j}), dist_max)
                        index = index + 1
                    end
                end
            end
            local weight = 0
            local candidates = {}
            local index = 1
            for i = 1, nx do
                for j = 1, ny do
                    if weight > weights[index] then
                    elseif weight == weights[index] then
                        table.insert(candidates, {x = i, y = j})
                    else
                        weight = weights[index]
                        candidates = {}
                        table.insert(candidates, {x = i, y = j})
                    end
                    index = index + 1
                end
            end
            if #candidates > 0 then
                local screenPos = app.grid:_toScreenPos(candidates[app.random(1, #candidates)])
                actor._dragPosition = screenPos
                actor._targetPosition = screenPos
                actor:attack(blinkOrChargeSkill)
                return true
            end
        end
    else
        if blinkOrChargeSkill:isNeedATarget() then
            local target = actor:getTarget()
            if target == nil or target:isDead() then
                return false
            elseif blinkOrChargeSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
                return false
            end
        end
        actor:attack(blinkOrChargeSkill, true)
        return true
    end

end

function QAIHEALTH:_execute(args)
    local actor = args.actor

    if actor:isManualMode() then
        return false
    end

    if actor:isForceAuto() then
        if not (((app.battle:isInSunwell() and app.battle:isSunwellAllowControl()) or (app.battle:isInArena() and app.battle:isArenaAllowControl())) and actor:getType() == ACTOR_TYPES.HERO) then
            if self:_blinkOrCharge(actor) then
                return true
            end
        end
    end


    local manualSkill = actor:getManualSkills()[next(actor:getManualSkills())]
    if manualSkill == nil then
        return false
    end

    -- 检查技能是否能够使用
    if not actor:canAttack(manualSkill) then
        return false
    end

    if manualSkill:isNeedATarget() then
        local target = actor:getTarget()
        if target == nil or target:isDead() then
            return false
        elseif manualSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
            return false
        end
    end

    local skill = manualSkill
    if skill:getRangeType() == skill.MULTIPLE and skill:isNeedATarget() == false then
        local targets = actor:getMultipleTargetWithSkill(skill)
        if #targets < 1 then
            return false
        end
    end

    -- 检查血量，有人血量
    local teammates = app.battle:getMyTeammates(actor, true)
    local mostInjured = nil
    local mostInjuredPercent = 2.0
    local averageInjuredPercent = 0.0
    local healerHpCondition = skill:getHealerHpCondition()
    for _, mate in ipairs(teammates) do
        local injuredPercent = mate:getHp() / mate:getMaxHp()
        averageInjuredPercent = averageInjuredPercent + injuredPercent
        if injuredPercent <= healerHpCondition and not mate:isLockHp() then
            if mostInjuredPercent > injuredPercent then
                mostInjured = mate
                mostInjuredPercent = injuredPercent
            end
        end
    end
    averageInjuredPercent  = averageInjuredPercent / #teammates 

    if skill:getRangeType() ~= skill.MULTIPLE then
        if mostInjured == nil then
            return false
        end
        actor:setTarget(mostInjured)
    else
        if mostInjured == nil and averageInjuredPercent * #teammates > (#teammates - 0.5) then
            return false
        end
    end

    local pos = actor:getPosition()
    if app.grid:_toGridPos(pos.x, pos.y) then
        return false
    end

    actor:attack(manualSkill, true)

    return true
end

return QAIHEALTH