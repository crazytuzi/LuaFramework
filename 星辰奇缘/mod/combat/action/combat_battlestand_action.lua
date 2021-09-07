-- 站立
BattleStandAction = BattleStandAction or BaseClass(CombatBaseAction)

function BattleStandAction:__init(brocastCtx, controller)
    self.controller = controller
end

function BattleStandAction:Play()
    self.controller:PlayAction(FighterAction.BattleStand)
    self:OnActionEnd()
end

function BattleStandAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
