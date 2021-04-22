
local QAIAction = import("..base.QAIAction")
local QAITrackTarget = class("QAITrackTarget", QAIAction)

function QAITrackTarget:ctor( options )
    QAITrackTarget.super.ctor(self, options)
    self:setDesc("显示当前目标的连线")
end

function QAITrackTarget:_evaluate(args)
    local actor = args.actor
    local target = actor:getTarget()
    local disable = self:getOptions().disable
    if actor == nil or actor:isDead() or (disable ~= true and (target == nil or target:isDead())) then
        return false
    end

    if disable then
    	actor:EndOneTrack()
    else
    	actor:StartOneTrack(target, self:getOptions().interval, self._options.always)
    end
    return true
end

return QAITrackTarget