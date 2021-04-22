
local QAIAction = import("..base.QAIAction")
local QAIAttackClosestEnemyWithoutMove = class("QAIAttackClosestEnemyWithoutMove", QAIAction)

function QAIAttackClosestEnemyWithoutMove:ctor( options )
    QAIAttackClosestEnemyWithoutMove.super.ctor(self, options)
    self:setDesc("攻击最近且不需要移动的敌人")
end

function QAIAttackClosestEnemyWithoutMove:_execute(args)
    local actor = args.actor

    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    if actor:getTarget() ~= nil and not actor:getTarget():isDead() then
        -- 如果当前已经选择了敌人，则继续保持
        -- assert(app.grid:hasActor(actor:getTarget()) == true)
        return true
    end

    local enemies = app.battle:getMyEnemies(actor)

    local target_list = actor:getClosestActors(enemies)

    if target_list == nil or #target_list == 0 then
        return false
    end

    local talentSkill = actor:getTalentSkill()
    if talentSkill == nil then return false end

    -- 检查是否不需要移动就都能达到
    local selected_target = nil
    for _, target in ipairs(target_list) do
        local actorWidth = actor:getRect().size.width / 2
        local targetWidth = target:getRect().size.width / 2
        local _, skillRange = talentSkill:getSkillRange(false)

        local dx = math.abs(actor:getPosition().x - target:getPosition().x)
        local dy = math.abs(actor:getPosition().y - target:getPosition().y)

        if dx - actorWidth - targetWidth < skillRange and dy < skillRange * 0.6 then
            if not self:getOptions().current_target or target == actor:getTarget() then
                selected_target = target
            end
        end
    end

    if selected_target ~= nil then
        actor:setTarget(selected_target)
        return true
    else
        return false
    end
end

return QAIAttackClosestEnemyWithoutMove