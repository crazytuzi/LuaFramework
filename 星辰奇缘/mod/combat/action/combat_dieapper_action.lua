-- 消失
DisapperAction = DisapperAction or BaseClass(CombatBaseAction)

function DisapperAction:__init(brocastCtx, fighterId)
    self.fighterId = fighterId
    self.fighterCtrl = self:FindFighter(fighterId)

    self.alpha = 1
end

function DisapperAction:Play()
    self.fighterCtrl:DestroyTalkBubble()
    self.fighterCtrl:HideBloodBar()
    self.fighterCtrl:HideCommand()
    self.fighterCtrl:HideNameText()
    self.fighterCtrl:HideBuffPanel()
    self.fighterCtrl:ShowShadow(false)
    self.fighterCtrl:SetDisappear(true)
    if self.fighterCtrl.fighterData ~= nil then
        self.fighterCtrl.fighterData.is_die = 1
    end
    self:disapper()
end

function DisapperAction:disapper()
    if self.alpha >= 0 and CombatManager.Instance.isFighting and self.fighterCtrl ~= nil and not BaseUtils.is_null(self.fighterCtrl.transform) and self.fighterCtrl.IsDisappear then
        self.fighterCtrl:SetAlpha(self.alpha)
        self.alpha = self.alpha -0.03
        self:InvokeDelay(self.disapper, 0.02, self)
    else
        self:OnActionEnd()
    end
end

function DisapperAction:OnActionEnd()
    if self.fighterCtrl.IsDisappear then
        self.fighterCtrl:SetAlpha(0)
        if not BaseUtils.isnull(self.fighterCtrl.transform) then
            self.fighterCtrl.transform.position = Vector3.one*100
        end
    else
        self.fighterCtrl:SetAlpha(1)
    end
    self:InvokeAndClear(CombatEventType.End)
end


