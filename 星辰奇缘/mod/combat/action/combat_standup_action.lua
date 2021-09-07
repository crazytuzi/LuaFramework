-- 站立
StandupAction = StandupAction or BaseClass(CombatBaseAction)

function StandupAction:__init(brocastCtx, controller)
    self.controller = controller
end

function StandupAction:Play()
    self.controller:PlayAction(FighterAction.Standup)
    self:InvokeDelay(self.OnActionEnd, 1.2, self)
end

function StandupAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
