DramaTimeScale = class("DramaTimeScale", DramaAbs);

function DramaTimeScale:_Init()
    self._lastScale = Time.timeScale
end

function DramaTimeScale:_Begin(fixed)
    if fixed then return end
    local p1 = self.config[DramaAbs.EvenParam1]
    Time.timeScale = tonumber( p1[1])
end

function DramaTimeScale:_End()
    Time.timeScale = self._lastScale
end

function DramaTimeScale:_Dispose()
    if self._lastScale and Time.timeScale ~= self._lastScale then Time.timeScale = self._lastScale end
end