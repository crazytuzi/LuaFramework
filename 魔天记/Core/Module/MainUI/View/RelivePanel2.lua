require "Core.Module.Common.Panel"

RelivePanel2 = class("RelivePanel2", Panel);
 function RelivePanel2:IsPopup()
    return false
 end

function RelivePanel2:New()
    self = { };
    setmetatable(self, { __index = RelivePanel2 });
    return self
end


function RelivePanel2:_Init()
    self:_InitReference();
end

function RelivePanel2:_InitReference()
    self._timer = Timer.New( function() RelivePanel1._OnTimerHandler(self) end, 1, -1, false);
    self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime")
end
 
function RelivePanel2:_Dispose()
    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end

end 

function RelivePanel2:UpdateRelivePanel(data, config)
    self._time = config.time
    if (data) then
        self._txtTime.text = tostring(self._time)
    end
    self._timer:Stop()
    self._timer:Start();
end

function RelivePanel2:_OnTimerHandler()
    self._time = self._time - 1
    self._txtTime.text = tostring(self._time)
    if (self._time == 0) then
        self._timer:Stop()
        MainUIProxy.SendRelive(0)
    end
end