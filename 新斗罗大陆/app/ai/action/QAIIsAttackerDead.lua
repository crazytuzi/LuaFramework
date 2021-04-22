
local QAIAction = import("..base.QAIAction")
local QAIIsAttackerDead = class("QAIIsAttackerDead", QAIAction)

function QAIIsAttackerDead:ctor( options )
    QAIIsAttackerDead.super.ctor(self, options)
    self:setDesc("是否之前的攻击我的对象已经死亡")
end

function QAIIsAttackerDead:_evaluate(args)
    local attackee = args.actor:getLastAttacker()
    return not not (attackee and attackee:isDead())
end

return QAIIsAttackerDead