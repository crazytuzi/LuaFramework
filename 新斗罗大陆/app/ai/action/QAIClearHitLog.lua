
local QAIAction = import("..base.QAIAction")
local QAIClearHitlog = class("QAIClearHitlog", QAIAction)

function QAIClearHitlog:ctor( options )
    QAIClearHitlog.super.ctor(self, options)
    self:setDesc("清空当前的仇恨列表")
end

function QAIClearHitlog:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    actor:getHitLog():clearAll()

    actor:stopMoving()
    actor:setTarget(nil)

    return true
end

return QAIClearHitlog