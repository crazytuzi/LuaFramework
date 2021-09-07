-- 待机
WaitingAction = WaitingAction or BaseClass(CombatBaseAction)

function WaitingAction:__init(brocastCtx, actionData)
end

function WaitingAction:Play()
    self:OnActionEnd()
end

function WaitingAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
