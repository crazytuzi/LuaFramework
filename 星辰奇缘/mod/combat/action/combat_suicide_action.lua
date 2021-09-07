-- 自杀
SuicideAction = SuicideAction or BaseClass(CombatBaseAction)

function SuicideAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.fighterId = self.actionData.self_id
    self.deadAction = DeadAction.New(self.brocastCtx, self.fighterId)
    self.deadAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
end

function SuicideAction:Play()
    self.deadAction:Play()
end

function SuicideAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
