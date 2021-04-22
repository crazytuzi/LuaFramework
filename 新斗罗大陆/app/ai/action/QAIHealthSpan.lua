
local QAIAction = import("..base.QAIAction")
local QAIHealthSpan = class("QAIHealthSpan", QAIAction)

function QAIHealthSpan:ctor( options )
    QAIHealthSpan.super.ctor(self, options)
    self:setDesc("在一定的时血量百分比范围内")
end

function QAIHealthSpan:_evaluate(args)
	local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local options = self:getOptions()
    if options.from == nil then options.from = 1.0 end -- 允许接受nil， 各取上界和下界，1.0 - 0.0，单位是剩余血量比值
    if options.to == nil then options.to = 0.0 end

    if options.from < options.to then -- 允许顺序颠倒，取反即可
        local tmp = options.from
        options.from = options.to
        options.to = tmp
    end

    return true
end

function QAIHealthSpan:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local options = self:getOptions()
    local current_health_ratio = actor:getHp() / actor:getMaxHp() -- 取当前剩余血量比值

    if current_health_ratio <= options.from and current_health_ratio >= options.to then
    	return true
    else
    	return false
    end
end

return QAIHealthSpan