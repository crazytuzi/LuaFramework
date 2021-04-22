
local QAIAction = import("..base.QAIAction")
local QAIIgnoreHitLog = class("QAIIgnoreHitLog", QAIAction)

function QAIIgnoreHitLog:ctor( options )
    QAIIgnoreHitLog.super.ctor(self, options)
    self:setDesc("使actor忽略仇恨列表，可以保存当前仇恨列表")
end

function QAIIgnoreHitLog:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    -- actor忽略仇恨列表，并且锁定当前目标。所以这个action一般跟随一个QAIAttackXXX类action使用才会达到一定的效果
    actor:lockTarget()

    local current_time = app.battle:getDungeonDuration() - app.battle:getTimeLeft()
    if self:getOptions().clear == true then
    	actor:getHitLog():clearAll()
    else
    	if (self._lastTime == nil or current_time - self._lastTime > 0.5) and self:getOptions().store == true then
    		-- 保存当前的hit log
    		actor:getHitLog():store()
    	end
 	end

 	self._lastTime = current_time
    return true
end

return QAIIgnoreHitLog