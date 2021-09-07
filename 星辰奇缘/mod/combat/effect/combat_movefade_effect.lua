MoveFadeEffect = MoveFadeEffect or BaseClass(CombatBaseAction)

function MoveFadeEffect:__init(brocastCtx, panel)
    self.panel = panel
    self.moveEffect = UIMoveEffect.New(brocastCtx, panel, UIMoveDir.Up, 50, 1)
    self.fadeEffect = UIFadeEffect.New(brocastCtx, panel, 0, 1)

    self.syncAction = SyncSupporter.New(brocastCtx)
    self.syncAction:AddAction(self.moveEffect)
    self.syncAction:AddAction(self.fadeEffect)
    self.syncAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
end

function MoveFadeEffect:Play()
    self.panel:SetActive(true)
    self.syncAction:Play()
end

function MoveFadeEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
