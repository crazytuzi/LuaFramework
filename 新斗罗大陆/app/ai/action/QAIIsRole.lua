local QAIAction = import("..base.QAIAction")
local QAIIsRole = class("QAIIsRole", QAIAction)

function QAIIsRole:ctor( options )
    QAIIsRole.super.ctor(self, options)
    self:setDesc("判断自己或目标魂师的职业是否在选定的职业中,或NPC是否是大小BOSS.")
end

function QAIIsRole:_execute( args )
    local role = self._options.role --输入table格式,支持“dps","t""health","boss","elite_boss"
    local reverse_result = self._options.reverse_result
    local target
    local result
	if self._options.is_target then
		target = args.actor:getTarget()
	else
		target = args.actor
	end
    if target and role then
    	for i,v in ipairs(role) do
    		if v == "elite_boss" then
	    		result = target:isEliteBoss()
		    elseif v == "boss" then
		    	result = target:isBoss()
		    else
		    	result = v == target:getTalentFunc()
		    end
		    if result == true then
		    	break
		    end
    	end
    end

	result = reverse_result and result == false or result --nil要返回false 所以用==false而不是用not

    return result
end

return QAIIsRole