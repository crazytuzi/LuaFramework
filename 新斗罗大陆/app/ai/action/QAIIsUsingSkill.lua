
local QAIAction = import("..base.QAIAction")
local QAIIsUsingSkill = class("QAIIsUsingSkill", QAIAction)

function QAIIsUsingSkill:ctor( options )
    QAIIsUsingSkill.super.ctor(self, options)
    if self._options.check_skill_id ~= nil then
    	self:setDesc("是否在使用魂技" .. self._options.check_skill_id .. "中")
    else
    	self:setDesc("是否在使用魂技中")
    end
end

function QAIIsUsingSkill:_evaluate(args)
    local actor = args.actor

    local result
    local currentSkill = actor:getCurrentSkill()
    if self._options.check_skill_id == nil then
    	if currentSkill ~= nil then
    		result = true
    	else
    		result = false
    	end
    else
    	if currentSkill ~= nil and currentSkill:getId() == self._options.check_skill_id then
    		result = true
    	else
    		result = false
    	end
    end

    local reverse = self._options.reverse_result ~= nil and self._options.reverse_result
    if reverse then result = not result end
    return result
end

return QAIIsUsingSkill