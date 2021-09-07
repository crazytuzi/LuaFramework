-- 消失
ColorChangeAction = ColorChangeAction or BaseClass(CombatBaseAction)

function ColorChangeAction:__init(brocastCtx, fighterId, val)
    self.fighterId = fighterId
    self.fighterCtrl = self:FindFighter(fighterId)

    self.alpha = 1
end

function ColorChangeAction:Play()
    if self.fighterCtrl ~= nil then
        local color = Color(1,0,1,1)
        self.fighterCtrl:SetColor(color)
        self:OnActionEnd()
    else
        self:OnActionEnd()
    end
end

function ColorChangeAction:disapper()
    if self.alpha >= 0 and CombatManager.Instance.isFighting and self.fighterCtrl ~= nil and not BaseUtils.is_null(self.fighterCtrl.transform) and self.fighterCtrl.IsDisappear then
        self.fighterCtrl:SetAlpha(self.alpha)
        self.alpha = self.alpha -0.03
        self:InvokeDelay(self.disapper, 0.02, self)
    else
        self:OnActionEnd()
    end
end

function ColorChangeAction:OnActionEnd()
    if self.fighterCtrl.IsDisappear then
        self.fighterCtrl:SetAlpha(0)
    else
        self.fighterCtrl:SetAlpha(1)
    end
    self:InvokeAndClear(CombatEventType.End)
end


