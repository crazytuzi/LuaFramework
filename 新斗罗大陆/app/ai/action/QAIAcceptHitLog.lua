
local QAIAction = import("..base.QAIAction")
local QAIAcceptHitLog = class("QAIAcceptHitLog", QAIAction)

function QAIAcceptHitLog:ctor( options )
    QAIAcceptHitLog.super.ctor(self, options)
    self:setDesc("使得actor受到仇恨列表影响，可以恢复之前保存的仇恨列表。")
end

function QAIAcceptHitLog:_execute(args)
    local actor = args.actor
    if actor == nil then
        assert(false, "invalid args, actor is nil.")
        return false
    end

    -- actor接受仇恨列表，取消锁定当前目标。这个action配合QAIIgnoreHitLog使用.
    actor:unlockTarget()

    if (self._lastTime == nil or app.battle:getTime() - self._lastTime > 0.5) and self:getOptions().restore == true and actor:getHitLog():hasStoredHits() then
        -- 恢复hit log
        actor:getHitLog():restore()
    end

    self._lastTime = app.battle:getTime()
    return true
end

return QAIAcceptHitLog