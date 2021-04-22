
local QAIAction = import("..base.QAIAction")
local QAIAttackByHitlog = class("QAIAttackByHitlog", QAIAction)

function QAIAttackByHitlog:ctor( options )
    QAIAttackByHitlog.super.ctor(self, options)
    self:setDesc("根据仇恨列表选择一个敌人攻击")
end

function QAIAttackByHitlog:_evaluate(args)
    local actor = args.actor
    if actor == nil or actor:isDead() == true then
        return false
    end

    if actor:getHitLog():isEmpty() == true then
        return false
    end

    return true
end

function QAIAttackByHitlog:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local target = actor:getHitLog():getMaxHatred()
    if target == nil then
        return false
    end

    actor:setTarget(target)

    return true
end

return QAIAttackByHitlog