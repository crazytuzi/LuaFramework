
local QAIAction = import("..base.QAIAction")
local QAITimer = class("QAITimer", QAIAction)

function QAITimer:ctor( options )
    QAITimer.super.ctor(self, options)
    self._lastTime = self:_getTime()
    self._isInFirstInterval = (self._options.first_interval ~= nil)
    self._maxHit = self._options.max_hit
    self._hitCount = 0
    self:setDesc("计时器")
end

function QAITimer:_execute(args)
    if self._lastTimeFrameSkip == nil and self._options.allow_frameskip == true then
        self._lastTimeFrameSkip = self:_getTime()
        self._lastTime = self._lastTimeFrameSkip
    end

    local currentTime = self:_getTime()
    
    local interval = self._options.interval or 0
    if self._isInFirstInterval == true then
        interval = self._options.first_interval
    end

    if currentTime - self._lastTime >= interval then
        if self._options.allow_frameskip == true then
            self._lastTime = currentTime
        else
            self._lastTime = self._lastTime + interval
        end

        if self._isInFirstInterval == true then
            self._isInFirstInterval = false
        end

        if self._maxHit then
            if self._hitCount >= self._maxHit then
                return false
            else
                self._hitCount = self._hitCount + 1
            end
        end

        return true
    end

    return false
end

function QAITimer:_getTime()
    return app.battle:getDungeonDuration() - app.battle:getTimeLeft()
end

return QAITimer