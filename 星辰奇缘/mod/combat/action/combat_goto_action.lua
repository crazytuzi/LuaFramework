-- 瞬移
GoToAction = GoToAction or BaseClass(CombatBaseAction)

function GoToAction:__init(brocastCtx, controller, point)
    self.controller = controller
    self.point = point
end

function GoToAction:Play()
    self.controller:GoTo(self.point)
    self.controller:ReLocaHpBar()
    self:OnActionEnd()
end

function GoToAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
