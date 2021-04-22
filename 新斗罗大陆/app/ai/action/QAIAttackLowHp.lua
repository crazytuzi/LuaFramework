
local QAIAction = import("..base.QAIAction")
local QAIAttackLowHp = class("QAIAttackLowHp", QAIAction)

function QAIAttackLowHp:ctor( options )
    QAIAttackLowHp.super.ctor(self, options)
    self:setDesc("攻击血量最低的敌人")
end

function QAIAttackLowHp:_execute(args)
    local actor = args.actor
    local target = actor:getTarget()
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    if target and not target:isDead() and target:isMarked() then
        return false
    end

    local enemies = app.battle:getMyEnemies(actor)

    if enemies == nil then 
        return nil 
    end

    local hpPer = 1.1
    local target = nil
    for i, other in ipairs(enemies) do
        if not other:isDead() then
            local otherHpPer = other:getHp() / other:getMaxHp()
            if otherHpPer < hpPer then
                hpPer = otherHpPer
                target = other
            end
        end
    end

    if target == nil then
        return false
    end

    actor:setTarget(target)

    return true
end

return QAIAttackLowHp