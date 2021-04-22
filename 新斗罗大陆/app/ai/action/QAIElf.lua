
local QAIAction = import("..base.QAIAction")
local QAIElf = class("QAIElf", QAIAction)

function QAIElf:ctor( options )
    QAIElf.super.ctor(self, options)
    self:setDesc("")

    self:createRegulator(5)
end

function QAIElf:_evaluate(args)
    if not args.actor then
        return false
    end

    return true
end

function QAIElf:_dpsAttack(actor)
    if app.battle and app.battle:isPausedBetweenWave() then
        return false
    end

    local manualSkill = actor:getFirstManualSkill()
    if manualSkill == nil then
        return false
    end

    -- 检查自动释放的连击点数
    if manualSkill:isNeedComboPoints() and actor:getComboPoints() < actor:getComboPointsAuto() then
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
        elseif manualSkill:getRangeType() == manualSkill.SINGLE and manualSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
            return false
        end
    end

    local skill = manualSkill
    if skill:getRangeType() == skill.MULTIPLE and skill:isNeedATarget() == false then
        local targets = actor:getMultipleTargetWithSkill(skill)
        local count = 0
        for _, target in ipairs(targets) do
            local pos = target:getPosition()
            if pos.x > BATTLE_AREA.left and pos.x < BATTLE_AREA.right then
                count = count + 1
            end
        end
        if count < 1 then
            return false
        end
    end

    local range = app.grid:getRangeArea()
    local pos = actor:getPosition()
    if pos.x < range.left or pos.x > range.right then
        return false
    end

    -- 检查斩杀线
    local execute_percent = skill:getExecutePercent()
    if execute_percent and execute_percent > 0 then
        local target = actor:getTarget()
        if target and not target:isBoss() then
            local current_percent = target:getHp() / target:getMaxHp()
            if current_percent > execute_percent then
                return false
            end
        end
    end

    actor:attack(manualSkill, true)

    return true
end

function QAIElf:_healthAttack(actor)
    local manualSkill = actor:getFirstManualSkill()
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
        if injuredPercent <= healerHpCondition then
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

    local range = app.grid:getRangeArea()
    local pos = actor:getPosition()
    if pos.x < range.left or pos.x > range.right or pos.y < range.bottom or pos.y > range.top then
        return false
    end

    actor:attack(manualSkill, true)

    return true
end

function QAIElf:_selectTarget(actor)
    if actor:isHealth() then
        local teammates = app.battle:getMyTeammates(actor, false)
        table.sort(teammates, function(a, b) return a:getHp()/a:getMaxHp() < b:getHp()/b:getMaxHp() end)
        actor:setTarget(teammates[1])
    end
end

function QAIElf:_attack(actor)
    if not actor:isHealth() then
        return self:_dpsAttack(actor)
    else
        return self:_healthAttack(actor)
    end
end

function QAIElf:_execute(args)
    if not self._regulator() then
        return false
    end

    local actor = args.actor

    self:_selectTarget(actor)

    if not args.actor:isForceAuto() then
        return false
    end

    if self:_attack(actor) then
        return true
    end

    return false
end


return QAIElf