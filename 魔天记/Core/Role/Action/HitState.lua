require "Core.Role.Action.AbsState";

HitState = class("HitState", AbsState)
local alpha = 0.3
local duration = 0.2

function HitState:SetEnable(val)
	self.enable = val
    if self.enable then
        self:_StartTimer(duration, 1)
    else
        self:_StopTimer()
    end
end
function HitState:_OnStartHandler()
    if(self._controller and self._controller.gameObject) then
        UIUtil.SetShaderFloat(self._controller.gameObject, "_BlinkTime", alpha)
    end
end
function HitState:_OnStopHandler()
    if(self._controller and self._controller.gameObject) then
        UIUtil.SetShaderFloat(self._controller.gameObject, "_BlinkTime", 0)
    end
end
