local FrameTaskExt = {}
FrameTaskExt.__index = FrameTaskExt


function FrameTaskExt.New(taskFunc)
    local o = {}
    setmetatable(o, FrameTaskExt)
    o:init(taskFunc)
    return o
end

function FrameTaskExt:start()
    if not self._isRuning and not self._isFinish then
        self._isRuning = true
        self._timer:Start()
    end
end

function FrameTaskExt:stop()
    if self._isRuning then
        self._isRuning = false
        self._timer:Stop()
    end
end

function FrameTaskExt:reset(taskFunc, times)
    self._taskFunc = taskFunc or self._taskFunc
    self._times = times or 0
    self._isFinish = false
    self:stop()
end

function FrameTaskExt:getTimes()
    return self._times
end

function FrameTaskExt:init(taskFunc)
    self._taskFunc = taskFunc
    self._times = 0
    self._isRuning = false
    self._isFinish = false
    self._timer = FrameTimer.New(function() self:onTimer() end, 1, -1)
end

function FrameTaskExt:onTimer()
    self._times = self._times + 1
    local isContinue = false
    self._isFinish, isContinue = self._taskFunc(self._times)
    if self._isFinish then
        isContinue = false
        self._isFinish = true
        self:stop()
    end
    if isContinue then
        self:onTimer()
    end
end

return FrameTaskExt
