local QSBAction = import(".QSBAction")
local QSBSSZhuzhuQingRangeOffset = class("QSBSSZhuzhuQingRangeOffset", QSBAction)

function QSBSSZhuzhuQingRangeOffset:ctor(director, attacker, target, skill, options)
    QSBSSZhuzhuQingRangeOffset.super.ctor(self, director, attacker, target, skill, options)
    self._speed = self._options.speed or 500
    self._duration = self._options.duration or 1
    self._offset = self._options.offset
    if self._offset == nil then self._offset = {x = 0, y = 0} end
end

function QSBSSZhuzhuQingRangeOffset:_execute(dt)
    if self._start_time == nil then
        self._start_time = 0
        return
    end
    if self._start_time >= self._duration then
        self:finished()
        return
    end
    self._start_time = self._start_time + dt
    app.battle:setFromMap(self._attacker, "SS_ZHUZHUQING_RANGE_OFFSET", {x = self._start_time * self._speed + self._offset.x, y = 0 + self._offset.y})
end


return QSBSSZhuzhuQingRangeOffset
