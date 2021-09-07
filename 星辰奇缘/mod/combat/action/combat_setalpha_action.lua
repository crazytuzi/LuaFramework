-- 透明处理
SetAlphaAction = SetAlphaAction or BaseClass(CombatBaseAction)

function SetAlphaAction:__init(brocastCtx, fighterId, alpha)
    self.controller = self:FindFighter(fighterId)
    self.alpha = alpha
end

function SetAlphaAction:Play()
    self.controller:SetAlpha(self.alpha)
    self:InvokeDelay(self.OnActionEnd, 0.02, self)
end

function SetAlphaAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
