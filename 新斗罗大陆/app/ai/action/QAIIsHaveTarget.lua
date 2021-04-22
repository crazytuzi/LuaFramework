
local QAIAction = import("..base.QAIAction")
local QAIIsHaveTarget = class("QAIIsHaveTarget", QAIAction)

function QAIIsHaveTarget:ctor( options )
    QAIIsHaveTarget.super.ctor(self, options)
    self:setDesc("是否有攻击对象")
end

function QAIIsHaveTarget:_evaluate(args)
    local actor = args.actor
    if actor ~= nil and actor:getTarget() ~= nil and actor:getTarget():isDead() == false then
        return true
    end

    return false
end

return QAIIsHaveTarget