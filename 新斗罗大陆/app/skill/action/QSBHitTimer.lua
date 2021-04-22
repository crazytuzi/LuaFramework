--[[
    Class name QSBHitTimer
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBHitTimer = class("QSBHitTimer", QSBAction)

function QSBHitTimer:ctor(director, attacker, target, skill, options)
    QSBHitTimer.super.ctor(self, director, attacker, target, skill, options)
    self._duration = self._options.duration_time or self._skill:getAdditionValueWithKey("duration_time")
    self._interval = self._options.interval_time or self._skill:getAdditionValueWithKey("interval_time")
end

function QSBHitTimer:_execute(dt)
    if self._startTime == nil then
        self._startTime = app.battle:getTime()
        self._currentTime = self._startTime
        self._lastTriggerTime = self._startTime
    else
        self._currentTime = self._currentTime + dt
    end

    if self._currentTime - self._lastTriggerTime >= self._interval then
        self:_onHitTime()
        self._lastTriggerTime = self._lastTriggerTime + self._interval
    end

    if self._currentTime - self._startTime >= self._duration then
        self:finished()
    end
end

function QSBHitTimer:_onHitTime()
    if self._attacker ~= nil then
        self._attacker:onHit(self._skill, self._target, nil, self._options.delay_per_hit, nil, nil, self._options.delay_all)
    end
end

return QSBHitTimer