-- 延迟
DelayAction = DelayAction or BaseClass(CombatBaseAction)

-- msec 毫秒
function DelayAction:__init(brocastCtx, msec)
    self.msec = msec
end

function DelayAction:Play()
    self:InvokeAndClear(CombatEventType.Start)
    if self.msec == 0 then
        self:OnActionEnd()
    else
        self:InvokeDelay(self.OnActionEnd, self.msec / 1000, self)
    end
end

function DelayAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
