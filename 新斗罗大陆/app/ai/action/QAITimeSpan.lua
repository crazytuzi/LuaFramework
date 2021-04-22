
local QAIAction = import("..base.QAIAction")
local QAITimeSpan = class("QAITimeSpan", QAIAction)

function QAITimeSpan:ctor( options )
    QAITimeSpan.super.ctor(self, options)
    self:setDesc("在一定的时间范围内")
end

function QAITimeSpan:_evaluate(args)
	local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local options = self:getOptions()
    if options.from == nil then options.from = 0 end -- 允许接受nil，分别取上界和下界，999999 - 0
    if options.to == nil then options.to = 999999 end

    return true
end

function QAITimeSpan:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    local options = self:getOptions()
    local current_arena_time = app.battle:getDungeonDuration() - app.battle:getTimeLeft()

    -- 以战斗计时作为判断是否要初始化的条件，战斗计时不受到游戏暂停的影响
    if self._last_arena_time == nil or current_arena_time - self._last_arena_time > 0.5 then
    	-- 接受from和to以{lower, upper}为参数，实际值取lower upper之间的random
	    if type(options.from) == "table" then
	    	local ratio = app.random()
	    	self._from = options.from[1] * ratio + options.from[2] * (1 - ratio)
	    else
	    	self._from = options.from
	    end
	    if type(options.to) == "table" then
	    	local ratio = app.random()
	    	self._to = options.to[1] * ratio + options.to[2] * (1 - ratio)
	    else
	    	self._to = options.to
	    end

	    -- relative表示从from 和 to是从初始化开始算起，而非整场战斗开始，这对于boss不是一开场就上的战斗有必要
    	local relativetime = (options.relative and current_arena_time) or 0
    	self._from = self._from + relativetime
    	self._to = self._to + relativetime

    	if self._from > self._to  then
    		local tmp = self._from
    		self._from = self._to
    		self._to = tmp
    	end
    end

    self._last_arena_time = current_arena_time

    if current_arena_time >= self._from and current_arena_time <= self._to then
    	return true
    else
    	return false
    end
end

return QAITimeSpan