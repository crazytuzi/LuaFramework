local TimeoutJob = class("TimeoutJob")


function TimeoutJob:ctor( jobFunc, timeoutCallback, timeout )
    self._timeoutCallback = timeoutCallback
    self._timeout = timeout
    self._finish = false

    self._timer = GlobalFunc.addTimer(self._timeout, function() 
        self:timeout()

    end)


    jobFunc()

end

function TimeoutJob:_clearTimer()
    if self._timer then
        GlobalFunc.removeTimer(self._timer )
        self._timer = nil
    end
end

function TimeoutJob:timeout()
    self:stop()
    self._timeoutCallback( self._finish)
end


function TimeoutJob:finish()
    self._finish = true
    self:_clearTimer()
end

function TimeoutJob:stop()
    self:_clearTimer()
end

return TimeoutJob