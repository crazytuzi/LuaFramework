
local QAIAction = import("..base.QAIAction")
local QAIIsOutOfDistance = class("QAIIsOutOfDistance", QAIAction)

function QAIIsOutOfDistance:ctor( options )
    QAIIsOutOfDistance.super.ctor(self, options)
    self:setDesc("目标是否在距离之外")
end

function QAIIsOutOfDistance:_evaluate(args)
	local actor = args.actor
	local target = actor:getTarget()
	if target == nil then
		return false
	end
	local distance = self._options.distance or 0
	return q.distOf2Points(actor:getPosition(), target:getPosition()) > distance
end

return QAIIsOutOfDistance