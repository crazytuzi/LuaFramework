local ServerTime = require "Zeus.Logic.ServerTime"

local CDLabelExt = {}
CDLabelExt.__index = CDLabelExt


function CDLabelExt.New(label, cd, format, callback,refshcount)
    local o = {}
    setmetatable(o, CDLabelExt)
    o:_init(label, cd, format, callback,refshcount)
    return o
end

function CDLabelExt:start()
    if self._started then return end
    self._started = true
    self._timer:Start()
    self:_onUpdate()
end


function CDLabelExt:setEndTime(time)
    self._begenTime = ServerTime.GetServerUnixTime()
    self._cd = time - ServerTime.GetServerUnixTime()
    if self._cd < 0 then self._cd = 0 end
    return self._cd
end


function CDLabelExt:setCD(time)
    self._begenTime = ServerTime.GetServerUnixTime()
    self._cd = time
end

function CDLabelExt:stop()
    if not self._started then return end
    self._started = false
    self._timer:Stop()
end




function CDLabelExt:_init(label, cd, format, callback,refshcount)
    self._label = label
    self._cd = cd
    self._format = format
    self._callback = callback
    self._begenTime = ServerTime.GetServerUnixTime()
    self._started = false
    refshcount = refshcount or 0.03
    self._timer = Timer.New(function() self:_onUpdate() end, refshcount, -1)
end

function CDLabelExt:_onUpdate()
    local serTime = ServerTime.GetServerUnixTime()
    if serTime < self._begenTime then
        return
    end

    local cd = self._cd - (serTime - self._begenTime)
    if cd <= 0 then
        cd = 0
        if self._callback then
            self._callback()
        end
        self:stop()
    end
    local text = self._format(cd, self._label)
    if type(text) == "string" then
        self._label.Text = text
    end
end

return CDLabelExt
