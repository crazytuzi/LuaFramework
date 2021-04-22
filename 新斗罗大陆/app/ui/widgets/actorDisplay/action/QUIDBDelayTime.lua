
local QUIDBAction = import(".QUIDBAction")
local QUIDBDelayTime = class("QUIDBDelayTime", QUIDBAction)

function QUIDBDelayTime:_execute(dt)
	if self._isStarting == true then
		return
	end

	local delay = self._options.delay_time or 0
    if delay == 0 and self._options.delay_frame ~= nil then
        delay = self._options.delay_frame / 30.0
    end

    self._handler = scheduler.performWithDelayGlobal(function()
        self:finished()
    end, delay)
end

function QUIDBDelayTime:_onCancel()
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
	end
end

return QUIDBDelayTime